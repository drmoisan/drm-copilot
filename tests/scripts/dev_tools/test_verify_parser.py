"""Unit tests for the top-level `verify_parser.py` helper script.

These tests avoid filesystem access by injecting a fake plan parser.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import pytest  # noqa: TCH002 - pytest required at runtime for fixtures

import verify_parser


@dataclass
class _FakeTask:
    """Minimal task object compatible with verify_parser's task protocol."""

    task_id: str
    title: str
    expect_fail: bool
    test_ref: str | None


@dataclass
class _FakeModel:
    """Minimal plan model object compatible with verify_parser's model protocol."""

    tasks: list[_FakeTask]


class _CapturingParser:
    """Fake PlanParser that captures the path and returns a fixed model."""

    def __init__(self, path: Path, model: _FakeModel) -> None:
        self.path = path
        self._model = model

    def parse(self) -> _FakeModel:
        return self._model


def test_build_task_summary_output_renders_expected_lines() -> None:
    """A found task should render in the legacy 4-line format with newline."""
    model = _FakeModel(
        tasks=[
            _FakeTask(
                task_id="P1-T1",
                title="Do the thing",
                expect_fail=True,
                test_ref="tests/unit/test_x.py::test_y",
            )
        ]
    )

    out = verify_parser.build_task_summary_output(model, task_id="P1-T1")

    assert out == (
        "Task: P1-T1\n"
        "Title: Do the thing\n"
        "Expect Fail: True\n"
        "Test Ref: tests/unit/test_x.py::test_y\n"
    )


def test_build_task_summary_output_returns_none_when_missing() -> None:
    """Missing task IDs should produce None (no output)."""
    model = _FakeModel(tasks=[_FakeTask("P1-T2", "Other", False, None)])

    assert verify_parser.build_task_summary_output(model, task_id="P1-T1") is None


def test_find_task_summary_returns_first_match_when_duplicate_ids_exist() -> None:
    """The task scan should stop at the first match for deterministic output."""
    model = _FakeModel(
        tasks=[
            _FakeTask("P1-T1", "First", False, None),
            _FakeTask("P1-T1", "Second", True, "tests/x.py::t"),
        ]
    )

    summary = verify_parser.find_task_summary(model, task_id="P1-T1")

    assert summary is not None
    assert summary.title == "First"


def test_run_uses_parser_factory_and_passes_plan_path() -> None:
    """run() should create the parser from the provided factory and use it."""
    plan_path = Path("/workspace/plan.md")
    model = _FakeModel(tasks=[_FakeTask("P1-T1", "Title", False, None)])
    created: list[_CapturingParser] = []

    def fake_factory(path: Path) -> _CapturingParser:
        parser = _CapturingParser(path, model)
        created.append(parser)
        return parser

    out = verify_parser.run(
        plan_path=plan_path, task_id="P1-T1", parser_factory=fake_factory
    )

    assert out is not None
    assert created and created[0].path == plan_path


def test_main_prints_not_found_message_and_returns_nonzero(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """main() should print a friendly message and return 1 when missing."""

    def fake_run(**_: object) -> str | None:
        return None

    monkeypatch.setattr(verify_parser, "run", fake_run)

    rc = verify_parser.main()

    captured = capsys.readouterr()
    assert rc == 1
    assert "Task not found" in captured.out


def test_main_prints_output_and_returns_zero(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """main() should print the output and return 0 when a task is found."""

    def fake_run(**_: object) -> str | None:
        return "Task: P1-T1\n"

    monkeypatch.setattr(verify_parser, "run", fake_run)

    rc = verify_parser.main()

    captured = capsys.readouterr()
    assert rc == 0
    assert captured.out == "Task: P1-T1\n"
