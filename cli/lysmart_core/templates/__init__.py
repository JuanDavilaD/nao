"""Template engine module for LySmart providers.

This module provides a Jinja2-based templating system that allows users
to customize the output of sync providers (databases, repos, etc.).

Default templates are stored in this package and can be overridden by
placing templates with the same name in the project's `templates/` directory.

Additionally, this module supports rendering user Jinja templates in the
context folder, making the `lysmart` object available for accessing provider data.

Example user template (docs/report.md.j2):
    # {{ lysmart.config.project_name }}

    {{ lysmart.notion.page('https://notion.so/...').content }}
"""

from .context import LySmartContext, NotionPage, NotionProvider, create_lysmart_context
from .engine import TemplateEngine, get_template_engine
from .render import (
    TemplateRenderResult,
    discover_templates,
    render_all_templates,
    render_template,
)

__all__ = [
    # Engine
    "TemplateEngine",
    "get_template_engine",
    # Context
    "LySmartContext",
    "NotionPage",
    "NotionProvider",
    "create_lysmart_context",
    # Render
    "TemplateRenderResult",
    "discover_templates",
    "render_template",
    "render_all_templates",
]
