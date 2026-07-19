"""Discovery package: the `dev.discovery.*` command namespace package.

This package hosts the repository-local domain-profile configuration contract and its
typed, fail-fast loader. Domain specificity is supplied at runtime by the profile file,
never hardcoded in this package.

Public loader surface:
    DomainProfile, LegacySourceConfig, TargetConfig, TechnologyStackConfig,
    ArtifactsConfig, DomainProfileError, parse_domain_profile_text,
    load_domain_profile, DEFAULT_PROFILE_FILENAME.
"""

from scripts.dev_tools.discovery.domain_profile import (
    DEFAULT_PROFILE_FILENAME,
    load_domain_profile,
    parse_domain_profile_text,
)
from scripts.dev_tools.discovery.domain_profile_models import (
    ArtifactsConfig,
    DomainProfile,
    DomainProfileError,
    LegacySourceConfig,
    TargetConfig,
    TechnologyStackConfig,
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
