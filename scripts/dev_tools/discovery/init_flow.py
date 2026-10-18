"""Preserve legacy imports while the installed runtime owns initialization."""

from drm_copilot_discovery.init_flow import (
    create_discovery_workspace,
    substitute_placeholders,
    validate_target_path,
    validate_template_set,
)

__all__ = [
    "create_discovery_workspace",
    "substitute_placeholders",
    "validate_target_path",
    "validate_template_set",
]
