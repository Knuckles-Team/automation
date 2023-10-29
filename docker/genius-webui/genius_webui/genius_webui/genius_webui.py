"""Welcome to Reflex!."""

import reflex as rx
from genius_webui import styles
from genius_webui.components import chat, modal, navbar, sidebar
from genius_webui.state import State


async def assimilate(item_id: int):
    return {"my_result": item_id}


def index() -> rx.Component:
    """The main app."""
    return rx.vstack(
        navbar(),
        chat.chat(),
        chat.action_bar(),
        sidebar(),
        modal(),
        bg=styles.bg_dark_color,
        color=styles.text_light_color,
        min_h="100vh",
        align_items="stretch",
        spacing="0",
    )


# Add state and page to the app.
app = rx.App(state=State, style=styles.base_style)
app.add_page(index)
app.api.add_api_route("/assimilate/{item_id}", assimilate)
app.compile()
