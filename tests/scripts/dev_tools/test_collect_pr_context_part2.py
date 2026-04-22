from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Sequence

    import pytest

from scripts.dev_tools.pr_context.collector import (
    CommandResult,
    GitClient,
    IssueDetails,
    PullRequestDetails,
    collect_and_write,
    main,
    parse_args,
    write_output,
)
from scripts.dev_tools.pr_context.models import FeatureDocExcerpt, PRContextResult
from scripts.dev_tools.pr_context.summary_helpers import (
    extract_digest_bullets as _extract_digest_bullets,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    is_scoping_doc as _is_scoping_doc,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    issue_appendix as _issue_appendix,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    parse_numstat_detailed as _parse_numstat_detailed,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    pr_appendix as _pr_appendix,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    pr_digest as _pr_digest,
)


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


def test_pr_digest_and_appendix_cover_headings_and_files():
    pr = PullRequestDetails(
        number="#21",
        title="Improve docs",
        state="open",
        author="lee",
        base_ref="main",
        head_ref="feature/docs",
        created_at="2024-01-01",
        updated_at="2024-01-02",
        merged_at=None,
        labels=["docs"],
        assignees=["lee"],
        body="## Why\n- clarify usage\n",
        closing_issues=["#8"],
        files_changed=["a.md", "b.md", "c.md", "d.md"],
    )
    digest = _pr_digest(pr)
    appendix = _pr_appendix(pr)
    assert "Why: clarify usage" in digest
    assert "Files (first 25)" in appendix
    assert "closes" not in appendix.lower()


def test_issue_appendix_includes_user_story_block():
    issue = IssueDetails(
        number="#12",
        title="Story reference",
        state="open",
        labels=[],
        assignees=[],
        author="alex",
        created_at="2024-03-01",
        updated_at="2024-03-02",
        body="Context\n" + "\n".join(f"line {i}" for i in range(10)),
        comments=["note"],
        user_story_path="docs/story/user-story.md",
        user_story_content="Story content line 1\nline 2",
    )
    appendix = _issue_appendix(issue)
    assert "User story (docs/story/user-story.md)" in appendix
    assert "Story content line" in appendix


def test_parse_numstat_detailed_handles_non_numeric_entries():
    adds, dels, mapping = _parse_numstat_detailed(
        "-\t-\tfirst.txt\nnotnum\t3\tsecond.txt\n"
    )
    assert adds == 0
    assert dels == 3
    assert mapping["first.txt"] == (0, 0)
    assert mapping["second.txt"] == (0, 3)


def test_is_scoping_doc_identifies_feature_files():
    assert _is_scoping_doc("docs/features/active/feat/spec.md")
    assert _is_scoping_doc("docs/features/active/feat/plan.md")
    assert _is_scoping_doc("docs/features/active/feat/bug-remediation-plan.md")
    assert _is_scoping_doc("docs/features/active/feat/user-story.md")
    assert not _is_scoping_doc("docs/features/ideas/idea.md")
    assert not _is_scoping_doc("src/main.py")


def test_collect_and_write_uses_feature_refs_and_scoping(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    captured: list[tuple[Path, str]] = []

    def fake_write_output(text: str, out_path: Path, append: bool) -> None:
        captured.append((out_path, text))

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.write_output", fake_write_output
    )

    class FakeGit:
        def __init__(self, *args: object, **kwargs: object) -> None:
            self._root = Path(__file__).resolve().parents[3]

        def resolve_root(self) -> Path:
            return self._root

        def branch_name(self) -> str:
            return "feature/ABC-10"

        def diff_range(self, args: Sequence[str]) -> str:
            path = "docs/features/active/fix-all-script/spec.md"
            if "--name-status" in args:
                return f"M\t{path}"
            if "--numstat" in args:
                return f"20\t0\t{path}"
            if "--unified=0" in args:
                return f"+++ b/{path}\n+## Acceptance Criteria\n+New criteria"
            return ""

        def rev_parse(self, ref: str) -> str:
            return f"{ref}-sha"

    class FakeGh:
        status_message = "ok"

        def __init__(self, *args: object, **kwargs: object) -> None:
            return None

        def ensure_available(self) -> None:
            return None

        def current_pr(self) -> PullRequestDetails | None:
            return None

        def classify_entity(self, number: str) -> str | None:
            return "issue" if number in {"1", "ABC-10"} else "pull"

        def issue_details(self, number: str) -> IssueDetails:
            return IssueDetails(
                number=f"#{number}",
                title="Issue",
                state="open",
                labels=[],
                assignees=[],
                author="alex",
                created_at="2024-01-01",
                updated_at="2024-01-02",
                body="Body",
                comments=[],
            )

        def pr_details(self, number: str) -> PullRequestDetails:
            return PullRequestDetails(
                number=f"#{number}",
                title="PR",
                state="open",
                author="alex",
                base_ref="main",
                head_ref="feature",
                created_at="2024-01-01",
                updated_at="2024-01-02",
                merged_at=None,
                labels=[],
                assignees=[],
                body="PR body",
                closing_issues=[],
                files_changed=["file.py"],
            )

        def ci_status(self, head_sha: str) -> tuple[str | None, list[str]]:
            return "success", []

    feature_calls: list[list[str]] = []

    def fake_build_pr_context(
        *,
        git: GitClient,
        gh: FakeGh,
        base_ref: str | None,
        head_ref: str | None,
        include_untracked: bool,
        feature_issue_refs: Sequence[str] | None = None,
        current_pr: PullRequestDetails | None = None,
        gh_available: bool | None = None,
    ) -> PRContextResult:
        feature_calls.append(list(feature_issue_refs or []))
        context_text = "\n".join(
            [
                "===== Changed files (name-status) =====",
                "M\tdocs/features/active/fix-all-script/spec.md",
                "===== Diff shortstat =====",
            ]
        )
        return PRContextResult(
            text=context_text,
            referenced_issues=["#1"],
            referenced_prs=["#2"],
            verified_closing=["#1"],
            invalid_references=[],
            base_ref=base_ref,
            resolved_base="origin/main",
            base_sha="base-sha",
            head_ref=head_ref or "feature",
            head_sha="head-sha",
            merge_base="base-sha",
            rev_range="base-sha..head-sha",
            gh_available=True,
        )

    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GitClient", FakeGit)
    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GhClient", FakeGh)
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.build_pr_context",
        fake_build_pr_context,
    )

    def fake_gather_feature_excerpts(
        root: Path, paths: Sequence[str]
    ) -> list[FeatureDocExcerpt]:
        return [
            FeatureDocExcerpt(
                feature="fix-all-script",
                excerpt="Excerpt",
                issue_refs=["#7"],
                context_files=["docs/features/active/fix-all-script/spec.md"],
            )
        ]

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.gather_feature_excerpts",
        fake_gather_feature_excerpts,
    )

    collect_and_write(
        base="main",
        head="feature",
        out=mem_fs_path / "summary.txt",
        appendix_out=mem_fs_path / "appendix.txt",
        repo_root=mem_fs_path,
        append=False,
        include_untracked=False,
    )

    assert feature_calls[0] == []
    assert feature_calls[1] == ["#7"]
    summary_text = next(text for path, text in captured if path.name == "summary.txt")
    appendix_text = next(text for path, text in captured if path.name == "appendix.txt")
    assert "Scoping docs changed" in summary_text
    assert "fix-all-script" in appendix_text


def test_extract_digest_bullets_truncates_and_skips_blank_lines() -> None:
    body = "## Why\n- first\n\n- second\n- third"
    bullets = _extract_digest_bullets(body, headings=["Why"], limit=2)
    assert bullets == ["Why: first", "Why: second"]


def test_parse_numstat_detailed_skips_invalid_rows() -> None:
    adds, dels, mapping = _parse_numstat_detailed("\n1\t1\tfile.py\ninvalid-entry")
    assert adds == 1 and dels == 1
    assert mapping == {"file.py": (1, 1)}


def test_write_output_creates_parent_and_appends(mem_fs_path: Path) -> None:
    target = mem_fs_path / "nested" / "out.txt"
    write_output("first", target, append=False)
    write_output("second", target, append=True)
    assert target.read_text(encoding="utf-8").endswith("firstsecond")


def test_parse_args_and_main_delegate_to_collect(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    captured: dict[str, object] = {}

    def fake_collect_and_write(**kwargs: object) -> None:
        captured.update(kwargs)

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.collect_and_write",
        fake_collect_and_write,
    )

    args = parse_args(
        [
            "--base",
            "origin/dev",
            "--head",
            "feature/123",
            "--out",
            "~/summary.txt",
            "--appendix-out",
            "~/appendix.txt",
            "--repo-root",
            ".",
            "--append",
            "--no-untracked",
        ]
    )
    assert args.base == "origin/dev"
    assert args.append is True

    main(
        [
            "--base",
            "origin/dev",
            "--head",
            "feature/123",
            "--out",
            "~/summary.txt",
            "--appendix-out",
            "~/appendix.txt",
            "--repo-root",
            ".",
            "--append",
            "--no-untracked",
        ]
    )

    assert captured["base"] == "origin/dev"
    assert captured["head"] == "feature/123"
    assert captured["append"] is True
    assert captured["include_untracked"] is False
