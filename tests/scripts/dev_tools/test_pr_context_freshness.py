"""Tests for the generated-context freshness header on the Python surface.

The header exists so a consumer can decide, without parsing either document
body, whether a pair on disk describes the branch it is about to review. The two
checks it enables are pair identity (the generated-context block is
byte-identical in both files, proving one invocation produced both) and head
binding (the head SHA equals the head of the branch under review). Existence and
modification time are not freshness signals, so neither is asserted here.

The collect-and-write test drives the real entry point with a stubbed runner and
an in-memory write seam. No temporary file is created by any test in this module.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.pr_context.collector import (
    FeatureDocExcerpt,
    PRContextResult,
    PullRequestDetails,
    collect_and_write,
)
from scripts.dev_tools.pr_context.summary_helpers import (
    GENERATED_CONTEXT_SECTION_TITLE,
    HEAD_SHA_LABEL,
    UNKNOWN_HEAD_SHA_PLACEHOLDER,
    append_generation_timestamp,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

    import pytest

    from scripts.dev_tools.pr_context.git import CommandRunner, GitClient

#: Concrete forty-character fixture SHA supplied by these tests.
FIXTURE_HEAD_SHA = "0123456789abcdef0123456789abcdef01234567"
GENERATED_CONTEXT_BANNER = f"===== {GENERATED_CONTEXT_SECTION_TITLE} ====="
CHANGED_PATH = "docs/features/active/2025-12-18-docs-v3-upgrade/spec.md"
#: A changed path matching none of the collector's changed-file buckets.
UNBUCKETED_PATH = "assets/logo.svg"

#: Path of the TypeScript helper whose literals the parity test reads.
TYPESCRIPT_SUMMARY_HELPERS = Path(
    "extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts"
)


class StubGit:
    """Minimal git double supplying only the command shapes the collector uses."""

    def __init__(self, root: Path) -> None:
        self._root = root

    def resolve_root(self) -> Path:
        return self._root

    def branch_name(self) -> str:
        return "feature/freshness"

    def upstream(self) -> str:
        return "origin/feature/freshness"

    def remote_verbose(self) -> str:
        return "origin https://example/repo (fetch)"

    def status_short(self) -> str:
        return "## feature/freshness"

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
        # Two changed paths, chosen so the collector's changed-file bucketing
        # exercises both a bucketed path and one that matches no bucket. The
        # docs path lands in the docs bucket; the asset path is neither a
        # rename, nor Python or PowerShell, nor docs, so it falls through.
        if "--name-status" in args:
            return f"M\t{CHANGED_PATH}\nM\t{UNBUCKETED_PATH}"
        if "--numstat" in args:
            return f"1\t0\t{CHANGED_PATH}\n2\t1\t{UNBUCKETED_PATH}"
        return ""

    def run(self, args: Sequence[str], *, allow_error: bool = False) -> object:
        _ = args, allow_error
        from scripts.dev_tools.pr_context.models import CommandResult

        return CommandResult(stdout="resolved", stderr="", code=0)


class StubGh:
    """Minimal GitHub CLI double reporting availability with no references."""

    status_message = "ok"
    available = True

    def __init__(self, *args: object, **kwargs: object) -> None:
        _ = args, kwargs

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


def _collect_pair(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path, head_sha: str | None
) -> tuple[str, str]:
    """Run `collect_and_write` against stubs and return the two written texts."""
    outputs: list[tuple[Path, str]] = []

    def fake_write_output(text: str, out_path: Path, append: bool) -> None:
        _ = append
        outputs.append((out_path, text))

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
        _ = git, gh, include_untracked, feature_issue_refs, current_pr, gh_available
        return PRContextResult(
            text="PR-CONTEXT-TEXT-BODY",
            referenced_issues=[],
            referenced_prs=[],
            verified_closing=[],
            invalid_references=[],
            base_ref=base_ref,
            resolved_base="origin/main",
            base_sha="base-sha",
            head_ref=head_ref or "feature/freshness",
            head_sha=head_sha,
            merge_base="base-sha",
            rev_range="base-sha..head-sha",
            gh_available=True,
        )

    def fake_git_client(runner: CommandRunner, root: Path) -> StubGit:
        _ = runner
        return StubGit(root)

    def fake_feature_excerpts(
        root: Path, paths: Sequence[str]
    ) -> list[FeatureDocExcerpt]:
        _ = root, paths
        return []

    def fake_scoping_doc_changes(
        *,
        git: GitClient,
        merge_base: str | None,
        head_sha: str | None,
        root: Path,
        name_status_text: str,
        numstat_details: dict[str, tuple[int, int]],
    ) -> list[tuple[str, bool, list[str], str | None]]:
        _ = git, merge_base, head_sha, root, name_status_text, numstat_details
        return []

    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.write_output", fake_write_output
    )
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.GitClient", fake_git_client
    )
    monkeypatch.setattr("scripts.dev_tools.pr_context.collector.GhClient", StubGh)
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.build_pr_context", fake_build_pr_context
    )
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector.gather_feature_excerpts",
        fake_feature_excerpts,
    )
    monkeypatch.setattr(
        "scripts.dev_tools.pr_context.collector._scoping_doc_changes",
        fake_scoping_doc_changes,
    )

    collect_and_write(
        base="main",
        head="feature/freshness",
        out=mem_fs_path / "summary.txt",
        appendix_out=mem_fs_path / "appendix.txt",
        repo_root=Path(__file__).resolve().parents[3],
        append=False,
        include_untracked=False,
    )

    summary_text = next(text for path, text in outputs if path.name == "summary.txt")
    appendix_text = next(text for path, text in outputs if path.name == "appendix.txt")
    return summary_text, appendix_text


def _generated_block(text: str) -> str:
    """Extract the generated-context block: the banner and the two lines after it."""
    lines = text.split("\n")
    index = lines.index(GENERATED_CONTEXT_BANNER)
    kept: list[str] = [GENERATED_CONTEXT_BANNER]
    # Keep the timestamp line and the head-SHA line, skipping the blank spacer.
    for line in lines[index + 1 :]:
        if line == "":
            continue
        kept.append(line)
        if len(kept) == 3:
            break
    return "\n".join(kept)


def _first_banner(text: str) -> str:
    """Return the first section banner appearing in a rendered document."""
    for line in text.split("\n"):
        if line.startswith("===== ") and line.endswith(" ====="):
            return line
    return ""


def test_collect_and_write_opens_both_documents_with_an_identical_generated_block(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """Both written documents open with a byte-identical generated-context block."""
    # Arrange / Act
    summary_text, appendix_text = _collect_pair(
        monkeypatch, mem_fs_path, FIXTURE_HEAD_SHA
    )

    # Assert: each document opens with the generated-context section.
    assert _first_banner(summary_text) == GENERATED_CONTEXT_BANNER
    assert _first_banner(appendix_text) == GENERATED_CONTEXT_BANNER

    # Assert: the generated-context block is byte-identical between the two.
    summary_block = _generated_block(summary_text)
    assert summary_block == _generated_block(appendix_text)
    assert f"{HEAD_SHA_LABEL} {FIXTURE_HEAD_SHA}" in summary_block


def test_head_sha_line_renders_the_fixture_sha_and_the_unknown_placeholder() -> None:
    """The head-SHA line carries a concrete SHA, or the unknown placeholder."""
    # Arrange
    assert len(FIXTURE_HEAD_SHA) == 40

    # Act
    with_sha = append_generation_timestamp(FIXTURE_HEAD_SHA)
    without_sha = append_generation_timestamp()

    # Assert
    assert f"{HEAD_SHA_LABEL} {FIXTURE_HEAD_SHA}" in with_sha
    assert f"{HEAD_SHA_LABEL} {UNKNOWN_HEAD_SHA_PLACEHOLDER}" in without_sha
    assert FIXTURE_HEAD_SHA not in without_sha


def test_freshness_header_literals_match_the_typescript_helper() -> None:
    """The two runtimes use the same section-title and head-SHA-label literals.

    The verbatim-port relationship between the two pr-context surfaces is
    prose-declared and has no general parity harness. This assertion is confined
    to the two literals this change introduces: it reads the TypeScript helper's
    source text and requires the literals it contains to equal the ones the
    Python helper uses. It spawns no process and adds no harness beyond this
    comparison.
    """
    # Arrange
    repo_root = Path(__file__).resolve().parents[3]
    typescript_source = (repo_root / TYPESCRIPT_SUMMARY_HELPERS).read_text(
        encoding="utf-8"
    )

    # Act / Assert: each Python literal appears as a quoted literal in the
    # TypeScript source, so the two runtimes cannot drift on either string.
    assert f'"{GENERATED_CONTEXT_SECTION_TITLE}"' in typescript_source
    assert f'"{HEAD_SHA_LABEL}"' in typescript_source
    assert f'"{UNKNOWN_HEAD_SHA_PLACEHOLDER}"' in typescript_source
