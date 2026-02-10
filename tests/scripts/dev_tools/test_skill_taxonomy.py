"""Unit tests for skill taxonomy validation."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools import skill_taxonomy

if TYPE_CHECKING:
    import pytest


def test_validate_reports_missing_skill_file() -> None:
    """
    Ensure validation reports a missing SKILL.md file.

    Purpose:
        Confirm that a skill directory without SKILL.md is surfaced as an error.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: If the expected missing-skill error is not present.

    Side Effects:
        None.
    """
    fixture_root = _fixture_root("missing_skill")
    registry = skill_taxonomy.SkillRegistry.from_root(fixture_root)
    errors = registry.validate()

    missing_skill_found = False

    # Scan validation errors for the expected missing-skill condition.
    for error in errors:
        if error.code == "missing_skill_file" and error.skill_name == "missing-skill":
            missing_skill_found = True
            break

    assert missing_skill_found


def test_validate_reports_duplicate_canonical_locations() -> None:
    """
    Ensure validation reports duplicate canonical locations.

    Purpose:
        Confirm that two skills defining the same canonical location are flagged.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: If the duplicate canonical location error is not present.

    Side Effects:
        None.
    """
    fixture_root = _fixture_root("duplicate_canonical")
    registry = skill_taxonomy.SkillRegistry.from_root(fixture_root)
    errors = registry.validate()

    duplicate_found = False

    # Scan validation errors for a duplicate canonical location report.
    for error in errors:
        if error.code != "duplicate_canonical_location":
            continue
        if error.canonical_location == "docs/canonical/location.md":
            duplicate_found = True
            break

    assert duplicate_found


def test_validate_reports_missing_frontmatter_keys() -> None:
    """
    Ensure validation reports missing frontmatter keys.

    Purpose:
        Confirm that required frontmatter fields are validated and missing keys
        are surfaced as errors.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: If the missing-frontmatter error is not present.

    Side Effects:
        None.
    """
    fixture_root = _fixture_root("missing_frontmatter")
    registry = skill_taxonomy.SkillRegistry.from_root(fixture_root)
    errors = registry.validate()

    missing_frontmatter_found = False

    # Scan validation errors for missing frontmatter keys.
    for error in errors:
        if error.code != "missing_frontmatter":
            continue
        if error.skill_name == "skill-missing" and "description" in error.missing_keys:
            missing_frontmatter_found = True
            break

    assert missing_frontmatter_found


def test_validate_handles_missing_skills_root() -> None:
    """
    Ensure validation succeeds when the skills root is absent.

    Purpose:
        Cover the branch where .github/skills does not exist under root.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: If validation reports errors for an empty root.

    Side Effects:
        None.
    """
    fixture_root = _fixture_root("empty_root")
    registry = skill_taxonomy.SkillRegistry.from_root(fixture_root)
    errors = registry.validate()

    assert errors == []


def test_validate_reports_missing_frontmatter_block() -> None:
    """
    Ensure missing frontmatter blocks surface both required keys.

    Purpose:
        Exercise the branch where no frontmatter exists in the SKILL.md file.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: If missing keys are not reported as expected.

    Side Effects:
        None.
    """
    fixture_root = _fixture_root("no_frontmatter")
    registry = skill_taxonomy.SkillRegistry.from_root(fixture_root)
    errors = registry.validate()

    missing_block_found = False

    # Identify the missing-frontmatter error for the no-frontmatter fixture.
    for error in errors:
        if error.code != "missing_frontmatter":
            continue
        if error.skill_name == "no-frontmatter":
            missing_block_found = True
            assert "name" in error.missing_keys
            assert "description" in error.missing_keys
            break

    assert missing_block_found


def test_render_includes_context_fields() -> None:
    """
    Ensure error rendering includes optional context fields.

    Purpose:
        Verify that render output contains skill, canonical location, missing
        keys, and path metadata when provided.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: If render output omits expected context fields.

    Side Effects:
        None.
    """
    error = skill_taxonomy.SkillValidationError(
        code="missing_frontmatter",
        message="Required frontmatter keys are missing",
        skill_name="skill-missing",
        canonical_location="docs/missing/location.md",
        missing_keys=("description",),
        skill_path=Path("/repo/.github/skills/skill-missing"),
    )
    rendered = error.render()

    assert "skill=skill-missing" in rendered
    assert "canonical_location=docs/missing/location.md" in rendered
    assert "missing_keys=description" in rendered
    expected_path = str(Path("/repo/.github/skills/skill-missing"))
    assert f"path={expected_path}" in rendered


def test_cli_returns_zero_when_no_errors(capsys: pytest.CaptureFixture[str]) -> None:
    """
    Ensure CLI returns success and emits no errors for valid skills.

    Purpose:
        Validate the success path of the CLI entry point.

    Args:
        capsys (object): Pytest capture fixture for stdout/stderr.

    Returns:
        None.

    Raises:
        AssertionError: If errors are printed for a valid fixture.

    Side Effects:
        None.
    """
    exit_code = skill_taxonomy.main([str(_fixture_root("valid_skill"))])
    captured = capsys.readouterr()

    assert exit_code == 0
    assert "SKILL_VALIDATION_ERROR" not in captured.out


def test_cli_reports_errors_for_missing_skill(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """
    Ensure CLI emits error output and returns non-zero for failures.

    Purpose:
        Validate error reporting and exit code for invalid skill fixtures.

    Args:
        capsys (object): Pytest capture fixture for stdout/stderr.

    Returns:
        None.

    Raises:
        AssertionError: If error output or exit code is incorrect.

    Side Effects:
        None.
    """
    exit_code = skill_taxonomy.main([str(_fixture_root("missing_skill"))])
    captured = capsys.readouterr()

    assert exit_code == 1
    assert "SKILL_VALIDATION_ERROR" in captured.out


def test_cli_reports_duplicate_canonical_location(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """
    Ensure CLI emits canonical location details for duplication errors.

    Purpose:
        Exercise render output for duplicate canonical location validation.

    Args:
        capsys (pytest.CaptureFixture[str]): Pytest capture fixture.

    Returns:
        None.

    Raises:
        AssertionError: If canonical location output is missing.

    Side Effects:
        None.
    """
    exit_code = skill_taxonomy.main([str(_fixture_root("duplicate_canonical"))])
    captured = capsys.readouterr()

    assert exit_code == 1
    assert "canonical_location=docs/canonical/location.md" in captured.out


def test_from_root_raises_for_missing_repo() -> None:
    """
    Ensure from_root raises when the repository path is missing.

    Purpose:
        Cover the invalid-root branch for registry construction.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: If ValueError is not raised.

    Side Effects:
        None.
    """
    missing_root = Path("Z:/__skill_taxonomy_missing_root__")

    raised = False

    # Exercise the invalid-root branch without touching real filesystem paths.
    try:
        skill_taxonomy.SkillRegistry.from_root(missing_root)
    except ValueError:
        raised = True

    assert raised


def _fixture_root(fixture_name: str) -> Path:
    """
    Build the absolute path to a skill taxonomy fixture root.

    Purpose:
        Centralize fixture path construction for test readability.

    Args:
        fixture_name (str): Fixture directory name under tests/fixtures.

    Returns:
        Path: Absolute path to the fixture root.

    Raises:
        None.

    Side Effects:
        None.
    """
    return (
        Path(__file__).resolve().parents[2]
        / "fixtures"
        / "skill_taxonomy"
        / fixture_name
    )
