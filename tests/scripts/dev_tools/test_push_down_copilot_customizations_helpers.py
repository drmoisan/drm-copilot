"""Focused helper coverage for the push-down customization publisher.

Purpose:
    Raise coverage on the split publisher modules without expanding the original
    feature test file that already sits near the repo's file-size policy limit.
"""

from __future__ import annotations

import importlib
import json
from dataclasses import dataclass
from pathlib import Path

import pytest  # noqa: TCH002 - pytest required at runtime for test assertions


@dataclass
class MemoryFile:
    """Represent text content stored in the recording filesystem."""

    content: str


class RecordingPushDownFileSystem:
    """
    Provide a deterministic filesystem double for helper-focused tests.

    Purpose:
        Exercise the publisher's validation, artifact emission, and CLI success
        paths without touching the real filesystem.

    Usage:
        Seed `files` and `directories`, then pass the instance to the publisher
        entry points under test.

    Flow:
        The double stores file content in memory, tracks created directories,
        and exposes the minimal API required by `PushDownFileSystem`.

    Invariants / Constraints:
        Only UTF-8 text content is modeled because the publisher currently works
        with repository text files.

    Side Effects:
        Mutates in-memory dictionaries and sets only.
    """

    def __init__(self, *, files: dict[Path, MemoryFile] | None = None) -> None:
        """
        Initialize the recording filesystem.

        Purpose:
            Seed the test double with optional source or destination files.

        Args:
            files (dict[Path, MemoryFile] | None): Optional initial file map.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Stores the provided file map and starts with no tracked directories.
        """
        self.files: dict[Path, MemoryFile] = files or {}
        self.directories: set[Path] = set()

    def list_files(self, root: Path) -> list[Path]:
        """
        Return all files under a root path in sorted order.

        Purpose:
            Mirror the deterministic enumeration expectations used by the
            production publisher.

        Args:
            root (Path): Root path to scan.

        Returns:
            list[Path]: Sorted file paths under `root`.

        Raises:
            None.

        Side Effects:
            None.
        """
        files: list[Path] = []
        # Keep enumeration deterministic so assertions do not depend on hash order.
        for path in self.files:
            try:
                path.relative_to(root)
            except ValueError:
                continue
            files.append(path)
        return sorted(files)

    def is_dir(self, path: Path) -> bool:
        """
        Return whether the path is tracked as a directory.

        Purpose:
            Support destination validation without real filesystem access.

        Args:
            path (Path): Path to inspect.

        Returns:
            bool: True when `path` is in the tracked directory set.

        Raises:
            None.

        Side Effects:
            None.
        """
        return path in self.directories

    def is_file(self, path: Path) -> bool:
        """
        Return whether the path is tracked as a file.

        Purpose:
            Let tests drive created-versus-overwritten classification.

        Args:
            path (Path): Path to inspect.

        Returns:
            bool: True when `path` exists in the file map.

        Raises:
            None.

        Side Effects:
            None.
        """
        return path in self.files

    def read_text(self, path: Path) -> str:
        """
        Return file content from the in-memory store.

        Purpose:
            Support publisher reads and artifact assertions.

        Args:
            path (Path): File path to read.

        Returns:
            str: Stored file content.

        Raises:
            FileNotFoundError: When the path has not been seeded.

        Side Effects:
            None.
        """
        if path not in self.files:
            raise FileNotFoundError(path)
        return self.files[path].content

    def write_text(self, path: Path, content: str) -> None:
        """
        Store file content in memory.

        Purpose:
            Capture publisher output and summary artifacts without disk I/O.

        Args:
            path (Path): File path to write.
            content (str): Text content to persist.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Updates the in-memory file map and marks the parent directory as
            present.
        """
        self.files[path] = MemoryFile(content=content)
        self.directories.add(path.parent)

    def ensure_dir(self, path: Path) -> None:
        """
        Mark a directory as created.

        Purpose:
            Let tests assert the publisher creates destination and artifact
            directories deterministically.

        Args:
            path (Path): Directory path to mark.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Mutates the tracked directory set.
        """
        self.directories.add(path)


def _load_main_module():
    """
    Import the public push-down module under test.

    Purpose:
        Keep imports local to tests so future module reload needs stay easy to
        manage.

    Args:
        None.

    Returns:
        object: Imported main module.

    Raises:
        ModuleNotFoundError: Propagated when the module path changes.

    Side Effects:
        Imports the module.
    """
    return importlib.import_module("scripts.dev_tools.push_down_copilot_customizations")


def _load_filesystem_module():
    """
    Import the filesystem helper module under test.

    Purpose:
        Keep helper-module imports explicit in filesystem-focused tests.

    Args:
        None.

    Returns:
        object: Imported filesystem helper module.

    Raises:
        ModuleNotFoundError: Propagated when the helper path changes.

    Side Effects:
        Imports the module.
    """
    return importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations_filesystem"
    )


def _load_rewrite_module():
    """
    Import the rewrite helper module under test.

    Purpose:
        Keep helper-module imports explicit in rewrite-focused tests.

    Args:
        None.

    Returns:
        object: Imported rewrite helper module.

    Raises:
        ModuleNotFoundError: Propagated when the helper path changes.

    Side Effects:
        Imports the module.
    """
    return importlib.import_module(
        "scripts.dev_tools.push_down_copilot_customizations_rewrites"
    )


def test_parse_args_returns_destination_namespace() -> None:
    """Parse the required destination flag for the stable public CLI contract."""
    module = _load_main_module()

    args = module.parse_args(["--destination", "C:/workspace/destination"])

    assert args.destination == "C:/workspace/destination"


def test_push_down_customizations_rejects_repo_root_destination() -> None:
    """Reject the source repository root as the destination before copying."""
    module = _load_main_module()
    repo_root = Path("/repo-root")
    fs = RecordingPushDownFileSystem()
    fs.ensure_dir(repo_root)

    with pytest.raises(ValueError, match="must not be the source repository root"):
        module.push_down_customizations(
            repo_root=repo_root,
            destination_root=repo_root,
            fs=fs,
        )


def test_push_down_customizations_writes_summary_artifact_json() -> None:
    """Write a deterministic JSON summary artifact during a successful run."""
    module = _load_main_module()
    repo_root = Path("/source-repo")
    destination_root = Path("/destination-repo")
    source_file = repo_root / ".github/prompts/example.prompt.md"
    fs = RecordingPushDownFileSystem(
        files={source_file: MemoryFile(content="No rewrites needed here.")}
    )
    fs.ensure_dir(repo_root)
    fs.ensure_dir(source_file.parent)
    fs.ensure_dir(destination_root)

    summary = module.push_down_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
    )

    artifact_payload = json.loads(fs.read_text(Path(summary.artifact_path)))
    assert artifact_payload["repo_root"] == repo_root.as_posix()
    assert artifact_payload["destination_root"] == destination_root.as_posix()
    assert artifact_payload["created_count"] == 1
    assert artifact_payload["overwritten_count"] == 0
    assert (
        artifact_payload["files"][0]["relative_path"]
        == ".github/prompts/example.prompt.md"
    )


def test_main_prints_summary_artifact_path_on_success(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Print the artifact path when the CLI completes successfully."""
    module = _load_main_module()
    repo_root = Path("/source-repo").expanduser().resolve()
    destination_root = Path("/destination-repo").expanduser().resolve()
    fs = RecordingPushDownFileSystem()
    fs.ensure_dir(repo_root)
    fs.ensure_dir(destination_root)

    exit_code = module.main(
        ["--destination", str(destination_root)],
        repo_root=repo_root,
        fs=fs,
    )

    captured = capsys.readouterr()
    assert exit_code == 0
    assert "Wrote push-down summary artifact to:" in captured.out
    assert "artifacts/copilot-customizations/push-down-" in captured.out


def test_main_preserves_windows_style_absolute_paths_on_linux_hosts(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Keep Windows absolute test paths stable when the host runner is Linux."""
    module = _load_main_module()
    repo_root = Path("C:/source-repo")
    destination_root = Path("C:/destination-repo")
    source_file = repo_root / ".github" / "prompts" / "example.prompt.md"
    fs = RecordingPushDownFileSystem(
        files={source_file: MemoryFile(content="No rewrites needed here.")}
    )
    fs.ensure_dir(repo_root)
    fs.ensure_dir(source_file.parent)
    fs.ensure_dir(destination_root)

    exit_code = module.main(
        ["--destination", str(destination_root)],
        repo_root=repo_root,
        fs=fs,
    )

    captured = capsys.readouterr()
    assert exit_code == 0
    assert "Wrote push-down summary artifact to:" in captured.out
    assert (
        fs.read_text(destination_root / ".github" / "prompts" / "example.prompt.md")
        == "No rewrites needed here."
    )


def test_real_filesystem_list_files_returns_empty_when_root_is_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Return an empty list when the requested source root does not exist."""
    filesystem_module = _load_filesystem_module()
    root = Path("/missing-root")

    def fake_is_dir(_: Path) -> bool:
        """Report the requested root as absent for this enumeration scenario."""
        return False

    monkeypatch.setattr(Path, "is_dir", fake_is_dir)

    assert filesystem_module.RealPushDownFileSystem().list_files(root) == []


def test_real_filesystem_list_files_filters_and_sorts_paths(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Keep only files and sort them deterministically during enumeration."""
    filesystem_module = _load_filesystem_module()
    root = Path("/repo/.github")
    later_file = root / "z-last.md"
    earlier_file = root / "a-first.md"
    non_file = root / "nested"

    def fake_root_is_dir(candidate: Path) -> bool:
        """Mark only the requested root as a directory for the test run."""
        return candidate == root

    def fake_rglob(self: Path, pattern: str):
        """Return an intentionally unsorted mixed directory listing."""
        assert self == root
        assert pattern == "*"
        return [later_file, non_file, earlier_file]

    def fake_is_file(candidate: Path) -> bool:
        """Treat only the seeded markdown paths as files for sorting coverage."""
        return candidate in {later_file, earlier_file}

    monkeypatch.setattr(Path, "is_dir", fake_root_is_dir)
    monkeypatch.setattr(Path, "rglob", fake_rglob)
    monkeypatch.setattr(Path, "is_file", fake_is_file)

    files = filesystem_module.RealPushDownFileSystem().list_files(root)

    assert files == [earlier_file, later_file]


def test_real_filesystem_delegates_path_operations(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Delegate file and directory operations to the underlying Path methods."""
    filesystem_module = _load_filesystem_module()
    adapter = filesystem_module.RealPushDownFileSystem()
    directory_path = Path("/repo/output")
    file_path = directory_path / "example.md"
    calls: dict[str, object] = {}
    mkdir_calls: list[tuple[Path, bool, bool]] = []

    def fake_is_dir(candidate: Path) -> bool:
        """Mark only the seeded output directory as an existing directory."""
        return candidate == directory_path

    def fake_is_file(candidate: Path) -> bool:
        """Mark only the seeded markdown file as an existing file."""
        return candidate == file_path

    monkeypatch.setattr(Path, "is_dir", fake_is_dir)
    monkeypatch.setattr(Path, "is_file", fake_is_file)

    def fake_read_text(self: Path, *, encoding: str) -> str:
        """Record read delegation and return deterministic content."""
        calls["read"] = (self, encoding)
        return "file content"

    def fake_write_text(
        self: Path,
        content: str,
        *,
        encoding: str,
        newline: str,
    ) -> int:
        """Record write delegation and require LF-only output semantics."""
        calls["write"] = (self, content, encoding, newline)
        return len(content)

    def fake_mkdir(self: Path, *, parents: bool, exist_ok: bool) -> None:
        """Record directory-creation requests."""
        mkdir_calls.append((self, parents, exist_ok))

    monkeypatch.setattr(Path, "read_text", fake_read_text)
    monkeypatch.setattr(Path, "write_text", fake_write_text)
    monkeypatch.setattr(Path, "mkdir", fake_mkdir)

    assert adapter.is_dir(directory_path) is True
    assert adapter.is_file(file_path) is True
    assert adapter.read_text(file_path) == "file content"
    adapter.write_text(file_path, "updated content")
    adapter.ensure_dir(directory_path)

    assert calls["read"] == (file_path, "utf-8")
    assert calls["write"] == (file_path, "updated content", "utf-8", "\n")
    assert mkdir_calls == [
        (directory_path, True, True),
        (directory_path, True, True),
    ]


def test_build_rewrite_catalog_contains_expected_command_targets() -> None:
    """Expose the stable implemented and placeholder command IDs in the catalog."""
    rewrite_module = _load_rewrite_module()

    catalog = rewrite_module.build_rewrite_catalog()

    assert catalog["scripts.dev_tools.pr_context.collector"].command_id == (
        "drmCopilotExtension.collectPrContext"
    )
    assert (
        catalog["scripts.dev_tools.new_active_feature_folder"].is_placeholder is False
    )
    assert catalog["scripts/dev_tools/new-potential-entry.ps1"].command_id == (
        "drmCopilotExtension.newPotentialEntry"
    )


def test_normalize_reference_for_lookup_removes_prefixes_and_normalizes_slashes() -> (
    None
):
    """Normalize workspace-prefixed references onto the catalog key space."""
    rewrite_module = _load_rewrite_module()

    normalized = rewrite_module.normalize_reference_for_lookup(
        "poetry run python -m "
        "${workspaceFolder}\\scripts\\dev-tools\\new-potential-entry.ps1"
    )

    assert normalized == "scripts/dev_tools/new-potential-entry.ps1"


def test_rewrite_matched_reference_preserves_trailing_punctuation() -> None:
    """Keep trailing punctuation attached when a placeholder reference is rewritten."""
    rewrite_module = _load_rewrite_module()
    catalog = rewrite_module.build_rewrite_catalog()

    replacement, rewritten_count, placeholder_count, unmatched = (
        rewrite_module.rewrite_matched_reference(
            "scripts.dev_tools.new_active_feature_folder.",
            catalog,
        )
    )

    assert rewritten_count == 1
    assert placeholder_count == 0
    assert unmatched == []
    assert replacement.endswith(").")
    assert "`drmCopilotExtension.newActiveFeatureFolder`" in replacement


def test_rewrite_text_references_reports_unique_unmatched_references() -> None:
    """Report unknown references once even when they appear repeatedly in one file."""
    rewrite_module = _load_rewrite_module()
    text = (
        "Run poetry run python -m scripts.dev_tools.unknown_tool and "
        "scripts.dev_tools.unknown_tool again. Also run "
        "poetry run python -m scripts.dev_tools.pr_context.collector."
    )

    rewritten_text, rewritten_count, placeholder_count, unmatched = (
        rewrite_module.rewrite_text_references(text)
    )

    assert rewritten_count == 1
    assert placeholder_count == 0
    assert unmatched == ["scripts.dev_tools.unknown_tool"]
    assert "drm-copilot: Collect PR Context" in rewritten_text


def test_push_down_customizations_reads_from_explicit_source_root() -> None:
    """Enumerate source files from a packaged source root.

    Verifies behaviour when source root is distinct from the destination.
    """
    module = _load_main_module()
    source_root = Path("/packaged-source")
    destination_root = Path("/destination-workspace")
    fs = RecordingPushDownFileSystem()
    fs.ensure_dir(source_root)
    fs.ensure_dir(destination_root)

    source_file = source_root / ".github/prompts/example.prompt.md"
    fs.ensure_dir(source_file.parent)
    fs.write_text(source_file, "packaged prompt content")

    summary = module.push_down_customizations(
        repo_root=source_root,
        destination_root=destination_root,
        source_root=source_root,
        fs=fs,
    )

    assert summary.created_count == 1
    copied_text = fs.read_text(destination_root / ".github/prompts/example.prompt.md")
    assert copied_text == "packaged prompt content"


def test_push_down_writes_artifact_under_explicit_artifact_root() -> None:
    """Write summary artifact under an explicit artifact root.

    Verifies the artifact lands outside the source root.
    """
    module = _load_main_module()
    source_root = Path("/packaged-source")
    destination_root = Path("/destination-workspace")
    artifact_root = Path("/destination-workspace")
    fs = RecordingPushDownFileSystem()
    fs.ensure_dir(source_root)
    fs.ensure_dir(destination_root)

    source_file = source_root / ".github/prompts/example.prompt.md"
    fs.ensure_dir(source_file.parent)
    fs.write_text(source_file, "prompt content")

    summary = module.push_down_customizations(
        repo_root=source_root,
        destination_root=destination_root,
        artifact_root=artifact_root,
        fs=fs,
    )

    assert "destination-workspace" in summary.artifact_path
    assert "packaged-source" not in summary.artifact_path


def test_thinking_beast_mode_bundle_mirror_matches_root_agent() -> None:
    """Keep the bundled Thinking Beast Mode agent identical to the root source."""
    repo_root = Path(__file__).resolve().parents[3]
    root_agent_path = (
        repo_root / ".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"
    )
    mirror_agent_path = repo_root / (
        "extensions/drm-copilot/resources/customizations/.github/agents/"
        "5.1-Thinking-Beast-Mode-adjusted.agent.md"
    )

    assert mirror_agent_path.read_text(encoding="utf-8") == root_agent_path.read_text(
        encoding="utf-8"
    )


def test_split_trailing_punctuation_returns_core_and_suffix() -> None:
    """Split trailing prose punctuation away from the matched reference core."""
    rewrite_module = _load_rewrite_module()

    core, suffix = rewrite_module.split_trailing_punctuation(
        "scripts.dev_tools.potential_to_issue!)"
    )

    assert core == "scripts.dev_tools.potential_to_issue"
    assert suffix == "!)"
