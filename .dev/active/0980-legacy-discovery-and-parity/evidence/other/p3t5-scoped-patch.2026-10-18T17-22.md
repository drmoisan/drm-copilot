# P3-T5 exact staged review patch

Timestamp: 2026-10-18T17-22
Baseline: 1cc73b60cd636f186ca0269bf3942d32acd18105
Representation: UTF-8 zero-context unified diff with full Git blob identities; exact four owned paths.

```diff
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py b/packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py
new file mode 100644
index 0000000000000000000000000000000000000000..ff34edd78af35c96c248afbe1bef2eeba87fa428
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py
@@ -0,0 +1,343 @@
+"""Register locally verifiable evidence without changing any observation or approval."""
+
+from __future__ import annotations
+
+from dataclasses import dataclass
+from typing import TYPE_CHECKING, cast
+
+from drm_copilot_discovery.catalog import V2_URN
+from drm_copilot_discovery.evidence_rules import assess_evidence
+from drm_copilot_discovery.findings import child_pointer
+from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
+from drm_copilot_discovery.mutation_io import commit_mutation
+from drm_copilot_discovery.mutation_plan import (
+    MutationChange,
+    MutationError,
+    plan_mutation,
+)
+from drm_copilot_discovery.path_models import WriteGrant, relative_path
+from drm_copilot_discovery.reference_links import schema_references
+from drm_copilot_discovery.references import ArtifactRecord, index_references
+from drm_copilot_discovery.revision_rules import RevisionInputs
+from drm_copilot_discovery.schema_validation import validate_document
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.agent_output import InvocationContext
+    from drm_copilot_discovery.mutation_io import MutationResult, MutationWriter
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
+
+
+@dataclass(frozen=True, kw_only=True)
+class EvidencePayload:
+    """Carry exact supplied bytes for exclusive creation under an allowed evidence root.
+
+    The relative path must be named by the evidence record. Construction performs
+    no I/O and grants no authority; the shared planner enforces roots and grants.
+    """
+
+    path: str
+    content: bytes
+
+    def __post_init__(self) -> None:
+        """Reject unsafe names or mutable payloads with ValueError; return None."""
+        relative_path(self.path)
+        if not isinstance(cast("object", self.content), bytes):
+            raise ValueError("Evidence payload content must be immutable bytes")
+
+
+@dataclass(frozen=True, kw_only=True)
+class EvidenceLink:
+    """Select one local artifact/member, its original digest and supplied provenance.
+
+    link_path optionally names an existing evidence-reference array relative to
+    the selected record, using object keys and integer array positions. Defaults
+    cover feature, scenario, question, decision approval and implementation links.
+    Collection members require a grant for their containing file. These inputs
+    convey no native authority and cannot set claim, run or approval state.
+    """
+
+    artifact_kind: str
+    artifact_id: str
+    expected_sha256: str
+    record: JsonObject
+    payloads: tuple[EvidencePayload, ...] = ()
+    link_path: tuple[str | int, ...] = ()
+
+    def __post_init__(self) -> None:
+        """Detach supplied sequences; return None or raise ValueError for bad inputs."""
+        object.__setattr__(self, "payloads", tuple(self.payloads))
+        object.__setattr__(self, "link_path", tuple(self.link_path))
+        MutationChange(
+            artifact_kind=self.artifact_kind,
+            artifact_id=self.artifact_id,
+            path="selected.json",
+            content=b"",
+            expected_sha256=self.expected_sha256,
+        )
+        # Reject mutable provenance and invalid path tokens before graph traversal.
+        if (
+            cast("object", self.expected_sha256) is None
+            or not isinstance(cast("object", self.record), JsonObject)
+            or any(
+                not isinstance(cast("object", item), EvidencePayload)
+                for item in self.payloads
+            )
+            or any(
+                type(item) not in (str, int) or isinstance(item, int) and item < 0
+                for item in self.link_path
+            )
+        ):
+            raise ValueError(
+                "Evidence links require immutable provenance and selectors"
+            )
+
+
+def _default_path(kind: str, evidence_type: JsonValue) -> tuple[str | int, ...]:
+    """Return core field tokens for the selected kind/type without effects.
+
+    Unsupported or row-based kinds return an empty tuple requiring an explicit
+    selector; this lookup neither creates a field nor validates its current value.
+    """
+    # Runtime captures and manual observations belong to the feature's runtime links.
+    if kind == "feature-contract":
+        return (
+            (
+                "runtime_evidence_refs"
+                if evidence_type in ("runtime", "observation")
+                else "source_evidence_refs"
+            ),
+        )
+    return {
+        "runtime-characterization-scenario": ("evidence_refs",),
+        "unspecified-behavior": ("evidence_refs",),
+        "acceptance-specification": ("evidence_refs",),
+        "implementation-record": ("verification_evidence_refs",),
+        "product-decision": ("approval", "evidence_refs"),
+    }.get(kind, ())
+
+
+def _append_link(
+    value: JsonValue, path: tuple[str | int, ...], reference: JsonObject
+) -> tuple[JsonValue, int]:
+    """Return copied value and link index, following typed path tokens in memory.
+
+    reference is appended only to an existing tuple leaf, with exact repeats
+    retained once. Invalid paths/leaves raise MutationError; inputs stay immutable.
+    """
+    # Only the selected leaf can grow; object members and array siblings stay exact.
+    if not path:
+        if not isinstance(value, tuple):
+            raise MutationError("EVIDENCE_LINK_FIELD", "Select an existing link array")
+        if reference in value:
+            return value, value.index(reference)
+        return (*value, reference), len(value)
+    head, *tail = path
+    if isinstance(value, JsonObject) and isinstance(head, str) and head in value:
+        updated, position = _append_link(value[head], tuple(tail), reference)
+        return JsonObject(tuple({**value, head: updated}.items())), position
+    if isinstance(value, tuple) and isinstance(head, int) and 0 <= head < len(value):
+        updated, position = _append_link(value[head], tuple(tail), reference)
+        return (*value[:head], updated, *value[head + 1 :]), position
+    raise MutationError("EVIDENCE_LINK_FIELD", "The selected link field does not exist")
+
+
+def _linked_document(
+    baseline: CapturedWorkspace,
+    target: ArtifactRecord,
+    request: EvidenceLink,
+    reference: JsonObject,
+) -> JsonObject:
+    """Append only where the accepted schema identifies an evidence reference.
+
+    Schema-directed traversal excludes extension payloads and arbitrary arrays.
+    baseline supplies the trusted catalog; target supplies the containing document
+    and member pointer. request selects the leaf for the supplied reference.
+    The containing artifact is preserved, including collection siblings and all
+    observation/approval fields. Return its updated immutable object without I/O;
+    missing or non-evidence locations raise MutationError.
+    """
+    selected = request.link_path or _default_path(
+        target.kind, request.record.get("evidence_type")
+    )
+    # Indexed member pointers are generated by the accepted collection index.
+    prefix: tuple[str | int, ...] = tuple(
+        int(part) if part.isdecimal() else part
+        for part in target.pointer.split("/")[1:]
+    )
+    path = prefix + selected
+    document, position = _append_link(target.artifact.document, path, reference)
+    pointer = ""
+    # Retain exact array position for the shared schema traversal's typed leaf.
+    for part in (*path, position):
+        pointer = child_pointer(pointer, part)
+    schemas = dict(baseline.snapshot.catalog.documents)
+    identifier = V2_URN + target.artifact.expected_kind
+    # Recognition must come from a core schema leaf at the exact appended position.
+    if not any(
+        location == pointer and expected == "evidence-reference"
+        for location, _, expected, _ in schema_references(
+            document, schemas[identifier], schemas, base=identifier, pointer=""
+        )
+    ):
+        raise MutationError(
+            "EVIDENCE_LINK_FIELD", "Select a core evidence-reference array"
+        )
+    return cast("JsonObject", document)
+
+
+def evidence_changes(
+    baseline: CapturedWorkspace, request: EvidenceLink
+) -> tuple[MutationChange, ...]:
+    """Project create-only evidence/payloads and one exact-byte artifact update.
+
+    baseline supplies captured bytes/identities and request selects the append.
+    Return immutable MutationChange values using the accepted schema/reference
+    index; no local or remote I/O occurs and neither input is modified.
+    Invalid metadata, duplicate identities, absent/imported targets and unrelated
+    payloads raise MutationError. This projection is not a validated write plan;
+    roots, grants, freshness and the complete graph are checked by plan_evidence_link.
+    """
+    snapshot = baseline.snapshot
+    if not snapshot.ok:
+        raise MutationError(
+            "EVIDENCE_BASELINE",
+            "Captured inputs are invalid",
+            findings=snapshot.findings,
+        )
+    content = canonical_json(request.record)
+    validation = validate_document(
+        content,
+        expected_kind="evidence-reference",
+        expected_version="2.0.0",
+        catalog=snapshot.catalog,
+        limits=snapshot.profile.limits.parse_limits(),
+    )
+    if not validation.ok:
+        raise MutationError(
+            "EVIDENCE_RECORD",
+            "Evidence metadata is invalid",
+            findings=validation.findings,
+        )
+    identifier = cast("str", request.record["id"])
+    path = snapshot.profile.artifacts["evidence"] + "/" + identifier + ".json"
+    index = index_references(snapshot)
+    # IDs remain repository-scoped; imported evidence is never overwritten locally.
+    for field in ("id", "evidence_id"):
+        if index.candidates(
+            "evidence-reference",
+            cast("str", request.record[field]),
+            repository=snapshot.profile.repository.id,
+            identity_field=field,
+        ):
+            raise MutationError(
+                "EVIDENCE_DUPLICATE", "Evidence identity already exists"
+            )
+    targets = index.candidates(
+        request.artifact_kind,
+        request.artifact_id,
+        repository=snapshot.profile.repository.id,
+    )
+    if len(targets) != 1 or targets[0].artifact.origin_path is not None:
+        raise MutationError("EVIDENCE_TARGET", "Select one captured local artifact")
+    target = targets[0]
+    # Local links use the accepted ID form; transport paths require full pinned refs.
+    reference = JsonObject(
+        (("artifact_kind", "evidence-reference"), ("id", identifier))
+    )
+    updated = _linked_document(baseline, target, request, reference)
+    changes = [
+        MutationChange(
+            artifact_kind="evidence-reference",
+            artifact_id=identifier,
+            path=path,
+            content=content,
+            expected_sha256=None,
+        ),
+        MutationChange(
+            artifact_kind=target.artifact.expected_kind,
+            artifact_id=cast("str", cast("JsonObject", target.artifact.document)["id"]),
+            path=target.artifact.path,
+            content=canonical_json(updated),
+            expected_sha256=request.expected_sha256,
+        ),
+    ]
+    runtime = request.record.get("runtime_artifact")
+    payload_paths = {request.record.get("path")}
+    if isinstance(runtime, JsonObject):
+        payload_paths.add(runtime.get("path"))
+    # Supplied bytes cannot smuggle unrelated files into the authorized operation.
+    for payload in request.payloads:
+        if payload.path not in payload_paths:
+            raise MutationError(
+                "EVIDENCE_PAYLOAD", "Payload is not named by the record"
+            )
+        changes.append(
+            MutationChange(
+                artifact_kind="evidence-payload",
+                artifact_id=identifier,
+                path=payload.path,
+                content=payload.content,
+                expected_sha256=None,
+            )
+        )
+    return tuple(changes)
+
+
+def plan_evidence_link(
+    baseline: CapturedWorkspace,
+    request: EvidenceLink,
+    *,
+    grants: tuple[WriteGrant, ...],
+    invocation: InvocationContext | None = None,
+) -> MutationPlan:
+    """Validate a complete prospective graph and require exact local evidence bytes.
+
+    Return a MutationPlan for baseline/request; grants/invocation are forwarded
+    unchanged, never generated here. Source/test
+    proof requires objects already captured at full pins in baseline; working-tree
+    bytes are not substituted. URI-only descriptions cannot satisfy this operation.
+    Shared planning errors or EVIDENCE_UNVERIFIED propagate before any writes.
+    """
+    plan = plan_mutation(
+        baseline,
+        evidence_changes(baseline, request),
+        grants=grants,
+        invocation=invocation,
+    )
+    index = index_references(plan.prospective)
+    record = index.candidates(
+        "evidence-reference",
+        cast("str", request.record["id"]),
+        repository=plan.prospective.profile.repository.id,
+    )[0]
+    assessment = assess_evidence(RevisionInputs(plan.prospective), record)
+    if not assessment.locally_verified:
+        raise MutationError(
+            "EVIDENCE_UNVERIFIED",
+            "Evidence must identify locally verified bytes",
+            findings=assessment.findings,
+        )
+    return plan
+
+
+def link_evidence(
+    baseline: CapturedWorkspace,
+    request: EvidenceLink,
+    *,
+    grants: tuple[WriteGrant, ...],
+    writer: MutationWriter,
+    dry_run: bool = False,
+    invocation: InvocationContext | None = None,
+) -> MutationResult:
+    """Register and link through the shared writer, returning its explicit outcome.
+
+    Planning exceptions propagate without writes. The injected trusted writer owns
+    freshness, invalidation and per-file publication; partial failures remain in its
+    MutationResult. Dry-run performs validation without writes or invalidation.
+    Neither a link nor a successful result promotes a claim or product approval.
+    """
+    return commit_mutation(
+        plan_evidence_link(baseline, request, grants=grants, invocation=invocation),
+        writer=writer,
+        dry_run=dry_run,
+    )
diff --git a/tests/discovery_runtime/evidence_test_support.py b/tests/discovery_runtime/evidence_test_support.py
new file mode 100644
index 0000000000000000000000000000000000000000..c27690845012691a680cdadb5f4646ae8ecee1e4
--- /dev/null
+++ b/tests/discovery_runtime/evidence_test_support.py
@@ -0,0 +1,117 @@
+"""Build immutable evidence fixtures and fresh memory writers for isolated tests."""
+
+from __future__ import annotations
+
+from dataclasses import replace
+from hashlib import sha256
+from typing import TYPE_CHECKING
+
+import pytest
+from drm_copilot_discovery.evidence_linking import EvidenceLink, EvidencePayload
+from drm_copilot_discovery.models import canonical_json
+from drm_copilot_discovery.snapshot import ArtifactSnapshot, SnapshotFile
+
+from tests.discovery_runtime.draft_test_support import add_feature, draft_case
+from tests.discovery_runtime.test_mutation_commit import MemoryWriter
+from tests.discovery_runtime.test_references import immutable
+from tests.discovery_runtime.test_snapshot_io import MemoryStore
+from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+
+CONTENT = b"captured observation\r\nsecond line\n"
+
+
+@pytest.fixture(scope="module")
+def link_baseline(mutation_catalog: SchemaCatalog) -> CapturedWorkspace:
+    """Share immutable real draft inputs; mutable stores are constructed per test."""
+    store, _ = draft_case(mutation_catalog)
+    return add_feature(store, mutation_catalog, "feature")
+
+
+def request_for(
+    baseline: CapturedWorkspace,
+    *,
+    kind: str = "runtime",
+    updates: dict[str, object] | None = None,
+) -> EvidenceLink:
+    """Construct fresh provenance and exact supplied bytes without inventing proof."""
+    target = next(
+        item
+        for item in baseline.snapshot.artifacts
+        if item.expected_kind == "feature-contract"
+    )
+    path = baseline.snapshot.profile.artifacts["evidence"] + "/capture.txt"
+    record = load_fixture("evidence-reference")
+    record.update(
+        id="proof",
+        evidence_id="proof",
+        repository=baseline.snapshot.profile.repository.id,
+        evidence_type=kind,
+        revision="a" * 40 if kind in {"source", "test"} else None,
+        path=path,
+        runtime_artifact=(
+            {"path": path, "capture_method": "manual"}
+            if kind in {"runtime", "observation"}
+            else None
+        ),
+    )
+    as_object(record["environment"])["client_id"] = None
+    as_object(record["checksum"])["value"] = sha256(CONTENT).hexdigest()
+    record.update(updates or {})
+    return EvidenceLink(
+        artifact_kind="feature-contract",
+        artifact_id="feature",
+        expected_sha256=baseline.snapshot.file(target.path).sha256,
+        record=immutable(record),
+        payloads=(EvidencePayload(path=path, content=CONTENT),),
+    )
+
+
+def add_record(
+    baseline: CapturedWorkspace, document: dict[str, object], *, path: str
+) -> CapturedWorkspace:
+    """Add an isolated immutable graph record for narrow projection/error tests."""
+    value = immutable(document)
+    artifact = ArtifactSnapshot(
+        path=path,
+        expected_kind=str(document["artifact_kind"]),
+        repository=baseline.snapshot.artifacts[0].repository,
+        document=value,
+    )
+    files = tuple(
+        file for file in baseline.snapshot.manifest.files if file.path != path
+    )
+    artifacts = tuple(item for item in baseline.snapshot.artifacts if item.path != path)
+    return replace(
+        baseline,
+        snapshot=replace(
+            baseline.snapshot,
+            artifacts=(*artifacts, artifact),
+            manifest=replace(
+                baseline.snapshot.manifest,
+                files=(
+                    *files,
+                    SnapshotFile(
+                        path=path, content=canonical_json(value), category="artifact"
+                    ),
+                ),
+                missing_paths=tuple(
+                    item
+                    for item in baseline.snapshot.manifest.missing_paths
+                    if item != path
+                ),
+            ),
+        ),
+    )
+
+
+def memory_writer(baseline: CapturedWorkspace) -> MemoryWriter:
+    """Recreate a fresh physical model from exact immutable baseline bytes."""
+    store = MemoryStore(baseline.workspace_root)
+    # Only captured bytes populate the new test-owned store.
+    for file in baseline.snapshot.manifest.files:
+        store.put(file.path, file.content)
+    return MemoryWriter(store, baseline.snapshot.catalog)
diff --git a/tests/discovery_runtime/test_evidence_linking.py b/tests/discovery_runtime/test_evidence_linking.py
new file mode 100644
index 0000000000000000000000000000000000000000..41ec2ff1ade98dbd310a6ab2b2192e238d34965b
--- /dev/null
+++ b/tests/discovery_runtime/test_evidence_linking.py
@@ -0,0 +1,480 @@
+"""Check exact evidence-link projections and their unchanged claim/approval states."""
+
+from __future__ import annotations
+
+import json
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery import evidence_linking
+from drm_copilot_discovery.evidence_linking import (
+    EvidenceLink,
+    evidence_changes,
+    link_evidence,
+    plan_evidence_link,
+)
+from drm_copilot_discovery.findings import Finding
+from drm_copilot_discovery.models import JsonObject, canonical_json, to_plain_value
+from drm_copilot_discovery.mutation_io import MutationArtifact, MutationResult
+from drm_copilot_discovery.mutation_plan import MutationError
+
+from tests.discovery_runtime.evidence_test_support import (
+    CONTENT,
+    add_record,
+    memory_writer,
+    request_for,
+)
+from tests.discovery_runtime.evidence_test_support import link_baseline as link_baseline
+from tests.discovery_runtime.mutation_test_support import constant, grants_for
+from tests.discovery_runtime.mutation_test_support import (
+    mutation_catalog as mutation_catalog,
+)
+from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.agent_output import InvocationContext
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
+
+
+@pytest.mark.parametrize(
+    "kind",
+    [
+        "source",
+        "test",
+        "runtime",
+        "observation",
+        "decision",
+        "documentation",
+        "inventory",
+    ],
+)
+def test_registration_projects_exact_provenance_and_preserves_every_other_field(
+    link_baseline: CapturedWorkspace, kind: str
+) -> None:
+    """Every evidence type has a stable record/payload and no claim-state mutation."""
+    request = request_for(link_baseline, kind=kind)
+    before = link_baseline.snapshot.sha256
+    changes = evidence_changes(link_baseline, request)
+    original = next(
+        item
+        for item in link_baseline.snapshot.artifacts
+        if item.path == changes[1].path
+    )
+    updated = as_object(json.loads(changes[1].content))
+    expected = as_object(to_plain_value(original.document))
+    field = (
+        "runtime_evidence_refs"
+        if kind in {"runtime", "observation"}
+        else "source_evidence_refs"
+    )
+    links = cast("list[object]", updated.pop(field))
+    assert expected.pop(field) == []
+    assert updated == expected, "Evidence registration changed unrelated claims"
+    assert links == [{"artifact_kind": "evidence-reference", "id": "proof"}]
+    assert changes[0].content == canonical_json(request.record)
+    assert changes[2].content == CONTENT and changes[2].expected_sha256 is None
+    assert changes[1].expected_sha256 == request.expected_sha256
+    assert evidence_changes(link_baseline, request) == changes
+    assert link_baseline.snapshot.sha256 == before
+
+
+@pytest.mark.parametrize("kind", ["unspecified-behavior", "product-decision"])
+def test_collection_member_update_preserves_siblings_and_approval(
+    link_baseline: CapturedWorkspace, kind: str
+) -> None:
+    """The containing file grant and digest bind a member-only evidence append."""
+    member = load_fixture(kind)
+    if kind == "unspecified-behavior":
+        member.update(
+            status="open",
+            resolution_basis=None,
+            resolution_evidence_refs=[],
+            decision=None,
+            approved_target_behavior=None,
+        )
+    collection = load_fixture(kind + "-collection")
+    members = [member, dict(member, id="unrelated")]
+    collection.update(id="collection", records=members)
+    path = link_baseline.snapshot.profile.artifacts[
+        "product_decisions" if kind == "product-decision" else "unspecified_behaviors"
+    ]
+    baseline = add_record(link_baseline, collection, path=path)
+    request = replace(
+        request_for(baseline),
+        artifact_kind=kind,
+        artifact_id=str(member["id"]),
+        expected_sha256=baseline.snapshot.file(path).sha256,
+    )
+    changes = evidence_changes(baseline, request)
+    value = as_object(json.loads(changes[1].content))
+    records = cast("list[dict[str, object]]", value["records"])
+    assert changes[1].artifact_kind == kind + "-collection"
+    assert changes[1].artifact_id == "collection"
+    assert records[1] == members[1]
+    selected = records[0]
+    assert selected["status"] == member["status"]
+    if kind == "product-decision":
+        approval = as_object(selected["approval"])
+        original = as_object(member["approval"])
+        assert (
+            approval["owner"] == original["owner"]
+            and approval["timestamp"] == original["timestamp"]
+        )
+        assert (
+            cast("list[object]", approval["evidence_refs"])[:-1]
+            == original["evidence_refs"]
+        )
+    else:
+        assert selected["decision"] is selected["resolution_basis"] is None
+
+
+@pytest.mark.parametrize(
+    "path",
+    [
+        ("trigger", "evidence_refs"),
+        ("state_transitions", "entries", 0, "before", "evidence_refs"),
+    ],
+)
+def test_nested_evidence_is_linked_without_promoting_observation(
+    link_baseline: CapturedWorkspace, path: tuple[str | int, ...]
+) -> None:
+    """Nested selection changes one recognized array, including transition phases."""
+    target = next(
+        item
+        for item in link_baseline.snapshot.artifacts
+        if item.expected_kind == "feature-contract"
+    )
+    document = as_object(to_plain_value(target.document))
+    transition = as_object(document["state_transitions"])
+    phase = dict(as_object(document["trigger"]))
+    transition["entries"] = [
+        dict(id="step", before=phase, action=phase, after=phase, evidence_refs=[])
+    ]
+    baseline = add_record(link_baseline, document, path=target.path)
+    request = replace(request_for(baseline), link_path=path)
+    updated = as_object(json.loads(evidence_changes(baseline, request)[1].content))
+    cursor: object = updated
+    original: object = document
+    # Follow the explicit selector so assertions remain independent of serialization.
+    for token in path[:-1]:
+        cursor = (
+            cast("list[object]", cursor)[token]
+            if isinstance(token, int)
+            else as_object(cursor)[token]
+        )
+        original = (
+            cast("list[object]", original)[token]
+            if isinstance(token, int)
+            else as_object(original)[token]
+        )
+    value = as_object(cursor)
+    assert (
+        value["observation_state"]
+        == as_object(original)["observation_state"]
+        == "unknown"
+    )
+    assert (
+        value["statement"] is None
+        and len(cast("list[object]", value["evidence_refs"])) == 1
+    )
+
+
+@pytest.mark.parametrize(
+    "path",
+    [
+        ("extensions", "evidence_refs"),
+        ("acceptance_criteria",),
+        ("absent",),
+        ("name",),
+        ("state_transitions", "entries", 100, "evidence_refs"),
+    ],
+)
+def test_only_core_existing_evidence_arrays_are_eligible(
+    link_baseline: CapturedWorkspace, path: tuple[str | int, ...]
+) -> None:
+    """Arbitrary arrays, scalar state and missing fields cannot receive links."""
+    request = replace(request_for(link_baseline), link_path=path)
+    with pytest.raises(MutationError) as caught:
+        evidence_changes(link_baseline, request)
+    assert caught.value.code == "EVIDENCE_LINK_FIELD"
+
+
+@pytest.mark.parametrize("invalid", ["missing", "duplicate", "imported"])
+def test_target_must_resolve_to_one_local_record(
+    link_baseline: CapturedWorkspace, invalid: str
+) -> None:
+    """Absence, ambiguity and imported identity cannot select a writable destination."""
+    request = request_for(link_baseline)
+    target = next(
+        item
+        for item in link_baseline.snapshot.artifacts
+        if item.expected_kind == "feature-contract"
+    )
+    if invalid == "missing":
+        request = replace(request, artifact_id="missing")
+    else:
+        with_extra = add_record(
+            link_baseline,
+            as_object(to_plain_value(target.document)),
+            path="docs/duplicate.json",
+        )
+        extra = replace(
+            target,
+            path="docs/duplicate.json",
+            origin_path="feature.json" if invalid == "imported" else None,
+        )
+        artifacts = tuple(
+            item
+            for item in link_baseline.snapshot.artifacts
+            if invalid == "duplicate" or item != target
+        )
+        link_baseline = replace(
+            with_extra,
+            snapshot=replace(with_extra.snapshot, artifacts=(*artifacts, extra)),
+        )
+    with pytest.raises(MutationError) as caught:
+        evidence_changes(link_baseline, request)
+    assert caught.value.code == "EVIDENCE_TARGET"
+
+
+@pytest.mark.parametrize("field", ["id", "evidence_id"])
+def test_duplicate_evidence_identity_is_rejected_before_proposing_writes(
+    link_baseline: CapturedWorkspace, field: str
+) -> None:
+    """Both artifact and domain identity namespaces reject existing local records."""
+    request = request_for(link_baseline)
+    record = as_object(to_plain_value(request.record))
+    record["evidence_id" if field == "id" else "id"] = "other"
+    baseline = add_record(
+        link_baseline, record, path="docs/migration/discovery/evidence/other.json"
+    )
+    with pytest.raises(MutationError) as caught:
+        evidence_changes(baseline, request)
+    assert caught.value.code == "EVIDENCE_DUPLICATE"
+
+
+@pytest.mark.parametrize(
+    "change",
+    [
+        {"evidence_type": "manual"},
+        {"revision": "HEAD", "evidence_type": "source"},
+        {"checksum": None},
+        {"timestamp": "invalid"},
+    ],
+)
+def test_malformed_evidence_is_rejected_by_the_accepted_schema(
+    link_baseline: CapturedWorkspace, change: dict[str, object]
+) -> None:
+    """Semantic types and provenance are never coerced or repaired by registration."""
+    request = request_for(link_baseline, updates=change)
+    with pytest.raises(MutationError) as caught:
+        evidence_changes(link_baseline, request)
+    assert caught.value.code == "EVIDENCE_RECORD" and caught.value.findings
+
+
+def test_invalid_captured_input_remains_an_explicit_prewrite_error(
+    link_baseline: CapturedWorkspace,
+) -> None:
+    """Invalid snapshots cannot supply target identities or cause effects."""
+    baseline = replace(
+        link_baseline,
+        snapshot=replace(
+            link_baseline.snapshot,
+            findings=(
+                Finding(
+                    code="TEST_INVALID",
+                    message="Invalid input",
+                    next_action="Correct input",
+                ),
+            ),
+        ),
+    )
+    with pytest.raises(MutationError) as caught:
+        evidence_changes(baseline, request_for(baseline))
+    assert (
+        caught.value.code == "EVIDENCE_BASELINE"
+        and caught.value.findings == baseline.snapshot.findings
+    )
+
+
+@pytest.mark.parametrize("already_linked", [False, True])
+def test_existing_links_are_preserved_and_exact_repeat_is_not_duplicated(
+    link_baseline: CapturedWorkspace, already_linked: bool
+) -> None:
+    """Adding provenance retains unrelated links and one copy of a selected link."""
+    target = next(
+        item
+        for item in link_baseline.snapshot.artifacts
+        if item.expected_kind == "feature-contract"
+    )
+    document = as_object(to_plain_value(target.document))
+    existing = [{"artifact_kind": "evidence-reference", "id": "other"}]
+    selected = {"artifact_kind": "evidence-reference", "id": "proof"}
+    if already_linked:
+        existing.append(selected)
+    document["runtime_evidence_refs"] = existing
+    baseline = add_record(link_baseline, document, path=target.path)
+    result = evidence_changes(baseline, request_for(baseline))
+    updated = as_object(json.loads(result[1].content))
+    assert updated["runtime_evidence_refs"] == [existing[0], selected]
+
+
+def test_evidence_link_cannot_create_a_product_approval(
+    link_baseline: CapturedWorkspace,
+) -> None:
+    """An unapproved decision's null approval cannot become an object during linking."""
+    document = load_fixture("product-decision-collection")
+    member = load_fixture("product-decision")
+    member.update(status="proposed", approval=None)
+    document["records"] = [member]
+    path = link_baseline.snapshot.profile.artifacts["product_decisions"]
+    baseline = add_record(link_baseline, document, path=path)
+    request = replace(
+        request_for(baseline),
+        artifact_kind="product-decision",
+        artifact_id=str(member["id"]),
+        expected_sha256=baseline.snapshot.file(path).sha256,
+    )
+    with pytest.raises(MutationError) as caught:
+        evidence_changes(baseline, request)
+    assert caught.value.code == "EVIDENCE_LINK_FIELD"
+    assert member["approval"] is None and member["status"] == "proposed"
+
+
+@pytest.fixture(scope="module")
+def evidence_plan(link_baseline: CapturedWorkspace) -> MutationPlan:
+    """Exercise the real complete planner once; reuse only its immutable result."""
+    request = request_for(link_baseline)
+    changes = evidence_changes(link_baseline, request)
+    return plan_evidence_link(link_baseline, request, grants=grants_for(*changes))
+
+
+def test_real_plan_validates_local_bytes_and_preserves_unknown_state(
+    evidence_plan: MutationPlan,
+) -> None:
+    """A verifiable evidence link leaves the draft observation explicitly unknown."""
+    assert evidence_plan.validation.ok
+    assert (
+        evidence_plan.prospective.file(
+            "docs/migration/discovery/evidence/capture.txt"
+        ).content
+        == CONTENT
+    )
+    feature = next(
+        item
+        for item in evidence_plan.prospective.artifacts
+        if item.expected_kind == "feature-contract"
+    )
+    assert isinstance(feature.document, JsonObject)
+    trigger = cast("JsonObject", feature.document["trigger"])
+    assert trigger["observation_state"] == "unknown" and trigger["statement"] is None
+
+
+def test_wrapper_forwards_exact_context_grants_and_dry_run(
+    link_baseline: CapturedWorkspace,
+    evidence_plan: MutationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """Thin orchestration forwards dry-run arguments and returns the exact result."""
+    context = cast("InvocationContext", object())
+    seen: list[object] = []
+
+    def planned(
+        baseline: CapturedWorkspace,
+        request: EvidenceLink,
+        *,
+        grants: object,
+        invocation: object,
+    ) -> MutationPlan:
+        """Observe untouched inputs while reusing a genuinely validated plan."""
+        seen.extend((baseline, request, grants, invocation))
+        return evidence_plan
+
+    monkeypatch.setattr(evidence_linking, "plan_evidence_link", planned)
+    request = request_for(link_baseline)
+    writer = memory_writer(link_baseline)
+    expected = MutationResult(
+        ok=True,
+        artifacts=(),
+        findings=(),
+        validation=evidence_plan.validation,
+        authority_invalidated=False,
+    )
+
+    def committed(plan: MutationPlan, **options: object) -> MutationResult:
+        """Observe the wrapper seam; actual publication is an integration concern."""
+        seen.extend((plan, options))
+        return expected
+
+    monkeypatch.setattr(evidence_linking, "commit_mutation", committed)
+    result = link_evidence(
+        link_baseline,
+        request,
+        grants=evidence_plan.grants,
+        writer=writer,
+        dry_run=True,
+        invocation=context,
+    )
+    assert seen == [
+        link_baseline,
+        request,
+        evidence_plan.grants,
+        context,
+        evidence_plan,
+        {"writer": writer, "dry_run": True},
+    ]
+    assert result is expected and writer.invalidations == writer.attempts == 0
+
+
+@pytest.mark.parametrize("fail", [False, True])
+def test_shared_writer_commits_or_reports_explicit_partial_failure(
+    link_baseline: CapturedWorkspace,
+    evidence_plan: MutationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+    fail: bool,
+) -> None:
+    """The wrapper preserves the shared writer's complete or partial disposition."""
+    monkeypatch.setattr(evidence_linking, "plan_evidence_link", constant(evidence_plan))
+    writer = memory_writer(link_baseline)
+    output = evidence_plan.writes[0].change
+    artifact = MutationArtifact(
+        path=output.path,
+        artifact_kind=output.artifact_kind,
+        artifact_id=output.artifact_id,
+        sha256=evidence_plan.prospective.file(output.path).sha256,
+        status="conflict" if fail else "created",
+    )
+    expected = MutationResult(
+        ok=not fail,
+        artifacts=(artifact,),
+        findings=(
+            (
+                Finding(
+                    code="MUTATION_IO", message="bounded failure", next_action="Reload"
+                ),
+            )
+            if fail
+            else ()
+        ),
+        validation=evidence_plan.validation,
+        authority_invalidated=True,
+        uncertain_paths=(output.path,) if fail else (),
+    )
+    seen: list[object] = []
+
+    def committed(plan: MutationPlan, **options: object) -> MutationResult:
+        """Return a distinct shared result without running unrelated graph logic."""
+        seen.extend((plan, options))
+        return expected
+
+    monkeypatch.setattr(evidence_linking, "commit_mutation", committed)
+    result = link_evidence(
+        link_baseline,
+        request_for(link_baseline),
+        grants=evidence_plan.grants,
+        writer=writer,
+    )
+    assert result is expected
+    assert seen == [evidence_plan, {"writer": writer, "dry_run": False}]
+    assert writer.invalidations == writer.attempts == 0
diff --git a/tests/discovery_runtime/test_evidence_payloads.py b/tests/discovery_runtime/test_evidence_payloads.py
new file mode 100644
index 0000000000000000000000000000000000000000..5cb36ba8ede51e5352a1a83d3124ca2173ed8576
--- /dev/null
+++ b/tests/discovery_runtime/test_evidence_payloads.py
@@ -0,0 +1,354 @@
+"""Verify evidence bytes, immutable pins and delegated mutation safety boundaries."""
+
+from __future__ import annotations
+
+import json
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery import evidence_linking
+from drm_copilot_discovery.evidence_linking import (
+    EvidencePayload,
+    evidence_changes,
+    plan_evidence_link,
+)
+from drm_copilot_discovery.models import to_plain_value
+from drm_copilot_discovery.mutation_plan import MutationError
+from drm_copilot_discovery.path_models import PathPolicyError
+from drm_copilot_discovery.profile_v2 import ProfileV2
+from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
+from drm_copilot_discovery.snapshot import SnapshotFile
+
+from tests.discovery_runtime.evidence_test_support import CONTENT, request_for
+from tests.discovery_runtime.evidence_test_support import link_baseline as link_baseline
+from tests.discovery_runtime.mutation_test_support import constant, grants_for
+from tests.discovery_runtime.mutation_test_support import (
+    mutation_catalog as mutation_catalog,
+)
+from tests.discovery_runtime.test_evidence_linking import evidence_plan as evidence_plan
+from tests.discovery_runtime.test_references import immutable
+from tests.schemas.discovery.v2_schema_test_support import as_object
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.agent_output import InvocationContext
+    from drm_copilot_discovery.mutation_plan import (
+        CapturedWorkspace,
+        MutationChange,
+        MutationPlan,
+    )
+    from drm_copilot_discovery.path_models import WriteGrant
+
+
+@pytest.mark.parametrize(
+    "path",
+    ["../escape.txt", "C:/outside.txt", "/absolute.txt", "evidence/../escape.txt"],
+)
+def test_payload_paths_reject_escape_without_filesystem_access(path: str) -> None:
+    """Input normalization never turns escaping paths into writable local names."""
+    with pytest.raises(ValueError):
+        EvidencePayload(path=path, content=CONTENT)
+
+
+def test_payload_requires_exact_immutable_bytes() -> None:
+    """Mutable byte buffers cannot change proposed content after authorization."""
+    with pytest.raises(ValueError, match="immutable"):
+        EvidencePayload(path="capture.txt", content=cast("bytes", bytearray(CONTENT)))
+
+
+@pytest.mark.parametrize(
+    "changes",
+    [
+        {"artifact_id": "../bad"},
+        {"expected_sha256": "invalid"},
+        {"expected_sha256": None},
+        {"record": {}},
+        {"payloads": (object(),)},
+        {"link_path": (True,)},
+        {"link_path": (-1,)},
+    ],
+)
+def test_request_contract_rejects_invalid_identity_digest_and_mutable_values(
+    link_baseline: CapturedWorkspace, changes: dict[str, object]
+) -> None:
+    """Malformed selectors fail at construction before graph traversal or I/O."""
+    request = request_for(link_baseline)
+    with pytest.raises(ValueError):
+        replace(request, **changes)
+
+
+def test_request_detaches_caller_sequences(link_baseline: CapturedWorkspace) -> None:
+    """Mutable outer sequences cannot alter a frozen request after construction."""
+    request = request_for(link_baseline)
+    payloads = list(request.payloads)
+    path: list[str | int] = ["trigger", "evidence_refs"]
+    detached = replace(
+        request,
+        payloads=cast("tuple[EvidencePayload, ...]", payloads),
+        link_path=cast("tuple[str | int, ...]", path),
+    )
+    payloads.clear()
+    path.clear()
+    assert detached.payloads == request.payloads and detached.link_path == (
+        "trigger",
+        "evidence_refs",
+    )
+
+
+def test_unrelated_payload_cannot_be_added_to_an_evidence_operation(
+    link_baseline: CapturedWorkspace,
+) -> None:
+    """Exact grants alone cannot smuggle a file not identified by the record."""
+    request = replace(
+        request_for(link_baseline),
+        payloads=(
+            EvidencePayload(
+                path="docs/migration/discovery/evidence/unrelated.txt", content=CONTENT
+            ),
+        ),
+    )
+    with pytest.raises(MutationError) as caught:
+        evidence_changes(link_baseline, request)
+    assert caught.value.code == "EVIDENCE_PAYLOAD"
+
+
+@pytest.mark.parametrize("kind", ["source", "test"])
+def test_source_and_test_records_use_actual_captured_immutable_objects(
+    link_baseline: CapturedWorkspace, kind: str
+) -> None:
+    """A full pin and matching retained Git bytes pass prospective validation."""
+    request = replace(
+        request_for(
+            link_baseline,
+            kind=kind,
+            updates={
+                "path": "src/code.py" if kind == "source" else "tests/test_code.py"
+            },
+        ),
+        payloads=(),
+    )
+    retained = RepositoryFile(
+        repository=RepositoryIdentity(
+            id=link_baseline.snapshot.profile.repository.id, revision="a" * 40
+        ),
+        path=str(request.record["path"]),
+        content=CONTENT,
+    )
+    baseline = replace(
+        link_baseline,
+        snapshot=replace(
+            link_baseline.snapshot,
+            checkout=retained.repository,
+            repository_files=(retained,),
+        ),
+    )
+    changes = evidence_changes(baseline, request)
+    result = plan_evidence_link(baseline, request, grants=grants_for(*changes))
+    assert result.validation.ok and retained in result.prospective.repository_files
+    assert len(result.writes) == 2
+
+
+def test_working_bytes_cannot_replace_missing_pinned_source(
+    link_baseline: CapturedWorkspace,
+) -> None:
+    """Newly supplied local bytes cannot substitute for immutable Git proof."""
+    request = request_for(link_baseline, kind="source")
+    changes = evidence_changes(link_baseline, request)
+    with pytest.raises(MutationError) as caught:
+        plan_evidence_link(link_baseline, request, grants=grants_for(*changes))
+    assert caught.value.code == "MUTATION_INVALID"
+    assert "EVIDENCE_CONTENT_UNAVAILABLE" in {
+        item.code for item in caught.value.findings
+    }
+
+
+@pytest.mark.parametrize("invalid", ["checksum", "second-capture"])
+def test_payload_integrity_uses_both_exact_declared_paths(
+    link_baseline: CapturedWorkspace, invalid: str
+) -> None:
+    """Wrong checksum or a mismatched second runtime path blocks the complete plan."""
+    request = request_for(link_baseline)
+    if invalid == "checksum":
+        request = replace(
+            request, payloads=(replace(request.payloads[0], content=b"changed"),)
+        )
+    else:
+        other = "docs/migration/discovery/evidence/other.txt"
+        document = as_object(to_plain_value(request.record))
+        as_object(document["runtime_artifact"])["path"] = other
+        request = replace(
+            request,
+            record=immutable(document),
+            payloads=(
+                *request.payloads,
+                EvidencePayload(path=other, content=b"different"),
+            ),
+        )
+    changes = evidence_changes(link_baseline, request)
+    with pytest.raises(MutationError) as caught:
+        plan_evidence_link(link_baseline, request, grants=grants_for(*changes))
+    assert caught.value.code == "MUTATION_INVALID"
+    assert "EVIDENCE_CHECKSUM" in {item.code for item in caught.value.findings}
+
+
+def test_uri_description_cannot_be_registered_as_locally_verified_evidence(
+    link_baseline: CapturedWorkspace,
+) -> None:
+    """Structurally allowed descriptive URLs cannot satisfy the local-proof gate."""
+    request = replace(
+        request_for(
+            link_baseline,
+            kind="documentation",
+            updates={
+                "path": None,
+                "uri": "https://example.invalid/proof",
+                "checksum": None,
+            },
+        ),
+        payloads=(),
+    )
+    changes = evidence_changes(link_baseline, request)
+    with pytest.raises(MutationError) as caught:
+        plan_evidence_link(link_baseline, request, grants=grants_for(*changes))
+    assert caught.value.code == "EVIDENCE_UNVERIFIED"
+
+
+@pytest.mark.parametrize(
+    "invalid", ["grant", "digest", "collision", "outside-root", "duplicate-payload"]
+)
+def test_shared_planner_rejects_ungranted_stale_or_colliding_writes(
+    link_baseline: CapturedWorkspace, invalid: str
+) -> None:
+    """The evidence composition cannot bypass accepted kind/path/ID or CAS checks."""
+    request = request_for(link_baseline)
+    changes = evidence_changes(link_baseline, request)
+    grants = grants_for(*changes)
+    if invalid == "grant":
+        grants = (replace(grants[0], artifact_id="wrong"), *grants[1:])
+    elif invalid == "digest":
+        request = replace(request, expected_sha256="0" * 64)
+    elif invalid == "collision":
+        # Create-only registration cannot replace a pre-existing opaque file.
+        link_baseline = replace(
+            link_baseline,
+            snapshot=replace(
+                link_baseline.snapshot,
+                manifest=replace(
+                    link_baseline.snapshot.manifest,
+                    files=(
+                        *link_baseline.snapshot.manifest.files,
+                        evidence_plan_file(request.payloads[0]),
+                    ),
+                ),
+            ),
+        )
+    elif invalid == "outside-root":
+        path = "docs/outside.txt"
+        document = as_object(to_plain_value(request.record))
+        document["path"] = path
+        as_object(document["runtime_artifact"])["path"] = path
+        request = replace(
+            request,
+            record=immutable(document),
+            payloads=(EvidencePayload(path=path, content=CONTENT),),
+        )
+        grants = grants_for(*evidence_changes(link_baseline, request))
+    else:
+        request = replace(request, payloads=request.payloads * 2)
+    with pytest.raises((MutationError, PathPolicyError)) as caught:
+        plan_evidence_link(link_baseline, request, grants=grants)
+    assert (
+        caught.value.code
+        == {
+            "grant": "MUTATION_GRANT",
+            "digest": "MUTATION_PRECONDITION",
+            "collision": "MUTATION_PRECONDITION",
+            "outside-root": "PATH_WRITE_DENIED",
+            "duplicate-payload": "PATH_COLLISION",
+        }[invalid]
+    )
+
+
+def evidence_plan_file(payload: EvidencePayload) -> SnapshotFile:
+    """Build one captured opaque payload for a precondition-only test."""
+    return SnapshotFile(path=payload.path, content=payload.content, category="evidence")
+
+
+def test_custom_root_controls_record_and_supplied_payload_locations(
+    link_baseline: CapturedWorkspace,
+) -> None:
+    """Projection uses accepted profile data rather than a hard-coded discovery path."""
+    document = as_object(to_plain_value(link_baseline.snapshot.profile.document))
+    as_object(document["artifacts"])["evidence"] = "work/proofs"
+    document["evidence_roots"] = ["work/proofs"]
+    profile = ProfileV2(
+        json.dumps(document), format="json", catalog=link_baseline.snapshot.catalog
+    )
+    baseline = replace(
+        link_baseline, snapshot=replace(link_baseline.snapshot, profile=profile)
+    )
+    changes = evidence_changes(baseline, request_for(baseline))
+    assert changes[0].path == "work/proofs/proof.json"
+    assert changes[2].path == "work/proofs/capture.txt"
+
+
+def test_planner_forwards_native_context_and_exact_grants_without_creation(
+    link_baseline: CapturedWorkspace,
+    evidence_plan: MutationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """The thin boundary cannot derive or replace invocation identity and grants."""
+    context = cast("InvocationContext", object())
+    seen: list[object] = []
+
+    def planned(
+        baseline: CapturedWorkspace,
+        changes: tuple[MutationChange, ...],
+        *,
+        grants: tuple[WriteGrant, ...],
+        invocation: InvocationContext | None,
+    ) -> MutationPlan:
+        """Record composition arguments without rerunning unchanged graph semantics."""
+        seen.extend((baseline, changes, grants, invocation))
+        return evidence_plan
+
+    monkeypatch.setattr(evidence_linking, "plan_mutation", planned)
+    request = request_for(link_baseline)
+    result = plan_evidence_link(
+        link_baseline, request, grants=evidence_plan.grants, invocation=context
+    )
+    assert result is evidence_plan
+    assert seen == [
+        link_baseline,
+        evidence_changes(link_baseline, request),
+        evidence_plan.grants,
+        context,
+    ]
+
+
+def test_unverified_assessment_cannot_be_hidden_by_an_injected_plan(
+    link_baseline: CapturedWorkspace,
+    evidence_plan: MutationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """Evidence eligibility remains explicit even after a successful planner result."""
+    request = request_for(link_baseline)
+    prospective = replace(
+        evidence_plan.prospective,
+        manifest=replace(
+            evidence_plan.prospective.manifest,
+            files=tuple(
+                file
+                for file in evidence_plan.prospective.manifest.files
+                if file.path != request.payloads[0].path
+            ),
+        ),
+    )
+    monkeypatch.setattr(
+        evidence_linking,
+        "plan_mutation",
+        constant(replace(evidence_plan, prospective=prospective)),
+    )
+    with pytest.raises(MutationError) as caught:
+        plan_evidence_link(link_baseline, request, grants=evidence_plan.grants)
+    assert caught.value.code == "EVIDENCE_UNVERIFIED" and caught.value.findings
```
