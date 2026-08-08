"""Tests for the blast-radius contention relation and its reason records.

Cover the four disjuncts in isolation, glob-versus-concrete matching, the
fail-closed undecidable glob pair, empty-radius cases, the fixed reason order,
and the construction invariants of ``ConflictReason`` and ``ConflictResult``.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._blast_radius_glob import _entries_overlap
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    ConflictReason,
    ConflictResult,
    conflicts,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

COMPUTED_AT = "2026-08-07T12-00"

# The relation reads no key from the truth table; a minimal mapping is enough to
# satisfy the frozen signature.
CONFIG: Mapping[str, object] = {"version": 1, "over_breadth_fraction": 0.25}


def make_radius(
    *,
    paths: Sequence[str] = (),
    modules: Sequence[str] = (),
    shared_surfaces: Sequence[str] = (),
    contracts: Sequence[str] = (),
) -> BlastRadius:
    """Build a declared radius whose unspecified levels are empty."""
    return BlastRadius(
        paths=paths,
        modules=modules,
        shared_surfaces=shared_surfaces,
        contracts=contracts,
        source="declared",
        computed_at=COMPUTED_AT,
    )


def test_conflict_reason_rejects_an_unknown_kind() -> None:
    """Reject a reason kind outside the four contention levels."""
    with pytest.raises(ValueError, match="ConflictReason kind"):
        ConflictReason(kind="vibes_overlap", detail="d")


def test_conflict_reason_rejects_a_blank_detail() -> None:
    """Reject a reason that cites no evidence."""
    with pytest.raises(ValueError, match="detail must not be empty"):
        ConflictReason(kind="path_overlap", detail="  ")


def test_conflict_result_rejects_a_verdict_that_disagrees_with_its_reasons() -> None:
    """Reject a result whose verdict contradicts its reason list."""
    with pytest.raises(ValueError, match="conflict must be True"):
        ConflictResult(conflict=True, reasons=())


def test_conflict_result_rejects_reasons_out_of_the_fixed_order() -> None:
    """Reject reasons that do not follow the frozen kind order."""
    reasons = (
        ConflictReason(kind="module_overlap", detail="m"),
        ConflictReason(kind="path_overlap", detail="p"),
    )

    with pytest.raises(ValueError, match="must follow the order"):
        ConflictResult(conflict=True, reasons=reasons)


def test_path_overlap_triggers_on_identical_concrete_paths() -> None:
    """Report path overlap when both radii name the same file."""
    radius = make_radius(paths=["scripts/dev_tools/a.py"])

    result = conflicts(radius, radius, CONFIG)

    assert result.conflict is True
    assert [(r.kind, r.detail) for r in result.reasons] == [
        ("path_overlap", "scripts/dev_tools/a.py ~ scripts/dev_tools/a.py")
    ]


def test_distinct_concrete_paths_do_not_overlap() -> None:
    """Require equality between two concrete paths before reporting overlap."""
    result = conflicts(
        make_radius(paths=["scripts/dev_tools/a.py"]),
        make_radius(paths=["scripts/dev_tools/b.py"]),
        CONFIG,
    )

    assert result.conflict is False


def test_path_overlap_triggers_between_a_glob_and_a_concrete_path() -> None:
    """Match a concrete path against the other radius's glob."""
    result = conflicts(
        make_radius(paths=["scripts/dev_tools/**"]),
        make_radius(paths=["scripts/dev_tools/a.py"]),
        CONFIG,
    )

    assert [r.kind for r in result.reasons] == ["path_overlap"]


def test_path_overlap_triggers_when_the_glob_is_the_second_argument() -> None:
    """Apply the pattern match in either argument position."""
    result = conflicts(
        make_radius(paths=["scripts/dev_tools/a.py"]),
        make_radius(paths=["scripts/dev_tools/**"]),
        CONFIG,
    )

    assert [r.kind for r in result.reasons] == ["path_overlap"]


def test_path_overlap_fails_closed_for_an_undecidable_glob_pair() -> None:
    """Count a glob pair that cannot be proven disjoint as overlapping."""
    result = conflicts(
        make_radius(paths=["scripts/dev_tools/*.py"]),
        make_radius(paths=["scripts/dev_tools/validate_*.py"]),
        CONFIG,
    )

    assert result.conflict is True


def test_provably_disjoint_globs_do_not_conflict() -> None:
    """Separate two globs whose literal prefixes diverge."""
    result = conflicts(
        make_radius(paths=["scripts/**"]), make_radius(paths=["tests/**"]), CONFIG
    )

    assert result.conflict is False
    assert result.reasons == ()


def test_two_feature_folder_globs_do_not_conflict() -> None:
    """Keep two features' own document folders out of contention."""
    result = conflicts(
        make_radius(paths=["docs/features/active/alpha/**"]),
        make_radius(paths=["docs/features/active/beta/**"]),
        CONFIG,
    )

    assert result.conflict is False


def test_module_overlap_triggers_without_any_path_overlap() -> None:
    """Report module overlap as the second, wider net after paths."""
    result = conflicts(
        make_radius(paths=["docs/a.md"], modules=["docs"]),
        make_radius(paths=["tests/b.py"], modules=["docs"]),
        CONFIG,
    )

    assert [(r.kind, r.detail) for r in result.reasons] == [("module_overlap", "docs")]


def test_shared_surface_overlap_triggers_on_its_own() -> None:
    """Report shared-surface overlap independently of the other levels."""
    result = conflicts(
        make_radius(paths=["docs/a.md"], shared_surfaces=["poetry.lock"]),
        make_radius(paths=["tests/b.py"], shared_surfaces=["poetry.lock"]),
        CONFIG,
    )

    assert [(r.kind, r.detail) for r in result.reasons] == [
        ("shared_surface_overlap", "poetry.lock")
    ]


def test_contract_dependency_triggers_on_its_own() -> None:
    """Report a contract dependency from identifier equality alone."""
    result = conflicts(
        make_radius(paths=["docs/a.md"], contracts=["derive_example"]),
        make_radius(paths=["tests/b.py"], contracts=["derive_example"]),
        CONFIG,
    )

    assert [(r.kind, r.detail) for r in result.reasons] == [
        ("contract_dependency", "derive_example")
    ]


def test_empty_radii_do_not_conflict_with_each_other() -> None:
    """Treat two empty radii as non-contending."""
    assert conflicts(make_radius(), make_radius(), CONFIG).conflict is False


def test_an_empty_radius_does_not_conflict_with_a_populated_one() -> None:
    """Treat an empty radius as overlapping nothing at any level."""
    populated = make_radius(
        paths=["docs/a.md"], modules=["docs"], shared_surfaces=["poetry.lock"]
    )

    assert conflicts(make_radius(), populated, CONFIG).conflict is False


def test_all_triggered_reasons_are_reported_in_the_fixed_kind_order() -> None:
    """Report every triggered disjunct, ordered by the frozen kind sequence."""
    radius = make_radius(
        paths=["docs/a.md"],
        modules=["docs"],
        shared_surfaces=["poetry.lock"],
        contracts=["Alpha"],
    )

    result = conflicts(radius, radius, CONFIG)

    assert [r.kind for r in result.reasons] == [
        "path_overlap",
        "module_overlap",
        "shared_surface_overlap",
        "contract_dependency",
    ]
    assert all(reason.detail for reason in result.reasons)


def test_the_overlapping_pair_detail_is_ordered_ordinally() -> None:
    """Render the smaller entry of an overlapping pair first."""
    result = conflicts(
        make_radius(paths=["scripts/dev_tools/z.py"]),
        make_radius(paths=["scripts/dev_tools/**"]),
        CONFIG,
    )

    assert result.reasons[0].detail == (
        "scripts/dev_tools/**" " ~ " "scripts/dev_tools/z.py"
    )


def test_conflicts_rejects_a_non_mapping_config() -> None:
    """Fail fast when the truth table is not a mapping."""
    with pytest.raises(TypeError, match="config must be a mapping"):
        conflicts(make_radius(), make_radius(), cast("Mapping[str, object]", []))


# Direct coverage of the entry-level relation, added by issue #452. Before that
# issue the relation was reachable only through ``conflicts``, so the Gap 2
# under-reporting was invisible to the Python suite.

OVERLAPPING_ENTRY_PAIRS = [
    ("scripts/dev_tools", "scripts/dev_tools/a.py"),
    ("scripts/dev_tools/", "scripts/dev_tools/a.py"),
    ("docs", "docs/features/active/x/spec.md"),
    ("scripts/dev_tools", "scripts/dev_tools/**"),
    ("scripts/dev_tools", "scripts/dev_tools/*.py"),
    ("scripts/dev_tools", "scripts/*/a.py"),
]


@pytest.mark.parametrize(("entry_a", "entry_b"), OVERLAPPING_ENTRY_PAIRS)
def test_a_listed_directory_overlaps_what_lies_beneath_it(
    entry_a: str, entry_b: str
) -> None:
    """Report overlap when one entry names a directory containing the other."""
    assert _entries_overlap(entry_a, entry_b) is True


@pytest.mark.parametrize(("entry_a", "entry_b"), OVERLAPPING_ENTRY_PAIRS)
def test_the_entry_relation_is_symmetric_for_overlapping_pairs(
    entry_a: str, entry_b: str
) -> None:
    """Return the same verdict regardless of the argument order."""
    assert _entries_overlap(entry_b, entry_a) is True


def test_a_directory_entry_overlaps_a_file_beneath_it() -> None:
    """Mirror the inverted Pester assertion in ``BlastRadiusGlob.Tests.ps1``.

    The PowerShell suite previously asserted the Gap 2 defect as intended
    behaviour. This is the Python counterpart of the corrected assertion.
    """
    assert _entries_overlap("scripts/dev_tools", "scripts/dev_tools/a.py") is True


# Regression guards. These pairs are disjoint today and must stay disjoint: the
# Gap 2 correction widens the relation, and widening past these pairs would make
# unrelated work items contend.

DISJOINT_ENTRY_PAIRS = [
    ("scripts/dev_tools", "scripts/dev_toolsX/a.py"),
    ("scripts/dev_tools/a.py", "scripts/dev_tools/b.py"),
    ("docs/features/active/alpha", "docs/features/active/beta/**"),
    ("scripts/a.py", "tests/**"),
]


@pytest.mark.parametrize(("entry_a", "entry_b"), DISJOINT_ENTRY_PAIRS)
def test_unrelated_entries_do_not_overlap(entry_a: str, entry_b: str) -> None:
    """Keep a sibling prefix, two peer files, and diverging roots disjoint."""
    assert _entries_overlap(entry_a, entry_b) is False


@pytest.mark.parametrize(("entry_a", "entry_b"), DISJOINT_ENTRY_PAIRS)
def test_the_entry_relation_is_symmetric_for_disjoint_pairs(
    entry_a: str, entry_b: str
) -> None:
    """Return the same disjoint verdict regardless of the argument order."""
    assert _entries_overlap(entry_b, entry_a) is False


# Monotonicity guard for the fail-closed invariant O_old subset-of O_new. These
# are every pair the pre-change baseline recorded as overlapping. Widening the
# relation must never drop one of them, because reporting LESS contention is a
# regression rather than a fix. The PowerShell mirror asserts the identical set.

PREVIOUSLY_OVERLAPPING_ENTRY_PAIRS = [
    ("scripts/dev_tools", "scripts/**"),
    ("scripts/dev_tools/**", "scripts/dev_tools/compute_blast_radius.py"),
    ("shared.py", "shared.py"),
    ("scripts/*/alpha.py", "scripts/*/beta.py"),
]


@pytest.mark.parametrize(("entry_a", "entry_b"), PREVIOUSLY_OVERLAPPING_ENTRY_PAIRS)
def test_widening_the_relation_never_drops_a_prior_overlap(
    entry_a: str, entry_b: str
) -> None:
    """Keep every pre-change overlapping pair overlapping after the widening."""
    assert _entries_overlap(entry_a, entry_b) is True
