"""Documentation-parity tests for the required checkpoint keys (issue #798).

Purpose:
    ``REQUIRED_STATE_KEYS`` in ``scripts/dev_tools/validate_orchestrator_state.py``
    names the top-level keys that plain validation requires in an orchestrator
    checkpoint. These tests pin that tuple, in both directions, to the
    ``## Required Top-Level Keys`` section of
    ``.claude/rules/orchestrator-state.md``. They also pin the related
    statements in the orchestrate skill, in the orchestrator agent persona, and
    in the rule's ``## Bare-Module CLI Contract``.

Invariants / Constraints:
    Committed documents are read in place. No file is created, no process is
    started, and no external service is consulted. Phrase checks run over
    whitespace-collapsed section text, so a reflow cannot break them.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.validate_orchestrator_state import REQUIRED_STATE_KEYS

if TYPE_CHECKING:
    from collections.abc import Iterable

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
RULE = REPO_ROOT / ".claude" / "rules" / "orchestrator-state.md"
SKILL = REPO_ROOT / ".claude" / "skills" / "orchestrate" / "SKILL.md"
AGENT = REPO_ROOT / ".claude" / "agents" / "orchestrator.md"

REQUIRED_KEYS_HEADING = "## Required Top-Level Keys"
PRECEDING_HEADING = "## Foreign Schema Warning (do not copy verbatim)"
FOLLOWING_HEADING = "## Scope and Backward Compatibility"
KEY_BULLET = re.compile(r"^- `([^`]+)`")


def read_lines(path: Path) -> list[str]:
    """Return the lines of a committed document, read in place."""

    return path.read_text(encoding="utf-8").splitlines()


def heading_index(lines: list[str], heading: str) -> int | None:
    """Return the index of the line equal to ``heading``, or ``None``."""

    return next(
        (index for index, line in enumerate(lines) if line.strip() == heading), None
    )


def section(path: Path, heading: str) -> str:
    """Return the body of ``heading`` up to the next level-2 heading.

    An empty string is returned when the heading is absent.
    """

    lines = read_lines(path)
    start = heading_index(lines, heading)
    if start is None:
        return ""
    body: list[str] = []
    for line in lines[start + 1 :]:
        if line.startswith("## "):
            break
        body.append(line)
    return "\n".join(body)


def collapse(text: str) -> str:
    """Collapse every run of whitespace to one space."""

    return " ".join(text.split())


def documented_keys(section_text: str) -> list[str]:
    """Return the key named by each backticked bullet, in document order."""

    keys: list[str] = []
    for line in section_text.splitlines():
        match = KEY_BULLET.match(line)
        if match is not None:
            keys.append(match.group(1))
    return keys


def compare_key_sets(
    required: Iterable[str], documented: Iterable[str]
) -> tuple[list[str], list[str]]:
    """Return the undocumented required keys and the documented extra keys."""

    required_set = set(required)
    documented_set = set(documented)
    return sorted(required_set - documented_set), sorted(documented_set - required_set)


def rule_keys() -> list[str]:
    """Return the keys documented in the rule's required-keys section."""

    return documented_keys(section(RULE, REQUIRED_KEYS_HEADING))


@pytest.mark.parametrize("key", REQUIRED_STATE_KEYS)
def test_required_key_is_documented_in_rule(key: str) -> None:
    """Each key the validator requires is a backticked bullet in the rule."""

    # Act
    keys = rule_keys()

    # Assert
    assert key in keys, f"`{key}` missing from {REQUIRED_KEYS_HEADING}"


def test_rule_documented_keys_equal_required_state_keys() -> None:
    """The rule lists exactly the required keys, each once."""

    # Act
    keys = rule_keys()
    undocumented, extra = compare_key_sets(REQUIRED_STATE_KEYS, keys)

    # Assert
    assert keys, f"{REQUIRED_KEYS_HEADING} lists no keys"
    assert undocumented == [], f"required keys missing from the rule: {undocumented}"
    assert extra == [], f"rule lists keys the validator does not require: {extra}"
    assert len(keys) == len(set(keys)), "each key must be listed once"


def test_parity_comparison_detects_undocumented_and_extra_keys() -> None:
    """The comparison reports a key on either side that the other lacks."""

    # Arrange
    required = list(REQUIRED_STATE_KEYS)

    # Act
    undocumented_case = compare_key_sets([*required, "synthetic_required"], required)
    extra_case = compare_key_sets(required, [*required, "synthetic_documented"])
    matching_case = compare_key_sets(required, list(reversed(required)))

    # Assert
    assert undocumented_case == (["synthetic_required"], []), "missing key not found"
    assert extra_case == ([], ["synthetic_documented"]), "extra key not found"
    assert matching_case == ([], []), "equal sets must report no mismatch"


def test_required_keys_section_sits_between_foreign_schema_and_scope_sections() -> None:
    """The new section follows the foreign-schema warning and precedes scope."""

    # Arrange
    lines = read_lines(RULE)

    # Act
    preceding = heading_index(lines, PRECEDING_HEADING)
    current = heading_index(lines, REQUIRED_KEYS_HEADING)
    following = heading_index(lines, FOLLOWING_HEADING)

    # Assert
    assert preceding is not None, f"{PRECEDING_HEADING} heading missing"
    assert current is not None, f"{REQUIRED_KEYS_HEADING} heading missing"
    assert following is not None, f"{FOLLOWING_HEADING} heading missing"
    assert preceding < current < following, "required-keys section is out of place"


def test_rule_section_names_authority_and_check_semantics() -> None:
    """The section names the authority, both ports, and the check semantics."""

    # Act
    text = collapse(section(RULE, REQUIRED_KEYS_HEADING))

    # Assert
    for phrase in (
        "`REQUIRED_STATE_KEYS`",
        "`scripts/dev_tools/validate_orchestrator_state.py`",
        "`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`",
        "`.claude/lib/orchestrator-state/OrchestratorState.psm1`",
        "unconditional",
        "presence-only",
        "`Checkpoint missing required key: <key>`",
    ):
        assert phrase in text, f"{REQUIRED_KEYS_HEADING} must contain {phrase}"


def test_rule_documents_last_updated_semantics() -> None:
    """The section defines the format and the refresh rule of last_updated."""

    # Act
    text = collapse(section(RULE, REQUIRED_KEYS_HEADING))

    # Assert
    for phrase in (
        "`last_updated`",
        "ISO-8601",
        "UTC",
        "rewritten on every checkpoint write",
        "including halts",
        "do not parse the value",
    ):
        assert phrase in text, f"{REQUIRED_KEYS_HEADING} must contain {phrase}"


def test_orchestrate_skill_references_last_updated_and_rule_section() -> None:
    """Checkpoint Handling names last_updated, its refresh rule, and the rule."""

    # Act
    text = collapse(section(SKILL, "## Checkpoint Handling"))

    # Assert
    assert "`last_updated`" in text, "Checkpoint Handling must name last_updated"
    assert "rewritten on every checkpoint write" in text, "refresh rule missing"
    assert "Required Top-Level Keys" in text, "rule section reference missing"


def test_orchestrate_skill_records_hyphenated_issue_num_key() -> None:
    """Issue Number Consistency records the hyphenated checkpoint key."""

    # Act
    text = collapse(section(SKILL, "## Issue Number Consistency"))

    # Assert
    assert "Record as `issue-num`" in text, "the checkpoint key must be issue-num"
    assert "Record as `issue_num`" not in text, "issue_num is not a checkpoint key"


@pytest.mark.parametrize("key", REQUIRED_STATE_KEYS)
def test_orchestrator_agent_checkpoint_persistence_lists_required_keys(
    key: str,
) -> None:
    """Checkpoint Persistence in the agent persona names each required key."""

    # Act
    text = section(AGENT, "## Checkpoint Persistence")

    # Assert
    assert f"`{key}`" in text, f"`{key}` missing from Checkpoint Persistence"


def test_rule_documents_both_dispatcher_invocation_forms() -> None:
    """The CLI contract documents both dispatcher forms and the -m validator."""

    # Act
    text = collapse(section(RULE, "## Bare-Module CLI Contract"))

    # Assert
    for phrase in (
        "python -m scripts.dev_tools.validate_orchestration_artifacts",
        "python scripts/dev_tools/validate_orchestration_artifacts.py",
        "python -m scripts.dev_tools.validate_orchestrator_state",
    ):
        assert phrase in text, f"Bare-Module CLI Contract must contain {phrase}"
