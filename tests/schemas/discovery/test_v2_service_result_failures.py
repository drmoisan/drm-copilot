"""Verify only the approved nullable service failure branch using core schemas."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.models import ParseLimits, canonical_json
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.schema_validation import validate_document

from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_control_test_support import control_fixture, finding
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


def failure_document() -> dict[str, object]:
    """Return a fresh exit-2 wire fixture with honest null context; no I/O."""
    value = control_fixture("service-result")
    value.update(
        operation=None,
        mode=None,
        ok=False,
        exit_code=2,
        findings=[finding()],
        runtime=None,
        input_manifest=None,
    )
    as_object(value["summary"]).update(
        counts=[], validation_result=None, receipt_ref=None, invocation_ref=None
    )
    return value


def accepts(document: dict[str, object], catalog: SchemaCatalog) -> bool:
    """Validate a local dict with immutable catalog; return bool without writes.

    Unexpected fixture/budget failures propagate. No result grants authority.
    """
    raw = canonical_json(bounded_object(document, limits=ParseLimits()))
    return validate_document(
        raw, expected_kind="service-result", expected_version="2.0.0", catalog=catalog
    ).ok


@pytest.mark.parametrize("field", ["operation", "mode", "runtime", "input_manifest"])
def test_null_context_cannot_describe_success_or_semantic_completion(
    snapshot_catalog: SchemaCatalog,
    field: str,
) -> None:
    """Return None after rejecting null field (str) for success and exit-1.

    snapshot_catalog (SchemaCatalog) supplies only immutable schemas; fixtures
    are local. This preserves the accepted non-null success requirement.
    """
    value = control_fixture("service-result")
    value[field] = None
    assert not accepts(value, snapshot_catalog)
    value.update(ok=False, exit_code=1, findings=[finding()])
    assert not accepts(value, snapshot_catalog)


@pytest.mark.parametrize(
    "operation,mode,exit_code",
    [
        (None, None, 2),
        ("inventory", None, 2),
        (None, "planning", 2),
        ("inventory", "structural", 2),
        ("inventory", "structural", 3),
    ],
)
def test_preexecution_failure_preserves_recognized_context(
    snapshot_catalog: SchemaCatalog,
    operation: str | None,
    mode: str | None,
    exit_code: int,
) -> None:
    """Accept independent recognized context and exact exit; return None.

    catalog is SchemaCatalog; operation/mode are nullable str, exit_code is int.
    Local fixtures never invent runtime, capture or evaluated output.
    """
    value = failure_document()
    value.update(operation=operation, mode=mode, exit_code=exit_code)
    assert accepts(value, snapshot_catalog)


@pytest.mark.parametrize(
    "change",
    [
        "missing-key",
        "unknown-operation",
        "unknown-mode",
        "exit3-unknown",
        "artifacts",
        "counts",
        "validation",
        "receipt",
        "invocation",
        "pointer",
        "action",
        "runtime-shape",
        "manifest-shape",
    ],
)
def test_failure_branch_rejects_partial_claims_and_ambiguous_context(
    snapshot_catalog: SchemaCatalog,
    change: str,
) -> None:
    """Reject one invalid change (str) through injected SchemaCatalog; return None.

    Mutates only a fresh fixture. All original closed fields stay strict.
    """
    value = failure_document()
    summary = as_object(value["summary"])
    if change == "missing-key":
        del value["runtime"]
    elif change == "unknown-operation":
        value["operation"] = "execute-python"
    elif change == "unknown-mode":
        value["mode"] = "trusted"
    elif change == "exit3-unknown":
        value["exit_code"] = 3
    elif change == "artifacts":
        value["artifacts"] = [
            {
                "path": "report.json",
                "kind": "validation-report",
                "status": "created",
                "sha256": "a" * 64,
            }
        ]
    elif change == "counts":
        summary["counts"] = [{"name": "outputs", "value": 1}]
    elif change == "validation":
        summary["validation_result"] = "pass"
    elif change in ("receipt", "invocation"):
        summary[f"{change}_ref"] = "protected-alpha-00000001"
    elif change in ("pointer", "action"):
        entry = finding()
        entry["pointer" if change == "pointer" else "next_action"] = ""
        value["findings"] = [entry]
    elif change == "runtime-shape":
        value["runtime"] = {}
    else:
        value["input_manifest"] = {}
    assert not accepts(value, snapshot_catalog)


def test_real_context_allows_partial_write_failure(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Retain captured context for an exit-3 partial effect; return None.

    snapshot_catalog is immutable SchemaCatalog; no real write is performed.
    """
    value = control_fixture("service-result")
    value.update(ok=False, exit_code=3, findings=[finding()])
    value["artifacts"] = [
        {
            "path": "report.json",
            "kind": "validation-report",
            "status": "created",
            "sha256": "a" * 64,
        }
    ]
    assert accepts(value, snapshot_catalog)
    value["runtime"] = None
    assert not accepts(value, snapshot_catalog)
