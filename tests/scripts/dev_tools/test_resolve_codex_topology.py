"""Tests for deterministic Codex topology resolution."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools.resolve_codex_topology import (
    main,
    resolve_codex_topology,
)

if TYPE_CHECKING:
    from collections.abc import Callable


@pytest.mark.parametrize(
    ("language", "production_files", "test_files", "expected_agent"),
    [
        ("python", 3, 3, "python-typed-engineer"),
        ("powershell", 2, 3, "powershell-typed-engineer"),
        ("csharp", 3, 3, "csharp-typed-engineer"),
    ],
)
def test_standalone_budget_boundary_selects_typed_engineer(
    language: str,
    production_files: int,
    test_files: int,
    expected_agent: str,
) -> None:
    """Select the language engineer at each canonical direct-mode boundary."""

    receipt = resolve_codex_topology(
        [language], production_files, test_files, "standalone"
    )

    assert receipt["route"] == "small"
    assert receipt["topology"] == "typed_engineer"
    assert receipt["logical_agent"] == expected_agent
    assert receipt["routing_reason"] == "within_language_budget"


@pytest.mark.parametrize(
    ("language", "production_files", "test_files", "reason"),
    [
        ("python", 4, 3, "production_budget_exceeded"),
        ("powershell", 3, 3, "production_budget_exceeded"),
        ("csharp", 4, 3, "production_budget_exceeded"),
    ],
)
def test_over_budget_scope_selects_orchestrator(
    language: str, production_files: int, test_files: int, reason: str
) -> None:
    """Escalate production count beyond its language topology limit."""

    receipt = resolve_codex_topology(
        [language], production_files, test_files, "standalone"
    )

    assert receipt["route"] == "large"
    assert receipt["logical_agent"] == "orchestrator"
    assert receipt["routing_reason"] == reason


@pytest.mark.parametrize(
    ("language", "production_files", "test_files", "expected_agent"),
    [
        ("python", 3, 12, "python-typed-engineer"),
        ("powershell", 2, 12, "powershell-typed-engineer"),
        ("csharp", 3, 12, "csharp-typed-engineer"),
    ],
)
def test_test_batch_count_does_not_change_topology(
    language: str,
    production_files: int,
    test_files: int,
    expected_agent: str,
) -> None:
    """Keep test batch caps independent from the production-file topology axis."""

    receipt = resolve_codex_topology(
        [language], production_files, test_files, "standalone"
    )

    assert receipt["route"] == "small"
    assert receipt["logical_agent"] == expected_agent
    assert receipt["test_file_count"] == test_files


@pytest.mark.parametrize(
    ("languages", "cross_cutting", "reason"),
    [
        (["python", "csharp"], False, "cross_language"),
        (["python"], True, "cross_cutting"),
        (["rust"], False, "unsupported_language"),
        ([], False, "unsupported_language"),
        (["typescript"], False, "direct_mode_disabled"),
    ],
)
def test_non_direct_scope_selects_orchestrator(
    languages: list[str], cross_cutting: bool, reason: str
) -> None:
    """Escalate cross-surface and unsupported direct-mode scopes."""

    receipt = resolve_codex_topology(
        languages, 1, 1, "standalone", cross_cutting=cross_cutting
    )

    assert receipt["topology"] == "orchestrator"
    assert receipt["logical_agent"] == "orchestrator"
    assert receipt["routing_reason"] == reason


@pytest.mark.parametrize(
    ("production_files", "test_files"),
    [(0, 0), (-1, 1), (1, -1)],
)
def test_zero_or_negative_estimate_selects_orchestrator(
    production_files: int, test_files: int
) -> None:
    """Fail closed to orchestration when file-count estimates are unusable."""

    receipt = resolve_codex_topology(
        ["python"], production_files, test_files, "standalone"
    )

    assert receipt["routing_reason"] == "invalid_estimate"
    assert receipt["logical_agent"] == "orchestrator"


@pytest.mark.parametrize("context", ["epic_preparation_child", "epic_execution_child"])
def test_epic_child_context_always_selects_orchestrator(context: str) -> None:
    """Apply the epic child override even to an otherwise small Python scope."""

    receipt = resolve_codex_topology(["python"], 1, 1, context)

    assert receipt["route"] == "large"
    assert receipt["logical_agent"] == "orchestrator"
    assert receipt["routing_reason"] == "epic_child_context"


@pytest.mark.parametrize("persona", ["epic-planner", "epic-orchestrator"])
def test_root_epic_persona_is_forced(persona: str) -> None:
    """Resolve each root epic persona directly without file-count escalation."""

    receipt = resolve_codex_topology([], 0, 0, "standalone", root_persona=persona)

    assert receipt["route"] == "epic"
    assert receipt["logical_agent"] == persona
    assert receipt["root_persona"] == persona
    assert receipt["routing_reason"] == "forced_root_persona"


def test_language_normalization_is_stable() -> None:
    """Normalize case and duplicate language inputs before resolution."""

    receipt = resolve_codex_topology([" Python ", "PYTHON"], 1, 0, "standalone")

    assert receipt["languages"] == ["python"]
    assert receipt["logical_agent"] == "python-typed-engineer"


@pytest.mark.parametrize(
    "invoke",
    [
        lambda: resolve_codex_topology([""], 1, 1, "standalone"),
        lambda: resolve_codex_topology(["python"], cast("int", True), 1, "standalone"),
        lambda: resolve_codex_topology(["python"], 1, cast("int", True), "standalone"),
        lambda: resolve_codex_topology(
            ["python"], 1, 1, "standalone", cross_cutting=cast("bool", "yes")
        ),
        lambda: resolve_codex_topology([], 0, 0, "standalone", root_persona="unknown"),
        lambda: resolve_codex_topology(["python"], 1, 1, "unknown"),
    ],
)
def test_invalid_typed_input_is_rejected(invoke: Callable[[], object]) -> None:
    """Reject values that cannot form a deterministic typed receipt."""

    with pytest.raises(ValueError):
        invoke()


def test_root_persona_rejects_epic_child_context() -> None:
    """Keep root-persona invocation distinct from epic child delegation."""

    with pytest.raises(ValueError, match="requires standalone context"):
        resolve_codex_topology(
            [],
            0,
            0,
            "epic_execution_child",
            root_persona="epic-orchestrator",
        )


def test_cli_emits_stable_receipt(capsys: pytest.CaptureFixture[str]) -> None:
    """Expose the pure resolver through a machine-readable CLI."""

    exit_code = main(
        [
            "--language",
            "python",
            "--production-file-count",
            "2",
            "--test-file-count",
            "1",
            "--execution-context",
            "standalone",
        ]
    )

    output = json.loads(capsys.readouterr().out)
    assert exit_code == 0
    assert output["logical_agent"] == "python-typed-engineer"
    assert output["routing_reason"] == "within_language_budget"
