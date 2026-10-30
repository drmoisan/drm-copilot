"""Prove baseline reconstruction refuses malformed records and every drift class."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.gateway_host_baseline import reconstruct_baseline
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.report_models import bounded_object

from tests.discovery_runtime.gateway_host_test_support import (
    EXISTING_BYTES,
    EXISTING_OUTPUT,
    HostCase,
    host_case,
)
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan

if TYPE_CHECKING:
    from collections.abc import Callable

    from tests.discovery_runtime.test_service import MemoryService

Document = dict[str, object]


def record(case: HostCase, name: str) -> Document:
    """Return the stored protected record name as a mutable document."""
    return json.loads(case.store.files[f"{case.directory}/{name}"])


def rows_of(document: Document, key: str) -> list[Document]:
    """Return the mutable non-empty row list stored under key in document."""
    rows = document[key]
    assert isinstance(rows, list) and rows, f"{key} must be a non-empty row list"
    return cast("list[Document]", rows)


def bound(document: Document) -> JsonObject:
    """Return document as the immutable JsonObject the decoders would yield."""
    return bounded_object(document, limits=ParseLimits())


def rebuild(case: HostCase, invocation: Document, stored: Document) -> object:
    """Run reconstruction over the current capture with the given records."""
    return reconstruct_baseline(
        case.capture(),
        bound(invocation),
        bound(stored),
        repository=case.service.repository,
    )


def refused(action: Callable[[], object], code: str, reason: str) -> None:
    """Assert action raises the exit-3 failure with code and reason."""
    with pytest.raises(OperationFailure) as caught:
        action()
    assert caught.value.exit_code == 3
    assert caught.value.findings[0].code == code
    assert reason in caught.value.findings[0].message


def test_reconstruction_restores_the_prepared_output_bytes(
    service_io: MemoryService,
) -> None:
    """The reconstructed snapshot carries the stored content of an existing output."""
    case = host_case(service_io)
    service_io.disk.store.put(EXISTING_OUTPUT, b'{"id": "feature-beta-v2"}\n')

    snapshot = reconstruct_baseline(
        case.capture(),
        bound(record(case, "invocation.json")),
        bound(record(case, "baseline-result.json")),
        repository=service_io.repository,
    )

    assert snapshot.file(EXISTING_OUTPUT).content == EXISTING_BYTES


def test_invocation_without_required_outputs_is_refused(
    service_io: MemoryService,
) -> None:
    """A record without a required-output manifest cannot pin a baseline."""
    case = host_case(service_io)
    invocation = record(case, "invocation.json")
    invocation["required_outputs"] = None

    refused(
        lambda: rebuild(case, invocation, record(case, "baseline-result.json")),
        "SERVICE_AUTHORITY",
        "no required-output manifest",
    )


@pytest.mark.parametrize("outputs", ["rows", [1, 2]])
def test_malformed_required_output_rows_are_refused(
    service_io: MemoryService, outputs: object
) -> None:
    """Required outputs that are not object rows are refused as malformed."""
    case = host_case(service_io)
    invocation = record(case, "invocation.json")
    manifest = invocation["required_outputs"]
    assert isinstance(manifest, dict)
    manifest["outputs"] = outputs

    refused(
        lambda: rebuild(case, invocation, record(case, "baseline-result.json")),
        "SERVICE_AUTHORITY",
        "malformed",
    )


def test_baseline_without_input_manifest_is_drift(service_io: MemoryService) -> None:
    """A stored result that carries no input manifest cannot prove the baseline."""
    case = host_case(service_io)
    stored = record(case, "baseline-result.json")
    stored["input_manifest"] = None

    refused(
        lambda: rebuild(case, record(case, "invocation.json"), stored),
        "SERVICE_BASELINE",
        "no input manifest",
    )


def test_removed_input_is_drift(service_io: MemoryService) -> None:
    """An input the baseline pinned that is now absent refuses the request."""
    case = host_case(service_io)
    stored = record(case, "baseline-result.json")
    manifest = stored["input_manifest"]
    assert isinstance(manifest, dict)
    rows_of(cast("Document", manifest), "entries").append(
        {
            "path": "proposals/removed.md",
            "sha256": "0" * 64,
            "size": 1,
            "category": "documentation",
        }
    )

    refused(
        lambda: rebuild(case, record(case, "invocation.json"), stored),
        "SERVICE_BASELINE",
        "removed",
    )


def test_pinned_row_without_text_is_drift(service_io: MemoryService) -> None:
    """A stored output row without text content cannot be replayed."""
    case = host_case(service_io)
    stored = record(case, "baseline-result.json")
    row = rows_of(stored, "artifacts")[0]
    del row["content"]

    refused(
        lambda: rebuild(case, record(case, "invocation.json"), stored),
        "SERVICE_BASELINE",
        "no text content",
    )


def test_pinned_row_digest_mismatch_is_drift(service_io: MemoryService) -> None:
    """A stored output row whose digest disagrees with its content is refused."""
    case = host_case(service_io)
    stored = record(case, "baseline-result.json")
    row = rows_of(stored, "artifacts")[0]
    row["sha256"] = "0" * 64

    refused(
        lambda: rebuild(case, record(case, "invocation.json"), stored),
        "SERVICE_BASELINE",
        "digest differs",
    )
