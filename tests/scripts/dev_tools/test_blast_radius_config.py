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

from scripts.dev_tools.compute_blast_radius import conflicts, derive_blast_radius

if TYPE_CHECKING:
    from collections.abc import Mapping

    from scripts.dev_tools.compute_blast_radius import BlastRadius, ConflictResult

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_blast_radius_config.py, so the repository root is
# three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CONFIG_PATH = REPO_ROOT / "config" / "blast-radius.json"

# The second committed copy of the truth table. The Claude push-down surface
# publishes it into a destination repository, so it is a separate artifact that
# can drift from the repo-root copy and must be pinned alongside it.
BUNDLED_CONFIG_PATH = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "claude-customizations"
    / "config"
    / "blast-radius.json"
)

# Timestamp handed to every derived radius below. The value is a constant rather
# than a clock read so the derivation tests are deterministic.
COMPUTED_AT = "2026-08-15T09-48"

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


def load_config_file(path: Path) -> Mapping[str, object]:
    """Read and parse one committed blast-radius truth table.

    Args:
        path (Path): Absolute path to a committed ``blast-radius.json`` copy.

    Returns:
        Mapping[str, object]: The parsed top-level configuration object.

    Raises:
        TypeError: If the file does not parse to a JSON object.

    Side Effects:
        Reads the named file. Every copy this module reads is committed and
        read-only for these tests; no temporary file is created.
    """
    parsed = cast("object", json.loads(path.read_text(encoding="utf-8")))
    if not isinstance(parsed, dict):
        raise TypeError(f"{path.name} must contain a JSON object.")
    return cast("Mapping[str, object]", parsed)


def load_config() -> Mapping[str, object]:
    """Read and parse the repo-root blast-radius truth table.

    Thin wrapper over ``load_config_file`` that names the repo-root copy once
    so its many consumers do not repeat the path.

    Returns:
        Mapping[str, object]: The parsed top-level configuration object.

    Raises:
        TypeError: If the file does not parse to a JSON object.

    Side Effects:
        Reads the committed, read-only ``config/blast-radius.json``.
    """
    return load_config_file(CONFIG_PATH)


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


def derive_item_radius(feature_folder: str, plan_text: str) -> BlastRadius:
    """Derive one work item's radius against the committed truth table.

    Args:
        feature_folder (str): Bare feature-folder name. Callers pass distinct
            names so the radii carry distinct feature-folder globs, making the
            verdict depend on the module map, not on a shared document tree.
        plan_text (str): Approved-plan text citing paths in inline code.

    Returns:
        BlastRadius: The derived radius, with a fixed timestamp.

    Side Effects:
        None beyond the module-level read of the committed configuration.
    """
    return derive_blast_radius(
        plan_text, "", feature_folder, CONFIG, computed_at=COMPUTED_AT
    )


def reason_kinds(result: ConflictResult) -> tuple[str, ...]:
    """Read the triggered contention kinds out of a conflict result.

    Args:
        result (ConflictResult): Verdict returned by ``conflicts``.

    Returns:
        tuple[str, ...]: The ``kind`` of each reason, in the fixed order the
        relation reports them.
    """
    # Reading only the kinds keeps the assertions independent of the
    # smallest-overlap detail, which differs between the pre- and post-fix maps.
    return tuple(reason.kind for reason in result.reasons)


def reason_detail(result: ConflictResult, kind: str) -> str:
    """Read the detail string of one triggered contention kind.

    Args:
        result (ConflictResult): Verdict returned by ``conflicts``.
        kind (str): Contention kind whose detail is wanted.

    Returns:
        str: The detail of the matching reason.

    Raises:
        AssertionError: If no reason of that kind is present, so the calling
            test fails instead of raising an opaque lookup error.
    """
    # A generator with next() would raise StopIteration on a miss; selecting the
    # matches first lets the assertion name the kind that was absent.
    matches = tuple(reason for reason in result.reasons if reason.kind == kind)
    assert matches, f"Expected a {kind} reason; observed {reason_kinds(result)}."
    return matches[0].detail


def test_disjoint_items_do_not_contend_through_the_committed_map() -> None:
    """Reject a module map that makes two unrelated work items contend.

    Two items with distinct feature folders and disjoint production paths must
    schedule concurrently. A location-bucket module keyed on where a file lives
    (``docs``, ``tests``) attaches to essentially every item, so it would make
    this pair contend at the module level and force an otherwise parallel run to
    execute serially (issue #472).
    """
    # Arrange: two work items whose only structural similarity is that each
    # writes its own feature folder and its own tests.
    benchmarks_item = derive_item_radius(
        "2026-08-15-example-benchmark-item",
        "- [ ] [P1-T1] Edit `scripts/benchmarks/run.py` and "
        "`tests/benchmarks/test_run.py`.",
    )
    extension_item = derive_item_radius(
        "2026-08-15-example-extension-item",
        "- [ ] [P1-T1] Edit `extensions/drm-copilot/src/lib/foo.ts`.",
    )

    # Act: ask the contention relation whether the two items may run together.
    result = conflicts(benchmarks_item, extension_item, CONFIG)

    # Assert: no disjunct may fire. The reason tuple is asserted empty as well as
    # the verdict so a failure names which level forced the false contention.
    assert result.conflict is False, (
        "Two items with disjoint production paths must not contend; observed "
        f"reasons {tuple((r.kind, r.detail) for r in result.reasons)}."
    )
    assert result.reasons == (), (
        "A disjoint item pair must report zero contention reasons; observed "
        f"{tuple((r.kind, r.detail) for r in result.reasons)}."
    )


# Paths the behaviour-preservation matrix has both items cite. Each names a real
# contention level that must keep firing after the location-bucket modules are
# removed: a production module file, a test file, and a declared shared surface.
SHARED_DEV_TOOLS_PATH = "scripts/dev_tools/example_shared.py"
SHARED_TEST_PATH = "tests/scripts/dev_tools/test_example_shared.py"
SHARED_CONFIG_SURFACE = "config/blast-radius.json"


def derive_matrix_pair(path: str) -> tuple[BlastRadius, BlastRadius]:
    """Derive two radii whose plans cite the same single path.

    Args:
        path (str): Repository-relative path both work items cite.

    Returns:
        tuple[BlastRadius, BlastRadius]: The two radii. Their feature folders
        differ, so the shared path is their only deliberate commonality.
    """
    citation = f"- [ ] [P1-T1] Edit `{path}`."
    return (
        derive_item_radius("2026-08-15-example-matrix-left", citation),
        derive_item_radius("2026-08-15-example-matrix-right", citation),
    )


def test_items_sharing_a_dev_tools_file_contend_on_path_and_module() -> None:
    """Preserve contention for two items editing the same production file."""
    # Arrange / Act: both items cite the same file under scripts/dev_tools/.
    left, right = derive_matrix_pair(SHARED_DEV_TOOLS_PATH)
    result = conflicts(left, right, CONFIG)
    kinds = reason_kinds(result)

    # Assert: the path level and the subsystem module level must both fire. The
    # module is asserted through the resolved module sets, not the reason detail,
    # because the detail reports the smallest shared module and that selection
    # differs while a location bucket is still present.
    assert result.conflict is True, "Items editing the same file must contend."
    assert "path_overlap" in kinds, f"Expected path_overlap; observed {kinds}."
    assert "module_overlap" in kinds, f"Expected module_overlap; observed {kinds}."
    assert "python-dev-tools" in left.modules, "Left item must resolve the module."
    assert "python-dev-tools" in right.modules, "Right item must resolve the module."


def test_items_sharing_only_a_test_file_contend_on_the_path_level() -> None:
    """Preserve contention for two items editing the same test file."""
    # Arrange / Act: both items cite the same file under tests/.
    left, right = derive_matrix_pair(SHARED_TEST_PATH)
    result = conflicts(left, right, CONFIG)

    # Assert: removing the tests location bucket must not stop two items editing
    # the same test file from contending; the path level carries that case.
    assert result.conflict is True, "Items editing the same test file must contend."
    assert "path_overlap" in reason_kinds(result), (
        "Expected path_overlap for a shared test file; observed "
        f"{reason_kinds(result)}."
    )
    assert (
        reason_detail(result, "path_overlap")
        == f"{SHARED_TEST_PATH} ~ {SHARED_TEST_PATH}"
    ), "The path_overlap detail must cite the shared test file."


def test_items_sharing_the_truth_table_contend_on_three_levels() -> None:
    """Preserve contention for two items editing the blast-radius truth table."""
    # Arrange / Act: both items cite config/blast-radius.json, which is itself a
    # declared shared surface as well as a member of the config module.
    left, right = derive_matrix_pair(SHARED_CONFIG_SURFACE)
    result = conflicts(left, right, CONFIG)
    kinds = reason_kinds(result)

    # Assert: all three applicable levels must fire.
    assert result.conflict is True, "Items editing the truth table must contend."
    assert "path_overlap" in kinds, f"Expected path_overlap; observed {kinds}."
    assert "module_overlap" in kinds, f"Expected module_overlap; observed {kinds}."
    assert "config" in left.modules, "Left item must resolve the config module."
    assert "config" in right.modules, "Right item must resolve the config module."
    assert (
        "shared_surface_overlap" in kinds
    ), f"Expected shared_surface_overlap; observed {kinds}."
    assert (
        reason_detail(result, "shared_surface_overlap") == SHARED_CONFIG_SURFACE
    ), "The shared_surface_overlap detail must cite the truth table itself."


# Location-bucket module names and globs: buckets keyed on where a file lives
# rather than on which subsystem owns it. Such a bucket attaches to nearly every
# work item, so it makes every pair contend at the module level (issue #472).
LOCATION_BUCKET_NAMES = ("docs", "tests")
LOCATION_BUCKET_GLOBS = ("docs/**", "tests/**")

# Both committed copies, labelled by repo-relative path so a parametrized
# failure names the offending file.
BUNDLED_CONFIG_LABEL = (
    "extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json"
)
COMMITTED_CONFIGS: tuple[tuple[str, Path], ...] = (
    ("config/blast-radius.json", CONFIG_PATH),
    (BUNDLED_CONFIG_LABEL, BUNDLED_CONFIG_PATH),
)


@pytest.mark.parametrize(("label", "path"), COMMITTED_CONFIGS)
def test_no_committed_copy_declares_a_location_bucket_module(
    label: str, path: Path
) -> None:
    """Reject a location-bucket module in either committed truth table."""
    # Arrange: read the copy under test rather than the module-level CONFIG, so
    # the bundled copy is pinned by the same assertions as the repo-root one.
    pairs = load_module_globs(load_config_file(path))
    names = tuple(name for name, _ in pairs)
    globs = tuple(glob for _, entries in pairs for glob in entries)

    # Assert: neither the bucket name nor its glob may appear anywhere in the
    # map. Both are checked because a rename would defeat a name-only pin.
    for bucket in LOCATION_BUCKET_NAMES:
        assert bucket not in names, f"{label} must not declare module {bucket!r}."
    for bucket in LOCATION_BUCKET_GLOBS:
        assert bucket not in globs, f"{label} must not declare glob {bucket!r}."
