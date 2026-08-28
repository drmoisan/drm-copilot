"""Summary and appendix document assembly for the PR-context collector.

This module holds the two document-assembly blocks that were inlined in
``collector.collect_and_write``, together with the two character budgets they
truncate against and the summary-preparation helpers the summary builder
consumes. Extracting them keeps ``collector.py`` within the 500-line limit
without changing what either document contains.

The output-path contract is unchanged and is deliberately not expressed here:
neither function writes a file and neither resolves a path. ``collector.py``
continues to write to the path it was given, resolved by the host against its
own working directory.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from .models import (
    FeatureDocExcerpt,
    IssueDetails,
    PRContextResult,
    PullRequestDetails,
    format_list,
    section,
    truncate_lines,
)
from .summary_helpers import bucket_text
from .summary_helpers import (
    issue_appendix as _issue_appendix,
)
from .summary_helpers import (
    pr_appendix as _pr_appendix,
)
from .verification_evidence import (
    VerificationEvidenceRecord,
    parse_verification_evidence_file,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

__all__ = [
    "SUMMARY_CHAR_BUDGET",
    "APPENDIX_CHAR_BUDGET",
    "build_appendix_document",
    "build_feature_summary",
    "build_summary_document",
    "render_verification_evidence_section",
]

SUMMARY_CHAR_BUDGET = 160000  # 10x increase: ~2300 lines at 70 chars/line avg
APPENDIX_CHAR_BUDGET = 480000  # 10x increase: ~6900 lines at 70 chars/line avg


def render_verification_evidence_section(
    *, resolved_root: Path, feature_docs: list[FeatureDocExcerpt]
) -> str:
    """Render canonical verification evidence rows for summary output.

    Args:
        resolved_root: Repository root used to read discovered evidence files.
        feature_docs: Feature excerpts whose context files may include evidence paths.

    Returns:
        A formatted section body containing parsed evidence rows or fallback text.

    Side Effects:
        Reads evidence files from disk and tolerates unreadable artifacts.
    """
    records: list[VerificationEvidenceRecord] = []
    # Parse only canonical evidence files already enumerated in context files.
    for doc in feature_docs:
        for raw_path in doc.context_files:
            normalized = raw_path.replace("\\", "/")
            if "/evidence/" not in normalized:
                continue
            try:
                record: VerificationEvidenceRecord = parse_verification_evidence_file(
                    root=resolved_root,
                    feature=doc.feature,
                    relative_path=Path(normalized),
                )
            except OSError:
                continue
            records.append(record)

    parseable_records = [
        item for item in records if item.normalized_result in {"pass", "fail"}
    ]
    if not parseable_records:
        return "No canonical verification evidence parsed"

    lines: list[str] = []
    # Render deterministic rows sorted by source path for stable artifacts.
    for record in sorted(parseable_records, key=lambda item: item.source_file):
        # Show a declared expectation only when non-zero; other rows render as before.
        expected = record.expected_exit_code
        expected_rows = [f"  - Expected EXIT_CODE: {expected}"] if expected else []
        lines.extend(
            [
                f"- Feature: {record.feature}",
                f"  - Source: {record.source_file}",
                f"  - Timestamp: {record.timestamp}",
                f"  - Command: {record.command}",
                f"  - EXIT_CODE: {record.exit_code}",
                *expected_rows,
                f"  - Normalized result: {record.normalized_result}",
            ]
        )
    return "\n".join(lines)


def build_feature_summary(feature_docs: list[FeatureDocExcerpt]) -> str:
    """Assemble the feature-doc excerpt block shown in the summary.

    Args:
        feature_docs: Feature excerpts discovered for this range.

    Returns:
        The rendered block, or ``(none)`` when there are no feature docs.
    """
    feature_summary_lines: list[str] = []
    for doc in feature_docs:
        feature_summary_lines.extend(
            [
                f"Feature: {doc.feature}",
                "Excerpt:",
                truncate_lines(doc.excerpt, 80),
                "Context files:",
                format_list(doc.context_files, "(none)"),
                "",
            ]
        )
    if not feature_summary_lines:
        return "(none)"
    return "\n".join(feature_summary_lines).rstrip()


def build_summary_document(
    *,
    generated_section: str,
    gh_status_text: str,
    gh_available: bool,
    context_result: PRContextResult,
    head: str | None,
    issues_to_autoclose_section: str,
    close_candidates: str,
    additional_context_files: Sequence[str],
    feature_summary: str,
    referenced_issues: Sequence[str],
    referenced_prs: Sequence[str],
    invalid_refs: Sequence[str],
    scoping_summary_lines: Sequence[str],
    bucket_core: Sequence[tuple[str, tuple[int, int]]],
    bucket_renames: Sequence[tuple[str, tuple[int, int]]],
    bucket_docs: Sequence[tuple[str, tuple[int, int]]],
    issue_digests: str,
    pr_digests: str,
    verification_evidence_section: str,
    ci_status: str | None,
    ci_jobs: Sequence[str],
    appendix_path: Path,
) -> str:
    """Assemble the summary document text.

    The generated-context freshness header is the first entry, ahead of the
    GitHub CLI status section, so a consumer can read the generation timestamp
    and the head SHA without parsing the body.

    Args:
        generated_section: Freshness header rendered once for this invocation.
        gh_status_text: Resolved GitHub CLI status line.
        gh_available: Whether the GitHub CLI was usable for this run.
        context_result: The computed PR context record.
        head: Requested head ref, used only as a display fallback.
        issues_to_autoclose_section: Pre-rendered autoclose section.
        close_candidates: Pre-rendered close-candidates section.
        additional_context_files: Additional context file paths.
        feature_summary: Pre-rendered feature-doc excerpt block.
        referenced_issues: Classified referenced issue refs.
        referenced_prs: Classified referenced pull-request refs.
        invalid_refs: References that could not be resolved.
        scoping_summary_lines: Pre-rendered scoping-summary lines.
        bucket_core: Core-logic changed files with their stats.
        bucket_renames: Mechanical move/rename files with their stats.
        bucket_docs: Docs/templates/agents/tooling files with their stats.
        issue_digests: Pre-joined issue digests.
        pr_digests: Pre-joined pull-request digests.
        verification_evidence_section: Pre-rendered verification-evidence rows.
        ci_status: CI status for the head commit, when resolved.
        ci_jobs: Failing job names, when any.
        appendix_path: Path named by the appendix pointer section.

    Returns:
        The (possibly truncated) summary text.
    """
    intent_block = "\n".join(
        [
            section("PR Intent"),
            "Primary outcome:",
            "User/dev impact:",
            "Risks:",
            "Author-asserted autoclose issues:",
        ]
    )

    summary_sections = [
        generated_section,
        section("GitHub CLI status"),
        gh_status_text,
        intent_block,
        section("Base/Head"),
        f"Base ref (requested): {context_result.base_ref or '(default)'}",
        (
            f"Base ref (resolved): {context_result.resolved_base or '(unknown)'} @ "
            f"{context_result.base_sha or '(unknown)'}"
        ),
        (
            f"Head ref (resolved): {context_result.head_ref or head or '(unknown)'} @ "
            f"{context_result.head_sha or '(unknown)'}"
        ),
        f"Merge base: {context_result.merge_base or '(unknown)'}",
        f"Range: {context_result.rev_range or '(unknown)'}",
    ]
    if (
        context_result.base_ref
        and context_result.resolved_base
        and not str(context_result.resolved_base).startswith("origin/")
    ):
        summary_sections.append(
            "WARNING: Requested base is local and may be stale; prefer "
            f"origin/{context_result.base_ref}"
        )
    summary_sections.extend(
        [
            "",
            issues_to_autoclose_section,
            "",
            close_candidates,
            "",
            section("Additional context files"),
            format_list(list(additional_context_files), "(none)"),
            "",
            section("Feature doc excerpts"),
            feature_summary,
            "",
            section("Referenced issues (classified)"),
            format_list(list(referenced_issues), "(none)")
            + ("\nNOTE: Unverified (GitHub unavailable)" if not gh_available else ""),
            "",
            section("PRs in range (classified)"),
            format_list(list(referenced_prs), "(none)"),
            "",
            section("Invalid references (not found)"),
            format_list(list(invalid_refs), "(none)"),
            "",
            section("Scoping docs changed"),
            "\n".join(scoping_summary_lines),
            "",
            section("Changed files overview"),
            bucket_text("Core logic changes", list(bucket_core)),
            "",
            bucket_text("Mechanical moves/renames", list(bucket_renames)),
            "",
            bucket_text("Docs/templates/agents/tooling", list(bucket_docs)),
            "",
            section("Issue digests"),
            issue_digests or "(none)",
            "",
            section("PR digests"),
            pr_digests or "(none)",
            "",
            section("Verification evidence (feature docs + canonical artifacts)"),
            verification_evidence_section,
            "",
            section("CI status (HEAD)"),
            (
                f"Status: {ci_status}\n"
                + (f"Failing jobs: {', '.join(ci_jobs)}" if ci_jobs else "")
                if ci_status
                else "(not available)"
            ),
            "",
            section("Appendix pointer"),
            f"See {appendix_path}",
        ]
    )

    summary_text = "\n".join(summary_sections)
    if len(summary_text) > SUMMARY_CHAR_BUDGET:
        summary_text = (
            summary_text[:SUMMARY_CHAR_BUDGET] + "\nTRUNCATED: summary budget exceeded"
        )
    return summary_text


def build_appendix_document(
    *,
    generated_section: str,
    context_result: PRContextResult,
    issue_details: Sequence[IssueDetails],
    pr_details_list: Sequence[PullRequestDetails],
    feature_docs: Sequence[FeatureDocExcerpt],
) -> str:
    """Assemble the appendix document text.

    The generated-context freshness header is the first entry, carrying the same
    timestamp string the summary carries because both receive the identical
    rendered section.

    Args:
        generated_section: Freshness header rendered once for this invocation.
        context_result: The computed PR context record.
        issue_details: Issue records rendered into the issue-details section.
        pr_details_list: Pull-request records rendered into their section.
        feature_docs: Feature excerpts appended as the trailing feature block.

    Returns:
        The (possibly truncated) appendix text.
    """
    feature_block = "\n".join(doc.excerpt for doc in feature_docs)

    issue_sections = [_issue_appendix(detail) for detail in issue_details]
    pr_sections = [_pr_appendix(detail) for detail in pr_details_list]
    appendix_parts = [
        generated_section,
        context_result.text,
        "",
        section("Issue details"),
        "\n\n".join(issue_sections) if issue_sections else "(none)",
        "",
        section("Contributing pull requests"),
        "\n\n".join(pr_sections) if pr_sections else "(none)",
    ]
    if feature_block:
        appendix_parts.extend(["", feature_block])
    appendix_text = "\n".join(appendix_parts)
    if len(appendix_text) > APPENDIX_CHAR_BUDGET:
        appendix_text = (
            appendix_text[:APPENDIX_CHAR_BUDGET]
            + "\nTRUNCATED: appendix budget exceeded"
        )
    return appendix_text
