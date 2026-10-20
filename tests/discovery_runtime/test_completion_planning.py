"""Verify completion-only grants and derived paired views with memory captures."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import completion_report, mutation_plan, validation
from drm_copilot_discovery.completion_report import (
    build_completion_report,
    plan_completion_report,
)
from drm_copilot_discovery.mutation_io import commit_mutation
from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationError
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError

from tests.discovery_runtime.mutation_test_support import capture, mutation_case
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)
from tests.discovery_runtime.test_mutation_commit import MemoryWriter
from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import ParseLimits
    from drm_copilot_discovery.report_models import DiscoveryReport
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.validation import ValidationMode
    from pytest import MonkeyPatch

    from tests.discovery_runtime.test_snapshot_io import MemoryStore


@pytest.fixture
def completion_case(
    mutation_catalog: SchemaCatalog,
) -> tuple[MemoryStore, CapturedWorkspace]:
    """Return a fresh memory store/capture using schemas (SchemaCatalog).

    The accepted fixture is structurally valid and honestly incomplete. No
    filesystem, process or network access occurs; all mutable state is local.
    """
    return mutation_case(mutation_catalog)


def completion_grants(
    baseline: CapturedWorkspace, *, identifier: str = "completion"
) -> tuple[WriteGrant, ...]:
    """Return two explicit test grants for baseline and identifier (str).

    CapturedWorkspace supplies the configured reports root. These fixture
    values model caller input only; they confer no host authority or side effect.
    """
    root = baseline.snapshot.profile.artifacts["reports"]
    # Keep each kind/identity/path triple explicit and restricted to derived views.
    return tuple(
        WriteGrant(
            artifact_kind="completion-report",
            artifact_id=identifier,
            path=root + "/completion-report." + suffix,
        )
        for suffix in ("json", "md")
    )


def test_public_builder_delegates_one_exact_mode_and_identifier(
    completion_case: tuple[MemoryStore, CapturedWorkspace],
    monkeypatch: MonkeyPatch,
) -> None:
    """Return None after checking one public projection call and detached views.

    completion_case (tuple[MemoryStore, CapturedWorkspace]) supplies input.
    monkeypatch (MonkeyPatch) locally replaces projection, not graph validity.
    """
    _, baseline = completion_case
    observed: list[tuple[DiscoverySnapshot, str, str, ValidationMode]] = []
    document: dict[str, object] = {
        "artifact_kind": "completion-report",
        "id": "review",
        "mode": "planning",
        "validation_result": "fail",
        "findings": [],
    }

    def project(
        snapshot: DiscoverySnapshot, *, kind: str, identifier: str, mode: ValidationMode
    ) -> dict[str, object]:
        """Return local dict after recording snapshot and projection selectors.

        snapshot (DiscoverySnapshot), kind/identifier (str) and mode
        (ValidationMode) are recorded only in the test-local list; no I/O occurs.
        """
        observed.append((snapshot, kind, identifier, mode))
        return document

    monkeypatch.setattr(validation, "report_projection", project)
    report = build_completion_report(
        baseline.snapshot, mode="planning", identifier="review"
    )
    assert observed == [(baseline.snapshot, "completion-report", "review", "planning")]
    assert report.to_dict() == document
    assert json.loads(report.to_json()) == document
    assert report.to_markdown().startswith("# Discovery completion report\n")
    document["validation_result"] = "changed after construction"
    assert report.document["validation_result"] == "fail"


@pytest.mark.parametrize(
    "fault",
    [
        "none",
        "one",
        "extra",
        "duplicate",
        "kind",
        "identifier",
        "json",
        "md",
        "member",
        "list",
    ],
)
def test_planning_rejects_any_nonexact_grant_pair_before_projection(
    completion_case: tuple[MemoryStore, CapturedWorkspace],
    monkeypatch: MonkeyPatch,
    fault: str,
) -> None:
    """Return None after one str-selected grant defect fails with MUTATION_GRANT.

    completion_case (tuple[MemoryStore, CapturedWorkspace]) supplies input;
    fault (str) chooses one defect. monkeypatch (MonkeyPatch) forbids subsequent
    production and planning. No derived bytes or store mutation is permitted.
    """
    store, baseline = completion_case
    pair = completion_grants(baseline)
    grant = pair[0]
    # Each branch changes one authority dimension while keeping the control pair.
    if fault in {"none", "one", "extra", "duplicate"}:
        values = {
            "none": (),
            "one": pair[:1],
            "extra": (*pair, pair[0]),
            "duplicate": (pair[0], pair[0]),
        }
        grants = values[fault]
    elif fault in {"kind", "identifier", "json", "md"}:
        field, value = {
            "kind": ("artifact_kind", "feature-contract"),
            "identifier": ("artifact_id", "other"),
            "json": ("path", "docs/authored.json"),
            "md": ("path", "docs/authored.md"),
        }[fault]
        changed = replace(pair[1] if fault == "md" else grant, **{field: value})
        grants = (pair[0], changed) if fault == "md" else (changed, pair[1])
    else:
        grants = cast(
            "tuple[WriteGrant, ...]",
            (object(), pair[1]) if fault == "member" else list(pair),
        )
    before = dict(store.files)

    def forbidden(*args: object, **kwargs: object) -> None:
        """Raise AssertionError for any object-argument call; no external effect."""
        raise AssertionError("Invalid grants must fail before report work")

    monkeypatch.setattr(completion_report, "build_completion_report", forbidden)
    monkeypatch.setattr(mutation_plan, "plan_mutation", forbidden)
    with pytest.raises(MutationError) as error:
        plan_completion_report(baseline, mode="structural", grants=grants)
    assert error.value.code == "MUTATION_GRANT"
    assert store.files == before


@pytest.mark.parametrize("mode", ["agent-output", "custom", "", True])
def test_planning_rejects_unsupported_modes_before_capture_or_grants(
    mode: object,
) -> None:
    """Return None after invalid mode (object) fails before any capture inspection."""
    with pytest.raises(ValueError, match="root validation mode"):
        plan_completion_report(
            cast("CapturedWorkspace", None),
            mode=cast("ValidationMode", mode),
            grants=(),
        )


def test_planning_requires_an_actual_captured_workspace() -> None:
    """Return None after an invalid baseline raises ValueError without I/O."""
    with pytest.raises(ValueError, match="captured workspace"):
        plan_completion_report(
            cast("CapturedWorkspace", None), mode="structural", grants=()
        )


def test_planning_reserves_captured_file_comparisons_before_projection(
    completion_case: tuple[MemoryStore, CapturedWorkspace],
    monkeypatch: MonkeyPatch,
) -> None:
    """Return None after counted work fails before captured-file indexing.

    completion_case (tuple[MemoryStore, CapturedWorkspace]) has captured files;
    monkeypatch (MonkeyPatch) installs a local budget with one fewer comparison
    than required and a forbidden builder. No external state changes.
    """
    _, baseline = completion_case
    expected = 2 * len(baseline.snapshot.manifest.files)
    reservations: list[int] = []

    class BoundedBudget(ReportBudget):
        """Retain all byte/node guards and expose only a local work capacity.

        Instances record attempted reservations without mutating caller input;
        the inherited work method raises ReportLimitError before excess work.
        """

        def __init__(self, limits: ParseLimits) -> None:
            """Initialize limits (ParseLimits); return None with local reduced work."""
            super().__init__(limits)
            self.work_left = expected - 1

        def work(self, count: int) -> None:
            """Record count (int); return None or propagate ReportLimitError."""
            reservations.append(count)
            super().work(count)

    def forbidden(*args: object, **kwargs: object) -> None:
        """Reject any object-argument report call with AssertionError."""
        raise AssertionError("Reservation must precede report projection")

    monkeypatch.setattr(completion_report, "ReportBudget", BoundedBudget)
    monkeypatch.setattr(completion_report, "build_completion_report", forbidden)
    with pytest.raises(ReportLimitError):
        plan_completion_report(
            baseline, mode="structural", grants=completion_grants(baseline)
        )
    assert reservations == [expected]


def test_paired_views_support_dry_run_replacement_and_exact_unchanged_skip(
    completion_case: tuple[MemoryStore, CapturedWorkspace],
    mutation_catalog: SchemaCatalog,
    monkeypatch: MonkeyPatch,
) -> None:
    """Return None after real memory planning/commit preserves its captured source.

    completion_case (tuple[MemoryStore, CapturedWorkspace]) and mutation_catalog
    (SchemaCatalog) supply real inputs. monkeypatch (MonkeyPatch) observes the
    builder without replacing its result. Only the test-local memory store
    changes; a failed parity assessment does not imply structural failure.
    """
    store, baseline = completion_case
    profile = as_object(json.loads(store.files[PROFILE_PATH]))
    as_object(profile["artifacts"])["reports"] = "docs/generated/review"
    store.put(PROFILE_PATH, json.dumps(profile).encode("utf-8"))
    baseline = capture(store, mutation_catalog)
    originals = dict(store.files)
    observed: list[tuple[DiscoverySnapshot, DiscoveryReport]] = []
    original_builder = build_completion_report

    def observe(
        snapshot: DiscoverySnapshot,
        *,
        mode: ValidationMode,
        identifier: str = "completion",
    ) -> DiscoveryReport:
        """Return the actual DiscoveryReport and retain its input locally.

        snapshot (DiscoverySnapshot), mode (ValidationMode) and identifier (str)
        pass unchanged to the builder. Its errors propagate without I/O.
        """
        report = original_builder(snapshot, mode=mode, identifier=identifier)
        observed.append((snapshot, report))
        return report

    monkeypatch.setattr(completion_report, "build_completion_report", observe)
    grants = completion_grants(baseline, identifier="review")
    plan = plan_completion_report(
        baseline, mode="structural", grants=grants, identifier="review"
    )
    assert len(observed) == 1 and observed[0][0] is baseline.snapshot
    report = observed[0][1]
    # Compare both planned streams to the same measured immutable report carrier.
    contents = {write.change.path: write.change.content for write in plan.writes}
    assert contents == {
        grants[0].path: report.to_json().encode("utf-8"),
        grants[1].path: report.to_markdown().encode("utf-8"),
    }
    # Neither new view may acquire replacement authority for an existing file.
    assert all(write.change.expected_sha256 is None for write in plan.writes)
    assert plan.validation.ok and plan.invocation is None
    writer = MemoryWriter(store, mutation_catalog)
    before = (dict(store.files), dict(store.metadata.entries))
    dry = commit_mutation(plan, writer=writer, dry_run=True)
    assert dry.ok and writer.attempts == writer.invalidations == 0
    assert (store.files, store.metadata.entries) == before
    created = commit_mutation(plan, writer=writer)
    # Every paired output must report actual creation rather than partial success.
    assert created.ok and [item.status for item in created.artifacts] == ["created"] * 2
    captured = writer.capture()
    unchanged = plan_completion_report(
        captured, mode="structural", grants=grants, identifier="review"
    )
    skipped = commit_mutation(unchanged, writer=writer)
    # Recomputed identical views preserve both stored byte streams.
    assert skipped.ok and [item.status for item in skipped.artifacts] == ["skipped"] * 2
    replacement = plan_completion_report(
        captured, mode="parity-complete", grants=grants, identifier="review"
    )
    # Replacement CAS uses the exact captured bytes for each existing paired view.
    assert all(
        write.change.expected_sha256 == captured.snapshot.file(write.change.path).sha256
        for write in replacement.writes
    )
    value = as_object(json.loads(replacement.writes[0].change.content))
    assert value["mode"] == "parity-complete" and value["validation_result"] == "fail"
    assert as_object(value["completion"])["assessment_state"] == "available"
    replaced = commit_mutation(replacement, writer=writer)
    # Both changed views must report replacement under their captured digests.
    assert (
        replaced.ok and [item.status for item in replaced.artifacts] == ["updated"] * 2
    )
    # Report publication leaves every authored original byte untouched.
    assert all(store.files[path] == content for path, content in originals.items())
    # The exact supplied pair is the complete set of newly created paths.
    assert set(store.files) - set(originals) == {grant.path for grant in grants}


def test_malformed_core_diagnostic_cannot_pass_prospective_mutation_validation(
    completion_case: tuple[MemoryStore, CapturedWorkspace],
    mutation_catalog: SchemaCatalog,
) -> None:
    """Return None after malformed memory bytes stay diagnosable but unpublishable.

    completion_case (tuple[MemoryStore, CapturedWorkspace]) is rebuilt through
    the actual loader with mutation_catalog (SchemaCatalog). MutationError
    retains original findings; planning changes no local bytes or metadata.
    """
    store, baseline = completion_case
    store.put(baseline.snapshot.profile.artifacts["scope"], b"{")
    invalid = capture(store, mutation_catalog)
    before = (dict(store.files), dict(store.metadata.entries))
    diagnostic = build_completion_report(invalid.snapshot, mode="structural")
    assert diagnostic.document["validation_result"] == "fail"
    assert diagnostic.document["counts"] is None
    assert (
        as_object(diagnostic.to_dict()["completion"])["assessment_state"]
        == "unavailable"
    )
    with pytest.raises(MutationError) as error:
        plan_completion_report(
            invalid, mode="structural", grants=completion_grants(invalid)
        )
    assert error.value.code == "MUTATION_INVALID"
    assert error.value.findings
    assert (store.files, store.metadata.entries) == before
