"""Shared in-memory fakes and builders for potential-to-issue tests."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools import potential_to_issue as mod

if TYPE_CHECKING:
    from collections.abc import Iterable


class FakeFileSystem(mod.FileSystem):
    """In-memory filesystem fake used to isolate promotion tests from disk IO."""

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


def build_feature_potential_content(feature_name: str) -> str:
    """Return minimal feature content for potential-to-issue promotion tests."""
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
