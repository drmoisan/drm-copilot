"""Verify the profile adapter delegates real v2 validation and explicit v1 reads."""

from __future__ import annotations

import json

import pytest

from scripts.dev_tools.validate_discovery_profile import validate_profile_text
from tests.discovery_runtime.test_profile_v2 import (
    profile_document,
    profile_extension_catalog,
    profile_text,
)
from tests.scripts.dev_tools.discovery.test_domain_profile import VALID_MINIMAL


@pytest.mark.parametrize("text", ("", "key: [unterminated", "- one\n- two\n"))
def test_profile_adapter_rejects_empty_malformed_and_non_mapping_documents(
    text: str,
) -> None:
    """Parser failures remain actionable text errors without escaping exceptions."""
    errors = validate_profile_text(text)

    assert len(errors) == 1 and errors[0]


def test_profile_adapter_rejects_placeholder_and_missing_real_contract_fields() -> None:
    """The former placeholder can no longer claim a valid discovery profile."""
    assert validate_profile_text("legacy_source_path: /path/to/legacy\n")
    document = profile_document()
    del document["production_roots"]

    errors = validate_profile_text(json.dumps(document))

    assert len(errors) == 1 and "production_roots" in errors[0]


def test_profile_adapter_accepts_complete_authoritative_v2_contract() -> None:
    """A complete current profile passes without a second validation engine."""
    assert validate_profile_text(profile_text()) == []


def test_profile_adapter_preserves_only_explicit_v1_compatibility() -> None:
    """Caller-selected legacy parsing remains valid and cannot become a v2 claim."""
    assert validate_profile_text(VALID_MINIMAL, schema_version="1.0.0") == []
    assert validate_profile_text(VALID_MINIMAL)
    assert validate_profile_text(profile_text(), schema_version="1.0.0")
    assert (
        "Unsupported profile schema version"
        in validate_profile_text(profile_text(), schema_version="2.0.1")[0]
    )


def test_profile_adapter_enforces_supplied_extension_binding_and_payload() -> None:
    """Declared extensions need pinned bytes; legacy readers cannot accept catalogs."""
    document, catalog = profile_extension_catalog()

    assert validate_profile_text(json.dumps(document), catalog=catalog) == []
    assert validate_profile_text(json.dumps(document))
    assert (
        "do not accept extension catalogs"
        in validate_profile_text(
            VALID_MINIMAL, schema_version="1.0.0", catalog=catalog
        )[0]
    )
