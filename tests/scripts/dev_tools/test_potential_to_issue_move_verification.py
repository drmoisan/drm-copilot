"""Regression tests for #623: post-move destination verification.

`promote_potential` must confirm that the promoted destination exists after the
move before it reports success. These cases use in-memory fakes only, with no
disk, network, subprocess, or temporary-file use.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools import potential_to_issue as mod

if TYPE_CHECKING:
    from collections.abc import Iterable


class InMemoryFileSystem(mod.FileSystem):
    """In-memory filesystem fake isolating promotion tests from disk IO.

    Purpose:
        Back the promotion workflow with a dictionary store so tests can observe
        file state without touching the local filesystem.

    Responsibilities:
        Implement every `FileSystem` protocol method; `move` writes the
        destination and deletes the source, like a real move.

    Attributes:
        files (dict[Path, str]): Fake file contents keyed by path.
        dirs (set[Path]): Directories requested through `ensure_dir` or `move`.
        moves (list[tuple[Path, Path]]): Ordered record of move requests.
    """

    def __init__(self) -> None:
        """Initialize empty file, directory, and move tracking structures."""
        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()
        self.moves: list[tuple[Path, Path]] = []

    def resolve_path(self, path_str: str) -> Path:
        """Return the path unchanged, without touching the local filesystem.

        Args:
            path_str (str): Path text supplied by the caller.

        Returns:
            Path: The path built from `path_str`.
        """
        return Path(path_str)

    def exists(self, path: Path) -> bool:
        """Return whether the fake store holds `path`.

        Args:
            path (Path): Path to test.

        Returns:
            bool: True when `path` is a key of `files`.
        """
        return path in self.files

    def read_text(self, path: Path) -> str:
        """Return the stored text for `path`.

        Args:
            path (Path): Path to read.

        Returns:
            str: Stored content.

        Raises:
            KeyError: When `path` is absent from the store.
        """
        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        """Store `content` at `path`.

        Args:
            path (Path): Path to write.
            content (str): Text to store.

        Returns:
            None.
        """
        self.files[path] = content

    def write_lines(self, path: Path, lines: Iterable[str]) -> None:
        """Store `lines` joined with newlines at `path`.

        Args:
            path (Path): Path to write.
            lines (Iterable[str]): Lines to join and store.

        Returns:
            None.
        """
        self.files[path] = "\n".join(lines)

    def ensure_dir(self, path: Path) -> None:
        """Record a directory-creation request.

        Args:
            path (Path): Directory requested.

        Returns:
            None.
        """
        self.dirs.add(path)

    def move(self, src: Path, dest: Path) -> None:
        """Move stored content from `src` to `dest`.

        Args:
            src (Path): Source path; must exist in the store.
            dest (Path): Destination path that receives the content.

        Returns:
            None.

        Raises:
            FileNotFoundError: When `src` is absent from the store.
        """
        if src not in self.files:
            raise FileNotFoundError(src)
        self.files[dest] = self.files[src]
        del self.files[src]
        self.moves.append((src, dest))
        self.dirs.add(dest.parent)


class DroppingMoveFileSystem(InMemoryFileSystem):
    """Filesystem fake whose `move` deletes the source without writing `dest`.

    Purpose:
        Reproduce the #623 signature: the move returns normally, yet the promoted
        destination does not exist afterwards.
    """

    def move(self, src: Path, dest: Path) -> None:
        """Delete `src` and record the move without writing `dest`.

        Args:
            src (Path): Source path; must exist in the store.
            dest (Path): Destination path; recorded but never written.

        Returns:
            None.

        Raises:
            FileNotFoundError: When `src` is absent from the store.
        """
        if src not in self.files:
            raise FileNotFoundError(src)
        del self.files[src]
        self.moves.append((src, dest))


class StubGhClient(mod.GhClient):
    """Authenticated gh client stub with a fixed successful issue creation.

    Purpose:
        Drive the promotion workflow to the move step without any subprocess.
    """

    def is_authenticated(self) -> bool:
        """Report the client as authenticated.

        Returns:
            bool: Always True.
        """
        return True

    def issue_create(self, title: str, body: str, promotion_type: str) -> mod.GhResult:
        """Return a successful create result naming issue 123.

        Args:
            title (str): Issue title (unused by the stub).
            body (str): Issue body (unused by the stub).
            promotion_type (str): Promotion label (unused by the stub).

        Returns:
            mod.GhResult: One `Created:` line and exit code 0.
        """
        return mod.GhResult(["Created: https://example.com/issues/123"], 0)

    def ensure_label(self, label: str) -> mod.GhResult:
        """Return an empty successful result.

        Args:
            label (str): Label name (unused by the stub).

        Returns:
            mod.GhResult: No output and exit code 0.
        """
        return mod.GhResult([], 0)

    def issue_view(self, issue_number: str) -> mod.GhResult:
        """Return an empty successful result.

        Args:
            issue_number (str): Issue number (unused by the stub).

        Returns:
            mod.GhResult: No output and exit code 0.
        """
        return mod.GhResult([], 0)


def _feature_content() -> str:
    """Return minimal feature-potential markdown with all six sections.

    Returns:
        str: Markdown accepted by the promotion workflow.
    """
    return "\n".join(
        [
            "# Feature Title",
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


POTENTIAL = Path("/workspace/docs/features/potential/sample.md")
EXPECTED_DEST = (
    Path("/workspace") / "docs" / "features" / "potential" / "promoted" / "sample.md"
)


def test_promote_potential_returns_exit_1_when_destination_missing_after_move() -> None:
    """A move that drops the file yields exit code 1 and no destination.

    The last message names the missing destination and no "Moved" line is
    emitted, so the caller cannot mistake the run for a success.
    """
    # Arrange
    fs = DroppingMoveFileSystem()
    fs.files[POTENTIAL] = _feature_content()

    # Act
    outcome = mod.promote_potential(
        str(POTENTIAL),
        "feature",
        fs=fs,
        gh=StubGhClient(),
        workspace=Path("/workspace"),
        emit=lambda _message: None,
    )

    # Assert
    assert outcome.exit_code == 1
    assert outcome.destination is None
    assert outcome.messages[-1] == f"Promoted file missing after move: {EXPECTED_DEST}"
    assert not any(
        message.startswith("Moved potential file to promoted folder:")
        for message in outcome.messages
    )


def test_promote_potential_returns_destination_when_move_succeeds() -> None:
    """A move that writes the destination keeps the success outcome unchanged."""
    # Arrange
    fs = InMemoryFileSystem()
    fs.files[POTENTIAL] = _feature_content()

    # Act
    outcome = mod.promote_potential(
        str(POTENTIAL),
        "feature",
        fs=fs,
        gh=StubGhClient(),
        workspace=Path("/workspace"),
        emit=lambda _message: None,
    )

    # Assert
    assert outcome.exit_code == 0
    assert outcome.destination == EXPECTED_DEST
    assert EXPECTED_DEST in fs.files
    assert outcome.messages[-1] == (
        f"Moved potential file to promoted folder: {EXPECTED_DEST}"
    )
