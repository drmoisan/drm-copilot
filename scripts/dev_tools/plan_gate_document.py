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
from types import MappingProxyType
from typing import TYPE_CHECKING

from scripts.dev_tools.plan_gate_commands import (
    PLAN_WHITESPACE_CLASS,
    normalize_plan_whitespace,
    split_plan_lines,
)
from scripts.dev_tools.plan_gate_scratch import FENCE_RE

if TYPE_CHECKING:
    from collections.abc import Mapping

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

# G13 size guideline: canonical task lines and physical lines. A plan file whose
# stamp sorts before the cutoff of its stamp zone keeps the legacy pair.
PLAN_TASK_GUIDELINE = 20
PLAN_LINE_GUIDELINE = 250
LEGACY_PLAN_TASK_GUIDELINE = 40
LEGACY_PLAN_LINE_GUIDELINE = 400

# Stamp zone of each plan-file name shape: the feature-folder tooling stamps
# `plan.<stamp>.md` in America/New_York, and remediation plans carry the UTC
# stamp of the review that produced them.
PLAN_STAMP_ZONES: Mapping[str, str] = MappingProxyType(
    {
        "plan": "America/New_York",
        "plan-remediation-cycle": "UTC",
        "remediation-plan": "UTC",
        "remediation-folder": "UTC",
    }
)

# G13 guideline cutoff: one instant, the clock reading of the G13 commit,
# written once per stamp zone. Each entry is a `yyyy-MM-ddTHH-mm` stamp.
PLAN_GUIDELINE_CUTOFF: Mapping[str, str] = MappingProxyType(
    {
        "America/New_York": "2026-11-07T18-31",
        "UTC": "2026-11-07T23-31",
    }
)

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
_STAMP_TEXT = r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}"
_STAMP_RE = re.compile(_STAMP_TEXT, re.ASCII)
_PATH_SEPARATOR_RE = re.compile(r"[\\/]")
# K4 file-name shapes whose stamp sits in the name, in match order.
_NAME_SHAPES: tuple[tuple[str, re.Pattern[str]], ...] = (
    ("plan", re.compile(rf"plan\.({_STAMP_TEXT})\.md", re.ASCII)),
    (
        "plan-remediation-cycle",
        re.compile(rf"plan\.remediation-cycle-[0-9]+\.({_STAMP_TEXT})\.md", re.ASCII),
    ),
    (
        "remediation-plan",
        re.compile(rf"remediation-plan\.({_STAMP_TEXT})\.md", re.ASCII),
    ),
)
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


def plan_file_stamp(path: str | None) -> tuple[str, str] | None:
    """Return the stamp of a plan-file path with the zone of its name shape.

    Purpose:
        Read the K4 stamp shapes: `plan.<stamp>.md` (America/New_York),
        `plan.remediation-cycle-<N>.<stamp>.md`, `remediation-plan.<stamp>.md`,
        and `remediation/<stamp>/remediation-plan.md` (all UTC). The path is
        split on both `/` and `\\`, so a Windows path and a POSIX path read
        the same. Matching is case-sensitive and each name must match fully.

    Args:
        path (str | None): Plan-file path, relative or absolute, or `None`.

    Returns:
        tuple[str, str] | None: `(stamp, zone)` for a recognized shape, with the
        zone taken from `PLAN_STAMP_ZONES`; `None` for any other name, an
        empty path, or no path.

    Raises:
        None.

    Side Effects:
        None. The path is parsed as text and never read from disk.
    """

    if not path:
        return None
    segments = _PATH_SEPARATOR_RE.split(path)
    name = segments[-1]
    # Try the shapes whose stamp sits in the file name; the first full match
    # decides the shape, and the shapes cannot both match one name.
    for shape, pattern in _NAME_SHAPES:
        match = pattern.fullmatch(name)
        if match is not None:
            return match.group(1), PLAN_STAMP_ZONES[shape]
    # The folder form carries its stamp in the parent segment, under a
    # `remediation` segment, and only for the exact name `remediation-plan.md`.
    is_folder_form = (
        name == "remediation-plan.md"
        and len(segments) >= 3
        and _STAMP_RE.fullmatch(segments[-2]) is not None
        and segments[-3] == "remediation"
    )
    if is_folder_form:
        return segments[-2], PLAN_STAMP_ZONES["remediation-folder"]
    return None


def plan_size_guideline(
    stamped: tuple[str, str] | None,
    *,
    cutoff: Mapping[str, str] = PLAN_GUIDELINE_CUTOFF,
) -> tuple[int, int]:
    """Return the G13 task and line guideline that applies to a plan stamp.

    Purpose:
        Keep the legacy pair for a plan written before G13 lowered the
        guideline. A stamp is compared, as a string, with the cutoff entry of
        its own zone, so a UTC stamp is never read against the New York entry.

    Args:
        stamped (tuple[str, str] | None): `(stamp, zone)` from
            `plan_file_stamp`, or `None` when the plan has no recognized stamp.
        cutoff (Mapping[str, str]): Cutoff stamp per zone. Defaults to
            `PLAN_GUIDELINE_CUTOFF`; tests inject a fixed pair.

    Returns:
        tuple[int, int]: The legacy pair when a stamp exists and sorts strictly
        before its zone's cutoff entry; otherwise the current pair, including
        for a zone the cutoff mapping holds no entry for.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Only a stamped plan from before the cutoff keeps the legacy pair; an
    # unstamped plan and a stamp at or after the cutoff use the current pair.
    # A zone with no entry compares with the empty string, which no stamp
    # sorts before.
    if stamped is not None:
        stamp, zone = stamped
        if stamp < cutoff.get(zone, ""):
            return LEGACY_PLAN_TASK_GUIDELINE, LEGACY_PLAN_LINE_GUIDELINE
    return PLAN_TASK_GUIDELINE, PLAN_LINE_GUIDELINE


def plan_size_message(
    tasks: int,
    lines: int,
    *,
    guideline: tuple[int, int] = (PLAN_TASK_GUIDELINE, PLAN_LINE_GUIDELINE),
) -> str:
    """Return the G13 finding string, byte-identical to the TypeScript twin.

    Args:
        tasks (int): Canonical task-line count.
        lines (int): Physical-line count.
        guideline (tuple[int, int]): The task and line guideline that applied.

    Returns:
        str: The finding string naming the guideline that applied.

    Raises:
        None.

    Side Effects:
        None.
    """

    task_guideline, line_guideline = guideline
    return (
        f"Line 1: plan size `{tasks} tasks, {lines} lines` exceeds the "
        f"guideline of {task_guideline} tasks or {line_guideline} "
        "lines and carries no `## Size Justification` section; split the item "
        "or state why the size is necessary."
    )


def _channel(report: PlanGateReport, severity: str) -> list[str]:
    """Return the report list a severity constant selects."""

    return report.blocking if severity == BLOCKING_CHANNEL else report.warnings


def evaluate_document_gates(
    report: PlanGateReport, text: str, *, plan_path: str | None = None
) -> None:
    """Append the G11, G12, and G13 findings for a plan document to the report.

    G13 selects its guideline from the stamp of `plan_path`: a plan stamped
    before the cutoff of its stamp zone keeps the legacy pair, and a plan with
    no path or no recognized stamp uses the current pair.

    Args:
        report (PlanGateReport): Report whose channels receive the findings.
        text (str): Full plan document text.
        plan_path (str | None): Plan-file path, used only to read its stamp.

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
    guideline = plan_size_guideline(plan_file_stamp(plan_path))
    over_guideline = tasks > guideline[0] or lines > guideline[1]
    if over_guideline and not has_size_justification(text):
        _channel(report, G13_SEVERITY).append(
            plan_size_message(tasks, lines, guideline=guideline)
        )
