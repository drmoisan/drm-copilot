"""Prove the host-principal gateway composition over memory stores."""

from __future__ import annotations

import json
from hashlib import sha256
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.gateway_host import (
    HostServiceIO,
    invocation_directory,
    partition_name,
    session_directory,
)
from drm_copilot_discovery.mutation_io import GuardedMutationWriter
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.service_contracts import ServiceAuthority
from drm_copilot_discovery.service_request_rules import CONTROLLED_OPERATIONS

from tests.discovery_runtime.gateway_host_test_support import (
    AGENT,
    EXISTING_BYTES,
    EXISTING_OUTPUT,
    FINALIZE_REFERENCE,
    FIXTURE,
    INVOCATION,
    NEW_OUTPUT,
    READ_REFERENCE,
    ROLE,
    SESSION,
    SOURCE,
    host_case,
    new_contract,
    request,
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
    from tests.discovery_runtime.test_service import MemoryService


def test_partition_paths_follow_the_host_digest_layout(
    service_io: MemoryService,
) -> None:
    """Session and invocation partitions are the sha256 of the correlation ids."""
    location = service_io.configuration.location

    assert partition_name(SESSION) == sha256(SESSION.encode()).hexdigest()
    assert session_directory(location, SESSION) == (
        f"{location.directory}/sessions/{partition_name(SESSION)}"
    )
    assert invocation_directory(location, SESSION, INVOCATION) == (
        f"{session_directory(location, SESSION)}/invocations/"
        f"{partition_name(INVOCATION)}"
    )


def test_controlled_operations_equal_the_pinned_fixture() -> None:
    """The Python controlled set is the fixture both runtimes assert against."""
    fixture = json.loads(FIXTURE.read_text(encoding="utf-8"))

    assert sorted(CONTROLLED_OPERATIONS) == fixture["controlled_operations"]


def test_host_authority_binds_invocation_grants_and_pinned_baseline(
    service_io: MemoryService,
) -> None:
    """A verified request yields a host authority bound to the prepared baseline."""
    case = host_case(service_io)
    # The agent has since created the new output and rewritten the existing one.
    service_io.disk.store.put(NEW_OUTPUT, b'{"id": "feature-alpha"}\n')
    service_io.disk.store.put(EXISTING_OUTPUT, b'{"id": "feature-beta-v2"}\n')
    before = dict(service_io.disk.store.files)

    authority = case.io.authorize(new_contract(case), baseline=case.capture())

    assert authority.principal == "host" and authority.author_or_agent == AGENT
    assert authority.invocation is not None
    assert authority.invocation.invocation_id == INVOCATION
    assert authority.invocation.role == ROLE
    assert authority.invocation.selected_ids == ("feature-alpha",)
    assert authority.grants == (
        WriteGrant(
            artifact_kind="feature-contract",
            artifact_id="feature-alpha",
            path=NEW_OUTPUT,
        ),
        WriteGrant(
            artifact_kind="feature-contract",
            artifact_id="feature-beta",
            path=EXISTING_OUTPUT,
        ),
    )
    baseline_files = {
        f.path: f.content for f in authority.invocation.baseline.manifest.files
    }
    assert NEW_OUTPUT not in baseline_files
    assert baseline_files[EXISTING_OUTPUT] == EXISTING_BYTES
    assert authority.read_selection is None
    assert case.store.writes == [] and service_io.disk.store.files == before
    assert service_io.writer_calls == 0


def test_authorize_before_capture_uses_its_own_bound_capture(
    service_io: MemoryService,
) -> None:
    """Without a service capture the host IO captures through the same ports."""
    case = host_case(service_io)

    authority = case.io.authorize(new_contract(case), baseline=None)

    assert authority.principal == "host" and authority.invocation is not None
    assert {f.path for f in authority.invocation.baseline.manifest.files} >= {
        DEFAULT_PROFILE,
        EXISTING_OUTPUT,
    }
    assert case.store.writes == []


def test_read_source_authority_is_bounded_by_the_selected_paths(
    service_io: MemoryService,
) -> None:
    """A read inside the invocation's selected paths yields exact read grants."""
    case = host_case(service_io)
    case.authorization(
        READ_REFERENCE, tool="read_discovery_source", operation="read-source"
    )

    authority = case.io.authorize(
        request(
            "read-source",
            {"read_operation": "read", "paths": [SOURCE]},
            root=service_io.disk.root,
            reference=READ_REFERENCE,
        ),
        baseline=case.capture(),
    )

    assert authority.principal == "host" and authority.read_selection is not None
    assert [grant.path for grant in authority.read_selection.grants] == [SOURCE]
    assert authority.read_selection.grants[0].directory is False


def test_finalize_authority_carries_every_required_output_grant(
    service_io: MemoryService,
) -> None:
    """finalize-agent is admitted under host with the invocation's grants."""
    case = host_case(service_io)
    case.authorization(
        FINALIZE_REFERENCE, tool="finalize_discovery_agent", operation="finalize-agent"
    )

    authority = case.io.authorize(
        request(
            "finalize-agent", root=service_io.disk.root, reference=FINALIZE_REFERENCE
        ),
        baseline=case.capture(),
    )

    assert authority.principal == "host" and len(authority.grants) == 2
    assert authority.invocation is not None
    assert authority.invocation.required_outputs["invocation_id"] == INVOCATION


def test_writer_is_issued_only_for_the_verified_host_authority(
    service_io: MemoryService,
) -> None:
    """The writer binds the host principal, agent and a verified invocation."""
    case = host_case(service_io)
    baseline = case.capture()
    authority = case.io.authorize(new_contract(case), baseline=baseline)

    writer = case.io.writer(baseline, authority=authority)

    assert isinstance(writer, GuardedMutationWriter)
    local = ServiceAuthority(
        principal="local-user",
        author_or_agent=AGENT,
        invocation=None,
        grants=(),
        read_selection=None,
    )
    with pytest.raises(PermissionError):
        case.io.writer(baseline, authority=local)
    other_agent = ServiceAuthority(
        principal="host",
        author_or_agent="agent-beta",
        invocation=authority.invocation,
        grants=authority.grants,
        read_selection=None,
    )
    with pytest.raises(PermissionError):
        case.io.writer(baseline, authority=other_agent)
    fresh = HostServiceIO(
        activation=service_io.activation,
        repository=service_io.repository,
        principal=case.io.principal,
        store=case.store,
        runtime_identity=service_io.runtime_identity,
    )
    with pytest.raises(PermissionError):
        fresh.writer(baseline, authority=authority)
    assert case.store.writes == [] and service_io.writer_calls == 0


def test_capability_observation_is_never_reported_for_a_host(
    service_io: MemoryService,
) -> None:
    """Doctor is not a host operation, so the host IO observes no capability."""
    case = host_case(service_io)

    assert case.io.capability_observation() is None
    assert case.io.runtime_identity() == service_io.runtime_identity()


def test_host_io_never_writes_the_protected_store(service_io: MemoryService) -> None:
    """Every store interaction of a successful authorization is a read."""
    case = host_case(service_io)

    case.io.authorize(new_contract(case), baseline=case.capture())

    assert case.store.writes == []
    assert all(
        path.startswith(case.directory) or path.startswith(case.session)
        for path in case.store.reads
    )
