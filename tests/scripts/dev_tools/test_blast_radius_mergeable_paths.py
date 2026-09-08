"""Reader and matcher tests for the ``mergeable_paths`` truth-table key.

Cover the leaf module ``scripts/dev_tools/_blast_radius_mergeable.py`` added by
issue #643: the optional-key reader, the three-step matcher, and the exclusion
filter, plus the shape of the key in both committed truth tables and its
re-export from the facade. Every configuration used here is an in-memory
literal or a committed truth table; no temporary file is created and no
external process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import _blast_radius_mergeable, compute_blast_radius
from scripts.dev_tools._blast_radius_mergeable import (
    config_mergeable_paths,
    exclude_mergeable_paths,
    matches_mergeable_path,
)
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    conflicts,
    derive_blast_radius,
    validate_blast_radius,
)
from scripts.dev_tools.parallel_drift_detection import detect_escaped_paths

if TYPE_CHECKING:
    from collections.abc import Mapping

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py, so the
# repository root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CONFIG_PATH = REPO_ROOT / "config" / "blast-radius.json"
BUNDLED_CONFIG_PATH = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "claude-customizations"
    / "config"
    / "blast-radius.json"
)

# The five default entries, in the order both committed copies declare them.
DEFAULT_MERGEABLE_PATHS = (
    "**/*.csproj",
    "**/packages.config",
    "**/app.config",
    "**/*.vbproj",
    "**/*.props",
)

# Timestamp handed to every radius built below. A constant rather than a clock
# read keeps the contention tests deterministic.
COMPUTED_AT = "2026-09-07T15-00"

# The shared project file and the two private sources of the contention pair.
SHARED_PROJECT_FILE = "QuickFiler.Test/QuickFiler.Test.csproj"
PRIVATE_SOURCE = "QuickFiler.Test/A.cs"
FEATURE_FOLDER = "2026-09-07-example-mergeable"

# A plan citing one project file and one private source. Both are genuine write
# claims, so the derived radius must list both whatever the exclusion says.
PROJECT_CITING_PLAN = "\n".join(
    [
        "### Phase 1 - Implementation",
        f"- [ ] [P1-T1] Edit `{SHARED_PROJECT_FILE}` and `{PRIVATE_SOURCE}`.",
    ]
)

# Tracked-file count handed to V3, large enough that a small radius never trips
# the over-breadth advisory and the tests stay focused on V1 and V2.
TRACKED_FILE_COUNT = 5000


def radius(paths: tuple[str, ...]) -> BlastRadius:
    """Build a declared radius carrying only the supplied paths.

    Args:
        paths (tuple[str, ...]): Repository-relative entries for the radius.

    Returns:
        BlastRadius: A radius with empty modules, surfaces, and contracts, so
        the contention verdict is decided by the path level alone.
    """
    return BlastRadius(
        paths=paths,
        modules=(),
        shared_surfaces=(),
        contracts=(),
        source="declared",
        computed_at=COMPUTED_AT,
    )


def load_config(path: Path) -> dict[str, object]:
    """Load a committed truth table from disk.

    Args:
        path (Path): Absolute path to a ``blast-radius.json`` copy.

    Returns:
        dict[str, object]: The parsed mapping.
    """
    parsed: dict[str, object] = json.loads(path.read_text(encoding="utf-8"))
    return parsed


@pytest.fixture
def defaults() -> tuple[str, ...]:
    """Supply the five default patterns to the matcher and filter tests.

    Returns:
        tuple[str, ...]: ``DEFAULT_MERGEABLE_PATHS``, in declared order.
    """
    return DEFAULT_MERGEABLE_PATHS


def test_config_mergeable_paths_returns_the_present_entries_sorted() -> None:
    """A present key yields its entries deduplicated and ordinally sorted."""
    # Arrange: entries supplied unsorted, with one duplicate.
    config: Mapping[str, object] = {
        "mergeable_paths": ["**/packages.config", "**/*.csproj", "**/*.csproj"]
    }

    # Act
    result = config_mergeable_paths(config)

    # Assert
    assert result == ("**/*.csproj", "**/packages.config")


def test_config_mergeable_paths_absent_key_yields_an_empty_tuple() -> None:
    """An absent key excludes nothing, reproducing pre-change behaviour."""
    # Arrange: a minimal config carrying another key but not this one.
    config: Mapping[str, object] = {"mandate_reads": ["quality-tiers.yml"]}

    # Act
    result = config_mergeable_paths(config)

    # Assert
    assert result == ()


def test_config_mergeable_paths_rejects_a_non_list_value() -> None:
    """A scalar value is a malformed table, not an implicit one-entry list."""
    # Arrange
    config: Mapping[str, object] = {"mergeable_paths": "**/*.csproj"}

    # Act / Assert
    with pytest.raises(TypeError, match="must be a list or tuple"):
        config_mergeable_paths(config)


def test_config_mergeable_paths_rejects_a_blank_entry() -> None:
    """A blank entry would match nothing and is rejected at read time."""
    # Arrange
    config: Mapping[str, object] = {"mergeable_paths": ["**/*.csproj", "   "]}

    # Act / Assert
    with pytest.raises(ValueError, match="must not be empty"):
        config_mergeable_paths(config)


def test_matches_mergeable_path_matches_a_root_level_file_for_a_double_star_prefix(
    defaults: tuple[str, ...],
) -> None:
    """The anchor-stripping step admits a file that sits at the repository root.

    Args:
        defaults (tuple[str, ...]): The five configured patterns.
    """
    # Arrange / Act / Assert: a wildcard-free remainder is compared for ordinal
    # equality, and a remainder that keeps a wildcard is matched as a glob.
    assert matches_mergeable_path("packages.config", defaults) is True
    assert matches_mergeable_path("Foo.csproj", defaults) is True


def test_matches_mergeable_path_never_treats_a_glob_entry_as_mergeable(
    defaults: tuple[str, ...],
) -> None:
    """A glob entry qualifies only by equalling a configured pattern verbatim.

    Args:
        defaults (tuple[str, ...]): The five configured patterns.
    """
    # Arrange / Act / Assert: a declared glob still contends, because pattern
    # subsumption is not decided; an exact repeat of a configured pattern does
    # qualify, because ordinal equality settles it.
    assert matches_mergeable_path("Proj/*.csproj", defaults) is False
    assert matches_mergeable_path("**/*.csproj", defaults) is True


def test_exclude_mergeable_paths_keeps_non_matching_entries_sorted(
    defaults: tuple[str, ...],
) -> None:
    """Survivors are the non-mergeable entries, deduplicated and sorted.

    Args:
        defaults (tuple[str, ...]): The five configured patterns.
    """
    # Arrange: two project files that must drop out and two sources that stay.
    entries = (
        "QuickFiler.Test/QuickFiler.Test.csproj",
        "QuickFiler.Test/B.cs",
        "QuickFiler.Test/A.cs",
        "packages.config",
    )

    # Act
    result = exclude_mergeable_paths(entries, defaults)

    # Assert
    assert result == ("QuickFiler.Test/A.cs", "QuickFiler.Test/B.cs")


def test_committed_mergeable_paths_is_a_non_empty_list_in_both_copies() -> None:
    """Both committed truth tables opt into the exclusion with a real list."""
    # Arrange / Act
    committed = config_mergeable_paths(load_config(CONFIG_PATH))
    bundled = config_mergeable_paths(load_config(BUNDLED_CONFIG_PATH))

    # Assert
    assert len(committed) > 0
    assert len(bundled) > 0


def test_committed_mergeable_paths_carries_the_five_default_entries() -> None:
    """Both copies declare the same five entries in the same order."""
    # Arrange / Act: read the raw values rather than the sorted reader output,
    # because the declared order is part of what the two copies must share.
    committed = load_config(CONFIG_PATH)["mergeable_paths"]
    bundled = load_config(BUNDLED_CONFIG_PATH)["mergeable_paths"]

    # Assert
    assert committed == list(DEFAULT_MERGEABLE_PATHS)
    assert bundled == list(DEFAULT_MERGEABLE_PATHS)


def test_facade_re_exports_the_mergeable_reader() -> None:
    """The facade exposes the same function object, not a wrapper."""
    # Assert
    assert (
        compute_blast_radius.config_mergeable_paths
        is _blast_radius_mergeable.config_mergeable_paths
    )


def test_conflicts_yields_no_edge_for_a_csproj_only_overlap(
    defaults: tuple[str, ...],
) -> None:
    """Two items whose only shared path is a project file do not contend.

    Args:
        defaults (tuple[str, ...]): The five configured patterns.
    """
    # Arrange
    config: Mapping[str, object] = {"mergeable_paths": list(defaults)}
    a = radius((SHARED_PROJECT_FILE, "QuickFiler.Test/A.cs"))
    b = radius((SHARED_PROJECT_FILE, "QuickFiler.Test/B.cs"))

    # Act
    result = conflicts(a, b, config)

    # Assert
    assert result.conflict is False
    assert result.reasons == ()


def test_conflicts_leaves_the_csproj_in_both_radii_paths(
    defaults: tuple[str, ...],
) -> None:
    """The exclusion filters copies, so neither radius record is rewritten.

    Args:
        defaults (tuple[str, ...]): The five configured patterns.
    """
    # Arrange
    config: Mapping[str, object] = {"mergeable_paths": list(defaults)}
    a = radius((SHARED_PROJECT_FILE, "QuickFiler.Test/A.cs"))
    b = radius((SHARED_PROJECT_FILE, "QuickFiler.Test/B.cs"))

    # Act
    conflicts(a, b, config)

    # Assert
    assert SHARED_PROJECT_FILE in a.paths
    assert SHARED_PROJECT_FILE in b.paths


def test_conflicts_still_contends_for_a_declared_glob_entry(
    defaults: tuple[str, ...],
) -> None:
    """A declared glob is never mergeable, so the pair still contends.

    Args:
        defaults (tuple[str, ...]): The five configured patterns.
    """
    # Arrange
    config: Mapping[str, object] = {"mergeable_paths": list(defaults)}
    a = radius(("Proj/**",))
    b = radius(("Proj/*.csproj",))

    # Act
    result = conflicts(a, b, config)

    # Assert
    assert result.conflict is True
    assert len(result.reasons) == 1
    assert result.reasons[0].kind == "path_overlap"
    assert result.reasons[0].detail == "Proj/** ~ Proj/*.csproj"


def test_conflicts_absent_key_and_empty_list_produce_identical_results() -> None:
    """An absent key and an empty list are the same fail-closed configuration."""
    # Arrange: the same pair judged under a config without the key and under a
    # config that declares it empty.
    without_key: Mapping[str, object] = {}
    empty_list: Mapping[str, object] = {"mergeable_paths": []}
    a = radius((SHARED_PROJECT_FILE, "QuickFiler.Test/A.cs"))
    b = radius((SHARED_PROJECT_FILE, "QuickFiler.Test/B.cs"))

    # Act
    absent_result = conflicts(a, b, without_key)
    empty_result = conflicts(a, b, empty_list)

    # Assert: both reproduce pre-change behaviour, which is a path overlap.
    assert absent_result == empty_result
    assert absent_result.conflict is True
    assert absent_result.reasons[0].kind == "path_overlap"


def test_validate_blast_radius_findings_are_identical_with_and_without_the_key() -> (
    None
):
    """V1, V2, and V3 read no mergeable key, so their findings cannot differ."""
    # Arrange: the committed table, and the same table with the key removed.
    with_key = load_config(CONFIG_PATH)
    without_key = {k: v for k, v in with_key.items() if k != "mergeable_paths"}

    # Act
    derived_with = derive_blast_radius(
        PROJECT_CITING_PLAN, "", FEATURE_FOLDER, with_key, computed_at=COMPUTED_AT
    )
    derived_without = derive_blast_radius(
        PROJECT_CITING_PLAN, "", FEATURE_FOLDER, without_key, computed_at=COMPUTED_AT
    )
    findings_with = validate_blast_radius(
        derived_with,
        PROJECT_CITING_PLAN,
        with_key,
        tracked_file_count=TRACKED_FILE_COUNT,
    )
    findings_without = validate_blast_radius(
        derived_without,
        PROJECT_CITING_PLAN,
        without_key,
        tracked_file_count=TRACKED_FILE_COUNT,
    )

    # Assert: identical findings, and the project file survives in both radii.
    assert tuple(findings_with) == tuple(findings_without)
    assert SHARED_PROJECT_FILE in derived_with.paths
    assert SHARED_PROJECT_FILE in derived_without.paths


def test_derive_blast_radius_keeps_a_cited_csproj_in_paths() -> None:
    """Derivation records every genuine write claim, mergeable shapes included."""
    # Arrange / Act
    derived = derive_blast_radius(
        PROJECT_CITING_PLAN,
        "",
        FEATURE_FOLDER,
        load_config(CONFIG_PATH),
        computed_at=COMPUTED_AT,
    )

    # Assert
    assert SHARED_PROJECT_FILE in derived.paths


def test_detect_escaped_paths_is_unaffected_by_the_key() -> None:
    """Drift detection compares observed against declared and reads no config.

    The truth-table key is not an input to ``detect_escaped_paths``, so an
    undeclared project file still escapes and a declared one still does not.
    """
    # Arrange / Act
    undeclared = detect_escaped_paths([SHARED_PROJECT_FILE], [PRIVATE_SOURCE])
    declared = detect_escaped_paths([SHARED_PROJECT_FILE], [SHARED_PROJECT_FILE])

    # Assert
    assert undeclared == (SHARED_PROJECT_FILE,)
    assert declared == ()
