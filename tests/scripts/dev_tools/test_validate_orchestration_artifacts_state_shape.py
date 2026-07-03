"""`orchestrator-state` payload-shape tests for the orchestration artifact validator.

Split out of `test_validate_orchestration_artifacts.py` (issue #275 remediation
cycle 2) because that file exceeded the repository's 500-line hard cap. This
module contains the residual, less-fixture-cohesive `orchestrator-state`
payload-shape tests and the two helper functions used exclusively by them; the
shared `build_valid_orchestrator_state` builder is imported from the sibling
module rather than duplicated, following the sibling-module convention already
used by `test_validate_orchestration_artifacts_dispatch.py`. This module is
distinct from the pre-existing `test_validate_orchestrator_state.py`, which
tests a different module, `scripts.dev_tools.validate_orchestrator_state`,
directly.
"""

from __future__ import annotations

import json
from typing import cast

import scripts.dev_tools.validate_orchestration_artifacts as validator
from tests.scripts.dev_tools.test_validate_orchestration_artifacts import (
    build_valid_orchestrator_state,
)


def get_first_receipt(state: dict[str, object]) -> dict[str, object]:
    """Return the first typed delegation receipt from a valid state payload."""

    receipts = cast("list[dict[str, object]]", state["delegation_receipts"])
    return dict(receipts[0])


def build_namespaced_orchestrator_state() -> dict[str, object]:
    """Return a valid orchestrator-state payload using the promotion namespace."""

    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = {
        "promotion": {
            "potential_entry": {"path": "docs/features/potential/demo.md"},
            "issue": "https://github.com/drmoisan/drm-copilot/issues/168",
            "feature_folder": {
                "path": (
                    "docs/features/active/2026-04-29-"
                    "harden-feature-promotion-lifecycle-mcp-only-168"
                )
            },
        }
    }
    return state


def test_validate_orchestrator_state_text_requires_receipts_for_completion() -> None:
    """Reject complete-state checkpoints that still show blocked delegation."""

    state = build_valid_orchestrator_state()
    state["step8_status"] = "blocked"

    errors = validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("step8_status is blocked" in error for error in errors)


def test_validate_orchestrator_state_text_accepts_legacy_list_delegation_receipts() -> (
    None
):
    """Allow the legacy list-based delegation receipt payload."""

    errors = validator.validate_orchestrator_state_text(
        json.dumps(build_valid_orchestrator_state())
    )

    assert errors == []


def test_validate_orchestrator_state_text_accepts_promotion_receipt_namespace() -> None:
    """Allow the additive promotion receipt namespace without normalizing values."""

    errors = validator.validate_orchestrator_state_text(
        json.dumps(build_namespaced_orchestrator_state())
    )

    assert errors == []


def test_validate_orchestrator_state_text_rejects_json_root_that_is_not_an_object() -> (
    None
):
    """Reject orchestrator-state payloads whose JSON root is not an object."""

    errors = validator.validate_orchestrator_state_text("[]")

    assert errors == ["Checkpoint root must be a JSON object."]


def test_validate_orchestrator_state_rejects_noncontainer_receipts() -> None:
    """Reject scalar delegation receipt payloads that are not containers."""

    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = "invalid"

    errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert any(
        "delegation_receipts must be a list or object namespace" in error
        for error in errors
    )


def test_validate_orchestrator_state_rejects_unknown_promotion_receipt_keys() -> None:
    """Reject nested promotion receipt keys outside the documented namespace."""

    state = build_namespaced_orchestrator_state()
    promotion = cast(
        "dict[str, object]",
        cast("dict[str, object]", state["delegation_receipts"])["promotion"],
    )
    promotion["extra_key"] = {"unexpected": True}

    errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert any(
        "delegation_receipts.promotion contains unsupported key: extra_key" in error
        for error in errors
    )


def test_validate_orchestrator_state_text_rejects_receipt_missing_result_signal() -> (
    None
):
    """Reject receipts that omit the contract-required result signal."""

    state = build_valid_orchestrator_state()
    receipt = get_first_receipt(state)
    receipt.pop("result_signal")
    state["delegation_receipts"] = [receipt]

    errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert any("missing key: result_signal" in error for error in errors)


def test_validate_orchestrator_state_rejects_receipt_nonlist_artifact_paths() -> None:
    """Reject receipts whose artifact path payload is not a list."""

    state = build_valid_orchestrator_state()
    receipt = get_first_receipt(state)
    receipt["artifact_paths"] = "docs/features/active/feature-1/plan.md"
    state["delegation_receipts"] = [receipt]

    errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert any("artifact_paths must be a list" in error for error in errors)
