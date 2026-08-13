"""Contract tests for bundled `.codex` / `.agents` customization resources."""

from __future__ import annotations

import json
import re
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
RUNTIME_ONLY_ROOTS: tuple[Path, ...] = (Path(".codex/state"),)
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
PARALLEL_RUNTIME_CONTRACT_FILES = (
    Path(".agents/skills/parallel-add/SKILL.md"),
    Path(".agents/skills/parallel-close/SKILL.md"),
    Path(".agents/skills/parallel-orchestrate/SKILL.md"),
    Path(".agents/skills/parallel-plan/SKILL.md"),
    Path(".agents/skills/parallel-remove/SKILL.md"),
    Path(".agents/skills/parallel-run/SKILL.md"),
    Path(".codex/agents/parallel-orchestrator.toml"),
    Path(".codex/agents/parallel-planner.toml"),
    Path(".codex/hooks/authorize-root-parallel-invocation.ps1"),
    Path(".codex/hooks/codex-authority-store.ps1"),
    Path(".codex/hooks/enforce-codex-model-routing.ps1"),
    Path(".codex/hooks/enforce-completion-consistency.ps1"),
    Path(".codex/hooks/enforce-parallel-abandon-gate.ps1"),
    Path(".codex/hooks/enforce-parallel-child-worktree-binding.ps1"),
    Path(".codex/hooks/enforce-parallel-cohort-barrier.ps1"),
    Path(".codex/hooks/enforce-parallel-drift-gate.ps1"),
    Path(".codex/hooks/enforce-parallel-root-invocation.ps1"),
    Path(".codex/hooks/enforce-parallel-worktree-removal-gate.ps1"),
    Path(".codex/hooks/parallel-hook-common.ps1"),
    Path(".codex/hooks/record-subagent-routing-attestation.ps1"),
    Path(".codex/hooks/validate-codex-subagent-routing.ps1"),
    Path(".codex/hooks/validate-parallel-agent-output.ps1"),
    Path(".codex/scripts/codex-child-launch-contract-core.ps1"),
    Path(".codex/scripts/codex-child-launch-persistence.ps1"),
    Path(".codex/scripts/codex-child-launch-resume.ps1"),
    Path(".codex/scripts/codex-child-launch-runtime.ps1"),
    Path(".codex/scripts/launch-parallel-child-batch.ps1"),
    Path(".codex/scripts/parallel-child-launch-contract.ps1"),
    Path(".codex/scripts/parallel-child-post-session.ps1"),
    Path(".codex/scripts/resume-parallel-child.ps1"),
    Path(".codex/config.toml"),
)
PARALLEL_PERSONA_CONTRACTS = (
    (Path(".codex/agents/parallel-planner.toml"), "parallel-planner-workspace"),
    (
        Path(".codex/agents/parallel-orchestrator.toml"),
        "parallel-orchestrator-workspace",
    ),
)
COMMIT_STEWARD_PROFILE_FILES = tuple(
    Path(f".codex/agents/commit-steward{suffix}.toml")
    for suffix in ("", "-c1", "-c2", "-c3", "-c3-elevated", "-c4")
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
            if not path.is_file():
                continue
            relative_path = path.relative_to(root)
            if any(
                relative_path == runtime_root or runtime_root in relative_path.parents
                for runtime_root in RUNTIME_ONLY_ROOTS
            ):
                continue
            files.append(relative_path)
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


def test_parallel_runtime_contract_has_exact_root_and_bundle_membership() -> None:
    """Require every parallel runtime contract file in source and bundle."""

    root_files = frozenset(list_scoped_files(REPO_ROOT))
    bundled_files = frozenset(list_scoped_files(BUNDLED_ROOT))

    assert len(PARALLEL_RUNTIME_CONTRACT_FILES) == 31
    assert len(set(PARALLEL_RUNTIME_CONTRACT_FILES)) == 31
    for relative_path in PARALLEL_RUNTIME_CONTRACT_FILES:
        assert relative_path in root_files
        assert relative_path in bundled_files
    assert (BUNDLED_ROOT / "AGENTS.md").read_bytes() == (
        REPO_ROOT / "AGENTS.md"
    ).read_bytes()


def test_parallel_persona_prompts_match_profiles_and_generated_bundles() -> None:
    """Require dedicated prompt authority, bundle parity, and Claude write denial."""

    for relative_path, expected_permission in PARALLEL_PERSONA_CONTRACTS:
        assert ".claude" not in relative_path.parts
        assert (REPO_ROOT / relative_path).read_bytes() == (
            BUNDLED_ROOT / relative_path
        ).read_bytes()

        for root in (REPO_ROOT, BUNDLED_ROOT):
            persona = read_toml(root, relative_path)
            assert persona["default_permissions"] == expected_permission
            prompt = persona["developer_instructions"]
            assert isinstance(prompt, str)
            assert f"sandbox authority `{expected_permission}`." in prompt
            assert "sandbox authority `orchestrator-workspace`." not in prompt

            config = read_toml(root, CODEX_CONFIG_PATH)
            permissions = config.get("permissions")
            assert isinstance(permissions, dict)
            profile = cast("dict[str, object]", permissions)[expected_permission]
            assert isinstance(profile, dict)
            filesystem = cast("dict[str, object]", profile)["filesystem"]
            assert isinstance(filesystem, dict)
            roots = cast("dict[str, object]", filesystem)[":workspace_roots"]
            assert isinstance(roots, dict)
            writable_roots = cast("dict[str, object]", roots)
            assert writable_roots[".claude/**"] == "deny"
            assert not any(
                path.startswith(".claude/") and access == "write"
                for path, access in writable_roots.items()
            )


def test_commit_steward_family_has_exact_full_tree_pairing() -> None:
    """Require full-tree publishing to carry exactly the generated family."""

    root_files = frozenset(list_scoped_files(REPO_ROOT))
    bundled_files = frozenset(list_scoped_files(BUNDLED_ROOT))
    root_family = {
        path
        for path in root_files
        if path.parent == Path(".codex/agents")
        and path.stem.startswith("commit-steward")
    }
    bundled_family = {
        path
        for path in bundled_files
        if path.parent == Path(".codex/agents")
        and path.stem.startswith("commit-steward")
    }

    assert len(COMMIT_STEWARD_PROFILE_FILES) == 6
    assert root_family == set(COMMIT_STEWARD_PROFILE_FILES)
    assert bundled_family == set(COMMIT_STEWARD_PROFILE_FILES)
    for relative_path in COMMIT_STEWARD_PROFILE_FILES:
        assert (REPO_ROOT / relative_path).read_bytes() == (
            BUNDLED_ROOT / relative_path
        ).read_bytes()


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


CODEX_LEGACY_VARIANT_FILES: tuple[Path, ...] = (
    Path(".agents-variants/csharp-legacy/skills/csharp/SKILL.md"),
    Path(".agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md"),
)
LEGACY_REQUIRED_SUBSTRINGS: tuple[str, ...] = (
    "dotnet tool run csharpier format .",
    "dotnet tool run csharpier check .",
    "dotnet tool restore",
    "/t:Rebuild /m",
    '"/p:Platform=Any CPU"',
    "/p:TreatWarningsAsErrors=true",
    "#nullable enable",
)
LEGACY_FORBIDDEN_SUBSTRINGS: tuple[str, ...] = (
    "csharpier .",
    "sln /t:Build",
    '/p:Platform="Any CPU"',
)
NULLABLE_SPAN_SCOPE_LITERALS: tuple[str, str] = ("msbuild", "/p:Nullable=enable")
INLINE_CODE_SPAN_PATTERN = re.compile(r"`([^`\n]+)`")


def test_codex_legacy_variant_files_contain_corrected_gate_commands() -> None:
    """Assert both Codex legacy variant files carry the corrected gate commands.

    The corrected `csharp-legacy` gate contract requires the CSharpier
    subcommand forms, the manifest restore step, the `/t:Rebuild /m` local
    build, the whole-argument platform token, the retained warnings-as-errors
    property, and the per-file nullable opt-in marker. Real repository bytes are
    read so the assertion reflects what the push-down engine emits.
    """

    # Arrange: the two canonical Codex variant sources.
    variant_files = CODEX_LEGACY_VARIANT_FILES

    # Act / Assert: every required substring must appear in every variant file.
    for relative_path in variant_files:
        content = read_text(BUNDLED_ROOT, relative_path)
        for required in LEGACY_REQUIRED_SUBSTRINGS:
            assert required in content, (
                f"Required legacy gate substring missing from "
                f"{relative_path}: {required}"
            )


def _spans_with_both_literals(content: str) -> list[str]:
    """Return inline code spans containing both nullable-scope literals.

    Purpose:
        Implement the span-scoped nullable predicate: a documented command lives
        inside a backtick-delimited inline code span, so the guard against
        `/p:Nullable=enable` reaching an MSBuild command line is expressed as a
        conjunction over one span rather than over a whole line or file.

    Args:
        content (str): Full UTF-8 text of a variant file.

    Returns:
        list[str]: Every extracted span that contains both the lowercase
        `msbuild` token and the `/p:Nullable=enable` literal. An empty list
        means the file satisfies the predicate.

    Raises:
        None.

    Side Effects:
        None.
    """

    msbuild_token, nullable_property = NULLABLE_SPAN_SCOPE_LITERALS
    # Matching is case-sensitive on purpose: the lowercase `msbuild` token
    # appears only in command spans, while prose names the product `MSBuild`.
    return [
        span
        for span in INLINE_CODE_SPAN_PATTERN.findall(content)
        if msbuild_token in span and nullable_property in span
    ]


def test_codex_legacy_variant_files_exclude_stale_gate_commands() -> None:
    """Assert both Codex legacy variant files carry no stale gate command form.

    Two distinct scopes apply. The three literals in
    ``LEGACY_FORBIDDEN_SUBSTRINGS`` are file-scoped: they must not appear
    anywhere in either variant file. The `/p:Nullable=enable` guard is
    span-scoped: no backtick-delimited inline code span may contain both
    `msbuild` and `/p:Nullable=enable`, which permits prohibition prose that
    names the property while still forbidding it as a command argument. The
    scan targets only these two files; the Codex default-slot files carry
    pre-existing, out-of-scope stale content and are deliberately not scanned.
    """

    # Arrange: the two canonical Codex variant sources.
    variant_files = CODEX_LEGACY_VARIANT_FILES

    # Act / Assert: file-scoped absence, then the span-scoped nullable predicate.
    for relative_path in variant_files:
        content = read_text(BUNDLED_ROOT, relative_path)
        for forbidden in LEGACY_FORBIDDEN_SUBSTRINGS:
            assert (
                forbidden not in content
            ), f"Stale legacy gate substring present in {relative_path}: {forbidden}"
        offending_spans = _spans_with_both_literals(content)
        assert not offending_spans, (
            f"Inline code span in {relative_path} contains both 'msbuild' and "
            f"'/p:Nullable=enable': {offending_spans}"
        )
