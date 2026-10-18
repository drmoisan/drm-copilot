"""Compatibility imports for the authoritative installed discovery runtime."""

from drm_copilot_discovery.io import (
    ArtifactValidationError,
    ArtifactValidator,
    read_artifact_text,
    validate_or_raise,
    write_report,
)

__all__ = [
    "ArtifactValidationError",
    "ArtifactValidator",
    "read_artifact_text",
    "validate_or_raise",
    "write_report",
]
