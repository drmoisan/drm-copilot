"""Verify authored axis states and bounded mode lookup without granting authority."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError

from tests.discovery_runtime.parity_test_support import classification
from tests.discovery_runtime.test_parity_metrics import (
    axes,
    cast_rows,
    report_graph,
    summary,
)
from tests.discovery_runtime.test_parity_metrics import (
    report_profile as report_profile,
)
from tests.discovery_runtime.test_parity_report import assessed_projection
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import replace_document
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from pytest import MonkeyPatch

COUNTERS = ("passed", "failed", "blocked", "not_run")


@pytest.mark.parametrize("name", ["online", "offline", "mobile"])
@pytest.mark.parametrize("status", ["passed", "failed", "blocked", "not-run"])
def test_consistent_authored_state_counts_once_without_verified_proof(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    name: str,
    status: str,
) -> None:
    """Project name/status (str) with typed profile/catalog fixtures; return None.

    A direct aggregation unit supplies immutable outcomes, not report authority.
    Duplicate consistent representations count once even when proof is invalid.
    Only local outcome copies and private budgets change; no I/O occurs.
    """
    projection = assessed_projection(snapshot_profile, snapshot_catalog)
    obligation = projection.dimensions.obligations[0]
    original = projection.parity.entries[0]
    dimension = replace(
        original.dimensions[0],
        name=name,
        verification=status,
        applicability="applicable",
        consistent=True,
        valid=False,
        proof_valid=False,
    )
    entry = replace(original, valid=False, dimensions=(dimension, dimension))
    # A single named axis must survive duplicate authored representations once.
    row = next(row for row in projection.axes(obligation, entry) if row["name"] == name)
    # Every other authored status remains zero; none can imply checked execution.
    assert {key: row[key] for key in COUNTERS} == {
        key: int(key == status.replace("-", "_")) for key in COUNTERS
    }
    assert row["verified"] == row["required_verified"] == 0
    assert row["conflicting"] == 0 and row["applicable"] == 1


@pytest.mark.parametrize("status", ["passed", "failed", "blocked", "not-run"])
def test_client_aggregation_retains_authored_state_after_actual_assessment(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    status: str,
) -> None:
    """Assess status (str) with ProfileV2/SchemaCatalog, then count it per client.

    Both authored online representations change consistently. Passed claims have
    no target evidence and must remain unverified. Returns None without I/O or
    changes to shared fixtures; actual rules produce every retained outcome.
    """
    snapshot = report_graph(report_profile, snapshot_catalog)
    # Replace only the authored matrix while preserving source population authority.
    matrix = next(
        item for item in snapshot.artifacts if item.expected_kind == "parity-matrix"
    )
    document = as_object(to_plain_value(matrix.document))
    entry = as_object(cast_rows(document["entries"])[0])
    value = classification(verification=status, evidence_refs=[])
    entry["online"] = value
    as_object(entry["dimensions"])["online"] = dict(value)
    counts = as_object(
        axes(summary(replace_document(snapshot, matrix.path, document)))["online"]
    )
    # Authored status totals are independent from evidence-backed verification.
    assert {key: counts[key] for key in COUNTERS} == {
        key: int(key == status.replace("-", "_")) for key in COUNTERS
    }
    assert counts["obligations"] == 1
    assert counts["verified"] == counts["required_verified"] == 0


@pytest.mark.parametrize("conflict", ["verification", "applicability", "retained"])
def test_conflicting_representations_never_select_an_authored_status(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    conflict: str,
) -> None:
    """Keep conflict (str) explicit with typed immutable fixtures; return None.

    The three cases exercise differing values or a retained consistency failure.
    Only direct aggregation inputs change; no graph validation, I/O or shared
    mutation is substituted.
    """
    projection = assessed_projection(snapshot_profile, snapshot_catalog)
    original = projection.parity.entries[0]
    first = replace(
        original.dimensions[0],
        name="online",
        applicability="applicable",
        verification="passed",
        consistent=True,
    )
    # Each independent disagreement must prevent selection of either authored value.
    if conflict == "verification":
        second = replace(first, verification="failed")
    elif conflict == "applicability":
        second = replace(first, applicability="not-applicable")
    else:
        second = replace(first, consistent=False, valid=False)
    entry = replace(original, valid=False, dimensions=(first, second))
    # The axis is retained once even when its two authored declarations conflict.
    row = next(
        row
        for row in projection.axes(projection.dimensions.obligations[0], entry)
        if row["name"] == "online"
    )
    assert row["conflicting"] == 1 and row["verified"] == 0
    # Conflicting alternatives cannot contribute to any chosen authored-status total.
    assert all(row[key] == 0 for key in COUNTERS)


class CountedMode(str):
    """Observe comparisons and hashing of retained immutable mode names.

    Construct from ordinary text and a local two-counter list. Profile validation
    preserves this text subclass in its normalized tuple. Observe equality/hash
    calls only, then restore ordinary text at the strict output boundary. Values
    stay unchanged; no global state, I/O, timing or authority is introduced.
    """

    observations: list[int]

    def __new__(cls, value: str, observations: list[int]) -> CountedMode:
        """Return unchanged value (str), retaining observations (list[int]).

        The local list records equality/hash calls; no external effects occur.
        """
        result = super().__new__(cls, value)
        result.observations = observations
        return result

    def __eq__(self, value: object) -> bool:
        """Return real string equality for value (object); count one comparison.

        Only the shared local observation counter changes; no I/O occurs.
        """
        self.observations[0] += 1
        return super().__eq__(value)

    def __hash__(self) -> int:
        """Return the real string hash while counting one local lookup operation.

        Only the local hash counter changes; no external effects occur.
        """
        self.observations[1] += 1
        return super().__hash__()


@pytest.mark.parametrize("size", [8, 32, 64])
def test_custom_mode_membership_has_prospective_linear_work(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    size: int,
    monkeypatch: MonkeyPatch,
) -> None:
    """Bound size (int) modes with typed fixtures; return None without I/O.

    Check the real positive boundary and one-unit shortages before indexing and
    before rows. MonkeyPatch restores ordinary text at the strict output check,
    preserving values and actual budgets. Only local counters/rows change. A
    shortage raises ReportLimitError without retaining a partial output population.
    """
    projection = assessed_projection(snapshot_profile, snapshot_catalog)
    original = projection.dimensions.obligations[0]
    observations = [0, 0]
    # Increasing populations reveal repeated tuple membership independently of time.
    modes = tuple(
        CountedMode(f"custom-{index:03}", observations) for index in range(size)
    )
    requirement = replace(
        original.requirements, dimensions=(), platforms=(), modes=modes
    )
    obligation = replace(original, requirements=requirement)
    # Exclude immutable profile construction from the projection's work observation.
    observations[:] = [0, 0]
    original_check = ReportBudget.check

    def ordinary_text(budget: ReportBudget, value: object, depth: int = 1) -> None:
        """Restore observed names, then perform the unchanged strict budget check.

        budget/value/depth are ReportBudget/object/int. Returns None or propagates
        ReportLimitError. Only the local output row type changes; text, field
        counts and real budget enforcement remain identical.
        """
        if isinstance(value, dict) and "name" in value:
            row = cast("dict[str, object]", value)
            row["name"] = str(row["name"])
        original_check(budget, cast("object", value), depth)

    monkeypatch.setattr(ReportBudget, "check", ordinary_text)
    budget = projection.population.budget
    initial = 2 * size
    total = initial + 2 * (size + 3) + size + 3
    budget.work_left = initial - 1
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        projection.axes(obligation, None)
    assert observations == [0, 0]
    budget.work_left = total - 1
    output_before = projection.output.bytes_left
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        projection.axes(obligation, None)
    assert projection.output.bytes_left == output_before
    assert observations[0] <= 2 * size and 0 < observations[1] <= 8 * size + 12
    observations[:] = [0, 0]
    budget.work_left = total
    projection.output = ReportBudget(budget.limits)
    rows = projection.axes(obligation, None)
    assert len(rows) == size + 3 and budget.work_left == 0
    assert observations[0] <= 2 * size and 0 < observations[1] <= 8 * size + 12
