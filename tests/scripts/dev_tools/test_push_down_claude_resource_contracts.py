"""Contract tests for bundled `.claude` customization resources. [expect-fail]

These tests require the bundled `.claude` payload to exist at
`extensions/drm-copilot/resources/claude-customizations/`. That payload
is produced by Phase 9 of the push-down plan. Until Phase 9 completes,
all tests in this file are expected to fail.
"""

from __future__ import annotations

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


def test_bundled_claude_payload_contains_all_repo_runtime_contracts() -> None:
    """Require every repo `.claude` file to exist in the bundle.

    Excludes settings.local.json. Expected to fail until Phase 9 copies
    the .claude tree into the bundled root.
    """

    bundled_files = list_scoped_files(BUNDLED_ROOT)
    # Enumerate all repo .claude files, excluding the local-only settings file.
    repo_runtime_files = [
        f
        for f in list_scoped_files(REPO_ROOT)
        if f != Path(".claude/settings.local.json")
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
