"""Repository guard: every skill's scripts are published with the skill.

Reads the real repository tree (rooted three levels above this test folder)
through ``load_repository_inputs`` and asserts the bundling contract of issue
#762. The tests read files only and create none.
"""

from __future__ import annotations

import re
from pathlib import Path

from scripts.dev_tools.skill_bundle_contract import (
    PUBLISHED_ROOT_FOLDERS,
    evaluate_skill_bundle,
    extract_script_references,
    find_stale_exceptions,
    find_violations,
)
from scripts.dev_tools.skill_bundle_contract_cli import load_repository_inputs

_REPO_ROOT = Path(__file__).resolve().parents[3]
_CI_GATE_PARSER = ".claude/lib/ci-gate/Invoke-CiGateParser.ps1"
_TYPESCRIPT_ROOT_FOLDERS_FILE = (
    _REPO_ROOT / "extensions/drm-copilot/src/lib/push-down/claude-customizations.ts"
)


def test_every_skill_script_reference_is_bundled() -> None:
    """No skill invokes a script that its bundle and packs do not carry."""

    # Arrange
    inputs = load_repository_inputs(_REPO_ROOT)

    # Act
    violations = find_violations(inputs)

    # Assert: render one "<skill> | <path> | <reason>" line per violation.
    report = "\n".join(
        f"{violation.skill} | {violation.path} | {violation.reason}" for violation in violations
    )
    assert not violations, f"Unbundled skill script references:\n{report}"


def test_ci_gate_parser_skills_invoke_bundled_parser() -> None:
    """Both orchestration skills invoke the CI gate parser at its bundled path."""

    # Arrange
    skill_names = ("orchestrate", "epic-orchestrate")

    # Act: extract each skill's script references from its SKILL.md.
    references = {
        name: extract_script_references(
            (_REPO_ROOT / ".claude/skills" / name / "SKILL.md").read_text(encoding="utf-8")
        )
        for name in skill_names
    }

    # Assert: collect the skills whose references lack the bundled parser.
    missing = [name for name in skill_names if _CI_GATE_PARSER not in references[name]]
    assert not missing, f"Skills not invoking {_CI_GATE_PARSER}: {missing}; got {references}"


def test_every_skill_folder_file_is_carried_by_skill_packs() -> None:
    """Every file inside a skill folder is bundled and carried by the skill's packs."""

    # Arrange
    inputs = load_repository_inputs(_REPO_ROOT)

    # Act: an empty reference list isolates the skill-folder check per skill.
    violations = [
        violation
        for skill in sorted(inputs.skill_folder_files)
        for violation in evaluate_skill_bundle(skill, (), inputs)
    ]

    # Assert: render one "<skill> | <path> | <reason>" line per violation.
    report = "\n".join(
        f"{violation.skill} | {violation.path} | {violation.reason}" for violation in violations
    )
    assert not violations, f"Skill-folder files not carried:\n{report}"


def test_known_unbundled_references_are_not_stale() -> None:
    """Every registered #763 exception still matches a real violation."""

    # Arrange
    inputs = load_repository_inputs(_REPO_ROOT)

    # Act
    stale = find_stale_exceptions(inputs)

    # Assert
    assert stale == (), f"Stale exceptions: {stale}"


def test_published_root_folders_match_typescript_root_folders() -> None:
    """The Python root-folder constant equals the TypeScript push-down constant."""

    # Arrange
    source = _TYPESCRIPT_ROOT_FOLDERS_FILE.read_text(encoding="utf-8")
    declaration = re.search(r"export const ROOT_FOLDERS[^=]*=\s*\[([^\]]*)\]", source)
    assert declaration is not None, "ROOT_FOLDERS declaration not found"

    # Act: read the string literals of the array, in declaration order.
    typescript_folders = tuple(re.findall(r"\"([^\"]*)\"", declaration.group(1)))

    # Assert
    assert typescript_folders == PUBLISHED_ROOT_FOLDERS, (
        f"TypeScript {typescript_folders} != Python {PUBLISHED_ROOT_FOLDERS}"
    )
