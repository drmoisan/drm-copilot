"""Skill taxonomy validation utilities."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

REQUIRED_FRONTMATTER_KEYS = ("name", "description")


@dataclass(frozen=True)
class SkillMetadata:
    """
    Represent parsed metadata for a single skill file.

    Purpose:
        Carry the frontmatter-derived details needed for validation.

    Usage:
        Construct via SkillRegistry while scanning skill directories.

    Flow:
        - Determine the skill directory
        - Parse SKILL.md frontmatter
        - Store name/description/canonical location for validation passes

    Invariants / Constraints:
        The skill directory and file paths must be absolute paths.

    Side Effects:
        None.

    Attributes:
        skill_dir (Path): Directory that owns the skill definition.
        skill_file (Path): Path to the SKILL.md file.
        name (str | None): Parsed frontmatter name value.
        description (str | None): Parsed frontmatter description value.
        canonical_location (str | None): Optional canonical location string.
    """

    skill_dir: Path
    skill_file: Path
    name: str | None
    description: str | None
    canonical_location: str | None


@dataclass(frozen=True)
class SkillValidationError:
    """
    Describe a validation failure for a skill registry.

    Purpose:
        Provide structured error details to support tests and CLI output.

    Usage:
        Returned by SkillRegistry.validate() and rendered by CLI callers.

    Flow:
        - Create for each validation failure
        - Consume via tests or CLI rendering

    Invariants / Constraints:
        code must identify the error type for deterministic filtering.

    Side Effects:
        None.

    Attributes:
        code (str): Machine-readable error code.
        message (str): Human-readable error description.
        skill_name (str | None): Skill name associated with the error.
        skill_path (Path | None): Directory path associated with the error.
        canonical_location (str | None): Canonical location involved in the error.
        missing_keys (tuple[str, ...]): Missing frontmatter keys.
    """

    code: str
    message: str
    skill_name: str | None = None
    skill_path: Path | None = None
    canonical_location: str | None = None
    missing_keys: tuple[str, ...] = ()

    def render(self) -> str:
        """
        Render the error for CLI output.

        Purpose:
            Provide a stable string representation for command-line reporting.

        Args:
            None.

        Returns:
            str: Rendered error message string.

        Raises:
            None.

        Side Effects:
            None.
        """
        parts = [self.code, self.message]
        if self.skill_name:
            parts.append(f"skill={self.skill_name}")
        if self.canonical_location:
            parts.append(f"canonical_location={self.canonical_location}")
        if self.missing_keys:
            parts.append(f"missing_keys={','.join(self.missing_keys)}")
        if self.skill_path:
            parts.append(f"path={self.skill_path}")
        return " | ".join(parts)


class SkillRegistry:
    """
    Scan skills under a repository root and validate taxonomy rules.

    Purpose:
        Provide a reusable validator that checks for missing SKILL.md files,
        missing frontmatter keys, and duplicate canonical locations.

    Usage:
        registry = SkillRegistry.from_root(Path("."))
        errors = registry.validate()

    Flow:
        - Identify skill directories under .github/skills
        - Parse each SKILL.md frontmatter
        - Apply validation rules and return structured errors

    Invariants / Constraints:
        Root is expected to be a repository path containing .github/skills.

    Side Effects:
        Reads skill files from disk; no mutation.

    Attributes:
        root (Path): Repository root used for scanning.
        skills (list[SkillMetadata]): Parsed metadata for discovered skills.
    """

    def __init__(self, root: Path, skills: list[SkillMetadata]) -> None:
        """
        Initialize the registry with pre-parsed skill metadata.

        Purpose:
            Store registry state for validation.

        Args:
            root (Path): Repository root.
            skills (list[SkillMetadata]): Parsed skill metadata entries.

        Returns:
            None.

        Raises:
            ValueError: If root is not absolute.

        Side Effects:
            None.
        """
        if not root.is_absolute():
            raise ValueError("root must be an absolute path")
        self._root = root
        self._skills = skills

    @classmethod
    def from_root(cls, root: Path) -> SkillRegistry:
        """
        Build a registry by scanning the repository root.

        Purpose:
            Discover skill folders and parse their SKILL.md metadata.

        Args:
            root (Path): Repository root containing .github/skills.

        Returns:
            SkillRegistry: Registry populated with parsed skill metadata.

        Raises:
            ValueError: If root does not exist.

        Side Effects:
            Reads filesystem metadata and file contents.
        """
        if not root.exists():
            raise ValueError("root does not exist")

        resolved_root = root.resolve()
        skills_root = resolved_root / ".github" / "skills"
        skill_dirs = _collect_skill_dirs(skills_root)
        metadata: list[SkillMetadata] = []

        # Parse each skill directory into metadata for validation.
        for skill_dir in skill_dirs:
            skill_file = skill_dir / "SKILL.md"
            frontmatter = _parse_frontmatter(skill_file)
            metadata.append(
                SkillMetadata(
                    skill_dir=skill_dir,
                    skill_file=skill_file,
                    name=frontmatter.get("name"),
                    description=frontmatter.get("description"),
                    canonical_location=frontmatter.get("canonical_location"),
                )
            )

        return cls(resolved_root, metadata)

    def validate(self) -> list[SkillValidationError]:
        """
        Validate the registry against required skill taxonomy rules.

        Purpose:
            Detect missing skill files, missing frontmatter keys, and duplicate
            canonical locations.

        Args:
            None.

        Returns:
            list[SkillValidationError]: Validation errors, if any.

        Raises:
            None.

        Side Effects:
            None.
        """
        errors: list[SkillValidationError] = []
        canonical_locations: dict[str, list[str]] = {}

        # Inspect each skill metadata entry and record validation errors.
        for skill in self._skills:
            if not skill.skill_file.exists():
                errors.append(
                    SkillValidationError(
                        code="missing_skill_file",
                        message="SKILL.md file is missing",
                        skill_name=skill.skill_dir.name,
                        skill_path=skill.skill_dir,
                    )
                )
                continue

            missing_keys = _missing_frontmatter_keys(skill)
            if missing_keys:
                errors.append(
                    SkillValidationError(
                        code="missing_frontmatter",
                        message="Required frontmatter keys are missing",
                        skill_name=skill.name or skill.skill_dir.name,
                        skill_path=skill.skill_dir,
                        missing_keys=missing_keys,
                    )
                )

            if skill.canonical_location:
                canonical_locations.setdefault(skill.canonical_location, []).append(
                    skill.name or skill.skill_dir.name
                )

        # Flag any canonical locations defined by multiple skills.
        for canonical_location, skill_names in canonical_locations.items():
            if len(skill_names) <= 1:
                continue
            errors.append(
                SkillValidationError(
                    code="duplicate_canonical_location",
                    message="Canonical location is defined by multiple skills",
                    canonical_location=canonical_location,
                    missing_keys=(),
                    skill_name=None,
                )
            )

        return errors


def _collect_skill_dirs(skills_root: Path) -> list[Path]:
    """
    Collect skill directories under the skills root.

    Purpose:
        Provide a deterministic list of skill directories for scanning.

    Args:
        skills_root (Path): Path to the .github/skills directory.

    Returns:
        list[Path]: Sorted list of skill directory paths.

    Raises:
        None.

    Side Effects:
        None.
    """
    if not skills_root.exists():
        return []

    directories: list[Path] = []

    # Only include directories directly beneath the skills root.
    for child in skills_root.iterdir():
        if child.is_dir():
            directories.append(child)

    return sorted(directories, key=lambda path: path.name)


def _parse_frontmatter(skill_file: Path) -> dict[str, str]:
    """
    Parse YAML-like frontmatter from a SKILL.md file.

    Purpose:
        Extract key/value pairs needed for validation without external deps.

    Args:
        skill_file (Path): Path to the SKILL.md file.

    Returns:
        dict[str, str]: Parsed frontmatter keys and values.

    Raises:
        None.

    Side Effects:
        Reads the skill file when it exists.
    """
    if not skill_file.exists():
        return {}

    text = skill_file.read_text(encoding="utf-8")
    lines = text.splitlines()

    if not lines or lines[0].strip() != "---":
        return {}

    frontmatter: dict[str, str] = {}

    # Parse key/value lines until the closing frontmatter delimiter.
    for line in lines[1:]:
        if line.strip() == "---":
            break
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        frontmatter[key.strip()] = _normalize_frontmatter_value(value)

    return frontmatter


def _normalize_frontmatter_value(raw_value: str) -> str:
    """
    Normalize a frontmatter value by trimming whitespace and quotes.

    Purpose:
        Ensure values are clean strings suitable for comparisons.

    Args:
        raw_value (str): Raw value string from frontmatter.

    Returns:
        str: Normalized value string.

    Raises:
        None.

    Side Effects:
        None.
    """
    value = raw_value.strip()
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1]
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1]
    return value


def _missing_frontmatter_keys(skill: SkillMetadata) -> tuple[str, ...]:
    """
    Determine which required frontmatter keys are missing.

    Purpose:
        Provide a tuple of missing keys for validation errors.

    Args:
        skill (SkillMetadata): Skill metadata entry to inspect.

    Returns:
        tuple[str, ...]: Missing frontmatter keys.

    Raises:
        None.

    Side Effects:
        None.
    """
    missing: list[str] = []

    # Check each required key for presence in the parsed metadata.
    for key in REQUIRED_FRONTMATTER_KEYS:
        if key == "name" and skill.name:
            continue
        if key == "description" and skill.description:
            continue
        missing.append(key)

    return tuple(missing)


def _parse_args(argv: list[str] | None) -> Path:
    """
    Parse CLI arguments for the skill taxonomy validator.

    Purpose:
        Normalize CLI parsing for the validator entry point.

    Args:
        argv (list[str] | None): Optional argument list for testing or reuse.

    Returns:
        Path: Parsed repository root path.

    Raises:
        SystemExit: When parsing fails due to invalid arguments.

    Side Effects:
        None.
    """
    parser = argparse.ArgumentParser(
        description="Validate skill taxonomy under .github/skills."
    )
    parser.add_argument(
        "repo_root",
        type=Path,
        help="Path to the repository root containing .github/skills",
    )
    args = parser.parse_args(argv)
    return args.repo_root


def main(argv: list[str] | None = None) -> int:
    """
    Execute the skill taxonomy validator CLI.

    Purpose:
        Run validation and emit errors in a CLI-friendly format.

    Args:
        argv (list[str] | None): Optional argument list for testing.

    Returns:
        int: Process exit code (0 on success, 1 on validation errors).

    Raises:
        None.

    Side Effects:
        Prints validation errors to stdout.
    """
    repo_root = _parse_args(argv)
    registry = SkillRegistry.from_root(repo_root)
    errors = registry.validate()

    if not errors:
        return 0

    # Emit each validation error as a prefixed, single-line record.
    for error in errors:
        print(f"SKILL_VALIDATION_ERROR: {error.render()}")

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
