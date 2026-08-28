"""Unit tests for the atomic-plan command extractor."""

from __future__ import annotations

from scripts.dev_tools.plan_gate_commands import (
    PLAN_GATE_HEADING_RE,
    PLAN_GATE_TASK_RE,
    PlanCommand,
    extract_plan_commands,
)

_TASK_LINE = "- [ ] [P1-T1] Do the thing"


def _plan(*lines: str) -> str:
    """Join fixture lines into a plan document."""

    return "\n".join(lines) + "\n"


def test_extract_plan_commands_returns_exact_record_fields() -> None:
    """The extractor reports exactly the six declared record fields."""

    # Arrange
    acceptance = "  - Acceptance: `grep -F -n 'MIT License' LICENSE` reports one match."
    text = _plan(
        "### Phase 1 — Work",
        _TASK_LINE,
        acceptance,
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert sorted(PlanCommand.__dataclass_fields__) == [
        "argv",
        "kind",
        "raw_span",
        "source_line",
        "task_id",
        "task_text",
    ]
    assert len(commands) == 1
    command = commands[0]
    assert command.task_id == "P1-T1"
    assert command.source_line == 3
    assert command.raw_span == "grep -F -n 'MIT License' LICENSE"
    assert command.argv == ("grep", "-F", "-n", "MIT License", "LICENSE")
    assert command.kind == "grep"
    assert command.task_text == "\n".join([_TASK_LINE, acceptance])


def test_extract_plan_commands_populates_task_text_from_the_owning_task() -> None:
    """Task text is the whole window, not just the line the span sits on."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        "- [ ] [P1-T1] First task",
        "  - Acceptance: `poetry run pytest -q` reports 0 failed,",
        "    and the summary line is recorded.",
        "- [ ] [P1-T2] Second task",
        "  - Acceptance: `poetry run ruff check scripts` reports 0 findings.",
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert len(commands) == 2
    first, second = commands
    assert first.task_text == "\n".join(
        [
            "- [ ] [P1-T1] First task",
            "  - Acceptance: `poetry run pytest -q` reports 0 failed,",
            "    and the summary line is recorded.",
        ]
    )
    assert "Second task" not in first.task_text
    assert second.task_text == "\n".join(
        [
            "- [ ] [P1-T2] Second task",
            "  - Acceptance: `poetry run ruff check scripts` reports 0 findings.",
        ]
    )


def test_extract_plan_commands_leaves_task_text_empty_outside_any_window() -> None:
    """A span outside every window is dropped, so no record carries its text."""

    # Arrange
    text = _plan(
        "# Plan",
        "",
        "Run `poetry run pytest -q` before starting.",
        "",
        "### Phase 1 — Work",
        "",
        "This phase ends with `poetry run ruff check scripts`.",
        "",
        _TASK_LINE,
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert commands == []
    assert PlanCommand.__dataclass_fields__["task_text"].default == ""


def test_extract_plan_commands_classifies_kind_grep_pytest_cov_and_other() -> None:
    """The three argv shapes classify as grep, pytest_cov, and other."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        _TASK_LINE,
        "  - Acceptance: `git grep -F -l pinned LICENSE` and",
        "    `poetry run pytest -q --cov=scripts.dev_tools.foo` and",
        "    `poetry run black --check scripts`.",
    )

    # Act
    kinds = [command.kind for command in extract_plan_commands(text)]

    # Assert
    assert kinds == ["grep", "pytest_cov", "other"]


def test_extract_plan_commands_skips_document_preamble() -> None:
    """A span before the first task line is attributed to no task."""

    # Arrange
    text = _plan(
        "# Plan",
        "",
        "Run `poetry run pytest -q` before starting.",
        "",
        "### Phase 1 — Work",
        _TASK_LINE,
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert commands == []


def test_extract_plan_commands_skips_phase_preamble() -> None:
    """A span between a phase heading and its first task is dropped."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        "",
        "This phase runs `poetry run pytest -q` at the end.",
        "",
        _TASK_LINE,
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert commands == []


def test_extract_plan_commands_skips_span_after_intervening_heading() -> None:
    """A heading between a task line and a span closes the window."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        _TASK_LINE,
        "",
        "#### Notes",
        "",
        "Run `poetry run pytest -q` manually.",
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert commands == []
    assert PLAN_GATE_HEADING_RE.match("#### Notes") is not None


def test_extract_plan_commands_skips_unbalanced_quoting() -> None:
    """A span whose quoting is unbalanced produces no record."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        _TASK_LINE,
        '  - Acceptance: `grep -F "unterminated` reports a match.',
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert commands == []


def test_extract_plan_commands_skips_command_without_operand() -> None:
    """A span that splits into fewer than two words produces no record."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        _TASK_LINE,
        "  - Acceptance: `scripts/dev_tools/plan_gate_commands.py` exists.",
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert commands == []


def test_extract_plan_commands_splits_single_and_double_quoted_words() -> None:
    """POSIX splitting preserves quoted operands, including nested quotes."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        _TASK_LINE,
        '  - Acceptance: `grep -n "\\"fast-uri\\"" package.json` reports a match.',
        "  - Acceptance: `grep -F 'MIT License' LICENSE` reports a match.",
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert len(commands) == 2
    nested = commands[0]
    assert len(nested.argv) == 4
    assert nested.argv[2] == '"fast-uri"'
    single_quoted = commands[1]
    assert single_quoted.argv == ("grep", "-F", "MIT License", "LICENSE")


def test_extract_plan_commands_scans_fenced_code_blocks() -> None:
    """Each non-blank line of a fenced block inside the window is a record."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        _TASK_LINE,
        "  - Acceptance: run the commands below.",
        "",
        "```bash",
        "poetry run black --check scripts",
        "",
        "poetry run ruff check scripts",
        "```",
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert [command.raw_span for command in commands] == [
        "poetry run black --check scripts",
        "poetry run ruff check scripts",
    ]
    assert {command.task_id for command in commands} == {"P1-T1"}
    assert [command.source_line for command in commands] == [6, 8]


def test_extract_plan_commands_attributes_continuation_bullet_to_task() -> None:
    """A continuation bullet's span is attributed to the preceding task."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        "- [ ] [P1-T1] First task",
        "  - Acceptance: `poetry run pytest -q` reports 0 failed.",
        "- [x] [P1-T2] Second task",
        "  - Acceptance: `poetry run ruff check scripts` reports 0 findings.",
    )

    # Act
    commands = extract_plan_commands(text)

    # Assert
    assert [(command.task_id, command.source_line) for command in commands] == [
        ("P1-T1", 3),
        ("P1-T2", 5),
    ]
    assert PLAN_GATE_TASK_RE.match("- [x] [P1-T2] Second task") is not None
