"""Tests for the blast-radius validation rules V1, V2, and V3.

Cover coverage findings (V1), shared-surface enumeration findings (V2), the
over-breadth threshold boundary (V3), finding ordering, and the fail-fast guards
on the tracked-file count and the truth table.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    derive_blast_radius,
    validate_blast_radius,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

COMPUTED_AT = "2026-08-07T12-00"

# Truth table used by every test. It is a reduced but shape-faithful copy of
# ``config/blast-radius.json`` so the tests stay independent of that file.
CONFIG: Mapping[str, object] = {
    "version": 1,
    "shared_surfaces": ["config/orchestration-routing.json", "poetry.lock"],
    "shared_surface_globs": ["scripts/dev_tools/validate_*.py"],
    "modules": {
        "config": ["config/**"],
        "docs": ["docs/**"],
        "python-dev-tools": ["scripts/dev_tools/**"],
        "tests": ["tests/**"],
    },
    "over_breadth_fraction": 0.25,
}


def make_radius(
    *,
    paths: Sequence[str] = (),
    shared_surfaces: Sequence[str] = (),
) -> BlastRadius:
    """Build a declared radius whose unspecified levels are empty."""
    return BlastRadius(
        paths=paths,
        modules=(),
        shared_surfaces=shared_surfaces,
        contracts=(),
        source="declared",
        computed_at=COMPUTED_AT,
    )


def test_v1_reports_a_plan_path_the_radius_does_not_cover() -> None:
    """Emit one Blocking V1 finding naming the uncovered plan path."""
    plan = "- [ ] [P1-T1] Edit `scripts/dev_tools/example.py`."
    radius = make_radius(paths=["docs/other.md"])

    findings = validate_blast_radius(radius, plan, CONFIG, tracked_file_count=100)

    assert [(f.rule, f.severity, f.subject) for f in findings] == [
        ("V1", "Blocking", "scripts/dev_tools/example.py")
    ]


def test_v1_accepts_a_plan_path_covered_by_a_glob() -> None:
    """Treat a glob entry as covering the concrete paths beneath it."""
    plan = "- [ ] [P1-T1] Edit `scripts/dev_tools/example.py`."
    radius = make_radius(paths=["scripts/dev_tools/**"])

    assert validate_blast_radius(radius, plan, CONFIG, tracked_file_count=100) == []


def test_v1_accepts_a_plan_path_covered_by_a_listed_directory() -> None:
    """Treat a wildcard-free directory entry as covering everything beneath it."""
    plan = "- [ ] [P1-T1] Edit `scripts/dev_tools/example.py`."
    radius = make_radius(paths=["scripts/dev_tools"])

    assert validate_blast_radius(radius, plan, CONFIG, tracked_file_count=100) == []


def test_v2_reports_a_shared_surface_covered_only_by_a_glob() -> None:
    """Require explicit enumeration even when a glob already covers the surface."""
    plan = "- [ ] [P1-T1] Edit `config/orchestration-routing.json`."
    radius = make_radius(paths=["config/**"])

    findings = validate_blast_radius(radius, plan, CONFIG, tracked_file_count=100)

    assert [(f.rule, f.severity, f.subject) for f in findings] == [
        ("V2", "Blocking", "config/orchestration-routing.json")
    ]


def test_v2_reports_a_surface_matched_by_a_membership_glob() -> None:
    """Count a glob-matched file as a shared surface needing enumeration."""
    plan = "- [ ] [P1-T1] Edit `scripts/dev_tools/validate_json.py`."
    radius = make_radius(paths=["scripts/dev_tools/validate_json.py"])

    findings = validate_blast_radius(radius, plan, CONFIG, tracked_file_count=100)

    assert [(f.rule, f.subject) for f in findings] == [
        ("V2", "scripts/dev_tools/validate_json.py")
    ]


def test_v2_accepts_an_explicitly_enumerated_shared_surface() -> None:
    """Accept a radius that names the touched surface by concrete path."""
    plan = "- [ ] [P1-T1] Edit `config/orchestration-routing.json`."
    radius = make_radius(
        paths=["config/orchestration-routing.json"],
        shared_surfaces=["config/orchestration-routing.json"],
    )

    assert validate_blast_radius(radius, plan, CONFIG, tracked_file_count=100) == []


@pytest.mark.parametrize(("path_count", "expected"), [(25, 0), (26, 1)])
def test_v3_triggers_only_above_the_over_breadth_fraction(
    path_count: int, expected: int
) -> None:
    """Report over-breadth strictly above the threshold, never exactly at it."""
    # A distinct concrete path per slot so the radius coverage equals the count.
    radius = make_radius(
        paths=[f"docs/file{index:03d}.md" for index in range(path_count)]
    )

    findings = validate_blast_radius(radius, "", CONFIG, tracked_file_count=100)

    assert len(findings) == expected


def test_v3_is_advisory_and_emits_at_most_one_finding() -> None:
    """Report an over-broad radius once, at Advisory severity."""
    # Far more concrete paths than the threshold allows, so the rule must fire.
    radius = make_radius(paths=[f"docs/file{index:03d}.md" for index in range(60)])

    findings = validate_blast_radius(radius, "", CONFIG, tracked_file_count=100)

    assert [(f.rule, f.severity, f.subject) for f in findings] == [
        ("V3", "Advisory", "blast_radius.paths")
    ]


def test_v3_ignores_glob_entries_when_measuring_coverage() -> None:
    """Measure over-breadth from concrete entries only, not from globs."""
    radius = make_radius(paths=[f"docs/dir{index:03d}/**" for index in range(60)])

    assert validate_blast_radius(radius, "", CONFIG, tracked_file_count=100) == []


def test_findings_are_sorted_by_rule_then_subject() -> None:
    """Order findings deterministically across rules and subjects."""
    plan = (
        "- [ ] [P1-T1] Edit `scripts/dev_tools/zeta.py` and "
        "`scripts/dev_tools/alpha.py` and `config/orchestration-routing.json`."
    )
    radius = make_radius(paths=["config/orchestration-routing.json"])

    findings = validate_blast_radius(radius, plan, CONFIG, tracked_file_count=100)

    assert [(f.rule, f.subject) for f in findings] == [
        ("V1", "scripts/dev_tools/alpha.py"),
        ("V1", "scripts/dev_tools/zeta.py"),
        ("V2", "config/orchestration-routing.json"),
    ]


def test_validation_rejects_a_non_positive_tracked_file_count() -> None:
    """Fail fast when the caller supplies an unusable tracked-file count."""
    with pytest.raises(ValueError, match="positive integer"):
        validate_blast_radius(make_radius(), "", CONFIG, tracked_file_count=0)


def test_validation_rejects_a_non_integer_tracked_file_count() -> None:
    """Fail fast when the tracked-file count is not an integer."""
    with pytest.raises(TypeError, match="must be an integer"):
        validate_blast_radius(
            make_radius(), "", CONFIG, tracked_file_count=cast("int", "100")
        )


def test_validation_rejects_non_string_plan_text() -> None:
    """Fail fast when the plan text is not a string."""
    with pytest.raises(TypeError, match="plan_text must be a string"):
        validate_blast_radius(
            make_radius(), cast("str", None), CONFIG, tracked_file_count=100
        )


@pytest.mark.parametrize(
    "bad_config",
    [
        {"over_breadth_fraction": "0.25"},
        {"over_breadth_fraction": True},
        {},
    ],
)
def test_validation_rejects_a_malformed_over_breadth_threshold(
    bad_config: Mapping[str, object],
) -> None:
    """Fail fast when the V3 threshold is absent or not a real number."""
    with pytest.raises(TypeError, match="over_breadth_fraction"):
        validate_blast_radius(make_radius(), "", bad_config, tracked_file_count=100)


def test_validation_rejects_an_out_of_range_over_breadth_threshold() -> None:
    """Fail fast when the V3 threshold falls outside the unit interval."""
    with pytest.raises(ValueError, match="within"):
        validate_blast_radius(
            make_radius(), "", {"over_breadth_fraction": 1.5}, tracked_file_count=100
        )


def test_validation_rejects_a_malformed_shared_surface_list() -> None:
    """Fail fast when a truth-table surface list is not a list of strings."""
    bad_config: Mapping[str, object] = {
        "shared_surfaces": "config/blast-radius.json",
        "over_breadth_fraction": 0.5,
    }

    with pytest.raises(TypeError, match="must be a list or tuple"):
        validate_blast_radius(make_radius(), "", bad_config, tracked_file_count=100)


def test_derivation_rejects_a_malformed_module_map() -> None:
    """Fail fast when the truth table's module map is not a mapping."""
    bad_config: Mapping[str, object] = {
        "modules": ["docs"],
        "over_breadth_fraction": 0.5,
    }

    with pytest.raises(TypeError, match="must be a mapping"):
        derive_blast_radius("", "", "f", bad_config, computed_at="t")


def test_derivation_rejects_a_non_string_module_name() -> None:
    """Fail fast when a module map key is not a string."""
    bad_config: Mapping[str, object] = {"modules": {1: ["docs/**"]}}

    with pytest.raises(TypeError, match="must be a string"):
        derive_blast_radius("", "", "f", bad_config, computed_at="t")
