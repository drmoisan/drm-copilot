"""Contract tests for the execution-environment brief (issue #964).

The brief is one byte-identical text in six locations. These tests pin its
copies, its required headings and section content, its preload wiring on the
Claude, Codex, and Copilot surfaces, and that it carries no line-number or
commit-SHA citation. Files are read in place; no file is written.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

from scripts.dev_tools.plan_gate_discrimination import PlanGateReport
from scripts.dev_tools.plan_gate_document import evaluate_document_gates

_REPO_ROOT = Path(__file__).resolve().parents[3]
_RESOURCES = "extensions/drm-copilot/resources"
_BRIEF = ".claude/skills/execution-environment/SKILL.md"
_BRIEF_COPIES = (
    _BRIEF,
    f"{_RESOURCES}/claude-customizations/.claude/skills/execution-environment/SKILL.md",
    ".agents/skills/execution-environment/SKILL.md",
    f"{_RESOURCES}/codex-and-agents-customizations/.agents/skills/"
    "execution-environment/SKILL.md",
    ".github/skills/execution-environment/SKILL.md",
    f"{_RESOURCES}/customizations/.github/skills/execution-environment/SKILL.md",
)
_REQUIRED_HEADINGS = (
    "## Purpose and Maintenance",
    "## Tool Routes by Agent",
    "## Command-Text Restrictions",
    "## PowerShell Route and PoshQC MCP Limits",
    "## Batch Budget",
    "## Hook Execution Context",
    "## MCP Surfaces Run the Installed Extension",
    "## CI Shape and Required Checks",
    "## CI-Only Failure Classes",
    "## Contract Tests That Pin Mirrored Files",
    "## Preflight Defect Classes the Validator Cannot See",
    "## Evidence and Documentation Rules",
    "## Coverage and File-Size Gates",
    "## Test Isolation Checks",
)
_REQUIRED_CONTEXTS = (
    "drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)",
    "drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)",
    "docs-validation / Documentation Validation",
    "poshqc / PowerShell QC",
    "shell-coverage / Shell Coverage (Bats + kcov)",
    "security-scan / Security Scanning",
    "quality-checks7 / Code Quality & Tests (3.10)",
    "quality-checks7 / Code Quality & Tests (3.11)",
    "quality-checks7 / Code Quality & Tests (3.12)",
    "quality-checks7 / Code Quality & Tests (3.13)",
    "build-check / Build Package",
)
_CLAUDE_AGENTS = (
    "task-researcher",
    "atomic-planner",
    "atomic-executor",
    "orchestrator",
)
_CODEX_AGENTS = _CLAUDE_AGENTS
_COPILOT_AGENTS = (
    ".github/agents/atomic_executor.agent.md",
    ".github/agents/atomic_planning.agent.md",
    ".github/agents/task-researcher.agent.md",
    ".github/agents/orchestrator.agent.md",
)
_CONSUMING_NAMES = ("TaskMaster", "No-COM")
_WHITESPACE = re.compile(r"\s+")
_NPM_RUN = re.compile(r"`npm run ([^`]+)`")


def _read(relative_path: str) -> str:
    """Return the UTF-8 text of a committed file."""

    return (_REPO_ROOT / relative_path).read_text(encoding="utf-8")


def _collapse(text: str) -> str:
    """Collapse whitespace runs so wrapped Markdown does not break a search."""

    return _WHITESPACE.sub(" ", text)


def _section(heading: str) -> str:
    """Return the whitespace-collapsed body of one `## ` section of the brief."""

    text = _read(_BRIEF)
    start = text.index(f"\n{heading}\n") + len(heading) + 2
    end = text.find("\n## ", start)
    return _collapse(text[start : end if end != -1 else len(text)])


def _missing(section: str, tokens: tuple[str, ...]) -> list[str]:
    """Return the tokens absent from a section."""

    return [token for token in tokens if token not in section]


def _frontmatter_skills(relative_path: str) -> list[str]:
    """Return the `skills:` list of a Claude agent's YAML frontmatter."""

    frontmatter = _read(relative_path).split("---", 2)[1]
    skills: list[str] = []
    in_skills = False
    for line in frontmatter.splitlines():
        if line.startswith("skills:"):
            in_skills = True
            continue
        if in_skills and line.startswith("  - "):
            skills.append(line[4:].strip().strip('"'))
        elif in_skills:
            break
    return skills


def test_brief_copies_are_byte_identical() -> None:
    """All six brief copies exist and are byte-identical."""

    # Arrange
    canonical = (_REPO_ROOT / _BRIEF).read_bytes()

    # Act
    differing = [
        path for path in _BRIEF_COPIES if (_REPO_ROOT / path).read_bytes() != canonical
    ]

    # Assert
    assert differing == [], f"brief copies differ from the canonical copy: {differing}"


def test_brief_has_required_headings() -> None:
    """The brief carries every required heading, in the specified order."""

    # Arrange
    text = _read(_BRIEF)

    # Act
    positions = [text.find(f"\n{heading}\n") for heading in _REQUIRED_HEADINGS]

    # Assert
    assert -1 not in positions, f"missing headings: {positions}"
    assert positions == sorted(positions), "required headings are out of order"
    assert "updated in the same change that alters any fact it states" in _collapse(
        _read(_BRIEF)
    )


def test_brief_states_isolation_guard_as_runtime_behavior() -> None:
    """The guard is runtime behavior, stated apart from the repository hooks."""

    # Arrange
    section = _section("## Command-Text Restrictions")

    # Act
    missing = _missing(
        section,
        (
            "Worktree isolation guard (Claude Code runtime behavior, not a "
            "repository hook)",
            "`.claude/hooks/validate-bash.ps1`",
            "`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`",
            "No file under `.claude/hooks/` implements this guard",
        ),
    )

    # Assert
    assert missing == [], f"Command-Text Restrictions lacks {missing}"


def test_brief_states_executor_route_and_poshqc_output_limits() -> None:
    """The brief states the executor route and where PowerShell counts come from."""

    # Arrange
    routes = _section("## Tool Routes by Agent")
    poshqc = _section("## PowerShell Route and PoshQC MCP Limits")

    # Act
    missing = _missing(
        routes,
        ("`atomic-executor` has no PowerShell tool", "`sh` launcher", "`SCRATCH`"),
    ) + _missing(
        poshqc,
        (
            "PoshQC MCP results carry no output",
            "`artifacts/pester/pester-junit.xml`",
            "`artifacts/pester/powershell-coverage.xml`",
            "`Invoke-ScriptAnalyzer`",
        ),
    )

    # Assert
    assert missing == [], f"route or PoshQC section lacks {missing}"


def test_brief_batch_budget_section_states_cap_codes_and_exemptions() -> None:
    """The Batch Budget section states the cap, codes, exemption, and visibility."""

    # Arrange
    section = _section("## Batch Budget")

    # Act
    missing = _missing(
        section,
        (
            "fourth distinct non-test PowerShell file",
            "`POWERSHELL_LARGE_PATH_REQUIRED`",
            "`PYTHON_LARGE_PATH_REQUIRED`",
            "`large`, `remediation`, or `preparation`",
            "Bundle mirror copies",
            "count against the cap",
            "resolves inside the worktree root",
            "Files under `SCRATCH`",
            "without consuming a slot",
            "Files written by Bash, by a copy script, or by a generator are not seen",
        ),
    )

    # Assert
    assert missing == [], f"Batch Budget lacks {missing}"


def test_brief_ci_section_names_jobs_and_required_contexts() -> None:
    """The CI section names the job shape, merge_group, and every required context."""

    # Arrange
    section = _section("## CI Shape and Required Checks")

    # Act
    missing = _missing(
        section,
        (
            "`poshqc / PowerShell hook suites (Linux)`",
            "`poshqc / PowerShell QC static`",
            "`poshqc / PowerShell QC shard 1`",
            "the aggregator `poshqc / PowerShell QC`",
            "`merge_group`",
            "ruleset 15241672",
            "2026-10-16",
            "Refresh rule",
            *(f"`{context}`" for context in _REQUIRED_CONTEXTS),
        ),
    )

    # Assert
    assert missing == [], f"CI section lacks {missing}"


def test_brief_is_preloaded_by_four_claude_agents() -> None:
    """The four Claude agents preload the brief through `skills:`."""

    # Arrange / Act
    lacking = [
        agent
        for agent in _CLAUDE_AGENTS
        if "execution-environment"
        not in _frontmatter_skills(f".claude/agents/{agent}.md")
    ]

    # Assert
    assert lacking == [], f"agents without the brief preload: {lacking}"


def test_brief_is_listed_by_codex_base_agents() -> None:
    """The Codex base agents list the brief as a canonical skill."""

    # Arrange / Act
    lacking = [
        agent
        for agent in _CODEX_AGENTS
        if "\n- execution-environment\n" not in _read(f".codex/agents/{agent}.toml")
    ]

    # Assert
    assert lacking == [], f"Codex base agents without the brief: {lacking}"


def test_brief_is_referenced_by_copilot_base_agents() -> None:
    """The Copilot base agents carry the read-first instruction."""

    # Arrange
    instruction = "Read `.github/skills/execution-environment/SKILL.md` first"

    # Act
    lacking = [path for path in _COPILOT_AGENTS if instruction not in _read(path)]

    # Assert
    assert lacking == [], f"Copilot agents without the read-first line: {lacking}"


def test_orchestrate_prerequisites_reference_brief() -> None:
    """The orchestrate skill's Prerequisites section names the brief."""

    # Arrange
    text = _read(".claude/skills/orchestrate/SKILL.md")

    # Act
    start = text.index("## Prerequisites")
    section = text[start : text.index("\n## ", start + 1)]

    # Assert
    assert "`.claude/skills/execution-environment/SKILL.md`" in section


def test_architecture_doc_lists_brief() -> None:
    """The architecture document's mirror table has a row for the brief."""

    # Arrange / Act
    text = _read("docs/engineering/claude-code-architecture.md")

    # Assert
    assert (
        "| `.github/skills/execution-environment/SKILL.md` | "
        "`.claude/skills/execution-environment/SKILL.md` |"
    ) in text


def test_epic_orchestrator_is_unchanged_by_brief_wiring() -> None:
    """The hash-pinned epic orchestrator agent does not preload the brief."""

    # Arrange / Act
    text = _read(".claude/agents/epic-orchestrator.md")

    # Assert
    assert "execution-environment" not in text


def test_brief_has_no_consuming_names() -> None:
    """The brief names no consuming product."""

    # Arrange / Act
    found = [name for name in _CONSUMING_NAMES if name in _read(_BRIEF)]

    # Assert
    assert found == [], f"brief names consuming products: {found}"


def test_brief_has_no_g11_or_g12_findings() -> None:
    """The document gates report no line-number or commit-SHA citation in the brief."""

    # Arrange
    report = PlanGateReport()

    # Act
    evaluate_document_gates(report, _read(_BRIEF))
    citations = [
        message
        for message in report.blocking + report.warnings
        if "line-number citation" in message or "commit-SHA citation" in message
    ]

    # Assert
    assert citations == [], f"brief carries citations: {citations}"


def test_brief_npm_run_tokens_exist_in_package_json() -> None:
    """Every backticked npm script token in the brief exists in the root package."""

    # Arrange
    scripts = set(json.loads(_read("package.json"))["scripts"])

    # Act
    unknown = [
        token for token in _NPM_RUN.findall(_read(_BRIEF)) if token not in scripts
    ]

    # Assert
    assert unknown == [], f"brief names unknown npm scripts: {unknown}"
    assert "vitest" not in _read(_BRIEF).lower()


def test_brief_test_isolation_requires_seeded_pester_shuffle() -> None:
    """The isolation section requires seeded Jest, reversed Python, seeded Pester."""

    # Arrange
    section = _section("## Test Isolation Checks")

    # Act
    missing = _missing(
        section,
        (
            "`node run-jest.cjs --randomize --seed=<n>`",
            "with the seed recorded",
            "reversed-order run of the new or changed Python test modules",
            "seeded shuffled file-order run of the touched Pester suites",
            "at least three seeds",
            "each seed and its file order recorded",
        ),
    )

    # Assert
    assert missing == [], f"Test Isolation Checks lacks {missing}"
