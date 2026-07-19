"""Structural contract tests for the legacy-discovery workflow skills.

These tests pin the seven domain-neutral ``discovery-*`` workflow-mechanics
skills authored for issue #367. The guarantees are expressed as skill Markdown
text, so the repository's text-fragment contract-test convention (precedent:
``test_epic_run_kickoff_discovery_contract.py``) is the applicable verification
surface. For each skill the tests assert existence, frontmatter well-formedness,
required body fragments (agent slugs, ``dev.discovery.*`` command names, schema
paths, worker-routing sections, and the umbrella Referenced Contracts registry),
absence of the banned domain substrings, non-collision with the
``code-modernization`` plugin name set, and byte-identical presence in the
bundled payload under ``extensions/``.

The module asserts only on this feature's own files. It never asserts the
existence of the upstream #9006 analyzer framework or #9007 agent-role files, so
the suite is green independent of upstream merge order.
"""

from __future__ import annotations

from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_CLAUDE_ROOT = (
    REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"
)

# The seven skill folder names delivered by this feature, in workflow stage
# order. Every table below is keyed by these names.
SKILL_NAMES: tuple[str, ...] = (
    "discovery-workflow",
    "discovery-repo-inventory",
    "discovery-coverage-ledger",
    "discovery-runtime-characterization",
    "discovery-parity-matrix",
    "discovery-behavior-reconciliation",
    "discovery-validate-artifacts",
)


def skill_relative_path(skill_name: str) -> Path:
    """Return the repo-root-relative path to a skill's SKILL.md.

    Args:
        skill_name (str): The skill folder name (for example
            ``discovery-workflow``).

    Returns:
        Path: The ``.claude/skills/<name>/SKILL.md`` relative path.

    Raises:
        None.

    Side Effects:
        None.
    """

    return Path(".claude") / "skills" / skill_name / "SKILL.md"


def read_repo_text(relative_path: Path) -> str:
    """Return UTF-8 text for a repository file addressed relative to the root.

    Args:
        relative_path (Path): Repo-root-relative path to the file to read.

    Returns:
        str: The file's UTF-8 decoded content.

    Raises:
        FileNotFoundError: If the file does not exist at the resolved path.

    Side Effects:
        Reads from the filesystem.
    """

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


# The banned domain substrings (case-insensitive). None may appear in any new
# skill text or its bundle mirror. ``task management`` covers the unhyphenated
# spelling in addition to ``task-management``.
BANNED_SUBSTRINGS: frozenset[str] = frozenset(
    {
        "taskmaster",
        "tmw",
        "outlook",
        "vsto",
        "email",
        "task-management",
        "task management",
    }
)

# The installed ``code-modernization`` plugin command and agent names. No new
# skill name may collide with any entry in this frozen set.
CODE_MODERNIZATION_NAMES: frozenset[str] = frozenset(
    {
        "modernize-assess",
        "modernize-brief",
        "modernize-extract-rules",
        "modernize-harden",
        "modernize-map",
        "modernize-preflight",
        "modernize-reimagine",
        "modernize-status",
        "modernize-transform",
        "modernize-uplift",
        "legacy-analyst",
        "business-rules-extractor",
        "architecture-critic",
        "scaffolder",
        "security-auditor",
        "test-engineer",
        "version-delta-analyst",
    }
)


@pytest.mark.parametrize("skill_name", SKILL_NAMES)
def test_skill_file_exists(skill_name: str) -> None:
    """Require each discovery skill's SKILL.md to exist at its folder path.

    Args:
        skill_name (str): The skill folder name under test.
    """

    # Arrange / Act: resolve the concrete path for the skill's SKILL.md.
    skill_path = REPO_ROOT / skill_relative_path(skill_name)

    # Assert the SKILL.md file is present at the expected location.
    assert skill_path.is_file(), f"missing SKILL.md for skill: {skill_name}"


@pytest.mark.parametrize("skill_name", SKILL_NAMES)
def test_skill_frontmatter_name_matches_folder(skill_name: str) -> None:
    """Require each skill's frontmatter ``name`` to match its folder name.

    Args:
        skill_name (str): The skill folder name under test.
    """

    skill_text = read_repo_text(skill_relative_path(skill_name))

    # The frontmatter name line must match the folder exactly per the SKILL.md
    # contract, so a copy-paste rename mismatch fails this test.
    assert (
        f"name: {skill_name}\n" in skill_text
    ), f"frontmatter name does not match folder for skill: {skill_name}"


@pytest.mark.parametrize("skill_name", SKILL_NAMES)
def test_skill_has_nonempty_single_quoted_description(skill_name: str) -> None:
    """Require each skill to carry a non-empty single-quoted ``description``.

    Args:
        skill_name (str): The skill folder name under test.
    """

    skill_text = read_repo_text(skill_relative_path(skill_name))

    # Locate the description frontmatter line and verify it is single-quoted and
    # carries non-whitespace content between the quotes.
    description_line = _find_description_line(skill_text)
    assert (
        description_line is not None
    ), f"missing description line for skill: {skill_name}"
    assert description_line.startswith(
        "description: '"
    ), f"description is not single-quoted for skill: {skill_name}"
    inner = description_line[len("description: '") :].rstrip()
    assert inner.endswith("'"), f"description quote not closed for skill: {skill_name}"
    assert len(inner[:-1].strip()) > 0, f"description is empty for skill: {skill_name}"


def _find_description_line(skill_text: str) -> str | None:
    """Return the first ``description:`` frontmatter line, or None if absent.

    Args:
        skill_text (str): Full text of a skill's SKILL.md.

    Returns:
        str | None: The stripped description line if present, else None.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Scan each line and return the first that declares the description key.
    for line in skill_text.splitlines():
        if line.startswith("description:"):
            return line.strip()
    return None


# The body-level worker-routing pairings from the decomposition table: each
# agent-stage skill routes to exactly one generic agent slug.
WORKER_ROUTING_PAIRINGS: tuple[tuple[str, str], ...] = (
    ("discovery-coverage-ledger", "migration-coverage-reviewer"),
    ("discovery-runtime-characterization", "runtime-characterization-analyst"),
    ("discovery-parity-matrix", "legacy-parity-analyst"),
    ("discovery-behavior-reconciliation", "requirements-reconciler"),
)

# The full set of nine ``dev.discovery.validate-*`` console-script names plus the
# profile and inventory commands, used by the umbrella and gate assertions.
NINE_VALIDATOR_COMMANDS: tuple[str, ...] = (
    "dev.discovery.validate-profile",
    "dev.discovery.validate-feature-contract",
    "dev.discovery.validate-coverage-ledger",
    "dev.discovery.validate-runtime-scenario",
    "dev.discovery.validate-parity-matrix",
    "dev.discovery.validate-unspecified-behavior",
    "dev.discovery.validate-product-decision",
    "dev.discovery.validate-evidence-reference",
    "dev.discovery.validate-all",
)

# The seven schema paths under ``schemas/discovery/v1/``.
SEVEN_SCHEMA_PATHS: tuple[str, ...] = (
    "schemas/discovery/v1/feature-contract.schema.json",
    "schemas/discovery/v1/coverage-ledger.schema.json",
    "schemas/discovery/v1/runtime-characterization-scenario.schema.json",
    "schemas/discovery/v1/parity-matrix.schema.json",
    "schemas/discovery/v1/unspecified-behavior-record.schema.json",
    "schemas/discovery/v1/product-decision-record.schema.json",
    "schemas/discovery/v1/evidence-reference.schema.json",
)

# Per-skill required ``dev.discovery.*`` command fragments from the decomposition
# table. Each listed command must appear literally in the named skill's text.
REQUIRED_COMMANDS_BY_SKILL: dict[str, tuple[str, ...]] = {
    "discovery-workflow": ("dev.discovery.profile", "dev.discovery.inventory")
    + NINE_VALIDATOR_COMMANDS,
    "discovery-repo-inventory": (
        "dev.discovery.profile",
        "dev.discovery.inventory",
        "dev.discovery.validate-profile",
        "dev.discovery.validate-evidence-reference",
    ),
    "discovery-coverage-ledger": (
        "dev.discovery.validate-feature-contract",
        "dev.discovery.validate-coverage-ledger",
    ),
    "discovery-runtime-characterization": (
        "dev.discovery.validate-runtime-scenario",
        "dev.discovery.validate-evidence-reference",
    ),
    "discovery-parity-matrix": ("dev.discovery.validate-parity-matrix",),
    "discovery-behavior-reconciliation": (
        "dev.discovery.validate-unspecified-behavior",
        "dev.discovery.validate-product-decision",
    ),
    "discovery-validate-artifacts": NINE_VALIDATOR_COMMANDS,
}

# Per-skill required schema-path fragments from the decomposition table.
REQUIRED_SCHEMAS_BY_SKILL: dict[str, tuple[str, ...]] = {
    "discovery-workflow": SEVEN_SCHEMA_PATHS,
    "discovery-coverage-ledger": (
        "schemas/discovery/v1/feature-contract.schema.json",
        "schemas/discovery/v1/coverage-ledger.schema.json",
    ),
    "discovery-runtime-characterization": (
        "schemas/discovery/v1/runtime-characterization-scenario.schema.json",
        "schemas/discovery/v1/evidence-reference.schema.json",
    ),
    "discovery-parity-matrix": (
        "schemas/discovery/v1/parity-matrix.schema.json",
        "schemas/discovery/v1/feature-contract.schema.json",
        "schemas/discovery/v1/runtime-characterization-scenario.schema.json",
    ),
    "discovery-behavior-reconciliation": (
        "schemas/discovery/v1/unspecified-behavior-record.schema.json",
        "schemas/discovery/v1/product-decision-record.schema.json",
    ),
    "discovery-validate-artifacts": SEVEN_SCHEMA_PATHS,
}


@pytest.mark.parametrize(("skill_name", "agent_slug"), WORKER_ROUTING_PAIRINGS)
def test_worker_routing_pairing_present(skill_name: str, agent_slug: str) -> None:
    """Require each agent-stage skill to route to its documented agent slug.

    Args:
        skill_name (str): The agent-stage skill folder name.
        agent_slug (str): The agent slug the skill must route to.
    """

    skill_text = read_repo_text(skill_relative_path(skill_name))

    # A ``## Worker Routing`` section naming the agent slug is the body-level
    # routing convention; both fragments must be present in the same file.
    assert "## Worker Routing" in skill_text, f"missing Worker Routing: {skill_name}"
    assert agent_slug in skill_text, f"{skill_name} does not name slug: {agent_slug}"


@pytest.mark.parametrize("skill_name", sorted(REQUIRED_COMMANDS_BY_SKILL))
def test_required_command_names_present(skill_name: str) -> None:
    """Require each skill to name its ``dev.discovery.*`` commands literally.

    Args:
        skill_name (str): The skill folder name under test.
    """

    skill_text = read_repo_text(skill_relative_path(skill_name))

    # Every command the decomposition table assigns to the skill must appear.
    for command in REQUIRED_COMMANDS_BY_SKILL[skill_name]:
        assert command in skill_text, f"{skill_name} missing command: {command}"


@pytest.mark.parametrize("skill_name", sorted(REQUIRED_SCHEMAS_BY_SKILL))
def test_required_schema_paths_present(skill_name: str) -> None:
    """Require each skill to reference its ``schemas/discovery/v1/`` schemas.

    Args:
        skill_name (str): The skill folder name under test.
    """

    skill_text = read_repo_text(skill_relative_path(skill_name))

    # Every schema path the decomposition table assigns to the skill must appear.
    for schema_path in REQUIRED_SCHEMAS_BY_SKILL[skill_name]:
        assert schema_path in skill_text, f"{skill_name} missing schema: {schema_path}"


def test_umbrella_registry_and_fan_in_flags_present() -> None:
    """Require ``discovery-workflow`` to hold the registry and fan-in flags.

    The umbrella skill must contain the canonical ``## Referenced Contracts``
    registry, the assumed #9006 inventory command, all four #9007 agent slugs,
    and an explicit fan-in reconciliation-assumption flag for both the inventory
    command and the agent slugs.
    """

    skill_text = read_repo_text(skill_relative_path("discovery-workflow"))

    # The canonical registry heading must exist in the umbrella skill only.
    assert "## Referenced Contracts" in skill_text

    # Both assumed upstream names must be present as plain strings.
    assert "dev.discovery.inventory" in skill_text
    for agent_slug in (
        "legacy-parity-analyst",
        "runtime-characterization-analyst",
        "requirements-reconciler",
        "migration-coverage-reviewer",
    ):
        assert agent_slug in skill_text, f"registry missing agent slug: {agent_slug}"

    # Two explicit fan-in assumption flags must be present: one for the inventory
    # command and one for the agent slugs.
    assumption_flags = skill_text.count("Fan-in reconciliation assumption")
    assert (
        assumption_flags >= 2
    ), f"expected two fan-in assumption flags, found {assumption_flags}"


@pytest.mark.parametrize("skill_name", SKILL_NAMES)
def test_banned_substrings_absent(skill_name: str) -> None:
    """Require each skill's text to contain none of the banned substrings.

    Args:
        skill_name (str): The skill folder name under test.
    """

    # Compare against a lowercased copy so the check is case-insensitive.
    skill_text_lower = read_repo_text(skill_relative_path(skill_name)).lower()

    # No banned domain substring may appear anywhere in the skill text.
    for banned in sorted(BANNED_SUBSTRINGS):
        assert (
            banned not in skill_text_lower
        ), f"{skill_name} contains banned substring: {banned}"


@pytest.mark.parametrize("skill_name", SKILL_NAMES)
def test_skill_name_does_not_collide_with_code_modernization(skill_name: str) -> None:
    """Require no new skill name to appear in the code-modernization name set.

    Args:
        skill_name (str): The skill folder name under test.
    """

    # The skill name must be disjoint from the frozen plugin command/agent set.
    assert (
        skill_name not in CODE_MODERNIZATION_NAMES
    ), f"skill name collides with code-modernization name: {skill_name}"


@pytest.mark.parametrize("skill_name", SKILL_NAMES)
def test_skill_is_mirrored_into_bundled_payload(skill_name: str) -> None:
    """Require each skill to be byte-identical in the bundled payload.

    Following the mirroring-assertion pattern of
    ``test_discovery_fix_is_mirrored_into_bundled_payload``, the distributed
    runtime under ``extensions/`` is the copy end users receive, so each skill
    must be present there identically to keep the push-down mirror gate green.

    Args:
        skill_name (str): The skill folder name under test.
    """

    relative_path = skill_relative_path(skill_name)

    # Read both the source and bundled copies and require an exact byte match.
    source_text = read_repo_text(relative_path)
    bundled_text = (BUNDLED_CLAUDE_ROOT / relative_path).read_text(encoding="utf-8")
    assert source_text == bundled_text, f"bundled payload drift: {relative_path}"
