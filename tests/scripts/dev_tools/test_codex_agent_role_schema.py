"""Schema guard for Codex agent role files (issue #697).

Codex rejects a role file whose top-level keys fall outside its documented
schema, and it routes generated role files by their `model` and
`model_reasoning_effort` pins. These tests parse every role file in the three
role-file sets (the repository `.codex/agents`, the bundled
`.codex/agents`, and the bundled `.codex-variants/**/agents`) and assert the
key allowlist, the identity keys, the routed-file model pins, and that each
variant file matches its canonical bundled counterpart.
"""

from __future__ import annotations

import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import pytest

from scripts.dev_tools.resolve_codex_deployment import GENERATED_AGENT_FAMILIES

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLE_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)

ALLOWED_TOP_LEVEL_KEYS: frozenset[str] = frozenset(
    {
        "name",
        "description",
        "developer_instructions",
        "model",
        "model_reasoning_effort",
        "default_permissions",
        "skills",
        "sandbox_mode",
        "nickname_candidates",
    }
)
IDENTITY_KEYS: tuple[str, ...] = ("name", "description", "developer_instructions")
MODEL_PIN_KEYS: tuple[str, ...] = ("model", "model_reasoning_effort")
ROUTED_SUFFIXES: tuple[str, ...] = ("", "-c1", "-c2", "-c3", "-c3-elevated", "-c4")
ROUTED_ROOT_PERSONAS: frozenset[str] = frozenset({"epic-planner", "epic-orchestrator"})

CODEX_SET = ".codex/agents"
BUNDLE_SET = "bundle/.codex/agents"
VARIANT_SET = ".codex-variants"
EXPECTED_ROUTED_COUNTS: dict[str, int] = {CODEX_SET: 74, BUNDLE_SET: 74, VARIANT_SET: 1}
UNROUTED_REFERENCE_FILE = REPO_ROOT / ".codex" / "agents" / "5.1-beast-adjusted.toml"


@dataclass(frozen=True)
class RoleFile:
    """One parsed Codex role file and the set it belongs to.

    Attributes:
        set_name: Label of the role-file set (`.codex/agents`,
            `bundle/.codex/agents`, or `.codex-variants`).
        path: Absolute path of the TOML file.
        relative_name: Path of the file relative to its set root, used as
            the parametrize id suffix.
        data: Parsed TOML document.
    """

    set_name: str
    path: Path
    relative_name: str
    data: dict[str, Any]

    @property
    def test_id(self) -> str:
        """Return the `<set>/<file name>` parametrize id for this role file.

        Returns:
            str: The set label joined to the set-relative file path.
        """
        return f"{self.set_name}/{self.relative_name}"


def _load_role_set(set_name: str, root: Path, pattern: str) -> list[RoleFile]:
    """Parse every role file under one set root.

    Args:
        set_name: Label recorded on each returned `RoleFile`.
        root: Directory the glob pattern is evaluated against.
        pattern: Glob pattern selecting the role files.

    Returns:
        list[RoleFile]: Parsed role files sorted by set-relative path.

    Raises:
        tomllib.TOMLDecodeError: If a role file is not valid TOML.
    """
    role_files: list[RoleFile] = []
    # Parse each matching TOML file once so every test shares the same view.
    for path in sorted(root.glob(pattern)):
        with path.open("rb") as handle:
            data = tomllib.load(handle)
        relative_name = path.relative_to(root).as_posix()
        role_files.append(RoleFile(set_name, path, relative_name, data))
    return role_files


def _load_all_role_files() -> list[RoleFile]:
    """Parse the three role-file sets named by the specification.

    Returns:
        list[RoleFile]: Role files of the repository set, the bundled set,
        and the bundled variant set, in that order.
    """
    return [
        *_load_role_set(CODEX_SET, REPO_ROOT / ".codex" / "agents", "*.toml"),
        *_load_role_set(BUNDLE_SET, BUNDLE_ROOT / ".codex" / "agents", "*.toml"),
        *_load_role_set(
            VARIANT_SET, BUNDLE_ROOT / ".codex-variants", "**/agents/*.toml"
        ),
    ]


def disallowed_top_level_keys(data: dict[str, Any]) -> list[str]:
    """Return the top-level keys of a role document outside the allowlist.

    Args:
        data: Parsed role-file TOML document.

    Returns:
        list[str]: Sorted keys that Codex does not accept; empty when valid.
    """
    return sorted(key for key in data if key not in ALLOWED_TOP_LEVEL_KEYS)


def is_routed_role(stem: str) -> bool:
    """Decide whether a role file is selected by Codex model routing.

    A file is routed when its stem is a generated agent family, optionally
    followed by one complexity-band suffix, or is one of the two forced root
    personas.

    Args:
        stem: File name without the `.toml` extension.

    Returns:
        bool: True when the routing resolver can select this role file.
    """
    if stem in ROUTED_ROOT_PERSONAS:
        return True
    return any(
        stem == f"{family}{suffix}"
        for family in GENERATED_AGENT_FAMILIES
        for suffix in ROUTED_SUFFIXES
    )


def missing_model_pins(stem: str, data: dict[str, Any]) -> list[str]:
    """Return the model-pin keys a role file is required to declare but lacks.

    Args:
        stem: File name without the `.toml` extension.
        data: Parsed role-file TOML document.

    Returns:
        list[str]: Missing pin keys; always empty for an unrouted role file.
    """
    # Only routed files must carry pins; unrouted personas inherit defaults.
    if not is_routed_role(stem):
        return []
    return [key for key in MODEL_PIN_KEYS if key not in data]


ALL_ROLE_FILES = _load_all_role_files()
ROUTED_ROLE_FILES = [role for role in ALL_ROLE_FILES if is_routed_role(role.path.stem)]
VARIANT_ROLE_FILES = [role for role in ALL_ROLE_FILES if role.set_name == VARIANT_SET]


@pytest.mark.parametrize("role", ALL_ROLE_FILES, ids=lambda role: role.test_id)
def test_role_file_top_level_keys_are_allowlisted(role: RoleFile) -> None:
    """Every role file uses only top-level keys that Codex accepts (AC-1.2)."""
    # Arrange / Act
    violations = disallowed_top_level_keys(role.data)

    # Assert
    assert violations == [], f"{role.test_id} has disallowed keys: {violations}"


def test_allowlist_rule_reports_variant_key_in_memory() -> None:
    """The allowlist rule reports a `variant` key in an in-memory document (AC-1.2)."""
    # Arrange
    document = tomllib.loads(
        'name = "x"\ndescription = "d"\nvariant = "legacy"\n'
        "developer_instructions = '''text'''\n"
    )

    # Act
    violations = disallowed_top_level_keys(document)

    # Assert
    assert violations == ["variant"]


@pytest.mark.parametrize("role", ALL_ROLE_FILES, ids=lambda role: role.test_id)
def test_role_file_declares_identity_keys(role: RoleFile) -> None:
    """Every role file declares name, description, and instructions (AC-1.3)."""
    # Arrange / Act
    missing = [key for key in IDENTITY_KEYS if key not in role.data]

    # Assert
    assert missing == [], f"{role.test_id} lacks identity keys: {missing}"


@pytest.mark.parametrize("role", ROUTED_ROLE_FILES, ids=lambda role: role.test_id)
def test_routed_role_file_declares_model_pins(role: RoleFile) -> None:
    """Every routed role file declares `model` and `model_reasoning_effort` (AC-1.4)."""
    # Arrange / Act
    missing = missing_model_pins(role.path.stem, role.data)

    # Assert
    assert missing == [], f"{role.test_id} lacks model pins: {missing}"


@pytest.mark.parametrize(
    ("set_name", "expected_count"),
    sorted(EXPECTED_ROUTED_COUNTS.items()),
    ids=lambda value: str(value),
)
def test_routed_role_file_counts_per_set(set_name: str, expected_count: int) -> None:
    """Each role-file set holds the expected number of routed role files."""
    # Arrange / Act
    actual = sum(1 for role in ROUTED_ROLE_FILES if role.set_name == set_name)

    # Assert
    assert actual == expected_count, f"{set_name}: {actual} != {expected_count}"


def test_model_pins_not_required_for_unrouted_role() -> None:
    """An unrouted persona without pins passes the pin rule (AC-1.4)."""
    # Arrange
    with UNROUTED_REFERENCE_FILE.open("rb") as handle:
        data = tomllib.load(handle)

    # Act
    missing = missing_model_pins(UNROUTED_REFERENCE_FILE.stem, data)

    # Assert
    assert not is_routed_role(UNROUTED_REFERENCE_FILE.stem)
    assert "model" not in data
    assert missing == []


@pytest.mark.parametrize("role", VARIANT_ROLE_FILES, ids=lambda role: role.test_id)
def test_variant_role_file_matches_canonical_keys_and_pins(role: RoleFile) -> None:
    """A variant role file matches its canonical bundled counterpart (AC-1.5)."""
    # Arrange
    canonical_path = BUNDLE_ROOT / ".codex" / "agents" / role.path.name
    with canonical_path.open("rb") as handle:
        canonical = tomllib.load(handle)

    # Act
    variant_keys = sorted(role.data)
    canonical_keys = sorted(canonical)

    # Assert
    assert variant_keys == canonical_keys, f"{role.test_id} key set differs"
    # Compare each model pin separately so the failure names the diverging key.
    for key in MODEL_PIN_KEYS:
        assert role.data.get(key) == canonical.get(key), f"{role.test_id}: {key}"
