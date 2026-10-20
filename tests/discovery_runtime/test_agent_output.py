"""Verify exact role outputs and baseline preservation without host authority or I/O."""

from __future__ import annotations

from dataclasses import replace
from functools import partial
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import validation_operation
from drm_copilot_discovery.agent_output import (
    required_output_digest,
    validate_agent_output,
)
from drm_copilot_discovery.models import canonical_json, to_plain_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.validation import report_projection, validate_snapshot

from tests.discovery_runtime.test_decision_rules import decision
from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import (
    ROOT,
    alter_manifest,
    captured,
    document_record,
    mode_profile,
    no_scope_snapshot,
    output_context,
    replace_document,
)
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.validation import ValidationMode
    from pytest import MonkeyPatch


@pytest.mark.parametrize(
    "role",
    [
        "legacy-parity-analyst",
        "runtime-characterization-analyst",
        "requirements-reconciler",
        "migration-coverage-reviewer",
    ],
)
def test_all_four_roles_validate_only_their_exact_supplied_outputs(
    snapshot_catalog: SchemaCatalog, role: str
) -> None:
    """Each role has a real allowed artifact and a caller-bound exact manifest."""
    baseline = no_scope_snapshot(snapshot_catalog)
    payloads: tuple[SnapshotFile, ...] = ()
    if role == "legacy-parity-analyst":
        output = next(
            item
            for item in baseline.artifacts
            if item.expected_kind == "coverage-ledger"
        )
    elif role == "runtime-characterization-analyst":
        data = load_fixture("evidence-reference")
        payload = SnapshotFile(
            path=ROOT + "evidence/runtime.txt",
            content=b"Actual capture.",
            category="evidence",
        )
        data.update(
            repository=baseline.profile.repository.id,
            path=payload.path,
            runtime_artifact={"path": payload.path, "capture_method": "manual"},
            checksum={"algorithm": "sha256", "value": payload.sha256},
        )
        output = document_record(
            baseline.profile, "evidence-reference", ROOT + "evidence/runtime.json", data
        )
        payloads = (payload,)
    elif role == "requirements-reconciler":
        data = load_fixture("product-decision-collection")
        data["records"] = []
        output = document_record(
            baseline.profile,
            "product-decision-collection",
            baseline.profile.artifacts["product_decisions"],
            data,
        )
    else:
        data = report_projection(
            baseline,
            kind="completion-report",
            identifier="review",
            mode="discovery-complete",
        )
        output = document_record(
            baseline.profile, "completion-report", ROOT + "reports/review.json", data
        )
    snapshot, invocation = output_context(
        baseline,
        role,
        outputs=(output,),
        payloads=payloads,
        review_mode=(
            "discovery-complete" if role == "migration-coverage-reviewer" else None
        ),
    )
    before = (baseline.sha256, snapshot.sha256)
    result = validate_snapshot(snapshot, mode="agent-output", invocation=invocation)
    assert result.findings == () and result.output_valid is True and result.ok
    assert result.required_outputs_sha256 == required_output_digest(
        invocation.required_outputs
    )
    assert (baseline.sha256, snapshot.sha256) == before


@pytest.mark.parametrize("kind", ["completion-report", "coverage-report"])
@pytest.mark.parametrize("mode", ["discovery-complete", "parity-complete"])
def test_valid_failed_review_can_finish_without_authorizing_planning(
    snapshot_catalog: SchemaCatalog,
    kind: str,
    mode: ValidationMode,
    monkeypatch: MonkeyPatch,
) -> None:
    """Review output validity is independent from its recomputed completion failure."""
    baseline = captured(mode_profile(snapshot_catalog, draft=True), snapshot_catalog)
    data = report_projection(
        baseline,
        kind=kind,
        identifier="review",
        mode=mode,
    )
    output = document_record(baseline.profile, kind, ROOT + "reports/review.json", data)
    snapshot, invocation = output_context(
        baseline,
        "migration-coverage-reviewer",
        outputs=(output,),
        review_mode=mode,
    )
    counts: dict[str, int] = dict.fromkeys(
        ("validate_coverage", "validate_dimensions", "validate_acceptance"), 0
    )

    def counted(
        target: Callable[..., object], name: str, *args: object, **kwargs: object
    ) -> object:
        """Call target (Callable) with args/kwargs (object) and count name (str).

        Return its object result unchanged; propagate its validation exceptions.
        """
        if kwargs.get("complete") is True:
            counts[name] += 1
        return target(*args, **kwargs)

    # Count one validation operation, excluding setup and the later planning check.
    with monkeypatch.context() as scoped:
        # Every shared complete family must run once despite two report modes.
        for name in counts:
            scoped.setattr(
                validation_operation,
                name,
                partial(counted, getattr(validation_operation, name), name),
            )
        result = validate_snapshot(snapshot, mode="agent-output", invocation=invocation)
    assert set(counts.values()) == {1}
    assert (
        result.output_valid is True and result.ok and result.validation_result == "fail"
    )
    assert any(item.severity == "error" for item in result.findings)
    assert not validate_snapshot(snapshot, mode="planning").ok


def test_unrelated_stable_report_does_not_break_incremental_outputs(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Existing derived reports remain comparable without entering the schema index."""
    baseline = no_scope_snapshot(snapshot_catalog)
    data = report_projection(
        baseline, kind="coverage-report", identifier="old", mode="structural"
    )
    report = document_record(
        baseline.profile, "coverage-report", ROOT + "reports/old.json", data
    )
    baseline = replace(
        baseline,
        artifacts=(*baseline.artifacts, report),
        manifest=replace(
            baseline.manifest,
            files=(
                *baseline.manifest.files,
                SnapshotFile(
                    path=report.path,
                    content=canonical_json(report.document),
                    category="artifact",
                ),
            ),
        ),
    )
    ledger = next(
        item for item in baseline.artifacts if item.expected_kind == "coverage-ledger"
    )
    value = as_object(to_plain_value(ledger.document))
    value["extensions"] = {"example.discovery": {"review_note": "Later ledger update."}}
    changed = document_record(baseline.profile, "coverage-ledger", ledger.path, value)
    snapshot, invocation = output_context(baseline, outputs=(changed,))
    assert validate_snapshot(snapshot, mode="agent-output", invocation=invocation).ok
    assert "REPORT_RESULT" in {
        item.code for item in validate_snapshot(snapshot, mode="structural").findings
    }


@pytest.mark.parametrize(
    "case",
    [
        "role",
        "invocation",
        "workspace",
        "checksum",
        "profile",
        "stored",
        "malformed",
        "unknown-role",
    ],
)
def test_manifest_cannot_override_independent_invocation_bindings(
    snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Workspace control data cannot supply its own identity or host authority."""
    snapshot, invocation = output_context(no_scope_snapshot(snapshot_catalog))
    if case == "role":
        invocation = replace(invocation, role="requirements-reconciler")
    elif case == "invocation":
        invocation = replace(invocation, invocation_id="different")
    elif case == "workspace":
        invocation = replace(invocation, workspace=immutable({}))
    elif case == "profile":
        value = as_object(to_plain_value(invocation.workspace))
        value["profile_sha256"] = "f" * 64
        invocation = replace(invocation, workspace=immutable(value))
        snapshot, invocation = alter_manifest(snapshot, invocation, workspace=value)
    elif case == "unknown-role":
        invocation = replace(invocation, role="unrecognized")
    elif case == "stored":
        value = as_object(to_plain_value(invocation.required_outputs))
        value["id"] = "different"
        snapshot = replace_document(snapshot, ROOT + "reports/required.json", value)
    else:
        value = as_object(to_plain_value(invocation.required_outputs))
        value["manifest_sha256"] = "0" * 64
        if case == "malformed":
            value.pop("outputs")
        invocation = replace(invocation, required_outputs=immutable(value))
    result = validate_snapshot(snapshot, mode="agent-output", invocation=invocation)
    assert not result.ok and result.output_valid is False


@pytest.mark.parametrize(
    "case",
    [
        "missing",
        "kind",
        "id",
        "format",
        "path",
        "precondition",
        "duplicate",
        "manifest-omitted",
        "forbidden",
    ],
)
def test_exact_required_output_rows_cannot_be_broadened_or_substituted(
    snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Every output keeps its exact role/kind/path/ID/format and baseline hash."""
    baseline = no_scope_snapshot(snapshot_catalog)
    ledger = next(
        item for item in baseline.artifacts if item.expected_kind == "coverage-ledger"
    )
    snapshot, invocation = output_context(baseline, outputs=(ledger,))
    rows = cast(
        "list[dict[str, object]]",
        as_object(to_plain_value(invocation.required_outputs))["outputs"],
    )
    row = as_object(rows[0])
    if case == "missing":
        snapshot = replace(
            snapshot,
            artifacts=tuple(
                item for item in snapshot.artifacts if item.path != ledger.path
            ),
            manifest=replace(
                snapshot.manifest,
                files=tuple(
                    item for item in snapshot.manifest.files if item.path != ledger.path
                ),
            ),
        )
    elif case == "duplicate":
        rows.append({**row, "id": "another"})
    elif case == "manifest-omitted":
        rows = rows[:-1]
    else:
        changes = {
            "kind": ("artifact_kind", "inventory-snapshot"),
            "id": ("id", "wrong"),
            "format": ("format", "markdown"),
            "path": ("path", ROOT + "reports/no.json"),
            "precondition": ("expected_sha256", None),
            "forbidden": ("artifact_kind", "domain-profile"),
        }
        key, value = changes[case]
        row[key] = value
    snapshot, invocation = alter_manifest(snapshot, invocation, outputs=rows)
    assert not validate_snapshot(
        snapshot, mode="agent-output", invocation=invocation
    ).ok


@pytest.mark.parametrize("change", ["addition", "deletion", "bytes", "category"])
def test_ungranted_captured_input_changes_fail_output_validation(
    snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Complete baseline comparison includes unrelated files and category changes."""
    baseline = no_scope_snapshot(snapshot_catalog)
    file = SnapshotFile(
        path="docs/unrelated.txt", content=b"original", category="documentation"
    )
    baseline = replace(
        baseline,
        manifest=replace(baseline.manifest, files=(*baseline.manifest.files, file)),
    )
    snapshot, invocation = output_context(baseline)
    files = snapshot.manifest.files
    if change == "addition":
        files += (replace(file, path="docs/another.txt"),)
    elif change == "deletion":
        files = tuple(item for item in files if item != file)
    else:
        changed = (
            replace(file, content=b"changed")
            if change == "bytes"
            else replace(file, category="evidence")
        )
        files = tuple(changed if item == file else item for item in files)
    result = validate_snapshot(
        replace(snapshot, manifest=replace(snapshot.manifest, files=files)),
        mode="agent-output",
        invocation=invocation,
    )
    assert "OUTPUT_UNEXPECTED" in {item.code for item in result.findings}


@pytest.mark.parametrize(
    "mode", ["structural", "discovery-complete", "parity-complete", "planning"]
)
def test_role_context_cannot_be_reused_as_root_mode_authority(
    snapshot_catalog: SchemaCatalog, mode: ValidationMode
) -> None:
    """A valid analyst result does not grant a root completion or planning principal."""
    snapshot, invocation = output_context(no_scope_snapshot(snapshot_catalog))
    assert validate_snapshot(snapshot, mode="agent-output", invocation=invocation).ok
    result = validate_snapshot(snapshot, mode=mode, invocation=invocation)
    assert not result.ok and "VALIDATION_CONTEXT" in {
        item.code for item in result.findings
    }


def test_role_output_needs_context_and_reviewer_needs_exact_review_mode(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Neither missing caller context nor an empty review manifest satisfies output
    duties.
    """
    baseline = no_scope_snapshot(snapshot_catalog)
    assert not validate_snapshot(baseline, mode="agent-output").ok
    snapshot, invocation = output_context(baseline, "migration-coverage-reviewer")
    assert "OUTPUT_REVIEW" in {
        item.code
        for item in validate_snapshot(
            snapshot, mode="agent-output", invocation=invocation
        ).findings
    }
    report = document_record(
        baseline.profile,
        "coverage-report",
        ROOT + "reports/review.json",
        report_projection(
            baseline, kind="coverage-report", identifier="report", mode="structural"
        ),
    )
    snapshot, invocation = output_context(
        baseline,
        "migration-coverage-reviewer",
        outputs=(report,),
        review_mode="discovery-complete",
    )
    assert "OUTPUT_REVIEW_MODE" in {
        item.code
        for item in validate_snapshot(
            snapshot, mode="agent-output", invocation=invocation
        ).findings
    }


@pytest.mark.parametrize(
    "before,after,selected,expected",
    [
        ("proposed", "proposed", True, None),
        ("approved", "approved", True, None),
        ("proposed", "proposed", False, "OUTPUT_UNSELECTED"),
        ("proposed", "approved", True, "OUTPUT_APPROVAL"),
        ("approved", "proposed", True, "OUTPUT_APPROVAL"),
        ("approved", None, True, "OUTPUT_APPROVAL"),
        (None, "approved", True, "OUTPUT_APPROVAL"),
    ],
)
def test_selected_proposals_and_protected_approval_history(
    snapshot_catalog: SchemaCatalog,
    before: str | None,
    after: str | None,
    selected: bool,
    expected: str | None,
) -> None:
    """A granted collection path cannot change unrelated members or approval history."""
    profile = mode_profile(snapshot_catalog)
    value = load_fixture("product-decision-collection")
    old = decision(profile, status=before or "proposed")
    value["records"] = [to_plain_value(old.document)] if before else []
    path = profile.artifacts["product_decisions"]
    stored = document_record(profile, "product-decision-collection", path, value)
    baseline = captured(profile, snapshot_catalog, stored)
    new = as_object(
        to_plain_value(decision(profile, status=after or "proposed").document)
    )
    if before == after == "proposed":
        new["rationale"] = "Refined proposal rationale."
    value["records"] = [new] if after else []
    output = document_record(profile, "product-decision-collection", path, value)
    snapshot, invocation = output_context(
        baseline,
        "requirements-reconciler",
        outputs=(output,),
        selected=("decision",) if selected else (),
    )
    result = validate_agent_output(
        snapshot, invocation=invocation, index=index_references(snapshot)
    )
    codes = {item.code for item in result.findings}
    assert codes == ({expected} if expected else set())


@pytest.mark.parametrize("empty", [False, True])
def test_opaque_payload_must_be_nonempty_and_exactly_granted(
    snapshot_catalog: SchemaCatalog, empty: bool
) -> None:
    """A runtime payload can be inert binary data but cannot be an empty promised
    capture.
    """
    baseline = no_scope_snapshot(snapshot_catalog)
    payload = SnapshotFile(
        path=ROOT + "evidence/capture.bin",
        content=b"" if empty else b"capture",
        category="evidence",
    )
    snapshot, invocation = output_context(
        baseline, "runtime-characterization-analyst", payloads=(payload,)
    )
    result = validate_snapshot(snapshot, mode="agent-output", invocation=invocation)
    assert result.ok is not empty


def test_digest_ignores_own_checksum_but_preserves_output_order(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Only the manifest checksum field is excluded from its canonical identity."""
    snapshot, invocation = output_context(no_scope_snapshot(snapshot_catalog))
    value = as_object(to_plain_value(invocation.required_outputs))
    value["manifest_sha256"] = "f" * 64
    assert required_output_digest(immutable(value)) == required_output_digest(
        invocation.required_outputs
    )
    value["id"] = "different"
    assert required_output_digest(immutable(value)) != required_output_digest(
        invocation.required_outputs
    )
    assert (
        snapshot.sha256
        == validate_snapshot(
            snapshot, mode="agent-output", invocation=invocation
        ).input_sha256
    )
