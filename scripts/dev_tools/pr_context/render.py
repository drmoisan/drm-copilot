"""Rendering and extraction helpers for PR context collection."""

from __future__ import annotations

import re
import subprocess
from typing import TYPE_CHECKING, Protocol

from .models import PRContextResult, normalize_reference, section
from .render_feature_excerpts import (
    build_excerpt_text,
    completed_plan_tasks,
    directory_exists,
    extract_features_from_paths,
    extract_plan_sections,
    extract_spec_parts,
    extract_story_parts,
    gather_feature_excerpts,
    parse_section,
    read_text_file,
)
from .render_pr_helpers import (
    build_close_candidates_section,
    convert_numstat,
    extension_summary,
    extract_changed_paths,
    extract_issue_references,
    extract_merge_pr_numbers,
    format_diff_path,
    format_issue_details,
    format_pr_details,
    select_default_base,
    summarize_conventional_commits,
)

if TYPE_CHECKING:
    from collections.abc import Iterable
    from pathlib import Path

    from .git import GitClient
    from .models import PullRequestDetails

__all__ = [
    "build_close_candidates_section",
    "build_excerpt_text",
    "build_pr_context",
    "completed_plan_tasks",
    "convert_numstat",
    "directory_exists",
    "extension_summary",
    "extract_changed_paths",
    "extract_features_from_paths",
    "extract_issue_references",
    "extract_merge_pr_numbers",
    "extract_plan_sections",
    "extract_spec_parts",
    "extract_story_parts",
    "format_diff_path",
    "format_issue_details",
    "format_pr_details",
    "gather_feature_excerpts",
    "parse_section",
    "read_text_file",
    "resolve_feature_dir",
    "select_default_base",
    "summarize_conventional_commits",
]


class GhLike(Protocol):
    def ensure_available(self) -> None: ...

    def classify_entity(self, number: str) -> str | None: ...

    @property
    def available(self) -> bool: ...


def resolve_feature_dir(base_dir: Path, feature: str) -> Path | None:
    """Resolve feature directory by exact, strong-pattern, then weak match."""
    direct = base_dir / feature
    if directory_exists(direct):
        return direct

    if not directory_exists(base_dir):
        return None

    pattern = re.compile(rf"(?:^|[-_]){re.escape(feature)}(?:[-_]|$)")
    strong_matches: list[Path] = []
    weak_matches: list[Path] = []

    for candidate in sorted(base_dir.iterdir()):
        if not candidate.is_dir():
            continue
        name = candidate.name
        if pattern.search(name):
            strong_matches.append(candidate)
        elif feature in name:
            weak_matches.append(candidate)

    if strong_matches:
        return strong_matches[0]
    if weak_matches:
        return weak_matches[0]
    return None


def build_pr_context(
    *,
    git: GitClient,
    gh: GhLike,
    base_ref: str | None,
    head_ref: str | None,
    include_untracked: bool,
    feature_issue_refs: Iterable[str] | None = None,
    current_pr: PullRequestDetails | None = None,
    gh_available: bool | None = None,
) -> PRContextResult:
    """Build the full PR context payload from git/gh state and references."""
    gh_available = (
        gh.available
        if gh_available is None and hasattr(gh, "available")
        else gh_available
    )
    gh_available = True if gh_available is None else gh_available
    if gh_available:
        gh.ensure_available()
    branch_name = git.branch_name()
    upstream = git.upstream() or "(none)"

    remotes = git.remote_verbose()
    status_short = git.status_short()
    untracked = git.untracked() if include_untracked else ""
    untracked_display = untracked if untracked.strip() else "(none)"

    feature_issue_list = list(feature_issue_refs or [])
    referenced_issues: list[str] = []
    referenced_prs: list[str] = []
    verified_closing = (
        current_pr.closing_issues if (current_pr and gh_available) else []
    )
    invalid_references: list[str] = []

    resolved_base: str | None = None
    base_sha: str | None = None
    head_sha: str | None = None
    head_ref_resolved: str | None = head_ref or branch_name
    merge_base: str | None = None
    rev_range: str | None = None

    pr_block = ""
    base_warning: str | None = None
    try:
        requested_base = base_ref
        resolved_base = base_ref or select_default_base(git)
        if not resolved_base:
            raise RuntimeError("Failed to resolve base ref (tried common defaults)")

        if not resolved_base.startswith("origin/"):
            remote_candidate = f"origin/{resolved_base}"
            remote_probe = git.run(
                ["rev-parse", "--verify", "--quiet", remote_candidate],
                allow_error=True,
            )
            if remote_probe.code == 0 and remote_probe.stdout.strip():
                resolved_base = remote_candidate
            elif requested_base:
                base_warning = (
                    "WARNING: Requested base is local and may be stale; prefer "
                    f"origin/{requested_base}"
                )

        base_sha = git.rev_parse(resolved_base)
        head_ref_resolved = head_ref or branch_name
        head_sha = git.rev_parse(head_ref_resolved or "HEAD")
        merge_base = git.merge_base(base_sha, head_sha)
        rev_range = f"{merge_base}..{head_sha}"

        oneline = git.log("--pretty=format:%h %ad %an %s", rev_range)
        subjects = git.log("--pretty=%s", rev_range)
        authors = git.log("--format=%an <%ae>", rev_range)
        authors_list = sorted(
            {line.strip() for line in authors.splitlines() if line.strip()}
        )

        name_status = git.diff_range(["--name-status", merge_base, head_sha])
        numstat = git.diff_range(["--numstat", merge_base, head_sha])
        shortstat = git.diff_range(["--shortstat", merge_base, head_sha])
        stat = git.diff_range(["--stat", merge_base, head_sha])

        additions, deletions, files = convert_numstat(numstat)
        ext_summary = extension_summary(files)
        merge_prs = extract_merge_pr_numbers(oneline.splitlines())

        issue_candidates = [
            ref
            for ref in extract_issue_references(oneline + "\n" + subjects)
            if ref not in merge_prs
        ]
        issues: list[str] = []
        prs: list[str] = []
        for ref in issue_candidates:
            number = normalize_reference(ref)
            if gh_available:
                entity = gh.classify_entity(number)
            else:
                entity = None
            formatted_ref = ref if ref.startswith("#") else f"#{ref}"
            if entity == "issue":
                issues.append(formatted_ref)
            elif entity == "pull":
                prs.append(formatted_ref)
            else:
                if gh_available:
                    invalid_references.append(formatted_ref)
                else:
                    issues.append(formatted_ref)
        referenced_issues = sorted(set(issues))
        referenced_prs = sorted(set(prs + merge_prs))

        issues_display = ", ".join(sorted(set(referenced_issues + feature_issue_list)))
        if not issues_display:
            issues_display = "(none)"
        prs_display = ", ".join(referenced_prs) if referenced_prs else "(none)"

        oneline_display = oneline if oneline.strip() else "(none)"
        authors_display = "\n".join(authors_list) if authors_list else "(none)"
        name_status_display = name_status if name_status.strip() else "(none)"
        short_display = shortstat if shortstat.strip() else "(none)"
        ext_display = ext_summary if ext_summary else "(none)"
        stat_display = stat if stat.strip() else "(none)"

        block_lines = [
            section("PR Comparison"),
            f"Base ref (requested): {requested_base or '(default)'}",
            f"Base ref (resolved): {resolved_base} @ {base_sha}",
            f"Head ref (resolved): {head_ref_resolved} @ {head_sha}",
            f"Merge-base: {merge_base}",
        ]
        if base_warning:
            block_lines.append(f"Base warning: {base_warning}")
        block_lines.extend(
            [
                f"Range: {rev_range}\n",
                section("Commits in range"),
                oneline_display,
                "",
                section("Conventional commit type summary"),
                summarize_conventional_commits(subjects),
                "",
                section("Authors"),
                authors_display,
                "",
                section("Changed files (name-status)"),
                name_status_display,
                "",
                section("Diff shortstat"),
                short_display,
                "",
                section("Additions/Deletions totals (from numstat)"),
                f"Additions: {additions}\nDeletions: {deletions}\n",
                section("Files by extension"),
                ext_display,
                "",
                section("Referenced issues (detected)"),
                issues_display,
                "",
                section("PRs in range"),
                prs_display,
                "",
                section("Diff stat"),
                stat_display,
            ]
        )
        pr_block = "\n".join(block_lines)
    except (subprocess.CalledProcessError, RuntimeError, ValueError, OSError) as exc:
        pr_block = section("PR Comparison") + f"(FAILED to compute PR context: {exc})\n"
        referenced_issues = []
        referenced_prs = []
        verified_closing = []
        invalid_references = []
        resolved_base = None
        base_sha = None
        head_sha = None
        head_ref_resolved = head_ref or branch_name
        merge_base = None
        rev_range = None

    intent = "\n".join(
        [
            section("PR Intent (edit before generating PR body)"),
            "Primary outcome:",
            "Impact (user/developer):",
            "Risks:",
            "Author-asserted autoclose issues:",
        ]
    )

    combined_text = "\n".join(
        [
            intent,
            section("Repository remotes"),
            remotes,
            "",
            section("Current branch"),
            branch_name,
            "",
            section("Upstream"),
            upstream,
            "",
            section("Status (short)"),
            status_short,
            "",
            section("Untracked files"),
            untracked_display,
            "",
            section("Working tree diff (staged)"),
            git.diff_name_status(staged=True),
            git.diff_patch(staged=True),
            "",
            section("Working tree diff (unstaged)"),
            git.diff_name_status(staged=False),
            git.diff_patch(staged=False),
            pr_block,
        ]
    )

    return PRContextResult(
        text=combined_text,
        referenced_issues=referenced_issues,
        referenced_prs=referenced_prs,
        verified_closing=sorted(set(verified_closing)),
        invalid_references=sorted(set(invalid_references)),
        base_ref=base_ref,
        resolved_base=resolved_base,
        base_sha=base_sha,
        head_ref=head_ref_resolved,
        head_sha=head_sha,
        merge_base=merge_base,
        rev_range=rev_range,
        gh_available=gh_available,
    )
