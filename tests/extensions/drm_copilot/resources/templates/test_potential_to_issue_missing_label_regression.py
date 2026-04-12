"""Focused regressions for missing promotion-label recovery in the bundled runtime."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Iterable
    from types import ModuleType

ROOT = Path(__file__).resolve().parents[5]
BUNDLED_SCRIPTS_DIR = ROOT / "extensions" / "drm-copilot" / "resources" / "scripts"
BUNDLED_RUNTIME_PATH = BUNDLED_SCRIPTS_DIR / "dev_tools" / "potential_to_issue.py"


class FakeFileSystem:
    """Provide an in-memory filesystem for bundled-runtime regression tests.

    Purpose:
        Exercise bundled promotion behavior without local disk IO.

    Usage:
        Seed ``files`` with the potential markdown before invoking the bundled
        module's ``promote_potential`` function.

    Flow:
        File reads, writes, and moves are tracked entirely in memory.

    Side Effects:
        Mutates the in-memory ``files``, ``dirs``, and ``moves`` collections.
    """

    def __init__(self) -> None:
        """Initialize empty in-memory file, directory, and move state.

        Purpose:
            Prepare deterministic containers used by the fake filesystem methods.

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
            Match the bundled runtime filesystem contract without touching disk.

        Args:
            path_str (str): Raw path provided to the runtime.

        Returns:
            Path: Fake path object for the supplied string.

        Raises:
            None.

        Side Effects:
            None.
        """

        return Path(path_str)

    def exists(self, path: Path) -> bool:
        """Return whether the fake path exists in memory.

        Purpose:
            Support the bundled runtime's precondition checks.

        Args:
            path (Path): Fake path to inspect.

        Returns:
            bool: ``True`` when the file exists in ``files``.

        Raises:
            None.

        Side Effects:
            None.
        """

        return path in self.files

    def read_text(self, path: Path) -> str:
        """Read fake file content from memory.

        Purpose:
            Provide bundled runtime input without local filesystem access.

        Args:
            path (Path): Fake file path to read.

        Returns:
            str: Stored markdown content for the fake file.

        Raises:
            KeyError: When the path was not seeded.

        Side Effects:
            None.
        """

        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        """Persist fake file content in memory.

        Purpose:
            Mirror the bundled runtime filesystem adapter contract.

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
            Support bundled metadata updates after successful promotion.

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
        """Track bundled directory creation requests in memory.

        Purpose:
            Preserve parity with the bundled runtime directory-creation step.

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
            Validate that successful bundled promotions archive the source file.

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
    """Provide deterministic gh responses for bundled-runtime regression tests.

    Purpose:
        Simulate bundled ``issue_create``, ``ensure_label``, and ``issue_view``
        calls without invoking the real gh CLI.

    Usage:
        Configure the two-step create failure then success sequence required by
        the refactor-label recovery scenario.

    Flow:
        ``issue_create`` consumes queued responses, ``ensure_label`` records the
        selected label, and ``issue_view`` returns the configured JSON payload.

    Side Effects:
        Mutates call-tracking collections on the instance.
    """

    def __init__(
        self,
        create_results: list[object],
        *,
        view_result: object,
        label_result: object,
    ) -> None:
        """Capture deterministic gh responses for the bundled regression.

        Purpose:
            Initialize the ordered fake gh responses consumed by the runtime.

        Args:
            create_results (list[object]): Issue-create responses returned in
                order by the fake client.
            view_result (object): Issue-view response returned after success.
            label_result (object): Ensure-label response returned during recovery.

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

    def issue_create(self, title: str, body: str, promotion_type: str) -> object:
        """Record and return the next configured create response.

        Purpose:
            Simulate the initial refactor-label failure and retry success.

        Args:
            title (str): Issue title requested by the runtime.
            body (str): Issue body requested by the runtime.
            promotion_type (str): Label selected for the promotion.

        Returns:
            object: The next configured bundled-runtime gh result object.

        Raises:
            IndexError: When no configured create responses remain.

        Side Effects:
            Appends a ``create`` entry to ``calls`` and consumes one queued
            response.
        """

        self.calls.append(("create", (title, body, promotion_type)))
        return self.create_results.pop(0)

    def ensure_label(self, label: str) -> object:
        """Record and return the configured ensure-label response.

        Purpose:
            Simulate the bundled label-creation recovery step.

        Args:
            label (str): Label requested by the runtime.

        Returns:
            object: Configured ensure-label response object.

        Raises:
            None.

        Side Effects:
            Appends an ``ensure_label`` entry to ``calls`` and records the label
            in ``ensure_label_calls``.
        """

        self.ensure_label_calls.append(label)
        self.calls.append(("ensure_label", (label,)))
        return self.label_result

    def issue_view(self, issue_number: str) -> object:
        """Record and return the configured issue-view response.

        Purpose:
            Support bundled metadata refresh after the retry succeeds.

        Args:
            issue_number (str): Created issue number requested by the runtime.

        Returns:
            object: Configured issue-view response object.

        Raises:
            None.

        Side Effects:
            Appends a ``view`` entry to ``calls``.
        """

        self.calls.append(("view", (issue_number,)))
        return self.view_result


def _load_bundled_runtime_module(module_name: str) -> ModuleType:
    """Load the bundled runtime module directly from the extension package.

    Purpose:
        Test the exact Python script executed by the extension wrapper rather than
        a copied or repo-local surrogate.

    Args:
        module_name (str): Temporary module name used for the direct import.

    Returns:
        ModuleType: Loaded bundled runtime module.

    Raises:
        AssertionError: When the runtime module cannot be loaded from disk.

    Side Effects:
        Mutates ``sys.path`` and ``sys.modules`` for the duration of the test.
    """

    scripts_dir = str(BUNDLED_SCRIPTS_DIR)
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)

    spec = importlib.util.spec_from_file_location(module_name, BUNDLED_RUNTIME_PATH)
    if spec is None or spec.loader is None:
        raise AssertionError(
            f"Unable to load bundled runtime from {BUNDLED_RUNTIME_PATH}"
        )

    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    sys.modules["dev_tools.potential_to_issue"] = module
    spec.loader.exec_module(module)
    return module


def _clear_bundled_runtime_modules(module_name: str) -> None:
    """Remove temporary bundled runtime imports after each test.

    Purpose:
        Keep module state isolated across repeated direct-import regressions.

    Args:
        module_name (str): Temporary module name created by the test.

    Returns:
        None.

    Raises:
        None.

    Side Effects:
        Removes temporary entries from ``sys.modules``.
    """

    sys.modules.pop(module_name, None)
    sys.modules.pop("dev_tools.potential_to_issue", None)
    sys.modules.pop("dev_tools.potential_to_issue_content", None)
    sys.modules.pop("dev_tools.prompt_mode_contract", None)


def _build_potential_content(feature_name: str) -> str:
    """Return minimal potential markdown for bundled promotion regressions.

    Purpose:
        Provide the required markdown sections consumed by the bundled runtime.

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


def test_bundled_runtime_refactor_missing_label_recovers_and_moves_file() -> None:
    """Verify bundled refactor promotion retries after a missing-label failure."""

    module_name = "ext_pti_runtime_refactor_missing_label"
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module(module_name)
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/missing-refactor-label.md"
        fs = FakeFileSystem()
        fs.files[potential] = _build_potential_content("Missing Refactor Label")
        gh = FakeGhClient(
            [
                module.GhResult(["could not add label: 'refactor' not found"], 1),
                module.GhResult(["Created: https://example.com/issues/654"], 0),
            ],
            view_result=module.GhResult(
                [
                    '{"number":654,"title":"t","url":"https://example.com/issues/654","author":{"login":"me"},"updatedAt":"2024-04-06T00:00:00Z"}'
                ],
                0,
            ),
            label_result=module.GhResult(["refactor label ensured"], 0),
        )

        outcome = module.promote_potential(
            potential_path=str(potential),
            promotion_type="refactor",
            fs=fs,
            gh=gh,
            workspace=workspace,
        )

        expected_destination = (
            workspace / "docs/features/potential/promoted/missing-refactor-label.md"
        )
        assert outcome.exit_code == 0
        assert outcome.destination == expected_destination
        assert gh.ensure_label_calls == ["refactor"]
        create_calls = [call for call in gh.calls if call[0] == "create"]
        assert len(create_calls) == 2
        assert all(call[1][2] == "refactor" for call in create_calls)
        assert (potential, expected_destination) in fs.moves
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules(module_name)
