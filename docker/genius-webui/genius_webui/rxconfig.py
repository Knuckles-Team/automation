import reflex as rx
import os

webui_api_url = os.getenv("WEBUI_API_URL", "http://localhost:8000")

config = rx.Config(
    app_name="genius_webui",
    api_url=webui_api_url,
)