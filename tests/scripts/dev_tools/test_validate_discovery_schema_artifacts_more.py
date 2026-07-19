"""Additional unit tests for the final three discovery schema validators.

Purpose:
    Cover `validate_unspecified_behavior_text`, `validate_product_decision_text`,
    and `validate_evidence_reference_text` with a `decision_id`-requiring
    inline literal schema, split from `test_validate_discovery_schema_artifacts.py`
    per the repository's 500-line file cap.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest

import scripts.dev_tools.validate_discovery_schema_artifacts as discovery_schema

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from _pytest.monkeypatch import MonkeyPatch

_DECISION_ID_SCHEMA: dict[str, object] = {
    "type": "object",
    "required": ["decision_id"],
    "properties": {"decision_id": {"type": "string"}},
}


def _decision_id_schema(_uri: str, _cache_dir: Path) -> dict[str, object]:
    """Stand in for `load_schema` requiring `decision_id`."""
    return _DECISION_ID_SCHEMA


@pytest.mark.parametrize(
    "validator",
    [
        discovery_schema.validate_unspecified_behavior_text,
        discovery_schema.validate_product_decision_text,
        discovery_schema.validate_evidence_reference_text,
    ],
)
def test_final_three_schema_validators_accept_and_reject_fixtures(
    validator: Callable[[str], list[str]], monkeypatch: MonkeyPatch
) -> None:
    """Each of these three validators should accept a conforming fixture and
    reject a fixture missing the required `decision_id` field."""
    monkeypatch.setattr(discovery_schema, "load_schema", _decision_id_schema)

    conforming_errors = validator(
        json.dumps(
            {"$schema": "https://example.test/schema.json", "decision_id": "abc"}
        )
    )
    assert conforming_errors == []

    non_conforming_errors = validator(
        json.dumps({"$schema": "https://example.test/schema.json"})
    )
    assert len(non_conforming_errors) == 1
    assert "decision_id" in non_conforming_errors[0]
