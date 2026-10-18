"""Compatibility imports for the authoritative installed discovery runtime."""

from pathlib import Path

from drm_copilot_discovery.init_models import (
    ARTIFACT_RELATIVE_PATHS,
    DOMAIN_PROFILE_RELATIVE_PATH,
    EXPECTED_TEMPLATE_RELATIVE_PATHS,
    OUTPUT_RELATIVE_PATHS,
    FileSystem,
    RealFileSystem,
)

__all__ = [
    "ARTIFACT_RELATIVE_PATHS",
    "DOMAIN_PROFILE_RELATIVE_PATH",
    "EXPECTED_TEMPLATE_RELATIVE_PATHS",
    "OUTPUT_RELATIVE_PATHS",
    "FileSystem",
    "RealFileSystem",
    "resolve_default_template_root",
]


def resolve_default_template_root() -> Path:
    """Return the unchanged checkout template path for legacy initialization.

    This no-argument compatibility resolver performs no template I/O. Installed
    resource lookup belongs to the package resource boundary; only the existing
    repository initializer still needs this checkout-specific location.
    """
    return Path(__file__).resolve().parents[3] / "docs" / "discovery" / "templates"
