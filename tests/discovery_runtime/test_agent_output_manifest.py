"""Prove the stored output manifest is optional in the workspace and exact when present.

The required-output manifest is a host-protected record that the caller verifies
before building the invocation context (P12-T5), and its identifier derives from
the invocation id, so no host can declare a workspace copy among the expected
outputs before preparation. An exact output set therefore validates without a
stored manifest row; a row that does declare a copy is still held to the
protected record byte for byte.
"""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.agent_output import required_output_digest
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.validation import validate_snapshot

from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import (
    ROOT,
    no_scope_snapshot,
    output_context,
    replace_document,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot

MANIFEST_PATH = ROOT + "reports/required.json"


def ledger_output(baseline: DiscoverySnapshot) -> ArtifactSnapshot:
    """Return the baseline's coverage ledger as the analyst's single real output."""
    return next(
        item for item in baseline.artifacts if item.expected_kind == "coverage-ledger"
    )


def without_stored_manifest(
    snapshot: DiscoverySnapshot, context: InvocationContext
) -> tuple[DiscoverySnapshot, InvocationContext]:
    """Drop the stored manifest row and file so the host record is the only manifest.

    snapshot (DiscoverySnapshot) and context (InvocationContext) come from
    output_context, which always stores a manifest copy; the returned pair keeps
    every other output, recomputes the manifest digest and touches no file.
    """
    value = as_object(to_plain_value(context.required_outputs))
    rows = cast("list[object]", value["outputs"])
    # Keep every genuine output row; only the manifest's own row is removed.
    value["outputs"] = [
        row
        for row in rows
        if as_object(row)["artifact_kind"] != "required-output-manifest"
    ]
    value["manifest_sha256"] = required_output_digest(immutable(value))
    stripped = replace(
        snapshot,
        artifacts=tuple(a for a in snapshot.artifacts if a.path != MANIFEST_PATH),
        manifest=replace(
            snapshot.manifest,
            files=tuple(f for f in snapshot.manifest.files if f.path != MANIFEST_PATH),
        ),
    )
    return stripped, replace(context, required_outputs=immutable(value))


def test_exact_output_set_without_a_stored_manifest_row_is_valid(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A host-verified invocation needs no workspace copy of its output manifest."""
    baseline = no_scope_snapshot(snapshot_catalog)
    snapshot, context = output_context(baseline, outputs=(ledger_output(baseline),))
    stripped, invocation = without_stored_manifest(snapshot, context)

    result = validate_snapshot(stripped, mode="agent-output", invocation=invocation)

    assert result.findings == () and result.output_valid is True and result.ok
    assert result.required_outputs_sha256 == required_output_digest(
        invocation.required_outputs
    )


def test_a_declared_stored_manifest_must_equal_the_protected_record(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """When a row declares a stored copy, a copy that differs is still refused."""
    baseline = no_scope_snapshot(snapshot_catalog)
    snapshot, context = output_context(baseline, outputs=(ledger_output(baseline),))
    # Only the stored copy changes; the caller context keeps the protected record so
    # the binding check passes and the byte-for-byte equality check is what fires.
    stored = as_object(to_plain_value(context.required_outputs))
    stored["manifest_sha256"] = "f" * 64
    altered = replace_document(snapshot, MANIFEST_PATH, stored)

    result = validate_snapshot(altered, mode="agent-output", invocation=context)

    assert "OUTPUT_MANIFEST" in {item.code for item in result.findings}
    assert result.output_valid is False
