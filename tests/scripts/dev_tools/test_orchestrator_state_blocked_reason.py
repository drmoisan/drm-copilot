"""Tests for the orchestrator-state ``blocked_reason`` partition module (#523).

The partition module publishes the ``blocked_reason`` vocabulary as the
not-blocked member ``none`` plus two disjoint partitions (mechanical and
non-mechanical) and a pure classifier. These tests pin the partitions to the
committed oracle ``tests/fixtures/orchestrator_state_blocked_reason_partition.json``
(read in place; no temporary file is created), check that the primary validator
consumes the same constant, and enumerate the classifier over the whole
vocabulary plus the invalid-value classes. Property-based testing libraries are
not dependencies of this repository, so exhaustive parametrized enumeration is
used instead.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

import scripts.dev_tools._orchestrator_state_blocked_reason as blocked_reason
import scripts.dev_tools.validate_orchestrator_state as state_validator

_REPO_ROOT = Path(__file__).resolve().parents[3]
_PARTITION_ORACLE = (
    _REPO_ROOT
    / "tests"
    / "fixtures"
    / "orchestrator_state_blocked_reason_partition.json"
)

_MECHANICAL = (
    "spawn_agent_unavailable",
    "delegation_launch_failed",
    "delegate_no_receipt",
    "delegate_contract_incomplete",
    "validator_failed",
    "user_requested_stop",
)
_NON_MECHANICAL = (
    "premise_falsified",
    "external_dependency",
    "policy_hold",
    "awaiting_ci",
    "human_decision_required",
)
_INVALID_VALUES: tuple[object, ...] = (
    "halted",
    "Premise_Falsified",
    7,
    ["none"],
    {"k": "none"},
)


def _load_oracle() -> dict[str, list[str]]:
    """Return the committed partition oracle as a mapping of sorted lists."""

    return cast(
        "dict[str, list[str]]",
        json.loads(_PARTITION_ORACLE.read_text(encoding="utf-8")),
    )


def test_partitions_are_disjoint() -> None:
    """The mechanical and non-mechanical partitions share no member and omit none."""

    # Arrange
    mechanical = blocked_reason.MECHANICAL_BLOCKED_REASONS
    non_mechanical = blocked_reason.NON_MECHANICAL_BLOCKED_REASONS

    # Act
    overlap = mechanical & non_mechanical

    # Assert
    assert overlap == frozenset(), f"partitions overlap: {sorted(overlap)}"
    assert "none" not in mechanical
    assert "none" not in non_mechanical


def test_vocabulary_is_none_plus_both_partitions() -> None:
    """The published vocabulary is exactly ``none`` plus both partitions."""

    # Arrange
    expected = (
        {"none"}
        | blocked_reason.MECHANICAL_BLOCKED_REASONS
        | blocked_reason.NON_MECHANICAL_BLOCKED_REASONS
    )

    # Act
    actual = blocked_reason.VALID_BLOCKED_REASONS

    # Assert
    assert actual == expected
    assert len(actual) == 12


def test_validator_consumes_the_module_constant() -> None:
    """The primary validator's vocabulary equals the partition module's constant."""

    # Arrange
    module_constant = blocked_reason.VALID_BLOCKED_REASONS

    # Act
    validator_constant = state_validator.VALID_BLOCKED_REASONS

    # Assert
    assert validator_constant == module_constant


def test_partitions_match_the_oracle() -> None:
    """Each partition equals the corresponding sorted list in the committed oracle."""

    # Arrange
    oracle = _load_oracle()

    # Act
    actual = {
        "not_blocked": ["none"],
        "mechanical": sorted(blocked_reason.MECHANICAL_BLOCKED_REASONS),
        "non_mechanical": sorted(blocked_reason.NON_MECHANICAL_BLOCKED_REASONS),
    }

    # Assert
    assert actual == oracle


@pytest.mark.parametrize("value", [None, "none"])
def test_classify_returns_not_blocked(value: object) -> None:
    """JSON null and ``none`` classify as not blocked."""

    # Act
    result = blocked_reason.classify_blocked_reason(value)

    # Assert
    assert result == "not_blocked"


@pytest.mark.parametrize("value", _MECHANICAL)
def test_classify_returns_mechanical(value: str) -> None:
    """Each of the six validator-enforced members classifies as mechanical."""

    # Act
    result = blocked_reason.classify_blocked_reason(value)

    # Assert
    assert result == "mechanical"


@pytest.mark.parametrize("value", _NON_MECHANICAL)
def test_classify_returns_non_mechanical(value: str) -> None:
    """Each of the five new members classifies as non-mechanical."""

    # Act
    result = blocked_reason.classify_blocked_reason(value)

    # Assert
    assert result == "non_mechanical"


@pytest.mark.parametrize("value", _INVALID_VALUES, ids=repr)
def test_classify_rejects_invalid_values(value: object) -> None:
    """Out-of-vocabulary strings, case variants, and non-strings raise ValueError."""

    # Act / Assert
    with pytest.raises(ValueError, match=r"^invalid blocked_reason: "):
        blocked_reason.classify_blocked_reason(value)
