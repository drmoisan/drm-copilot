"""Contract tests for bundled `.codex` / `.agents` customization resources."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import cast

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
CANONICAL_ROUTING_CONFIG = REPO_ROOT / "config" / "orchestration-routing.json"
SHARED_ROUTING_CONFIG = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "config"
    / "orchestration-routing.json"
)
BUNDLE_ROUTING_CONFIG = BUNDLED_ROOT / "config" / "orchestration-routing.json"
MCP_SERVER_MANIFEST = REPO_ROOT / "packages" / "mcp-server" / "package.json"
SCOPED_ROOTS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))
PACK_MANIFEST_ROOT = Path("pack-manifests")
VARIANT_ROOTS: tuple[Path, ...] = (
    Path(".agents-variants"),
    Path(".codex-variants"),
)
REQUIRED_PACK_MANIFESTS = (
    Path("pack-manifests/core.json"),
    Path("pack-manifests/python.json"),
    Path("pack-manifests/powershell.json"),
    Path("pack-manifests/typescript.json"),
    Path("pack-manifests/csharp-modern.json"),
    Path("pack-manifests/csharp-legacy.json"),
)
REQUIRED_VARIANT_FILES = (
    Path(".agents-variants/csharp-legacy/skills/csharp/SKILL.md"),
    Path(".agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md"),
    Path(".agents-variants/csharp-legacy/skills/invoke-csharp-engineer/SKILL.md"),
    Path(".codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml"),
)
REQUIRED_BUNDLED_FILES = (
    Path(".agents/README.md"),
    Path(".agents/skills/README.md"),
    Path(".agents/skills/atomic-executor/SKILL.md"),
    Path(".agents/skills/atomic-planner/SKILL.md"),
    Path(".agents/skills/orchestrator-workflow/SKILL.md"),
    Path(".agents/skills/repo-automation-adapter/agents/openai.yaml"),
    Path(".codex/config.toml"),
    Path(".codex/agents/atomic-executor.toml"),
    Path(".codex/agents/atomic-planner.toml"),
    Path(".codex/agents/orchestrator.toml"),
    Path(".codex/prompts/generate-pr.md"),
    Path(".codex/prompts/orchestrate-work.md"),
)
CODEX_CONFIG_PATH = Path(".codex/config.toml")
ORCHESTRATOR_ROLE_PATH = Path(".codex/agents/orchestrator.toml")
EXPECTED_DRM_COPILOT_TOOLS = (
    "collect_commit_context",
    "collect_pr_context",
    "run_codex_native_converter",
    "push_down_copilot_customizations",
    "push_down_codex_and_agents_customizations",
    "push_down_claude_customizations",
    "new_potential_bug_entry",
    "new_potential_entry",
    "link_parent_child",
    "potential_to_issue",
    "new_active_feature_folder",
    "run_poshqc_format",
    "run_poshqc_analyze",
    "run_poshqc_test",
    "run_poshqc_analyze_autofix",
    "run_poshqc_suite",
    "resolve_policy_audit_template_asset",
    "resolve_execute_hard_lock_prompt",
    "resolve_atomic_plan_prompt",
    "validate_orchestration_artifacts",
)
APPROVED_DRM_COPILOT_TOOLS = tuple(
    tool
    for tool in EXPECTED_DRM_COPILOT_TOOLS
    if tool
    not in {
        "run_codex_native_converter",
        "push_down_copilot_customizations",
        "push_down_codex_and_agents_customizations",
        "push_down_claude_customizations",
    }
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


def list_bundle_only_files(root: Path) -> list[Path]:
    """Return bundle-only manifest and variant files."""

    files: list[Path] = []
    for scoped_root in (PACK_MANIFEST_ROOT, *VARIANT_ROOTS):
        scoped_path = root / scoped_root
        for path in scoped_path.rglob("*"):
            if path.is_file():
                files.append(path.relative_to(root))
    return sorted(files)


def read_text(root: Path, relative_path: Path) -> str:
    """Return UTF-8 text for a bundled or source payload file."""

    return (root / relative_path).read_text(encoding="utf-8")


def read_toml(root: Path, relative_path: Path) -> dict[str, object]:
    """Return parsed TOML for a bundled or source payload file."""

    return tomllib.loads(read_text(root, relative_path))


def assert_full_drm_copilot_transport(config: dict[str, object]) -> None:
    """Require the complete drm-copilot MCP transport configuration."""

    mcp_version = json.loads(MCP_SERVER_MANIFEST.read_text(encoding="utf-8"))["version"]
    expected_package_spec = f"@danmoisan/drm-copilot-mcp@{mcp_version}"
    mcp_servers = config.get("mcp_servers")
    assert isinstance(mcp_servers, dict)
    mcp_servers_by_name = cast("dict[str, object]", mcp_servers)
    drm_copilot = mcp_servers_by_name.get("drm-copilot")
    assert isinstance(drm_copilot, dict)
    transport = cast("dict[str, object]", drm_copilot)
    assert transport["command"] == "npx"
    assert transport["args"] == ["-y", expected_package_spec]
    assert transport["required"] is True
    enabled_tools = transport["enabled_tools"]
    assert isinstance(enabled_tools, list)
    enabled_tool_values = cast("list[object]", enabled_tools)
    assert all(isinstance(tool, str) for tool in enabled_tool_values)
    enabled_tool_names = [tool for tool in enabled_tool_values if isinstance(tool, str)]
    assert tuple(enabled_tool_names) == EXPECTED_DRM_COPILOT_TOOLS
    tools = transport.get("tools")
    assert isinstance(tools, dict)
    tools_by_name = cast("dict[str, object]", tools)
    assert tuple(sorted(tools_by_name)) == tuple(sorted(APPROVED_DRM_COPILOT_TOOLS))
    for tool_name in APPROVED_DRM_COPILOT_TOOLS:
        tool_settings = tools_by_name.get(tool_name)
        assert isinstance(tool_settings, dict)
        typed_settings = cast("dict[str, object]", tool_settings)
        assert typed_settings["approval_mode"] == "approve"


def assert_no_role_local_drm_copilot_transport(role: dict[str, object]) -> None:
    """Require role TOML files to omit MCP transport configuration."""

    assert "mcp_servers" not in role


def test_bundled_codex_and_agents_payload_contains_required_runtime_files() -> None:
    """Require the bundled payload to include the expected runtime support files."""

    bundled_files = list_scoped_files(BUNDLED_ROOT)

    assert bundled_files
    for relative_path in REQUIRED_BUNDLED_FILES:
        assert relative_path in bundled_files


def test_bundled_codex_pack_manifests_and_variants_exist() -> None:
    """Require Codex manifests and bundle-only C# variant resources."""

    bundled_files = list_bundle_only_files(BUNDLED_ROOT)

    for relative_path in REQUIRED_PACK_MANIFESTS:
        assert relative_path in bundled_files
    for relative_path in REQUIRED_VARIANT_FILES:
        assert relative_path in bundled_files


def test_routing_config_remains_a_shared_resource_outside_codex_bundle() -> None:
    """Require one extension resource source and no Codex-bundle duplicate."""

    assert SHARED_ROUTING_CONFIG.read_bytes() == CANONICAL_ROUTING_CONFIG.read_bytes()
    assert not BUNDLE_ROUTING_CONFIG.exists()


def test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts() -> None:
    """Require the bundled payload to include all repo `.agents` and `.codex` files."""

    bundled_files = list_scoped_files(BUNDLED_ROOT)
    repo_runtime_files = list_scoped_files(REPO_ROOT)
    bundle_only_files = list_bundle_only_files(BUNDLED_ROOT)

    for relative_path in repo_runtime_files:
        assert relative_path not in bundle_only_files
        assert relative_path in bundled_files
        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
            REPO_ROOT,
            relative_path,
        )


def test_codex_config_files_retain_full_drm_copilot_transport() -> None:
    """Require root and bundled Codex configs to retain the MCP transport."""

    assert_full_drm_copilot_transport(read_toml(REPO_ROOT, CODEX_CONFIG_PATH))
    assert_full_drm_copilot_transport(read_toml(BUNDLED_ROOT, CODEX_CONFIG_PATH))


def test_codex_role_files_do_not_retain_drm_copilot_transport() -> None:
    """Require root and bundled Codex roles to omit MCP transport."""

    assert_no_role_local_drm_copilot_transport(
        read_toml(REPO_ROOT, ORCHESTRATOR_ROLE_PATH),
    )
    assert_no_role_local_drm_copilot_transport(
        read_toml(BUNDLED_ROOT, ORCHESTRATOR_ROLE_PATH),
    )
