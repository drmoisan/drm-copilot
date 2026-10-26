"""Prove grant derivation and attribution follow the principal without expansion."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.agent_output import InvocationContext
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.mutation_plan import MutationChange
from drm_copilot_discovery.operation_grants import attribution, derive_grants
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.service_contracts import ServiceAuthority, ServiceRequest

from tests.discovery_runtime.test_service import MemoryService
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan

if TYPE_CHECKING:
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

CONTRACT = "docs/migration/discovery/feature-contracts/feature.json"
QUESTIONS = "docs/migration/discovery/unspecified-behaviors.yaml"
CHANGES = (
    MutationChange(
        artifact_kind="feature-contract",
        artifact_id="feature",
        path=CONTRACT,
        content=b"{}",
        expected_sha256=None,
    ),
    MutationChange(
        artifact_kind="unspecified-behavior-collection",
        artifact_id="questions",
        path=QUESTIONS,
        content=b"records: []\n",
        expected_sha256=None,
    ),
)
EXACT = tuple(
    WriteGrant(artifact_kind=c.artifact_kind, artifact_id=c.artifact_id, path=c.path)
    for c in CHANGES
)


def request(
    *, invocation: str | None = None, authorization: str | None = None
) -> ServiceRequest:
    """Return a new-contract request with optional host markers."""
    return ServiceRequest(
        id="request",
        request_id="correlation",
        operation="new-contract",
        mode="agent-output" if invocation else "structural",
        workspace_root="/workspace",
        profile_path=None,
        dry_run=False,
        write=False,
        format="json",
        inputs=JsonObject((("feature_id", "feature"), ("name", "Feature"))),
        invocation_ref=invocation,
        authorization_ref=authorization,
    )


def invocation(snapshot: DiscoverySnapshot) -> InvocationContext:
    """Return a minimal verified invocation context over snapshot."""
    return InvocationContext(
        baseline=snapshot,
        role="legacy-parity-analyst",
        invocation_id="invocation-alpha",
        workspace=JsonObject(()),
        required_outputs=JsonObject(()),
    )


def local(grants: tuple[WriteGrant, ...] = ()) -> ServiceAuthority:
    """Return a local-user authority with optional provider grants."""
    return ServiceAuthority(
        principal="local-user",
        author_or_agent="operator",
        invocation=None,
        grants=grants,
        read_selection=None,
    )


def host(
    snapshot: DiscoverySnapshot, grants: tuple[WriteGrant, ...] = EXACT
) -> ServiceAuthority:
    """Return a host authority bound to invocation-alpha with grants."""
    return ServiceAuthority(
        principal="host",
        author_or_agent="agent-alpha",
        invocation=invocation(snapshot),
        grants=grants,
        read_selection=None,
    )


@pytest.fixture
def snapshot(service_io: MemoryService) -> DiscoverySnapshot:
    """Capture the configured memory workspace once for the host contexts."""
    from drm_copilot_discovery.configuration import DEFAULT_PROFILE
    from drm_copilot_discovery.mutation_io import capture_workspace

    return capture_workspace(
        workspace_root=service_io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=service_io.disk.store.metadata,
        read_bytes=service_io.disk.store.read,
        catalog=service_io.initialization.catalog,
        repository=service_io.repository,
    ).snapshot


def test_local_user_derives_exact_rows_from_its_changes() -> None:
    """A local-user without provider grants receives exactly the planned rows."""
    assert derive_grants(local(), request(), CHANGES) == EXACT


def test_local_user_provider_grants_must_match_exactly() -> None:
    """Nonempty provider grants are returned only when they equal the planned rows."""
    assert derive_grants(local(EXACT), request(), CHANGES) == EXACT
    with pytest.raises(OperationFailure) as caught:
        derive_grants(local(EXACT[:1]), request(), CHANGES)
    assert caught.value.exit_code == 3


@pytest.mark.parametrize(
    "fields",
    [
        {"invocation": "invocation-alpha"},
        {"authorization": "protected-alpha-00000001"},
    ],
)
def test_local_user_refuses_host_markers(fields: dict[str, str]) -> None:
    """Request references never let a local-user derive grants."""
    with pytest.raises(OperationFailure) as caught:
        derive_grants(local(), request(**fields), CHANGES)
    assert caught.value.exit_code == 3


def test_host_receives_only_granted_rows_without_expansion(
    snapshot: DiscoverySnapshot,
) -> None:
    """Every change inside the invocation's grants is returned; nothing is added."""
    extra = WriteGrant(
        artifact_kind="evidence-reference",
        artifact_id="proof",
        path="docs/migration/discovery/evidence/proof.json",
    )
    bound = request(
        invocation="invocation-alpha", authorization="protected-alpha-00000001"
    )

    granted = derive_grants(host(snapshot, (*EXACT, extra)), bound, CHANGES)

    assert granted == EXACT
    assert derive_grants(host(snapshot), bound, CHANGES[:1]) == EXACT[:1]


@pytest.mark.parametrize(
    "grants,fields",
    [
        (EXACT[:1], {"invocation": "invocation-alpha", "authorization": "protected-alpha-00000001"}),
        (EXACT, {"invocation": "invocation-beta", "authorization": "protected-alpha-00000001"}),
        (EXACT, {"invocation": "invocation-alpha"}),
        ((), {"invocation": "invocation-alpha", "authorization": "protected-alpha-00000001"}),
    ],
)
def test_host_refuses_ungranted_mismatched_or_unauthorized_changes(
    snapshot: DiscoverySnapshot,
    grants: tuple[WriteGrant, ...],
    fields: dict[str, str],
) -> None:
    """An ungranted path, another invocation or a missing authorization is refused."""
    with pytest.raises(OperationFailure) as caught:
        derive_grants(host(snapshot, grants), request(**fields), CHANGES)
    assert caught.value.exit_code == 3
    assert caught.value.findings[0].code == "SERVICE_AUTHORITY"


def test_host_without_invocation_is_refused(snapshot: DiscoverySnapshot) -> None:
    """A host authority that carries no verified invocation derives nothing."""
    authority = ServiceAuthority(
        principal="host",
        author_or_agent="agent-alpha",
        invocation=None,
        grants=EXACT,
        read_selection=None,
    )
    with pytest.raises(OperationFailure):
        derive_grants(
            authority,
            request(invocation="invocation-alpha", authorization="x" * 20),
            CHANGES,
        )


def test_attribution_follows_the_principal(snapshot: DiscoverySnapshot) -> None:
    """Local-user attribution is human; host attribution is agent."""
    assert attribution(local()) == JsonObject((("kind", "human"), ("id", "operator")))
    assert attribution(host(snapshot)) == JsonObject(
        (("kind", "agent"), ("id", "agent-alpha"))
    )
