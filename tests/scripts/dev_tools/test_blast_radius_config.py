"""Shape-pinning tests for the committed blast-radius truth table.

Load ``config/blast-radius.json`` from the repository tree and assert the shape
contract the Python library and its PowerShell mirror both rely on: the schema
version, a non-empty glob list per module, an over-breadth fraction inside
``(0, 1]``, repo-relative shared-surface paths, and wildcard-bearing membership
globs. Reading the committed configuration is the point of these tests: they
exist so the two implementations and the truth table cannot drift. No temporary
file is created and no external process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

if TYPE_CHECKING:
    from collections.abc import Mapping

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_blast_radius_config.py, so the repository root is
# three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CONFIG_PATH = REPO_ROOT / "config" / "blast-radius.json"

# A drive-qualified path such as ``C:/repo/config`` is absolute on Windows even
# without a leading separator, so the repo-relative check screens for it too.
DRIVE_SEPARATOR = ":"
PARENT_SEGMENT = ".."


def require_string_list(value: object, label: str) -> tuple[str, ...]:
    """Guard a truth-table entry that must be a list of non-blank strings.

    Args:
        value (object): Value read from the parsed configuration.
        label (str): Configuration key path used in the failure message.

    Returns:
        tuple[str, ...]: The entries in their committed order.

    Raises:
        TypeError: If the value is not a list, or holds a non-string entry.
        ValueError: If any entry is blank.
    """
    if not isinstance(value, list):
        raise TypeError(f"{label} must be a list, got {type(value).__name__}.")

    # Validate every entry before returning so a malformed truth table fails at
    # load time with the offending value named, rather than inside a test body.
    entries: list[str] = []
    for entry in cast("list[object]", value):
        if not isinstance(entry, str):
            raise TypeError(f"{label} entries must be strings.")
        if not entry.strip():
            raise ValueError(f"{label} entries must not be blank.")
        entries.append(entry)

    return tuple(entries)


def load_config() -> Mapping[str, object]:
    """Read and parse the committed blast-radius truth table.

    Returns:
        Mapping[str, object]: The parsed top-level configuration object.

    Raises:
        TypeError: If the file does not parse to a JSON object.

    Side Effects:
        Reads ``config/blast-radius.json`` from the repository tree. The file is
        committed and read-only for these tests.
    """
    parsed = cast("object", json.loads(CONFIG_PATH.read_text(encoding="utf-8")))
    if not isinstance(parsed, dict):
        raise TypeError("config/blast-radius.json must contain a JSON object.")
    return cast("Mapping[str, object]", parsed)


def load_module_globs(
    config: Mapping[str, object],
) -> tuple[tuple[str, tuple[str, ...]], ...]:
    """Read the module map as ordered module-name and glob-list pairs.

    Args:
        config (Mapping[str, object]): Parsed truth table.

    Returns:
        tuple[tuple[str, tuple[str, ...]], ...]: One pair per module holding the
        module name and its glob tuple, ordered by module name so the
        parametrized cases are deterministic.

    Raises:
        TypeError: If the module map is absent, is not an object, or maps a
            module to something other than a list of strings.
    """
    value = config.get("modules")
    if not isinstance(value, dict):
        raise TypeError('config["modules"] must be a JSON object.')

    # Pair each module with its validated glob tuple; sorting by name keeps the
    # generated test identifiers stable regardless of key order in the file.
    module_map = cast("Mapping[str, object]", value)
    pairs: list[tuple[str, tuple[str, ...]]] = []
    for name, globs in module_map.items():
        pairs.append((name, require_string_list(globs, f'config["modules"]["{name}"]')))

    return tuple(sorted(pairs))


CONFIG: Mapping[str, object] = load_config()
MODULE_GLOBS: tuple[tuple[str, tuple[str, ...]], ...] = load_module_globs(CONFIG)
SHARED_SURFACES: tuple[str, ...] = require_string_list(
    CONFIG.get("shared_surfaces"), 'config["shared_surfaces"]'
)
SHARED_SURFACE_GLOBS: tuple[str, ...] = require_string_list(
    CONFIG.get("shared_surface_globs"), 'config["shared_surface_globs"]'
)


def test_truth_table_declares_schema_version_one() -> None:
    """Pin the truth-table schema version consumed by both implementations."""
    # Arrange: the committed configuration is loaded at import.
    # Act: read the version entry.
    version = CONFIG.get("version")

    # Assert: the version is the integer 1, not a string or a later revision.
    assert version == 1, (
        f"config/blast-radius.json must declare version 1, got {version!r}. "
        "A version change is a cross-language contract change."
    )


def test_truth_table_populates_every_parametrized_collection() -> None:
    """Guard the parametrized cases below against passing vacuously."""
    # Arrange: the three collections are loaded at import.
    # Act: measure each collection.
    sizes = (len(MODULE_GLOBS), len(SHARED_SURFACES), len(SHARED_SURFACE_GLOBS))

    # Assert: an empty collection would silently generate zero parametrized
    # cases, so each one must be populated for the pinning tests to have force.
    assert all(size > 0 for size in sizes), (
        "config/blast-radius.json must populate modules, shared_surfaces, and "
        f"shared_surface_globs; observed sizes {sizes}."
    )


@pytest.mark.parametrize(("module_name", "globs"), MODULE_GLOBS)
def test_every_module_maps_to_a_non_empty_glob_list(
    module_name: str, globs: tuple[str, ...]
) -> None:
    """Require each module in the map to carry at least one path glob."""
    # Arrange: the module name and its globs are supplied by parametrization.
    # Act / Assert: a module with no globs can never resolve a path, so the
    # module would be unreachable and module-level overlap silently narrower.
    assert globs, (
        f'config["modules"]["{module_name}"] must list at least one glob; an '
        "empty list makes the module unreachable during resolution."
    )


def test_over_breadth_fraction_is_within_the_open_unit_interval() -> None:
    """Pin the V3 threshold to the ``(0, 1]`` range the validator accepts."""
    # Arrange: read the threshold as an unconstrained object.
    fraction = CONFIG.get("over_breadth_fraction")

    # Act: reject booleans explicitly, since Python treats them as integers and
    # a boolean would otherwise satisfy the numeric range comparison.
    is_number = isinstance(fraction, (int, float)) and not isinstance(fraction, bool)

    # Assert: the value is a real number inside (0, 1]; zero or a negative value
    # would make every radius over-broad and a value above 1 unreachable.
    assert is_number, (
        'config["over_breadth_fraction"] must be a number, got '
        f"{type(fraction).__name__}."
    )
    assert 0 < cast("float", fraction) <= 1, (
        'config["over_breadth_fraction"] must be within (0, 1], got ' f"{fraction!r}."
    )


@pytest.mark.parametrize("surface", SHARED_SURFACES)
def test_every_shared_surface_is_a_repo_relative_path(surface: str) -> None:
    """Require each enumerated shared surface to be a repo-relative path."""
    # Arrange: split into segments so a ``..`` component is detected exactly
    # rather than by substring match, which would reject a legitimate name.
    segments = surface.split("/")

    # Act / Assert: an absolute, drive-qualified, or parent-relative entry could
    # never equal a repository-relative path from a diff or a plan, so the
    # surface would never be recognized as touched.
    assert not surface.startswith(
        "/"
    ), f"Shared surface {surface!r} must be repo-relative, not absolute."
    assert (
        DRIVE_SEPARATOR not in surface
    ), f"Shared surface {surface!r} must be repo-relative, not drive-qualified."
    assert (
        PARENT_SEGMENT not in segments
    ), f"Shared surface {surface!r} must not contain a '..' segment."


@pytest.mark.parametrize("pattern", SHARED_SURFACE_GLOBS)
def test_every_shared_surface_glob_contains_a_wildcard(pattern: str) -> None:
    """Require each membership glob to carry a wildcard character."""
    # Arrange / Act: the pattern is supplied by parametrization.
    # Assert: a wildcard-free pattern belongs in the literal shared_surfaces
    # list; leaving it here would hide it from the enumeration V2 checks.
    assert "*" in pattern, (
        f"Shared-surface glob {pattern!r} must contain '*'; a concrete path "
        "belongs in the shared_surfaces list instead."
    )


# The separator-free subset of the committed shared_surfaces list. These are the
# entries Gap 1 (issue #452) made reachable through `config_root_surfaces`, and the
# only entries a bare inline-code token can match exactly.
SEPARATOR_FREE_SHARED_SURFACES: tuple[str, ...] = tuple(
    surface for surface in SHARED_SURFACES if "/" not in surface
)


@pytest.mark.parametrize("surface", SEPARATOR_FREE_SHARED_SURFACES)
def test_every_separator_free_shared_surface_is_wildcard_free(surface: str) -> None:
    """Require each separator-free shared surface to carry no wildcard.

    `config_root_surfaces` admits a separator-free entry as a concrete path
    token. A wildcard-bearing entry would classify as a glob instead, so the
    configured root surface would never be recognized as concrete and V2 could
    not enumerate it.
    """
    # Arrange / Act: the surface is supplied by parametrization.
    # Assert: neither supported wildcard may appear in a configured root surface.
    assert "*" not in surface, (
        f"Separator-free shared surface {surface!r} must not contain '*'; a "
        "wildcard entry belongs in the shared_surface_globs list instead."
    )
    assert "?" not in surface, (
        f"Separator-free shared surface {surface!r} must not contain '?'; a "
        "wildcard entry belongs in the shared_surface_globs list instead."
    )
