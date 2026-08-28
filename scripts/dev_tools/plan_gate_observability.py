"""Evaluate the G7, G8, G8b, and G9 observability plan-gate rules.

Purpose:
    Hold the rule group that judges whether an atomic plan's acceptance
    conditions observe anything beyond an exit code, and whether the ambient
    state a `git diff` reads can still discriminate once the change is
    committed. G7 reports a write-mode command whose attributed task text
    records none of the tool's observation markers. G8 reports an unanchored
    `git diff`. G8b reports a name-listing diff that cannot see an untracked
    path. G9 reports a coverage command that prints no coverage table.

Responsibilities and scope boundaries:
    This module decides commands only. It never constructs a `PlanGateReport`
    or a `PlanGateContext`; both arrive as parameters, so the dependency on
    `plan_gate_discrimination` is annotation-level and lives under
    `TYPE_CHECKING`. The runtime import graph therefore holds exactly one edge,
    `plan_gate_discrimination` importing this module, and stays acyclic.

Key invariants:
    G7, G8, and G8b are context-free and run on every invocation. G9 requires
    the tracked-tree seam, because the project `addopts` value can supply the
    terminal reporter the command omits, and does not run without a context.
    Every finding renders the offending span between backticks. The f-string
    conversion form and the builtin that render a Python representation are
    both prohibited in this module, because that builtin selects its quote
    character from the value's contents while the TypeScript twin always
    single-quotes, and the two runtimes must agree byte for byte. The
    prohibition is asserted by the parity suite over the whole module set.

Side effects:
    G9 queries the injected `git` seam of the supplied context in order to read
    the committed `pyproject.toml`. Nothing else performs I/O, and no function
    mutates its inputs beyond appending findings to the report it is given.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING

from scripts.dev_tools.plan_gate_commands import is_cov_flag_token

if TYPE_CHECKING:
    from scripts.dev_tools.plan_gate_commands import PlanCommand
    from scripts.dev_tools.plan_gate_discrimination import (
        PlanGateContext,
        PlanGateReport,
    )

# Channel names, declared here rather than imported. `plan_gate_discrimination`
# imports this module, so importing its channel constants back would form a
# cycle. This mirrors `plan_gate_commands`, which likewise declares its own copy
# of a value the validator also owns; the parity tests assert the copies agree.
BLOCKING_CHANNEL = "blocking"
WARNING_CHANNEL = "warning"

# Severity channel of each new rule. All four are authored at the Warning
# channel and are re-set from the pre-declared decision rule applied to the
# counts recorded in docs/features/active/2026-08-23-plan-acceptance-gates-miss-
# unobservable-and-ambient-state-gates-519/evidence/qa-gates/
# corpus-measurement.2026-08-24T00-00.md and by nothing else.
G7_SEVERITY: str = WARNING_CHANNEL
G8_SEVERITY: str = WARNING_CHANNEL
G8B_SEVERITY: str = WARNING_CHANNEL
G9_SEVERITY: str = WARNING_CHANNEL

# Leading wrapper window an executable may occupy, matching the extractor's
# `_EXECUTABLE_SCAN_LIMIT`. A tool name further right is an operand, not an
# invocation, so a task that searches a policy file for a register member's name
# never reports a finding against its own search command.
_EXECUTABLE_SCAN_LIMIT = 4

# Pathspec separator, which ends the operand run of a `git diff` invocation.
_PATHSPEC_SEPARATOR = "--"

# Flags that read the index rather than the worktree, so the comparison is not
# the ambient worktree-against-index one G8 reports.
_INDEX_FLAGS = ("--cached", "--staged")

# Flags that make a diff enumerate names rather than content. A name listing
# reports tracked changes only, so it can never see a path the plan creates.
_NAME_LISTING_FLAGS = ("--name-only", "--name-status")

# Companion spans, searched case-sensitively in the attributed task text.
_GIT_DIFF_SPAN = "git diff"
_GIT_STATUS_SPAN = "git status"
_GIT_ADD_SPAN = "git add"
_GIT_PORCELAIN_SPAN = "git status --porcelain"

# Project configuration file whose `addopts` value can supply the terminal
# reporter a coverage command omits.
_PROJECT_CONFIG_PATH = "pyproject.toml"

# Token prefixes that make a coverage command print or gate on a terminal
# result, so the acceptance condition can observe something.
_TERMINAL_REPORTER_PREFIX = "--cov-report=term"
_FAIL_UNDER_PREFIX = "--cov-fail-under"

# `addopts` assignment patterns, double-quoted form first. The expressions use
# literal text, character classes, and the `*` quantifier only, so they parse
# identically in the TypeScript twin's dialect.
_ADDOPTS_PATTERNS = (
    re.compile(r'addopts[ \t]*=[ \t]*"([^"]*)"'),
    re.compile(r"addopts[ \t]*=[ \t]*'([^']*)'"),
)


@dataclass(frozen=True)
class WriteModeShape:
    """One accepted argv shape of a write-mode register entry.

    Purpose:
        Express a register entry's argv predicate as data rather than as a
        callable, so the same six entries can be transcribed into the
        TypeScript twin without porting behaviour.

    Attributes:
        words (tuple[str, ...]): Consecutive argv words matched exactly. The
            first word must occupy an executable position.
        suffix (str): Alternative to `words`; a single argv word in an
            executable position whose text ends with this value.
        requires (tuple[str, ...]): Words that must appear anywhere in the argv
            for the shape to match.
    """

    words: tuple[str, ...] = ()
    suffix: str = ""
    requires: tuple[str, ...] = ()


@dataclass(frozen=True)
class WriteModeEntry:
    """One member of the write-mode register: a predicate plus its markers.

    Purpose:
        Name a tool that rewrites tracked source and still exits 0, together
        with the literals its success-case output prints. A plan that states
        such an invocation as an acceptance condition without recording one of
        those literals has asserted nothing the tool can fail.

    Attributes:
        name (str): Stable register-entry name, used by the completeness test.
        shapes (tuple[WriteModeShape, ...]): Accepted argv shapes; any match.
        excludes (tuple[str, ...]): Words whose presence anywhere in the argv
            puts the command into a non-writing mode, so the entry cannot match.
        markers (tuple[str, ...]): Observation markers, matched case-sensitively
            as substrings of the owning task's attributed text.
    """

    name: str
    shapes: tuple[WriteModeShape, ...]
    excludes: tuple[str, ...]
    markers: tuple[str, ...]


# The six-entry write-mode register, in selection order: the first entry whose
# argv predicate matches decides the command. Each entry names a tool that
# rewrites tracked source and exits 0 after rewriting, so its exit code cannot
# distinguish a clean run from a repairing one.
WRITE_MODE_REGISTER: tuple[WriteModeEntry, ...] = (
    WriteModeEntry(
        name="black-write",
        shapes=(WriteModeShape(words=("black",)),),
        excludes=("--check", "--diff"),
        markers=("reformatted", "left unchanged", "unchanged"),
    ),
    WriteModeEntry(
        name="ruff-fix",
        shapes=(WriteModeShape(words=("ruff", "check")),),
        excludes=("--no-fix",),
        markers=("Fixed", "All checks passed", "fixes applied"),
    ),
    WriteModeEntry(
        name="prettier-write",
        shapes=(
            WriteModeShape(words=("prettier",), requires=("--write",)),
            WriteModeShape(words=("npm", "run", "format")),
        ),
        excludes=(),
        markers=("(unchanged)", "unchanged", "rewrote"),
    ),
    WriteModeEntry(
        name="poshqc-format",
        shapes=(WriteModeShape(suffix="run_poshqc_format"),),
        excludes=(),
        markers=("formatted", "unchanged"),
    ),
    WriteModeEntry(
        name="poshqc-analyze-autofix",
        shapes=(WriteModeShape(suffix="run_poshqc_analyze_autofix"),),
        excludes=(),
        markers=("autofix", "Fixed", "unchanged"),
    ),
    WriteModeEntry(
        name="poshqc-suite",
        shapes=(WriteModeShape(suffix="run_poshqc_suite"),),
        excludes=(),
        markers=("formatted", "unchanged"),
    ),
)


def _append(report: PlanGateReport, severity: str, finding: str) -> None:
    """Append one finding to the channel the rule's severity constant names."""

    channel = report.blocking if severity == BLOCKING_CHANNEL else report.warnings
    channel.append(finding)


def _executable_positions(argv: tuple[str, ...]) -> list[int]:
    """Return the argv indices a tool name may occupy to count as an invocation.

    An index qualifies when it lies inside the leading wrapper window and the
    word immediately preceding it does not begin with a hyphen, so a tool name
    supplied as the operand of a search flag is never read as an invocation.
    """

    limit = min(len(argv), _EXECUTABLE_SCAN_LIMIT)
    return [
        index
        for index in range(limit)
        if index == 0 or not argv[index - 1].startswith("-")
    ]


def _shape_matches(argv: tuple[str, ...], shape: WriteModeShape) -> bool:
    """Return whether one accepted argv shape matches the command's argv."""

    if any(required not in argv for required in shape.requires):
        return False
    for index in _executable_positions(argv):
        if shape.suffix:
            if argv[index].endswith(shape.suffix):
                return True
            continue
        end = index + len(shape.words)
        if end <= len(argv) and argv[index:end] == shape.words:
            return True
    return False


def _matching_entry(argv: tuple[str, ...]) -> WriteModeEntry | None:
    """Return the first register entry whose argv predicate matches, if any."""

    for entry in WRITE_MODE_REGISTER:
        # An excluded word puts the tool into a non-writing mode, so the entry
        # cannot match however its shapes read.
        if any(excluded in argv for excluded in entry.excludes):
            continue
        if any(_shape_matches(argv, shape) for shape in entry.shapes):
            return entry
    return None


def _evaluate_write_mode(report: PlanGateReport, command: PlanCommand) -> None:
    """Apply G7 to one extracted command, in place."""

    entry = _matching_entry(command.argv)
    if entry is None:
        return
    # A marker is matched case-sensitively as a substring of the whole
    # attribution window, because a plan states its acceptance condition on the
    # lines that follow the task line rather than on the task line itself. The
    # offending span is removed once first, on the same reasoning the companion
    # searches below use: the span is part of the window, so a tool whose own
    # name contains one of its markers would exonerate itself unconditionally
    # and its register entry could never fire.
    remainder = command.task_text.replace(command.raw_span, " ", 1)
    if any(marker in remainder for marker in entry.markers):
        return
    _append(
        report,
        G7_SEVERITY,
        f"[{command.task_id}] write-mode command `{command.raw_span}` rewrites "
        "tracked source and exits 0 after rewriting; the attributed task text "
        "carries none of its observation markers. Record an observation beyond "
        "the exit code.",
    )


def _git_diff_index(argv: tuple[str, ...]) -> int | None:
    """Return the index of `diff` in a `git diff` invocation, or `None`.

    Only the leading wrapper window is scanned, so a `git diff` pair appearing
    later in the command is an operand rather than the invocation.
    """

    limit = min(len(argv), _EXECUTABLE_SCAN_LIMIT)
    for index in range(limit):
        if argv[index] == "git" and index + 1 < len(argv) and argv[index + 1] == "diff":
            return index + 1
    return None


def _diff_operands(argv: tuple[str, ...], diff_index: int) -> list[str]:
    """Return the words between `diff` and the `--` pathspec separator."""

    operands: list[str] = []
    for word in argv[diff_index + 1 :]:
        if word == _PATHSPEC_SEPARATOR:
            break
        operands.append(word)
    return operands


def _carries_pairing_companion(command: PlanCommand) -> bool:
    """Return whether the task text carries a second diff or a status span.

    The offending span is itself part of the task text, so it is removed once
    before the search; otherwise the answer would be `True` unconditionally.
    """

    remainder = command.task_text.replace(command.raw_span, " ", 1)
    return _GIT_DIFF_SPAN in remainder or _GIT_STATUS_SPAN in remainder


def _carries_listing_companion(command: PlanCommand) -> bool:
    """Return whether the task text carries a staging or porcelain-status span."""

    remainder = command.task_text.replace(command.raw_span, " ", 1)
    return _GIT_ADD_SPAN in remainder or _GIT_PORCELAIN_SPAN in remainder


def _evaluate_git_diff(report: PlanGateReport, command: PlanCommand) -> None:
    """Apply G8 and G8b to one extracted command, in place."""

    argv = command.argv
    diff_index = _git_diff_index(argv)
    if diff_index is None:
        return

    operands = _diff_operands(argv, diff_index)
    has_ref_operand = any(not word.startswith("-") for word in operands)
    has_index_flag = any(flag in argv for flag in _INDEX_FLAGS)

    # G8: no ref operand and no index flag means the command compares the
    # worktree against the index, which is empty once the change is committed.
    if not has_ref_operand and not has_index_flag:
        if not _carries_pairing_companion(command):
            _append(
                report,
                G8_SEVERITY,
                f"[{command.task_id}] git diff span `{command.raw_span}` carries "
                "no ref operand and no --cached flag; it compares the worktree "
                "against the index and passes vacuously once the change is "
                "committed. Anchor the diff to a ref.",
            )
        return

    # G8b: an anchored name-listing diff enumerates tracked changes only, so a
    # path the plan creates is invisible to it without a companion span.
    if has_ref_operand and any(flag in argv for flag in _NAME_LISTING_FLAGS):
        if not _carries_listing_companion(command):
            _append(
                report,
                G8B_SEVERITY,
                f"[{command.task_id}] name-listing diff `{command.raw_span}` never "
                "reports an untracked file, and the attributed task text carries "
                "neither a staging span nor a porcelain-status span; a path the "
                "plan creates is invisible to it. Add a staging or "
                "porcelain-status companion.",
            )


def project_addopts(context: PlanGateContext) -> str | None:
    """Return the project `addopts` value, or `None` when it cannot be read.

    Purpose:
        Read the committed `pyproject.toml` through the existing tracked-tree
        seam so G9 can tell a command that omits a terminal reporter the project
        supplies from one that omits a reporter nothing supplies.

    Args:
        context (PlanGateContext): Tracked-tree seam supplying the committed
            text of the project configuration file.

    Returns:
        str | None: The `addopts` value with its surrounding quotes removed, an
            empty string when the file was read but declares no assignment, and
            `None` when the seam produced no text at all. The three cases are
            distinguished because the finding claims the project supplies no
            terminal reporter, and that claim is only supportable when the
            configuration was actually read.

    Raises:
        None of its own. Any error raised by the `git` seam propagates to the
        caller's graceful degradation guard.
    """

    text = context.git.read_tracked_text(_PROJECT_CONFIG_PATH)
    if not text:
        return None
    # The double-quoted form is tried first, then the single-quoted form.
    for pattern in _ADDOPTS_PATTERNS:
        match = pattern.search(text)
        if match is not None:
            return match.group(1)
    return ""


def _collect_coverage_reporter(
    pending: list[str], command: PlanCommand, addopts: str
) -> None:
    """Collect the G9 finding for one extracted command, if it has one.

    Findings are buffered rather than reported directly, so a repository seam
    that fails part-way through discards the whole group instead of reporting
    it partially.
    """

    argv = command.argv
    if not any(is_cov_flag_token(word) for word in argv):
        return
    if any(word.startswith(_TERMINAL_REPORTER_PREFIX) for word in argv):
        return
    # A coverage threshold makes the run fail on its own, so the acceptance
    # condition discriminates without a printed table.
    if any(word.startswith(_FAIL_UNDER_PREFIX) for word in argv):
        return
    if _TERMINAL_REPORTER_PREFIX in addopts:
        return
    pending.append(
        f"[{command.task_id}] coverage command `{command.raw_span}` supplies no "
        "terminal reporter and the project addopts supplies none either, so no "
        "coverage table is printed. Add --cov-report=term-missing."
    )


def evaluate_observability_gates(
    report: PlanGateReport,
    commands: list[PlanCommand],
    *,
    context: PlanGateContext | None = None,
) -> None:
    """Apply the observability rule group to every extracted command, in place.

    Args:
        report (PlanGateReport): Report mutated in place; findings are appended
            to the channel each rule's severity constant names.
        commands (list[PlanCommand]): Extracted commands, in source order.
        context (PlanGateContext | None): Tracked-tree seam. When `None`, only
            the context-free rules G7, G8, and G8b run, because G9 cannot tell
            an omitted reporter from one the project configuration supplies.

    Returns:
        None. The function reports by mutating `report`.

    Raises:
        None. A failing repository seam discards the whole G9 group rather than
        reporting it partially, and never propagates.
    """

    for command in commands:
        _evaluate_write_mode(report, command)
        _evaluate_git_diff(report, command)

    if context is None:
        return

    pending: list[str] = []
    try:
        # The project value is read once per evaluation, not once per command.
        addopts = project_addopts(context)
        # A seam that produced no text cannot support the finding's claim that
        # the project supplies no terminal reporter, so the group is skipped.
        if addopts is None:
            return
        for command in commands:
            _collect_coverage_reporter(pending, command, addopts)
    except Exception:
        # Broad by contract: a validation run must never fail because the
        # repository could not be queried (spec AC11, graceful degradation).
        return

    for finding in pending:
        _append(report, G9_SEVERITY, finding)
