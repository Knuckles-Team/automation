#!/usr/bin/env python3
"""
FastMCP 2.0 Server with Standard Bearer Token Authentication
"""
import os
import ssl
import warnings
from typing import Optional
from datetime import datetime
import jwt
from jwt import PyJWKClient
from pydantic import BaseModel
from fastmcp import FastMCP
from fastapi import Request, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

# Suppress Pydantic deprecation warnings
warnings.filterwarnings("ignore", category=DeprecationWarning, module="pydantic")


# ========= Environment / Config =========
# Authentication mode: 'mock' or 'identity'
AUTH_MODE = os.getenv("AUTH_MODE", "mock")
IDENTITY_JWKS_URI = os.getenv("IDENTITY_JWKS_URI", "https://example.com/jwks")
EXPECTED_AUDIENCE = os.getenv("API_IDENTIFIER", "mcp-server-api")
# Scope variables
PRODUCT_READ_SCOPE = os.getenv("PRODUCT_READ_SCOPE", "mcpserverapi.product.read")
PRODUCT_WRITE_SCOPE = os.getenv("PRODUCT_WRITE_SCOPE", "mcpserverapi.product.write")
INVENTORY_READ_SCOPE = os.getenv("INVENTORY_READ_SCOPE", "mcpserverapi.inventory.read")
INVENTORY_WRITE_SCOPE = os.getenv("INVENTORY_WRITE_SCOPE", "mcpserverapi.inventory.write")

# ========= Models =========
class Product(BaseModel):
    id: int | None = None
    name: str
    price: float
    category: str
    description: str | None = None
class InventoryItem(BaseModel):
    id: int | None = None
    product_id: int
    quantity: int
    location: str
    last_updated: str | None = None
class AccessToken(BaseModel):
    token: str
    client_id: str
    subject: str
    scopes: list[str]
    claims: dict

# ========= Authentication =========
# HTTPBearer security scheme for standard Bearer token authentication
security = HTTPBearer(auto_error=False)
class IdentityAuthProvider:
    """Validates JWT tokens from Identity using JWKS"""
    def __init__(self):
        self.jwks_uri = IDENTITY_JWKS_URI
        self.expected_audience = EXPECTED_AUDIENCE
        self._jwks_client: Optional[PyJWKClient] = None
    def verify_token(self, token: str) -> Optional[AccessToken]:
        """Return AccessToken if valid, else None"""
        print(f" DEBUG: Received Bearer token for verification: '{token}'")
        print(f" Authentication mode: {AUTH_MODE}")

        # Handle authentication based on AUTH_MODE
        if AUTH_MODE.lower() == "mock":
            return self._verify_mock_token(token)
        elif AUTH_MODE.lower() == "identity":
            return self._verify_identity_token(token)
        else:
            print(f" Unknown AUTH_MODE: {AUTH_MODE}, defaulting to mock")
            return self._verify_mock_token(token)

    def _verify_mock_token(self, token: str) -> Optional[AccessToken]:
        """Handle mock authentication"""
        mock_tokens = [
            "valid_auth_token", "VALID_AUTH_TOKEN", "mock_token",
            "VALID_READ_SCOPE_TOKEN", "VALID_WRITE_SCOPE_TOKEN",
            "MOCK_TOKEN", "test_token", "valid_token", "bearer_token"
        ]

        if token in mock_tokens:
            print(f" USING MOCK AUTHENTICATION for Bearer token: {token}")
            return AccessToken(
                token=token,
                client_id="mock_client",
                subject="mock_user",
                scopes=[
                    PRODUCT_READ_SCOPE,
                    PRODUCT_WRITE_SCOPE,
                    INVENTORY_READ_SCOPE,
                    INVENTORY_WRITE_SCOPE
                ],
                claims={"sub": "mock_user", "client_id": "mock_client"}
            )
        else:
            print(f" Bearer token '{token}' not in mock token list")
            return None

    def _verify_identity_token(self, token: str) -> Optional[AccessToken]:
        """Handle Identity JWT authentication"""
        print(f" Attempting Identity JWT validation for token: {token[:10]}...")

        # Check if Identity is properly configured
        if not self.jwks_uri or self.jwks_uri == "https://example.com/jwks":
            print(f" Identity not configured properly. JWKS URI: {self.jwks_uri}")
            print(f" Falling back to mock authentication for development")
            return self._verify_mock_token(token)

        try:
            client = self._get_jwks_client()
            signing_key = client.get_signing_key_from_jwt(token)
            payload = jwt.decode(
                token,
                signing_key.key,
                algorithms=["RS256"],
                audience=self.expected_audience,
                options={"verify_exp": True},
            )
            scopes = payload.get("scope", [])
            if isinstance(scopes, str):
                scopes = scopes.split()
            print(f" Identity JWT validation successful")
            print(f" Subject: {payload.get('sub')}")
            print(f" Client ID: {payload.get('client_id', payload.get('azp', payload.get('sub')))}")
            print(f" Scopes: {scopes}")
            return AccessToken(
                token=token,
                client_id=payload.get("client_id", payload.get("azp", payload.get("sub"))),
                subject=payload.get("sub"),
                scopes=scopes,
                claims=payload,
            )
        except Exception as e:
            print(f" Identity JWT validation failed: {e}")
            print(f" Falling back to mock authentication for development")
            return self._verify_mock_token(token)

    def _get_jwks_client(self) -> PyJWKClient:
        if self._jwks_client is None:
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE
            self._jwks_client = PyJWKClient(
                self.jwks_uri,
                ssl_context=ssl_context,
            )
            return self._jwks_client

# Global auth provider instance
auth_provider = IdentityAuthProvider()
def get_current_user(
        credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
        fallback_token: Optional[str] = None
) -> AccessToken:
    """Get current authenticated user from Bearer token"""

    # Try to get token from Authorization header first
    token = None
    if credentials:
        token = credentials.credentials
    print(f" Extracted Bearer token from Authorization header: {token}")

    # Fallback to provided token (for backwards compatibility)
    if not token and fallback_token:
        token = fallback_token
    print(f" Using fallback token: {token}")

    if not token:
        print(" No Bearer token provided")
        raise HTTPException(status_code=401, detail="Bearer token required")

    access_token = auth_provider.verify_token(token)
    if not access_token:
        print(f" Bearer token validation failed")
        raise HTTPException(status_code=401, detail="Invalid Bearer token")

    print(f" Bearer authentication successful for user: {access_token.subject}")
    return access_token

def require_scope(required_scope: str):
    """Dependency to check if user has required scope"""
    def scope_checker(user: AccessToken = Depends(get_current_user)) -> AccessToken:
        if required_scope not in user.scopes:
            print(f" Insufficient permissions. Required: {required_scope}, Available: {user.scopes}")
            raise HTTPException(status_code=403, detail=f"Insufficient permissions for {required_scope}")
        return user
    return scope_checker


# ========= Sample Data =========
products_db = {
    1: Product(id=1, name="Gaming Laptop", price=1200.00, category="Electronics", description="High-performance gaming laptop"),
    2: Product(id=2, name="Wireless Mouse", price=25.99, category="Electronics", description="Ergonomic wireless mouse"),
    3: Product(id=3, name="Office Chair", price=299.99, category="Furniture", description="Comfortable office chair"),
    4: Product(id=4, name="Coffee Mug", price=12.50, category="Kitchen", description="Ceramic coffee mug"),
    5: Product(id=5, name="Smartphone", price=899.00, category="Electronics", description="Latest model smartphone")
}
inventory_db = {
    1: InventoryItem(id=1, product_id=1, quantity=15, location="Warehouse A", last_updated="2024-01-20T10:00:00Z"),
    2: InventoryItem(id=2, product_id=2, quantity=100, location="Warehouse A", last_updated="2024-01-20T10:00:00Z"),
    3: InventoryItem(id=3, product_id=3, quantity=25, location="Warehouse B", last_updated="2024-01-20T10:00:00Z"),
    4: InventoryItem(id=4, product_id=4, quantity=200, location="Warehouse A", last_updated="2024-01-20T10:00:00Z"),
    5: InventoryItem(id=5, product_id=5, quantity=50, location="Warehouse B", last_updated="2024-01-20T10:00:00Z")
}
# ========= FastMCP Server with Bearer Authentication =========
# Create FastMCP 2.0 server instance
mcp = FastMCP("E-commerce MCP Server with Bearer Authentication")

# ========= Tools =========
@mcp.tool()
def list_products(
        category: str = None,
        max_price: float = None,
        user: AccessToken = Depends(require_scope(PRODUCT_READ_SCOPE))
) -> list[dict]:
    """List all products with optional filtering by category and max price.
    Requires Bearer token with product read scope."""

    print(f" list_products called by user: {user.subject} with scope: {PRODUCT_READ_SCOPE}")

    products = list(products_db.values())
    if category:
        products = [p for p in products if p.category == category]
    if max_price:
        products = [p for p in products if p.price <= max_price]

    print(f" Returning {len(products)} products for authenticated user: {user.subject}")
    return [p.model_dump() for p in products]

@mcp.tool()
def create_product(
        name: str,
        price: float,
        category: str,
        description: str = None,
        user: AccessToken = Depends(require_scope(PRODUCT_WRITE_SCOPE))
) -> dict:
    """Create a new product. Requires Bearer token with product write scope."""

    print(f" create_product called by user: {user.subject} with scope: {PRODUCT_WRITE_SCOPE}")

    new_id = max(products_db.keys()) + 1 if products_db else 1
    new_product = Product(
        id=new_id,
        name=name,
        price=price,
        category=category,
        description=description
    )

    products_db[new_id] = new_product

    print(f" Created product {new_id} for authenticated user: {user.subject}")
    return new_product.model_dump()

@mcp.tool()
def list_inventory(
        location: str = None,
        product_id: int = None,
        user: AccessToken = Depends(require_scope(INVENTORY_READ_SCOPE))
) -> list[dict]:
    """List all inventory items with optional filtering by location and product ID.
    Requires Bearer token with inventory read scope."""

    print(f" list_inventory called by user: {user.subject} with scope: {INVENTORY_READ_SCOPE}")

    inventory = list(inventory_db.values())
    if location:
        inventory = [i for i in inventory if i.location == location]
    if product_id:
        inventory = [i for i in inventory if i.product_id == product_id]

    print(f" Returning {len(inventory)} inventory items for authenticated user: {user.subject}")
    return [i.model_dump() for i in inventory]

@mcp.tool()
def create_inventory_item(
        product_id: int,
        quantity: int,
        location: str,
        user: AccessToken = Depends(require_scope(INVENTORY_WRITE_SCOPE))
) -> dict:
    """Create a new inventory item. Requires Bearer token with inventory write scope."""

    print(f" create_inventory_item called by user: {user.subject} with scope: {INVENTORY_WRITE_SCOPE}")

    new_id = max(inventory_db.keys()) + 1 if inventory_db else 1
    new_item = InventoryItem(
        id=new_id,
        product_id=product_id,
        quantity=quantity,
        location=location,
        last_updated=datetime.now().isoformat() + "Z"
    )

    inventory_db[new_id] = new_item

    print(f" Created inventory item {new_id} for authenticated user: {user.subject}")
    return new_item.model_dump()

if __name__ == "__main__":
    print("Starting MCP server with SSE transport on http://0.0.0.0:8000/sse")
    print(" Standard Bearer token authentication enabled")
    print(" Authentication method: Authorization: Bearer <token>")
    print(f" Authentication mode: {AUTH_MODE}")
    print(" Supported scopes:")
    print(f" - {PRODUCT_READ_SCOPE}")
    print(f" - {PRODUCT_WRITE_SCOPE}")
    print(f" - {INVENTORY_READ_SCOPE}")
    print(f" - {INVENTORY_WRITE_SCOPE}")

    if AUTH_MODE.lower() == "mock":
        print(" Mock tokens accepted: mock_token, valid_auth_token, bearer_token")
    elif AUTH_MODE.lower() == "identity":
        print(f" Identity JWKS URI: {IDENTITY_JWKS_URI}")
        print(f" Expected audience: {EXPECTED_AUDIENCE}")
    if IDENTITY_JWKS_URI == "https://example.com/jwks":
        print(" WARNING: Using default JWKS URI - configure IDENTITY_JWKS_URI for production")

    mcp.run(transport="sse", host="0.0.0.0", port=8000)