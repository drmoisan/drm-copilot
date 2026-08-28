"""Collect Git repository context for pull request authorship."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import TYPE_CHECKING

from .collector_documents import (
    APPENDIX_CHAR_BUDGET as APPENDIX_CHAR_BUDGET,
)
from .collector_documents import (
    SUMMARY_CHAR_BUDGET as SUMMARY_CHAR_BUDGET,
)
from .collector_documents import (
    build_appendix_document,
    build_feature_summary,
    build_summary_document,
    render_verification_evidence_section,
)
from .feature_docs import (
    completed_plan_tasks,
    extract_issue_references,
    gather_feature_excerpts,
)
from .git import CommandRunner, GitClient, SubprocessRunner
from .github import GhClient
from .models import (
    CommandResult,
    FeatureDocExcerpt,
    IssueDetails,
    PRContextResult,
    PullRequestDetails,
    find_user_story_link,
    section,
    truncate_lines,
)
from .render import (
    build_close_candidates_section,
    build_pr_context,
    convert_numstat,
    extension_summary,
    extract_changed_paths,
    extract_merge_pr_numbers,
    format_diff_path,
    format_issue_details,
    format_pr_details,
    select_default_base,
)
from .render_pr_helpers import build_issues_to_autoclose_section
from .summary_helpers import append_generation_timestamp
from .summary_helpers import (
    issue_digest as _issue_digest,
)
from .summary_helpers import (
    parse_name_status_map as _parse_name_status_map,
)
from .summary_helpers import (
    parse_numstat_detailed as _parse_numstat_detailed,
)
from .summary_helpers import (
    pr_digest as _pr_digest,
)
from .summary_helpers import (
    scoping_doc_changes as _scoping_doc_changes,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

__all__ = [
    "CommandResult",
    "FeatureDocExcerpt",
    "IssueDetails",
    "PRContextResult",
    "PullRequestDetails",
    "GitClient",
    "SubprocessRunner",
    "CommandRunner",
    "GhClient",
    "build_pr_context",
    "build_close_candidates_section",
    "completed_plan_tasks",
    "convert_numstat",
    "extension_summary",
    "extract_issue_references",
    "extract_merge_pr_numbers",
    "format_diff_path",
    "format_issue_details",
    "format_pr_details",
    "gather_feature_excerpts",
    "select_default_base",
    "find_user_story_link",
    "section",
    "extract_changed_paths",
    "collect_and_write",
    "parse_args",
    "main",
]

SUMMARY_PATH_DEFAULT = "artifacts/pr_context.summary.txt"
APPENDIX_PATH_DEFAULT = "artifacts/pr_context.appendix.txt"
ISSUE_SUMMARY_LINE_BUDGET = 25
ISSUE_APPENDIX_LINE_BUDGET = 120
COMMENT_SUMMARY_LIMIT = 3
COMMENT_APPENDIX_LIMIT = 10
PR_BODY_SUMMARY_LINES = 25
PR_BODY_APPENDIX_LINES = 120


# Re-exported so importers that reach the private name directly keep working.
# `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` imports it
# from this module deliberately rather than through a public wrapper, and its
# own docstring records that choice, so moving the function without this alias
# would leave a dangling import.
_render_verification_evidence_section = render_verification_evidence_section


# helper functions moved to summary_helpers and collector_documents


def write_output(text: str, out_path: Path, append: bool) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    mode = "a" if append else "w"
    with out_path.open(mode, encoding="utf-8") as handle:
        handle.write(text)


def collect_and_write(
    *,
    base: str | None,
    head: str | None,
    out: Path,
    appendix_out: Path | None,
    repo_root: Path,
    append: bool,
    include_untracked: bool,
) -> None:
    runner = SubprocessRunner()
    git = GitClient(runner, repo_root)
    resolved_root = git.resolve_root()
    git = GitClient(runner, resolved_root)
    gh = GhClient(runner, resolved_root)
    gh_available = True
    gh_status_override: str | None = None
    try:
        gh.ensure_available()
    except RuntimeError as exc:  # pragma: no cover - availability gate
        gh_available = False
        gh_status_override = f"GitHub CLI unavailable: {exc}"

    summary_path = out
    appendix_path = appendix_out or Path(APPENDIX_PATH_DEFAULT)

    current_pr = gh.current_pr()

    context_result = build_pr_context(
        git=git,
        gh=gh,
        base_ref=base,
        head_ref=head,
        include_untracked=include_untracked,
        feature_issue_refs=[],
        current_pr=current_pr,
        gh_available=gh_available,
    )

    changed_paths = extract_changed_paths(context_result.text)
    feature_docs = gather_feature_excerpts(resolved_root, changed_paths)
    additional_context_files = sorted(
        {path for doc in feature_docs for path in doc.context_files if path}
    )
    feature_issue_refs = sorted(
        {ref for doc in feature_docs for ref in doc.issue_refs if ref.strip()}
    )

    if feature_issue_refs:
        context_result = build_pr_context(
            git=git,
            gh=gh,
            base_ref=base,
            head_ref=head,
            include_untracked=include_untracked,
            feature_issue_refs=feature_issue_refs,
            current_pr=current_pr,
            gh_available=gh_available,
        )

    referenced_issues_set = set(context_result.referenced_issues)
    referenced_prs_set = set(context_result.referenced_prs)
    invalid_refs_set = set(context_result.invalid_references)
    branch_refs = extract_issue_references(git.branch_name())
    path_refs = extract_issue_references("\n".join(changed_paths))
    if gh_available:
        for ref in feature_issue_refs:
            formatted = ref if ref.startswith("#") else f"#{ref}"
            entity = gh.classify_entity(ref.lstrip("#"))
            if entity == "issue":
                referenced_issues_set.add(formatted)
            elif entity == "pull":
                referenced_prs_set.add(formatted)
            else:
                invalid_refs_set.add(formatted)
        for ref in branch_refs + path_refs:
            formatted = ref if ref.startswith("#") else f"#{ref}"
            entity = gh.classify_entity(ref.lstrip("#"))
            if entity == "issue":
                referenced_issues_set.add(formatted)
            elif entity == "pull":
                referenced_prs_set.add(formatted)
            else:
                invalid_refs_set.add(formatted)
    else:
        referenced_issues_set.update(
            formatted if formatted.startswith("#") else f"#{formatted}"
            for formatted in feature_issue_refs
        )
        referenced_issues_set.update(
            formatted if formatted.startswith("#") else f"#{formatted}"
            for formatted in branch_refs + path_refs
        )

    referenced_issues = sorted(referenced_issues_set)
    referenced_prs = sorted(referenced_prs_set)
    invalid_refs = sorted(invalid_refs_set)

    author_asserted: list[str] = []
    author_reason = "None (author has not asserted autoclose issues)"
    verified = context_result.verified_closing if gh_available else []
    if not gh_available:
        verified_reason = "None (GitHub CLI unavailable)"
    elif current_pr is None:
        verified_reason = "None (no PR exists yet for this branch)"
    elif not verified:
        verified_reason = "None (closingIssuesReferences empty)"
    else:
        verified_reason = "(verified from GitHub PR metadata)"

    if referenced_issues:
        author_asserted = sorted(set(author_asserted + referenced_issues))
        author_reason = "Detected issue references (classified)"

    # Derive deterministic pending autoclose targets from explicit metadata only
    # when feature readiness is PASS.
    pending_primary: list[str] = []
    for feature_doc in feature_docs:
        if feature_doc.readiness_signal != "PASS":
            continue
        if not feature_doc.primary_issue_ref:
            continue
        if feature_doc.primary_issue_ref not in pending_primary:
            pending_primary.append(feature_doc.primary_issue_ref)
    readiness_signals = sorted(
        {
            feature_doc.readiness_signal
            for feature_doc in feature_docs
            if feature_doc.readiness_signal
        }
    )
    issues_to_autoclose_section = build_issues_to_autoclose_section(
        verified=verified,
        pending_primary=pending_primary,
        readiness_signals=readiness_signals,
    )

    issues_to_fetch = sorted(set(verified + author_asserted + referenced_issues))
    issue_details: list[IssueDetails] = []
    if gh_available:
        for ref in issues_to_fetch:
            issue_details.append(gh.issue_details(ref.lstrip("#")))

    pr_details_list: list[PullRequestDetails] = []
    if gh_available:
        for ref in referenced_prs:
            pr_details_list.append(gh.pr_details(ref.lstrip("#")))

    if context_result.merge_base and context_result.head_sha:
        name_status_text = git.diff_range(
            ["--name-status", context_result.merge_base, context_result.head_sha]
        )
        numstat_text = git.diff_range(
            ["--numstat", context_result.merge_base, context_result.head_sha]
        )
    else:
        name_status_text = git.diff_range(["--name-status"])
        numstat_text = git.diff_range(["--numstat"])

    _additions, _deletions, per_file_stats = _parse_numstat_detailed(numstat_text)
    status_map = _parse_name_status_map(name_status_text)

    scoping_changes = _scoping_doc_changes(
        git=git,
        merge_base=context_result.merge_base,
        head_sha=context_result.head_sha,
        root=resolved_root,
        name_status_text=name_status_text,
        numstat_details=per_file_stats,
    )
    material_scoping = [
        (path, reasons, excerpt)
        for path, material, reasons, excerpt in scoping_changes
        if material
    ]
    non_material_scoping = [
        (path, reasons)
        for path, material, reasons, _ in scoping_changes
        if not material
    ]

    ci_target = context_result.head_sha
    if not ci_target:
        try:
            ci_target = git.rev_parse("HEAD")
        except RuntimeError:
            ci_target = None
    ci_status, ci_jobs = (
        gh.ci_status(ci_target) if (ci_target and gh_available) else (None, [])
    )

    bucket_core: list[tuple[str, tuple[int, int]]] = []
    bucket_renames: list[tuple[str, tuple[int, int]]] = []
    bucket_docs: list[tuple[str, tuple[int, int]]] = []
    for path, status in status_map.items():
        stats = per_file_stats.get(path, (0, 0))
        if status.startswith("R"):
            bucket_renames.append((path, stats))
        elif path.endswith(".py") or path.endswith(".ps1"):
            bucket_core.append((path, stats))
        elif path.startswith("docs/") or path.startswith(".github") or "AGENTS" in path:
            bucket_docs.append((path, stats))

    scoping_summary_lines: list[str] = []
    if material_scoping:
        scoping_summary_lines.append("Scoping docs changed (material):")
        for path, reasons, excerpt in material_scoping:
            reason_text = (
                f"Reasons: {', '.join(reasons) if reasons else '(unspecified)'}"
            )
            scoping_summary_lines.append(f"- {path} ({reason_text})")
            if excerpt:
                scoping_summary_lines.append(truncate_lines(excerpt, 40))
    if non_material_scoping:
        scoping_summary_lines.append("Scoping docs changed (non-material):")
        for path, reasons in non_material_scoping[:5]:
            reason_text = (
                f"Reasons: {', '.join(reasons) if reasons else '(unspecified)'}"
            )
            scoping_summary_lines.append(f"- {path} ({reason_text})")
    if not scoping_summary_lines:
        scoping_summary_lines.append("(none)")

    issue_digests = "\n\n".join(_issue_digest(detail) for detail in issue_details)
    pr_digests = "\n\n".join(_pr_digest(detail) for detail in pr_details_list)

    feature_summary = build_feature_summary(feature_docs)
    verification_evidence_section = render_verification_evidence_section(
        resolved_root=resolved_root,
        feature_docs=feature_docs,
    )

    close_candidates = build_close_candidates_section(
        verified=verified,
        author_asserted=sorted(set(author_asserted)),
        referenced=referenced_issues,
        verified_reason=verified_reason,
        author_reason=author_reason,
    )

    gh_status_text = (
        gh_status_override or gh.status_message or "GitHub CLI authenticated."
    )
    if not gh_available and not gh_status_override:
        gh_status_text = "GitHub CLI unavailable; references unverified."
    # Render the freshness header exactly once per invocation and hand the same
    # string to both document builders, so the two documents cannot disagree on
    # the timestamp. The head SHA is already on the collected record, so no
    # additional git call is made.
    generated_section = append_generation_timestamp(context_result.head_sha)

    summary_text = build_summary_document(
        generated_section=generated_section,
        gh_status_text=gh_status_text,
        gh_available=gh_available,
        context_result=context_result,
        head=head,
        issues_to_autoclose_section=issues_to_autoclose_section,
        close_candidates=close_candidates,
        additional_context_files=additional_context_files,
        feature_summary=feature_summary,
        referenced_issues=referenced_issues,
        referenced_prs=referenced_prs,
        invalid_refs=invalid_refs,
        scoping_summary_lines=scoping_summary_lines,
        bucket_core=bucket_core,
        bucket_renames=bucket_renames,
        bucket_docs=bucket_docs,
        issue_digests=issue_digests,
        pr_digests=pr_digests,
        verification_evidence_section=verification_evidence_section,
        ci_status=ci_status,
        ci_jobs=ci_jobs,
        appendix_path=appendix_path,
    )

    appendix_text = build_appendix_document(
        generated_section=generated_section,
        context_result=context_result,
        issue_details=issue_details,
        pr_details_list=pr_details_list,
        feature_docs=feature_docs,
    )

    write_output(summary_text, summary_path, append)
    write_output(appendix_text, appendix_path, append)
    print(f"Wrote context summary to: {summary_path}")
    print(f"Wrote context appendix to: {appendix_path}")


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Collect PR context for GitHub.")
    parser.add_argument(
        "--base", dest="base", help="Base ref (default: auto-detect origin/main)"
    )
    parser.add_argument("--head", dest="head", help="Head ref (default: HEAD)")
    parser.add_argument(
        "--out",
        dest="out",
        default=SUMMARY_PATH_DEFAULT,
        help="Summary output file path",
    )
    parser.add_argument(
        "--appendix-out",
        dest="appendix_out",
        default=APPENDIX_PATH_DEFAULT,
        help="Appendix output file path",
    )
    parser.add_argument(
        "--repo-root",
        dest="repo_root",
        default=".",
        help="Repository root (defaults to current directory)",
    )
    parser.add_argument(
        "--append",
        dest="append",
        action="store_true",
        help="Append instead of overwrite",
    )
    parser.add_argument(
        "--no-untracked",
        dest="no_untracked",
        action="store_true",
        help="Exclude untracked files from status",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> None:
    args = parse_args(argv)
    out_path = Path(args.out).expanduser()
    repo_root = Path(args.repo_root).expanduser().resolve()
    collect_and_write(
        base=args.base,
        head=args.head,
        out=out_path,
        appendix_out=Path(args.appendix_out).expanduser(),
        repo_root=repo_root,
        append=bool(args.append),
        include_untracked=not bool(args.no_untracked),
    )


if __name__ == "__main__":
    main()
