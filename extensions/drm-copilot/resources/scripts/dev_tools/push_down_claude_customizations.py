"""Publish bundled `.claude` content into a destination workspace.

Purpose:
    Provide a dedicated public entry point for the Claude customization push-down
    workflow while reusing the shared publisher engine behind the existing
    `.github` customization flow. Settings-local configuration is excluded from
    push-down because it holds host-specific overrides that must not propagate.

    Agent-memory files under `.claude/agent-memory/` are filtered by a
    content-based scope check: only memories whose frontmatter declares
    `metadata.scope: general` are distributed to a destination workspace. A
    memory with an absent, malformed, or unrecognized scope is treated as
    `repo` and excluded (fail-safe default), so repository-specific memories do
    not leak into consumer workspaces. Files outside `.claude/agent-memory/`
    are copied verbatim and are never affected by the scope filter.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

AGENT_MEMORY_RELATIVE_ROOT = Path(".claude/agent-memory")
GENERAL_MEMORY_SCOPE = "general"
REPO_MEMORY_SCOPE = "repo"

# Match a leading YAML frontmatter block: the first `---` line, the block body,
# and the closing `---` line. DOTALL lets the body span multiple lines.
_FRONTMATTER_PATTERN = re.compile(
    r"\A---[ \t]*\r?\n(.*?)\r?\n---[ \t]*(?:\r?\n|\Z)", re.DOTALL
)
# Match a `metadata:` mapping key at column zero, then capture the indented
# block lines that belong to it (lines that are more-indented or blank) until
# the next column-zero key or end of the frontmatter body.
_METADATA_BLOCK_PATTERN = re.compile(
    r"^metadata:[ \t]*\r?\n((?:[ \t]+.*(?:\r?\n|\Z)|\r?\n)*)",
    re.MULTILINE,
)
# Match a `scope:` leaf inside the metadata block, capturing its scalar value
# up to an optional inline comment. Surrounding quotes are stripped later.
_SCOPE_LEAF_PATTERN = re.compile(
    r"^[ \t]+scope:[ \t]*([^\r\n#]*)",
    re.MULTILINE,
)

try:
    from scripts.dev_tools.push_down_copilot_customizations import (
        PushDownFileSystem,
        PushDownSummary,
        RealPushDownFileSystem,
        resolve_cli_path,
    )
    from scripts.dev_tools.push_down_copilot_customizations import (
        push_down_customizations as push_down_scoped_customizations,
    )
except ModuleNotFoundError as error:
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_copilot_customizations import (
        PushDownFileSystem,
        PushDownSummary,
        RealPushDownFileSystem,
        resolve_cli_path,
    )
    from dev_tools.push_down_copilot_customizations import (
        push_down_customizations as push_down_scoped_customizations,
    )

ARTIFACT_DIRECTORY = "artifacts/claude-customizations"
MODULE_ENTRY_POINT = "scripts.dev_tools.push_down_claude_customizations"
ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)
EXCLUDED_RELATIVE_PATHS: tuple[Path, ...] = (Path(".claude/settings.local.json"),)

__all__ = [
    "AGENT_MEMORY_RELATIVE_ROOT",
    "ARTIFACT_DIRECTORY",
    "EXCLUDED_RELATIVE_PATHS",
    "GENERAL_MEMORY_SCOPE",
    "PushDownSummary",
    "REPO_MEMORY_SCOPE",
    "ROOT_FOLDERS",
    "main",
    "parse_args",
    "push_down_customizations",
]


def _read_memory_scope(content: str) -> str:
    """Return the declared memory scope from a file's YAML frontmatter.

    Purpose:
        Extract the `metadata.scope` leaf from the leading YAML frontmatter
        block using a narrow `re`-based parser. This avoids adding a runtime
        YAML dependency (PyYAML) while reading only the single leaf the
        push-down scope filter requires.

    Args:
        content (str): The full text of a candidate memory file, including any
            leading `---` frontmatter block.

    Returns:
        str: ``"general"`` only when the frontmatter contains a `metadata:`
        mapping whose `scope:` leaf is exactly ``general`` (quotes and inline
        comments stripped). In every other case — missing frontmatter, no
        closing `---`, no `metadata:` block, no `scope:` leaf, or any value
        other than exactly ``general`` — it returns ``"repo"`` as the fail-safe
        default so nothing leaks by accident.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Isolate the leading frontmatter block; absent or unterminated frontmatter
    # fails safe to the repo scope so unmarked files are never distributed.
    frontmatter_match = _FRONTMATTER_PATTERN.match(content)
    if frontmatter_match is None:
        return REPO_MEMORY_SCOPE
    frontmatter_body = frontmatter_match.group(1)

    # Locate the metadata mapping; without it there is no scope leaf to read.
    metadata_match = _METADATA_BLOCK_PATTERN.search(frontmatter_body)
    if metadata_match is None:
        return REPO_MEMORY_SCOPE
    metadata_block = metadata_match.group(1)

    # Read the scope leaf from within the metadata block only; a top-level
    # `scope:` outside `metadata:` is intentionally ignored.
    scope_match = _SCOPE_LEAF_PATTERN.search(metadata_block)
    if scope_match is None:
        return REPO_MEMORY_SCOPE

    # Strip surrounding whitespace and optional matching quotes before the
    # exact-match comparison; only an exact `general` is treated as general.
    scope_value = scope_match.group(1).strip()
    if (
        len(scope_value) >= 2
        and scope_value[0] == scope_value[-1]
        and scope_value[0] in {'"', "'"}
    ):
        scope_value = scope_value[1:-1].strip()
    if scope_value == GENERAL_MEMORY_SCOPE:
        return GENERAL_MEMORY_SCOPE
    return REPO_MEMORY_SCOPE


def _is_general_memory_file(relative_path: Path, content: str) -> bool:
    """Return whether a candidate file may be distributed by push-down.

    Purpose:
        Decide inclusion for one source file. Files under
        `.claude/agent-memory/` are distributed only when general-scoped;
        every other file is always distributed and is unaffected by the scope
        filter.

    Args:
        relative_path (Path): The file path relative to the repository root.
        content (str): The full text of the file, used to read the memory
            scope when the path is under the agent-memory subtree.

    Returns:
        bool: ``True`` when the path is outside `.claude/agent-memory/`, or when
        the path is under that subtree and `_read_memory_scope(content)` is
        exactly ``general``. ``False`` only for an agent-memory file whose
        scope is not general (the fail-safe exclusion).

    Raises:
        None.

    Side Effects:
        None.
    """

    # Files outside the agent-memory subtree are always copied; the scope
    # filter never applies to rules, skills, agents, hooks, or settings.
    try:
        relative_path.relative_to(AGENT_MEMORY_RELATIVE_ROOT)
    except ValueError:
        return True
    return _read_memory_scope(content) == GENERAL_MEMORY_SCOPE


class _ExcludingFileSystem:
    """Wrap a PushDownFileSystem and filter specified paths from list_files.

    Purpose:
        Prevent host-specific files (e.g. `settings.local.json`) from being
        included when the publisher enumerates source files, and exclude
        repository-specific agent memories so only general-scoped memories are
        distributed. Chosen over a post-enumeration filter so the exclusion
        travels with the filesystem contract and is transparent to the shared
        engine.

    Usage:
        Instantiate with the inner adapter and exclusion paths relative to
        the repo root; pass the result as the `fs` argument to the engine.

    Invariants / Constraints:
        Excluded paths are resolved once at construction time for O(1) checks.
        The content-based scope filter reads file content only for candidates
        under `.claude/agent-memory/`; all other files skip the read.

    Side Effects:
        Delegates all I/O to the inner adapter.
    """

    def __init__(
        self, inner: PushDownFileSystem, repo_root: Path, excluded: tuple[Path, ...]
    ) -> None:
        """Set up the adapter; resolve exclusion paths relative to repo_root."""
        self._inner = inner
        # Retain the resolved repo root so per-file scope checks can derive the
        # repo-relative path needed by the agent-memory scope filter.
        self._repo_root = repo_root.resolve()
        # Resolve once at init so list_files per-path checks are O(1).
        self._excluded: frozenset[Path] = frozenset(
            (repo_root / p).resolve() for p in excluded
        )

    def _is_scope_included(self, path: Path) -> bool:
        """Return whether a candidate file passes the agent-memory scope filter.

        Purpose:
            Apply the general-vs-repo memory scope decision to one enumerated
            file, reading its content only when the path is under the
            agent-memory subtree.

        Args:
            path (Path): The absolute candidate path returned by the inner
                adapter's ``list_files``.

        Returns:
            bool: ``True`` when the file is outside `.claude/agent-memory/` or
            is a general-scoped memory; ``False`` for a non-general memory.

        Raises:
            None.

        Side Effects:
            Reads file content via the inner adapter for agent-memory
            candidates only.
        """

        # Derive the repo-relative path so the agent-memory check matches the
        # `.claude/agent-memory/` prefix regardless of the absolute location.
        try:
            relative_path = path.resolve().relative_to(self._repo_root)
        except ValueError:
            # A path outside the repo root cannot be an agent memory; include it.
            return True

        # Skip the content read entirely for files outside the memory subtree.
        try:
            relative_path.relative_to(AGENT_MEMORY_RELATIVE_ROOT)
        except ValueError:
            return True

        content = self._inner.read_text(path)
        return _is_general_memory_file(relative_path, content)

    def list_files(self, root: Path) -> list[Path]:
        """Return inner list_files output with excluded paths removed.

        Drops paths in ``EXCLUDED_RELATIVE_PATHS`` and any agent-memory file
        that is not general-scoped per the content-based scope filter.
        """
        return [
            p
            for p in self._inner.list_files(root)
            if p.resolve() not in self._excluded and self._is_scope_included(p)
        ]

    def is_dir(self, path: Path) -> bool:
        """Delegate to inner adapter."""
        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Delegate to inner adapter."""
        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Delegate to inner adapter."""
        return self._inner.read_text(path)

    def write_text(self, path: Path, content: str) -> None:
        """Delegate to inner adapter."""
        self._inner.write_text(path, content)

    def ensure_dir(self, path: Path) -> None:
        """Delegate to inner adapter."""
        self._inner.ensure_dir(path)


def _passthrough_rewrite(
    text: str,
) -> tuple[str, int, int, list[str]]:
    """Return unmodified text for payloads that do not need command rewrites."""

    return text, 0, 0, []


def push_down_customizations(
    *,
    repo_root: Path,
    destination_root: Path,
    fs: PushDownFileSystem,
    source_root: Path | None = None,
    artifact_root: Path | None = None,
) -> PushDownSummary:
    """Copy the `.claude` tree into the destination workspace.

    Excludes paths in `EXCLUDED_RELATIVE_PATHS` by wrapping `fs` in
    `_ExcludingFileSystem` before delegating to the shared engine.
    """

    # Wrap the caller-supplied adapter so enumeration omits excluded paths.
    excluding_fs = _ExcludingFileSystem(fs, repo_root, EXCLUDED_RELATIVE_PATHS)
    return push_down_scoped_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=excluding_fs,
        source_root=source_root,
        artifact_root=artifact_root,
        root_folders=ROOT_FOLDERS,
        artifact_directory=ARTIFACT_DIRECTORY,
        rewrite_references=_passthrough_rewrite,
    )


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments for the Claude customization push-down publisher."""

    parser = argparse.ArgumentParser(
        description=(
            "Publish bundled Claude customizations with "
            f"python -m {MODULE_ENTRY_POINT}."
        )
    )
    parser.add_argument(
        "--destination",
        required=True,
        help=("Destination workspace root that will receive the copied .claude tree."),
    )
    return parser.parse_args(argv)


def main(
    argv: list[str] | None = None,
    *,
    repo_root: Path | None = None,
    fs: PushDownFileSystem | None = None,
) -> int:
    """Run the Claude customization push-down publisher CLI."""

    args = parse_args(argv)
    resolved_repo_root = resolve_cli_path(repo_root or Path.cwd())
    resolved_destination = resolve_cli_path(args.destination)
    resolved_fs = fs or RealPushDownFileSystem()
    summary = push_down_customizations(
        repo_root=resolved_repo_root,
        destination_root=resolved_destination,
        fs=resolved_fs,
        source_root=resolved_repo_root,
        artifact_root=resolved_repo_root,
    )
    print(f"Wrote push-down summary artifact to: {summary.artifact_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
