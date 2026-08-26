"""Contract tests for `.claude/rules/` frontmatter scoping and agent preloads.

These tests pin the F2, F3, and F4 halves of issue #559. The Claude Code runtime
loads a rule file on every turn unless its YAML frontmatter carries a ``paths:``
list scoping it, and it injects every ``skills:`` entry of an agent's frontmatter
into that agent's standing context. Both surfaces are plain Markdown, so the
repository's text-and-frontmatter contract-test convention applies (see
``test_epic_run_kickoff_discovery_contract.py``).

Classification rule for the unconditional set: a rule file carrying **no**
frontmatter block counts as unconditional, because with no ``paths:`` scoping the
runtime loads it on every turn. Counting only explicit ``**`` entries would let an
unscoped file hide inside a four-file expectation and would make this module pass
before the fix landed.

Every assertion reads committed repository text only. No test creates, writes, or
removes a file, and no test consults an external service.
"""

from __future__ import annotations

import fnmatch
import re
from pathlib import Path
from typing import cast

import yaml

REPO_ROOT = Path(__file__).resolve().parents[3]
CLAUDE_ROOT = REPO_ROOT / ".claude"
RULES_DIR = CLAUDE_ROOT / "rules"
AGENTS_DIR = CLAUDE_ROOT / "agents"
SKILLS_DIR = CLAUDE_ROOT / "skills"

# `.claude/agent-memory/` is gitignored and machine-local, so its content varies
# per workstation. Excluding it keeps the `.claude/` scan deterministic.
EXCLUDED_CLAUDE_SUBDIRS = frozenset({"agent-memory"})

# A `paths:` entry that matches every file scopes nothing, so a rule carrying one
# loads unconditionally exactly as an unscoped rule does.
UNCONDITIONAL_GLOBS = frozenset({"**", "**/*", "*"})

# The four repository-wide policies whose applicability is genuinely not
# conditioned on file type. Every other rule file must be scoped.
DELIBERATE_UNCONDITIONAL_RULES = frozenset(
    {
        "general-code-change.md",
        "general-unit-test.md",
        "quality-tiers.md",
        "tonality.md",
    }
)

EPIC_ORCHESTRATOR_AGENT = "epic-orchestrator.md"

EPIC_ORCHESTRATOR_EXPECTED_SKILLS = (
    "policy-compliance-order",
    "epic-orchestrate",
    "acceptance-criteria-tracking",
)

# The ten runtime surfaces that write or resume an orchestration checkpoint. The
# `orchestrator-state` rule governs their checkpoint contract, so its `paths:`
# list must reach each of them or the rule is silent where it is needed.
CHECKPOINT_WRITER_SURFACES = (
    ".claude/agents/orchestrator.md",
    ".claude/agents/epic-orchestrator.md",
    ".claude/agents/parallel-orchestrator.md",
    ".claude/agents/epic-planner.md",
    ".claude/agents/parallel-planner.md",
    ".claude/skills/orchestrate/SKILL.md",
    ".claude/skills/epic-orchestrate/SKILL.md",
    ".claude/skills/parallel-orchestrate/SKILL.md",
    ".claude/skills/epic-plan/SKILL.md",
    ".claude/skills/parallel-plan/SKILL.md",
)

# The two runtime entry points that dispatch the plan acceptance gates. A change
# to either can alter gate behavior, so the rule must load for both.
PLAN_GATE_DISPATCHERS = (
    "scripts/dev_tools/validate_orchestration_artifacts.py",
    "extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts",
)

# Both committed copies of the blast-radius truth table. The parallel rule
# carries the contention doctrine that governs their content.
BLAST_RADIUS_CONFIG_SURFACES = (
    "config/blast-radius.json",
    "extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json",
)

# A `spec.md` section citation carrying no feature-folder qualification names a
# document the reader cannot locate, because every feature folder has a
# `spec.md`. The optional backtick absorbs the inline-code delimiter.
UNQUALIFIED_SPEC_SECTION = re.compile(r"spec\.md`?\s*§")


def read_text(path: Path) -> str:
    """Return the UTF-8 text of a repository file.

    Args:
        path (Path): Absolute path to the file to read.

    Returns:
        str: The file's UTF-8 decoded content.

    Raises:
        OSError: If the file cannot be read.

    Side Effects:
        Reads from disk. Writes nothing.
    """

    return path.read_text(encoding="utf-8")


def normalize_whitespace(text: str) -> str:
    """Collapse every whitespace run, including line breaks, to one space.

    Normalizing before searching makes a phrase assertion survive a reflow of the
    target file. A line-oriented search for a multi-word phrase silently returns
    zero matches once the phrase wraps, which turns the assertion into a no-op.

    Args:
        text (str): Raw text, possibly spanning many lines.

    Returns:
        str: The same text with all whitespace runs replaced by single spaces and
        the ends stripped. The function is pure and has no side effects.
    """

    return " ".join(text.split())


def parse_frontmatter(text: str) -> dict[str, object] | None:
    """Parse a document's leading YAML frontmatter block into a mapping.

    Isolates the untyped ``yaml.safe_load`` boundary so callers work against a
    ``dict[str, object]``. A document with no opening fence, no closing fence, or
    a non-mapping block is reported as absent rather than raising, because
    "carries no usable frontmatter" is the condition callers test for.

    Args:
        text (str): Raw document text.

    Returns:
        dict[str, object] | None: The parsed mapping, or ``None`` when the
        document carries no parseable frontmatter mapping. The function is pure
        and has no side effects.
    """

    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None

    # Walk forward to the closing fence; only the block between the fences is
    # YAML, and an unterminated block is treated as absent frontmatter.
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            try:
                parsed = yaml.safe_load("\n".join(lines[1:index]))
            except yaml.YAMLError:
                return None
            if not isinstance(parsed, dict):
                return None
            return cast("dict[str, object]", parsed)
    return None


def string_sequence(value: object) -> tuple[str, ...]:
    """Return the string members of a parsed YAML list value.

    Args:
        value (object): A value read from a parsed frontmatter mapping.

    Returns:
        tuple[str, ...]: The string members in order, or an empty tuple when the
        value is not a list. Non-string members are dropped rather than coerced,
        so a malformed entry cannot masquerade as a declared glob or skill name.
        The function is pure and has no side effects.
    """

    if not isinstance(value, list):
        return ()
    members = cast("list[object]", value)
    # Keep only genuine strings so a nested mapping or a bare number cannot be
    # counted as a declared entry.
    return tuple(member for member in members if isinstance(member, str))


def rule_files() -> tuple[Path, ...]:
    """Return every `.claude/rules/*.md` file in stable alphabetical order.

    Returns:
        tuple[Path, ...]: Absolute paths, sorted so failure messages are stable
        between runs and between machines.

    Side Effects:
        Reads the directory listing. Writes nothing.
    """

    return tuple(sorted(RULES_DIR.glob("*.md")))


def rule_paths(rule_file_name: str) -> tuple[str, ...]:
    """Return the declared ``paths:`` globs of one rule file.

    Args:
        rule_file_name (str): File name inside `.claude/rules/`.

    Returns:
        tuple[str, ...]: The declared globs, or an empty tuple when the file
        carries no parseable frontmatter or no ``paths:`` list.

    Side Effects:
        Reads the named file. Writes nothing.
    """

    mapping = parse_frontmatter(read_text(RULES_DIR / rule_file_name))
    if mapping is None:
        return ()
    return string_sequence(mapping.get("paths"))


def is_unconditional(rule_file: Path) -> bool:
    """Report whether a rule file loads on every turn.

    A file with no parseable frontmatter mapping and a file whose ``paths:`` list
    carries a match-everything glob are both unconditional: neither constrains
    when the runtime injects the rule.

    Args:
        rule_file (Path): Absolute path to a `.claude/rules/*.md` file.

    Returns:
        bool: ``True`` when the file is unconditional in effect.

    Side Effects:
        Reads the named file. Writes nothing.
    """

    mapping = parse_frontmatter(read_text(rule_file))
    if mapping is None:
        return True
    declared = string_sequence(mapping.get("paths"))
    if not declared:
        return True
    return any(glob in UNCONDITIONAL_GLOBS for glob in declared)


def globs_cover(globs: tuple[str, ...], target: str) -> bool:
    """Report whether any declared glob reaches a repo-relative target path.

    ``fnmatch`` is the matcher because its ``*`` crosses path separators, which is
    the behavior a ``**`` segment expresses. That is slightly permissive at a
    segment boundary; the alternative is reimplementing the runtime's own glob
    engine, which the repository does not expose.

    Args:
        globs (tuple[str, ...]): The declared ``paths:`` entries.
        target (str): A repo-relative path with forward slashes.

    Returns:
        bool: ``True`` when the target is an exact member of the declared set or
        is matched by one of its globs. The function is pure and has no side
        effects.
    """

    if target in globs:
        return True
    # Test each declared glob until one reaches the target; an exact literal was
    # already handled above, so only pattern entries can match here.
    return any(fnmatch.fnmatchcase(target, glob) for glob in globs)


def assert_rule_paths_reach(rule_file_name: str, targets: tuple[str, ...]) -> None:
    """Assert one rule file's declared scope reaches every named target.

    Shared by the three scope-coverage tests, which differ only in the rule read
    and the surfaces that rule must reach.

    Args:
        rule_file_name (str): File name inside `.claude/rules/`.
        targets (tuple[str, ...]): Repo-relative paths the rule must reach.

    Returns:
        None. The assertion is the result.

    Raises:
        AssertionError: If any target falls outside the declared scope. The
            message names every unreached target, so one run reports the whole
            gap rather than only its first entry.

    Side Effects:
        Reads the named rule file. Writes nothing.
    """

    declared = rule_paths(rule_file_name)
    unreached = [target for target in targets if not globs_cover(declared, target)]
    assert (
        not unreached
    ), f"`.claude/rules/{rule_file_name}` `paths:` does not reach: " + ", ".join(
        unreached
    )


def claude_markdown_files() -> tuple[Path, ...]:
    """Return every committed Markdown file under `.claude/`.

    Returns:
        tuple[Path, ...]: Absolute paths in sorted order, excluding the
        gitignored, machine-local subdirectories named in
        ``EXCLUDED_CLAUDE_SUBDIRS`` so the scan is deterministic.

    Side Effects:
        Walks the `.claude/` tree. Writes nothing.
    """

    found: list[Path] = []
    # Collect every Markdown document the runtime can inject, skipping the
    # machine-local memory tree whose content is not committed.
    for candidate in sorted(CLAUDE_ROOT.rglob("*.md")):
        relative_parts = candidate.relative_to(CLAUDE_ROOT).parts
        if relative_parts and relative_parts[0] in EXCLUDED_CLAUDE_SUBDIRS:
            continue
        found.append(candidate)
    return tuple(found)


def agent_skill_entries() -> tuple[tuple[str, tuple[str, ...]], ...]:
    """Return each agent file's declared ``skills:`` preload list.

    Returns:
        tuple[tuple[str, tuple[str, ...]], ...]: Pairs of agent file name and the
        skill names that agent preloads, in sorted file order.

    Side Effects:
        Reads every `.claude/agents/*.md` file. Writes nothing.
    """

    entries: list[tuple[str, tuple[str, ...]]] = []
    # Read each agent's frontmatter once and record its preload list so callers
    # do not re-parse the same files.
    for agent_file in sorted(AGENTS_DIR.glob("*.md")):
        mapping = parse_frontmatter(read_text(agent_file))
        declared = () if mapping is None else string_sequence(mapping.get("skills"))
        entries.append((agent_file.name, declared))
    return tuple(entries)


def test_every_claude_rule_carries_parseable_paths_and_description() -> None:
    """Require every rule file to declare a parseable scope and description.

    The runtime reads ``paths:`` to decide when to inject a rule and
    ``description:`` to describe it. A file missing either declares no scope, so
    it is injected on every turn regardless of relevance.
    """

    defects: list[str] = []
    # Check each rule file's frontmatter for the two keys the runtime consumes,
    # accumulating every defect so one run names all offending files.
    for rule_file in rule_files():
        mapping = parse_frontmatter(read_text(rule_file))
        if mapping is None:
            defects.append(f"{rule_file.name}: no parseable YAML frontmatter block")
            continue
        declared = string_sequence(mapping.get("paths"))
        if not declared or any(not glob.strip() for glob in declared):
            defects.append(f"{rule_file.name}: no non-empty `paths:` list")
        description = mapping.get("description")
        if not isinstance(description, str) or not description.strip():
            defects.append(f"{rule_file.name}: no non-empty `description:` scalar")

    assert not defects, "Rule files missing frontmatter contract: " + "; ".join(defects)


def test_unconditional_rule_set_is_exactly_the_four_deliberate_files() -> None:
    """Require exactly four rule files to load unconditionally.

    A file carrying no frontmatter block counts as unconditional because it
    declares no scope and is therefore injected on every turn. Only the four
    repository-wide policies may load that way.
    """

    # Select the rule files that carry no scope, treating an absent frontmatter
    # block and a match-everything glob as the same condition.
    observed = frozenset(
        rule_file.name for rule_file in rule_files() if is_unconditional(rule_file)
    )

    unexpected = sorted(observed - DELIBERATE_UNCONDITIONAL_RULES)
    missing = sorted(DELIBERATE_UNCONDITIONAL_RULES - observed)
    assert (
        not unexpected
    ), "Rule files loading unconditionally that must be scoped: " + ", ".join(
        unexpected
    )
    assert not missing, (
        "Deliberate unconditional rule files that are no longer unconditional: "
        + ", ".join(missing)
    )


def test_orchestrator_state_rule_paths_reach_every_checkpoint_writer() -> None:
    """Require the orchestrator-state rule to reach all ten checkpoint writers.

    The rule states the checkpoint invariants. An agent or skill that writes a
    checkpoint without the rule loaded is authoring against an unstated contract,
    so every writer surface must fall inside the declared scope.
    """

    assert_rule_paths_reach("orchestrator-state.md", CHECKPOINT_WRITER_SURFACES)


def test_plan_acceptance_gates_rule_paths_cover_both_dispatchers() -> None:
    """Require the plan-acceptance-gates rule to reach both gate dispatchers.

    The rule is enforced by validator logic in two runtimes. A change to either
    dispatcher can alter gate behavior, so the rule must load for both.
    """

    assert_rule_paths_reach("plan-acceptance-gates.md", PLAN_GATE_DISPATCHERS)


def test_parallel_orchestration_rule_paths_cover_blast_radius_config() -> None:
    """Require the parallel rule to reach both blast-radius truth tables.

    The rule carries the blast-radius contention doctrine, and that doctrine is
    the reason the two committed copies of the truth table diverge in a
    controlled way. Editing either copy without the rule loaded is the defect the
    doctrine was written to prevent.
    """

    assert_rule_paths_reach("parallel-orchestration.md", BLAST_RADIUS_CONFIG_SURFACES)


def test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file() -> None:
    """Require every agent `skills:` entry to name a real skill file.

    A preload naming a missing skill costs the reader a lookup and tells the
    runtime to inject nothing. This test is the guard that makes removing a
    preload safe: a removal that breaks another agent surfaces here.
    """

    defects: list[str] = []
    # Resolve each declared preload against the skills tree, accumulating every
    # unresolved name so one run reports the full set.
    for agent_name, declared in agent_skill_entries():
        for skill_name in declared:
            if not (SKILLS_DIR / skill_name / "SKILL.md").is_file():
                defects.append(f"{agent_name} -> {skill_name}")

    assert not defects, "Agent preloads that resolve to no skill file: " + ", ".join(
        defects
    )


def test_epic_orchestrator_preloads_exactly_three_skills() -> None:
    """Require the epic orchestrator to preload only its three needed skills.

    Every preload is injected into the agent's standing context on every turn.
    The three retained skills are the ones the agent's own procedure cites; the
    rest are reachable on demand and need not be always-on.
    """

    mapping = parse_frontmatter(read_text(AGENTS_DIR / EPIC_ORCHESTRATOR_AGENT))
    assert (
        mapping is not None
    ), f"`.claude/agents/{EPIC_ORCHESTRATOR_AGENT}` carries no parseable frontmatter"

    declared = string_sequence(mapping.get("skills"))

    assert declared == EPIC_ORCHESTRATOR_EXPECTED_SKILLS, (
        "epic-orchestrator `skills:` must be exactly "
        f"{list(EPIC_ORCHESTRATOR_EXPECTED_SKILLS)}, observed {list(declared)}"
    )


def test_no_unqualified_spec_section_citation_under_claude() -> None:
    """Reject a `spec.md` section citation that names no feature folder.

    Every feature folder in the repository carries a `spec.md`, so a bare citation
    of one plus a section marker points at no locatable document. The search runs
    over whitespace-normalized text so a citation split across a line wrap is
    still found.
    """

    offenders: list[str] = []
    # Scan every injectable Markdown document under `.claude/`, normalizing each
    # one first so a wrapped citation cannot escape the search.
    for markdown_file in claude_markdown_files():
        normalized = normalize_whitespace(read_text(markdown_file))
        if UNQUALIFIED_SPEC_SECTION.search(normalized):
            relative = markdown_file.relative_to(REPO_ROOT)
            offenders.append(str(relative).replace("\\", "/"))

    assert (
        not offenders
    ), "Unqualified `spec.md` section citations remain in: " + ", ".join(offenders)
