"""Parametrized invariant tests for the blast-radius library.

Satisfy the property-test obligation with ``pytest.mark.parametrize`` matrices
rather than a property-based framework, because ``hypothesis`` is not an
approved dependency of this repository. The invariants pinned here are conflict
symmetry, monotonicity in the fail-closed direction, self-conflict, determinism
and input-order independence, and V1 self-consistency.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    conflicts,
    derive_blast_radius,
    validate_blast_radius,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

COMPUTED_AT = "2026-08-07T12-00"

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


# Radius pairs spanning every conflict outcome: disjoint, one level triggered,
# glob-decided overlap, empty against populated, and every level triggered.
RADIUS_PAIRS: tuple[tuple[BlastRadius, BlastRadius], ...] = (
    (make_radius(paths=["scripts/**"]), make_radius(paths=["tests/**"])),
    (make_radius(paths=["docs/a.md"]), make_radius(paths=["docs/a.md"])),
    (make_radius(paths=["docs/**"]), make_radius(paths=["docs/a.md"])),
    (
        make_radius(paths=["scripts/dev_tools/*.py"]),
        make_radius(paths=["scripts/dev_tools/validate_*.py"]),
    ),
    (make_radius(modules=["docs"]), make_radius(modules=["docs", "tests"])),
    (
        make_radius(shared_surfaces=["poetry.lock"]),
        make_radius(shared_surfaces=["poetry.lock"]),
    ),
    (make_radius(contracts=["Alpha"]), make_radius(contracts=["Alpha", "Beta"])),
    (make_radius(), make_radius(paths=["docs/a.md"], modules=["docs"])),
    (make_radius(), make_radius()),
    (
        make_radius(
            paths=["docs/a.md"],
            modules=["docs"],
            shared_surfaces=["poetry.lock"],
            contracts=["Alpha"],
        ),
        make_radius(
            paths=["docs/a.md"],
            modules=["docs"],
            shared_surfaces=["poetry.lock"],
            contracts=["Alpha"],
        ),
    ),
)

# Non-empty radii used by the self-conflict matrix, one per contention level.
NON_EMPTY_RADII: tuple[BlastRadius, ...] = (
    make_radius(paths=["docs/a.md"]),
    make_radius(paths=["docs/**"]),
    make_radius(modules=["docs"]),
    make_radius(shared_surfaces=["poetry.lock"]),
    make_radius(contracts=["Alpha"]),
)

PLAN_A = """### Phase 1 — Implementation

- [ ] [P1-T1] Create `scripts/dev_tools/example.py`.
- [ ] [P1-T2] Edit `config/orchestration-routing.json`.
"""

PLAN_B = """### Phase 1 — Implementation

- [ ] [P1-T1] Edit `config/orchestration-routing.json`.
- [ ] [P1-T2] Create `scripts/dev_tools/example.py`.
"""

PLANS: tuple[str, ...] = (
    "",
    PLAN_A,
    PLAN_B,
    "- [ ] [P1-T1] Touch `docs/a.md` and `tests/scripts/dev_tools/test_a.py`.",
    "Prose only, citing `scripts/dev_tools/validate_json.py`.",
)


@pytest.mark.parametrize(("left", "right"), RADIUS_PAIRS)
def test_conflict_verdict_is_symmetric(left: BlastRadius, right: BlastRadius) -> None:
    """Return the same verdict whichever radius is supplied first."""
    assert (
        conflicts(left, right, CONFIG).conflict
        == conflicts(right, left, CONFIG).conflict
    )


@pytest.mark.parametrize(("left", "right"), RADIUS_PAIRS)
def test_conflict_reasons_are_symmetric(left: BlastRadius, right: BlastRadius) -> None:
    """Return the identical reason sequence whichever radius is supplied first."""
    assert (
        conflicts(left, right, CONFIG).reasons == conflicts(right, left, CONFIG).reasons
    )


@pytest.mark.parametrize("radius", NON_EMPTY_RADII)
def test_a_radius_with_a_non_empty_level_conflicts_with_itself(
    radius: BlastRadius,
) -> None:
    """Contend with itself whenever any contention level carries an entry."""
    assert conflicts(radius, radius, CONFIG).conflict is True


@pytest.mark.parametrize(
    "addition",
    [
        {"paths": ["schemas/extra.json"]},
        {"modules": ["schemas"]},
        {"shared_surfaces": ["quality-tiers.yml"]},
        {"contracts": ["Extra"]},
    ],
)
def test_widening_a_radius_never_removes_a_conflict(
    addition: Mapping[str, Sequence[str]],
) -> None:
    """Keep a conflict standing when either radius gains an unrelated entry."""
    base = make_radius(
        paths=["docs/a.md"], modules=["docs"], shared_surfaces=["poetry.lock"]
    )
    widened = make_radius(
        paths=[*base.paths, *addition.get("paths", ())],
        modules=[*base.modules, *addition.get("modules", ())],
        shared_surfaces=[*base.shared_surfaces, *addition.get("shared_surfaces", ())],
        contracts=[*base.contracts, *addition.get("contracts", ())],
    )

    assert conflicts(base, base, CONFIG).conflict is True
    assert conflicts(widened, base, CONFIG).conflict is True


@pytest.mark.parametrize(
    "addition",
    [
        {"paths": ["docs/a.md"]},
        {"modules": ["docs"]},
        {"shared_surfaces": ["poetry.lock"]},
        {"contracts": ["Alpha"]},
    ],
)
def test_widening_a_disjoint_radius_can_only_create_a_conflict(
    addition: Mapping[str, Sequence[str]],
) -> None:
    """Move a non-conflicting pair toward conflict, never away from it."""
    other = make_radius(
        paths=["docs/a.md"],
        modules=["docs"],
        shared_surfaces=["poetry.lock"],
        contracts=["Alpha"],
    )
    disjoint = make_radius(paths=["schemas/other.json"])
    widened = make_radius(
        paths=[*disjoint.paths, *addition.get("paths", ())],
        modules=[*addition.get("modules", ())],
        shared_surfaces=[*addition.get("shared_surfaces", ())],
        contracts=[*addition.get("contracts", ())],
    )

    assert conflicts(disjoint, other, CONFIG).conflict is False
    assert conflicts(widened, other, CONFIG).conflict is True


@pytest.mark.parametrize("plan_text", PLANS)
def test_derivation_is_deterministic(plan_text: str) -> None:
    """Produce byte-identical radii from repeated derivation of one input."""
    first = derive_blast_radius(plan_text, "", "f", CONFIG, computed_at=COMPUTED_AT)
    second = derive_blast_radius(plan_text, "", "f", CONFIG, computed_at=COMPUTED_AT)

    assert first == second
    assert first.to_dict() == second.to_dict()


def test_derivation_is_independent_of_plan_task_order() -> None:
    """Produce the same radius when the same tasks appear in a different order."""
    first = derive_blast_radius(PLAN_A, "", "f", CONFIG, computed_at=COMPUTED_AT)
    second = derive_blast_radius(PLAN_B, "", "f", CONFIG, computed_at=COMPUTED_AT)

    assert first == second


@pytest.mark.parametrize(
    "entry_order",
    [
        ["docs/a.md", "config/orchestration-routing.json"],
        ["config/orchestration-routing.json", "docs/a.md"],
    ],
)
def test_validation_is_independent_of_radius_input_order(
    entry_order: Sequence[str],
) -> None:
    """Return the same findings however the radius collections were ordered."""
    radius = make_radius(
        paths=entry_order, shared_surfaces=["config/orchestration-routing.json"]
    )

    findings = validate_blast_radius(radius, PLAN_A, CONFIG, tracked_file_count=100)

    assert [(f.rule, f.subject) for f in findings] == [
        ("V1", "scripts/dev_tools/example.py")
    ]


@pytest.mark.parametrize("plan_text", PLANS)
def test_a_derived_radius_passes_v1_against_its_own_plan(plan_text: str) -> None:
    """Prove derivation and V1 share one extraction function."""
    radius = derive_blast_radius(plan_text, "", "f", CONFIG, computed_at=COMPUTED_AT)

    findings = validate_blast_radius(radius, plan_text, CONFIG, tracked_file_count=1000)

    assert [finding for finding in findings if finding.rule == "V1"] == []


@pytest.mark.parametrize("plan_text", PLANS)
def test_a_derived_radius_passes_v2_against_its_own_plan(plan_text: str) -> None:
    """Prove derivation enumerates every shared surface its own plan touches."""
    radius = derive_blast_radius(plan_text, "", "f", CONFIG, computed_at=COMPUTED_AT)

    findings = validate_blast_radius(radius, plan_text, CONFIG, tracked_file_count=1000)

    assert [finding for finding in findings if finding.rule == "V2"] == []
