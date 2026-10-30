"""Publication contracts for the issue #980 discovery surface across the three bundles.

The canonical sources are the four ``.github/agents`` roles, the sixteen
``.github/skills`` workflows and aliases, the native hooks and the shared
PowerShell helpers. P10-T1 regenerates the Copilot, Claude and Codex bundles
from those sources, and these tests pin the result: every logical role, skill,
hook, tool and resource has an exact native representation on every host, every
bundle byte agrees with its source, every published path is listed in its pack
manifest, and no source-ecosystem or consumer-specific content leaks into the
generated outputs. The tests read committed files only.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]
RESOURCES = REPO_ROOT / "extensions" / "drm-copilot" / "resources"
COPILOT_BUNDLE = RESOURCES / "customizations"
CLAUDE_BUNDLE = RESOURCES / "claude-customizations"
CODEX_BUNDLE = RESOURCES / "codex-and-agents-customizations"
CODEX_SHARED_LIB = RESOURCES / "lib" / "discovery-validation"
TOOL_NAMES_SOURCE = (
    REPO_ROOT / "extensions" / "drm-copilot" / "src" / "repo-automation-tool-names.ts"
)

ROLES: tuple[str, ...] = (
    "legacy-parity-analyst",
    "runtime-characterization-analyst",
    "requirements-reconciler",
    "migration-coverage-reviewer",
)
VARIANT_SUFFIXES: tuple[str, ...] = ("-c1", "-c2", "-c3", "-c3-elevated", "-c4")
WORKFLOWS: tuple[str, ...] = (
    "inventory-legacy-system",
    "extract-feature-contract",
    "characterize-runtime-behavior",
    "reconcile-parity-matrix",
    "review-discovery-coverage",
    "adjudicate-unspecified-behavior",
    "generate-acceptance-scenarios",
    "initialize-discovery-workspace",
    "validate-discovery-artifacts",
)
ALIASES: tuple[str, ...] = (
    "discovery-workflow",
    "discovery-repo-inventory",
    "discovery-coverage-ledger",
    "discovery-runtime-characterization",
    "discovery-parity-matrix",
    "discovery-behavior-reconciliation",
    "discovery-validate-artifacts",
)
SKILLS: tuple[str, ...] = WORKFLOWS + ALIASES
COPILOT_ROOTS: tuple[str, ...] = (
    ".github/agents",
    ".github/hooks",
    ".github/instructions",
    ".github/prompts",
    ".github/skills",
)
CLAUDE_HOOKS: tuple[str, ...] = (
    "discovery-capability-probe.ps1",
    "enforce-discovery-artifact-gate.ps1",
    "enforce-discovery-planning-gate.ps1",
    "record-discovery-agent-start.ps1",
    "validate-discovery-artifact-gate.ps1",
)
CODEX_HOOKS: tuple[str, ...] = (
    "discovery-capability-probe.ps1",
    "discovery-start-attestation.ps1",
    "enforce-discovery-artifact-gate.ps1",
    "enforce-discovery-planning-gate.ps1",
    "validate-discovery-agent-output.ps1",
)
GITHUB_HOOK_HANDLERS: tuple[str, ...] = (
    "discovery-agent-start.ps1",
    "discovery-pre-tool.ps1",
    "discovery-planning.ps1",
    "discovery-agent-stop.ps1",
)
GITHUB_HOOK_FILES: tuple[str, ...] = GITHUB_HOOK_HANDLERS + (
    "discovery-capability-probe.ps1",
    "discovery.json",
)
SHARED_HELPERS: tuple[str, ...] = (
    "DiscoveryAuthority.psd1",
    "DiscoveryAuthority.psm1",
    "DiscoveryAuthorization.psm1",
    "DiscoveryCapability.psm1",
    "DiscoveryEncoding.psm1",
    "DiscoveryManifest.psm1",
    "DiscoveryObservation.psm1",
    "DiscoveryPayload.psm1",
    "DiscoveryPlanning.psm1",
    "DiscoveryRootGrant.psm1",
    "DiscoveryStart.psm1",
    "DiscoveryStartRecord.psm1",
    "DiscoveryStop.psm1",
    "DiscoveryToolRouting.psm1",
)
# The compatibility module is published to the Claude bundle only; the Codex
# shared library carries exactly SHARED_HELPERS.
CLAUDE_ONLY_HELPERS: tuple[str, ...] = ("DiscoveryValidation.psm1",)
# Published hook files that no host configuration registers directly.
UNREGISTERED_HOOK_FILES: frozenset[str] = frozenset(
    {"discovery-capability-probe.ps1", "discovery-start-attestation.ps1"}
)
SOURCE_ECOSYSTEM_MARKERS: tuple[str, ...] = (
    ".github/",
    "drmcopilotextension",
    ".agent.md",
)
CONSUMER_NAMES: tuple[str, ...] = ("TaskMaster", "No-COM")
COPILOT_TOOL = re.compile(r"^  - drmcopilotextension/([A-Za-z0-9_]+)$", re.MULTILINE)
CLAUDE_TOOL = re.compile(r'^  - "mcp__drm-copilot__([A-Za-z0-9_]+)"$', re.MULTILINE)
QUOTED_NAME = re.compile(r'"([a-z][a-z0-9_]+)"')


def _files_under(root: Path) -> list[Path]:
    """Return every file under root as a sorted relative path list."""

    return sorted(path.relative_to(root) for path in root.rglob("*") if path.is_file())


def _assert_mirror(source: Path, target: Path) -> None:
    """Assert the target exists and carries exactly the source bytes."""

    assert source.is_file(), f"canonical source missing: {source}"
    assert target.is_file(), f"published mirror missing: {target}"
    assert target.read_bytes() == source.read_bytes(), f"mirror drift: {target}"


def _manifest_paths(bundle: Path) -> frozenset[str]:
    """Return the path inventory of a bundle's core pack manifest."""

    document = json.loads((bundle / "pack-manifests" / "core.json").read_text("utf-8"))
    return frozenset(document["paths"])


def _registered_tool_names() -> frozenset[str]:
    """Return every quoted tool name in the repo-automation tool-name registry."""

    return frozenset(QUOTED_NAME.findall(TOOL_NAMES_SOURCE.read_text("utf-8")))


@pytest.mark.parametrize("root", COPILOT_ROOTS)
def test_copilot_bundle_mirrors_every_scoped_github_file(root: str) -> None:
    """The Copilot bundle carries every scoped .github file byte-for-byte, no extras."""

    source_root = REPO_ROOT / root
    bundle_root = COPILOT_BUNDLE / root
    sources = _files_under(source_root)
    assert sources, f"empty canonical root {root}"
    # Every canonical file must be published with identical bytes.
    for relative in sources:
        _assert_mirror(source_root / relative, bundle_root / relative)
    orphans = sorted(set(_files_under(bundle_root)) - set(sources))
    assert orphans == [], f"bundle files without a canonical source under {root}"


@pytest.mark.parametrize("role", ROLES)
def test_role_has_exact_native_representation_on_every_host(role: str) -> None:
    """Each role is published as a Copilot agent, Claude persona and Codex family."""

    canonical = REPO_ROOT / ".github" / "agents" / f"{role}.agent.md"
    _assert_mirror(
        canonical, COPILOT_BUNDLE / ".github" / "agents" / f"{role}.agent.md"
    )
    _assert_mirror(
        REPO_ROOT / ".claude" / "agents" / f"{role}.md",
        CLAUDE_BUNDLE / ".claude" / "agents" / f"{role}.md",
    )
    # The Codex base and its five generated variants are published together.
    for suffix in ("",) + VARIANT_SUFFIXES:
        _assert_mirror(
            REPO_ROOT / ".codex" / "agents" / f"{role}{suffix}.toml",
            CODEX_BUNDLE / ".codex" / "agents" / f"{role}{suffix}.toml",
        )
    claude_text = (REPO_ROOT / ".claude" / "agents" / f"{role}.md").read_text("utf-8")
    codex_text = (REPO_ROOT / ".codex" / "agents" / f"{role}.toml").read_text("utf-8")
    # Generated outputs carry no Copilot-ecosystem identifiers or consumer names.
    for marker in SOURCE_ECOSYSTEM_MARKERS:
        assert (
            marker not in claude_text
        ), f"{marker} leaked into the Claude persona of {role}"
    for name in CONSUMER_NAMES:
        assert name not in claude_text and name not in codex_text, f"{name} in {role}"
    assert (
        f".github/agents/{role}.agent.md" in codex_text
    ), "Codex base names its source"


@pytest.mark.parametrize("role", ROLES)
def test_role_tools_resolve_to_registered_mcp_tools(role: str) -> None:
    """The Claude tool list equals the canonical list and names registered MCP tools."""

    canonical = (REPO_ROOT / ".github" / "agents" / f"{role}.agent.md").read_text(
        "utf-8"
    )
    claude_text = (REPO_ROOT / ".claude" / "agents" / f"{role}.md").read_text("utf-8")
    codex_text = (REPO_ROOT / ".codex" / "agents" / f"{role}.toml").read_text("utf-8")
    copilot_ops = COPILOT_TOOL.findall(canonical)
    claude_ops = CLAUDE_TOOL.findall(claude_text)
    assert copilot_ops, f"{role} declares no Copilot tools"
    assert (
        claude_ops == copilot_ops
    ), f"{role} Claude tools differ from the canonical list"
    registered = _registered_tool_names()
    # Every operation a role may call is a registered drm-copilot MCP tool.
    for operation in copilot_ops:
        assert operation in registered, f"{operation} is not a registered MCP tool"
        assert (
            f"mcp__drm-copilot__{operation}" in codex_text
        ), f"{operation} absent from Codex"
    frontmatter = claude_text.split("---", 2)[1]
    # No role keeps a Write grant; artifact writes flow through the MCP tools only.
    assert "Write(" not in frontmatter, f"{role} retains a Write grant"


def test_roles_carry_stop_and_tool_controls_on_every_host() -> None:
    """Each role name and handler is registered by the three host configurations."""

    settings = (REPO_ROOT / ".claude" / "settings.json").read_text("utf-8")
    config = (REPO_ROOT / ".codex" / "config.toml").read_text("utf-8")
    discovery = (REPO_ROOT / ".github" / "hooks" / "discovery.json").read_text("utf-8")
    # Every role must appear in the Claude and Codex matchers, and every event handler
    # must be registered; the capability probe is an operator entry point, not a hook,
    # and the Codex start attestation is dot-sourced by the registered routing hook.
    for role in ROLES:
        assert role in settings, f"{role} missing from .claude/settings.json"
        assert role in config, f"{role} missing from .codex/config.toml"
    for hook in CLAUDE_HOOKS:
        if hook not in UNREGISTERED_HOOK_FILES:
            assert hook in settings, f"{hook} not registered in .claude/settings.json"
    for hook in CODEX_HOOKS:
        if hook not in UNREGISTERED_HOOK_FILES:
            assert hook in config, f"{hook} not registered in .codex/config.toml"
    for handler in GITHUB_HOOK_HANDLERS:
        assert handler in discovery, f"{handler} not registered in discovery.json"


@pytest.mark.parametrize("skill", SKILLS)
def test_skill_is_represented_on_every_host(skill: str) -> None:
    """Each workflow or alias is published for all three hosts with resolved links."""

    canonical = REPO_ROOT / ".github" / "skills" / skill / "SKILL.md"
    _assert_mirror(
        canonical, COPILOT_BUNDLE / ".github" / "skills" / skill / "SKILL.md"
    )
    claude_skill = REPO_ROOT / ".claude" / "skills" / skill / "SKILL.md"
    codex_skill = REPO_ROOT / ".agents" / "skills" / skill / "SKILL.md"
    _assert_mirror(
        claude_skill, CLAUDE_BUNDLE / ".claude" / "skills" / skill / "SKILL.md"
    )
    _assert_mirror(
        codex_skill, CODEX_BUNDLE / ".agents" / "skills" / skill / "SKILL.md"
    )
    claude_text = claude_skill.read_text("utf-8")
    codex_text = codex_skill.read_text("utf-8")
    # Each generated copy points at its own host's files, never at the source host.
    for marker in SOURCE_ECOSYSTEM_MARKERS:
        assert (
            marker not in claude_text
        ), f"{marker} leaked into the Claude skill {skill}"
        assert marker not in codex_text, f"{marker} leaked into the Codex skill {skill}"
    assert (
        ".claude/" not in codex_text
    ), f"Claude path leaked into the Codex skill {skill}"
    # A workflow routes to its role on each host; an alias dispatches to workflows only.
    if skill in WORKFLOWS:
        assert ".codex/agents/" in codex_text, f"{skill} Codex copy routes to no role"
        assert (
            ".claude/agents/" in claude_text
        ), f"{skill} Claude copy routes to no role"
    else:
        assert "/agents/" not in claude_text, f"alias {skill} routes to a role directly"
        assert any(
            f"../{workflow}/SKILL.md" in claude_text for workflow in WORKFLOWS
        ), f"alias {skill} dispatches to no canonical workflow"
    for name in CONSUMER_NAMES:
        assert name not in claude_text and name not in codex_text, f"{name} in {skill}"


def test_native_hooks_and_helpers_are_published_and_listed() -> None:
    """Hooks and helpers are mirrored into their bundles and listed by the manifests."""

    claude_manifest = _manifest_paths(CLAUDE_BUNDLE)
    codex_manifest = _manifest_paths(CODEX_BUNDLE)
    # Claude: hooks and every helper (compatibility module included) mirror and list.
    for hook in CLAUDE_HOOKS:
        _assert_mirror(
            REPO_ROOT / ".claude" / "hooks" / hook,
            CLAUDE_BUNDLE / ".claude" / "hooks" / hook,
        )
        assert (
            f".claude/hooks/{hook}" in claude_manifest
        ), f"{hook} absent from the Claude manifest"
    for helper in SHARED_HELPERS + CLAUDE_ONLY_HELPERS:
        source = REPO_ROOT / ".claude" / "lib" / "discovery-validation" / helper
        _assert_mirror(
            source, CLAUDE_BUNDLE / ".claude" / "lib" / "discovery-validation" / helper
        )
        assert f".claude/lib/discovery-validation/{helper}" in claude_manifest, helper
    # Codex: hooks mirror into the bundle; shared helpers publish via the virtual lib.
    for hook in CODEX_HOOKS:
        _assert_mirror(
            REPO_ROOT / ".codex" / "hooks" / hook,
            CODEX_BUNDLE / ".codex" / "hooks" / hook,
        )
        assert (
            f".codex/hooks/{hook}" in codex_manifest
        ), f"{hook} absent from the Codex manifest"
    for helper in SHARED_HELPERS:
        _assert_mirror(
            REPO_ROOT / ".claude" / "lib" / "discovery-validation" / helper,
            CODEX_SHARED_LIB / helper,
        )
        assert f".codex/lib/discovery-validation/{helper}" in codex_manifest, helper
    assert sorted(path.name for path in CODEX_SHARED_LIB.iterdir()) == sorted(
        SHARED_HELPERS
    )
    # GitHub: the handlers, probe and registration publish through the Copilot bundle.
    for hook in GITHUB_HOOK_FILES:
        _assert_mirror(
            REPO_ROOT / ".github" / "hooks" / hook,
            COPILOT_BUNDLE / ".github" / "hooks" / hook,
        )


def test_generated_discovery_paths_are_listed_in_the_core_manifests() -> None:
    """Every generated role and skill path appears in its bundle's core manifest."""

    claude_manifest = _manifest_paths(CLAUDE_BUNDLE)
    codex_manifest = _manifest_paths(CODEX_BUNDLE)
    # Roles and variants.
    for role in ROLES:
        assert f".claude/agents/{role}.md" in claude_manifest, role
        for suffix in ("",) + VARIANT_SUFFIXES:
            assert (
                f".codex/agents/{role}{suffix}.toml" in codex_manifest
            ), f"{role}{suffix}"
    # Workflows and aliases.
    for skill in SKILLS:
        assert f".claude/skills/{skill}/SKILL.md" in claude_manifest, skill
        assert f".agents/skills/{skill}/SKILL.md" in codex_manifest, skill
