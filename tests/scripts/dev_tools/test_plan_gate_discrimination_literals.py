"""Unit tests for the search-literal plan-gate rules G5 and G6."""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools.plan_gate_discrimination import (
    G5_SEVERITY,
    PlanGateContext,
    PlanGateReport,
    evaluate_plan_gates,
)

_PHASE = "### Phase 2 — Work"
_LITERAL = "pinned items occupy"
_ACCEPTANCE = f"grep -F -n '{_LITERAL}' docs/design.md"
_NEL = "\x85"
_BOM = chr(0xFEFF)
_G5_ABSENT_FINDING = (
    "[P2-T1] search literal `pinned items occupy` is absent from the tracked "
    "tree and is not quoted in the plan; the search returns zero matches "
    "whatever the executor does. Quote the exact literal the task will "
    "create, or assert a literal that exists."
)
_G6_CROSS_LINE_WARNING = (
    "[P2-T1] search literal `pinned items occupy` is present only across "
    "adjacent lines of a tracked file and matches no single line; a "
    "line-oriented search returns zero matches. Search a shorter single-line "
    "token."
)


class StubGitRepository:
    """Stub tracked-tree seam whose answers are supplied per test.

    Attributes:
        matches (dict[str, list[str]]): `files_containing` answers by literal.
        texts (dict[str, str]): `read_tracked_text` answers by path.
        failure (Exception | None): Raised by `files_containing` when set.
    """

    def __init__(
        self,
        *,
        matches: dict[str, list[str]] | None = None,
        texts: dict[str, str] | None = None,
        failure: Exception | None = None,
    ) -> None:
        self.matches = matches or {}
        self.texts = texts or {}
        self.failure = failure

    def files_containing(self, literal: str) -> list[str]:
        """Return the configured matches, or raise the configured failure."""

        if self.failure is not None:
            raise self.failure
        return list(self.matches.get(literal, []))

    def is_tracked_file(self, path: str) -> bool:
        """Return False; the literal rules never consult tracked files."""

        return False

    def is_tracked_directory(self, path: str) -> bool:
        """Return False; the literal rules never consult tracked directories."""

        return False

    def read_tracked_text(self, path: str) -> str:
        """Return the configured committed text for the path."""

        return self.texts.get(path, "")


class _StubFileSystem:
    """Read-only filesystem stub that answers negatively and reads nothing."""

    def is_file(self, path: Path) -> bool:
        """Return False; no literal rule consults the filesystem seam."""

        return False

    def is_dir(self, path: Path) -> bool:
        """Return False; no literal rule consults the filesystem seam."""

        return False

    def read_text(self, path: Path) -> str:
        """Return an empty string; no literal rule consults the seam."""

        return ""

    def read_bytes(self, path: Path) -> bytes:
        """Return empty bytes; no literal rule consults the seam."""

        return b""

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        """Return an empty list; no literal rule consults the seam."""

        return []


def _context(git: StubGitRepository) -> PlanGateContext:
    """Wrap a stub git seam in a context with a stub filesystem."""

    return PlanGateContext(
        workspace_root=Path("/workspace"),
        file_system=_StubFileSystem(),
        git=git,
    )


def _plan(acceptance: str, *extra: str, task: str = "P2-T1") -> str:
    """Build a one-task plan whose acceptance bullet holds a command."""

    return "\n".join(
        [
            _PHASE,
            f"- [ ] [{task}] Do the thing",
            f"  - Acceptance: `{acceptance}` reports one match.",
            *extra,
            "",
        ]
    )


def _channel(report: PlanGateReport) -> list[str]:
    """Return the report channel G5 findings are routed to."""

    return report.blocking if G5_SEVERITY == "blocking" else report.warnings


def _other_channel(report: PlanGateReport) -> list[str]:
    """Return the report channel G5 findings must never appear on."""

    return report.warnings if G5_SEVERITY == "blocking" else report.blocking


def test_g5_reports_literal_absent_from_tree_and_plan() -> None:
    """A literal absent from the tree and unquoted in the plan is reported."""

    # Arrange: the only occurrence of the literal is the command span itself.
    text = _plan(_ACCEPTANCE)
    git = StubGitRepository()

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert len(_channel(report)) == 1
    assert _other_channel(report) == []
    finding = _channel(report)[0]
    assert finding.startswith("[P2-T1] ")
    assert f"`{_LITERAL}`" in finding


def test_g5_exonerates_literal_quoted_in_plan() -> None:
    """The same literal quoted in plan prose outside the span is exonerated."""

    # Arrange: identical plan plus one prose sentence quoting the literal.
    text = _plan(
        _ACCEPTANCE,
        f"  - The task writes the sentence {_LITERAL} into the design note.",
    )
    git = StubGitRepository()

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_g6_cross_line_literal_is_warning_and_not_blocking() -> None:
    """A literal present only across adjacent tracked lines is a Warning."""

    # Arrange: the first word matches a line, but the phrase wraps.
    git = StubGitRepository(
        matches={"pinned": ["docs/design.md"]},
        texts={"docs/design.md": "the pinned\nitems occupy the cohort\n"},
    )
    text = _plan(_ACCEPTANCE)
    quoted = _plan(
        _ACCEPTANCE,
        f"  - The task rewrites the wrapped line to read {_LITERAL} exactly.",
    )

    # Act
    report = evaluate_plan_gates(text, context=_context(git))
    exonerated = evaluate_plan_gates(quoted, context=_context(git))

    # Assert
    assert report.blocking == []
    assert len(report.warnings) == 1
    warning = report.warnings[0]
    assert warning.startswith("[P2-T1] ")
    assert "shorter single-line token" in warning
    # The same fixture plus a prose quotation outside the span is exonerated.
    assert exonerated.warnings == []
    assert exonerated.blocking == []


@pytest.mark.parametrize(
    "tracked_text",
    [
        pytest.param("the pinned\fitems occupy the cohort\n", id="form-feed"),
        pytest.param("the pinned\u2028items occupy the cohort\n", id="line-separator"),
    ],
)
def test_g6_window_split_ignores_form_feed_and_line_separator(
    tracked_text: str,
) -> None:
    """A form feed or U+2028 does not end a tracked line, so G6 does not fire.

    The tracked file is split on CR LF, LF, and CR only, as the TypeScript
    `hasCrossLinePresence` does, so the phrase never spans two lines and the
    G5 finding is reported instead of the G6 cross-line warning.
    """

    # Arrange
    git = StubGitRepository(
        matches={"pinned": ["docs/design.md"]},
        texts={"docs/design.md": tracked_text},
    )
    text = _plan(_ACCEPTANCE)
    expected = (
        "[P2-T1] search literal `pinned items occupy` is absent from the tracked "
        "tree and is not quoted in the plan; the search returns zero matches "
        "whatever the executor does. Quote the exact literal the task will "
        "create, or assert a literal that exists."
    )

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert _channel(report) == [expected]
    assert _other_channel(report) == []


@pytest.mark.parametrize(
    ("tracked_text", "expected"),
    [
        pytest.param(
            "the pinned\n" + _NEL + "\nitems occupy\n",
            _G5_ABSENT_FINDING,
            id="nel-only-line",
        ),
        pytest.param(
            "the pinned\n" + _BOM + "\nitems occupy\n",
            _G5_ABSENT_FINDING,
            id="bom-only-line",
        ),
        pytest.param(
            "the pinned" + _NEL + "items occupy\nthe pinned\nitems occupy\n",
            _G6_CROSS_LINE_WARNING,
            id="nel-joined-line",
        ),
        pytest.param(
            "the pinned" + _BOM + "items occupy\nthe pinned\nitems occupy\n",
            _G6_CROSS_LINE_WARNING,
            id="bom-joined-line",
        ),
    ],
)
def test_g6_normalization_uses_plan_whitespace_class(
    tracked_text: str, expected: str
) -> None:
    """G6 treats NEL and the byte-order mark as ordinary characters.

    Both are outside `PLAN_WHITESPACE_CLASS`, so a line holding only one of
    them is not blank, and a phrase joined by one of them is not on one line.
    The TypeScript suite holds the same four cases. G5 ships on the Warning
    channel, so both expected findings are Warnings.
    """

    # Arrange
    git = StubGitRepository(
        matches={"pinned": ["docs/design.md"]},
        texts={"docs/design.md": tracked_text},
    )
    text = _plan(_ACCEPTANCE)

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert (report.blocking, report.warnings) == ([], [expected])


def test_g5_whitespace_only_literal_is_never_quoted() -> None:
    """A whitespace-only literal normalizes to an empty needle, never quoted.

    The TypeScript suite holds the same case.
    """

    # Arrange
    text = _plan("grep -F -n ' ' docs/design.md")
    git = StubGitRepository()
    expected = (
        "[P2-T1] search literal ` ` is absent from the tracked tree and is "
        "not quoted in the plan; the search returns zero matches whatever "
        "the executor does. Quote the exact literal the task will create, "
        "or assert a literal that exists."
    )

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert (report.blocking, report.warnings) == ([], [expected])


def test_checkable_literal_skips_regex_metacharacters() -> None:
    """A pattern carrying metacharacters without `-F` is not checkable."""

    # Arrange
    text = _plan("grep -n 'recolor_unstarted(' scripts/dev_tools/foo.py")
    git = StubGitRepository()

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_checkable_literal_accepts_fixed_string_flag() -> None:
    """`-F` makes a metacharacter-bearing pattern checkable."""

    # Arrange
    text = _plan("grep -F -n 'recolor_unstarted(' scripts/dev_tools/foo.py")
    git = StubGitRepository()

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert len(_channel(report)) == 1
    assert "`recolor_unstarted(`" in _channel(report)[0]


def test_checkable_literal_skips_placeholder_operand() -> None:
    """A placeholder operand states no real assertion and is never reported."""

    # Arrange
    text = _plan("grep -F -n '<expected message>' docs/design.md")
    git = StubGitRepository()

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_window_boundary_five_lines_apart_is_not_joined() -> None:
    """Words five lines apart never share a window, so G6 does not fire."""

    # Arrange: `pinned` is on line 1 and `occupy` on line 5.
    git = StubGitRepository(
        matches={"pinned": ["docs/design.md"]},
        texts={"docs/design.md": "pinned\nalpha\nbeta\ngamma\nitems occupy\n"},
    )
    text = _plan(_ACCEPTANCE)

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert len(_channel(report)) == 1
    assert _other_channel(report) == []
    assert all(
        "shorter single-line token" not in finding
        for finding in report.blocking + report.warnings
    )


def test_context_free_call_skips_context_rules() -> None:
    """With no context, G2, G3, G5, and G6 produce no findings."""

    # Arrange
    text = _plan(_ACCEPTANCE, "  - Also: `poetry run pytest --cov=scripts/x`.")

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_failing_git_adapter_produces_no_findings() -> None:
    """A raising git seam is degraded to zero findings and no exception."""

    # Arrange
    git = StubGitRepository(failure=RuntimeError("git unavailable"))
    text = _plan(_ACCEPTANCE)

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_g5_severity_matches_measured_false_positive_count() -> None:
    """The AC1 G5 finding lands on the measured channel and on no other."""

    # Arrange: the same fixture as the AC1 finding test.
    git = StubGitRepository()
    text = _plan(_ACCEPTANCE)

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert G5_SEVERITY in {"blocking", "warning"}
    assert len(_channel(report)) == 1
    assert _other_channel(report) == []


def test_g5_exonerates_literal_present_in_tracked_tree() -> None:
    """Presence anywhere in the tracked tree exonerates the literal."""

    # Arrange
    git = StubGitRepository(matches={_LITERAL: ["docs/design.md"]})
    text = _plan(_ACCEPTANCE)

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_single_word_literal_never_reaches_the_window_check() -> None:
    """A one-word literal cannot wrap, so G5 reports it without a window scan."""

    # Arrange
    git = StubGitRepository()
    text = _plan("grep -F -n pinned docs/design.md")

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert len(_channel(report)) == 1
    assert _other_channel(report) == []
    assert "`pinned`" in _channel(report)[0]


def test_grep_command_without_operand_produces_no_finding() -> None:
    """A grep fragment used as prose supplies no pattern operand to judge."""

    # Arrange
    git = StubGitRepository()
    text = _plan("grep -r -F")

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert report.warnings == []
