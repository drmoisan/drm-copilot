"""Regression tests for the `scripts.dev_tools.discovery` package export surface.

These tests guard the public re-export surface of the discovery package
``__init__`` so it cannot silently regress again (feature #362, cycle 1). Each
name re-exported from the package must be the identical object exported by its
defining submodule (`domain_profile` / `domain_profile_models`). The tests are
deterministic and perform no filesystem I/O.
"""

from __future__ import annotations

from scripts.dev_tools import discovery
from scripts.dev_tools.discovery import domain_profile, domain_profile_models


def test_package_reexports_are_identical_to_submodule_objects() -> None:
    """Each package-level name is the same object as its submodule counterpart."""
    # Arrange / Act / Assert: loader names originate in `domain_profile`.
    assert discovery.load_domain_profile is domain_profile.load_domain_profile
    assert (
        discovery.parse_domain_profile_text is domain_profile.parse_domain_profile_text
    )
    assert discovery.DEFAULT_PROFILE_FILENAME is domain_profile.DEFAULT_PROFILE_FILENAME
    # Value-object and error names originate in `domain_profile_models`.
    assert discovery.DomainProfile is domain_profile_models.DomainProfile
    assert discovery.DomainProfileError is domain_profile_models.DomainProfileError


def test_package_all_exposes_the_expected_public_surface() -> None:
    """`__all__` lists exactly the documented public loader surface."""
    # Arrange
    expected = {
        "DEFAULT_PROFILE_FILENAME",
        "ArtifactsConfig",
        "DomainProfile",
        "DomainProfileError",
        "LegacySourceConfig",
        "TargetConfig",
        "TechnologyStackConfig",
        "load_domain_profile",
        "parse_domain_profile_text",
    }
    # Act / Assert
    assert set(discovery.__all__) == expected
    # Every advertised name must be importable from the package namespace.
    for name in expected:
        assert hasattr(discovery, name), f"missing re-export: {name}"
