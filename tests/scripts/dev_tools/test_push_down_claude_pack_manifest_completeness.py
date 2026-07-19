"""Real-filesystem completeness check for `.claude` pack manifests.

Purpose:
    Python/Codex-side counterpart to
    `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
    (issue #279). `compute_published_paths()` only publishes files listed in a
    selected pack manifest's `paths` array, so a bundled `.claude` agent,
    skill, or hook that is never added to any manifest is silently dropped
    from a manifest-scoped push-down. Unlike the sibling contract tests in
    this directory, this module intentionally reads the real bundled
    `.claude` tree and the real `pack-manifests/*.json` files from disk rather
    than an in-memory fake, so it fails whenever the actual bundle and the
    actual manifests drift apart.

Scope note:
    Three bundled files (`.claude/agents/pr-author.md`,
    `.claude/hooks/enforce-completion-helpers.ps1`,
    `.claude/hooks/validate-pr-author-output.ps1`) were already absent from
    every pack manifest before issue #279 and are unrelated to this feature
    (issue #372). They are tracked as pre-existing, out-of-scope exceptions
    below, reusing the identical exception set as the TypeScript twin, so
    this test can assert real completeness without silently absorbing an
    unrelated production fix into this change.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_CLAUDE_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "claude-customizations"
    / ".claude"
)
MANIFEST_DIR = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "claude-customizations"
    / "pack-manifests"
)

# Pre-existing, unrelated manifest gaps out of scope for issue #279, identical to
# the exception set in the TypeScript twin `claude-pack-manifest-completeness.test.ts`.
PRE_EXISTING_UNRELATED_EXCEPTIONS: frozenset[str] = frozenset(
    {
        ".claude/agents/pr-author.md",
        ".claude/hooks/enforce-completion-helpers.ps1",
        ".claude/hooks/validate-pr-author-output.ps1",
    }
)


def enumerate_bundled_claude_relative_paths() -> list[str]:
    """Enumerate every bundled `.claude`-relative agent, skill, and hook path.

    Walks the on-disk bundled `.claude` tree for agent persona files
    (`agents/*.md`), hook scripts (`hooks/*`), and skill definitions
    (`skills/<name>/SKILL.md`), returning each as a `.claude`-relative POSIX
    path string.

    Returns:
        list[str]: Sorted `.claude`-relative POSIX paths found on disk.

    Raises:
        None.

    Side Effects:
        Reads directory entries from the bundled `.claude` tree on disk.
    """

    results: list[str] = []

    agents_dir = BUNDLED_CLAUDE_ROOT / "agents"
    # Enumerate every bundled agent-persona markdown file.
    for entry in sorted(agents_dir.glob("*.md")):
        results.append(f".claude/agents/{entry.name}")

    hooks_dir = BUNDLED_CLAUDE_ROOT / "hooks"
    # Enumerate every bundled hook script (no extension filter: hooks may be
    # `.ps1` or other executable script types).
    for entry in sorted(hooks_dir.iterdir()):
        if entry.is_file():
            results.append(f".claude/hooks/{entry.name}")

    skills_dir = BUNDLED_CLAUDE_ROOT / "skills"
    # Enumerate every bundled skill folder that carries a SKILL.md definition.
    for entry in sorted(skills_dir.iterdir()):
        if not entry.is_dir():
            continue
        skill_file = entry / "SKILL.md"
        if skill_file.is_file():
            results.append(f".claude/skills/{entry.name}/SKILL.md")

    return sorted(results)


def union_of_manifest_paths() -> frozenset[str]:
    """Parse every `pack-manifests/*.json` file and union their `paths` arrays.

    Returns:
        frozenset[str]: The set of every `.claude`-relative path listed by any
        manifest file in `MANIFEST_DIR`.

    Raises:
        None.

    Side Effects:
        Reads and parses every `*.json` file under `MANIFEST_DIR`.
    """

    union: set[str] = set()
    # Union the `paths` array of every manifest file so a path registered in
    # any single manifest counts as covered.
    for manifest_file in sorted(MANIFEST_DIR.glob("*.json")):
        loaded: object = json.loads(manifest_file.read_text(encoding="utf-8"))
        if not isinstance(loaded, dict):
            continue
        # Treat the decoded mapping as untyped JSON values; each leaf is
        # narrowed explicitly below.
        parsed = cast("dict[str, object]", loaded)
        paths = parsed.get("paths")
        if not isinstance(paths, list):
            continue
        raw_paths = cast("list[object]", paths)
        for candidate in raw_paths:
            if isinstance(candidate, str):
                union.add(candidate)
    return frozenset(union)


def test_bundled_claude_files_are_listed_in_some_pack_manifest() -> None:
    """Require every bundled `.claude` agent/skill/hook to appear in a manifest.

    Compares the real on-disk bundle against the real manifest union,
    excluding the three documented pre-existing exceptions, and asserts no
    other bundled file is silently dropped from every pack manifest.
    """

    on_disk_paths = enumerate_bundled_claude_relative_paths()
    manifest_union = union_of_manifest_paths()

    missing = [
        candidate
        for candidate in on_disk_paths
        if candidate not in manifest_union
        and candidate not in PRE_EXISTING_UNRELATED_EXCEPTIONS
    ]

    assert (
        missing == []
    ), f"Bundled .claude files missing from every manifest: {missing}"


def test_documented_exceptions_remain_absent_from_every_manifest() -> None:
    """Assert the documented pre-existing exceptions still describe reality.

    Guards against the exception list silently growing stale: if a documented
    exception is later added to a manifest, this test should be updated to
    remove it from `PRE_EXISTING_UNRELATED_EXCEPTIONS` rather than leaving a
    stale, overly permissive exception in place.
    """

    manifest_union = union_of_manifest_paths()

    for exception_path in sorted(PRE_EXISTING_UNRELATED_EXCEPTIONS):
        assert exception_path not in manifest_union, (
            f"Documented exception {exception_path} is now present in a "
            "manifest; remove it from PRE_EXISTING_UNRELATED_EXCEPTIONS."
        )
