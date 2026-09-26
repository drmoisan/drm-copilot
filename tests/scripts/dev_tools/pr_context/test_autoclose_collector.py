"""Collector autoclose tests for issue #622 (in-memory files, in-process doubles)."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.pr_context.collector import collect_and_write
from scripts.dev_tools.pr_context.models import (
    AUTOCLOSE_PENDING_NOT_OPEN_TEXT,
    AUTOCLOSE_UNVERIFIED_ANNOTATION,
    CommandResult,
    IssueDetails,
    PRContextResult,
    PullRequestDetails,
)

if TYPE_CHECKING:
    from collections.abc import Sequence
    from pathlib import Path

FEATURE_DIR = "docs/features/active/2026-09-25-autoclose-fixture-622"
CHANGED_PATH = f"{FEATURE_DIR}/spec.md"
AUTOCLOSE_TITLE = "Issues to autoclose (verified or pending)"
VERIFIED_LABEL = "Auto-close issues (verified from GitHub PR metadata):"
AUTHOR_LABEL = "Auto-close issues (author asserted):"
DETECTED_LABEL = "Referenced issues (detected):"
NARRATIVE_SPEC = "Narrative mentions #40 #42 #43 in notes.\n"
NO_REFS = "No references.\n"


class _StubGit:
    """In-memory git double mirroring the integration-test git stub's methods."""

    def __init__(self, runner: object, root: Path) -> None:
        """Store the repository root; the runner is accepted and ignored."""
        _ = runner
        self._root = root

    def resolve_root(self) -> Path:
        """Return the in-memory repository root."""
        return self._root

    def branch_name(self) -> str:
        """Return a branch name carrying no issue reference."""
        return "feature/autoclose-fixture"

    def upstream(self) -> str:
        """Return a fixed upstream ref."""
        return "upstream/feature/autoclose-fixture"

    def remote_verbose(self) -> str:
        """Return a fixed remote listing."""
        return "upstream https://example/repo (fetch)"

    def status_short(self) -> str:
        """Return a fixed short status line."""
        return "## feature/autoclose-fixture"

    def untracked(self) -> str:
        """Return no untracked files."""
        return ""

    def diff_name_status(self, *, staged: bool) -> str:
        """Return an empty working-tree name-status diff."""
        _ = staged
        return ""

    def diff_patch(self, *, staged: bool) -> str:
        """Return an empty working-tree patch."""
        _ = staged
        return ""

    def rev_parse(self, ref: str) -> str:
        """Return a synthetic SHA derived from the ref name."""
        return f"{ref}-sha"

    def merge_base(self, base: str, head: str) -> str:
        """Return a fixed merge-base SHA."""
        _ = base, head
        return "base-sha"

    def log(self, fmt: str, rev_range: str) -> str:
        """Return an empty commit log."""
        _ = fmt, rev_range
        return ""

    def diff_range(self, args: Sequence[str]) -> str:
        """Return name-status or numstat text for the single changed spec file."""
        # Route by diff mode; other modes carry no data the assertions read.
        if "--name-status" in args:
            return f"M\t{CHANGED_PATH}"
        if "--numstat" in args:
            return f"1\t0\t{CHANGED_PATH}"
        return ""

    def run(self, args: Sequence[str], *, allow_error: bool = False) -> CommandResult:
        """Return a fixed successful command result."""
        _ = args, allow_error
        return CommandResult(stdout="resolved", stderr="", code=0)


def _gh_double(
    *,
    available: bool,
    classifications: dict[str, str | None],
    states: dict[str, str],
    issue_detail_calls: list[str],
) -> type[object]:
    """Build a ``GhClient`` double; unlisted numbers are unclassified, ``(unknown)``."""
    gh_is_available = available

    class _GhDouble:
        """Scenario-configured stand-in for ``GhClient``."""

        status_message: str | None = "ok" if gh_is_available else None
        available = gh_is_available

        def __init__(self, *args: object, **kwargs: object) -> None:
            """Accept and ignore the collector's constructor arguments."""
            _ = args, kwargs

        def ensure_available(self) -> None:
            """Raise ``RuntimeError`` when the scenario marks gh unavailable."""
            if not gh_is_available:
                raise RuntimeError("offline")

        def current_pr(self) -> PullRequestDetails | None:
            """Report that no pull request exists for the branch."""
            return None

        def classify_entity(self, number: str) -> str | None:
            """Return the scenario classification for ``number``."""
            return classifications.get(number)

        def issue_details(self, number: str) -> IssueDetails:
            """Record the fetch and return details with the scenario state."""
            issue_detail_calls.append(number)
            return IssueDetails(
                number=f"#{number}",
                title=f"Issue {number}",
                state=states.get(number, "(unknown)"),
                labels=[],
                assignees=[],
                author="alex",
                created_at="2026-01-01",
                updated_at="2026-01-02",
                body="Body",
                comments=[],
            )

        def pr_details(self, number: str) -> PullRequestDetails:
            """Return fixed pull request details for ``number``."""
            return PullRequestDetails(
                number=f"#{number}",
                title="PR",
                state="open",
                author="alex",
                base_ref="main",
                head_ref="feature/autoclose-fixture",
                created_at="2026-01-01",
                updated_at="2026-01-02",
                merged_at=None,
                labels=[],
                assignees=[],
                body="PR body",
                closing_issues=[],
                files_changed=["file.py"],
            )

        def ci_status(self, head_sha: str) -> tuple[str | None, list[str]]:
            """Report a successful CI run with no failing jobs."""
            _ = head_sha
            return "success", []

    return _GhDouble


def _online_gh(
    states: dict[str, str],
    *,
    kinds: dict[str, str | None] | None = None,
    calls: list[str] | None = None,
) -> type[object]:
    """Wrap ``_gh_double`` online; ``states`` keys are issues unless ``kinds`` says."""
    classifications: dict[str, str | None] = dict.fromkeys(states, "issue")
    classifications.update(kinds or {})
    return _gh_double(
        available=True,
        classifications=classifications,
        states=states,
        issue_detail_calls=[] if calls is None else calls,
    )


def _run_collector(
    monkeypatch: pytest.MonkeyPatch,
    mem_fs_path: Path,
    *,
    spec_text: str,
    gh_cls: type[object],
    primary: str = "#622",
) -> str:
    """Seed the fixture feature, run ``collect_and_write``, and return the summary."""
    # Seed the feature folder: spec prose, issue metadata, and a PASS audit.
    feature_dir = mem_fs_path / FEATURE_DIR
    feature_dir.mkdir(parents=True)
    (feature_dir / "spec.md").write_text(spec_text, encoding="utf-8")
    (feature_dir / "issue.md").write_text(f"- Issue: {primary}\n", encoding="utf-8")
    (feature_dir / "feature-audit.2026-01-01T00-00.md").write_text(
        "Readiness: PASS\n", encoding="utf-8"
    )
    (mem_fs_path / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

    outputs: list[tuple[Path, str]] = []

    def fake_write_output(text: str, out_path: Path, append: bool) -> None:
        """Capture the rendered document instead of writing it."""
        _ = append
        outputs.append((out_path, text))

    def fake_build_pr_context(**kwargs: object) -> PRContextResult:
        """Return a comparison result naming only the fixture spec file."""
        return PRContextResult(
            text=f"===== Changed files (name-status) =====\nM\t{CHANGED_PATH}",
            referenced_issues=[],
            referenced_prs=[],
            verified_closing=[],
            invalid_references=[],
            base_ref="main",
            resolved_base="main",
            base_sha="base-sha",
            head_ref="feature",
            head_sha="head-sha",
            merge_base="base-sha",
            rev_range="base-sha..head-sha",
            gh_available=bool(kwargs.get("gh_available")),
        )

    def fake_scoping_doc_changes(
        **kwargs: object,
    ) -> list[tuple[str, bool, list[str], str | None]]:
        """Report no scoping-document changes."""
        _ = kwargs
        return []

    collector = "scripts.dev_tools.pr_context.collector"
    monkeypatch.setattr(f"{collector}.write_output", fake_write_output)
    monkeypatch.setattr(f"{collector}.GitClient", _StubGit)
    monkeypatch.setattr(f"{collector}.GhClient", gh_cls)
    monkeypatch.setattr(f"{collector}.build_pr_context", fake_build_pr_context)
    monkeypatch.setattr(f"{collector}._scoping_doc_changes", fake_scoping_doc_changes)

    collect_and_write(
        base="main",
        head="feature",
        out=mem_fs_path / "summary.txt",
        appendix_out=mem_fs_path / "appendix.txt",
        repo_root=mem_fs_path,
        append=False,
        include_untracked=False,
    )
    return next(text for path, text in outputs if path.name == "summary.txt")


def _section(summary: str, title: str) -> str:
    """Return the ``===== title =====`` banner and its lines up to the next banner."""
    header = f"===== {title} ====="
    lines = summary.split("\n")
    collected = [header]
    # Walk forward from the banner until the next section banner begins.
    for line in lines[lines.index(header) + 1 :]:
        if line.startswith("====="):
            break
        collected.append(line)
    return "\n".join(collected)


def _lines_after(summary: str, label: str) -> list[str]:
    """Return the lines after the first ``label`` line, up to the first blank line."""
    lines = summary.split("\n")
    collected: list[str] = []
    # Collect the label's list block, which ends at the first blank line.
    for line in lines[lines.index(label) + 1 :]:
        if not line.strip():
            break
        collected.append(line)
    return collected


def _autoclose_surfaces(summary: str) -> list[str]:
    """Return the autoclose section and both auto-close label blocks as text."""
    return [
        _section(summary, AUTOCLOSE_TITLE),
        "\n".join(_lines_after(summary, VERIFIED_LABEL)),
        "\n".join(_lines_after(summary, AUTHOR_LABEL)),
    ]


def test_collector_excludes_scraped_tokens_from_autoclose_when_gh_unavailable(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """C1: scraped tokens stay out of autoclose; the metadata list is annotated."""
    # Arrange
    gh = _gh_double(
        available=False, classifications={}, states={}, issue_detail_calls=[]
    )
    spec = "Timestamps use #ISO-8601 and ISO-8601; finding #CR-1 (CR-1); see #468.\n"

    # Act
    summary = _run_collector(monkeypatch, mem_fs_path, spec_text=spec, gh_cls=gh)

    # Assert: no scraped token reaches any autoclose surface.
    for surface in _autoclose_surfaces(summary):
        for token in ("ISO-8601", "CR-1", "#468"):
            assert token not in surface, f"{token} leaked into:\n{surface}"
    autoclose_lines = _section(summary, AUTOCLOSE_TITLE).split("\n")
    entry_index = autoclose_lines.index("- #622")
    assert autoclose_lines[entry_index + 1] == AUTOCLOSE_UNVERIFIED_ANNOTATION
    classified = _section(summary, "Referenced issues (classified)")
    assert "#468" in classified
    assert "NOTE: Unverified (GitHub unavailable)" in classified


def test_collector_excludes_prose_cited_closed_issue_from_autoclose(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """C2: a closed issue cited in prose is not offered for autoclose."""
    # Arrange
    gh = _online_gh({"468": "closed", "622": "open"})
    spec = "See #468.\n"

    # Act
    summary = _run_collector(monkeypatch, mem_fs_path, spec_text=spec, gh_cls=gh)

    # Assert
    for surface in _autoclose_surfaces(summary):
        assert "#468" not in surface, f"#468 leaked into:\n{surface}"


def test_collector_excludes_prose_cited_open_out_of_scope_issue_from_autoclose(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """C3: an open issue cited in prose is listed as detected, not autoclosed."""
    # Arrange
    gh = _online_gh({"584": "open", "622": "open"})
    spec = "Related to #584.\n"

    # Act
    summary = _run_collector(monkeypatch, mem_fs_path, spec_text=spec, gh_cls=gh)

    # Assert
    for surface in _autoclose_surfaces(summary):
        assert "#584" not in surface, f"#584 leaked into:\n{surface}"
    assert "- #584" in _lines_after(summary, DETECTED_LABEL)


@pytest.mark.parametrize(
    ("classification", "state"),
    [
        pytest.param("issue", "closed", id="closed-issue"),
        pytest.param("issue", "(unknown)", id="unknown-state"),
        pytest.param("pull", "open", id="pull-request"),
        pytest.param(None, "open", id="unclassified"),
    ],
)
def test_collector_excludes_closed_pending_primary_without_printing_it(
    monkeypatch: pytest.MonkeyPatch,
    mem_fs_path: Path,
    classification: str | None,
    state: str,
) -> None:
    """C4: a pending primary that is not an open issue renders the not-open text."""
    # Arrange
    gh = _online_gh({"622": state}, kinds={"622": classification})

    # Act
    summary = _run_collector(monkeypatch, mem_fs_path, spec_text=NO_REFS, gh_cls=gh)

    # Assert
    section_text = _section(summary, AUTOCLOSE_TITLE)
    non_empty = [line for line in section_text.split("\n") if line.strip()]
    assert non_empty[-1] == AUTOCLOSE_PENDING_NOT_OPEN_TEXT
    assert "#622" not in section_text


@pytest.mark.parametrize("state", ["open", "OPEN"])
def test_collector_keeps_open_pending_primary(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path, state: str
) -> None:
    """C5: an open pending primary stays in the section without annotation."""
    # Arrange
    gh = _online_gh({"622": state})

    # Act
    summary = _run_collector(monkeypatch, mem_fs_path, spec_text=NO_REFS, gh_cls=gh)

    # Assert
    section_text = _section(summary, AUTOCLOSE_TITLE)
    assert "- #622" in section_text
    assert "Unverified:" not in section_text


def test_collector_fetches_each_issue_once(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """C6: every issue's details are fetched at most once per run."""
    # Arrange
    calls: list[str] = []
    states = {"468": "closed", "584": "open", "622": "open"}
    gh = _online_gh(states, kinds={"7": "pull"}, calls=calls)
    spec = "Cites #468, #584, and #7.\n"

    # Act
    _run_collector(monkeypatch, mem_fs_path, spec_text=spec, gh_cls=gh)

    # Assert
    assert sorted(calls) == ["468", "584", "622"]


def test_narrative_mentions_excluded_from_autoclose_section(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """C7: narrative refs stay out of the approved autoclose section."""
    # Arrange
    gh = _online_gh({"46": "open"})

    # Act
    summary_text = _run_collector(
        monkeypatch, mem_fs_path, spec_text=NARRATIVE_SPEC, gh_cls=gh, primary="#46"
    )

    # Assert
    section_start = summary_text.index(f"===== {AUTOCLOSE_TITLE} =====")
    section_end = summary_text.index("===== Close candidates =====", section_start)
    approved_section = summary_text[section_start:section_end]
    assert "#46" in approved_section
    assert "#40" not in approved_section
    assert "#42" not in approved_section
    assert "#43" not in approved_section


def test_pass_readiness_autoclose_section(
    monkeypatch: pytest.MonkeyPatch, mem_fs_path: Path
) -> None:
    """C8: PASS readiness promotes the deterministic primary issue."""
    # Arrange
    gh = _online_gh({"46": "open"})

    # Act
    summary_text = _run_collector(
        monkeypatch, mem_fs_path, spec_text=NARRATIVE_SPEC, gh_cls=gh, primary="#46"
    )

    # Assert
    assert "===== Issues to autoclose (verified or pending) =====" in summary_text
    assert "#46" in summary_text
