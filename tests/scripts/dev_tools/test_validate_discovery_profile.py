"""Unit tests for `validate_discovery_profile.validate_profile_text`."""

from __future__ import annotations

from scripts.dev_tools.validate_discovery_profile import validate_profile_text


def test_validate_profile_text_rejects_empty_document() -> None:
    """An empty document should report a single, specific error."""
    assert validate_profile_text("") == ["Profile document is empty."]


def test_validate_profile_text_rejects_malformed_yaml() -> None:
    """Malformed YAML should report a single error string, never raise."""
    errors = validate_profile_text("key: [unterminated")

    assert len(errors) == 1


def test_validate_profile_text_rejects_non_mapping_root() -> None:
    """A non-mapping root (a YAML sequence) should be rejected explicitly."""
    errors = validate_profile_text("- one\n- two\n")

    assert errors == ["Profile document root must be a mapping."]


def test_validate_profile_text_reports_missing_legacy_source_path() -> None:
    """A mapping missing the placeholder required field should be flagged."""
    errors = validate_profile_text("some_other_key: value\n")

    assert errors == ["Missing required field: legacy_source_path."]


def test_validate_profile_text_accepts_conforming_minimal_profile() -> None:
    """A mapping with the placeholder required field should pass."""
    errors = validate_profile_text("legacy_source_path: /path/to/legacy\n")

    assert errors == []
