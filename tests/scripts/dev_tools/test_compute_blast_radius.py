"""Tests for the blast-radius data model and the two derivation entry points.

Cover construction invariants and serialization of ``BlastRadius``, the
``RadiusFinding`` vocabulary, derivation from plan and spec text, and radii
built from an observed diff path list. Validation rules live in
``test_blast_radius_validation.py`` and contention in
``test_blast_radius_conflicts.py``, mirroring the production module split.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    RadiusFinding,
    derive_blast_radius,
    radius_from_observed_paths,
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

PLAN_TEXT = """### Phase 1 — Implementation

- [ ] [P1-T1] Create `scripts/dev_tools/example.py` and edit \
`config/orchestration-routing.json`.
- [ ] [P1-T2] Add `tests/scripts/dev_tools/test_example.py`.

Evidence lands in `docs/notes.md`.
"""

SPEC_TEXT = """# Feature

## Overview

Touches `scripts/dev_tools/helper.py`.

## Public API Contract

Exposes `derive_example` and `ExampleResult`.
"""


def make_radius(
    *,
    paths: Sequence[str] = (),
    modules: Sequence[str] = (),
    shared_surfaces: Sequence[str] = (),
    contracts: Sequence[str] = (),
    source: str = "declared",
) -> BlastRadius:
    """Build a radius whose unspecified levels are empty."""
    return BlastRadius(
        paths=paths,
        modules=modules,
        shared_surfaces=shared_surfaces,
        contracts=contracts,
        source=source,
        computed_at=COMPUTED_AT,
    )


def test_blast_radius_sorts_and_deduplicates_every_collection() -> None:
    """Normalize collections ordinally at construction regardless of input order."""
    radius = make_radius(paths=["b.md", "a.md", "b.md"], modules=["z", "a"])

    assert radius.paths == ("a.md", "b.md")
    assert radius.modules == ("a", "z")


def test_blast_radius_sorts_ordinally_not_case_insensitively() -> None:
    """Order uppercase before lowercase, matching ordinal string comparison."""
    radius = make_radius(contracts=["beta", "Alpha", "Zeta"])

    assert radius.contracts == ("Alpha", "Zeta", "beta")


@pytest.mark.parametrize("source", ["derived", "declared", "observed"])
def test_blast_radius_accepts_each_confidence_source(source: str) -> None:
    """Admit exactly the three documented confidence sources."""
    assert make_radius(source=source).source == source


def test_blast_radius_rejects_unknown_source() -> None:
    """Reject a source outside the frozen three-value vocabulary."""
    with pytest.raises(ValueError, match="source must be one of"):
        make_radius(source="guessed")


def test_blast_radius_rejects_non_string_path_entry() -> None:
    """Reject a collection entry that is not a string."""
    with pytest.raises(TypeError, match="paths entry must be a string"):
        make_radius(paths=cast("Sequence[str]", [1]))


def test_blast_radius_rejects_a_blank_collection_entry() -> None:
    """Reject a blank collection entry so an empty citation fails fast."""
    with pytest.raises(ValueError, match="contracts entry must not be empty"):
        make_radius(contracts=["  "])


def test_blast_radius_rejects_a_bare_string_collection() -> None:
    """Reject a bare string, which would otherwise split into characters."""
    with pytest.raises(TypeError, match="paths must be a list or tuple"):
        make_radius(paths=cast("Sequence[str]", "docs/a.md"))


def test_blast_radius_rejects_blank_computed_at() -> None:
    """Reject a blank timestamp so an unset caller value fails fast."""
    with pytest.raises(ValueError, match="computed_at must not be empty"):
        BlastRadius(
            paths=(),
            modules=(),
            shared_surfaces=(),
            contracts=(),
            source="derived",
            computed_at="   ",
        )


def test_to_dict_exposes_exactly_the_frozen_key_set() -> None:
    """Serialize the six manifest keys and nothing else."""
    serialized = make_radius(paths=["docs/a.md"]).to_dict()

    assert set(serialized) == {
        "paths",
        "modules",
        "shared_surfaces",
        "contracts",
        "source",
        "computed_at",
    }
    assert serialized["paths"] == ["docs/a.md"]


def test_from_dict_round_trip_reproduces_an_equal_radius() -> None:
    """Reconstruct an equal radius from a serialized dict."""
    radius = make_radius(
        paths=["docs/a.md"], modules=["docs"], shared_surfaces=[], contracts=["Alpha"]
    )

    assert BlastRadius.from_dict(radius.to_dict()) == radius


def test_from_dict_rejects_a_missing_key() -> None:
    """Reject a dict missing a manifest key rather than defaulting it away."""
    payload = make_radius().to_dict()
    del payload["contracts"]

    with pytest.raises(ValueError, match="missing keys"):
        BlastRadius.from_dict(payload)


def test_from_dict_rejects_an_unexpected_key() -> None:
    """Reject an unknown key rather than silently dropping its data."""
    payload = make_radius().to_dict()
    payload["extra"] = []

    with pytest.raises(ValueError, match="unexpected keys"):
        BlastRadius.from_dict(payload)


@pytest.mark.parametrize(("rule", "severity"), [("V4", "Blocking"), ("V1", "Warning")])
def test_radius_finding_rejects_out_of_vocabulary_values(
    rule: str, severity: str
) -> None:
    """Reject a finding whose rule or severity is outside its vocabulary."""
    with pytest.raises(ValueError, match="RadiusFinding"):
        RadiusFinding(rule=rule, severity=severity, subject="s", message="m")


def test_radius_finding_rejects_a_blank_subject() -> None:
    """Reject a finding that names no subject."""
    with pytest.raises(ValueError, match="subject must not be empty"):
        RadiusFinding(rule="V1", severity="Blocking", subject=" ", message="m")


def derive_sample() -> BlastRadius:
    """Derive the radius the derivation tests share."""
    return derive_blast_radius(
        PLAN_TEXT, SPEC_TEXT, "2026-08-07-example-1", CONFIG, computed_at=COMPUTED_AT
    )


def test_derivation_collects_plan_spec_and_feature_folder_paths() -> None:
    """Gather paths from plan tasks, plan prose, the spec, and the feature folder."""
    radius = derive_sample()

    assert radius.paths == (
        "config/orchestration-routing.json",
        "docs/features/active/2026-08-07-example-1/**",
        "docs/notes.md",
        "scripts/dev_tools/example.py",
        "scripts/dev_tools/helper.py",
        "tests/scripts/dev_tools/test_example.py",
    )


def test_derivation_resolves_modules_from_the_config_map() -> None:
    """Resolve every matching module name and omit the unmatched ones."""
    assert derive_sample().modules == ("config", "docs", "python-dev-tools", "tests")


def test_derivation_records_no_module_for_an_unmapped_path() -> None:
    """Resolve no module for a path that matches no configured glob."""
    radius = derive_blast_radius(
        "- [ ] [P1-T1] Edit `schemas/thing.json`.",
        "",
        "f",
        CONFIG,
        computed_at=COMPUTED_AT,
    )

    assert "schemas/thing.json" in radius.paths
    assert radius.modules == ("docs",)


def test_derivation_resolves_no_module_when_the_config_omits_the_map() -> None:
    """Return no modules when the truth table carries no module map at all."""
    radius = derive_blast_radius(
        "", "", "f", {"over_breadth_fraction": 0.25}, computed_at="t"
    )

    assert radius.modules == ()


def test_derivation_enumerates_a_listed_shared_surface() -> None:
    """Record a touched surface named in the literal truth-table list."""
    assert derive_sample().shared_surfaces == ("config/orchestration-routing.json",)


def test_derivation_enumerates_a_glob_matched_shared_surface() -> None:
    """Record a touched surface that matches a membership glob only."""
    radius = derive_blast_radius(
        "- [ ] [P1-T1] Edit `scripts/dev_tools/validate_json.py`.",
        "",
        "f",
        CONFIG,
        computed_at=COMPUTED_AT,
    )

    assert radius.shared_surfaces == ("scripts/dev_tools/validate_json.py",)


def test_derivation_extracts_contracts_from_interface_sections_only() -> None:
    """Take identifiers from interface sections and ignore other sections."""
    assert derive_sample().contracts == ("ExampleResult", "derive_example")


def test_derivation_of_a_pathless_plan_yields_only_the_feature_folder() -> None:
    """Return a radius containing just the feature folder when nothing is cited."""
    radius = derive_blast_radius("", "", "empty-feature", CONFIG, computed_at="t")

    assert radius.paths == ("docs/features/active/empty-feature/**",)
    assert radius.contracts == ()


def test_derivation_accepts_an_already_qualified_feature_folder() -> None:
    """Avoid doubling the feature root when the caller passes a full path."""
    radius = derive_blast_radius(
        "", "", "docs/features/active/qualified", CONFIG, computed_at="t"
    )

    assert radius.paths == ("docs/features/active/qualified/**",)


def test_derivation_trims_separators_from_the_feature_folder() -> None:
    """Normalize a folder name that arrives with surrounding separators."""
    radius = derive_blast_radius("", "", " trimmed/ ", CONFIG, computed_at="t")

    assert radius.paths == ("docs/features/active/trimmed/**",)


def test_derivation_records_the_requested_declared_source() -> None:
    """Record ``declared`` when a planner adopts the radius as authoritative."""
    radius = derive_blast_radius(
        "", "", "f", CONFIG, source="declared", computed_at="t"
    )

    assert radius.source == "declared"


def test_derivation_rejects_a_blank_feature_folder() -> None:
    """Fail fast when the feature folder is absent."""
    with pytest.raises(ValueError, match="feature_folder must not be empty"):
        derive_blast_radius("", "", "  ", CONFIG, computed_at="t")


def test_derivation_rejects_non_string_spec_text() -> None:
    """Fail fast when the spec text is not a string."""
    with pytest.raises(TypeError, match="spec_text must be a string"):
        derive_blast_radius("", cast("str", None), "f", CONFIG, computed_at="t")


def test_observed_radius_records_the_observed_source() -> None:
    """Mark a radius built from a diff listing as ``observed``."""
    radius = radius_from_observed_paths(["docs/a.md"], CONFIG, computed_at=COMPUTED_AT)

    assert radius.source == "observed"
    assert radius.contracts == ()


def test_observed_radius_resolves_modules_and_shared_surfaces() -> None:
    """Apply the derivation resolution rules to observed paths."""
    radius = radius_from_observed_paths(
        ["poetry.lock", "scripts/dev_tools/example.py"], CONFIG, computed_at="t"
    )

    assert radius.modules == ("python-dev-tools",)
    assert radius.shared_surfaces == ("poetry.lock",)


def test_observed_radius_accepts_an_empty_path_list() -> None:
    """Return an empty radius when the diff listed no file."""
    radius = radius_from_observed_paths([], CONFIG, computed_at="t")

    assert radius.paths == ()
    assert radius.modules == ()


def test_observed_radius_rejects_a_non_string_path() -> None:
    """Fail fast when the supplied diff listing holds a non-string entry."""
    with pytest.raises(TypeError, match="observed_paths entry must be a string"):
        radius_from_observed_paths(cast("Sequence[str]", [1]), CONFIG, computed_at="t")


def test_observed_and_derived_radii_resolve_the_same_paths_identically() -> None:
    """Resolve modules and surfaces the same way in both entry points."""
    paths = ["config/orchestration-routing.json", "scripts/dev_tools/example.py"]
    observed = radius_from_observed_paths(paths, CONFIG, computed_at="t")
    derived = derive_blast_radius(
        "- [ ] [P1-T1] Edit `config/orchestration-routing.json` and "
        "`scripts/dev_tools/example.py`.",
        "",
        "f",
        CONFIG,
        computed_at="t",
    )

    assert observed.shared_surfaces == derived.shared_surfaces
    assert set(observed.modules) <= set(derived.modules)
