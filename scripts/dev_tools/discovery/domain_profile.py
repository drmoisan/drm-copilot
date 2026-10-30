"""Compatibility imports for the authoritative installed discovery runtime."""

from drm_copilot_discovery.domain_profile import (
    DEFAULT_PROFILE_FILENAME,
    ArtifactsConfig,
    DomainProfile,
    DomainProfileError,
    LegacySourceConfig,
    TargetConfig,
    TechnologyStackConfig,
    load_domain_profile,
    parse_domain_profile_text,
)

__all__ = [
    "DEFAULT_PROFILE_FILENAME",
    "ArtifactsConfig",
    "DomainProfile",
    "DomainProfileError",
    "LegacySourceConfig",
    "TargetConfig",
    "TechnologyStackConfig",
    "load_domain_profile",
    "parse_domain_profile_text",
]
