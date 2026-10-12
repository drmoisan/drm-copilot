"""Repository guard: every skill's scripts are published with the skill.

Reads the real repository tree (rooted three levels above this test folder)
through ``load_repository_inputs`` and asserts the bundling contract of issue
#762. The tests read files only and create none.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

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
_MUTATION_SCRIPT = ".claude/lib/bash/mutate-parallel-run.sh"

# The Python engine module and the six engine functions no mutation skill may
# still instruct the agent to call (issue #890, FU-791-1).
_PYTHON_ENGINE_NAMES = (
    "parallel_mutation_protocol",
    "decide_admission",
    "recolor_unstarted",
    "build_add_entry",
    "decide_close",
    "build_close_entry",
    "build_requeue_entry",
)

# The subcommand invocations each mutation skill must carry.
_MUTATION_SKILL_SUBCOMMANDS = {
    "parallel-add": (
        "mutate-parallel-run.sh admit",
        "mutate-parallel-run.sh recolor",
        "mutate-parallel-run.sh add-entry",
    ),
    "parallel-close": (
        "mutate-parallel-run.sh close --items",
        "mutate-parallel-run.sh close-entry",
    ),
    "parallel-orchestrate": (
        "mutate-parallel-run.sh requeue-entry",
        "mutate-parallel-run.sh recolor",
    ),
}


def test_every_skill_script_reference_is_bundled() -> None:
    """No skill invokes a script that its bundle and packs do not carry."""

    # Arrange
    inputs = load_repository_inputs(_REPO_ROOT)

    # Act
    violations = find_violations(inputs)

    # Assert: render one "<skill> | <path> | <reason>" line per violation.
    report = "\n".join(
        f"{violation.skill} | {violation.path} | {violation.reason}"
        for violation in violations
    )
    assert not violations, f"Unbundled skill script references:\n{report}"


def test_ci_gate_parser_skills_invoke_bundled_parser() -> None:
    """Both orchestration skills invoke the CI gate parser at its bundled path."""

    # Arrange
    skill_names = ("orchestrate", "epic-orchestrate")

    # Act: extract each skill's script references from its SKILL.md.
    references = {
        name: extract_script_references(
            (_REPO_ROOT / ".claude/skills" / name / "SKILL.md").read_text(
                encoding="utf-8"
            )
        )
        for name in skill_names
    }

    # Assert: collect the skills whose references lack the bundled parser.
    missing = [name for name in skill_names if _CI_GATE_PARSER not in references[name]]
    assert (
        not missing
    ), f"Skills not invoking {_CI_GATE_PARSER}: {missing}; got {references}"


def test_parallel_plan_extracts_compute_cohorts_under_bash_fence() -> None:
    """The parallel-plan skill's bash-fenced cohort invocation is extracted.

    Regression for issue #791 (FU-763-5): the invocation sits on the first
    line of a bash fence.
    """

    # Arrange
    text = (_REPO_ROOT / ".claude/skills/parallel-plan/SKILL.md").read_text(
        encoding="utf-8"
    )

    # Act
    references = extract_script_references(text)

    # Assert
    assert (
        ".claude/lib/bash/compute-cohorts.sh" in references
    ), f"compute-cohorts.sh not extracted from parallel-plan; got {references}"


def test_parallel_remove_invokes_bundled_remove_script() -> None:
    """The parallel-remove skill invokes the bundled bash removal script.

    Regression for issue #791 (FU-763-3): the skill must call the bash entry
    point rather than the Python mutation engine functions.
    """

    # Arrange
    text = (_REPO_ROOT / ".claude/skills/parallel-remove/SKILL.md").read_text(
        encoding="utf-8"
    )

    # Act
    references = extract_script_references(text)

    # Assert: (a) the bundled entry point is an extracted script reference.
    assert (
        ".claude/lib/bash/remove-parallel-item.sh" in references
    ), f"remove-parallel-item.sh not extracted from parallel-remove; got {references}"
    # Assert: (b) each subcommand is invoked through the entry point.
    missing_subcommands = [
        form
        for form in (
            "remove-parallel-item.sh decide",
            "remove-parallel-item.sh recolor",
            "remove-parallel-item.sh entry",
        )
        if form not in text
    ]
    assert (
        not missing_subcommands
    ), f"parallel-remove lacks subcommand invocations: {missing_subcommands}"
    # Assert: (c) no Python engine function name remains.
    remaining_functions = [
        name
        for name in ("decide_removal", "recolor_unstarted", "build_remove_entry")
        if name in text
    ]
    assert (
        not remaining_functions
    ), f"parallel-remove still names Python engine functions: {remaining_functions}"
    # Assert: (d) the Python parity module is cited at most once.
    protocol_mentions = text.count("parallel_mutation_protocol")
    assert (
        protocol_mentions <= 1
    ), f"parallel-remove cites parallel_mutation_protocol {protocol_mentions} times"


@pytest.mark.parametrize(
    "skill_name",
    sorted(_MUTATION_SKILL_SUBCOMMANDS),
    ids=sorted(_MUTATION_SKILL_SUBCOMMANDS),
)
def test_mutation_skills_invoke_bundled_mutation_script(skill_name: str) -> None:
    """Each mutation skill invokes the bundled bash mutation script, not Python.

    Regression for issue #890 (FU-791-1): the add, close, and requeue steps must
    run through ``mutate-parallel-run.sh`` so they work in a pushed-down
    workspace that has no Python engine.
    """

    # Arrange
    text = (_REPO_ROOT / ".claude/skills" / skill_name / "SKILL.md").read_text(
        encoding="utf-8"
    )

    # Act
    references = extract_script_references(text)

    # Assert: (a) the bundled entry point is an extracted script reference.
    assert (
        _MUTATION_SCRIPT in references
    ), f"{_MUTATION_SCRIPT} not extracted from {skill_name}; got {references}"
    # Assert: (b) each required subcommand form is present.
    missing_forms = [
        form for form in _MUTATION_SKILL_SUBCOMMANDS[skill_name] if form not in text
    ]
    assert (
        not missing_forms
    ), f"{skill_name} lacks subcommand invocations: {missing_forms}"
    # Assert: (c) no Python engine module or function name remains.
    remaining = [name for name in _PYTHON_ENGINE_NAMES if name in text]
    assert not remaining, f"{skill_name} still names Python engine items: {remaining}"


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
        f"{violation.skill} | {violation.path} | {violation.reason}"
        for violation in violations
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
    assert (
        typescript_folders == PUBLISHED_ROOT_FOLDERS
    ), f"TypeScript {typescript_folders} != Python {PUBLISHED_ROOT_FOLDERS}"
