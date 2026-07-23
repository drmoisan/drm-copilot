"""Branch-coverage tests for scripts/dev_tools/potential_to_issue.py.

These cases target the partial branches identified in the term-missing coverage
report for `potential_to_issue.py` to raise its per-module branch coverage above
the 75% floor. No production code is modified; all cases use in-memory fakes with
no network, subprocess, real-filesystem, or temporary-file usage.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import potential_to_issue as mod

if TYPE_CHECKING:
    from collections.abc import Iterable


class FakeFileSystem(mod.FileSystem):
    """In-memory filesystem fake isolating promotion tests from disk IO."""

    def __init__(self) -> None:
        """Initialize in-memory file, directory, and move tracking structures."""
        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()
        self.moves: list[tuple[Path, Path]] = []

    def resolve_path(self, path_str: str) -> Path:
        """Resolve fake paths without touching the local filesystem."""
        return Path(path_str)

    def exists(self, path: Path) -> bool:
        """Return whether a fake file path exists in memory."""
        return path in self.files

    def read_text(self, path: Path) -> str:
        """Read in-memory text content for a fake file path."""
        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        """Write in-memory text content for a fake file path."""
        self.files[path] = content

    def write_lines(self, path: Path, lines: Iterable[str]) -> None:
        """Persist line collections as newline-joined in-memory text."""
        self.files[path] = "\n".join(lines)

    def ensure_dir(self, path: Path) -> None:
        """Track directory creation requests in memory."""
        self.dirs.add(path)

    def move(self, src: Path, dest: Path) -> None:
        """Move fake file content from source path to destination path."""
        if src not in self.files:
            raise FileNotFoundError(src)
        self.files[dest] = self.files[src]
        del self.files[src]
        self.moves.append((src, dest))
        self.dirs.add(dest.parent)


class FakeGhClient(mod.GhClient):
    """Deterministic gh client fake for promotion workflow testing."""

    def __init__(
        self,
        create_result: mod.GhResult | list[mod.GhResult],
        view_result: mod.GhResult | None = None,
        label_result: mod.GhResult | None = None,
        authenticated: bool = True,
    ) -> None:
        """Initialize fake gh responses and call tracking state."""
        self.create_results = (
            create_result if isinstance(create_result, list) else [create_result]
        )
        self.view_result = view_result
        self.label_result = label_result or mod.GhResult([], 0)
        self.authenticated = authenticated
        self.calls: list[tuple[str, tuple[str, ...]]] = []
        self.ensure_label_calls: list[str] = []

    def is_authenticated(self) -> bool:
        """Return preconfigured authentication status."""
        return self.authenticated

    def issue_create(self, title: str, body: str, promotion_type: str) -> mod.GhResult:
        """Record issue-create invocations and return configured result."""
        self.calls.append(("create", (title, body, promotion_type)))
        if len(self.create_results) > 1:
            return self.create_results.pop(0)
        return self.create_results[0]

    def ensure_label(self, label: str) -> mod.GhResult:
        """Record label-ensure requests and return configured result."""
        self.ensure_label_calls.append(label)
        self.calls.append(("ensure_label", (label,)))
        return self.label_result

    def issue_view(self, issue_number: str) -> mod.GhResult:
        """Record issue-view invocation and return configured view result."""
        self.calls.append(("view", (issue_number,)))
        return self.view_result or mod.GhResult([], 0)


def _feature_content(feature_name: str = "Feature Title") -> str:
    """Return minimal feature-potential markdown content for promotion tests."""
    return "\n".join(
        [
            f"# {feature_name}",
            "## Problem / Why",
            "why",
            "## Proposed Behavior",
            "behave",
            "## Acceptance Criteria (early draft)",
            "criteria",
            "## Constraints & Risks",
            "risk",
            "## Test Conditions to Consider",
            "tests",
        ]
    )


# --- RealGhClient branch cases -------------------------------------------------


def test_real_gh_client_post_init_accepts_explicit_gh_path() -> None:
    """Cover branch 117->119: __post_init__ skips PATH lookup when gh_path is set.

    An explicit gh_path bypasses the `shutil.which` resolution branch and passes
    the emptiness guard without raising.
    """
    # Arrange / Act: construct with an explicit resolved path.
    client = mod.RealGhClient(gh_path="C:/tools/gh.exe")

    # Assert: the supplied path is retained and no FileNotFoundError is raised.
    assert client.gh_path == "C:/tools/gh.exe"


def test_real_gh_client_is_authenticated_false_when_path_unresolved() -> None:
    """Cover line 128: is_authenticated returns False when gh_path is None.

    The early guard returns False before any subprocess call, so no external
    process is executed.
    """
    # Arrange: construct with a path, then clear it to hit the unresolved guard.
    client = mod.RealGhClient(gh_path="C:/tools/gh.exe")
    client.gh_path = None

    # Act
    result = client.is_authenticated()

    # Assert
    assert result is False


def test_real_gh_client_command_raises_when_path_unresolved() -> None:
    """Cover line 140: command execution raises RuntimeError when gh_path is None.

    issue_view delegates to the internal command runner, whose guard raises before
    any subprocess call, so no external process runs. Exercising the public method
    avoids accessing the protected runner directly.
    """
    # Arrange
    client = mod.RealGhClient(gh_path="C:/tools/gh.exe")
    client.gh_path = None

    # Act / Assert
    with pytest.raises(RuntimeError, match="gh CLI path was not resolved"):
        client.issue_view("1")


# --- promote_potential validation branches ------------------------------------


def test_promote_potential_rejects_invalid_work_mode() -> None:
    """Cover branch 397->398: an unsupported work_mode raises PromotionError."""
    # Arrange
    fs = FakeFileSystem()
    gh = FakeGhClient(mod.GhResult([], 0))

    # Act / Assert
    with pytest.raises(mod.PromotionError, match="Invalid work mode"):
        mod.promote_potential(
            potential_path="/workspace/docs/sample.md",
            promotion_type="feature",
            fs=fs,
            gh=gh,
            workspace=Path("/workspace"),
            work_mode="not-a-mode",
        )


def test_promote_potential_rejects_empty_content() -> None:
    """Cover branch 414->415: whitespace-only content raises PromotionError."""
    # Arrange: a file that exists but holds only whitespace.
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/blank.md"
    fs = FakeFileSystem()
    fs.files[potential] = "   \n\t\n"
    gh = FakeGhClient(mod.GhResult([], 0))

    # Act / Assert
    with pytest.raises(mod.PromotionError, match="Potential file is empty"):
        mod.promote_potential(
            potential_path=str(potential),
            promotion_type="feature",
            fs=fs,
            gh=gh,
            workspace=workspace,
        )


def test_promote_potential_wraps_invalid_mode_type_combination() -> None:
    """Cover branch 430->432 and lines 432-433: invalid mode/type combo re-raises.

    normalize_requested_work_mode raises ValueError for the (bug, full-feature)
    combination, which is caught and re-raised as PromotionError.
    """
    # Arrange
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/bug.md"
    fs = FakeFileSystem()
    fs.files[potential] = _feature_content("Bug Title")
    gh = FakeGhClient(mod.GhResult(["Created: https://example.com/issues/1"], 0))

    # Act / Assert
    with pytest.raises(mod.PromotionError):
        mod.promote_potential(
            potential_path=str(potential),
            promotion_type="bug",
            fs=fs,
            gh=gh,
            workspace=workspace,
            work_mode="full-feature",
        )


def test_relative_path_falls_back_to_absolute_on_value_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Cover branch 423->425 and lines 425-426: relpath ValueError fallback.

    When os.path.relpath raises ValueError (for example, cross-drive paths on
    Windows), the helper returns the absolute resolved path and promotion still
    completes.
    """

    # Arrange: force relpath to raise ValueError for the footer path computation.
    def _raise_value_error(_path: str, _start: str) -> str:
        raise ValueError("path is on mount 'C:', start on mount 'D:'")

    monkeypatch.setattr(mod.os.path, "relpath", _raise_value_error)

    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample.md"
    fs = FakeFileSystem()
    fs.files[potential] = _feature_content()
    create_result = mod.GhResult(["Created: https://example.com/issues/700"], 0)
    view_result = mod.GhResult(
        [
            '{"number":700,"title":"t","url":"https://example.com/issues/700",'
            '"author":{"login":"me"},"updatedAt":"2024-01-02T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result)

    # Act
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    # Assert: promotion succeeds despite the relpath failure.
    assert outcome.exit_code == 0
    assert outcome.destination is not None


# --- issue-body routing and gh-outcome branches -------------------------------


def test_minor_audit_uses_existing_evidence_checklist() -> None:
    """Cover branch 459->463: a present Evidence Checklist skips the default.

    A non-bug potential promoted in minor-audit mode with an authored Evidence
    Checklist section retains that authored content instead of the fallback
    checklist.
    """
    # Arrange
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/audit.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Audit Feature",
            "## Problem / Why",
            "why",
            "## Proposed Behavior",
            "behave",
            "## Acceptance Criteria (early draft)",
            "criteria",
            "## Constraints & Risks",
            "risk",
            "## Test Conditions to Consider",
            "tests",
            "## Evidence Checklist",
            "- [x] Authored evidence item",
        ]
    )
    create_result = mod.GhResult(["Created: https://example.com/issues/810"], 0)
    view_result = mod.GhResult(
        [
            '{"number":810,"title":"t","url":"https://example.com/issues/810",'
            '"author":{"login":"me"},"updatedAt":"2024-01-02T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result)

    # Act
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )

    # Assert: the authored checklist is used; the default checklist is absent.
    assert outcome.exit_code == 0
    create_call = next(call for call in gh.calls if call[0] == "create")
    body = create_call[1][1]
    assert "Authored evidence item" in body
    assert "- [ ] Baseline" not in body


def test_missing_label_failure_without_retry_when_ensure_label_fails() -> None:
    """Cover branch 512->515: a failed ensure_label skips the create retry.

    When the label-create recovery itself returns a non-zero exit code, the
    promotion does not retry issue creation and returns the original failure.
    """
    # Arrange
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample.md"
    fs = FakeFileSystem()
    fs.files[potential] = _feature_content()
    create_result = mod.GhResult(
        ["could not add label: 'feature' not found"],
        1,
    )
    label_result = mod.GhResult(["label create denied"], 1)
    gh = FakeGhClient(create_result, label_result=label_result)

    # Act
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    # Assert: original failure returned, label recovery attempted once, no retry.
    assert outcome.exit_code == 1
    assert outcome.destination is None
    assert gh.ensure_label_calls == ["feature"]
    create_calls = [call for call in gh.calls if call[0] == "create"]
    assert len(create_calls) == 1


def test_create_success_without_issue_number_skips_view_and_metadata() -> None:
    """Cover branches 530->535 and 535->548: no parsed issue number skips both.

    A successful create whose output contains no recognizable issue URL yields no
    issue number, so the issue-view and metadata-update blocks are skipped while
    the source file is still archived.
    """
    # Arrange
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample.md"
    fs = FakeFileSystem()
    fs.files[potential] = _feature_content()
    create_result = mod.GhResult(["Issue created but no url present"], 0)
    gh = FakeGhClient(create_result)

    # Act
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    # Assert: success and archived, but no issue-view call and no metadata write.
    assert outcome.exit_code == 0
    assert outcome.destination is not None
    assert (potential, outcome.destination) in fs.moves
    assert all(call[0] != "view" for call in gh.calls)
