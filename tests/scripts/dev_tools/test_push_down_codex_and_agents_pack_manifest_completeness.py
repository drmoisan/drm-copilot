"""Real-filesystem completeness check for `.codex`/`.agents` pack manifests.

Purpose:
    Codex-side counterpart to `test_push_down_claude_pack_manifest_completeness.py`
    (which itself is the Python-side counterpart to
    `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`,
    issue #279), closing the same manifest-omission gap for the Codex-native
    bundle: `compute_published_paths()` only publishes files listed in a
    selected pack manifest's `paths` array, so a bundled Codex agent, skill,
    or hook that is never added to any manifest is silently dropped from a
    manifest-scoped push-down. This module intentionally reads the real
    bundled `.codex`/`.agents` tree and the real `pack-manifests/*.json`
    files from disk rather than an in-memory fake, so it fails whenever the
    actual bundle and the actual manifests drift apart.

Scope note (issue #372):
    Unlike the Claude-side bundle (three narrow, already-documented
    exceptions), the Codex-side `core.json`/variant manifests were found
    during authoring to have a much larger, pre-existing set of bundled
    agent, hook, and skill files that were never registered in any
    Codex-side manifest. These omissions predate this feature (this
    feature's own Phase 3 mirroring tasks copied zero new Codex-side files;
    see `docs/features/active/2026-07-17-legacy-discovery-publishing-372/`
    `evidence/other/codex-mirror-gap-inventory.2026-07-19T05-36.md`) and are
    unrelated to `legacy-discovery-publishing` (issue #372), which
    only mirrors newly landed discovery-framework assets and does not
    backfill historical Codex-side manifest registration. They are tracked
    below as documented, out-of-scope exceptions, following the same
    convention as `test_push_down_claude_pack_manifest_completeness.py` (itself
    following `claude-pack-manifest-completeness.test.ts`), so this test can
    assert real completeness for any newly bundled Codex asset without
    silently absorbing an unrelated, pre-existing backfill into this change.
    Closing this pre-existing gap is a separate, out-of-scope remediation
    item; see the executor's completion report for issue #372 for the
    reproduction evidence recommending a follow-up remediation cycle.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_CODEX_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
MANIFEST_DIR = BUNDLED_CODEX_ROOT / "pack-manifests"

# Pre-existing, unrelated Codex-side manifest gaps out of scope for issue #372
# (see the module docstring "Scope note"). Verified against the real bundle
# at plan-execution time; a path removed from this set must actually gain a
# manifest entry, and a path added here must be independently justified as
# pre-existing and unrelated, not used to mask a new regression.
PRE_EXISTING_UNRELATED_AGENT_EXCEPTIONS: frozenset[str] = frozenset(
    {
        ".codex/agents/5.1-beast-adjusted.toml",
        ".codex/agents/5.1-thinking-beast-mode-adjusted.toml",
        ".codex/agents/api-architect.toml",
        ".codex/agents/atomic-planning.toml",
        ".codex/agents/commentary-remediation.toml",
        ".codex/agents/commit-steward.toml",
        ".codex/agents/csharp-atomic-executor.toml",
        ".codex/agents/csharp-atomic-planning.toml",
        ".codex/agents/csharp-orchestrator.toml",
        ".codex/agents/epic-review.toml",
        ".codex/agents/expert-nextjs-developer.toml",
        ".codex/agents/expert-react-frontend-engineer.toml",
        ".codex/agents/feature-review.toml",
        ".codex/agents/gpt-5-beast-mode.toml",
        ".codex/agents/hlbpa.toml",
        ".codex/agents/mentor.toml",
        ".codex/agents/powershell-di-unit-test-engineer.toml",
        ".codex/agents/prd.toml",
        ".codex/agents/pytest-unit-test-coding.toml",
        ".codex/agents/python-execution-only-typed.toml",
        ".codex/agents/staged-review.toml",
        ".codex/agents/status-updater.toml",
        ".codex/agents/tdd-green.toml",
        ".codex/agents/tdd-red.toml",
        ".codex/agents/tdd-refactor.toml",
        ".codex/agents/voidbeast-gpt41enhanced.toml",
    }
)

PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS: frozenset[str] = frozenset(
    {
        ".codex/hooks/check-powershell-test-purity.ps1",
        ".codex/hooks/check-python-test-purity.ps1",
        ".codex/hooks/enforce-checkpoint-monotonic.ps1",
        ".codex/hooks/enforce-completion-consistency.ps1",
        ".codex/hooks/enforce-completion-helpers.ps1",
        ".codex/hooks/enforce-evidence-locations.ps1",
        ".codex/hooks/enforce-orchestration-preimplementation-gate.ps1",
        ".codex/hooks/enforce-powershell-batch-budget.ps1",
        ".codex/hooks/enforce-promotion-mcp-only.ps1",
        ".codex/hooks/enforce-python-batch-budget.ps1",
        ".codex/hooks/validate-bash.ps1",
        ".codex/hooks/validate-feature-review-coverage.ps1",
    }
)

PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS: frozenset[str] = frozenset(
    {
        ".agents/skills/architecture-boundaries/SKILL.md",
        ".agents/skills/benchmark-baselines/SKILL.md",
        ".agents/skills/ci-workflows/SKILL.md",
        ".agents/skills/commit-message-conventions/SKILL.md",
        ".agents/skills/commit-message/SKILL.md",
        ".agents/skills/csharp-change-budget-router/SKILL.md",
        ".agents/skills/csharp-orchestration-state-machine/SKILL.md",
        ".agents/skills/execute-hard-lock/SKILL.md",
        ".agents/skills/feature-promotion-lifecycle/SKILL.md",
        ".agents/skills/feature-review-workflow/SKILL.md",
        ".agents/skills/feature-review/SKILL.md",
        ".agents/skills/fill-feature-docs/SKILL.md",
        ".agents/skills/general-code-change/SKILL.md",
        ".agents/skills/general-unit-test/SKILL.md",
        ".agents/skills/human-exception-runbook/SKILL.md",
        ".agents/skills/make-skill-template/SKILL.md",
        ".agents/skills/orchestrator-state/SKILL.md",
        ".agents/skills/policy-audit-template-usage/SKILL.md",
        ".agents/skills/pr-author/SKILL.md",
        ".agents/skills/pr-authoring/SKILL.md",
        ".agents/skills/pr-base-branch-merge-base/SKILL.md",
        ".agents/skills/pr-context-artifacts/SKILL.md",
        ".agents/skills/quality-tiers/SKILL.md",
        ".agents/skills/remediation-handoff-atomic-planner/SKILL.md",
        ".agents/skills/research-issue/SKILL.md",
        ".agents/skills/review-epic/SKILL.md",
        ".agents/skills/review-feature/SKILL.md",
        ".agents/skills/review-staged/SKILL.md",
        ".agents/skills/self-explanatory-code-commenting/SKILL.md",
        ".agents/skills/skill-canonical-location-audit/SKILL.md",
        ".agents/skills/tonality/SKILL.md",
        ".agents/skills/translate-claude-to-codex/SKILL.md",
        ".agents/skills/translate-copilot-to-claude/SKILL.md",
        ".agents/skills/update-status/SKILL.md",
    }
)

PRE_EXISTING_UNRELATED_EXCEPTIONS: frozenset[str] = (
    PRE_EXISTING_UNRELATED_AGENT_EXCEPTIONS
    | PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS
    | PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS
)


def enumerate_bundled_codex_relative_paths() -> list[str]:
    """Enumerate every bundled Codex-relative agent, skill, and hook path.

    Walks the on-disk bundled Codex tree for agent-role files
    (`.codex/agents/*.toml`), hook scripts (`.codex/hooks/*`), and
    Codex-side skill definitions (`.agents/skills/<name>/SKILL.md`),
    returning each as a repo-relative POSIX path string.

    Returns:
        list[str]: Sorted repo-relative POSIX paths found on disk.

    Raises:
        None.

    Side Effects:
        Reads directory entries from the bundled Codex/`.agents` tree on disk.
    """

    results: list[str] = []

    agents_dir = BUNDLED_CODEX_ROOT / ".codex" / "agents"
    # Enumerate every bundled Codex-native agent-role TOML file.
    for entry in sorted(agents_dir.glob("*.toml")):
        results.append(f".codex/agents/{entry.name}")

    hooks_dir = BUNDLED_CODEX_ROOT / ".codex" / "hooks"
    # Enumerate every bundled Codex-side hook script.
    for entry in sorted(hooks_dir.iterdir()):
        if entry.is_file():
            results.append(f".codex/hooks/{entry.name}")

    skills_dir = BUNDLED_CODEX_ROOT / ".agents" / "skills"
    # Enumerate every bundled Codex-side skill folder that carries a
    # SKILL.md definition.
    for entry in sorted(skills_dir.iterdir()):
        if not entry.is_dir():
            continue
        skill_file = entry / "SKILL.md"
        if skill_file.is_file():
            results.append(f".agents/skills/{entry.name}/SKILL.md")

    return sorted(results)


def union_of_manifest_paths() -> frozenset[str]:
    """Parse every `pack-manifests/*.json` file and union their `paths` arrays.

    Returns:
        frozenset[str]: The set of every repo-relative path listed by any
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


def test_bundled_codex_files_are_listed_in_some_pack_manifest() -> None:
    """Require every bundled Codex agent/skill/hook to appear in a manifest.

    Compares the real on-disk bundle against the real manifest union,
    excluding the documented pre-existing exceptions (see module docstring
    "Scope note"), and asserts no other bundled file is silently dropped
    from every pack manifest. This is the assertion that would catch this
    feature's own newly mirrored Codex-side assets, had P3-T1 through P3-T3
    copied any (they copied zero; see the module docstring).
    """

    on_disk_paths = enumerate_bundled_codex_relative_paths()
    manifest_union = union_of_manifest_paths()

    missing = [
        candidate
        for candidate in on_disk_paths
        if candidate not in manifest_union
        and candidate not in PRE_EXISTING_UNRELATED_EXCEPTIONS
    ]

    assert missing == [], f"Bundled Codex files missing from every manifest: {missing}"


def test_no_bundled_codex_file_is_absent_from_disk_and_exception_list() -> None:
    """Assert every documented exception still exists as a real bundled file.

    Guards against the exception list silently growing stale: an exception
    entry that no longer corresponds to an on-disk bundled file would mean
    the file was removed or renamed without updating this test, which could
    mask a real completeness regression for its renamed counterpart.
    """

    on_disk_paths = frozenset(enumerate_bundled_codex_relative_paths())

    stale_exceptions = sorted(
        exception_path
        for exception_path in PRE_EXISTING_UNRELATED_EXCEPTIONS
        if exception_path not in on_disk_paths
    )

    assert stale_exceptions == [], (
        "Documented exceptions no longer exist on disk (stale entries): "
        f"{stale_exceptions}"
    )
