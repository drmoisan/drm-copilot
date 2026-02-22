"""PR context rendering utility helpers extracted from render module."""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

from .models import (
    CONVENTIONAL_TYPES,
    IssueDetails,
    PullRequestDetails,
    format_list,
    section,
    truncate,
)

if TYPE_CHECKING:
    from collections.abc import Iterable

    from .git import GitClient


def select_default_base(git: GitClient) -> str | None:
    """Select the first existing base ref from standard default candidates."""
    candidates = [
        "origin/main",
        "origin/master",
        "main",
        "master",
        "origin/develop",
        "develop",
    ]
    for ref in candidates:
        result = git.run(["rev-parse", "--verify", "--quiet", ref], allow_error=True)
        if result.code == 0 and result.stdout.strip():
            return ref
    return None


def format_diff_path(path_text: str | None) -> str:
    """Normalize git diff path output, including rename syntax variants."""
    if path_text is None:
        return ""
    if path_text.strip() == "":
        return path_text

    trimmed = path_text.strip().strip('"')
    trimmed = re.sub(r"\{[^{}]*\s=>\s([^{}]*)\}", r"\1", trimmed)

    arrow_match = re.match(r"^\s*(.+?)\s=>\s(.+?)\s*$", trimmed)
    if arrow_match:
        return arrow_match.group(2)
    return trimmed


def convert_numstat(numstat_text: str) -> tuple[int, int, list[str]]:
    """Convert git numstat output into totals and raw path list."""
    adds = 0
    dels = 0
    files: list[str] = []

    for raw_line in numstat_text.splitlines():
        if not raw_line.strip():
            continue

        parts = raw_line.split("\t")
        if len(parts) < 3:
            continue

        add_part, del_part, file_part = parts[0], parts[1], parts[2]
        if add_part.isdigit():
            adds += int(add_part)
        if del_part.isdigit():
            dels += int(del_part)
        files.append(file_part)

    return adds, dels, files


def extension_summary(files: Iterable[str]) -> str:
    """Summarize changed files by extension."""
    counts: dict[str, int] = {}
    for raw in files:
        name = format_diff_path(raw)
        ext = "(unknown)"
        try:
            suffix = Path(name).suffix
            ext = suffix if suffix else "(noext)"
        except ValueError:
            fallback = re.search(r"\.([A-Za-z0-9_]+)$", name)
            ext = f".{fallback.group(1)}" if fallback else "(unknown)"

        counts[ext] = counts.get(ext, 0) + 1

    lines = [f"{counts[k]:8d}  {k}" for k in sorted(counts)]
    return "\n".join(lines)


def extract_issue_references(text: str) -> list[str]:
    """Extract issue tokens like #123 and ABC-123 in encounter order."""
    if not text:
        return []
    matches = re.findall(r"(?<!\w)#\d+|\b[A-Z][A-Z0-9]+-\d+\b", text)
    seen: set[str] = set()
    ordered: list[str] = []
    for item in matches:
        if item not in seen:
            seen.add(item)
            ordered.append(item)
    return ordered


def extract_merge_pr_numbers(subjects: Iterable[str]) -> list[str]:
    """Extract merged PR numbers from commit subject lines."""
    numbers: set[str] = set()
    pattern = re.compile(r"Merge pull request #(\d+)", re.IGNORECASE)
    for subj in subjects:
        match = pattern.search(subj)
        if match:
            numbers.add(f"#{match.group(1)}")
    return sorted(numbers)


def summarize_conventional_commits(subjects: str) -> str:
    """Count conventional commit types in subject lines."""
    counts = {key: 0 for key in CONVENTIONAL_TYPES}
    counts["other"] = 0

    for line in subjects.splitlines():
        line = line.strip()
        if not line:
            continue
        match = re.match(
            r"(feat|fix|refactor|perf|docs|test|chore|build|ci|style)(\(|!|:)",
            line,
        )
        label = match.group(1) if match else "other"
        counts[label] += 1

    non_zero = [(k, v) for k, v in counts.items() if v > 0]
    if not non_zero:
        return "(no recognizable conventional commit types)"
    return "\n".join(f"{name:<9} : {value}" for name, value in non_zero)


def format_issue_details(issue: IssueDetails) -> str:
    """Render structured issue details for PR context appendix output."""
    comments_text = format_list(issue.comments, "(no comments)")
    lines = [
        section(f"Issue {issue.number}: {issue.title}"),
        f"State: {issue.state}",
        f"Author: {issue.author}",
        f"Labels: {', '.join(issue.labels) if issue.labels else '(none)'}",
        f"Assignees: {', '.join(issue.assignees) if issue.assignees else '(none)'}",
        f"Created: {issue.created_at}",
        f"Updated: {issue.updated_at}",
        "",
        truncate(issue.body, 1200),
        "",
        "Comments:",
        comments_text,
    ]
    if issue.user_story_content:
        lines.extend(
            [
                "",
                f"User story ({issue.user_story_path or 'user-story.md'}):",
                truncate(issue.user_story_content, 1200),
            ]
        )
    return "\n".join(lines)


def format_pr_details(pr: PullRequestDetails) -> str:
    """Render structured pull request details for PR context appendix output."""
    return "\n".join(
        [
            section(f"Pull Request {pr.number}: {pr.title}"),
            f"State: {pr.state}",
            f"Author: {pr.author}",
            f"Base: {pr.base_ref}",
            f"Head: {pr.head_ref}",
            f"Created: {pr.created_at}",
            f"Updated: {pr.updated_at}",
            f"Merged: {pr.merged_at or '(not merged)'}",
            f"Labels: {', '.join(pr.labels) if pr.labels else '(none)'}",
            f"Assignees: {', '.join(pr.assignees) if pr.assignees else '(none)'}",
            truncate(pr.body, 1200),
            "",
            "Auto-close issues (from this PR):",
            format_list(pr.closing_issues, "(none)"),
            "",
            "Files (first 15):",
            format_list(pr.files_changed[:15], "(none)"),
        ]
    )


def build_close_candidates_section(
    *,
    verified: list[str],
    author_asserted: list[str],
    referenced: list[str],
    verified_reason: str,
    author_reason: str,
) -> str:
    """Render close-candidate section grouped by verification source."""
    all_auto_close = set(verified + author_asserted + referenced)
    author_auto_close = sorted(all_auto_close)
    referenced_only = sorted(set(referenced) - all_auto_close)

    return "\n".join(
        [
            section("Close candidates"),
            "Auto-close issues (verified from GitHub PR metadata):",
            format_list(verified, verified_reason),
            "",
            "Auto-close issues (author asserted):",
            format_list(author_auto_close, author_reason),
            "",
            "Referenced issues (detected):",
            format_list(referenced_only, "(none)"),
        ]
    )


def extract_changed_paths(context_text: str) -> list[str]:
    """Extract changed file paths from the 'Changed files' section text."""
    paths: list[str] = []
    capture = False
    for line in context_text.splitlines():
        if line.startswith("===== Changed files"):
            capture = True
            continue
        if capture:
            if line.startswith("====="):
                break
            if line.strip() and "\t" in line:
                path_part = line.split("\t")[-1]
                paths.append(format_diff_path(path_part.strip()))
            elif line.strip():
                paths.append(format_diff_path(line.strip()))
    return paths
