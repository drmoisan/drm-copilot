"""Plan acceptance-gate wiring tests for the orchestration artifact validator.

Covers the two-channel entry point, the `--workspace-root` option, the CLI
warning prefix, and the byte identity of the seven pre-existing structural
error strings recorded in the Phase 0 baseline artifact
`evidence/baseline/existing-plan-error-strings.2026-08-20T11-40.md`.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

import scripts.dev_tools.validate_orchestration_artifacts as validator
from scripts.dev_tools.plan_gate_discrimination import PlanGateContext
from tests.scripts.dev_tools.test_validate_orchestration_artifacts import (
    build_read_text_stub,
)

if TYPE_CHECKING:
    from collections.abc import Callable

    from pytest import CaptureFixture, MonkeyPatch

_CLEAN_PLAN = "\n".join(
    [
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Do the thing",
        "  - Acceptance: `poetry run pytest -q --cov=scripts.dev_tools.foo` passes.",
        "",
    ]
)

_G1_PLAN = "\n".join(
    [
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Do the thing",
        "  - Acceptance: `poetry run pytest -q --cov=scripts/dev_tools/foo.py` passes.",
        "",
    ]
)

_G4_PLAN = "\n".join(
    [
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Do the thing",
        "  - Acceptance: `poetry run pytest -q --cov tests/foo` passes.",
        "",
    ]
)


class _StubGitRepository:
    """Tracked-tree stub that answers every query negatively."""

    def files_containing(self, literal: str) -> list[str]:
        """Return no matches."""

        return []

    def is_tracked_file(self, path: str) -> bool:
        """Return False."""

        return False

    def is_tracked_directory(self, path: str) -> bool:
        """Return False."""

        return False

    def read_tracked_text(self, path: str) -> str:
        """Return an empty string."""

        return ""


class _StubFileSystem:
    """Read-only filesystem stub that answers negatively and reads nothing."""

    def is_file(self, path: Path) -> bool:
        """Return False."""

        return False

    def is_dir(self, path: Path) -> bool:
        """Return False."""

        return False

    def read_text(self, path: Path) -> str:
        """Return an empty string."""

        return ""

    def read_bytes(self, path: Path) -> bytes:
        """Return empty bytes."""

        return b""

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        """Return an empty list."""

        return []


def _stub_context() -> PlanGateContext:
    """Build a context whose seams are fully stubbed."""

    return PlanGateContext(
        workspace_root=Path("/workspace"),
        file_system=_StubFileSystem(),
        git=_StubGitRepository(),
    )


def test_structural_errors_match_recorded_baseline_strings() -> None:
    """The seven pre-existing structural strings are unchanged in text and order."""

    # Arrange: one document exercising the five line-scoped errors in order.
    malformed = "\n".join(
        [
            "- [ ] [P1-T1] Task before any phase heading",
            "### Phase 1 - hyphen instead of em dash",
            "### Phase 1 — Work",
            "- [x] [P1-T1] Correct first task",
            "- [ ] [P2-T2] Task whose phase does not match",
            "- [ ] [P1-T9] Task whose number is unexpected",
            "- [ ] [P1-T] Task line missing the task number",
            "",
        ]
    )

    # Act
    errors = validator.validate_plan_text(malformed)
    empty = validator.validate_plan_text("no plan content here\n")

    # Assert
    assert errors == [
        "Line 1: task appears before a canonical phase heading.",
        "Line 2: phase heading must match `### Phase N — <Title>`.",
        "Line 5: task phase P2 does not match current phase 1.",
        "Line 5: expected task number T1 for phase 2, found T2.",
        "Line 6: expected task number T2 for phase 1, found T9.",
        "Line 7: task line must match `- [ ] [P#-T#] <Title>`.",
    ]
    assert empty == [
        "Plan does not contain any canonical phase headings.",
        "Plan does not contain any canonical task lines.",
    ]


def test_clean_plan_returns_empty_without_context() -> None:
    """A clean plan returns an empty error list with no context supplied."""

    # Arrange / Act
    errors, warnings = validator.validate_plan_text_with_warnings(_CLEAN_PLAN)

    # Assert
    assert errors == []
    assert warnings == []


def test_clean_plan_returns_empty_with_stub_context() -> None:
    """A clean plan returns an empty error list with a stub context supplied."""

    # Arrange / Act
    errors, warnings = validator.validate_plan_text_with_warnings(
        _CLEAN_PLAN, context=_stub_context()
    )

    # Assert
    assert errors == []
    assert warnings == []


def test_validate_plan_text_includes_g1_blocking_finding() -> None:
    """The single-channel entry point returns G1 findings, not only structure."""

    # Arrange / Act
    errors = validator.validate_plan_text(_G1_PLAN)

    # Assert
    assert len(errors) == 1
    assert errors[0].startswith("[P1-T1] ")
    assert "Use --cov=scripts.dev_tools.foo." in errors[0]


def test_plan_route_reports_g1_without_new_flag(monkeypatch: MonkeyPatch) -> None:
    """The existing `plan` route reports G1 with no additional flag."""

    # Arrange
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(_G1_PLAN))

    # Act
    exit_code = validator.main(["plan", "ignored.md"])

    # Assert
    assert exit_code == 1


def test_plan_subparser_option_set_is_path_and_workspace_root() -> None:
    """The `plan` subparser exposes only `path`, `--workspace-root`, and help."""

    # Arrange
    parser = validator.build_parser()

    # Act
    args = parser.parse_args(["plan", "p.md"])
    with pytest.raises(SystemExit) as help_exit:
        parser.parse_args(["plan", "--help"])
    with pytest.raises(SystemExit) as unknown_exit:
        parser.parse_args(["plan", "p.md", "--require-complete"])

    # Assert
    assert sorted(vars(args)) == ["artifact_type", "path", "workspace_root"]
    assert args.path == "p.md"
    assert args.workspace_root == "."
    # The `-h`/`--help` action argparse injects into every parser exits cleanly.
    assert help_exit.value.code == 0
    # No option beyond `--workspace-root` and help exists on the route.
    assert unknown_exit.value.code == 2


def test_main_emits_warning_prefix_on_stderr_and_exits_zero(
    monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
) -> None:
    """A warning-only plan exits 0 with the prefixed line on stderr."""

    # Arrange
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(_G4_PLAN))

    # Act
    exit_code = validator.main(["plan", "ignored.md"])
    captured = capsys.readouterr()

    # Assert
    assert exit_code == 0
    assert captured.out == "plan validation passed: ignored.md\n"
    assert captured.err.startswith("PLAN GATE WARNING: [P1-T1] ")
    assert captured.err.endswith("\n")


def test_main_emits_blocking_error_on_stderr_and_exits_one(
    monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
) -> None:
    """A Blocking plan exits 1, writes the finding to stderr, and no stdout."""

    # Arrange
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(_G1_PLAN))

    # Act
    exit_code = validator.main(["plan", "ignored.md"])
    captured = capsys.readouterr()

    # Assert
    assert exit_code == 1
    assert captured.out == ""
    assert captured.err.startswith("[P1-T1] ")
    assert "PLAN GATE WARNING: " not in captured.err


def test_plan_branch_builds_context_and_calls_two_channel_entry_point(
    monkeypatch: MonkeyPatch,
) -> None:
    """The `plan` branch builds a context and calls the two-channel entry point."""

    # Arrange
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(_CLEAN_PLAN))
    builder_calls: list[Path] = []
    entry_point_calls: list[bool] = []

    def _fake_builder(workspace_root: Path) -> PlanGateContext:
        builder_calls.append(workspace_root)
        return _stub_context()

    def _fake_entry_point(
        text: str, *, context: PlanGateContext | None = None
    ) -> tuple[list[str], list[str]]:
        entry_point_calls.append(context is not None)
        return [], []

    monkeypatch.setattr(validator, "build_plan_gate_context", _fake_builder)
    monkeypatch.setattr(
        validator, "validate_plan_text_with_warnings", _fake_entry_point
    )

    # Act
    exit_code = validator.main(["plan", "ignored.md", "--workspace-root", "sub/root"])

    # Assert
    assert exit_code == 0
    assert len(builder_calls) == 1
    assert builder_calls[0] == Path("sub/root")
    assert entry_point_calls == [True]


def test_non_plan_route_returns_an_empty_warning_channel(
    monkeypatch: MonkeyPatch,
) -> None:
    """Every non-plan artifact type reports no warnings on the second channel."""

    # Arrange
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub("ignored"))
    # Access the private dispatcher via vars() to avoid Pyright
    # reportPrivateUsage and Ruff B009 conflicts, matching the sibling module.
    dispatch = cast(
        "Callable[[argparse.Namespace], tuple[list[str], list[str]]]",
        vars(validator)["_validate_from_args_with_warnings"],
    )

    # Act
    errors, warnings = dispatch(
        argparse.Namespace(path="ignored.md", artifact_type="unsupported")
    )

    # Assert
    assert errors == ["Unsupported artifact type: unsupported"]
    assert warnings == []
