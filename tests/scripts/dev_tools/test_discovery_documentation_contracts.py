"""Documentation contracts for the legacy discovery and parity capability (issue #980).

The engineering documentation under ``docs/engineering/legacy-discovery-and-parity``
must let a consumer install and operate the capability without a checkout of this
repository. These tests pin the page set, resolvable links, the facts the pages assert
against their sources of truth (console scripts, MCP tools, VS Code commands, schema
kinds, analyzer identifiers, hooks, roles and skills), the required topics, the
criteria-versus-test-pass separation, the planning-prerequisite linkage in the
architecture document and the orchestrator and planner skills, the current skill
mirrors, and the absence of consumer names outside the separated examples. The tests
read committed files only.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

import pytest
import tomllib

REPO_ROOT = Path(__file__).resolve().parents[3]
DOC = REPO_ROOT / "docs" / "engineering" / "legacy-discovery-and-parity"
PAGES: tuple[str, ...] = (
    "README.md",
    "architecture.md",
    "workflow.md",
    "domain-profile.md",
    "artifacts-and-schemas.md",
    "analyzers.md",
    "running-the-workflow.md",
    "cli-reference.md",
    "enforcement.md",
    "migration.md",
    "consumer-onboarding.md",
    "maintainer-guide.md",
)
ROLES = (
    "legacy-parity-analyst",
    "runtime-characterization-analyst",
    "requirements-reconciler",
    "migration-coverage-reviewer",
)
WORKFLOWS = (
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
ALIASES = (
    "discovery-workflow",
    "discovery-repo-inventory",
    "discovery-coverage-ledger",
    "discovery-runtime-characterization",
    "discovery-parity-matrix",
    "discovery-behavior-reconciliation",
    "discovery-validate-artifacts",
)
HOOKS = {
    ".claude/hooks": (
        "record-discovery-agent-start.ps1",
        "enforce-discovery-artifact-gate.ps1",
        "enforce-discovery-planning-gate.ps1",
        "validate-discovery-artifact-gate.ps1",
        "discovery-capability-probe.ps1",
    ),
    ".codex/hooks": (
        "discovery-start-attestation.ps1",
        "enforce-discovery-artifact-gate.ps1",
        "enforce-discovery-planning-gate.ps1",
        "validate-discovery-agent-output.ps1",
        "discovery-capability-probe.ps1",
    ),
    ".github/hooks": (
        "discovery-agent-start.ps1",
        "discovery-pre-tool.ps1",
        "discovery-planning.ps1",
        "discovery-agent-stop.ps1",
        "discovery-capability-probe.ps1",
    ),
}
# Topics the task requires the documentation set to cover, as phrases that must appear.
REQUIRED_TOPICS = (
    "profile_state",
    "schema_version",
    "observation-state",
    "Ownership",
    "Local setup",
    "No runtime",
    "Manual",
    "Combined",
    "Separate",
    "Multi-client",
    "Safe extensions",
    "Evidence and pins",
    "Limits",
    "Supported native controls",
    "Inactive compatibility",
    "Version 1 to version 2",
    "Criteria versus test pass",
    "planning_prerequisite",
)
CONSUMER_NAMES = ("TaskMaster", "TMW")
LINK = re.compile(r"\]\(([^)#\s]+)(#[^)]*)?\)")
MERMAID = re.compile(r"```mermaid\n(.*?)\n```", re.DOTALL)
SKILL_LINKAGE = (
    "completion_gates.planning_prerequisite",
    "docs/engineering/legacy-discovery-and-parity/enforcement.md",
)


def read(relative: str) -> str:
    """Return the UTF-8 text of a repository file."""

    return (REPO_ROOT / relative).read_text(encoding="utf-8")


def page(name: str) -> str:
    """Return the text of one documentation page."""

    return (DOC / name).read_text(encoding="utf-8")


def flat(name: str) -> str:
    """Return a page with every whitespace run collapsed, so wrapped phrases match."""

    return " ".join(page(name).split())


def corpus() -> str:
    """Return the concatenated text of every page."""

    return "\n".join(page(name) for name in PAGES)


def test_every_page_exists_and_is_indexed() -> None:
    """The twelve pages exist and the README links each topic page."""

    readme = page("README.md")
    for name in PAGES:
        assert (DOC / name).is_file(), f"missing documentation page {name}"
        if name != "README.md":
            assert f"]({name})" in readme, f"README does not link {name}"


@pytest.mark.parametrize("name", PAGES)
def test_every_relative_link_resolves(name: str) -> None:
    """Every non-URL link on a page resolves to an existing file or directory."""

    for target, _anchor in LINK.findall(page(name)):
        if "://" in target or target.startswith("mailto:"):
            continue
        resolved = (DOC / target).resolve()
        assert resolved.exists(), f"{name} links to missing target {target}"


def test_architecture_page_carries_a_mermaid_diagram() -> None:
    """The architecture page holds one Mermaid flowchart naming the four components."""

    diagrams = MERMAID.findall(page("architecture.md"))
    assert len(diagrams) == 1
    body = diagrams[0]
    assert body.startswith("flowchart")
    for token in (
        "gateway",
        "Native hooks",
        "Protected authority store",
        "Consumer workspace",
    ):
        assert token in body


def test_cli_reference_lists_every_console_script() -> None:
    """Every console script of the runtime package is documented, and no extra one."""

    project = tomllib.loads(read("packages/discovery-runtime/pyproject.toml"))
    scripts = sorted(project["tool"]["poetry"]["scripts"])
    reference = page("cli-reference.md")
    # Each script appears as its `dev.discovery.` suffix in a table cell.
    for script in scripts:
        suffix = script.removeprefix("dev.discovery.")
        assert f"`{suffix}`" in reference, f"console script {script} is not documented"
    assert len(scripts) == 31
    assert "Thirty-one scripts" in reference


def test_cli_reference_lists_every_discovery_mcp_tool_and_command() -> None:
    """Every discovery MCP tool and VS Code command is documented."""

    names = read("extensions/drm-copilot/src/repo-automation-tool-names.ts")
    tools = [
        token for token in re.findall(r'"([a-z_]+)"', names) if "discovery" in token
    ]
    reference = page("cli-reference.md")
    for tool in tools:
        assert f"`{tool}`" in reference, f"MCP tool {tool} is not documented"
    assert len(tools) == 18
    manifest = json.loads(read("extensions/drm-copilot/package.json"))
    commands = sorted(
        entry["command"]
        for entry in manifest["contributes"]["commands"]
        if "iscovery" in entry["command"]
    )
    assert len(commands) == 13
    for command in commands:
        short = command.removeprefix("drmCopilotExtension.")
        assert f"`{short}`" in reference or f"`{command}`" in reference, command


def test_gateway_operations_and_modes_match_the_service_contract() -> None:
    """The documented operation and mode lists equal the runtime literals."""

    contract = read(
        "packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py"
    )
    operations = re.search(
        r"Operation: TypeAlias = Literal\[(.*?)\]", contract, re.DOTALL
    )
    modes = re.search(r"Mode: TypeAlias = Literal\[(.*?)\]", contract, re.DOTALL)
    assert operations is not None and modes is not None
    reference = page("cli-reference.md")
    for operation in re.findall(r'"([a-z-]+)"', operations.group(1)):
        assert f"`{operation}`" in reference, f"operation {operation} is not documented"
    for mode in re.findall(r'"([a-z-]+)"', modes.group(1)):
        assert f"`{mode}`" in reference, f"mode {mode} is not documented"


def test_artifact_kinds_and_analyzers_match_the_schemas() -> None:
    """Every v2 artifact kind and analyzer identifier is documented."""

    common = json.loads(read("schemas/discovery/v2/common.schema.json"))
    kinds = common["$defs"]["artifact-kind"]["enum"]
    artifacts = page("artifacts-and-schemas.md")
    for kind in kinds:
        assert f"`{kind}`" in artifacts, f"artifact kind {kind} is not documented"
    profile = json.loads(read("schemas/discovery/v2/domain-profile.schema.json"))
    analyzers = profile["$defs"]["analyzers"]["properties"]["enabled"]["items"]["enum"]
    analyzer_page = page("analyzers.md")
    for identifier in analyzers:
        assert f"`{identifier}`" in analyzer_page, f"analyzer {identifier} is missing"
    prerequisite = profile["$defs"]["completion-gates"]["properties"][
        "planning_prerequisite"
    ]["enum"]
    for value in prerequisite:
        assert f"`{value}`" in page("domain-profile.md")


def test_roles_workflows_aliases_and_hooks_are_documented() -> None:
    """The workflow and enforcement pages name every role, skill and hook."""

    workflow = page("workflow.md")
    for name in ROLES + WORKFLOWS + ALIASES:
        assert f"`{name}`" in workflow, f"{name} is not documented"
    enforcement = corpus()
    for folder, hooks in HOOKS.items():
        for hook in hooks:
            assert (REPO_ROOT / folder / hook).is_file(), f"{folder}/{hook} missing"
            assert f"`{hook}`" in enforcement, f"{hook} is not documented"
    for prefix in (
        "DISCOVERY_START_ATTESTATION_BLOCKED:",
        "DISCOVERY_ARTIFACT_GATE_BLOCKED:",
        "DISCOVERY_PLANNING_GATE_BLOCKED:",
    ):
        assert prefix in page("enforcement.md")


def test_required_topics_are_covered() -> None:
    """Each topic the delivery requires appears in the documentation set."""

    text = corpus()
    for topic in REQUIRED_TOPICS:
        assert topic in text, f"topic {topic} is not covered"


def test_criteria_are_separated_from_test_passes() -> None:
    """The documentation never lets framework output assert an implementation pass."""

    artifacts = flat("artifacts-and-schemas.md")
    assert "## Criteria versus test pass" in artifacts
    assert "never claims that a target test passed" in artifacts
    assert "verification_state" in artifacts
    readme = flat("README.md")
    assert "never asserts that a consumer's implementation passes" in readme


def test_consumer_names_appear_only_in_separated_examples() -> None:
    """No topic page names a consumer; examples are the only permitted location."""

    for name in PAGES:
        text = page(name)
        for consumer in CONSUMER_NAMES:
            assert consumer not in text, f"{name} names the consumer {consumer}"


def test_no_checkout_is_required() -> None:
    """Onboarding states that no asset must be copied from this repository."""

    onboarding = flat("consumer-onboarding.md")
    assert "without a checkout of this repository" in onboarding
    assert "no asset must be copied from this repository" in onboarding
    assert "python -I -m pip install" in onboarding


def test_architecture_document_links_the_planning_prerequisite() -> None:
    """The Claude architecture document describes the discovery controls."""

    text = read("docs/engineering/claude-code-architecture.md")
    assert "enforce-discovery-planning-gate.ps1" in text
    assert "completion_gates.planning_prerequisite" in text
    assert "docs/engineering/legacy-discovery-and-parity/enforcement.md" in text


@pytest.mark.parametrize(
    ("skill", "mirror"),
    (
        (
            ".agents/skills/orchestrator-workflow/SKILL.md",
            "extensions/drm-copilot/resources/codex-and-agents-customizations/"
            ".agents/skills/orchestrator-workflow/SKILL.md",
        ),
        (
            ".agents/skills/atomic-planner/SKILL.md",
            "extensions/drm-copilot/resources/codex-and-agents-customizations/"
            ".agents/skills/atomic-planner/SKILL.md",
        ),
        (
            ".claude/skills/orchestrate/SKILL.md",
            "extensions/drm-copilot/resources/claude-customizations/"
            ".claude/skills/orchestrate/SKILL.md",
        ),
    ),
)
def test_orchestration_skills_carry_the_linkage_and_current_mirrors(
    skill: str, mirror: str
) -> None:
    """The orchestrator and planner skills link the prerequisite and are mirrored."""

    text = read(skill)
    for token in SKILL_LINKAGE:
        assert token in text, f"{skill} lacks {token}"
    assert (REPO_ROOT / mirror).read_bytes() == (REPO_ROOT / skill).read_bytes(), mirror


def test_execution_environment_fact_is_unchanged_across_copies() -> None:
    """The execution-environment brief is byte-identical across every committed copy."""

    canonical = read(".github/skills/execution-environment/SKILL.md").encode("utf-8")
    # The committed copies: .claude, .agents and the three bundle mirrors; the packaged
    # mcp-server resources are build output and are not part of the committed set.
    copies = sorted(
        path
        for path in REPO_ROOT.rglob("execution-environment/SKILL.md")
        if not {"node_modules", ".git", "packages"} & set(path.parts)
    )
    assert len(copies) == 6, [str(path) for path in copies]
    for path in copies:
        assert (
            path.read_bytes() == canonical
        ), f"{path} differs from the canonical brief"
