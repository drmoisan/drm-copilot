"""Classify Claude source artifacts for the Codex-native converter.

Purpose:
    Hold the Claude classification path and the shared optional-read helpers
    so ``classifier.py`` stays within the 500-line policy. The GitHub Copilot
    path and the public dispatcher remain in ``classifier.py``.

Usage:
    ``classifier.classify_source_artifact`` calls ``classify_claude`` for
    every Claude artifact returned by the inventory module.

Flow:
    The classifier inspects the normalized relative path, applies the Claude
    routing rules, and emits a ``MappingRecord`` with ``target_path`` still
    unresolved.

Invariants / Constraints:
    Classification is deterministic and path-driven. Only PowerShell helper
    modules under ``.claude/lib`` are an approved native helper surface; every
    other helper resource is marked unsupported and optional rather than
    inferred into a native control.

Side Effects:
    Reads file contents only when necessary to annotate mixed-concern
    artifacts with additional review notes.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    MappingRecord,
    SourceEcosystem,
    SourceKind,
    TargetRole,
)

if TYPE_CHECKING:
    from pathlib import Path

_REPO_WIDE_PATHS_PATTERN = re.compile(r"(?m)^paths:\s*\n\s*-\s*([\"'])?\*\*(?:\1)?\s*$")
# Approved native helper surface: PowerShell modules and scripts the published
# Codex hooks import by name from `.codex/lib/<library>/`.
HELPER_MODULE_SUFFIXES: tuple[str, ...] = (".psm1", ".psd1", ".ps1")
CLAUDE_HELPER_ROOT = ".claude/lib/"


def read_optional_text(source_root: Path, source_path: Path) -> str:
    """Read source text when note generation requires content inspection.

    Purpose:
        Inspect agent manifests for mixed-concern markers such as handoffs
        without making text parsing a hard requirement for every file.

    Args:
        source_root (Path): Absolute or relative source root.
        source_path (Path): Source-root-relative path to inspect.

    Returns:
        str: File contents decoded as UTF-8 when possible; otherwise an empty
        string.

    Raises:
        None.

    Side Effects:
        Reads a source file from disk.
    """

    absolute_path = (source_root.resolve() / source_path).resolve()
    try:
        return absolute_path.read_text(encoding="utf-8")
    except OSError:
        return ""


def has_repo_wide_paths_yaml(source_root: Path, source_path: Path) -> bool:
    """Determine whether one rule file declares repo-wide YAML `paths` scope.

    Purpose:
        Identify Claude rule files whose declared scope is every path in the
        repository so they can merge into standing guidance instead of a skill.

    Args:
        source_root (Path): Absolute or relative source root.
        source_path (Path): Source-root-relative path to inspect.

    Returns:
        bool: True when the rule declares a YAML list-form `paths:` block whose
        only entry is `**`.

    Raises:
        None.

    Side Effects:
        Reads one source file from disk.
    """

    source_text = read_optional_text(source_root, source_path)
    return bool(_REPO_WIDE_PATHS_PATTERN.search(source_text))


def _classify_claude_helper(path_text: str) -> MappingRecord:
    """Classify one `.claude/lib` helper resource.

    Purpose:
        Approve PowerShell helper modules as a direct native helper surface
        (published under `.codex/lib`) while keeping every other helper
        resource, such as bash libraries or documentation, explicitly
        unsupported and optional.

    Args:
        path_text (str): POSIX source-root-relative helper path.

    Returns:
        MappingRecord: The classification result with unresolved target path.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Only PowerShell helpers are importable by the published Codex hooks; a
    # bash library or a README has no native runtime role and must not be
    # represented as a native control.
    if path_text.endswith(HELPER_MODULE_SUFFIXES):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.HOST_ADAPTER_REFERENCE,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.HOOK,
            target_path=None,
            notes=(
                "Shared PowerShell helper publishes verbatim under the native "
                "hook library root.",
            ),
        )
    return MappingRecord(
        source_path=path_text,
        source_ecosystem=SourceEcosystem.CLAUDE,
        source_kind=SourceKind.UNKNOWN,
        conversion_class=ConversionClass.UNSUPPORTED,
        target_role=TargetRole.UNSUPPORTED,
        target_path=None,
        notes=(
            "Helper resources other than PowerShell modules have no native "
            "runtime surface in v1.",
        ),
        is_required=False,
    )


def classify_claude(source_root: Path, source_path: Path) -> MappingRecord:
    """Classify one Claude source artifact.

    Purpose:
        Apply deterministic Claude classification rules for v1 mapping.

    Args:
        source_root (Path): Source root that bounds the artifact.
        source_path (Path): Source-root-relative artifact path.

    Returns:
        MappingRecord: The classification result with unresolved target path.

    Raises:
        None.

    Side Effects:
        May read agent manifests to add review notes for mixed-concern content.
    """

    path_text = source_path.as_posix()
    notes: list[str] = []

    if path_text == "CLAUDE.md":
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.STANDING_INSTRUCTION,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.STANDING_GUIDANCE,
            target_path=None,
        )

    if "/SKILL.md" in path_text and path_text.startswith(".claude/skills/"):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.REUSABLE_SKILL,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.SHARED_SKILL,
            target_path=None,
        )

    if path_text.startswith(".claude/agents/") and path_text.endswith(".md"):
        source_text = read_optional_text(source_root, source_path)
        if "handoff" in source_text.lower() or "agent:" in source_text.lower():
            notes.append(
                "Claude agent manifest may encode orchestration or handoff "
                "semantics that require validation before apply mode."
            )
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.AGENT_MANIFEST,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SUBAGENT,
            target_path=None,
            notes=tuple(notes),
        )

    if path_text.startswith(".claude/hooks/"):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.HOOK_DEFINITION,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.HOOK,
            target_path=None,
        )

    if path_text.startswith(CLAUDE_HELPER_ROOT):
        return _classify_claude_helper(path_text)

    if path_text == ".claude/settings.json":
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.PERMISSIONS_OR_SETTINGS,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.MCP_CONFIG,
            target_path=None,
            notes=(
                "Claude settings require decomposition across native Codex "
                "config, hooks, and approval surfaces.",
            ),
        )

    if path_text.startswith(".claude/rules/") and path_text.endswith(".md"):
        if has_repo_wide_paths_yaml(source_root, source_path):
            return MappingRecord(
                source_path=path_text,
                source_ecosystem=SourceEcosystem.CLAUDE,
                source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
                conversion_class=ConversionClass.DECOMPOSED,
                target_role=TargetRole.STANDING_GUIDANCE,
                target_path=None,
                notes=(
                    "Repo-wide Claude rule applies to all files and merges into "
                    "standing guidance.",
                ),
            )
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SHARED_SKILL,
            target_path=None,
            notes=(
                "Path-scoped Claude rule requires decomposition into shared "
                "skills or standing guidance.",
            ),
        )

    return MappingRecord(
        source_path=path_text,
        source_ecosystem=SourceEcosystem.CLAUDE,
        source_kind=SourceKind.UNKNOWN,
        conversion_class=ConversionClass.UNSUPPORTED,
        target_role=TargetRole.UNSUPPORTED,
        target_path=None,
        notes=("No supported Claude v1 mapping rule matched this artifact.",),
    )
