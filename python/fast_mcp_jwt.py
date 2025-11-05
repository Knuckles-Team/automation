#!/usr/bin/env python3
"""
FastMCP 2.0 Server with Native JWT + Optional Eunomia
Supports: JWKS, HMAC, Static Keys | Scope-based access
"""

import os
import sys
from typing import Optional
from datetime import datetime
from pydantic import BaseModel

from fastmcp import FastMCP
from fastmcp.server.auth import JWTVerifier
from fastmcp.server.middleware import Middleware
from fastapi import HTTPException, Depends

# Optional Eunomia
try:
    from eunomia_mcp import create_eunomia_middleware
    EUNOMIA_AVAILABLE = True
except ImportError:
    EUNOMIA_AVAILABLE = False

# ========= Config from Env =========
AUTH_MODE = os.getenv("AUTH_MODE", "mock")  # mock | jwt
JWKS_URI = os.getenv("IDENTITY_JWKS_URI")
ISSUER = os.getenv("TOKEN_ISSUER")
AUDIENCE = os.getenv("API_IDENTIFIER", "mcp-server-api")
ALGORITHM = os.getenv("TOKEN_ALGORITHM")  # HS256, RS256, etc.
SECRET = os.getenv("TOKEN_SECRET")  # for HMAC or static key
PUBLIC_KEY = os.getenv("TOKEN_PUBLIC_KEY")  # PEM file or inline
REQUIRED_SCOPES = os.getenv("REQUIRED_SCOPES", "").split(",") if os.getenv("REQUIRED_SCOPES") else None

# Scopes
PRODUCT_READ = os.getenv("PRODUCT_READ_SCOPE", "mcpserverapi.product.read")
PRODUCT_WRITE = os.getenv("PRODUCT_WRITE_SCOPE", "mcpserverapi.product.write")
INVENTORY_READ = os.getenv("INVENTORY_READ_SCOPE", "mcpserverapi.inventory.read")
INVENTORY_WRITE = os.getenv("INVENTORY_WRITE_SCOPE", "mcpserverapi.inventory.write")

# Eunomia
EUNOMIA_TYPE = os.getenv("EUNOMIA_TYPE", "none")  # none | embedded | remote
EUNOMIA_POLICY_FILE = os.getenv("EUNOMIA_POLICY_FILE", "mcp_policies.json")
EUNOMIA_REMOTE_URL = os.getenv("EUNOMIA_REMOTE_URL")

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

# ========= Sample Data =========
products_db = {
    1: Product(id=1, name="Laptop", price=1200, category="Electronics"),
    2: Product(id=2, name="Mouse", price=25, category="Electronics"),
}
inventory_db = {
    1: InventoryItem(id=1, product_id=1, quantity=10, location="A1"),
    2: InventoryItem(id=2, product_id=2, quantity=50, location="A2"),
}

# ========= FastMCP Server =========
mcp = FastMCP("E-commerce MCP with JWT + Eunomia")

# ========= JWT Auth Setup =========
if AUTH_MODE == "jwt":
    if not (JWKS_URI or SECRET or PUBLIC_KEY):
        print("JWT mode requires JWKS_URI, TOKEN_SECRET, or TOKEN_PUBLIC_KEY")
        sys.exit(1)

    # Load static key if file
    public_key = None
    if PUBLIC_KEY and os.path.isfile(PUBLIC_KEY):
        with open(PUBLIC_KEY) as f:
            public_key = f.read()

    auth = JWTVerifier(
        jwks_uri=JWKS_URI,
        public_key=SECRET or public_key,
        issuer=ISSUER,
        audience=AUDIENCE,
        algorithm=ALGORITHM if ALGORITHM and ALGORITHM.startswith("HS") else None,
        required_scopes=REQUIRED_SCOPES,
    )
    print(f"JWTVerifier enabled | Mode: {'JWKS' if JWKS_URI else 'HMAC' if ALGORITHM and ALGORITHM.startswith('HS') else 'Static'}")
else:
    print("Using mock auth (no JWT)")

# ========= Scope Dependency =========
def require_scope(scope: str):
    def checker():
        if AUTH_MODE != "jwt":
            return  # Mock mode: allow all
        claims = mcp.context.auth.claims
        scopes = claims.get("scope", [])
        if isinstance(scopes, str):
            scopes = scopes.split()
        if scope not in scopes:
            raise HTTPException(403, f"Missing scope: {scope}")
    return checker

# ========= Tools =========
@mcp.tool()
def list_products(
        category: Optional[str] = None,
        max_price: Optional[float] = None,
        _auth=Depends(require_scope(PRODUCT_READ))
) -> list[dict]:
    products = list(products_db.values())
    if category:
        products = [p for p in products if p.category == category]
    if max_price:
        products = [p for p in products if p.price <= max_price]
    return [p.model_dump() for p in products]

@mcp.tool()
def create_product(
        name: str, price: float, category: str, description: Optional[str] = None,
        _auth=Depends(require_scope(PRODUCT_WRITE))
) -> dict:
    new_id = max(products_db.keys()) + 1
    product = Product(id=new_id, name=name, price=price, category=category, description=description)
    products_db[new_id] = product
    return product.model_dump()

@mcp.tool()
def list_inventory(
        location: Optional[str] = None,
        product_id: Optional[int] = None,
        _auth=Depends(require_scope(INVENTORY_READ))
) -> list[dict]:
    items = list(inventory_db.values())
    if location:
        items = [i for i in items if i.location == location]
    if product_id:
        items = [i for i in items if i.product_id == product_id]
    return [i.model_dump() for i in items]

@mcp.tool()
def create_inventory_item(
        product_id: int, quantity: int, location: str,
        _auth=Depends(require_scope(INVENTORY_WRITE))
) -> dict:
    new_id = max(inventory_db.keys()) + 1
    item = InventoryItem(
        id=new_id, product_id=product_id, quantity=quantity,
        location=location, last_updated=datetime.now().isoformat() + "Z"
    )
    inventory_db[new_id] = item
    return item.model_dump()

# ========= Optional Eunomia Middleware =========
if EUNOMIA_TYPE != "none" and EUNOMIA_AVAILABLE:
    if EUNOMIA_TYPE == "embedded":
        middleware = create_eunomia_middleware(policy_file=EUNOMIA_POLICY_FILE)
    elif EUNOMIA_TYPE == "remote":
        middleware = create_eunomia_middleware(eunomia_endpoint=EUNOMIA_REMOTE_URL)
    else:
        print("Invalid EUNOMIA_TYPE")
        sys.exit(1)
    mcp.add_middleware(middleware)
    print(f"Eunomia enabled: {EUNOMIA_TYPE}")
elif EUNOMIA_TYPE != "none":
    print("Eunomia requested but not installed: pip install eunomia-mcp")

# ========= Run =========
if __name__ == "__main__":
    print(f"\nStarting MCP Server | Transport: sse | Port: 8000")
    print(f"Auth: {'JWT' if AUTH_MODE == 'jwt' else 'Mock'}")
    if AUTH_MODE == "jwt":
        print(f"  - JWKS: {JWKS_URI or 'None'}")
        print(f"  - Audience: {AUDIENCE}")
        print(f"  - Required Scopes: {REQUIRED_SCOPES}")
    print(f"Eunomia: {'Enabled' if EUNOMIA_TYPE != 'none' and EUNOMIA_AVAILABLE else 'Disabled'}")
    print("\nTools require scopes:")
    print(f"  list_products → {PRODUCT_READ}")
    print(f"  create_product → {PRODUCT_WRITE}")
    print(f"  list_inventory → {INVENTORY_READ}")
    print(f"  create_inventory_item → {INVENTORY_WRITE}\n")

    mcp.run(transport="sse", host="0.0.0.0", port=8000)