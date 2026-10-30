"""Exercise remaining legacy wrappers using actual frozen schema fixtures."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import pytest

import scripts.dev_tools.validate_discovery_schema_artifacts as discovery_schema
from tests.scripts.dev_tools.test_validate_discovery_schema_artifacts import (
    fixture_text,
)

if TYPE_CHECKING:
    from collections.abc import Callable


@pytest.mark.parametrize(
    ("validator", "kind"),
    [
        (discovery_schema.validate_unspecified_behavior_text, "unspecified-behavior"),
        (discovery_schema.validate_product_decision_text, "product-decision"),
        (discovery_schema.validate_evidence_reference_text, "evidence-reference"),
    ],
)
def test_final_three_schema_validators_accept_and_reject_real_fixtures(
    validator: Callable[[str], list[str]],
    kind: str,
) -> None:
    """Each wrapper preserves positive and required-property negative behavior."""
    text = fixture_text(kind)
    document = cast("dict[str, object]", json.loads(text))
    del document["id"]

    assert validator(text) == []
    errors = validator(json.dumps(document))
    assert len(errors) == 1
    assert "'id' is a required property" in errors[0]
