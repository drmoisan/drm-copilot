# P3-T6 scoped review diff

Timestamp: 2026-10-18T18:14:22.553384+00:00
Command: Python difflib.unified_diff n=0
EXIT_CODE: 0
Output Summary: Nine authorized task paths against the original accepted baseline.

Baseline: 27753e5f8b9a6cd1d85b9d1d28d2999800af209a. UTF-8 zero-context text preserves complete change hunks; exact raw SHA-256 and normalized Git blob identities are recorded in the inventory.

```diff
--- a/packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py
@@ -29,0 +30 @@
+    from drm_copilot_discovery.transport_manifest import TransportRoute
@@ -158,0 +160 @@
+        transport: TransportRoute | None = None,
@@ -165,0 +168 @@
+        self._transport = transport
@@ -433 +436 @@
-        if location is None:
+        if location is None and self._transport is None:
@@ -439,2 +442,10 @@
-        root = self._locations[location]
-        allowed = path == root if location in FILE_KEYS else path.startswith(root + "/")
+        if self._transport is not None:
+            # Only the root-owned mutation route supplies a reconstructed transport.
+            allowed = self._transport.allows(
+                grant, root=self._locations["source_snapshots"]
+            )
+        else:
+            root = self._locations[cast("ArtifactKey", location)]
+            allowed = (
+                path == root if location in FILE_KEYS else path.startswith(root + "/")
+            )
--- a/packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py
@@ -36,0 +37 @@
+    from drm_copilot_discovery.transport_manifest import TransportRoute
@@ -134,0 +136 @@
+    transport: TransportRoute | None = None
@@ -150,0 +153 @@
+    transport: TransportRoute | None = None
@@ -274,0 +278 @@
+    transport: TransportRoute | None = None,
@@ -285,0 +290,26 @@
+    if transport is not None:
+        if invocation is not None:
+            raise MutationError(
+                "MUTATION_TRANSPORT", "Transport is a root-only operation"
+            )
+        transport.revalidate(
+            catalog=baseline.snapshot.catalog,
+            limits=baseline.snapshot.profile.limits.parse_limits(),
+        )
+        members = {member.grant for member in transport.members}
+        if (
+            set(grants) != members
+            or len(grants) != len(members)
+            or {item.path for item in changes} != {grant.path for grant in members}
+        ):
+            raise MutationError(
+                "MUTATION_TRANSPORT",
+                "Require the exact complete transport grants and members",
+            )
+        # The header is published only after every complete immutable member exists.
+        changes = tuple(
+            sorted(
+                changes,
+                key=lambda item: (item.path == transport.manifest.path, item.path),
+            )
+        )
@@ -299,0 +330 @@
+        transport=transport,
@@ -316,0 +348,6 @@
+        if transport is not None:
+            transport.check(grant, change.content)
+            if prior is not None and prior.content != change.content:
+                raise MutationError(
+                    "MUTATION_TRANSPORT", "Immutable snapshot bytes cannot be replaced"
+                )
@@ -324,0 +362 @@
+            and transport is None
@@ -339,0 +378 @@
+                transport=transport,
@@ -385,0 +425 @@
+        transport=transport,
--- a/packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py
@@ -159,0 +160,8 @@
+            if write.transport is not None:
+                write.transport.revalidate(
+                    catalog=current.snapshot.catalog,
+                    limits=current.snapshot.profile.limits.parse_limits(),
+                )
+                write.transport.check(
+                    cast("WriteGrant", write.target.grant), write.change.content
+                )
@@ -163,0 +172 @@
+                transport=write.transport,
@@ -176,0 +186,4 @@
+            if write.transport is not None and prior is not None:
+                raise MutationError(
+                    "MUTATION_TRANSPORT", "Transport publication requires absence"
+                )
@@ -275,0 +289 @@
+        transport=write.transport,
@@ -293,0 +308 @@
+        transport=plan.transport,
@@ -339,0 +355 @@
+                transport=write.transport,
@@ -346 +362,4 @@
-                change=write.change, target=target, skipped=False
+                change=write.change,
+                target=target,
+                skipped=False,
+                transport=write.transport,
--- a/packages/discovery-runtime/src/drm_copilot_discovery/references.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/references.py
@@ -22,0 +23 @@
+from drm_copilot_discovery.transport_manifest import replica_aliases
@@ -98,0 +100 @@
+    replicas: tuple[tuple[str, ArtifactRecord], ...] = ()
@@ -117,0 +120 @@
+        object.__setattr__(self, "replicas", tuple(self.replicas))
@@ -171,0 +175,4 @@
+        if len(candidates) == 1 and (source_contract or transport):
+            candidates = self._replica_targets(
+                candidates[0], source=source, transport=transport
+            )
@@ -214,0 +222,24 @@
+
+    def _replica_targets(
+        self, target: ArtifactRecord, *, source: ArtifactRecord, transport: bool
+    ) -> tuple[ArtifactRecord, ...]:
+        """Select physical imported bytes only within a proven equivalence group.
+
+        Ordinary candidates retain local mutation identity. Manifest rows select
+        their own physical member; source links use a deterministic proven copy.
+        Different bytes, pins or unbound duplicates never enter this group.
+        """
+        copies = tuple(
+            record
+            for representative, record in self.replicas
+            if representative == target.artifact.path
+            and record.pointer == target.pointer
+        )
+        if target.artifact.origin_path is not None:
+            copies = (*copies, target)
+        if not copies:
+            return (target,)
+        if transport and source.kind == "source-snapshot-manifest":
+            path = source.artifact.path.rsplit("/", 1)[0] + "/" + target.path
+            return tuple(record for record in copies if record.artifact.path == path)
+        return (min(copies, key=lambda record: record.artifact.path),)
@@ -337,0 +369 @@
+    aliases = replica_aliases(snapshot)
@@ -340,0 +373 @@
+        if artifact.path not in aliases
@@ -343 +376,7 @@
-    index = ReferenceIndex(records=records)
+    replicas = tuple(
+        (aliases[artifact.path], record)
+        for artifact in snapshot.artifacts
+        if artifact.path in aliases
+        for record in _records(artifact, collector)
+    )
+    index = ReferenceIndex(records=records, replicas=replicas)
@@ -347,2 +386,3 @@
-    # Collection members are walked individually to retain their own source identity.
-    for record in records:
+    # Physical replicas need outgoing links for later path-keyed provenance checks.
+    # Their common links retain canonical targets and existing evidence assessments.
+    for record in records + tuple(record for _, record in replicas):
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py
@@ -0,0 +1,271 @@
+"""Bind immutable local transport bytes without granting native write authority.
+
+The existing parser/catalog validate the envelope. This component adds only the
+transport digest, exact member set and replica provenance contract. It performs
+no I/O; every physical input remains in the caller's complete snapshot.
+"""
+
+from __future__ import annotations
+
+from collections import defaultdict
+from dataclasses import dataclass
+from hashlib import sha256
+from typing import TYPE_CHECKING, cast
+
+from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
+from drm_copilot_discovery.path_models import WriteGrant, check_path_collisions
+from drm_copilot_discovery.repository_reader import RepositoryIdentity, full_revision
+from drm_copilot_discovery.schema_validation import validate_document
+from drm_copilot_discovery.snapshot import SnapshotFile
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot
+
+
+def transport_digest(document: JsonObject) -> str:
+    """Hash canonical UTF-8/LF content excluding only digest and importer fields.
+
+    Export time, author, tool, source pin and all member declarations remain bound.
+    The three verification fields describe a later local check, never authority.
+    """
+    transport = cast("JsonObject", document["transport"])
+    payload = JsonObject(
+        tuple(
+            (key, value)
+            for key, value in transport.items()
+            if key not in {"verification_status", "verified_at", "verified_by"}
+        )
+    )
+    value = JsonObject(
+        tuple(
+            (key, payload if key == "transport" else child)
+            for key, child in document.items()
+            if key != "manifest_sha256"
+        )
+    )
+    return sha256(canonical_json(value)).hexdigest()
+
+
+@dataclass(frozen=True, kw_only=True)
+class TransportMember:
+    """Bind an exact physical output to an original path and immutable byte digest."""
+
+    grant: WriteGrant
+    origin: str | None
+    sha256: str
+    size: int
+
+
+@dataclass(frozen=True, kw_only=True)
+class TransportRoute:
+    """Retain a checked manifest and its complete output set, including the header.
+
+    Construct through bind_transport. Plans and guarded writers reconstruct this
+    value from its raw header before using it; caller-created values are not proof.
+    """
+
+    manifest: SnapshotFile
+    document: JsonObject
+    source: RepositoryIdentity
+    members: tuple[TransportMember, ...]
+
+    def allows(self, grant: WriteGrant, *, root: str) -> bool:
+        """Match one exact member beneath the configured transport root, purely."""
+        return (
+            self.manifest.path.startswith(root + "/")
+            and self.manifest.path != root + "/manifest.json"
+            and any(member.grant == grant for member in self.members)
+        )
+
+    def check(self, grant: WriteGrant, content: bytes) -> None:
+        """Reject a substituted member identity or byte sequence with ValueError."""
+        member = next((item for item in self.members if item.grant == grant), None)
+        if member is None or (
+            member.size != len(content) or member.sha256 != sha256(content).hexdigest()
+        ):
+            raise ValueError("Transport member identity, size or checksum differs")
+
+    def check_files(self, files: tuple[SnapshotFile, ...]) -> None:
+        """Require every declared member exactly once; never accept an extra file."""
+        check_path_collisions(file.path for file in files)
+        by_path = {file.path: file.content for file in files}
+        if set(by_path) != {member.grant.path for member in self.members}:
+            raise ValueError("Transport requires its exact complete declared file set")
+        for member in self.members:
+            self.check(member.grant, by_path[member.grant.path])
+
+    def revalidate(self, *, catalog: SchemaCatalog, limits: ParseLimits) -> None:
+        """Reconstruct all fields from raw bytes; reject forged or stale route data."""
+        if self != bind_transport(
+            self.manifest.path, self.manifest.content, catalog=catalog, limits=limits
+        ):
+            raise ValueError("Transport route differs from its original manifest")
+
+
+def bind_transport(
+    path: str, content: bytes, *, catalog: SchemaCatalog, limits: ParseLimits
+) -> TransportRoute:
+    """Validate one local manifest and derive its exact immutable member route.
+
+    Raises ValueError for unsupported/malformed envelopes, mutable bytes, non-full
+    pins, digest/count/identity/path conflicts, or finite-limit violations. This
+    verifies declarations only; check_files and the complete loader verify bytes.
+    """
+    manifest = SnapshotFile(path=path, content=content, category="source-snapshot")
+    if not path.endswith("/manifest.json"):
+        raise ValueError("A transport requires a child manifest.json path")
+    result = validate_document(
+        content,
+        expected_kind="source-snapshot-manifest",
+        expected_version="2.0.0",
+        artifact_path=path,
+        catalog=catalog,
+        limits=limits,
+    )
+    if not result.ok or result.document is None:
+        raise ValueError(
+            "Transport manifest is malformed or uses an unsupported schema"
+        )
+    document = result.document
+    owner = cast("JsonObject", document["source_repository"])
+    revision = owner["revision"]
+    if not isinstance(revision, str):
+        raise ValueError("Transport requires a full immutable source revision")
+    source = RepositoryIdentity(
+        id=cast("str", owner["id"]), revision=full_revision(revision)
+    )
+    if transport_digest(document) != document["manifest_sha256"]:
+        raise ValueError("Transport manifest checksum differs")
+    artifacts = cast("tuple[JsonObject, ...]", document["artifacts"])
+    payloads = cast("tuple[JsonObject, ...]", document["payloads"])
+    transport = cast("JsonObject", document["transport"])
+    if (transport["artifact_count"], transport["payload_count"]) != (
+        len(artifacts),
+        len(payloads),
+    ):
+        raise ValueError("Transport member counts differ")
+    if len(artifacts) + len(payloads) + 1 > limits.artifact_records:
+        raise ValueError("Transport member count exceeds the configured limit")
+    identities = [(row["artifact_kind"], row["id"]) for row in artifacts]
+    if len(set(identities)) != len(identities):
+        raise ValueError("Transport contains duplicate artifact identities")
+    parent = path.rsplit("/", 1)[0]
+    members: list[TransportMember] = []
+    for row in artifacts + payloads:
+        origin = cast("str", row["path"])
+        if origin.split("/")[-1] == "manifest.json":
+            raise ValueError("A transport member cannot introduce another manifest")
+        size = cast("int", row["size"])
+        if size > limits.document_bytes:
+            raise ValueError("Transport member exceeds the configured byte limit")
+        members.append(
+            TransportMember(
+                grant=WriteGrant(
+                    artifact_kind=cast(
+                        "str", row.get("artifact_kind", "evidence-payload")
+                    ),
+                    artifact_id=cast(
+                        "str",
+                        row.get("id", "payload-" + sha256(origin.encode()).hexdigest()),
+                    ),
+                    path=parent + "/" + origin,
+                ),
+                origin=origin,
+                sha256=cast("str", row["sha256"]),
+                size=size,
+            )
+        )
+    members.append(
+        TransportMember(
+            grant=WriteGrant(
+                artifact_kind="source-snapshot-manifest",
+                artifact_id=cast("str", document["id"]),
+                path=path,
+            ),
+            origin=None,
+            sha256=manifest.sha256,
+            size=len(content),
+        )
+    )
+    paths = set(check_path_collisions(member.grant.path for member in members))
+    if any(
+        "/".join(path.split("/")[:length]) in paths
+        for path in paths
+        for length in range(1, len(path.split("/")))
+    ):
+        raise ValueError("Transport file and directory paths collide")
+    return TransportRoute(
+        manifest=manifest, document=document, source=source, members=tuple(members)
+    )
+
+
+def replica_aliases(snapshot: DiscoverySnapshot) -> dict[str, str]:
+    """Coalesce proven replicas while retaining the sole ordinary local identity.
+
+    Invalid or incomplete manifests grant no equivalence. Ordinary duplicates and
+    unbound imported copies remain visible to the existing duplicate validator.
+    All physical files, manifests and loader findings remain untouched.
+    """
+    bound: set[str] = set()
+    artifacts = {item.path: item for item in snapshot.artifacts}
+    root = snapshot.profile.artifacts["source_snapshots"]
+    for header in snapshot.artifacts:
+        if (
+            header.expected_kind != "source-snapshot-manifest"
+            or not header.path.startswith(root + "/")
+        ):
+            continue
+        try:
+            route = bind_transport(
+                header.path,
+                snapshot.file(header.path).content,
+                catalog=snapshot.catalog,
+                limits=snapshot.profile.limits.parse_limits(),
+            )
+            route.check_files(
+                tuple(snapshot.file(item.grant.path) for item in route.members)
+            )
+        except (KeyError, ValueError):
+            # Failure preserves ordinary duplicate rejection; it grants no exemption.
+            continue
+        for member in route.members:
+            artifact = artifacts.get(member.grant.path)
+            if (
+                artifact is not None
+                and member.origin is not None
+                and artifact.origin_path == member.origin
+                and artifact.repository == route.source
+                and artifact.expected_kind == member.grant.artifact_kind
+                and artifact.document is not None
+                and artifact.document.get("id") == member.grant.artifact_id
+            ):
+                bound.add(artifact.path)
+    groups: dict[
+        tuple[RepositoryIdentity, str, str, str, bytes], list[ArtifactSnapshot]
+    ] = defaultdict(list)
+    for artifact in snapshot.artifacts:
+        if artifact.document is None or artifact.repository.revision is None:
+            continue
+        if artifact.origin_path is not None and artifact.path not in bound:
+            continue
+        key = (
+            artifact.repository,
+            artifact.origin_path or artifact.path,
+            artifact.expected_kind,
+            str(artifact.document.get("id")),
+            snapshot.file(artifact.path).content,
+        )
+        groups[key].append(artifact)
+    aliases: dict[str, str] = {}
+    for copies in groups.values():
+        imported = sorted(item.path for item in copies if item.path in bound)
+        local = [item.path for item in copies if item.origin_path is None]
+        if imported and len(local) <= 1:
+            representative = local[0] if local else imported[0]
+            aliases.update(
+                (item.path, representative)
+                for item in copies
+                if item.path != representative
+            )
+    return aliases
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py
@@ -0,0 +1,437 @@
+"""Compose immutable local source transport with the shared mutation boundary.
+
+All source bytes come from the supplied complete capture. No function discovers
+sibling repositories, fetches revisions or grants native access. Export/import
+validate declarations and exact bytes; they never change claim or approval state.
+"""
+
+from __future__ import annotations
+
+from dataclasses import dataclass
+from hashlib import sha256
+from typing import TYPE_CHECKING, cast
+
+from drm_copilot_discovery.evidence_rules import assess_evidence
+from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
+from drm_copilot_discovery.mutation_io import commit_mutation
+from drm_copilot_discovery.mutation_plan import (
+    MutationChange,
+    MutationError,
+    plan_mutation,
+)
+from drm_copilot_discovery.path_policy import PathPolicy
+from drm_copilot_discovery.references import index_references
+from drm_copilot_discovery.repository_reader import RepositoryIdentity, full_revision
+from drm_copilot_discovery.revision_rules import RevisionInputs
+from drm_copilot_discovery.snapshot import repository_pins
+from drm_copilot_discovery.transport_manifest import bind_transport, transport_digest
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.agent_output import InvocationContext
+    from drm_copilot_discovery.mutation_io import MutationResult, MutationWriter
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
+    from drm_copilot_discovery.path_models import WriteGrant
+    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
+    from drm_copilot_discovery.transport_manifest import TransportRoute
+
+
+@dataclass(frozen=True, kw_only=True)
+class SnapshotExport:
+    """Select source artifacts and explicit export attribution, without authority."""
+
+    export_id: str
+    artifacts: tuple[tuple[str, str], ...]
+    exported_at: str
+    exported_by: JsonObject
+
+
+@dataclass(frozen=True, kw_only=True)
+class SnapshotImport:
+    """Select an already captured local bundle and its expected configured source."""
+
+    manifest_path: str
+    source: RepositoryIdentity
+    verified_at: str
+    verified_by: JsonObject
+
+
+@dataclass(frozen=True, kw_only=True)
+class SnapshotProposal:
+    """Bind a complete immutable transport proposal, not a validated write grant."""
+
+    route: TransportRoute
+    changes: tuple[MutationChange, ...]
+
+
+def _closure(
+    baseline: CapturedWorkspace, selections: tuple[tuple[str, str], ...]
+) -> tuple[ReferenceIndex, tuple[ArtifactRecord, ...]]:
+    """Include whole immutable containers and their transitive local dependencies."""
+    if not selections or len(set(selections)) != len(selections):
+        raise MutationError("SNAPSHOT_SELECTION", "Select distinct nonempty artifacts")
+    index = index_references(baseline.snapshot)
+    pending: list[ArtifactRecord] = []
+    for kind, identifier in selections:
+        matches = index.candidates(
+            kind, identifier, repository=baseline.snapshot.profile.repository.id
+        )
+        if len(matches) != 1:
+            raise MutationError(
+                "SNAPSHOT_SELECTION", "Select one captured source artifact"
+            )
+        pending.append(matches[0])
+    selected: dict[str, ArtifactRecord] = {}
+    while pending:
+        record = pending.pop()
+        artifact = record.artifact
+        if artifact.path in selected:
+            continue
+        if (
+            artifact.origin_path is not None
+            or artifact.repository.id != baseline.snapshot.profile.repository.id
+        ):
+            raise MutationError(
+                "SNAPSHOT_SOURCE", "Export only this repository's local artifacts"
+            )
+        findings = tuple(
+            item
+            for item in baseline.snapshot.findings
+            if item.artifact_path == artifact.path
+        )
+        if findings:
+            raise MutationError(
+                "SNAPSHOT_INPUT",
+                "Selected source artifact is malformed",
+                findings=findings,
+            )
+        # A collection is copied intact, so every member's links join the closure.
+        selected[artifact.path] = next(
+            item
+            for item in index.records
+            if item.artifact.path == artifact.path and not item.pointer
+        )
+        for link in index.links:
+            if link.source.artifact.path == artifact.path:
+                if link.target is None:
+                    raise MutationError(
+                        "SNAPSHOT_REFERENCE",
+                        "Source dependency is unresolved",
+                        findings=link.findings,
+                    )
+                pending.append(link.target)
+    return index, tuple(selected[path] for path in sorted(selected))
+
+
+def _payloads(
+    baseline: CapturedWorkspace, index: ReferenceIndex, paths: set[str]
+) -> dict[str, bytes]:
+    """Require locally verified evidence and retain exact captured payload bytes."""
+    inputs = RevisionInputs(baseline.snapshot)
+    payloads: dict[str, bytes] = {}
+    for record in index.records:
+        if record.artifact.path not in paths or record.kind != "evidence-reference":
+            continue
+        assessment = assess_evidence(inputs, record)
+        if not assessment.locally_verified:
+            raise MutationError(
+                "SNAPSHOT_EVIDENCE",
+                "Export requires locally verified evidence",
+                findings=assessment.findings,
+            )
+        document = record.document
+        locations = {cast("str", document["path"])}
+        runtime = document.get("runtime_artifact")
+        if isinstance(runtime, JsonObject):
+            locations.add(cast("str", runtime["path"]))
+        for path in sorted(locations):
+            content = inputs.content(
+                record,
+                repository=cast("str", document["repository"]),
+                revision=cast("str | None", document.get("revision")),
+                path=path,
+                immutable=document.get("evidence_type") in {"source", "test"},
+            )
+            if content is None or (path in payloads and payloads[path] != content):
+                raise MutationError(
+                    "SNAPSHOT_PAYLOAD",
+                    "Captured payload bytes are missing or conflicting",
+                )
+            payloads[path] = content
+    return payloads
+
+
+def _proposal(
+    baseline: CapturedWorkspace, route: TransportRoute, contents: dict[str, bytes]
+) -> SnapshotProposal:
+    """Allow only new outputs or byte-identical repeats, retaining original CAS."""
+    files = {item.path: item for item in baseline.snapshot.manifest.files}
+    changes: list[MutationChange] = []
+    for member in route.members:
+        content = (
+            route.manifest.content if member.origin is None else contents[member.origin]
+        )
+        route.check(member.grant, content)
+        prior = files.get(member.grant.path)
+        if prior is not None and prior.content != content:
+            raise MutationError(
+                "SNAPSHOT_CONFLICT", "Immutable destination bytes already differ"
+            )
+        changes.append(
+            MutationChange(
+                artifact_kind=member.grant.artifact_kind,
+                artifact_id=member.grant.artifact_id,
+                path=member.grant.path,
+                content=content,
+                expected_sha256=prior.sha256 if prior else None,
+            )
+        )
+    return SnapshotProposal(route=route, changes=tuple(changes))
+
+
+def prepare_snapshot_export(
+    baseline: CapturedWorkspace, request: SnapshotExport
+) -> SnapshotProposal:
+    """Project a deterministic source export and complete local dependency closure.
+
+    Source/test evidence requires accepted captured Git objects. Artifact and
+    payload bytes are copied unchanged. Complete prospective graph validation is
+    performed by plan_snapshot_export; this pure projection performs no writes.
+    """
+    snapshot = baseline.snapshot
+    if snapshot.profile.system.role not in {"legacy-source", "combined"}:
+        raise MutationError("SNAPSHOT_ROLE", "Only a configured source role can export")
+    revision = full_revision(snapshot.profile.repository.revision or "")
+    index, records = _closure(baseline, request.artifacts)
+    contents = _payloads(baseline, index, {item.artifact.path for item in records})
+    payload_rows = tuple(
+        JsonObject(
+            (
+                ("path", path),
+                ("sha256", sha256(content).hexdigest()),
+                ("size", len(content)),
+            )
+        )
+        for path, content in sorted(contents.items())
+    )
+    rows: list[JsonObject] = []
+    for record in records:
+        file = snapshot.file(record.artifact.path)
+        if file.path in contents:
+            raise MutationError(
+                "SNAPSHOT_PAYLOAD", "One path cannot be artifact and payload"
+            )
+        contents[file.path] = file.content
+        rows.append(
+            JsonObject(
+                (
+                    ("artifact_kind", record.kind),
+                    ("id", record.id),
+                    ("schema_version", "2.0.0"),
+                    ("path", file.path),
+                    ("sha256", file.sha256),
+                    ("size", len(file.content)),
+                )
+            )
+        )
+    fields: dict[str, JsonValue] = {
+        "$schema": "urn:drm-copilot:discovery:2.0.0:source-snapshot-manifest",
+        "schema_version": "2.0.0",
+        "artifact_kind": "source-snapshot-manifest",
+        "id": request.export_id,
+        "source_repository": JsonObject(
+            (("id", snapshot.profile.repository.id), ("revision", revision))
+        ),
+        "schema_versions": ("2.0.0",),
+        "tool": JsonObject((("id", "drm-copilot-discovery"), ("version", "2.0.0"))),
+        "artifacts": tuple(rows),
+        "payloads": payload_rows,
+        "transport": JsonObject(
+            (
+                ("method", "local-files"),
+                ("exported_at", request.exported_at),
+                ("exported_by", request.exported_by),
+                ("verification_status", "pending"),
+                ("verified_at", None),
+                ("verified_by", None),
+                ("artifact_count", len(rows)),
+                ("payload_count", len(payload_rows)),
+            )
+        ),
+        "extensions": JsonObject(()),
+    }
+    fields["manifest_sha256"] = transport_digest(JsonObject(tuple(fields.items())))
+    route = bind_transport(
+        snapshot.profile.artifacts["source_snapshots"]
+        + "/"
+        + request.export_id
+        + "/manifest.json",
+        canonical_json(JsonObject(tuple(fields.items()))),
+        catalog=snapshot.catalog,
+        limits=snapshot.profile.limits.parse_limits(),
+    )
+    return _proposal(baseline, route, contents)
+
+
+def _captured_transport(baseline: CapturedWorkspace, path: str) -> TransportRoute:
+    """Bind one complete local bundle from captured files, with no fresh reads."""
+    snapshot = baseline.snapshot
+    PathPolicy(
+        snapshot.profile,
+        workspace_root=baseline.workspace_root,
+        metadata=baseline.inspect,
+    ).resolve_read(path)
+    route = bind_transport(
+        path,
+        snapshot.file(path).content,
+        catalog=snapshot.catalog,
+        limits=snapshot.profile.limits.parse_limits(),
+    )
+    parent = path.rsplit("/", 1)[0] + "/"
+    route.check_files(
+        tuple(item for item in snapshot.manifest.files if item.path.startswith(parent))
+    )
+    return route
+
+
+def prepare_snapshot_import(
+    baseline: CapturedWorkspace, request: SnapshotImport
+) -> SnapshotProposal:
+    """Verify an already captured local transport against configured source pins.
+
+    Inputs may be staged in a configured readable documentation directory. They
+    remain in complete-input freshness checks. Identical existing manifests keep
+    their original attribution; different identities or bytes never overwrite.
+    """
+    snapshot = baseline.snapshot
+    if snapshot.profile.system.role not in {"modernization-target", "combined"}:
+        raise MutationError("SNAPSHOT_ROLE", "Only a target role can import")
+    incoming = _captured_transport(baseline, request.manifest_path)
+    sources, _ = repository_pins(snapshot.profile)
+    if request.source != incoming.source or incoming.source not in sources:
+        raise MutationError(
+            "SNAPSHOT_SOURCE", "Transport does not match a configured immutable source"
+        )
+    root = snapshot.profile.artifacts["source_snapshots"]
+    path = root + "/" + cast("str", incoming.source.revision) + "/manifest.json"
+    configured = next(
+        (
+            item.snapshot_manifest
+            for item in snapshot.profile.repositories
+            if item.id == incoming.source.id and item.snapshot_manifest is not None
+        ),
+        None,
+    )
+    path = configured or path
+    # Reuse one already imported/exported identical identity, including combined repos.
+    existing = tuple(
+        item
+        for item in snapshot.artifacts
+        if item.expected_kind == "source-snapshot-manifest"
+        and item.document is not None
+        and item.document.get("id") == incoming.document["id"]
+    )
+    if len(existing) > 1:
+        raise MutationError("SNAPSHOT_CONFLICT", "Transport identity is duplicated")
+    contents = {
+        item.origin: snapshot.file(item.grant.path).content
+        for item in incoming.members
+        if item.origin is not None
+    }
+    if existing:
+        retained = _captured_transport(baseline, existing[0].path)
+        if (
+            retained.source != incoming.source
+            or transport_digest(retained.document)
+            != transport_digest(incoming.document)
+            or configured is not None
+            and retained.manifest.path != configured
+        ):
+            raise MutationError(
+                "SNAPSHOT_CONFLICT", "Existing transport identity differs"
+            )
+        return _proposal(baseline, retained, contents)
+    transport = dict(cast("JsonObject", incoming.document["transport"]))
+    transport.update(
+        verification_status="verified",
+        verified_at=request.verified_at,
+        verified_by=request.verified_by,
+    )
+    document = dict(incoming.document)
+    document["transport"] = JsonObject(tuple(transport.items()))
+    route = bind_transport(
+        path,
+        canonical_json(JsonObject(tuple(document.items()))),
+        catalog=snapshot.catalog,
+        limits=snapshot.profile.limits.parse_limits(),
+    )
+    return _proposal(baseline, route, contents)
+
+
+def plan_snapshot_export(
+    baseline: CapturedWorkspace,
+    request: SnapshotExport,
+    *,
+    grants: tuple[WriteGrant, ...],
+    invocation: InvocationContext | None = None,
+) -> MutationPlan:
+    """Validate the export graph with exact external grants and root context."""
+    proposal = prepare_snapshot_export(baseline, request)
+    return plan_mutation(
+        baseline,
+        proposal.changes,
+        grants=grants,
+        invocation=invocation,
+        transport=proposal.route,
+    )
+
+
+def plan_snapshot_import(
+    baseline: CapturedWorkspace,
+    request: SnapshotImport,
+    *,
+    grants: tuple[WriteGrant, ...],
+    invocation: InvocationContext | None = None,
+) -> MutationPlan:
+    """Validate the complete imported graph; supplied status never grants trust."""
+    proposal = prepare_snapshot_import(baseline, request)
+    return plan_mutation(
+        baseline,
+        proposal.changes,
+        grants=grants,
+        invocation=invocation,
+        transport=proposal.route,
+    )
+
+
+def export_snapshot(
+    baseline: CapturedWorkspace,
+    request: SnapshotExport,
+    *,
+    grants: tuple[WriteGrant, ...],
+    writer: MutationWriter,
+    dry_run: bool = False,
+    invocation: InvocationContext | None = None,
+) -> MutationResult:
+    """Commit or dry-run through the existing writer, preserving partial outcomes."""
+    return commit_mutation(
+        plan_snapshot_export(baseline, request, grants=grants, invocation=invocation),
+        writer=writer,
+        dry_run=dry_run,
+    )
+
+
+def import_snapshot(
+    baseline: CapturedWorkspace,
+    request: SnapshotImport,
+    *,
+    grants: tuple[WriteGrant, ...],
+    writer: MutationWriter,
+    dry_run: bool = False,
+    invocation: InvocationContext | None = None,
+) -> MutationResult:
+    """Publish only verified matching local bytes without replacement or fetching."""
+    return commit_mutation(
+        plan_snapshot_import(baseline, request, grants=grants, invocation=invocation),
+        writer=writer,
+        dry_run=dry_run,
+    )
--- /dev/null
+++ b/tests/discovery_runtime/test_snapshot_export.py
@@ -0,0 +1,475 @@
+"""Verify exact transport manifests, immutable export routes and replica identity."""
+
+from __future__ import annotations
+
+import json
+from dataclasses import replace
+from hashlib import sha256
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.claim_rules import ClaimContext
+from drm_copilot_discovery.evidence_linking import evidence_changes
+from drm_copilot_discovery.evidence_rules import EvidenceValidation
+from drm_copilot_discovery.models import ParseLimits, canonical_json
+from drm_copilot_discovery.mutation_plan import (
+    MutationError,
+    plan_mutation,
+)
+from drm_copilot_discovery.path_models import PathPolicyError
+from drm_copilot_discovery.path_policy import PathPolicy
+from drm_copilot_discovery.references import index_references
+from drm_copilot_discovery.snapshot import SnapshotFile
+from drm_copilot_discovery.source_snapshots import prepare_snapshot_export
+from drm_copilot_discovery.transport_manifest import (
+    bind_transport,
+    replica_aliases,
+    transport_digest,
+)
+
+from tests.discovery_runtime.evidence_test_support import request_for
+from tests.discovery_runtime.mutation_test_support import capture, grants_for
+from tests.discovery_runtime.mutation_test_support import (
+    mutation_catalog as mutation_catalog,
+)
+from tests.discovery_runtime.source_snapshot_test_support import (
+    changed_header,
+    evidence_capture,
+    export_fault,
+    export_request,
+    transport_case,
+    unit_transport,
+    with_files,
+)
+from tests.discovery_runtime.source_snapshot_test_support import (
+    source_capture as source_capture,
+)
+from tests.discovery_runtime.test_references import immutable
+from tests.schemas.discovery.v2_schema_test_support import as_object
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+
+
+def test_manifest_binds_exact_bytes_and_excludes_only_importer_verification(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Authored success flags cannot replace raw digest/member validation."""
+    route = unit_transport(mutation_catalog)
+    route.check_files(
+        tuple(
+            SnapshotFile(
+                path=item.grant.path,
+                content=route.manifest.content if item.origin is None else b"{}",
+                category="artifact",
+            )
+            for item in route.members
+        )
+    )
+    transport = as_object(json.loads(route.manifest.content))["transport"]
+    as_object(transport).update(
+        verification_status="verified",
+        verified_at="2026-01-01T00:00:00Z",
+        verified_by={"kind": "human", "id": "reviewer"},
+    )
+    changed = bind_transport(
+        route.manifest.path,
+        changed_header(route, {"transport": transport}, digest=False),
+        catalog=mutation_catalog,
+        limits=ParseLimits(),
+    )
+    assert transport_digest(changed.document) == transport_digest(route.document)
+    assert changed.manifest.sha256 != route.manifest.sha256
+    assert [item.grant for item in changed.members] == [
+        item.grant for item in route.members
+    ]
+
+
+@pytest.mark.parametrize(
+    "updates,digest,match",
+    [
+        ({"schema_version": "3.0.0"}, False, "unsupported"),
+        ({"manifest_sha256": "0" * 64}, False, "checksum"),
+        (
+            {"source_repository": {"id": "source", "revision": None}},
+            True,
+            "unsupported",
+        ),
+        (
+            {"source_repository": {"id": "source", "revision": "main"}},
+            True,
+            "unsupported",
+        ),
+    ],
+)
+def test_bad_manifest_identity_version_and_digest_are_rejected(
+    updates: dict[str, object],
+    digest: bool,
+    match: str,
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Invalid declarations fail before becoming a route or a write plan."""
+    route = unit_transport(mutation_catalog)
+    with pytest.raises(ValueError, match=match):
+        bind_transport(
+            route.manifest.path,
+            changed_header(route, updates, digest=digest),
+            catalog=mutation_catalog,
+            limits=ParseLimits(),
+        )
+
+
+@pytest.mark.parametrize(
+    "fault",
+    [
+        "counts",
+        "duplicate-id",
+        "duplicate-path",
+        "escape",
+        "manifest",
+        "ancestor",
+        "oversize",
+    ],
+)
+def test_manifest_member_conflicts_and_bounds_are_rejected(
+    fault: str, mutation_catalog: SchemaCatalog
+) -> None:
+    """Reject aliases, conflicting identities and oversized transport members."""
+    route = unit_transport(mutation_catalog)
+    document = as_object(json.loads(route.manifest.content))
+    rows = cast("list[dict[str, object]]", document["artifacts"])
+    if fault == "counts":
+        as_object(document["transport"])["payload_count"] = 1
+    elif fault == "duplicate-id":
+        rows[1].update(artifact_kind=rows[0]["artifact_kind"], id=rows[0]["id"])
+    elif fault == "duplicate-path":
+        rows[1]["path"] = rows[0]["path"]
+    elif fault == "escape":
+        rows[0]["path"] = "../escape.json"
+    elif fault == "manifest":
+        rows[0]["path"] = "nested/manifest.json"
+    elif fault == "ancestor":
+        rows[1]["path"] = str(rows[0]["path"]) + "/child.json"
+    else:
+        rows[0]["size"] = 67108865
+    document["manifest_sha256"] = transport_digest(immutable(document))
+    with pytest.raises(ValueError):
+        bind_transport(
+            route.manifest.path,
+            canonical_json(immutable(document)),
+            catalog=mutation_catalog,
+            limits=ParseLimits(),
+        )
+
+
+def test_transport_route_is_exact_and_ordinary_policy_remains_closed(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """An authenticated member grant still needs the explicit transport context."""
+    _, baseline, route, _ = transport_case(mutation_catalog)
+    grant = route.members[0].grant
+    policy = PathPolicy(
+        baseline.snapshot.profile,
+        workspace_root=baseline.workspace_root,
+        metadata=baseline.inspect,
+    )
+    with pytest.raises(PathPolicyError, match="PATH_WRITE_DENIED"):
+        policy.resolve_write(grant.path, grant=grant)
+    policy = PathPolicy(
+        baseline.snapshot.profile,
+        workspace_root=baseline.workspace_root,
+        metadata=baseline.inspect,
+        transport=route,
+    )
+    assert policy.resolve_write(grant.path, grant=grant).grant == grant
+    with pytest.raises(PathPolicyError, match="PATH_WRITE_DENIED"):
+        policy.resolve_write(grant.path, grant=replace(grant, artifact_id="wrong"))
+    assert not route.allows(grant, root="elsewhere")
+
+
+def test_real_planner_accepts_exact_export_replicas_and_publishes_header_last(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """The complete graph retains original/import bytes without duplicate aliases."""
+    _, baseline, route, changes = transport_case(mutation_catalog)
+    request = replace(request_for(baseline), artifact_id="alpha")
+    before = evidence_changes(baseline, request)
+    plan = plan_mutation(
+        baseline, changes, grants=grants_for(*changes), transport=route
+    )
+    assert plan.validation.ok and plan.writes[-1].change.path == route.manifest.path
+    aliases = replica_aliases(plan.prospective)
+    assert set(aliases.values()) == {item.path for item in baseline.snapshot.artifacts}
+    assert len(plan.prospective.artifacts) == len(baseline.snapshot.artifacts) * 2 + 1
+    index = index_references(plan.prospective)
+    assert not index.findings
+    assert all(
+        plan.prospective.file(item.path).content == item.content
+        for item in baseline.snapshot.manifest.files
+    )
+    # Projection remains local; divergent same-pin writes still require validation.
+    assert (
+        evidence_changes(replace(baseline, snapshot=plan.prospective), request)
+        == before
+    )
+    local = index.candidates("feature-contract", "alpha")[0]
+    assert local.artifact.origin_path is None
+    reference = immutable(
+        dict(
+            artifact_kind=local.kind,
+            repository_id=local.repository,
+            revision=local.artifact.repository.revision,
+            artifact_path=local.path,
+            artifact_sha256=plan.prospective.file(local.artifact.path).sha256,
+            feature_id=local.document["feature_id"],
+            schema_version="2.0.0",
+        )
+    )
+    resolved = index.resolve(reference, source=local, pointer="/source_contract_ref")
+    assert not resolved.findings and resolved.target is not None
+    assert resolved.target.artifact.origin_path == local.path
+    assert aliases[resolved.target.artifact.path] == local.artifact.path
+    context = ClaimContext(index, EvidenceValidation(assessments=(), findings=()), 1000)
+    assert context.targets(local, "")
+    assert context.targets(resolved.target, "") == context.targets(local, "")
+    assert resolved.target not in index.records
+    for link in index.links:
+        if link.source.kind == "source-snapshot-manifest":
+            assert link.target is not None and link.target.artifact.origin_path
+            assert link.target.artifact.path == (
+                route.manifest.path.rsplit("/", 1)[0]
+                + "/"
+                + str(link.reference["path"])
+            )
+
+
+@pytest.mark.parametrize(
+    "fault",
+    ["unbound", "changed-bytes", "changed-pin", "changed-origin", "changed-header"],
+)
+def test_unbound_or_conflicting_copies_keep_duplicate_errors(
+    fault: str, mutation_catalog: SchemaCatalog
+) -> None:
+    """Only actual manifest-provenance-bound raw replicas can share lookup identity."""
+    store, baseline, route, changes = transport_case(mutation_catalog)
+    for item in changes:
+        store.put(item.path, item.content)
+    snapshot = capture(store, mutation_catalog).snapshot
+    imported = next(item for item in snapshot.artifacts if item.origin_path)
+    if fault == "unbound":
+        snapshot = replace(
+            snapshot,
+            artifacts=tuple(
+                item for item in snapshot.artifacts if item.path != route.manifest.path
+            ),
+        )
+    elif fault == "changed-pin":
+        snapshot = replace(
+            snapshot,
+            artifacts=tuple(
+                (
+                    replace(
+                        item, repository=replace(item.repository, revision="b" * 40)
+                    )
+                    if item == imported
+                    else item
+                )
+                for item in snapshot.artifacts
+            ),
+        )
+    elif fault == "changed-origin":
+        snapshot = replace(
+            snapshot,
+            artifacts=tuple(
+                replace(item, origin_path="other.json") if item == imported else item
+                for item in snapshot.artifacts
+            ),
+        )
+    else:
+        path = imported.path if fault == "changed-bytes" else route.manifest.path
+        snapshot = replace(
+            snapshot,
+            manifest=replace(
+                snapshot.manifest,
+                files=tuple(
+                    (
+                        replace(item, content=item.content + b" ")
+                        if item.path == path
+                        else item
+                    )
+                    for item in snapshot.manifest.files
+                ),
+            ),
+        )
+        if fault == "changed-header":
+            document = as_object(json.loads(snapshot.file(path).content))
+            document["manifest_sha256"] = "0" * 64
+            snapshot = replace(
+                snapshot,
+                manifest=replace(
+                    snapshot.manifest,
+                    files=tuple(
+                        (
+                            replace(item, content=json.dumps(document).encode())
+                            if item.path == path
+                            else item
+                        )
+                        for item in snapshot.manifest.files
+                    ),
+                ),
+            )
+    assert any(
+        item.code == "DUPLICATE_ID" for item in index_references(snapshot).findings
+    )
+    assert len(snapshot.manifest.files) >= len(baseline.snapshot.manifest.files)
+
+
+def test_ordinary_same_byte_duplicates_are_not_transport_replicas(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Matching content alone cannot exempt two ordinary declarations."""
+    store, baseline, _, _ = transport_case(mutation_catalog)
+    feature = next(
+        item
+        for item in baseline.snapshot.artifacts
+        if item.expected_kind == "feature-contract"
+    )
+    store.put(feature.path.replace("alpha", "copy"), store.files[feature.path])
+    snapshot = capture(store, mutation_catalog).snapshot
+    assert not replica_aliases(snapshot)
+    assert any(
+        item.code == "DUPLICATE_ID" for item in index_references(snapshot).findings
+    )
+
+
+def test_transport_rejects_incomplete_or_forged_bindings(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Membership and route reconstruction cannot be replaced by result flags."""
+    _, baseline, route, changes = transport_case(mutation_catalog)
+    with pytest.raises(MutationError, match="exact complete"):
+        plan_mutation(
+            baseline, changes[:-1], grants=grants_for(*changes), transport=route
+        )
+    with pytest.raises(ValueError, match="original manifest"):
+        replace(route, members=route.members[:-1]).revalidate(
+            catalog=mutation_catalog, limits=ParseLimits()
+        )
+    with pytest.raises(ValueError, match="checksum"):
+        route.check(route.members[0].grant, b"substituted")
+    with pytest.raises(ValueError, match="complete declared"):
+        route.check_files((route.manifest,))
+
+
+def test_export_projection_is_deterministic_complete_and_read_only(
+    source_capture: CapturedWorkspace,
+) -> None:
+    """Selected contracts keep unknown claims and bring their linked questions."""
+    original = source_capture.snapshot.sha256
+    first = prepare_snapshot_export(source_capture, export_request())
+    assert first == prepare_snapshot_export(source_capture, export_request())
+    assert len(first.changes) == 3
+    assert first.route.source.revision == "a" * 40
+    assert first.route.manifest.path.endswith("/release-alpha/manifest.json")
+    assert first.route.document["manifest_sha256"] == transport_digest(
+        first.route.document
+    )
+    transport = as_object(
+        as_object(json.loads(first.route.manifest.content))["transport"]
+    )
+    assert transport["verification_status"] == "pending"
+    for member, change in zip(first.route.members, first.changes, strict=True):
+        if member.origin is not None:
+            assert change.content == source_capture.snapshot.file(member.origin).content
+    assert source_capture.snapshot.sha256 == original
+
+
+@pytest.mark.parametrize(
+    "kind",
+    [
+        "source",
+        "test",
+        "runtime",
+        "observation",
+        "documentation",
+        "decision",
+        "inventory",
+    ],
+)
+def test_export_retains_verified_evidence_and_exact_payload_bytes(
+    source_capture: CapturedWorkspace,
+    kind: str,
+) -> None:
+    """A transported checksum binds the same bytes as accepted local evidence."""
+    baseline = evidence_capture(source_capture, kind)
+    proposal = prepare_snapshot_export(baseline, export_request())
+    payloads = cast("tuple[object, ...]", proposal.route.document["payloads"])
+    assert len(payloads) == 1
+    proof = next(
+        item for item in proposal.changes if item.artifact_kind == "evidence-reference"
+    )
+    payload = next(
+        item for item in proposal.changes if item.artifact_kind == "evidence-payload"
+    )
+    record = as_object(json.loads(proof.content))
+    assert as_object(record["checksum"])["value"] == sha256(payload.content).hexdigest()
+    assert record["revision"] == ("a" * 40 if kind in {"source", "test"} else None)
+    assert len(proposal.changes) == 5
+
+
+@pytest.mark.parametrize(
+    "fault", ["empty", "duplicate", "missing", "imported", "unresolved", "malformed"]
+)
+def test_export_rejects_invalid_selection_or_incomplete_source_closure(
+    source_capture: CapturedWorkspace,
+    fault: str,
+) -> None:
+    """Export cannot hide an absent, malformed, foreign or unresolved dependency."""
+    baseline, request = export_fault(source_capture, fault)
+    with pytest.raises(MutationError):
+        prepare_snapshot_export(baseline, request)
+
+
+@pytest.mark.parametrize("fault", ["checksum", "missing-object"])
+def test_export_never_substitutes_unverified_or_working_tree_source_bytes(
+    source_capture: CapturedWorkspace,
+    fault: str,
+) -> None:
+    """Checksum failures and unavailable immutable objects cannot enter a bundle."""
+    baseline = evidence_capture(source_capture, "source")
+    objects = baseline.snapshot.repository_files
+    if fault == "checksum":
+        objects = tuple(replace(item, content=b"different") for item in objects)
+    else:
+        objects = ()
+    baseline = replace(
+        baseline, snapshot=replace(baseline.snapshot, repository_files=objects)
+    )
+    with pytest.raises(MutationError, match="locally verified"):
+        prepare_snapshot_export(baseline, export_request())
+
+
+def test_export_repeat_binds_original_hash_and_conflicting_bytes_are_not_replaced(
+    source_capture: CapturedWorkspace,
+) -> None:
+    """Repeated projection skips identical immutable files and rejects replacements."""
+    proposal = prepare_snapshot_export(source_capture, export_request())
+    files = tuple(
+        SnapshotFile(path=item.path, content=item.content, category="source-snapshot")
+        for item in proposal.changes
+    )
+    baseline = with_files(
+        source_capture, (*source_capture.snapshot.manifest.files, *files)
+    )
+    repeated = prepare_snapshot_export(baseline, export_request())
+    assert all(
+        item.expected_sha256 == sha256(item.content).hexdigest()
+        for item in repeated.changes
+    )
+    changed = replace(files[0], content=b"changed")
+    baseline = with_files(
+        baseline, (*source_capture.snapshot.manifest.files, changed, *files[1:])
+    )
+    with pytest.raises(MutationError, match="destination bytes"):
+        prepare_snapshot_export(baseline, export_request())
--- /dev/null
+++ b/tests/discovery_runtime/test_snapshot_import.py
@@ -0,0 +1,449 @@
+"""Keep transport mutation forwarding and guarded validation isolated in memory."""
+
+from __future__ import annotations
+
+import json
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery import mutation_io, source_snapshots
+from drm_copilot_discovery.models import ParseLimits, to_plain_value
+from drm_copilot_discovery.mutation_io import (
+    GuardedMutationWriter,
+    MutationResult,
+    commit_mutation,
+)
+from drm_copilot_discovery.mutation_plan import (
+    MutationChange,
+    MutationError,
+    MutationPlan,
+    PlannedWrite,
+    plan_mutation,
+)
+from drm_copilot_discovery.snapshot import SnapshotFile
+from drm_copilot_discovery.source_snapshots import prepare_snapshot_import
+from drm_copilot_discovery.transport_manifest import transport_digest
+
+from tests.discovery_runtime.mutation_test_support import grants_for
+from tests.discovery_runtime.mutation_test_support import (
+    mutation_catalog as mutation_catalog,
+)
+from tests.discovery_runtime.source_snapshot_test_support import (
+    RecordingPrimitives,
+    export_request,
+    import_case,
+    isolated_plan,
+    with_files,
+)
+from tests.discovery_runtime.source_snapshot_test_support import (
+    source_capture as source_capture,
+)
+from tests.discovery_runtime.source_snapshot_test_support import (
+    target_capture as target_capture,
+)
+from tests.schemas.discovery.v2_schema_test_support import as_object
+
+if TYPE_CHECKING:
+
+    from drm_copilot_discovery.agent_output import InvocationContext
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_io import MutationWriter
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+    from drm_copilot_discovery.path_models import WriteGrant
+    from drm_copilot_discovery.source_snapshots import SnapshotImport
+    from drm_copilot_discovery.transport_manifest import TransportRoute
+
+
+def test_transport_rejects_specialist_invocation_before_projection(
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """A caller cannot obtain this root route by supplying a specialist context."""
+    plan = isolated_plan(mutation_catalog)
+    with pytest.raises(MutationError, match="root-only"):
+        plan_mutation(
+            plan.baseline,
+            tuple(item.change for item in plan.writes),
+            grants=plan.grants,
+            invocation=cast("InvocationContext", object()),
+            transport=plan.transport,
+        )
+
+
+@pytest.mark.parametrize("fault", ["grant", "extra-grant", "bytes", "existing"])
+def test_import_rejects_changed_members_or_incomplete_grants_before_graph_work(
+    fault: str, mutation_catalog: SchemaCatalog
+) -> None:
+    """Immutable routes cannot overwrite or widen a declared member set."""
+    plan = isolated_plan(mutation_catalog)
+    changes = tuple(item.change for item in plan.writes)
+    grants = plan.grants
+    baseline = plan.baseline
+    if fault == "grant":
+        grants = grants[:-1]
+    elif fault == "extra-grant":
+        grants += (replace(grants[0], path=grants[0].path + ".extra"),)
+    elif fault == "bytes":
+        changes = (replace(changes[0], content=b"changed"), *changes[1:])
+    else:
+        prior = SnapshotFile(
+            path=changes[0].path, content=b"existing", category="artifact"
+        )
+        baseline = replace(
+            baseline,
+            snapshot=replace(
+                baseline.snapshot,
+                manifest=replace(
+                    baseline.snapshot.manifest,
+                    files=baseline.snapshot.manifest.files + (prior,),
+                ),
+            ),
+        )
+        changes = (replace(changes[0], expected_sha256=prior.sha256), *changes[1:])
+    with pytest.raises(
+        ValueError, match="complete transport|checksum|cannot be replaced"
+    ):
+        plan_mutation(baseline, changes, grants=grants, transport=plan.transport)
+
+
+def test_commit_reconstructs_transport_and_dry_run_performs_no_publication(
+    monkeypatch: pytest.MonkeyPatch, mutation_catalog: SchemaCatalog
+) -> None:
+    """The commit orchestrator forwards the exact route, grants and captured input."""
+    plan = isolated_plan(mutation_catalog)
+    seen: list[TransportRoute | None] = []
+
+    def reconstruct(
+        baseline: CapturedWorkspace,
+        changes: tuple[MutationChange, ...],
+        *,
+        grants: tuple[WriteGrant, ...],
+        invocation: InvocationContext | None,
+        transport: TransportRoute | None,
+    ) -> MutationPlan:
+        assert baseline is plan.baseline and changes == tuple(
+            item.change for item in plan.writes
+        )
+        assert grants == plan.grants and invocation is None
+        seen.append(transport)
+        return plan
+
+    monkeypatch.setattr(mutation_io, "plan_mutation", reconstruct)
+    primitive = RecordingPrimitives()
+    revoked: list[bool] = []
+    writer = GuardedMutationWriter(
+        capture=lambda: plan.baseline,
+        invalidate_authority=lambda: revoked.append(True),
+        primitives=primitive,
+    )
+    first = commit_mutation(plan, writer=writer, dry_run=True)
+    second = commit_mutation(plan, writer=writer, dry_run=True)
+    assert first == second and first.ok and seen == [plan.transport, plan.transport]
+    assert not primitive.calls and not revoked
+    assert all(item.status == "planned" for item in first.artifacts)
+    with pytest.raises(MutationError, match="reconstruction"):
+        commit_mutation(
+            replace(
+                plan, writes=(replace(plan.writes[0], transport=None), *plan.writes[1:])
+            ),
+            writer=writer,
+            dry_run=True,
+        )
+
+
+@pytest.mark.parametrize("fault", [None, "route", "bytes", "prior"])
+def test_guarded_writer_revalidates_route_and_exact_bytes_before_create(
+    fault: str | None, monkeypatch: pytest.MonkeyPatch, mutation_catalog: SchemaCatalog
+) -> None:
+    """The guarded boundary independently rejects tampering without replacing files."""
+    plan = isolated_plan(mutation_catalog)
+    write = plan.writes[0]
+    baseline = plan.baseline
+    if fault == "route":
+        assert write.transport is not None
+        write = replace(
+            write,
+            transport=replace(write.transport, members=write.transport.members[:-1]),
+        )
+    elif fault == "bytes":
+        write = replace(write, change=replace(write.change, content=b"changed"))
+    elif fault == "prior":
+        prior = SnapshotFile(
+            path=write.change.path, content=write.change.content, category="artifact"
+        )
+        baseline = replace(
+            baseline,
+            snapshot=replace(
+                baseline.snapshot,
+                manifest=replace(
+                    baseline.snapshot.manifest,
+                    files=baseline.snapshot.manifest.files + (prior,),
+                ),
+            ),
+        )
+        write = replace(
+            write, change=replace(write.change, expected_sha256=prior.sha256)
+        )
+    postchecks: list[PlannedWrite] = []
+
+    def postcheck(
+        expected: CapturedWorkspace, current: CapturedWorkspace, item: PlannedWrite
+    ) -> None:
+        assert expected is baseline and current is baseline
+        postchecks.append(item)
+
+    monkeypatch.setattr(mutation_io, "_after_write", postcheck)
+    primitive = RecordingPrimitives()
+    writer = GuardedMutationWriter(
+        capture=lambda: baseline,
+        invalidate_authority=lambda: None,
+        primitives=primitive,
+    )
+    if fault:
+        with pytest.raises(ValueError, match="manifest|checksum|absence"):
+            writer.atomic_write(write, expected=baseline)
+        assert not primitive.calls and not postchecks
+    else:
+        writer.atomic_write(write, expected=baseline)
+        assert primitive.calls == [(write.target, write.change.content)]
+        assert postchecks == [write]
+
+
+def test_postcheck_keeps_transport_route_for_final_path_validation(
+    monkeypatch: pytest.MonkeyPatch, mutation_catalog: SchemaCatalog
+) -> None:
+    """The postcheck delegates graph projection but retains exact transport grants."""
+    plan = isolated_plan(mutation_catalog)
+    write = plan.writes[0]
+
+    def projected(
+        baseline: CapturedWorkspace, changes: tuple[MutationChange, ...]
+    ) -> object:
+        assert baseline is plan.baseline and changes == (write.change,)
+        return baseline.snapshot
+
+    monkeypatch.setattr(mutation_io, "project_snapshot", projected)
+    primitive = RecordingPrimitives()
+    writer = GuardedMutationWriter(
+        capture=lambda: plan.baseline,
+        invalidate_authority=lambda: None,
+        primitives=primitive,
+    )
+    writer.atomic_write(write, expected=plan.baseline)
+    assert primitive.calls == [(write.target, write.change.content)]
+    assert write.transport is not None
+    write.transport.revalidate(catalog=mutation_catalog, limits=ParseLimits())
+
+
+def test_import_verifies_new_local_bundle_without_changing_inputs_or_clients(
+    target_capture: tuple[CapturedWorkspace, SnapshotImport],
+) -> None:
+    """A new destination binds verified bytes and preserves both configured clients."""
+    baseline, request = target_capture
+    before = baseline.snapshot.sha256
+    proposal = prepare_snapshot_import(baseline, request)
+    transport = as_object(to_plain_value(proposal.route.document["transport"]))
+    assert transport["verification_status"] == "verified"
+    assert transport["verified_at"] == request.verified_at
+    assert proposal.route.source == request.source
+    assert len(proposal.changes) == 3 and len(baseline.snapshot.profile.clients) == 2
+    assert proposal.route.manifest.path.endswith("/" + "a" * 40 + "/manifest.json")
+    assert proposal.route.document["manifest_sha256"] == transport_digest(
+        proposal.route.document
+    )
+    for member, change in zip(proposal.route.members, proposal.changes, strict=True):
+        if member.origin is not None:
+            assert (
+                change.content
+                == baseline.snapshot.file(
+                    "docs/incoming/source/" + member.origin
+                ).content
+            )
+    assert baseline.snapshot.sha256 == before
+    assert all(item.expected_sha256 is None for item in proposal.changes)
+
+
+@pytest.mark.parametrize(
+    "fault",
+    ["identity", "pin", "version", "digest", "bytes", "missing", "extra", "escape"],
+)
+def test_import_rejects_foreign_changed_incomplete_or_escaping_transport(
+    target_capture: tuple[CapturedWorkspace, SnapshotImport],
+    fault: str,
+) -> None:
+    """Captured staging data must match one complete immutable configured source."""
+    baseline, request = target_capture
+    files = baseline.snapshot.manifest.files
+    if fault in {"identity", "pin"}:
+        source = replace(
+            request.source,
+            **({"id": "foreign"} if fault == "identity" else {"revision": "c" * 40}),
+        )
+        request = replace(request, source=source)
+    elif fault == "escape":
+        request = replace(request, manifest_path="../manifest.json")
+    elif fault == "extra":
+        files += (
+            SnapshotFile(
+                path="docs/incoming/source/extra.bin",
+                content=b"extra",
+                category="source-snapshot",
+            ),
+        )
+    else:
+        chosen = next(
+            item
+            for item in files
+            if item.path.startswith("docs/incoming/source/")
+            and (item.path == request.manifest_path) == (fault in {"version", "digest"})
+        )
+        content = b"changed"
+        if fault in {"version", "digest"}:
+            document = as_object(json.loads(chosen.content))
+            document["schema_version" if fault == "version" else "manifest_sha256"] = (
+                "3.0.0" if fault == "version" else "0" * 64
+            )
+            content = json.dumps(document).encode()
+        files = tuple(
+            replace(item, content=content) if item == chosen else item
+            for item in files
+            if fault != "missing" or item != chosen
+        )
+    with pytest.raises(ValueError):
+        prepare_snapshot_import(with_files(baseline, files), request)
+
+
+def test_import_respects_custom_root_without_renaming_source_paths(
+    source_capture: CapturedWorkspace,
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Configured destination roots preserve original paths inside the envelope."""
+    exported = source_snapshots.prepare_snapshot_export(
+        source_capture, export_request()
+    )
+    _, baseline, request = import_case(mutation_catalog, exported, custom=True)
+    proposal = prepare_snapshot_import(baseline, request)
+    assert all(item.path.startswith("docs/transport/") for item in proposal.changes)
+    assert [item.origin for item in proposal.route.members] == [
+        item.origin for item in exported.route.members
+    ]
+
+
+@pytest.mark.parametrize("operation", ["export", "import"])
+def test_public_planner_forwards_exact_proposal_grants_and_invocation(
+    operation: str,
+    monkeypatch: pytest.MonkeyPatch,
+    target_capture: tuple[CapturedWorkspace, SnapshotImport],
+    source_capture: CapturedWorkspace,
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Planning uses the shared engine without altering captured authority inputs."""
+    baseline, request = (
+        target_capture if operation == "import" else (source_capture, export_request())
+    )
+    proposal = (
+        source_snapshots.prepare_snapshot_import(
+            baseline, cast("SnapshotImport", request)
+        )
+        if operation == "import"
+        else source_snapshots.prepare_snapshot_export(baseline, export_request())
+    )
+    grants = grants_for(*proposal.changes)
+    context = cast("InvocationContext", object())
+    expected = isolated_plan(mutation_catalog)
+    calls: list[object] = []
+
+    def plan(
+        actual: CapturedWorkspace, changes: object, **options: object
+    ) -> MutationPlan:
+        calls.append((actual, changes, options))
+        return expected
+
+    monkeypatch.setattr(source_snapshots, "plan_mutation", plan)
+    actual = (
+        source_snapshots.plan_snapshot_import(
+            baseline, cast("SnapshotImport", request), grants=grants, invocation=context
+        )
+        if operation == "import"
+        else source_snapshots.plan_snapshot_export(
+            baseline, export_request(), grants=grants, invocation=context
+        )
+    )
+    assert actual is expected
+    assert calls == [
+        (
+            baseline,
+            proposal.changes,
+            dict(grants=grants, invocation=context, transport=proposal.route),
+        )
+    ]
+
+
+@pytest.mark.parametrize(
+    "operation,dry_run,partial",
+    [
+        ("export", True, False),
+        ("export", False, True),
+        ("import", True, False),
+        ("import", False, True),
+    ],
+)
+def test_public_commit_forwards_dry_run_and_preserves_partial_result(
+    operation: str,
+    dry_run: bool,
+    partial: bool,
+    monkeypatch: pytest.MonkeyPatch,
+    target_capture: tuple[CapturedWorkspace, SnapshotImport],
+    mutation_catalog: SchemaCatalog,
+) -> None:
+    """Thin wrappers retain exact planning context and shared writer outcomes."""
+    baseline, request = target_capture
+    plan = isolated_plan(mutation_catalog)
+    writer = cast("MutationWriter", object())
+    context = cast("InvocationContext", object())
+    result = MutationResult(
+        ok=not partial,
+        artifacts=(),
+        findings=(),
+        validation=plan.validation,
+        authority_invalidated=partial,
+        uncertain_paths=("uncertain",) if partial else (),
+    )
+    planned: list[object] = []
+    committed: list[object] = []
+
+    def prepare(actual: object, selected: object, **options: object) -> MutationPlan:
+        planned.append((actual, selected, options))
+        return plan
+
+    def commit(actual: object, **options: object) -> MutationResult:
+        committed.append((actual, options))
+        return result
+
+    monkeypatch.setattr(source_snapshots, "plan_snapshot_" + operation, prepare)
+    monkeypatch.setattr(source_snapshots, "commit_mutation", commit)
+    selected = request if operation == "import" else export_request()
+    actual = (
+        source_snapshots.import_snapshot(
+            baseline,
+            request,
+            grants=plan.grants,
+            writer=writer,
+            dry_run=dry_run,
+            invocation=context,
+        )
+        if operation == "import"
+        else source_snapshots.export_snapshot(
+            baseline,
+            export_request(),
+            grants=plan.grants,
+            writer=writer,
+            dry_run=dry_run,
+            invocation=context,
+        )
+    )
+    assert actual is result and actual.authority_invalidated == partial
+    assert planned == [
+        (baseline, selected, dict(grants=plan.grants, invocation=context))
+    ]
+    assert committed == [(plan, dict(writer=writer, dry_run=dry_run))]
--- /dev/null
+++ b/tests/discovery_runtime/source_snapshot_test_support.py
@@ -0,0 +1,373 @@
+"""Build immutable transport fixtures and fresh memory stores for task tests."""
+
+from __future__ import annotations
+
+import json
+from contextlib import nullcontext
+from dataclasses import replace
+from hashlib import sha256
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.evidence_linking import evidence_changes
+from drm_copilot_discovery.findings import Finding
+from drm_copilot_discovery.models import ParseLimits, canonical_json
+from drm_copilot_discovery.mutation_plan import (
+    MutationChange,
+    MutationPlan,
+    PlannedWrite,
+)
+from drm_copilot_discovery.path_policy import PathPolicy
+from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
+from drm_copilot_discovery.snapshot import SnapshotFile
+from drm_copilot_discovery.source_snapshots import (
+    SnapshotExport,
+    SnapshotImport,
+    prepare_snapshot_export,
+)
+from drm_copilot_discovery.transport_manifest import bind_transport, transport_digest
+from drm_copilot_discovery.validation import SnapshotValidation
+
+from tests.discovery_runtime.draft_test_support import add_feature, draft_case
+from tests.discovery_runtime.evidence_test_support import add_record, request_for
+from tests.discovery_runtime.mutation_test_support import (
+    capture,
+    grants_for,
+    mutation_case,
+)
+from tests.discovery_runtime.test_profile_v2 import profile_document
+from tests.discovery_runtime.test_references import immutable
+from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH, MemoryStore
+from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture
+
+if TYPE_CHECKING:
+    from contextlib import AbstractContextManager
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+    from drm_copilot_discovery.path_models import ResolvedPath
+    from drm_copilot_discovery.source_snapshots import SnapshotProposal
+    from drm_copilot_discovery.transport_manifest import TransportRoute
+
+
+def transport_case(
+    catalog: SchemaCatalog,
+) -> tuple[MemoryStore, CapturedWorkspace, TransportRoute, tuple[MutationChange, ...]]:
+    """Create a fresh truthful feature/question graph and exact export envelope."""
+    store, baseline = draft_case(catalog)
+    profile = as_object(json.loads(store.files[PROFILE_PATH]))
+    as_object(profile["repository"])["revision"] = "a" * 40
+    store.put(PROFILE_PATH, json.dumps(profile).encode())
+    baseline = add_feature(store, catalog, "alpha")
+    path = (
+        baseline.snapshot.profile.artifacts["source_snapshots"]
+        + "/export-alpha/manifest.json"
+    )
+    parent = path.rsplit("/", 1)[0]
+    document = load_fixture("source-snapshot-manifest")
+    document.update(
+        id="export-alpha",
+        source_repository={
+            "id": baseline.snapshot.profile.repository.id,
+            "revision": "a" * 40,
+        },
+        artifacts=[
+            dict(
+                artifact_kind=item.expected_kind,
+                id=str(item.document["id"]),
+                schema_version="2.0.0",
+                path=item.path,
+                sha256=baseline.snapshot.file(item.path).sha256,
+                size=len(baseline.snapshot.file(item.path).content),
+            )
+            for item in baseline.snapshot.artifacts
+            if item.document is not None
+        ],
+        payloads=[],
+    )
+    as_object(document["transport"]).update(
+        artifact_count=len(baseline.snapshot.artifacts), payload_count=0
+    )
+    document["manifest_sha256"] = transport_digest(immutable(document))
+    route = bind_transport(
+        path, canonical_json(immutable(document)), catalog=catalog, limits=ParseLimits()
+    )
+    contents = {
+        parent + "/" + item.path: item.content
+        for item in baseline.snapshot.manifest.files
+        if item.path != PROFILE_PATH
+    }
+    contents[path] = route.manifest.content
+    changes = tuple(
+        MutationChange(
+            artifact_kind=member.grant.artifact_kind,
+            artifact_id=member.grant.artifact_id,
+            path=member.grant.path,
+            content=contents[member.grant.path],
+            expected_sha256=None,
+        )
+        for member in route.members
+    )
+    return store, baseline, route, changes
+
+
+def unit_transport(catalog: SchemaCatalog) -> TransportRoute:
+    """Bind small inert byte declarations for isolated envelope validation cases."""
+    document = load_fixture("source-snapshot-manifest")
+    document["artifacts"] = [
+        dict(
+            artifact_kind=kind,
+            id=identifier,
+            schema_version="2.0.0",
+            path=path,
+            sha256=sha256(b"{}").hexdigest(),
+            size=2,
+        )
+        for kind, identifier, path in (
+            ("feature-contract", "alpha", "contracts/alpha.json"),
+            ("unspecified-behavior-collection", "questions", "questions.json"),
+        )
+    ]
+    document["payloads"] = []
+    as_object(document["transport"]).update(artifact_count=2, payload_count=0)
+    document["manifest_sha256"] = transport_digest(immutable(document))
+    return bind_transport(
+        "docs/migration/discovery/source-snapshots/export-alpha/manifest.json",
+        canonical_json(immutable(document)),
+        catalog=catalog,
+        limits=ParseLimits(),
+    )
+
+
+def changed_header(
+    route: TransportRoute, updates: dict[str, object], *, digest: bool = True
+) -> bytes:
+    """Produce independent hostile envelopes without mutating the original route."""
+    document = as_object(json.loads(route.manifest.content))
+    document.update(updates)
+    if digest:
+        document["manifest_sha256"] = transport_digest(immutable(document))
+    return canonical_json(immutable(document))
+
+
+@pytest.fixture(scope="module")
+def source_capture(mutation_catalog: SchemaCatalog) -> CapturedWorkspace:
+    """Reuse only immutable captured source inputs; never share a mutable store."""
+    return transport_case(mutation_catalog)[1]
+
+
+def export_request() -> SnapshotExport:
+    """Provide fixed caller attribution for deterministic projection assertions."""
+    return SnapshotExport(
+        export_id="release-alpha",
+        artifacts=(("feature-contract", "alpha"),),
+        exported_at="2026-01-01T00:00:00Z",
+        exported_by=immutable(dict(kind="human", id="owner")),
+    )
+
+
+def evidence_capture(baseline: CapturedWorkspace, kind: str) -> CapturedWorkspace:
+    """Attach fresh evidence and exact pinned objects for pure export-unit cases."""
+    request = replace(request_for(baseline, kind=kind), artifact_id="alpha")
+    result = baseline
+    for change in evidence_changes(baseline, request):
+        if change.artifact_kind != "evidence-payload":
+            result = add_record(
+                result, as_object(json.loads(change.content)), path=change.path
+            )
+    files = tuple(
+        SnapshotFile(path=item.path, content=item.content, category="evidence")
+        for item in request.payloads
+    )
+    identity = RepositoryIdentity(
+        id=baseline.snapshot.profile.repository.id, revision="a" * 40
+    )
+    objects = tuple(
+        RepositoryFile(repository=identity, path=item.path, content=item.content)
+        for item in files
+    )
+    return replace(
+        result,
+        snapshot=replace(
+            result.snapshot,
+            manifest=replace(
+                result.snapshot.manifest,
+                files=(*result.snapshot.manifest.files, *files),
+            ),
+            checkout=identity,
+            repository_files=objects,
+        ),
+    )
+
+
+def import_case(
+    catalog: SchemaCatalog,
+    proposal: SnapshotProposal,
+    *,
+    custom: bool = False,
+) -> tuple[MemoryStore, CapturedWorkspace, SnapshotImport]:
+    """Capture a fresh two-client target plus one complete local staging directory."""
+    document = profile_document()
+    as_object(document["system"])["role"] = "modernization-target"
+    as_object(document["repository"]).update(id="target", revision="b" * 40)
+    document["repositories"] = [
+        dict(
+            id=proposal.route.source.id,
+            role="legacy-source",
+            revision=proposal.route.source.revision,
+            snapshot_manifest=None,
+            clients=[],
+        )
+    ]
+    for client in cast("list[dict[str, object]]", document["clients"]):
+        client["target_repository"] = "target"
+    if custom:
+        as_object(document["artifacts"])["source_snapshots"] = "docs/transport"
+    store = MemoryStore()
+    store.put(PROFILE_PATH, json.dumps(document).encode())
+    origin = proposal.route.manifest.path.rsplit("/", 1)[0]
+    for change in proposal.changes:
+        store.put("docs/incoming/source" + change.path[len(origin) :], change.content)
+    baseline = capture(store, catalog)
+    request = SnapshotImport(
+        manifest_path="docs/incoming/source/manifest.json",
+        source=proposal.route.source,
+        verified_at="2026-01-02T00:00:00Z",
+        verified_by=immutable(dict(kind="human", id="importer")),
+    )
+    return store, baseline, request
+
+
+@pytest.fixture(scope="module")
+def target_capture(
+    source_capture: CapturedWorkspace,
+    mutation_catalog: SchemaCatalog,
+) -> tuple[CapturedWorkspace, SnapshotImport]:
+    """Reuse immutable staging inputs; every test owns its projected modifications."""
+    proposal = prepare_snapshot_export(source_capture, export_request())
+    _, baseline, request = import_case(mutation_catalog, proposal)
+    return baseline, request
+
+
+def with_files(
+    baseline: CapturedWorkspace, files: tuple[SnapshotFile, ...]
+) -> CapturedWorkspace:
+    """Replace only immutable captured bytes for narrow projection preconditions."""
+    return replace(
+        baseline,
+        snapshot=replace(
+            baseline.snapshot, manifest=replace(baseline.snapshot.manifest, files=files)
+        ),
+    )
+
+
+def export_fault(
+    baseline: CapturedWorkspace, fault: str
+) -> tuple[CapturedWorkspace, SnapshotExport]:
+    """Construct fresh malformed selection/closure inputs without changing fixtures."""
+    request = export_request()
+    artifacts = baseline.snapshot.artifacts
+    feature = next(
+        item for item in artifacts if item.expected_kind == "feature-contract"
+    )
+    if fault in {"empty", "duplicate", "missing"}:
+        selected = (
+            ()
+            if fault == "empty"
+            else (
+                request.artifacts * 2
+                if fault == "duplicate"
+                else (("feature-contract", "missing"),)
+            )
+        )
+        request = replace(request, artifacts=selected)
+    elif fault == "malformed":
+        baseline = replace(
+            baseline,
+            snapshot=replace(
+                baseline.snapshot,
+                findings=(
+                    Finding(
+                        code="SCHEMA_INVALID",
+                        message="bad",
+                        artifact_path=feature.path,
+                        next_action="Correct the malformed fixture.",
+                    ),
+                ),
+            ),
+        )
+    else:
+        selected_artifacts = tuple(
+            (
+                replace(item, origin_path="original.json")
+                if item == feature and fault == "imported"
+                else item
+            )
+            for item in artifacts
+            if fault != "unresolved" or item == feature
+        )
+        baseline = replace(
+            baseline, snapshot=replace(baseline.snapshot, artifacts=selected_artifacts)
+        )
+    return baseline, request
+
+
+class RecordingPrimitives:
+    """Record one isolated publication request without graph loading or native I/O."""
+
+    def __init__(self) -> None:
+        self.calls: list[tuple[ResolvedPath, bytes]] = []
+
+    def guard(self) -> AbstractContextManager[None]:
+        return nullcontext()
+
+    def create_exclusive(self, target: ResolvedPath, content: bytes) -> None:
+        self.calls.append((target, content))
+
+    def replace_if_digest(
+        self, target: ResolvedPath, content: bytes, *, expected_sha256: str
+    ) -> None:
+        raise AssertionError("An immutable transport must never request replacement")
+
+
+def isolated_plan(catalog: SchemaCatalog) -> MutationPlan:
+    """Build internal values for forwarding tests; never claim graph validation."""
+    _, baseline = mutation_case(catalog)
+    route = unit_transport(catalog)
+    changes = tuple(
+        MutationChange(
+            artifact_kind=item.grant.artifact_kind,
+            artifact_id=item.grant.artifact_id,
+            path=item.grant.path,
+            content=route.manifest.content if item.origin is None else b"{}",
+            expected_sha256=None,
+        )
+        for item in route.members
+    )
+    policy = PathPolicy(
+        baseline.snapshot.profile,
+        workspace_root=baseline.workspace_root,
+        metadata=baseline.inspect,
+        transport=route,
+    )
+    return MutationPlan(
+        baseline=baseline,
+        writes=tuple(
+            PlannedWrite(
+                change=item,
+                target=policy.resolve_write(item.path, grant=grant),
+                skipped=False,
+                transport=route,
+            )
+            for item, grant in zip(changes, grants_for(*changes), strict=True)
+        ),
+        grants=grants_for(*changes),
+        prospective=baseline.snapshot,
+        transport=route,
+        validation=SnapshotValidation(
+            mode="structural",
+            findings=(),
+            input_sha256=baseline.snapshot.sha256,
+            validation_result="pass",
+        ),
+    )
```
