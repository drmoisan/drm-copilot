"""Prove the service admits a verified host authority and refuses other host mixes."""

from __future__ import annotations

import json
from hashlib import sha256
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.path_models import WriteGrant

from tests.discovery_runtime.evidence_test_support import request_for
from tests.discovery_runtime.host_test_support import (
    AUTHORIZATION_REF,
    MemoryHostService,
    invoke_host,
)
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.discovery_runtime.test_service_publication import seed_contract

if TYPE_CHECKING:
    from tests.discovery_runtime.test_service import MemoryService

CONTRACTS = "docs/migration/discovery/feature-contracts"
CONTRACT = CONTRACTS + "/feature.json"
QUESTIONS = "docs/migration/discovery/unspecified-behaviors.yaml"
EVIDENCE = "docs/migration/discovery/evidence/proof.json"
CONTRACT_GRANTS = (
    WriteGrant(artifact_kind="feature-contract", artifact_id="feature", path=CONTRACT),
    WriteGrant(
        artifact_kind="unspecified-behavior-collection",
        artifact_id="unresolved-consumer-system",
        path=QUESTIONS,
    ),
)


def test_granted_new_contract_publishes_with_agent_attribution(
    service_io: MemoryService,
) -> None:
    """A host new-contract on granted rows publishes both planned files."""
    host = MemoryHostService(service_io, grants=CONTRACT_GRANTS)
    before = dict(service_io.disk.store.files)

    result = invoke_host(
        host, "new-contract", {"feature_id": "feature", "name": "Feature"}, write=True
    )

    assert result.ok, result.findings
    assert host.writer_calls == 1 and len(result.artifacts) == 2
    assert {row.path for row in result.artifacts} == {CONTRACT, QUESTIONS}
    assert service_io.disk.store.files != before
    assert all(
        sha256(service_io.disk.store.files[row.path]).hexdigest() == row.sha256
        for row in result.artifacts
    )
    assert result.summary["invocation_ref"] is None


def test_granted_update_artifact_publishes_the_replacement(
    service_io: MemoryService,
) -> None:
    """A host update-artifact on a granted output replaces the exact bytes."""
    path = seed_contract(service_io)
    original = service_io.disk.store.files[path]
    document = json.loads(original)
    document["name"] = "Feature (revised)"
    replacement = json.dumps(document).encode("utf-8")
    service_io.disk.store.put("proposals/replacement.json", replacement)
    host = MemoryHostService(
        service_io,
        grants=(
            WriteGrant(
                artifact_kind="feature-contract", artifact_id="feature", path=path
            ),
        ),
    )

    result = invoke_host(
        host,
        "update-artifact",
        {
            "artifact_kind": "feature-contract",
            "artifact_path": path,
            "input_path": "proposals/replacement.json",
            "expected_sha256": sha256(original).hexdigest(),
            "update_action": "replace",
        },
        write=True,
    )

    assert result.ok, result.findings
    assert service_io.disk.store.files[path] == replacement


def test_granted_link_evidence_publishes_the_linked_record(
    service_io: MemoryService,
) -> None:
    """A host link-evidence on granted rows publishes the reference and contract."""
    path = seed_contract(service_io)
    baseline = capture_workspace(
        workspace_root=service_io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=service_io.disk.store.metadata,
        read_bytes=service_io.disk.store.read,
        catalog=service_io.initialization.catalog,
        repository=service_io.repository,
    )
    payload_path = "proposals/capture.txt"
    link = request_for(
        baseline,
        updates={
            "path": payload_path,
            "revision": baseline.snapshot.profile.repository.revision,
            "runtime_artifact": {"path": payload_path, "capture_method": "manual"},
        },
    )
    # The payload and the proposed record are captured inputs, as for local-user.
    service_io.disk.store.put(payload_path, link.payloads[0].content)
    service_io.disk.store.put("proposals/evidence.json", canonical_json(link.record))
    host = MemoryHostService(
        service_io,
        grants=(
            WriteGrant(
                artifact_kind="evidence-reference",
                artifact_id=str(link.record["id"]),
                path=EVIDENCE,
            ),
            WriteGrant(
                artifact_kind="feature-contract", artifact_id="feature", path=path
            ),
        ),
    )

    result = invoke_host(
        host,
        "link-evidence",
        {
            "artifact_kind": "feature-contract",
            "artifact_id": "feature",
            "expected_sha256": link.expected_sha256,
            "evidence_path": "proposals/evidence.json",
        },
        write=True,
    )

    assert result.ok, result.findings
    assert host.writer_calls == 1
    assert {path, EVIDENCE} <= {row.path for row in result.artifacts}
    assert EVIDENCE in service_io.disk.store.files


def test_ungranted_change_is_refused_before_any_write(
    service_io: MemoryService,
) -> None:
    """A planned change outside the invocation's grants never reaches the writer."""
    host = MemoryHostService(service_io, grants=CONTRACT_GRANTS[:1])
    before = dict(service_io.disk.store.files)

    result = invoke_host(
        host, "new-contract", {"feature_id": "feature", "name": "Feature"}, write=True
    )

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert host.writer_calls == 0 and service_io.disk.store.files == before


@pytest.mark.parametrize(
    "fields",
    [
        # A well-formed reference (16+ characters) naming another invocation.
        {"invocation_ref": "invocation-gamma"},
        {"authorization_ref": None},
        # A structural request carrying no host marker reaches the admission rule.
        {"mode": "structural", "invocation_ref": None, "authorization_ref": None},
    ],
)
def test_host_requests_without_their_bindings_are_refused_before_capture(
    service_io: MemoryService, fields: dict[str, object]
) -> None:
    """A mismatched invocation, missing authorization or non-agent mode exits 3."""
    host = MemoryHostService(service_io, grants=CONTRACT_GRANTS)
    before = dict(service_io.disk.store.files)

    result = invoke_host(
        host,
        "new-contract",
        {"feature_id": "feature", "name": "Feature"},
        write=True,
        **fields,
    )

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert result.input_manifest is None
    assert host.writer_calls == 0 and service_io.disk.store.files == before


def test_root_only_operation_is_refused_under_host_authority(
    service_io: MemoryService,
) -> None:
    """A host principal cannot run a root-only operation even in structural mode."""
    host = MemoryHostService(service_io, grants=CONTRACT_GRANTS)
    before = dict(service_io.disk.store.files)

    result = invoke_host(
        host,
        "configure",
        {"configuration_action": "activate", "input_path": DEFAULT_PROFILE},
        mode="structural",
        invocation_ref=None,
        authorization_ref=AUTHORIZATION_REF,
    )

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert host.writer_calls == 0 and service_io.disk.store.files == before


def test_host_authority_without_invocation_is_refused(
    service_io: MemoryService,
) -> None:
    """A host authority that carries no verified invocation is not admitted."""
    host = MemoryHostService(service_io, grants=CONTRACT_GRANTS)
    host.invocation = None

    result = invoke_host(
        host, "new-contract", {"feature_id": "feature", "name": "Feature"}, write=True
    )

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert host.writer_calls == 0 and result.input_manifest is None


def test_provider_value_that_is_not_a_service_authority_is_refused(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A provider that returns anything but a ServiceAuthority is never admitted."""
    host = MemoryHostService(service_io, grants=CONTRACT_GRANTS)

    def forged(request: object, *, baseline: object) -> object:
        """Return a look-alike value instead of a ServiceAuthority."""
        return {"principal": "host", "author_or_agent": host.agent_id}

    monkeypatch.setattr(host, "authorize", forged)

    result = invoke_host(
        host, "new-contract", {"feature_id": "feature", "name": "Feature"}, write=True
    )

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert host.writer_calls == 0 and result.input_manifest is None


def test_local_user_behavior_is_unchanged(service_io: MemoryService) -> None:
    """The same memory service still refuses host markers under local-user rules."""
    host = MemoryHostService(service_io, grants=CONTRACT_GRANTS)
    host.principal = "local-user"
    host.invocation = None

    result = invoke_host(
        host, "new-contract", {"feature_id": "feature", "name": "Feature"}, write=True
    )

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert host.writer_calls == 0 and result.input_manifest is None
