"""Verify evidence bytes, immutable pins and delegated mutation safety boundaries."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import evidence_linking
from drm_copilot_discovery.evidence_linking import (
    EvidencePayload,
    evidence_changes,
    plan_evidence_link,
)
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.evidence_test_support import CONTENT, request_for
from tests.discovery_runtime.evidence_test_support import link_baseline as link_baseline
from tests.discovery_runtime.mutation_test_support import constant, grants_for
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)
from tests.discovery_runtime.test_evidence_linking import evidence_plan as evidence_plan
from tests.discovery_runtime.test_references import immutable
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.mutation_plan import (
        CapturedWorkspace,
        MutationChange,
        MutationPlan,
    )
    from drm_copilot_discovery.path_models import WriteGrant


@pytest.mark.parametrize(
    "path",
    ["../escape.txt", "C:/outside.txt", "/absolute.txt", "evidence/../escape.txt"],
)
def test_payload_paths_reject_escape_without_filesystem_access(path: str) -> None:
    """Input normalization never turns escaping paths into writable local names."""
    with pytest.raises(ValueError):
        EvidencePayload(path=path, content=CONTENT)


def test_payload_requires_exact_immutable_bytes() -> None:
    """Mutable byte buffers cannot change proposed content after authorization."""
    with pytest.raises(ValueError, match="immutable"):
        EvidencePayload(path="capture.txt", content=cast("bytes", bytearray(CONTENT)))


@pytest.mark.parametrize(
    "changes",
    [
        {"artifact_id": "../bad"},
        {"expected_sha256": "invalid"},
        {"expected_sha256": None},
        {"record": {}},
        {"payloads": (object(),)},
        {"link_path": (True,)},
        {"link_path": (-1,)},
    ],
)
def test_request_contract_rejects_invalid_identity_digest_and_mutable_values(
    link_baseline: CapturedWorkspace, changes: dict[str, object]
) -> None:
    """Malformed selectors fail at construction before graph traversal or I/O."""
    request = request_for(link_baseline)
    with pytest.raises(ValueError):
        replace(request, **changes)


def test_request_detaches_caller_sequences(link_baseline: CapturedWorkspace) -> None:
    """Mutable outer sequences cannot alter a frozen request after construction."""
    request = request_for(link_baseline)
    payloads = list(request.payloads)
    path: list[str | int] = ["trigger", "evidence_refs"]
    detached = replace(
        request,
        payloads=cast("tuple[EvidencePayload, ...]", payloads),
        link_path=cast("tuple[str | int, ...]", path),
    )
    payloads.clear()
    path.clear()
    assert detached.payloads == request.payloads and detached.link_path == (
        "trigger",
        "evidence_refs",
    )


def test_unrelated_payload_cannot_be_added_to_an_evidence_operation(
    link_baseline: CapturedWorkspace,
) -> None:
    """Exact grants alone cannot smuggle a file not identified by the record."""
    request = replace(
        request_for(link_baseline),
        payloads=(
            EvidencePayload(
                path="docs/migration/discovery/evidence/unrelated.txt", content=CONTENT
            ),
        ),
    )
    with pytest.raises(MutationError) as caught:
        evidence_changes(link_baseline, request)
    assert caught.value.code == "EVIDENCE_PAYLOAD"


@pytest.mark.parametrize("kind", ["source", "test"])
def test_source_and_test_records_use_actual_captured_immutable_objects(
    link_baseline: CapturedWorkspace, kind: str
) -> None:
    """A full pin and matching retained Git bytes pass prospective validation."""
    request = replace(
        request_for(
            link_baseline,
            kind=kind,
            updates={
                "path": "src/code.py" if kind == "source" else "tests/test_code.py"
            },
        ),
        payloads=(),
    )
    retained = RepositoryFile(
        repository=RepositoryIdentity(
            id=link_baseline.snapshot.profile.repository.id, revision="a" * 40
        ),
        path=str(request.record["path"]),
        content=CONTENT,
    )
    baseline = replace(
        link_baseline,
        snapshot=replace(link_baseline.snapshot, repository_files=(retained,)),
    )
    changes = evidence_changes(baseline, request)
    result = plan_evidence_link(baseline, request, grants=grants_for(*changes))
    assert result.validation.ok and retained in result.prospective.repository_files
    assert len(result.writes) == 2


def test_working_bytes_cannot_replace_missing_pinned_source(
    link_baseline: CapturedWorkspace,
) -> None:
    """Newly supplied local bytes cannot substitute for immutable Git proof."""
    request = request_for(link_baseline, kind="source")
    changes = evidence_changes(link_baseline, request)
    with pytest.raises(MutationError) as caught:
        plan_evidence_link(link_baseline, request, grants=grants_for(*changes))
    assert caught.value.code == "MUTATION_INVALID"
    assert "EVIDENCE_CONTENT_UNAVAILABLE" in {
        item.code for item in caught.value.findings
    }


@pytest.mark.parametrize("invalid", ["checksum", "second-capture"])
def test_payload_integrity_uses_both_exact_declared_paths(
    link_baseline: CapturedWorkspace, invalid: str
) -> None:
    """Wrong checksum or a mismatched second runtime path blocks the complete plan."""
    request = request_for(link_baseline)
    if invalid == "checksum":
        request = replace(
            request, payloads=(replace(request.payloads[0], content=b"changed"),)
        )
    else:
        other = "docs/migration/discovery/evidence/other.txt"
        document = as_object(to_plain_value(request.record))
        as_object(document["runtime_artifact"])["path"] = other
        request = replace(
            request,
            record=immutable(document),
            payloads=(
                *request.payloads,
                EvidencePayload(path=other, content=b"different"),
            ),
        )
    changes = evidence_changes(link_baseline, request)
    with pytest.raises(MutationError) as caught:
        plan_evidence_link(link_baseline, request, grants=grants_for(*changes))
    assert caught.value.code == "MUTATION_INVALID"
    assert "EVIDENCE_CHECKSUM" in {item.code for item in caught.value.findings}


def test_uri_description_cannot_be_registered_as_locally_verified_evidence(
    link_baseline: CapturedWorkspace,
) -> None:
    """Structurally allowed descriptive URLs cannot satisfy the local-proof gate."""
    request = replace(
        request_for(
            link_baseline,
            kind="documentation",
            updates={
                "path": None,
                "uri": "https://example.invalid/proof",
                "checksum": None,
            },
        ),
        payloads=(),
    )
    changes = evidence_changes(link_baseline, request)
    with pytest.raises(MutationError) as caught:
        plan_evidence_link(link_baseline, request, grants=grants_for(*changes))
    assert caught.value.code == "EVIDENCE_UNVERIFIED"


@pytest.mark.parametrize(
    "invalid", ["grant", "digest", "collision", "outside-root", "duplicate-payload"]
)
def test_shared_planner_rejects_ungranted_stale_or_colliding_writes(
    link_baseline: CapturedWorkspace, invalid: str
) -> None:
    """The evidence composition cannot bypass accepted kind/path/ID or CAS checks."""
    request = request_for(link_baseline)
    changes = evidence_changes(link_baseline, request)
    grants = grants_for(*changes)
    if invalid == "grant":
        grants = (replace(grants[0], artifact_id="wrong"), *grants[1:])
    elif invalid == "digest":
        request = replace(request, expected_sha256="0" * 64)
    elif invalid == "collision":
        # Create-only registration cannot replace a pre-existing opaque file.
        link_baseline = replace(
            link_baseline,
            snapshot=replace(
                link_baseline.snapshot,
                manifest=replace(
                    link_baseline.snapshot.manifest,
                    files=(
                        *link_baseline.snapshot.manifest.files,
                        evidence_plan_file(request.payloads[0]),
                    ),
                ),
            ),
        )
    elif invalid == "outside-root":
        path = "docs/outside.txt"
        document = as_object(to_plain_value(request.record))
        document["path"] = path
        as_object(document["runtime_artifact"])["path"] = path
        request = replace(
            request,
            record=immutable(document),
            payloads=(EvidencePayload(path=path, content=CONTENT),),
        )
        grants = grants_for(*evidence_changes(link_baseline, request))
    else:
        request = replace(request, payloads=request.payloads * 2)
    with pytest.raises((MutationError, PathPolicyError)) as caught:
        plan_evidence_link(link_baseline, request, grants=grants)
    assert (
        caught.value.code
        == {
            "grant": "MUTATION_GRANT",
            "digest": "MUTATION_PRECONDITION",
            "collision": "MUTATION_PRECONDITION",
            "outside-root": "PATH_WRITE_DENIED",
            "duplicate-payload": "PATH_COLLISION",
        }[invalid]
    )


def evidence_plan_file(payload: EvidencePayload) -> SnapshotFile:
    """Build one captured opaque payload for a precondition-only test."""
    return SnapshotFile(path=payload.path, content=payload.content, category="evidence")


def test_custom_root_controls_record_and_supplied_payload_locations(
    link_baseline: CapturedWorkspace,
) -> None:
    """Projection uses accepted profile data rather than a hard-coded discovery path."""
    document = as_object(to_plain_value(link_baseline.snapshot.profile.document))
    as_object(document["artifacts"])["evidence"] = "work/proofs"
    document["evidence_roots"] = ["work/proofs"]
    profile = ProfileV2(
        json.dumps(document), format="json", catalog=link_baseline.snapshot.catalog
    )
    baseline = replace(
        link_baseline, snapshot=replace(link_baseline.snapshot, profile=profile)
    )
    changes = evidence_changes(baseline, request_for(baseline))
    assert changes[0].path == "work/proofs/proof.json"
    assert changes[2].path == "work/proofs/capture.txt"


def test_planner_forwards_native_context_and_exact_grants_without_creation(
    link_baseline: CapturedWorkspace,
    evidence_plan: MutationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The thin boundary cannot derive or replace invocation identity and grants."""
    context = cast("InvocationContext", object())
    seen: list[object] = []

    def planned(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None,
    ) -> MutationPlan:
        """Record composition arguments without rerunning unchanged graph semantics."""
        seen.extend((baseline, changes, grants, invocation))
        return evidence_plan

    monkeypatch.setattr(evidence_linking, "plan_mutation", planned)
    request = request_for(link_baseline)
    result = plan_evidence_link(
        link_baseline, request, grants=evidence_plan.grants, invocation=context
    )
    assert result is evidence_plan
    assert seen == [
        link_baseline,
        evidence_changes(link_baseline, request),
        evidence_plan.grants,
        context,
    ]


def test_unverified_assessment_cannot_be_hidden_by_an_injected_plan(
    link_baseline: CapturedWorkspace,
    evidence_plan: MutationPlan,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Evidence eligibility remains explicit even after a successful planner result."""
    request = request_for(link_baseline)
    prospective = replace(
        evidence_plan.prospective,
        manifest=replace(
            evidence_plan.prospective.manifest,
            files=tuple(
                file
                for file in evidence_plan.prospective.manifest.files
                if file.path != request.payloads[0].path
            ),
        ),
    )
    monkeypatch.setattr(
        evidence_linking,
        "plan_mutation",
        constant(replace(evidence_plan, prospective=prospective)),
    )
    with pytest.raises(MutationError) as caught:
        plan_evidence_link(link_baseline, request, grants=evidence_plan.grants)
    assert caught.value.code == "EVIDENCE_UNVERIFIED" and caught.value.findings
