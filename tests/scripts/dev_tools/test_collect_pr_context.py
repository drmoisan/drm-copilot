from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from collections.abc import Sequence

from scripts.dev_tools.pr_context.collector import (
    CommandResult,
    GitClient,
    IssueDetails,
    PullRequestDetails,
    build_close_candidates_section,
    build_pr_context,
    convert_numstat,
    extension_summary,
    extract_issue_references,
    extract_merge_pr_numbers,
    find_user_story_link,
    format_diff_path,
    gather_feature_excerpts,
    select_default_base,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    issue_appendix as _issue_appendix,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    issue_digest as _issue_digest,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    last_with_truncation as _last_with_truncation,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    parse_name_status_map as _parse_name_status_map,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    parse_numstat_detailed as _parse_numstat_detailed,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    scoping_doc_changes as _scoping_doc_changes,
)


@pytest.fixture
def mem_path(tmp_path: Path) -> Path:
    """Alias fixture for cosmetic tmp_path->mem_path test parameter rename."""
    return tmp_path


class FakeRunner:
    def __init__(self, responses: dict[tuple[str, ...], CommandResult]) -> None:
        self.responses = responses

    def run(
        self,
        args: Sequence[str],
        *,
        cwd: Path | None = None,
        allow_error: bool = False,
    ) -> CommandResult:
        key = tuple(args)
        return self.responses.get(key, CommandResult(stdout="", stderr="", code=1))


class FakeGit(GitClient):
    def __init__(self) -> None:
        super().__init__(FakeRunner({}), Path("."))
        self.called = []

    def branch_name(self) -> str:
        return "feature/test"

    def upstream(self) -> str:
        return "origin/feature/test"

    def remote_verbose(self) -> str:
        return "origin https://example/repo (fetch)"

    def status_short(self) -> str:
        return "## feature/test...origin/feature/test"

    def untracked(self) -> str:
        return "docs/features/active/fix-all-script/spec.md"

    def diff_name_status(self, *, staged: bool) -> str:
        marker = "A" if staged else "M"
        return f"{marker}\tdocs/features/active/fix-all-script/spec.md"

    def diff_patch(self, *, staged: bool) -> str:
        return "(diff omitted)"

    def rev_parse(self, ref: str) -> str:
        return "basehash" if ref == "main" else "headhash"

    def merge_base(self, base: str, head: str) -> str:
        return base

    def log(self, fmt: str, rev_range: str) -> str:
        if fmt.startswith("--pretty=format:"):
            return "\n".join(
                [
                    "a1 2025-01-01 alice Merge pull request #53",
                    "a2 2025-01-02 bob fix(scope): closes #44",
                ]
            )
        if fmt == "--pretty=%s":
            return "Merge pull request #53\nfix(scope): closes #44"
        if fmt == "--format=%an <%ae>":
            return "alice <a@example.com>\nbob <b@example.com>"
        return ""

    def diff_range(self, args: Sequence[str]) -> str:
        if "--name-status" in args:
            return "M\tdocs/features/active/fix-all-script/spec.md"
        if "--numstat" in args:
            return "4\t2\tdocs/features/active/fix-all-script/spec.md"
        if "--shortstat" in args:
            return " 1 files changed, 4 insertions(+), 2 deletions(-)"
        if "--stat" in args:
            return " spec.md | 6 +-"
        return ""

    def run(self, args: Sequence[str], *, allow_error: bool = False) -> CommandResult:
        return CommandResult(stdout="resolved", stderr="", code=0)


class FakeGh:
    def __init__(self) -> None:
        self.available = True

    def ensure_available(self) -> None:
        return None

    def classify_entity(self, number: str) -> str | None:
        if number == "44":
            return "issue"
        if number == "53":
            return "pull"
        return None


def test_format_diff_path_handles_brace_and_simple_renames():
    assert format_diff_path("dir/{old => new}/file.txt") == "dir/new/file.txt"
    assert format_diff_path("old.txt => new.txt") == "new.txt"
    assert format_diff_path('"quoted.txt"') == "quoted.txt"


def test_convert_numstat_sums_and_collects_files():
    adds, dels, files = convert_numstat("4\t2\tfile1.py\n-\t-\timage.png")
    assert adds == 4
    assert dels == 2
    assert files == ["file1.py", "image.png"]


def test_extension_summary_sorts_and_counts():
    summary = extension_summary(["a.py", "b.py", "Makefile"])
    lines = summary.splitlines()
    assert "py" in lines[1]
    assert "(noext)" in summary


def test_extract_issue_references_filters_and_deduplicates():
    text = "Fixes #12 and relates to ABC-99 plus #12 again"
    refs = extract_issue_references(text)
    assert refs == ["#12", "ABC-99"]


def test_last_with_truncation_limits_list():
    items, truncated = _last_with_truncation(["a", "b", "c", "d"], 2)
    assert items == ["c", "d"]
    assert truncated is True


def test_parse_name_status_map_collects_statuses():
    mapping = _parse_name_status_map("A\tfirst.txt\nM\tsecond.txt")
    assert mapping == {"first.txt": "A", "second.txt": "M"}


def test_extract_merge_pr_numbers_ignores_non_merge_lines():
    subjects = [
        "Merge pull request #51 from branch",
        "fix: close #5",
        "Merge pull request #51 from branch",  # duplicate should dedupe
    ]
    numbers = extract_merge_pr_numbers(subjects)
    assert numbers == ["#51"]


def test_select_default_base_tries_candidates_in_order():
    responses = {
        ("git", "rev-parse", "--verify", "--quiet", "origin/main"): CommandResult(
            "", "", 1
        ),
        ("git", "rev-parse", "--verify", "--quiet", "main"): CommandResult(
            "main", "", 0
        ),
    }
    runner = FakeRunner(responses)
    git = GitClient(runner, Path("."))
    assert select_default_base(git) == "main"


def test_build_pr_context_classifies_prs_and_issues_and_embeds_closing():
    git = FakeGit()
    gh = FakeGh()
    current_pr = PullRequestDetails(
        number="#99",
        state="open",
        author="alice",
        base_ref="main",
        head_ref="feature/test",
        created_at="2025-01-01",
        updated_at="2025-01-02",
        merged_at=None,
        labels=[],
        assignees=[],
        title="current",
        body="closes #44",
        closing_issues=["#50"],
        files_changed=[],
    )
    context = build_pr_context(
        git=git,
        gh=gh,
        base_ref="main",
        head_ref="feature/test",
        include_untracked=True,
        current_pr=current_pr,
    )
    assert "PRs in range" in context.text
    assert "#53" in context.text
    assert "Referenced issues" in context.text
    assert "#44" in context.text
    assert "Author-asserted autoclose issues" in context.text
    assert context.verified_closing == ["#50"]
    assert context.invalid_references == []


def test_build_pr_context_excludes_merge_pr_numbers_from_issue_refs():
    git = FakeGit()
    gh = FakeGh()
    context = build_pr_context(
        git=git,
        gh=gh,
        base_ref="main",
        head_ref="feature/test",
        include_untracked=True,
        current_pr=None,
    )

    assert "#44" in context.referenced_issues
    assert "#53" not in context.referenced_issues
    assert "#53" in context.referenced_prs


def test_gather_feature_excerpts_reads_active_docs(mem_path: Path) -> None:
    root = mem_path
    feature = "2025-12-18-docs-v3-upgrade"
    feature_dir = root / "docs" / "features" / "active" / feature
    feature_dir.mkdir(parents=True)
    (root / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

    spec_path = feature_dir / "spec.md"
    plan_path = feature_dir / "plan.md"
    story_path = feature_dir / "user-story.md"

    spec_path.write_text(
        "## Context\n"
        "Working on #77 to modernize docs.\n"
        "\n"
        "## Acceptance Criteria\n"
        "- Documentation matches production behavior.\n",
        encoding="utf-8",
    )
    plan_path.write_text(
        "## Tasks\n"
        "- [x] Deliver ABC-123 migration steps.\n"
        "- [ ] Follow-up polish.\n"
        "\n"
        "## Verification\n"
        "Plan verification details captured.\n",
        encoding="utf-8",
    )
    story_path.write_text(
        "## Story Statement\n"
        "- As an operator, I need docs to mirror reality.\n"
        "\n"
        "## Problem / Why\n"
        "Old flows confuse teams.\n",
        encoding="utf-8",
    )

    paths = [
        f"docs/features/active/{feature}/spec.md",
        f"docs/features/active/{feature}/plan.md",
    ]
    excerpts = gather_feature_excerpts(root, paths)
    assert len(excerpts) == 1
    excerpt = excerpts[0]
    joined = excerpt.excerpt
    for expected in [
        feature,
        "Spec excerpts",
        "Plan completed tasks",
        "Plan verification notes",
        "Story Statement",
        "Problem / Why",
    ]:
        assert expected in joined

    assert excerpt.issue_refs == ["#77", "ABC-123"]
    assert set(excerpt.context_files) == {
        str(spec_path.relative_to(root)),
        str(plan_path.relative_to(root)),
        str(story_path.relative_to(root)),
    }


def test_collector_includes_canonical_evidence_paths_in_additional_context_files(
    mem_path: Path,
) -> None:
    """Assert canonical feature evidence paths are enumerated as additional context."""
    root = mem_path
    feature = "2026-02-22-pr-context-verification-contract-gap-46"
    feature_dir = root / "docs" / "features" / "active" / feature
    feature_dir.mkdir(parents=True)
    (root / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

    # Build a minimal active-feature doc set so excerpt discovery can run.
    (feature_dir / "spec.md").write_text("## Context\nContext", encoding="utf-8")
    (feature_dir / "plan.md").write_text("## Tasks\n- [x] done", encoding="utf-8")
    (feature_dir / "user-story.md").write_text(
        "## Story Statement\n- Story", encoding="utf-8"
    )

    # Add canonical evidence artifact that should be included in context files.
    evidence_file = (
        feature_dir / "evidence" / "qa-gates" / "black-final.2026-02-22T21-00.md"
    )
    evidence_file.parent.mkdir(parents=True)
    evidence_file.write_text(
        "Timestamp: 2026-02-22T21-00\n"
        "Command: poetry run black .\n"
        "EXIT_CODE: 0\n",
        encoding="utf-8",
    )

    changed_paths = [f"docs/features/active/{feature}/spec.md"]
    excerpts = gather_feature_excerpts(root, changed_paths)

    assert len(excerpts) == 1
    assert any(
        "/evidence/" in path.replace("\\", "/") for path in excerpts[0].context_files
    )


def test_find_user_story_link_extracts_blob_path():
    link = find_user_story_link(
        "See [story](https://github.com/org/repo/blob/main/docs/story/user-story.md)"
    )
    assert link == "docs/story/user-story.md"


def test_build_close_candidates_section_renders_lists():
    section_text = build_close_candidates_section(
        verified=["#1"],
        author_asserted=["#2"],
        referenced=["#3", "#4"],
        verified_reason="None (no PR exists yet for this branch)",
        author_reason="None (author asserted)",
    )
    assert "Close candidates" in section_text
    assert "#1" in section_text and "#2" in section_text and "#3" in section_text


def test_build_close_candidates_section_promotes_referenced_issues_to_auto_close():
    section_text = build_close_candidates_section(
        verified=[],
        author_asserted=[],
        referenced=["#3"],
        verified_reason="None (no PR exists yet for this branch)",
        author_reason="None (author has not asserted autoclose issues)",
    )

    lines = section_text.splitlines()
    author_index = lines.index("Auto-close issues (author asserted):")
    assert "- #3" in lines[author_index + 1]


def test_issue_digest_truncates_comments():
    issue = IssueDetails(
        number="#10",
        title="Test",
        state="open",
        labels=["bug"],
        assignees=["alice"],
        author="bob",
        created_at="2024-01-01",
        updated_at="2024-01-02",
        body="## Why\n- reason one\n- reason two\n",
        comments=[f"comment {idx}" for idx in range(6)],
        user_story_path=None,
        user_story_content=None,
    )
    digest = _issue_digest(issue)
    assert "reason one" in digest
    assert "TRUNCATED: last 3 comments shown" in digest


def test_issue_appendix_truncates_body_and_comments():
    issue = IssueDetails(
        number="#11",
        title="Another",
        state="open",
        labels=[],
        assignees=[],
        author="carol",
        created_at="2024-02-01",
        updated_at="2024-02-02",
        body="\n".join(f"line {i}" for i in range(130)),
        comments=[f"note {i}" for i in range(15)],
        user_story_path=None,
        user_story_content=None,
    )
    appendix = _issue_appendix(issue)
    assert "TRUNCATED: first" in appendix or "TRUNCATED" in appendix
    assert "TRUNCATED: last 10 comments shown" in appendix


def test_parse_numstat_detailed_collects_per_file():
    adds, dels, mapping = _parse_numstat_detailed("5\t1\ta.py\n3\t2\tdocs/readme.md")
    assert adds == 8 and dels == 3
    assert mapping["a.py"] == (5, 1)
    assert mapping["docs/readme.md"] == (3, 2)


class FakeGitScoping(GitClient):
    def __init__(self, diff_text: str) -> None:
        super().__init__(FakeRunner({}), Path("."))
        self._diff_text = diff_text

    def diff_range(self, args: Sequence[str]) -> str:
        return self._diff_text


def test_scoping_doc_changes_flags_material_headings():
    root = Path(__file__).resolve().parents[3]
    path = "docs/features/active/fix-all-script/spec.md"
    diff_text = f"+++ b/{path}\n+## Acceptance Criteria\n+New criteria"
    git = FakeGitScoping(diff_text)
    changes = _scoping_doc_changes(
        git=git,
        merge_base="base",
        head_sha="head",
        root=root,
        name_status_text=f"M\t{path}",
        numstat_details={path: (10, 2)},
    )
    material = [entry for entry in changes if entry[1]]
    assert material


def test_scoping_doc_changes_marks_non_material_link_only():
    root = Path(__file__).resolve().parents[3]
    path = "docs/features/active/fix-all-script/spec.md"
    diff_text = f"+++ b/{path}\n+http://example.com\n+[link](https://example.com)"
    git = FakeGitScoping(diff_text)
    changes = _scoping_doc_changes(
        git=git,
        merge_base="base",
        head_sha="head",
        root=root,
        name_status_text=f"M\t{path}",
        numstat_details={path: (2, 0)},
    )
    assert changes
    assert changes[0][1] is False
