"""Cross-cutting verification for the shared portable handoff fixtures."""

from __future__ import annotations

import json
from copy import deepcopy
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools.orchestration_handoff_contract import (
    HandoffContractError,
    HandoffEnvelope,
    validate_history_chain,
    validate_semantic_contract,
)

if TYPE_CHECKING:
    from collections.abc import Callable

ROOT = Path(__file__).parents[3]
FIXTURES = ROOT / "tests" / "fixtures" / "orchestration-handoff" / "contract"
REGISTRY = json.loads(
    (ROOT / "config" / "orchestration-handoff-registry.json").read_text()
)
SUPPORTED_CAPABILITIES = tuple(REGISTRY["capabilities"]["supported"])
POSITIVE_FIXTURES = (
    "valid-ordinary-claude-to-codex.json",
    "valid-parallel-codex-to-claude.json",
)
NEGATIVE_CASES = cast(
    "list[dict[str, object]]",
    json.loads((FIXTURES / "invalid-contract-cases.json").read_text()),
)
BUILD_ENVELOPE = cast(
    "Callable[[dict[str, Any]], HandoffEnvelope]",
    vars(state_validator)["_build_portable_envelope"],
)


def _load(name: str) -> dict[str, Any]:
    return cast(
        "dict[str, Any]", json.loads((FIXTURES / name).read_text(encoding="utf-8"))
    )


def _apply_case(case: dict[str, object]) -> dict[str, Any]:
    envelope = deepcopy(_load(cast("str", case["base"])))
    path = cast("list[str | int]", case["path"])
    target: Any = envelope
    for component in path[:-1]:
        target = target[component]
    target[path[-1]] = case["value"]
    return envelope


def _failure_for(case: dict[str, object]) -> str | None:
    try:
        envelope = BUILD_ENVELOPE(_apply_case(case))
        validate_history_chain(envelope.handoff_history)
    except HandoffContractError as exc:
        if exc.field == "plan.path":
            return "HANDOFF_PLAN_PATH_INVALID"
        return "HANDOFF_HISTORY_INVALID"
    return validate_semantic_contract(
        envelope,
        requested_transition="prepared_to_atomic_execution",
        transition_state="preparation_complete",
        requested_phase="atomic_execution",
        supported_capabilities=SUPPORTED_CAPABILITIES,
    )


def test_shared_fixture_set_contains_only_verified_contract_cases() -> None:
    expected = {*POSITIVE_FIXTURES, "invalid-contract-cases.json"}
    assert {path.name for path in FIXTURES.glob("*.json")} == expected


@pytest.mark.parametrize("name", POSITIVE_FIXTURES)
def test_shared_positive_fixture_builds_immutable_contract(name: str) -> None:
    envelope = BUILD_ENVELOPE(_load(name))
    validate_history_chain(envelope.handoff_history)
    assert isinstance(envelope, HandoffEnvelope)


@pytest.mark.parametrize(
    "case",
    NEGATIVE_CASES,
    ids=[cast("str", case["id"]) for case in NEGATIVE_CASES],
)
def test_shared_negative_fixture_has_expected_failure(
    case: dict[str, object],
) -> None:
    assert _failure_for(case) == case["expected"]
