"""Unit tests for skill bundle evaluation, exception filtering, and staleness.

Covers ``evaluate_skill_bundle``, ``find_violations``, ``find_stale_exceptions``,
and the ``KNOWN_UNBUNDLED_REFERENCES`` registry in
``scripts/dev_tools/skill_bundle_contract.py``. Every snapshot is inline and
every path is fictitious.
"""

from __future__ import annotations

from scripts.dev_tools.skill_bundle_contract import (
    KNOWN_UNBUNDLED_REFERENCES,
    KnownUnbundledReference,
    SkillBundleInputs,
    SkillBundleViolation,
    evaluate_skill_bundle,
    find_stale_exceptions,
    find_violations,
)

_SKILL = "demo-skill"
_SKILL_TEXT_PATH = ".claude/skills/demo-skill/SKILL.md"
_SCRIPT = ".claude/lib/example/example.sh"


def _inputs(
    *,
    skill_texts: dict[str, str] | None = None,
    skill_folder_files: dict[str, frozenset[str]] | None = None,
    repository_files: frozenset[str] = frozenset({_SCRIPT}),
    bundle_files: frozenset[str] = frozenset({_SCRIPT}),
    pack_paths: dict[str, frozenset[str]] | None = None,
) -> SkillBundleInputs:
    """Build a snapshot with defaults for a single core-listed demo skill.

    Args:
        skill_texts (dict[str, str] | None): Skill texts; defaults to none.
        skill_folder_files (dict[str, frozenset[str]] | None): Folder files;
            defaults to none.
        repository_files (frozenset[str]): Existing repository files.
        bundle_files (frozenset[str]): Bundle-relative files.
        pack_paths (dict[str, frozenset[str]] | None): Pack manifests;
            defaults to a core pack listing the demo skill and the script.

    Returns:
        SkillBundleInputs: The assembled snapshot.
    """

    return SkillBundleInputs(
        skill_texts=skill_texts or {},
        skill_folder_files=skill_folder_files or {},
        repository_files=repository_files,
        bundle_files=bundle_files,
        pack_paths=pack_paths
        if pack_paths is not None
        else {"core": frozenset({_SKILL_TEXT_PATH, _SCRIPT})},
    )


def test_evaluate_reports_missing_file() -> None:
    """A reference absent from the repository is ``missing-file``."""

    # Arrange
    inputs = _inputs(repository_files=frozenset())

    # Act
    violations = evaluate_skill_bundle(_SKILL, [_SCRIPT], inputs)

    # Assert
    assert violations == (SkillBundleViolation(_SKILL, _SCRIPT, "missing-file"),), violations


def test_evaluate_reports_not_in_bundle_for_unpublished_root() -> None:
    """A reference outside the published root folders is ``not-in-bundle``."""

    # Arrange
    path = "scripts/tools/example.sh"
    inputs = _inputs(repository_files=frozenset({path}), bundle_files=frozenset({path}))

    # Act
    violations = evaluate_skill_bundle(_SKILL, [path], inputs)

    # Assert
    assert violations == (SkillBundleViolation(_SKILL, path, "not-in-bundle"),), violations


def test_evaluate_reports_not_in_bundle_when_bundle_lacks_file() -> None:
    """A published-root reference the bundle does not carry is ``not-in-bundle``."""

    # Arrange
    inputs = _inputs(bundle_files=frozenset())

    # Act
    violations = evaluate_skill_bundle(_SKILL, [_SCRIPT], inputs)

    # Assert
    assert violations == (SkillBundleViolation(_SKILL, _SCRIPT, "not-in-bundle"),), violations


def test_evaluate_reports_not_in_skill_pack_for_pack_specific_skill() -> None:
    """A bundled reference missing from the skill's own pack is flagged."""

    # Arrange
    inputs = _inputs(
        pack_paths={"core": frozenset(), "python": frozenset({_SKILL_TEXT_PATH})},
    )

    # Act
    violations = evaluate_skill_bundle(_SKILL, [_SCRIPT], inputs)

    # Assert
    assert violations == (
        SkillBundleViolation(_SKILL, _SCRIPT, "not-in-skill-pack"),
    ), violations


def test_evaluate_accepts_reference_listed_in_core() -> None:
    """A bundled reference listed by the core pack is carried."""

    # Arrange
    inputs = _inputs()

    # Act
    violations = evaluate_skill_bundle(_SKILL, [_SCRIPT], inputs)

    # Assert
    assert violations == (), violations


def test_evaluate_accepts_reference_listed_in_every_skill_pack() -> None:
    """A reference listed by every pack that installs the skill is carried."""

    # Arrange
    listed = frozenset({_SKILL_TEXT_PATH, _SCRIPT})
    inputs = _inputs(pack_paths={"core": frozenset(), "python": listed, "powershell": listed})

    # Act
    violations = evaluate_skill_bundle(_SKILL, [_SCRIPT], inputs)

    # Assert
    assert violations == (), violations


def test_evaluate_accepts_script_outside_skill_folder_when_bundled() -> None:
    """Folder location is not a reason: a bundled, carried outside script passes."""

    # Arrange
    outside = "config/example/example.sh"
    inputs = _inputs(
        repository_files=frozenset({outside}),
        bundle_files=frozenset({outside}),
        pack_paths={"core": frozenset({_SKILL_TEXT_PATH, outside})},
    )

    # Act
    violations = evaluate_skill_bundle(_SKILL, [outside], inputs)

    # Assert
    assert violations == (), violations


def test_evaluate_reports_skill_folder_file_missing_from_packs() -> None:
    """A bundled skill-folder file that no pack lists is ``not-in-skill-pack``."""

    # Arrange
    folder_file = ".claude/skills/demo-skill/scripts/helper.sh"
    inputs = _inputs(
        skill_folder_files={_SKILL: frozenset({_SKILL_TEXT_PATH, folder_file})},
        bundle_files=frozenset({_SKILL_TEXT_PATH, folder_file}),
        pack_paths={"core": frozenset({_SKILL_TEXT_PATH})},
    )

    # Act
    violations = evaluate_skill_bundle(_SKILL, [], inputs)

    # Assert
    assert violations == (
        SkillBundleViolation(_SKILL, folder_file, "not-in-skill-pack"),
    ), violations


def test_find_violations_suppresses_known_exceptions() -> None:
    """A violation named by a registered exception is dropped."""

    # Arrange
    path = "scripts/tools/example_cli.py"
    inputs = _inputs(
        skill_texts={_SKILL: f"Run `python {path}`.", "other-skill": f"Run `python {path}`."},
        repository_files=frozenset({path}),
    )
    exception = KnownUnbundledReference(_SKILL, path, "#1")

    # Act
    violations = find_violations(inputs, exceptions=[exception])

    # Assert
    assert violations == (
        SkillBundleViolation("other-skill", path, "not-in-bundle"),
    ), violations


def test_find_stale_exceptions_reports_unmatched_exception() -> None:
    """An exception that matches no violation is reported as stale."""

    # Arrange
    inputs = _inputs(skill_texts={_SKILL: f"Run `bash {_SCRIPT}`."})
    stale = KnownUnbundledReference(_SKILL, "scripts/tools/gone.sh", "#1")

    # Act
    result = find_stale_exceptions(inputs, exceptions=[stale])

    # Assert
    assert result == (stale,), result


def test_find_stale_exceptions_returns_empty_when_all_match() -> None:
    """An exception that still matches a violation is not stale."""

    # Arrange
    path = "scripts/tools/example_cli.py"
    inputs = _inputs(
        skill_texts={_SKILL: f"Run `python {path}`."},
        repository_files=frozenset({path}),
    )
    live = KnownUnbundledReference(_SKILL, path, "#1")

    # Act
    result = find_stale_exceptions(inputs, exceptions=[live])

    # Assert
    assert result == (), result


def test_known_unbundled_references_cite_issue_763() -> None:
    """The registry holds exactly the two #763 Python CLI references."""

    # Arrange
    expected = (
        KnownUnbundledReference(
            "parallel-orchestrate", "scripts/dev_tools/parallel_drift_detection_cli.py", "#763"
        ),
        KnownUnbundledReference(
            "parallel-remove", "scripts/dev_tools/parallel_mutation_abandon_cli.py", "#763"
        ),
    )

    # Act
    registry = KNOWN_UNBUNDLED_REFERENCES

    # Assert
    assert registry == expected, registry
