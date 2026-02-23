from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from collections.abc import Sequence

from scripts.dev_tools.pr_context.collector import (
    CommandResult,
    GitClient,
    PullRequestDetails,
    collect_and_write,
)
from scripts.dev_tools.pr_context.models import FeatureDocExcerpt, PRContextResult


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


def test_collect_and_write_includes_intent_and_additional_context(
    monkeypatch: pytest.MonkeyPatch, mem_path: Path
) -> None:
    outputs: list[tuple[Path, str]] = []

    def fake_write_output(text: str, out_path: Path, append: bool) -> None:
        outputs.append((out_path, text))

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.write_output", fake_write_output
    )

    class StubGit:
        def __init__(self, *args: object, **kwargs: object) -> None:
            self._root = mem_path

        def resolve_root(self) -> Path:
            return self._root

        def branch_name(self) -> str:
            return "feature/ABC-10"

        def upstream(self) -> str:
            return "origin/feature/ABC-10"

        def remote_verbose(self) -> str:
            return "origin https://example/repo (fetch)"

        def status_short(self) -> str:
            return "## feature/ABC-10"

        def untracked(self) -> str:
            return ""

        def diff_name_status(self, *, staged: bool) -> str:
            return ""

        def diff_patch(self, *, staged: bool) -> str:
            return ""

        def rev_parse(self, ref: str) -> str:
            return f"{ref}-sha"

        def merge_base(self, base: str, head: str) -> str:
            return "base-sha"

        def log(self, fmt: str, rev_range: str) -> str:
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
            return None

        def ci_status(self, head_sha: str) -> tuple[str | None, list[str]]:
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
        context_text = "\n".join(
            [
                "===== Changed files (name-status) =====",
                "M\tdocs/features/active/2025-12-18-docs-v3-upgrade/spec.md",
                "===== Diff shortstat =====",
                " 1 files changed, 1 insertions(+), 0 deletions(-)",
            ]
        )
        return PRContextResult(
            text=context_text,
            referenced_issues=[],
            referenced_prs=[],
            verified_closing=[],
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

    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GitClient", StubGit)
    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GhClient", StubGh)
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.build_pr_context", fake_build_pr_context
    )

    def fake_gather_feature_excerpts(
        root: Path, paths: Sequence[str]
    ) -> list[FeatureDocExcerpt]:
        return [
            FeatureDocExcerpt(
                feature="2025-12-18-docs-v3-upgrade",
                excerpt=(
                    "Feature doc: 2025-12-18-docs-v3-upgrade\n"
                    "Plan verification notes\n"
                    "Excerpt"
                ),
                issue_refs=[],
                context_files=[
                    "docs/features/active/2025-12-18-docs-v3-upgrade/spec.md",
                    "docs/features/active/2025-12-18-docs-v3-upgrade/user-story.md",
                ],
            )
        ]

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.gather_feature_excerpts",
        fake_gather_feature_excerpts,
    )

    evidence_path = (
        mem_path
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "evidence"
        / "qa-gates"
        / "pytest-final.2026-02-22T21-00.md"
    )
    evidence_path.parent.mkdir(parents=True)
    evidence_path.write_text(
        "Timestamp: 2026-02-22T21-00\n" "Command: poetry run pytest\n" "EXIT_CODE: 0\n",
        encoding="utf-8",
    )

    repo_root = mem_path
    collect_and_write(
        base="main",
        head="feature",
        out=mem_path / "summary.txt",
        appendix_out=mem_path / "appendix.txt",
        repo_root=repo_root,
        append=False,
        include_untracked=False,
    )

    summary_text = next(text for path, text in outputs if path.name == "summary.txt")
    appendix_text = next(text for path, text in outputs if path.name == "appendix.txt")

    assert "PR Intent" in summary_text
    assert "Author-asserted autoclose issues" in summary_text
    assert "Additional context files" in summary_text
    assert "Feature doc excerpts" in summary_text
    assert "Excerpt" in summary_text
    assert "Feature: 2025-12-18-docs-v3-upgrade" in summary_text
    assert "Context files:" in summary_text
    assert (
        "docs/features/active/2025-12-18-docs-v3-upgrade/user-story.md" in summary_text
    )
    assert "Feature doc: 2025-12-18-docs-v3-upgrade" in appendix_text
    assert "Plan verification notes" in appendix_text


def test_collector_verification_evidence_section_is_rendered_with_normalized_fields(
    monkeypatch: pytest.MonkeyPatch, mem_path: Path
) -> None:
    """Require a normalized verification-evidence section in summary output."""
    outputs: list[tuple[Path, str]] = []

    def fake_write_output(text: str, out_path: Path, append: bool) -> None:
        _ = append
        outputs.append((out_path, text))

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.write_output", fake_write_output
    )

    class StubGit:
        def __init__(self, *args: object, **kwargs: object) -> None:
            self._root = mem_path

        def resolve_root(self) -> Path:
            return self._root

        def branch_name(self) -> str:
            return "feature/ABC-10"

        def upstream(self) -> str:
            return "origin/feature/ABC-10"

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
            resolved_base="origin/main",
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
                    "docs/features/active/2025-12-18-docs-v3-upgrade/spec.md",
                    "docs/features/active/2025-12-18-docs-v3-upgrade/evidence/qa-gates/pytest-final.2026-02-22T21-00.md",
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

    parseable_evidence_path = (
        mem_path
        / "docs"
        / "features"
        / "active"
        / "2025-12-18-docs-v3-upgrade"
        / "evidence"
        / "qa-gates"
        / "pytest-final.2026-02-22T21-00.md"
    )
    parseable_evidence_path.parent.mkdir(parents=True)
    parseable_evidence_path.write_text(
        "Timestamp: 2026-02-22T21-00\n" "Command: poetry run pytest\n" "EXIT_CODE: 0\n",
        encoding="utf-8",
    )

    repo_root = mem_path
    collect_and_write(
        base="main",
        head="feature",
        out=mem_path / "summary.txt",
        appendix_out=mem_path / "appendix.txt",
        repo_root=repo_root,
        append=False,
        include_untracked=False,
    )

    summary_text = next(text for path, text in outputs if path.name == "summary.txt")
    assert (
        "===== Verification evidence (feature docs + canonical artifacts) ====="
        in summary_text
    )
    assert "Timestamp" in summary_text
    assert "Command" in summary_text
    assert "EXIT_CODE" in summary_text
    assert "Normalized result" in summary_text


def test_collector_reports_unparseable_evidence_without_claiming_completion(
    monkeypatch: pytest.MonkeyPatch, mem_path: Path
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
            self._root = mem_path

        def resolve_root(self) -> Path:
            return self._root

        def branch_name(self) -> str:
            return "feature/ABC-10"

        def upstream(self) -> str:
            return "origin/feature/ABC-10"

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
            resolved_base="origin/main",
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
        mem_path
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

    repo_root = mem_path
    collect_and_write(
        base="main",
        head="feature",
        out=mem_path / "summary.txt",
        appendix_out=mem_path / "appendix.txt",
        repo_root=repo_root,
        append=False,
        include_untracked=False,
    )

    summary_text = next(text for path, text in outputs if path.name == "summary.txt")
    assert "No canonical verification evidence parsed" in summary_text


def test_pass_readiness_autoclose_section(
    monkeypatch: pytest.MonkeyPatch, mem_path: Path
) -> None:
    """Assert PASS readiness promotes deterministic primary issue."""
    outputs: list[tuple[Path, str]] = []

    def fake_write_output(text: str, out_path: Path, append: bool) -> None:
        _ = append
        outputs.append((out_path, text))

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.write_output", fake_write_output
    )

    class StubGit:
        def __init__(self, *args: object, **kwargs: object) -> None:
            self._root = mem_path

        def resolve_root(self) -> Path:
            return self._root

        def branch_name(self) -> str:
            return "feature/test"

        def upstream(self) -> str:
            return "origin/feature/test"

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
            resolved_base="origin/main",
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
                issue_refs=["#40", "#42", "#43"],
                context_files=["docs/features/active/test/spec.md"],
                primary_issue_ref="#46",
                readiness_signal="PASS",
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
        out=mem_path / "summary.txt",
        appendix_out=mem_path / "appendix.txt",
        repo_root=mem_path,
        append=False,
        include_untracked=False,
    )

    summary_text = next(text for path, text in outputs if path.name == "summary.txt")
    assert "===== Issues to autoclose (verified or pending) =====" in summary_text
    assert "#46" in summary_text


def test_non_pass_readiness_fallback(
    monkeypatch: pytest.MonkeyPatch, mem_path: Path
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
            self._root = mem_path

        def resolve_root(self) -> Path:
            return self._root

        def branch_name(self) -> str:
            return "feature/test"

        def upstream(self) -> str:
            return "origin/feature/test"

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
            resolved_base="origin/main",
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
        out=mem_path / "summary.txt",
        appendix_out=mem_path / "appendix.txt",
        repo_root=mem_path,
        append=False,
        include_untracked=False,
    )

    summary_text = next(text for path, text in outputs if path.name == "summary.txt")
    assert "===== Issues to autoclose (verified or pending) =====" in summary_text
    assert "None (no verified closing issues and readiness not PASS)" in summary_text
