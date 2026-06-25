"""Filtering filesystem wrapper for the `.claude` customization push-down.

Purpose:
    Provide the filesystem adapter that presents a filtered, variant-aware view
    of the source `.claude` tree to the shared publisher engine. The entry point
    (`scripts.dev_tools.push_down_claude_customizations`) composes this wrapper
    with the pack-selection helpers and delegates the copy to the shared engine.

Responsibilities:
    - Read the agent-memory scope leaf (`metadata.scope`) from YAML frontmatter
      without a runtime YAML dependency.
    - Decide per-file inclusion for the general-vs-repo memory scope filter.
    - Wrap an inner ``PushDownFileSystem`` to apply host-file exclusions, pack
      selection, C# legacy variant source redirection, and the memory mode.

Usage:
    Instantiated by the push-down entry point with the inner adapter, the source
    root, and the optional selection inputs. The result is passed as the ``fs``
    argument to the shared engine.

Invariants / Constraints:
    - Destination derivation in the engine relies on
      ``source.relative_to(source_root)``; this wrapper preserves the canonical
      destination path while optionally redirecting the read source.
    - The memory scope filter reads file content only for agent-memory
      candidates; all other files skip the read.

Side Effects:
    Delegates all I/O to the inner adapter.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

try:
    from scripts.dev_tools.push_down_claude_pack_selection import (
        CSHARP_CANONICAL_PATHS,
        CSharpVariant,
        MemoryMode,
        resolve_variant_source_path,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_claude_pack_selection import (
        CSHARP_CANONICAL_PATHS,
        CSharpVariant,
        MemoryMode,
        resolve_variant_source_path,
    )

if TYPE_CHECKING:
    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )

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


def read_memory_scope(content: str) -> str:
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


def is_general_memory_file(relative_path: Path, content: str) -> bool:
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
        the path is under that subtree and `read_memory_scope(content)` is
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
    return read_memory_scope(content) == GENERAL_MEMORY_SCOPE


class ExcludingFileSystem:
    """Wrap a PushDownFileSystem with scope, pack, variant, and memory filters.

    Purpose:
        Present a filtered, variant-aware view of the source tree to the shared
        publisher engine so the engine's destination derivation
        (``source.relative_to(source_root)``) stays correct while the actual
        published set, the per-file source content, and the agent-memory
        handling all honor the selected packs, C# variant, and memory mode.

    Responsibilities:
        - Exclude host-specific files (for example `settings.local.json`).
        - Apply the general-vs-repo agent-memory scope filter (unchanged).
        - When a pack selection is active, restrict enumeration to the
          `.claude`-relative destination paths in ``published_paths``.
        - When the legacy C# variant is active, redirect reads of the four
          canonical C# destination paths to the bundle-only legacy source so the
          destination receives legacy content at the canonical path.
        - Apply the memory mode: ``overwrite`` keeps prior behavior, ``skip``
          excludes the entire `.claude/agent-memory/**` subtree, and ``merge``
          excludes only general-scoped memories whose destination file already
          exists.

    Usage:
        Instantiate with the inner adapter, the source root, and the optional
        selection inputs; pass the result as the `fs` argument to the engine.

    Invariants / Constraints:
        Excluded paths are resolved once at construction time for O(1) checks.
        Content reads occur only for agent-memory candidates (scope filter) and
        for legacy variant reads (source redirection). When ``published_paths``
        is ``None`` the pack filter is inert and behavior matches the prior
        publish-everything contract.

    Side Effects:
        Delegates all I/O to the inner adapter.
    """

    def __init__(
        self,
        inner: PushDownFileSystem,
        repo_root: Path,
        excluded: tuple[Path, ...],
        *,
        source_root: Path | None = None,
        destination_root: Path | None = None,
        published_paths: frozenset[str] | None = None,
        csharp_variant: CSharpVariant = "modern",
        memory_mode: MemoryMode = "overwrite",
        variant_root: Path | None = None,
    ) -> None:
        """Set up the adapter and resolve filter inputs against the source root.

        Args:
            inner (PushDownFileSystem): The wrapped adapter performing real I/O.
            repo_root (Path): Repository root used to resolve excluded paths and
                the agent-memory scope prefix.
            excluded (tuple[Path, ...]): Repo-relative paths to always exclude.
            source_root (Path | None): Root the engine enumerates from; defaults
                to ``repo_root``. Used to map between absolute paths and
                `.claude`-relative paths for pack filtering and variant reads.
            destination_root (Path | None): Destination workspace root, required
                for the ``merge`` memory mode's destination-existence check.
            published_paths (frozenset[str] | None): The `.claude`-relative paths
                to publish, or ``None`` to publish everything (no pack filter).
            csharp_variant (CSharpVariant): Selected C# variant; ``"legacy"``
                redirects canonical C# reads to the legacy source.
            memory_mode (MemoryMode): One of ``overwrite``/``merge``/``skip``.
            variant_root (Path | None): Bundle root that holds the legacy variant
                subtree (``.claude-variants/csharp-legacy/``). Defaults to the
                source root when not supplied. The repository CLI passes the
                nested bundle directory; the template passes its bundle root.
        """
        self._inner = inner
        # Retain the resolved repo root so per-file scope checks can derive the
        # repo-relative path needed by the agent-memory scope filter.
        self._repo_root = repo_root.resolve()
        # Keep both the unresolved and resolved source roots. The resolved root
        # is used for relative-path comparisons (so absolute candidate paths
        # match), while the unresolved root is used to build redirected read
        # paths so they live in the same key space the engine enumerated from.
        self._source_root_raw = source_root or repo_root
        self._source_root = self._source_root_raw.resolve()
        # The variant root is the bundle directory that contains the legacy
        # variant subtree; legacy C# reads are redirected beneath it.
        self._variant_root_raw = variant_root or self._source_root_raw
        self._destination_root = destination_root
        self._published_paths = published_paths
        self._csharp_variant: CSharpVariant = csharp_variant
        self._memory_mode: MemoryMode = memory_mode
        # Resolve once at init so list_files per-path checks are O(1).
        self._excluded: frozenset[Path] = frozenset(
            (repo_root / p).resolve() for p in excluded
        )

    def _source_relative_posix(self, path: Path) -> str | None:
        """Return the source-relative POSIX path, or None when outside the root.

        Args:
            path (Path): An absolute candidate path from the inner adapter.

        Returns:
            str | None: The path relative to the source root as a POSIX string,
            or ``None`` when the path is not under the source root.
        """

        try:
            return path.resolve().relative_to(self._source_root).as_posix()
        except ValueError:
            return None

    def _is_pack_included(self, path: Path) -> bool:
        """Return whether a candidate path is in the active published set.

        Args:
            path (Path): An absolute candidate path from the inner adapter.

        Returns:
            bool: ``True`` when no pack filter is active (publish everything) or
            when the path's `.claude`-relative form is in ``published_paths``.
        """

        # A None published set means no --packs was supplied, so the pack filter
        # is inert and every enumerated file is included.
        if self._published_paths is None:
            return True
        relative = self._source_relative_posix(path)
        if relative is None:
            return True
        return relative in self._published_paths

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

        content = self.read_text(path)
        return is_general_memory_file(relative_path, content)

    def _is_memory_mode_included(self, path: Path) -> bool:
        """Return whether a candidate file passes the memory-mode filter.

        Purpose:
            Apply the selected memory mode to agent-memory files. ``overwrite``
            includes every memory (prior behavior); ``skip`` excludes the entire
            agent-memory subtree; ``merge`` excludes only memories whose
            destination file already exists so existing destination memories are
            preserved and new ones are still written.

        Args:
            path (Path): An absolute candidate path from the inner adapter.

        Returns:
            bool: ``True`` when the file should be published under the active
            memory mode; ``False`` when the memory mode excludes it.

        Side Effects:
            For ``merge``, reads destination existence via the inner adapter.
        """

        # Derive the source-relative path so the agent-memory prefix check is
        # independent of the absolute source location.
        relative = self._source_relative_posix(path)
        if relative is None:
            return True

        # Only agent-memory files are affected by the memory mode; all other
        # files are always included regardless of the mode.
        try:
            Path(relative).relative_to(AGENT_MEMORY_RELATIVE_ROOT)
        except ValueError:
            return True

        # Route by memory mode: skip drops all memories; merge keeps only those
        # absent at the destination; overwrite (default) keeps everything.
        if self._memory_mode == "skip":
            return False
        if self._memory_mode == "merge":
            if self._destination_root is None:
                return True
            destination_path = self._destination_root / relative
            # Exclude memories that already exist at the destination so merge
            # never overwrites an existing destination memory file.
            return not self._inner.is_file(destination_path)
        return True

    def _resolve_read_source(self, path: Path) -> Path:
        """Return the actual source path to read for a requested path.

        Purpose:
            Redirect reads of the four canonical C# destination paths to the
            bundle-only legacy source when the legacy variant is selected, so
            the destination receives legacy content at the canonical path.

        Args:
            path (Path): The absolute path the engine asked to read.

        Returns:
            Path: The redirected legacy source path for canonical C# files under
            the legacy variant; otherwise the original ``path`` unchanged.
        """

        # Variant redirection only applies to the legacy C# variant; modern and
        # all non-C# reads pass through unchanged.
        if self._csharp_variant != "legacy":
            return path
        relative = self._source_relative_posix(path)
        if relative is None or relative not in CSHARP_CANONICAL_PATHS:
            return path
        redirected_relative = resolve_variant_source_path(relative, "legacy")
        # The resolver returns a `.claude-variants/csharp-legacy/...` path. Join
        # it under the variant (bundle) root, dropping the leading
        # `.claude-variants` segment which the bundle root already implies via
        # the resolver-produced tail. Build from the unresolved root so the path
        # lives in the same key space the engine enumerated from.
        return self._variant_root_raw / redirected_relative

    def list_files(self, root: Path) -> list[Path]:
        """Return inner list_files output with all active filters applied.

        Drops paths in ``EXCLUDED_RELATIVE_PATHS``, any agent-memory file that
        is not general-scoped, any file outside the active published-pack set,
        and any agent-memory file excluded by the selected memory mode.
        """

        # Apply the four enumeration filters in sequence: hard exclusions, pack
        # selection, agent-memory scope, then memory mode.
        return [
            p
            for p in self._inner.list_files(root)
            if p.resolve() not in self._excluded
            and self._is_pack_included(p)
            and self._is_scope_included(p)
            and self._is_memory_mode_included(p)
        ]

    def is_dir(self, path: Path) -> bool:
        """Delegate to inner adapter."""
        return self._inner.is_dir(path)

    def is_file(self, path: Path) -> bool:
        """Delegate to inner adapter."""
        return self._inner.is_file(path)

    def read_text(self, path: Path) -> str:
        """Read text, redirecting canonical C# reads to the legacy source.

        For the legacy C# variant, a read of a canonical C# destination path is
        served from the bundle-only legacy source; all other reads pass through.
        """
        return self._inner.read_text(self._resolve_read_source(path))

    def write_text(self, path: Path, content: str) -> None:
        """Delegate to inner adapter."""
        self._inner.write_text(path, content)

    def ensure_dir(self, path: Path) -> None:
        """Delegate to inner adapter."""
        self._inner.ensure_dir(path)
