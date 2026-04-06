"""Focused regressions for missing promotion-label recovery in the root runtime."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools import potential_to_issue as mod

if TYPE_CHECKING:
    from collections.abc import Iterable


class FakeFileSystem:
    """Provide an in-memory filesystem for deterministic promotion tests.

    Purpose:
        Isolate the promotion workflow from disk IO while still exercising the
        file update and move branches used by the real script.

    Usage:
        Seed ``files`` with a potential markdown path before invoking
        ``mod.promote_potential``.

    Flow:
        Resolve, read, write, and move operations are tracked entirely in memory.

    Side Effects:
        Mutates the in-memory ``files``, ``dirs``, and ``moves`` collections.
    """

    def __init__(self) -> None:
        """Initialize empty in-memory file, directory, and move state.

        Purpose:
            Prepare deterministic containers used by the test double methods.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Initializes mutable tracking collections on the instance.
        """

        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()
        self.moves: list[tuple[Path, Path]] = []

    def resolve_path(self, path_str: str) -> Path:
        """Return the provided path string as a fake ``Path``.

        Purpose:
            Match the runtime filesystem contract without touching the host disk.

        Args:
            path_str (str): Raw potential-file path from the test.

        Returns:
            Path: The corresponding fake path object.

        Raises:
            None.

        Side Effects:
            None.
        """

        return Path(path_str)

    def exists(self, path: Path) -> bool:
        """Return whether the fake file exists in memory.

        Purpose:
            Support the runtime precondition checks against seeded test content.

        Args:
            path (Path): Fake path to look up.

        Returns:
            bool: ``True`` when the path is present in ``files``.

        Raises:
            None.

        Side Effects:
            None.
        """

        return path in self.files

    def read_text(self, path: Path) -> str:
        """Read fake file content from memory.

        Purpose:
            Provide the markdown content consumed by the promotion workflow.

        Args:
            path (Path): Fake path whose content should be returned.

        Returns:
            str: Stored markdown content for the fake file.

        Raises:
            KeyError: When the path was not seeded before the call.

        Side Effects:
            None.
        """

        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        """Persist fake file content in memory.

        Purpose:
            Mirror the real filesystem adapter used by the promotion workflow.

        Args:
            path (Path): Fake file path to update.
            content (str): New file content.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Updates the in-memory ``files`` mapping.
        """

        self.files[path] = content

    def write_lines(self, path: Path, lines: Iterable[str]) -> None:
        """Persist a line collection as newline-joined content.

        Purpose:
            Support the metadata update branch after successful promotion.

        Args:
            path (Path): Fake file path to update.
            lines (list[str]): Line collection to persist.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Updates the in-memory ``files`` mapping.
        """

        self.files[path] = "\n".join(lines)

    def ensure_dir(self, path: Path) -> None:
        """Track directory creation requests in memory.

        Purpose:
            Preserve parity with the runtime directory-creation step.

        Args:
            path (Path): Fake directory path requested by the runtime.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Records the created directory in ``dirs``.
        """

        self.dirs.add(path)

    def move(self, src: Path, dest: Path) -> None:
        """Move fake file content and record the destination.

        Purpose:
            Validate that successful promotions archive the source markdown file.

        Args:
            src (Path): Fake source file path.
            dest (Path): Fake destination file path.

        Returns:
            None.

        Raises:
            FileNotFoundError: When the source path was not seeded.

        Side Effects:
            Mutates ``files``, records the move, and tracks the destination
            directory in ``dirs``.
        """

        if src not in self.files:
            raise FileNotFoundError(src)

        self.files[dest] = self.files[src]
        del self.files[src]
        self.moves.append((src, dest))
        self.dirs.add(dest.parent)


class FakeGhClient:
    """Provide deterministic gh responses for promotion regression tests.

    Purpose:
        Simulate the create, ensure-label, and issue-view calls made by the
        promotion workflow without invoking external processes.

    Usage:
        Seed ``create_results`` with the red then green gh responses required by
        the scenario under test.

    Flow:
        ``issue_create`` records each call, ``ensure_label`` records the selected
        label, and ``issue_view`` returns the configured JSON payload.

    Side Effects:
        Mutates call-tracking collections on the instance.
    """

    def __init__(
        self,
        create_results: list[mod.GhResult],
        *,
        view_result: mod.GhResult,
        label_result: mod.GhResult,
    ) -> None:
        """Capture deterministic gh responses for the test scenario.

        Purpose:
            Initialize the ordered responses consumed by the fake gh methods.

        Args:
            create_results (list[mod.GhResult]): Issue-create responses returned
                in order.
            view_result (mod.GhResult): Issue-view response returned after
                successful creation.
            label_result (mod.GhResult): Ensure-label response returned during
                recovery.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Initializes mutable call-tracking collections on the instance.
        """

        self.create_results = list(create_results)
        self.view_result = view_result
        self.label_result = label_result
        self.calls: list[tuple[str, tuple[str, ...]]] = []
        self.ensure_label_calls: list[str] = []

    def is_authenticated(self) -> bool:
        """Return a successful authentication state for the fake client.

        Purpose:
            Keep the regression focused on label recovery rather than auth setup.

        Returns:
            bool: Always ``True`` for these tests.

        Raises:
            None.

        Side Effects:
            None.
        """

        return True

    def issue_create(self, title: str, body: str, promotion_type: str) -> mod.GhResult:
        """Record and return the next configured issue-create response.

        Purpose:
            Simulate the initial failure and subsequent retry used by the
            regression scenario.

        Args:
            title (str): Issue title requested by the runtime.
            body (str): Issue body requested by the runtime.
            promotion_type (str): Label selected for the promotion.

        Returns:
            mod.GhResult: The next configured create response.

        Raises:
            IndexError: When no configured create responses remain.

        Side Effects:
            Appends a ``create`` entry to ``calls`` and consumes one queued
            response.
        """

        self.calls.append(("create", (title, body, promotion_type)))
        return self.create_results.pop(0)

    def ensure_label(self, label: str) -> mod.GhResult:
        """Record and return the configured label-ensure response.

        Purpose:
            Simulate the gh label-creation recovery call.

        Args:
            label (str): Label name requested by the runtime.

        Returns:
            mod.GhResult: Configured label-ensure response.

        Raises:
            None.

        Side Effects:
            Appends an ``ensure_label`` entry to ``calls`` and records the label
            in ``ensure_label_calls``.
        """

        self.ensure_label_calls.append(label)
        self.calls.append(("ensure_label", (label,)))
        return self.label_result

    def issue_view(self, issue_number: str) -> mod.GhResult:
        """Record and return the configured issue-view response.

        Purpose:
            Support the metadata-refresh branch after a successful retry.

        Args:
            issue_number (str): Created issue number requested by the runtime.

        Returns:
            mod.GhResult: Configured issue-view response.

        Raises:
            None.

        Side Effects:
            Appends a ``view`` entry to ``calls``.
        """

        self.calls.append(("view", (issue_number,)))
        return self.view_result


def _build_potential_content(feature_name: str) -> str:
    """Return minimal potential markdown for promotion regression coverage.

    Purpose:
        Provide the required markdown sections consumed by the promotion script.

    Args:
        feature_name (str): Heading used for the potential entry.

    Returns:
        str: Minimal markdown body accepted by the promotion workflow.

    Raises:
        None.

    Side Effects:
        None.
    """

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


def test_promote_potential_refactor_missing_label_recovers_and_moves_file() -> None:
    """Verify refactor promotion retries after a missing-label create failure."""

    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/missing-refactor-label.md"
    fs = FakeFileSystem()
    fs.files[potential] = _build_potential_content("Missing Refactor Label")
    gh = FakeGhClient(
        [
            mod.GhResult(["could not add label: 'refactor' not found"], 1),
            mod.GhResult(["Created: https://example.com/issues/456"], 0),
        ],
        view_result=mod.GhResult(
            [
                '{"number":456,"title":"t","url":"https://example.com/issues/456","author":{"login":"me"},"updatedAt":"2024-04-06T00:00:00Z"}'
            ],
            0,
        ),
        label_result=mod.GhResult(["refactor label ensured"], 0),
    )

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="refactor",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    assert outcome.exit_code == 0
    expected_destination = (
        workspace / "docs/features/potential/promoted/missing-refactor-label.md"
    )
    assert outcome.destination == expected_destination
    assert gh.ensure_label_calls == ["refactor"]
    create_calls = [call for call in gh.calls if call[0] == "create"]
    assert len(create_calls) == 2
    assert all(call[1][2] == "refactor" for call in create_calls)
    assert (potential, expected_destination) in fs.moves
