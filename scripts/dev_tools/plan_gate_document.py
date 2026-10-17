"""Evaluate the document-level plan-gate rules G11, G12, and G13.

Purpose:
    Report the plan-text defects that make a design-level plan go stale or
    grow past review size (issue #964). G11 reports a line-number citation,
    G12 reports a commit-SHA citation, and G13 reports a plan whose task or
    physical-line count exceeds the size guideline without a
    `## Size Justification` section.

Responsibilities and scope boundaries:
    All three rules are document-level and context-free. They read the whole
    plan text, skip lines inside fenced code blocks, and never consult the
    repository seam. G11 and G12 report one finding per match; G13 reports at
    most one finding per document.

Key invariants:
    The runtime import graph stays acyclic. This module imports only the
    shared line splitter, `PLAN_WHITESPACE_CLASS`, and
    `normalize_plan_whitespace` from
    `plan_gate_commands` and the fence pattern from `plan_gate_scratch` at
    runtime, and it reads `PlanGateReport` from `plan_gate_discrimination`
    under `TYPE_CHECKING` only, because `plan_gate_discrimination` imports this
    module. Physical lines are split on CR LF, LF, and CR only, matching the
    TypeScript twin. No pattern uses lookbehind, so the Python and JavaScript
    dialects agree; G12's adjacency conditions are checked in code. Every
    finding renders the offending value between backticks; the f-string
    conversion flag and the builtin that produce a Python representation are
    prohibited here, because that builtin selects its quote character from the
    value's contents while the TypeScript twin renders the value verbatim.

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
from scripts.dev_tools.plan_gate_scratch import FENCE_RE

if TYPE_CHECKING:
    from scripts.dev_tools.plan_gate_discrimination import PlanGateReport

# Channel names, declared here rather than imported, for the same import-cycle
# reason recorded in `plan_gate_scratch`.
BLOCKING_CHANNEL = "blocking"
WARNING_CHANNEL = "warning"

# G11 and G12 ship on the Blocking channel by operator-approved scope for issue
# #964. G13 ships Blocking because its exoneration is under the author's control.
G11_SEVERITY: str = BLOCKING_CHANNEL
G12_SEVERITY: str = BLOCKING_CHANNEL
G13_SEVERITY: str = BLOCKING_CHANNEL

# G13 size guideline: canonical task lines and physical lines.
PLAN_TASK_GUIDELINE = 40
PLAN_LINE_GUIDELINE = 400

# G11 prose form, evaluated with inline code spans masked.
G11_PROSE_PATTERN = r"\b[Ll]ines?[ \t]+[0-9]+"
# G11 path form, evaluated including inline code.
G11_PATH_PATTERN = r"[A-Za-z0-9_./-]+\.[A-Za-z][A-Za-z0-9]{0,5}:[0-9]+"
# G11 anchor form.
G11_ANCHOR_PATTERN = r"#L[0-9]+"
# G12 bounded hexadecimal run; the digit, letter, and adjacency checks are code.
G12_SHA_PATTERN = r"\b[0-9a-f]{7,40}\b"
# G13 canonical task line.
G13_TASK_PATTERN = r"^- \[[ xX]\] \[P[0-9]+-T[0-9]+\] "
# Inline code span masked before the G11 prose form is applied.
INLINE_CODE_PATTERN = r"`[^`]*`"

_PROSE_RE = re.compile(G11_PROSE_PATTERN, re.ASCII)
_PATH_RE = re.compile(G11_PATH_PATTERN, re.ASCII)
_ANCHOR_RE = re.compile(G11_ANCHOR_PATTERN, re.ASCII)
_SHA_RE = re.compile(G12_SHA_PATTERN, re.ASCII)
_TASK_RE = re.compile(G13_TASK_PATTERN, re.ASCII)
_INLINE_CODE_RE = re.compile(INLINE_CODE_PATTERN)
_WHITESPACE_RE = re.compile(PLAN_WHITESPACE_CLASS)
_JUSTIFICATION_HEADING_RE = re.compile(r"^##[ \t]+Size Justification[ \t]*$")
_SECTION_END_RE = re.compile(r"^#{1,2}(?:[ \t]|$)")
_HEADING_RE = re.compile(r"^#{1,6}(?:[ \t]|$)")
_DIGITS = frozenset("0123456789")
_HEX_LETTERS = frozenset("abcdef")
_SHA_BEFORE_REJECT = frozenset("-_.")
_SHA_AFTER_REJECT = frozenset("-_")


def unfenced_lines(text: str) -> list[tuple[int, str]]:
    """Return every physical line outside a fenced code block with its number.

    Args:
        text (str): Full document text.

    Returns:
        list[tuple[int, str]]: `(1-based line number, line)` pairs in source
        order. Fence lines themselves are excluded.

    Raises:
        None.

    Side Effects:
        None.
    """

    result: list[tuple[int, str]] = []
    in_fence = False
    for index, line in enumerate(split_plan_lines(text)):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if not in_fence:
            result.append((index + 1, line))
    return result


def _mask_inline_code(line: str) -> str:
    """Replace each inline code span with spaces of the same length."""

    return _INLINE_CODE_RE.sub(lambda match: " " * len(match.group(0)), line)


def _enclosing_token(line: str, start: int, end: int) -> str:
    """Return the whitespace-delimited token that contains a match."""

    left = start
    while left > 0 and _WHITESPACE_RE.match(line[left - 1]) is None:
        left -= 1
    right = end
    while right < len(line) and _WHITESPACE_RE.match(line[right]) is None:
        right += 1
    return line[left:right]


def line_citations(text: str) -> list[tuple[int, str]]:
    """Return every G11 line-number citation in unfenced text.

    Purpose:
        Apply the prose form to each line with inline code masked, then the
        path form (skipping a match whose enclosing token contains `://`),
        then the anchor form, each to the unmasked line.

    Args:
        text (str): Full document text.

    Returns:
        list[tuple[int, str]]: One `(line number, matched text)` pair per
        match, in line order and, within a line, in form order.

    Raises:
        None.

    Side Effects:
        None.
    """

    findings: list[tuple[int, str]] = []
    for number, line in unfenced_lines(text):
        for match in _PROSE_RE.finditer(_mask_inline_code(line)):
            findings.append((number, match.group(0)))
        for match in _PATH_RE.finditer(line):
            if "://" in _enclosing_token(line, match.start(), match.end()):
                continue
            findings.append((number, match.group(0)))
        for match in _ANCHOR_RE.finditer(line):
            findings.append((number, match.group(0)))
    return findings


def _is_sha_candidate(line: str, start: int, end: int) -> bool:
    """Return whether a bounded hex run is reportable as a commit SHA."""

    token = line[start:end]
    if not any(character in _DIGITS for character in token):
        return False
    if not any(character in _HEX_LETTERS for character in token):
        return False
    if start > 0 and line[start - 1] in _SHA_BEFORE_REJECT:
        return False
    return not (end < len(line) and line[end] in _SHA_AFTER_REJECT)


def sha_citations(text: str) -> list[tuple[int, str]]:
    """Return every G12 commit-SHA citation in unfenced text.

    Args:
        text (str): Full document text.

    Returns:
        list[tuple[int, str]]: One `(line number, hex run)` pair per accepted
        match, in source order.

    Raises:
        None.

    Side Effects:
        None.
    """

    findings: list[tuple[int, str]] = []
    for number, line in unfenced_lines(text):
        for match in _SHA_RE.finditer(line):
            if _is_sha_candidate(line, match.start(), match.end()):
                findings.append((number, match.group(0)))
    return findings


def has_size_justification(text: str) -> bool:
    """Return whether a `## Size Justification` section carries content.

    The section is exonerating when at least one unfenced line after the
    heading is non-blank and is not a heading, before the next heading of
    level one or two.

    Args:
        text (str): Full document text.

    Returns:
        bool: True when a non-empty justification section exists.

    Raises:
        None.

    Side Effects:
        None.
    """

    in_section = False
    for _, line in unfenced_lines(text):
        if _JUSTIFICATION_HEADING_RE.match(line):
            in_section = True
            continue
        if not in_section:
            continue
        if _SECTION_END_RE.match(line):
            in_section = False
            continue
        if normalize_plan_whitespace(line) and not _HEADING_RE.match(line):
            return True
    return False


def plan_size(text: str) -> tuple[int, int]:
    """Return the canonical task-line count and the physical-line count.

    Args:
        text (str): Full document text.

    Returns:
        tuple[int, int]: `(unfenced task lines, physical lines)`.

    Raises:
        None.

    Side Effects:
        None.
    """

    tasks = sum(1 for _, line in unfenced_lines(text) if _TASK_RE.match(line))
    return tasks, len(split_plan_lines(text))


def line_citation_message(line_number: int, value: str) -> str:
    """Return the G11 finding string, byte-identical to the TypeScript twin."""

    return (
        f"Line {line_number}: line-number citation `{value}` anchors on a "
        "position that moves when main moves; cite the symbol, heading, or "
        "test name instead."
    )


def sha_citation_message(line_number: int, value: str) -> str:
    """Return the G12 finding string, byte-identical to the TypeScript twin."""

    return (
        f"Line {line_number}: commit-SHA citation `{value}` names a commit "
        "that goes stale when main moves; cite the branch, ref name, or merge "
        "base derivation instead."
    )


def plan_size_message(tasks: int, lines: int) -> str:
    """Return the G13 finding string, byte-identical to the TypeScript twin."""

    return (
        f"Line 1: plan size `{tasks} tasks, {lines} lines` exceeds the "
        f"guideline of {PLAN_TASK_GUIDELINE} tasks or {PLAN_LINE_GUIDELINE} "
        "lines and carries no `## Size Justification` section; split the item "
        "or state why the size is necessary."
    )


def _channel(report: PlanGateReport, severity: str) -> list[str]:
    """Return the report list a severity constant selects."""

    return report.blocking if severity == BLOCKING_CHANNEL else report.warnings


def evaluate_document_gates(report: PlanGateReport, text: str) -> None:
    """Append the G11, G12, and G13 findings for a plan document to the report.

    Args:
        report (PlanGateReport): Report whose channels receive the findings.
        text (str): Full plan document text.

    Returns:
        None.

    Raises:
        None.

    Side Effects:
        Appends to `report.blocking` or `report.warnings` only.
    """

    g11 = _channel(report, G11_SEVERITY)
    for line_number, value in line_citations(text):
        g11.append(line_citation_message(line_number, value))

    g12 = _channel(report, G12_SEVERITY)
    for line_number, value in sha_citations(text):
        g12.append(sha_citation_message(line_number, value))

    tasks, lines = plan_size(text)
    over_guideline = tasks > PLAN_TASK_GUIDELINE or lines > PLAN_LINE_GUIDELINE
    if over_guideline and not has_size_justification(text):
        _channel(report, G13_SEVERITY).append(plan_size_message(tasks, lines))
