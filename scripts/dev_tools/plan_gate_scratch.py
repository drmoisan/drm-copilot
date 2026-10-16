"""Evaluate the G10 plan-gate rule: a SCRATCH definition must name an issue.

Purpose:
    Report every logical line of an atomic plan that defines the `SCRATCH`
    token without namespacing it by issue number. Concurrent child runs in one
    session share one session scratchpad, so a plan must point `SCRATCH` at
    `<session scratchpad>/issue-<issue-num>/` rather than at the bare
    scratchpad (issue #900 introduced the rule; issue #932 enforces it).

Responsibilities and scope boundaries:
    G10 is document-level and context-free. It reads the whole plan text,
    including the preamble and terms lists that the task-attributed command
    extractor drops, and it never consults the repository seam. Lines inside
    fenced code blocks are skipped.

Key invariants:
    The runtime import graph stays acyclic. This module imports only the
    shared line splitter, `PLAN_WHITESPACE_CLASS`, and
    `normalize_plan_whitespace` from `plan_gate_commands` at runtime, and it
    reads `PlanGateReport` from `plan_gate_discrimination` under
    `TYPE_CHECKING` only, because `plan_gate_discrimination` imports this
    module. Physical lines are split on CR LF, LF, and CR only, matching the
    TypeScript twin. Blank-line, continuation, and normalization tests use
    `PLAN_WHITESPACE_CLASS`, which G6 also uses and whose pattern string is
    identical in the TypeScript twin. Every finding renders the logical line
    between backticks; the
    f-string conversion flag and the builtin that produce a Python
    representation are prohibited here, because that builtin selects its quote
    character from the value's contents while the TypeScript twin renders the
    value verbatim, and the two runtimes must agree byte for byte.

Side effects:
    None. The module reads no file, clock, environment variable, or git state.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from scripts.dev_tools.plan_gate_commands import (
    PLAN_WHITESPACE_CLASS,
    normalize_plan_whitespace,
    split_plan_lines,
)

if TYPE_CHECKING:
    from scripts.dev_tools.plan_gate_discrimination import PlanGateReport

# Channel names, declared here rather than imported. `plan_gate_discrimination`
# imports this module, so importing its channel constants back would form a
# cycle. This mirrors `plan_gate_observability`, which declares the same copy.
BLOCKING_CHANNEL = "blocking"
WARNING_CHANNEL = "warning"

# G10 ships on the Blocking channel by operator-approved scope for issue #932
# and by the pre-declared two-conjunct decision rule recorded in the issue #932
# feature folder evidence.
G10_SEVERITY: str = BLOCKING_CHANNEL

# The command extractor's fence pattern, repeated so this module needs no
# private import; a parity test asserts the two patterns are identical.
FENCE_RE = re.compile(r"^\s*```")

# Step 1 of the detection contract: a definition of SCRATCH. The pattern uses
# no lookbehind, so the Python and JavaScript dialects agree.
SCRATCH_DEFINITION_PATTERN = (
    r"(?:^|[^A-Za-z0-9_<>$/.-])`?SCRATCH`?(?:\*\*)?[ \t]*"
    r"(?:means\b|:=|=|:|is (?:the|a|an)\b|resolves to\b|abbreviates\b"
    r"|denotes\b|refers to\b|stands for\b)"
)

# Step 2 of the detection contract: an accepted issue namespace.
SCRATCH_NAMESPACE_PATTERN = r"issue-(?:<issue-num>|[0-9]+)"

_DEFINITION_RE = re.compile(SCRATCH_DEFINITION_PATTERN, re.ASCII)
_NAMESPACE_RE = re.compile(SCRATCH_NAMESPACE_PATTERN, re.ASCII)

_WHITESPACE_RUN_RE = re.compile(PLAN_WHITESPACE_CLASS + "+")


def _continues_logical_line(line: str) -> bool:
    """Return whether a physical line continues the current logical line.

    A continuation is non-blank, begins with whitespace, and is not a fence
    line. A Markdown ATX heading or task line written at column 0 therefore
    ends the logical line, while an indented heading or task line is absorbed
    into it. Whitespace here means `PLAN_WHITESPACE_CLASS`.
    """

    if not normalize_plan_whitespace(line) or _WHITESPACE_RUN_RE.match(line) is None:
        return False
    return FENCE_RE.match(line) is None


def _is_bare_definition(logical_line: str) -> bool:
    """Return whether a normalized logical line defines SCRATCH without a namespace."""

    match = _DEFINITION_RE.search(logical_line)
    if match is None:
        return False
    return _NAMESPACE_RE.search(logical_line[match.end() :]) is None


def bare_scratch_definitions(text: str) -> list[tuple[int, str]]:
    """Return every unfenced logical line that defines SCRATCH without an issue.

    Purpose:
        Apply the G10 detection contract in one linear pass. A logical line is
        a non-fenced physical line plus each immediately following continuation
        line; it is normalized by joining whitespace runs with one space.

    Args:
        text (str): Full document text.

    Returns:
        list[tuple[int, str]]: One `(line number, normalized logical line)`
        pair per offending logical line, in source order. The line number is
        the 1-based physical line number of the logical line's first line.

    Raises:
        None.

    Side Effects:
        None.
    """

    lines = split_plan_lines(text)
    findings: list[tuple[int, str]] = []
    in_fence = False
    index = 0

    # Walk the document once. A fence line toggles the fence state, and every
    # fenced line is skipped, so a definition quoted in a fence is not reported.
    while index < len(lines):
        line = lines[index]
        if FENCE_RE.match(line):
            in_fence = not in_fence
            index += 1
            continue
        if in_fence or not normalize_plan_whitespace(line):
            index += 1
            continue

        # A logical line starts here and absorbs its continuation lines.
        start = index
        parts = [line]
        index += 1
        while index < len(lines) and _continues_logical_line(lines[index]):
            parts.append(lines[index])
            index += 1

        logical_line = normalize_plan_whitespace(" ".join(parts))
        if _is_bare_definition(logical_line):
            findings.append((start + 1, logical_line))
    return findings


def scratch_finding_message(line_number: int, logical_line: str) -> str:
    """Return the G10 finding string for one offending logical line.

    Args:
        line_number (int): 1-based first physical line of the logical line.
        logical_line (str): Normalized logical line, rendered verbatim.

    Returns:
        str: The Error Message Contract string, byte-identical to the
        TypeScript twin.

    Raises:
        None.

    Side Effects:
        None.
    """

    return (
        f"Line {line_number}: SCRATCH definition `{logical_line}` is not "
        "namespaced by issue number; define SCRATCH as "
        "`<session scratchpad>/issue-<issue-num>/`."
    )


def evaluate_scratch_gate(
    report: PlanGateReport, text: str, *, severity: str = G10_SEVERITY
) -> None:
    """Append one G10 finding per offending logical line to the report.

    Args:
        report (PlanGateReport): Report whose channels receive the findings.
        text (str): Full plan document text.
        severity (str): Channel name. `BLOCKING_CHANNEL` selects the Blocking
            list; any other value selects the Warning list. Defaults to
            `G10_SEVERITY`.

    Returns:
        None.

    Raises:
        None.

    Side Effects:
        Appends to `report.blocking` or `report.warnings` only.
    """

    channel = report.blocking if severity == BLOCKING_CHANNEL else report.warnings
    for line_number, logical_line in bare_scratch_definitions(text):
        channel.append(scratch_finding_message(line_number, logical_line))
