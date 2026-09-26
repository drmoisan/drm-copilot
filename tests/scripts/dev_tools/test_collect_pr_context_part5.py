"""Collector evidence and readiness-fallback tests split out of part4.

Issue #622 moved these tests out of ``test_collect_pr_context_part4.py`` so
that neither file exceeds the repository's 500-line cap.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Sequence
    from pathlib import Path

    import pytest

from scripts.dev_tools.pr_context.collector import (
    CommandResult,
    PullRequestDetails,
    collect_and_write,
)
from scripts.dev_tools.pr_context.models import FeatureDocExcerpt, PRContextResult


def test_collector_reports_unparseable_evidence_without_claiming_completion(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """Require conservative fallback text when canonical evidence cannot be parsed."""
    outputs: list[tuple[Path, str]] = []

    def fake_write_output(text: str, out_path: Path, append: bool) -> None:
        _ = append
        outputs.append((out_path, text))

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.write_output", fake_write_output
    )

    class StubGit:
        def __init__(self, *args: object, **kwargs: object) -> None:
            self._root = mem_fs_path

        def resolve_root(self) -> Path:
            return self._root

        def branch_name(self) -> str:
            return "feature/ABC-10"

        def upstream(self) -> str:
            return "upstream/feature/ABC-10"

        def remote_verbose(self) -> str:
            return "origin https://example/repo (fetch)"

        def status_short(self) -> str:
            return "## feature/ABC-10"

        def untracked(self) -> str:
            return ""

        def diff_name_status(self, *, staged: bool) -> str:
            _ = staged
            return ""

        def diff_patch(self, *, staged: bool) -> str:
            _ = staged
            return ""

        def rev_parse(self, ref: str) -> str:
            return f"{ref}-sha"

        def merge_base(self, base: str, head: str) -> str:
            _ = base, head
            return "base-sha"

        def log(self, fmt: str, rev_range: str) -> str:
            _ = fmt, rev_range
            return ""

        def diff_range(self, args: Sequence[str]) -> str:
            if "--name-status" in args:
                return "M\tdocs/features/active/2025-12-18-docs-v3-upgrade/spec.md"
            if "--numstat" in args:
                return "1\t0\tdocs/features/active/2025-12-18-docs-v3-upgrade/spec.md"
            if "--shortstat" in args:
                return " 1 files changed, 1 insertions(+), 0 deletions(-)"
            if "--stat" in args:
                return " spec.md | 1 +"
            return ""

        def run(
            self, args: Sequence[str], *, allow_error: bool = False
        ) -> CommandResult:
            _ = args, allow_error
            return CommandResult(stdout="resolved", stderr="", code=0)

    class StubGh:
        status_message = "ok"
        available = True

        def __init__(self, *args: object, **kwargs: object) -> None:
            return None

        def ensure_available(self) -> None:
            return None

        def current_pr(self) -> PullRequestDetails | None:
            return None

        def classify_entity(self, number: str) -> str | None:
            _ = number
            return None

        def ci_status(self, head_sha: str) -> tuple[str | None, list[str]]:
            _ = head_sha
            return "success", []

    def fake_build_pr_context(
        *,
        git: StubGit,
        gh: StubGh,
        base_ref: str | None,
        head_ref: str | None,
        include_untracked: bool,
        feature_issue_refs: Sequence[str] | None = None,
        current_pr: PullRequestDetails | None = None,
        gh_available: bool | None = None,
    ) -> PRContextResult:
        _ = (
            git,
            gh,
            include_untracked,
            feature_issue_refs,
            current_pr,
            gh_available,
        )
        return PRContextResult(
            text=(
                "===== Changed files (name-status) =====\n"
                "M\tdocs/features/active/2025-12-18-docs-v3-upgrade/spec.md"
            ),
            referenced_issues=[],
            referenced_prs=[],
            verified_closing=[],
            invalid_references=[],
            base_ref=base_ref,
            resolved_base="upstream/main",
            base_sha="base-sha",
            head_ref=head_ref or "feature",
            head_sha="head-sha",
            merge_base="base-sha",
            rev_range="base-sha..head-sha",
            gh_available=True,
        )

    def fake_gather_feature_excerpts(
        root: Path, paths: Sequence[str]
    ) -> list[FeatureDocExcerpt]:
        _ = root, paths
        return [
            FeatureDocExcerpt(
                feature="2025-12-18-docs-v3-upgrade",
                excerpt="Feature doc excerpt",
                issue_refs=[],
                context_files=[
                    "docs/features/active/2025-12-18-docs-v3-upgrade/evidence/qa-gates/unparseable.2026-02-22T21-00.md",
                ],
            )
        ]

    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GitClient", StubGit)
    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GhClient", StubGh)
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.build_pr_context", fake_build_pr_context
    )
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.gather_feature_excerpts",
        fake_gather_feature_excerpts,
    )

    malformed_evidence_path = (
        mem_fs_path
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "evidence"
        / "qa-gates"
        / "unparseable.2026-02-22T21-00.md"
    )
    malformed_evidence_path.parent.mkdir(parents=True)
    malformed_evidence_path.write_text(
        "Timestamp: 2026-02-22T21-00\n" "Command: poetry run pytest\n",
        encoding="utf-8",
    )

    repo_root = mem_fs_path
    collect_and_write(
        base="main",
        head="feature",
        out=mem_fs_path / "summary.txt",
        appendix_out=mem_fs_path / "appendix.txt",
        repo_root=repo_root,
        append=False,
        include_untracked=False,
    )

    summary_text = next(text for path, text in outputs if path.name == "summary.txt")
    assert "No canonical verification evidence parsed" in summary_text


def test_non_pass_readiness_fallback(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """Assert approved section emits explicit None fallback for non-PASS."""
    outputs: list[tuple[Path, str]] = []

    def fake_write_output(text: str, out_path: Path, append: bool) -> None:
        _ = append
        outputs.append((out_path, text))

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.write_output", fake_write_output
    )

    class StubGit:
        def __init__(self, *args: object, **kwargs: object) -> None:
            self._root = mem_fs_path

        def resolve_root(self) -> Path:
            return self._root

        def branch_name(self) -> str:
            return "feature/test"

        def upstream(self) -> str:
            return "upstream/feature/test"

        def remote_verbose(self) -> str:
            return "origin https://example/repo (fetch)"

        def status_short(self) -> str:
            return "## feature/test"

        def untracked(self) -> str:
            return ""

        def diff_name_status(self, *, staged: bool) -> str:
            _ = staged
            return ""

        def diff_patch(self, *, staged: bool) -> str:
            _ = staged
            return ""

        def rev_parse(self, ref: str) -> str:
            return f"{ref}-sha"

        def merge_base(self, base: str, head: str) -> str:
            _ = base, head
            return "base-sha"

        def log(self, fmt: str, rev_range: str) -> str:
            _ = fmt, rev_range
            return ""

        def diff_range(self, args: Sequence[str]) -> str:
            if "--name-status" in args:
                return "M\tdocs/features/active/test/spec.md"
            if "--numstat" in args:
                return "1\t0\tdocs/features/active/test/spec.md"
            if "--shortstat" in args:
                return " 1 files changed, 1 insertions(+), 0 deletions(-)"
            if "--stat" in args:
                return " spec.md | 1 +"
            return ""

        def run(
            self, args: Sequence[str], *, allow_error: bool = False
        ) -> CommandResult:
            _ = args, allow_error
            return CommandResult(stdout="resolved", stderr="", code=0)

    class StubGh:
        status_message = "ok"
        available = True

        def __init__(self, *args: object, **kwargs: object) -> None:
            return None

        def ensure_available(self) -> None:
            return None

        def current_pr(self) -> PullRequestDetails | None:
            return None

        def classify_entity(self, number: str) -> str | None:
            _ = number
            return None

        def ci_status(self, head_sha: str) -> tuple[str | None, list[str]]:
            _ = head_sha
            return "success", []

    def fake_build_pr_context(
        *,
        git: StubGit,
        gh: StubGh,
        base_ref: str | None,
        head_ref: str | None,
        include_untracked: bool,
        feature_issue_refs: Sequence[str] | None = None,
        current_pr: PullRequestDetails | None = None,
        gh_available: bool | None = None,
    ) -> PRContextResult:
        _ = (
            git,
            gh,
            include_untracked,
            feature_issue_refs,
            current_pr,
            gh_available,
        )
        return PRContextResult(
            text=(
                "===== Changed files (name-status) =====\n"
                "M\tdocs/features/active/test/spec.md"
            ),
            referenced_issues=[],
            referenced_prs=[],
            verified_closing=[],
            invalid_references=[],
            base_ref=base_ref,
            resolved_base="upstream/main",
            base_sha="base-sha",
            head_ref=head_ref or "feature",
            head_sha="head-sha",
            merge_base="base-sha",
            rev_range="base-sha..head-sha",
            gh_available=True,
        )

    def fake_gather_feature_excerpts(
        root: Path, paths: Sequence[str]
    ) -> list[FeatureDocExcerpt]:
        _ = root, paths
        return [
            FeatureDocExcerpt(
                feature="test",
                excerpt="Feature doc excerpt",
                issue_refs=[],
                context_files=["docs/features/active/test/spec.md"],
                primary_issue_ref="#46",
                readiness_signal="NEEDS REVISION",
            )
        ]

    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GitClient", StubGit)
    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GhClient", StubGh)
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.build_pr_context", fake_build_pr_context
    )
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

    summary_text = next(text for path, text in outputs if path.name == "summary.txt")
    assert "===== Issues to autoclose (verified or pending) =====" in summary_text
    assert "None (no verified closing issues and readiness not PASS)" in summary_text
