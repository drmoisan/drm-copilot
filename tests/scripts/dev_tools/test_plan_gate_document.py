"""Unit tests for the document-level plan-gate rules G11, G12, and G13 (issue #964).

G11 reports line-number citations, G12 reports commit-SHA citations, and G13
reports a plan above the size guideline without a `## Size Justification`
section. Every fixture is an in-memory string with LF line endings. The same
twelve cases are duplicated, with the same names, in
`extensions/drm-copilot/test/lib/validate/plan-gate-document.test.ts`.
"""

from __future__ import annotations

from scripts.dev_tools.plan_gate_discrimination import (
    PlanGateReport,
    evaluate_plan_gates,
)
from scripts.dev_tools.plan_gate_document import (
    PLAN_LINE_GUIDELINE,
    PLAN_TASK_GUIDELINE,
    evaluate_document_gates,
    line_citation_message,
    plan_size_message,
    sha_citation_message,
)

_FULL_SHA = "0123456789abcdef0123456789abcdef01234567"
_DIGEST = "0123456789abcdef" * 4


def _run(text: str) -> PlanGateReport:
    """Evaluate the document gates alone into a fresh report."""

    report = PlanGateReport()
    evaluate_document_gates(report, text)
    return report


def _plan(task_count: int, line_count: int, *, extra: str = "") -> str:
    """Return a plan with exactly `task_count` task lines and `line_count` lines."""

    lines = ["# Plan", ""]
    if extra:
        lines.extend(extra.split("\n"))
    lines.extend(f"- [ ] [P1-T{index}] Do step {index}." for index in range(task_count))
    while len(lines) < line_count:
        lines.append("Filler prose.")
    assert len(lines) == line_count, "fixture over-filled"
    return "\n".join(lines) + "\n"


def test_g11_reports_prose_path_and_anchor_forms() -> None:
    """Each prose, path, and anchor form match yields one Blocking finding."""

    # Arrange
    text = (
        "# Plan\n"
        "See line 26 for the detail.\n"
        "Edit lines 134-143 next.\n"
        "Read `repo-automation-args.ts:20` and ModelRouting.psm1:42 here.\n"
        "Link https://example.com/o/r/blob/main/a.ts#L20 for review.\n"
    )

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [
        line_citation_message(2, "line 26"),
        line_citation_message(3, "lines 134"),
        line_citation_message(4, "repo-automation-args.ts:20"),
        line_citation_message(4, "ModelRouting.psm1:42"),
        line_citation_message(5, "#L20"),
    ], f"unexpected G11 findings: {report.blocking}"
    assert report.warnings == [], "G11 must not use the Warning channel"


def test_g11_ignores_count_phrases_inline_code_prose_url_ports_and_fences() -> None:
    """Counts, inline-code prose quotations, URL ports, and fences are not cited."""

    # Arrange
    text = (
        "# Plan\n"
        "The file stays at or below 500 lines and the guidelines 40 apply.\n"
        "Quote the validator prefix `Line 5:` exactly.\n"
        "Call https://example.com:8443/status for health.\n"
        "```text\n"
        "line 12 inside a fence\n"
        "module.py:3 and #L9\n"
        "```\n"
    )

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [], f"expected no G11 finding: {report.blocking}"


def test_g11_reports_scheme_less_host_and_port_as_documented_false_positive() -> None:
    """A host and port written without a URL scheme yields one G11 finding.

    The class is documented in `.claude/rules/plan-acceptance-gates.md` under
    `### Known false-positive classes — G11 and G12`; this case pins it.
    """

    # Arrange
    text = "# Plan\nAllow outbound traffic to api.github.com:443 only.\n"

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [
        line_citation_message(2, "api.github.com:443"),
    ], f"unexpected G11 findings: {report.blocking}"


def test_g12_reports_full_and_abbreviated_shas_in_prose_and_inline_code() -> None:
    """Full and abbreviated SHAs are reported in prose and in inline code."""

    # Arrange
    text = (
        "# Plan\n"
        f"Compare against {_FULL_SHA} first.\n"
        "Then check `a1b2c3d` and deadbee1 in prose.\n"
    )

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [
        sha_citation_message(2, _FULL_SHA),
        sha_citation_message(3, "a1b2c3d"),
        sha_citation_message(3, "deadbee1"),
    ], f"unexpected G12 findings: {report.blocking}"


def test_g12_ignores_ids_words_uuids_suffixes_digests_and_fences() -> None:
    """Decimal IDs, letter words, UUIDs, joined suffixes, digests, and fences pass."""

    # Arrange
    text = (
        "# Plan\n"
        "Run 18542345678 used ruleset 15241672 on 2026-10-16.\n"
        "The word defaced is not a commit.\n"
        "Request 123e4567-e89b-12d3-a456-426614174000 was logged.\n"
        "Worktree agent-a2c70f7fea97f192f and build 1a2b3c4d-x and file.1a2b3c4d.\n"
        f"Digest {_DIGEST} is asserted.\n"
        "```\n"
        "a1b2c3d4 inside a fence\n"
        "```\n"
    )

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [], f"expected no G12 finding: {report.blocking}"


def test_g13_fires_above_task_guideline_without_justification() -> None:
    """A plan with one task above the guideline yields one G13 finding."""

    # Arrange
    text = _plan(PLAN_TASK_GUIDELINE + 1, 60)

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [
        plan_size_message(PLAN_TASK_GUIDELINE + 1, 60)
    ], f"unexpected G13 findings: {report.blocking}"


def test_g13_fires_above_line_guideline_without_justification() -> None:
    """A plan with one physical line above the guideline yields one G13 finding."""

    # Arrange
    text = _plan(3, PLAN_LINE_GUIDELINE + 1)

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [
        plan_size_message(3, PLAN_LINE_GUIDELINE + 1)
    ], f"unexpected G13 findings: {report.blocking}"


def test_g13_silent_at_both_guidelines() -> None:
    """A plan exactly at both guidelines yields no G13 finding."""

    # Arrange
    text = _plan(PLAN_TASK_GUIDELINE, PLAN_LINE_GUIDELINE)

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [], f"expected no G13 finding: {report.blocking}"


def test_g13_silent_with_nonempty_justification() -> None:
    """A non-empty `## Size Justification` section exonerates an oversized plan."""

    # Arrange
    justification = (
        "## Size Justification\n\n### Why\n\n"
        "The inventory spans three surfaces.\n\n## Phases"
    )
    text = _plan(PLAN_TASK_GUIDELINE + 5, PLAN_LINE_GUIDELINE + 5, extra=justification)

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [], f"expected no G13 finding: {report.blocking}"


def test_g13_empty_justification_does_not_exonerate() -> None:
    """A justification section with only blanks and headings does not exonerate."""

    # Arrange
    justification = "## Size Justification\n\n### Reason\n\n## Phases\n\nPhase prose."
    text = _plan(PLAN_TASK_GUIDELINE + 1, 80, extra=justification)

    # Act
    report = _run(text)

    # Assert
    assert report.blocking == [
        plan_size_message(PLAN_TASK_GUIDELINE + 1, 80)
    ], f"an empty justification must not exonerate: {report.blocking}"


def test_evaluate_plan_gates_reports_document_gates_after_g10() -> None:
    """`evaluate_plan_gates` appends G11 to G13 findings after the G10 finding."""

    # Arrange
    text = (
        "# Plan\n"
        "- SCRATCH means the session scratchpad directory.\n"
        "See line 7 of the brief.\n"
    )

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert len(report.blocking) == 2, f"expected G10 then G11: {report.blocking}"
    assert report.blocking[0].startswith(
        "Line 2: SCRATCH definition"
    ), f"G10 must be first: {report.blocking}"
    assert report.blocking[1] == line_citation_message(
        3, "line 7"
    ), f"G11 must follow G10: {report.blocking}"


def test_document_gates_run_without_context() -> None:
    """The document gates run when no repository context is supplied."""

    # Arrange
    text = "# Plan\n\nPinned to a1b2c3d4e5 at the time of writing.\n"

    # Act
    report = evaluate_plan_gates(text, context=None)

    # Assert
    assert report.blocking == [
        sha_citation_message(3, "a1b2c3d4e5")
    ], f"G12 must run without a context: {report.blocking}"
    assert report.warnings == [], "no Warning is expected without a context"
