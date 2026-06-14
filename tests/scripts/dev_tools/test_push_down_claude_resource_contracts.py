"""Contract tests for bundled `.claude` customization resources.

These tests require the bundled `.claude` payload to exist at
`extensions/drm-copilot/resources/claude-customizations/`. The payload is
present in the repository, so these tests are expected to pass. The
byte-identical mirror assertion exempts the `.claude/agent-memory/**` subtree,
which is distributed by scope rather than mirrored byte-for-byte.
"""

from __future__ import annotations

import importlib
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_ROOT = (
    REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"
)
SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)
REQUIRED_BUNDLED_FILES = (
    Path(".claude/settings.json"),
    Path(".claude/skills/feature-promotion-lifecycle/SKILL.md"),
    Path(".claude/skills/atomic-plan-contract/SKILL.md"),
    Path(".claude/skills/policy-audit-template-usage/SKILL.md"),
    Path(".claude/skills/execute-hard-lock/SKILL.md"),
    Path(".claude/skills/pr-base-branch-merge-base/SKILL.md"),
    Path(".claude/rules/python.md"),
    Path(".claude/rules/typescript.md"),
    Path(".claude/agents/orchestrator.md"),
)


def list_scoped_files(root: Path) -> list[Path]:
    """Return scoped files in deterministic relative-path order."""

    files: list[Path] = []
    for scoped_root in SCOPED_ROOTS:
        scoped_path = root / scoped_root
        for path in scoped_path.rglob("*"):
            if path.is_file():
                files.append(path.relative_to(root))
    return sorted(files)


def read_text(root: Path, relative_path: Path) -> str:
    """Return UTF-8 text for a bundled or source payload file."""

    return (root / relative_path).read_text(encoding="utf-8")


def test_bundled_claude_payload_contains_required_runtime_files() -> None:
    """Require the bundled payload to include the expected Claude runtime files.

    Expected to fail until Phase 9 copies the .claude tree into the bundled root.
    """

    bundled_files = list_scoped_files(BUNDLED_ROOT)

    assert bundled_files
    # Verify each required anchor file is present in the bundled payload.
    for relative_path in REQUIRED_BUNDLED_FILES:
        assert (
            relative_path in bundled_files
        ), f"Required bundled file missing: {relative_path}"


AGENT_MEMORY_RELATIVE_ROOT = Path(".claude/agent-memory")


def _is_agent_memory_path(relative_path: Path) -> bool:
    """Return whether a scoped relative path lives under `.claude/agent-memory/`.

    Purpose:
        Identify agent-memory files so the byte-identical mirror assertion can
        exempt them: general memories live in the bundle but not at the
        gitignored root `.claude/agent-memory/`, so they cannot be compared
        against a root copy.

    Args:
        relative_path (Path): A `.claude`-scoped path relative to a payload
            root.

    Returns:
        bool: True when the path is under `.claude/agent-memory/`.

    Raises:
        None.

    Side Effects:
        None.
    """

    try:
        relative_path.relative_to(AGENT_MEMORY_RELATIVE_ROOT)
    except ValueError:
        return False
    return True


def test_bundled_claude_payload_contains_all_repo_runtime_contracts() -> None:
    """Require every non-memory repo `.claude` file to exist in the bundle.

    Excludes settings.local.json and the `.claude/agent-memory/**` subtree.
    Agent memories are distributed by scope (general memories live in the
    bundle but not at the gitignored root), so they are not subject to the
    byte-identical mirror assertion.
    """

    bundled_files = list_scoped_files(BUNDLED_ROOT)
    # Enumerate repo .claude files, excluding the local-only settings file and
    # the scope-filtered agent-memory subtree.
    repo_runtime_files = [
        f
        for f in list_scoped_files(REPO_ROOT)
        if f != Path(".claude/settings.local.json") and not _is_agent_memory_path(f)
    ]

    for relative_path in repo_runtime_files:
        assert (
            relative_path in bundled_files
        ), f"Repo file missing from bundle: {relative_path}"
        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
            REPO_ROOT,
            relative_path,
        ), f"Bundle content differs from repo for: {relative_path}"


def test_bundled_claude_payload_excludes_settings_local_json() -> None:
    """Verify settings.local.json is absent from the bundled payload.

    Expected to fail until Phase 9 copies the .claude tree into the bundled root.
    """

    assert not (
        BUNDLED_ROOT / ".claude" / "settings.local.json"
    ).exists(), "settings.local.json must not be present in the bundled payload"


def _frontmatter_declares_scope(content: str) -> bool:
    """Return whether a memory file explicitly declares `metadata.scope`.

    Purpose:
        Distinguish a file that explicitly carries a `metadata.scope` leaf from
        one the parser merely defaulted to `repo`. Used so the parity test can
        require every memory to be explicitly annotated rather than relying on
        the fail-safe default.

    Args:
        content (str): The full text of a bundled memory file.

    Returns:
        bool: True when a `scope:` leaf appears inside the frontmatter metadata
        block.

    Raises:
        None.

    Side Effects:
        None.
    """

    # A memory is explicitly scoped only when a metadata block and a scope leaf
    # are both present in the leading frontmatter.
    return "metadata:" in content and "scope:" in content


def test_bundled_agent_memory_scopes_are_well_formed() -> None:
    """Assert every bundled agent memory carries the required scope marker.

    Every `MEMORY.md` index file must declare `metadata.scope: repo` so an
    index is never distributed and never clobbers a destination's own index.
    Every non-index agent-memory file must declare exactly
    `metadata.scope: general`: repo-specific memories were physically removed
    from the bundle (Option B), so the bundle now holds only general-scoped,
    repository-neutral memories. A non-index file with any scope other than
    `general` (including the fail-safe `repo` default) is rejected so a
    repo-specific memory can never reside in the distributed bundle.
    """

    # Reuse the production scope parser so the test enforces exactly the value
    # the push-down filter reads at runtime.
    module = importlib.import_module(
        "scripts.dev_tools.push_down_claude_customizations"
    )
    agent_memory_root = BUNDLED_ROOT / ".claude" / "agent-memory"

    # Enumerate the entire bundled agent-memory tree so a newly added memory
    # cannot bypass the scope assertion.
    memory_files = sorted(
        path for path in agent_memory_root.rglob("*.md") if path.is_file()
    )
    assert memory_files, "Bundled agent-memory tree must contain memory files."

    # Classify each file by whether it is a MEMORY.md index and assert the
    # required scope for that class. Indexes must be repo-scoped (never
    # distributed); every other memory must be exactly general-scoped.
    for path in memory_files:
        content = path.read_text(encoding="utf-8")
        scope = module._read_memory_scope(content)
        if path.name == "MEMORY.md":
            assert (
                scope == "repo"
            ), f"MEMORY.md index must be scope: repo, got {scope}: {path}"
        else:
            assert _frontmatter_declares_scope(
                content
            ), f"Non-index memory must declare an explicit metadata.scope: {path}"
            assert (
                scope == "general"
            ), f"Non-index bundled memory must be scope: general, got {scope}: {path}"
