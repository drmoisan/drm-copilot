"""Extract task-attributed shell-command candidates from atomic-plan text.

Purpose:
    Provide the reusable command-extraction layer consumed by the plan
    acceptance-gate discrimination rules. The extractor reports every shell
    command an atomic plan attributes to a specific task so downstream rules
    can judge whether the plan's acceptance conditions are falsifiable.

    This module declares its own task-line and heading patterns and never
    imports `scripts.dev_tools.validate_orchestration_artifacts`, which imports
    this module transitively. Importing the validator here would form a cycle.
"""

from __future__ import annotations

import re
import shlex
from dataclasses import dataclass, replace

PLAN_GATE_TASK_RE = re.compile(
    r"^- \[(?P<state>[ xX])\] \[P(?P<phase>\d+)-T(?P<task>\d+)\] (?P<title>.+)$"
)
PLAN_GATE_HEADING_RE = re.compile(r"^#{1,6} ")

_INLINE_SPAN_RE = re.compile(r"`([^`]+)`")
_FENCE_RE = re.compile(r"^\s*```")

COV_FLAG = "--cov"
COV_FLAG_PREFIX = "--cov="

GREP_EXECUTABLES = frozenset({"grep", "egrep", "fgrep", "rg"})
_EXECUTABLE_SCAN_LIMIT = 4

KIND_GREP = "grep"
KIND_PYTEST_COV = "pytest_cov"
KIND_OTHER = "other"

_MINIMUM_ARGV_LENGTH = 2


@dataclass(frozen=True)
class PlanCommand:
    """A single shell command an atomic plan attributes to one task.

    Purpose:
        Carry the extracted command together with the plan location and task
        identifier the discrimination rules need in order to report a finding
        that a maintainer can act on.

    Attributes:
        task_id (str): Canonical `P#-T#` identifier of the owning task.
        source_line (int): 1-based line number the command span was read from.
        raw_span (str): Verbatim span text, before shell-word splitting.
        argv (tuple[str, ...]): Shell words the span splits into.
        kind (str): One of `grep`, `pytest_cov`, or `other`.
        task_text (str): Newline-joined text of the command's whole attribution
            window — the owning task line plus every following line up to, but
            not including, the line that closes the window. Empty for a record
            built outside any window. The field is trailing and defaulted, so
            every existing construction of this record keeps working.
    """

    task_id: str
    source_line: int
    raw_span: str
    argv: tuple[str, ...]
    kind: str
    task_text: str = ""


def is_cov_flag_token(token: str) -> bool:
    """Report whether a shell word is a `--cov` coverage argument.

    Purpose:
        Centralize the exact token-match rule so neighbouring pytest-cov flags
        such as `--cov-branch` and `--cov-report=term-missing` are never
        mistaken for a `--cov` argument by prefix matching.

    Args:
        token (str): Single shell word from an extracted command.

    Returns:
        bool: `True` when the token equals `--cov` exactly or begins with the
        six characters `--cov=`.

    Raises:
        None.

    Side Effects:
        None.
    """

    return token == COV_FLAG or token.startswith(COV_FLAG_PREFIX)


def grep_executable_index(argv: tuple[str, ...]) -> int | None:
    """Locate the grep-family executable within an argv.

    Purpose:
        Give both the kind classifier and the pattern-operand selector a single
        definition of where a grep-family command's operands begin.

    Args:
        argv (tuple[str, ...]): Shell words of an extracted command.

    Returns:
        int | None: Index of the grep-family executable, or `None` when the
        argv does not invoke one within the leading scan window.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Scan only the leading wrapper window so a grep-family name appearing as an
    # operand later in the command is never mistaken for the executable.
    limit = min(len(argv), _EXECUTABLE_SCAN_LIMIT)
    for index in range(limit):
        word = argv[index]
        if word in GREP_EXECUTABLES:
            return index
        # `git grep` places the grep-family verb one position after `git`.
        if word == "git" and index + 1 < len(argv) and argv[index + 1] == "grep":
            return index + 1
    return None


def _classify_kind(argv: tuple[str, ...]) -> str:
    """Classify an extracted command by the rule family that judges it.

    Purpose:
        Route each command to the discrimination rules that apply to it without
        re-deriving the executable shape at every rule site.

    Args:
        argv (tuple[str, ...]): Shell words of an extracted command.

    Returns:
        str: `grep` for a grep-family invocation, `pytest_cov` for an argv
        carrying a `--cov` argument, and `other` otherwise.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Executable shape is checked before flag shape because a grep-family
    # invocation is judged by the literal rules regardless of which flags it
    # carries, whereas the coverage rules key on a flag rather than a verb.
    if grep_executable_index(argv) is not None:
        return KIND_GREP
    # Any `--cov` argument anywhere in the argv marks the command as a coverage
    # invocation, because wrappers such as `poetry run` push the verb rightward.
    if any(is_cov_flag_token(word) for word in argv):
        return KIND_PYTEST_COV
    return KIND_OTHER


def _split_shell_words(span: str) -> tuple[str, ...] | None:
    """Split a command span into shell words using POSIX quoting rules.

    Purpose:
        Reject spans whose quoting is unbalanced rather than guess at the
        author's intent, so a malformed span never produces a finding.

    Args:
        span (str): Verbatim span text read from the plan.

    Returns:
        tuple[str, ...] | None: Shell words, or `None` when the span's quoting
        is unbalanced.

    Raises:
        None.

    Side Effects:
        None.
    """

    try:
        words = shlex.split(span, posix=True)
    except ValueError:
        return None
    return tuple(words)


def _task_identifier(match: re.Match[str]) -> str:
    """Render the canonical task identifier from a task-line match.

    Purpose:
        Keep the `P#-T#` rendering in one place so every finding prefixes the
        same identifier form the plan itself uses.

    Args:
        match (re.Match[str]): Match produced by `PLAN_GATE_TASK_RE`.

    Returns:
        str: Canonical `P#-T#` identifier.

    Raises:
        None.

    Side Effects:
        None.
    """

    return f"P{match.group('phase')}-T{match.group('task')}"


def _append_command(
    commands: list[PlanCommand],
    task_id: str,
    source_line: int,
    raw_span: str,
) -> None:
    """Append one extracted command when the span is a usable candidate.

    Purpose:
        Apply the two drop rules — unbalanced quoting and an argv shorter than
        two words — at the single point where records are created.

    Args:
        commands (list[PlanCommand]): Accumulator the record is appended to.
        task_id (str): Canonical `P#-T#` identifier of the owning task.
        source_line (int): 1-based line number the span was read from.
        raw_span (str): Verbatim span text.

    Returns:
        None.

    Raises:
        None.

    Side Effects:
        Mutates the supplied accumulator.
    """

    argv = _split_shell_words(raw_span)
    if argv is None or len(argv) < _MINIMUM_ARGV_LENGTH:
        return
    commands.append(
        PlanCommand(
            task_id=task_id,
            source_line=source_line,
            raw_span=raw_span,
            argv=argv,
            kind=_classify_kind(argv),
        )
    )


def _close_window(
    commands: list[PlanCommand], window_start: int, window_lines: list[str]
) -> None:
    """Assign the closing window's whole text to every record it produced.

    Purpose:
        Apply the whole-window definition of attributed task text at the single
        moment the window closes, so the extractor still walks the document
        exactly once and no second implementation of the window invariant is
        created.

    Args:
        commands (list[PlanCommand]): Accumulator holding every record so far.
        window_start (int): Index of the first record the closing window
            produced; records before it belong to an earlier window.
        window_lines (list[str]): Verbatim lines of the closing window, in
            source order.

    Returns:
        None.

    Raises:
        None.

    Side Effects:
        Replaces the closing window's records in the supplied accumulator with
        copies carrying the window text.
    """

    if window_start >= len(commands):
        return
    task_text = "\n".join(window_lines)
    for index in range(window_start, len(commands)):
        commands[index] = replace(commands[index], task_text=task_text)


def extract_plan_commands(text: str) -> list[PlanCommand]:
    """Extract every task-attributed command candidate from plan text.

    Purpose:
        Walk the plan in source order, tracking the attribution window, and
        report the commands a plan states as part of a task's acceptance
        condition. Spans outside an attribution window are dropped, because a
        span that belongs to no task cannot be reported against one.

    Args:
        text (str): Full plan document text.

    Returns:
        list[PlanCommand]: Extracted commands in source order.

    Raises:
        None.

    Side Effects:
        None.
    """

    commands: list[PlanCommand] = []
    current_task: str | None = None
    in_fence = False
    window_lines: list[str] = []
    window_start = 0

    # Walk the plan in source order, maintaining the attribution window so each
    # span is reported against the task whose acceptance condition states it.
    for line_number, line in enumerate(text.splitlines(), start=1):
        if _FENCE_RE.match(line):
            in_fence = not in_fence
            if current_task is not None:
                window_lines.append(line)
            continue

        # Inside a fence every non-blank line is a whole-line command candidate.
        if in_fence:
            if current_task is None:
                continue
            window_lines.append(line)
            fenced = line.strip()
            if fenced:
                _append_command(commands, current_task, line_number, fenced)
            continue

        # A heading closes the current attribution window.
        if PLAN_GATE_HEADING_RE.match(line):
            _close_window(commands, window_start, window_lines)
            window_start = len(commands)
            window_lines = []
            current_task = None
            continue

        task_match = PLAN_GATE_TASK_RE.match(line)
        if task_match is not None:
            # A task line closes the preceding window and opens the next one.
            _close_window(commands, window_start, window_lines)
            window_start = len(commands)
            window_lines = []
            current_task = _task_identifier(task_match)

        if current_task is None:
            continue

        window_lines.append(line)
        # A single line may carry several backticked spans; each is a candidate.
        for span in _INLINE_SPAN_RE.findall(line):
            _append_command(commands, current_task, line_number, span)

    # The end of the document closes the final window.
    _close_window(commands, window_start, window_lines)
    return commands
