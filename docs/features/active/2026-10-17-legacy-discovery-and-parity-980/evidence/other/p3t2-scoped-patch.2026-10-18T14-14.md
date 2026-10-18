# P3-T2 scoped staged patch

Timestamp: 2026-10-18T14-14
Regenerated: 2026-10-18T14:20:02.750628+00:00
Baseline: a74cb240a7698c1454a8e6018ac23862cd91dab0

Only the 18 authored and seven mechanically generated task paths are included.

Representation: exact zero-context unified diff with full Git blob identities.
The original baseline, task scope and validation provenance are unchanged. Context-only blank lines are omitted to satisfy repository evidence whitespace checks; no changed source line is omitted.
Read-only verification: git apply --cached --reverse --check --unidiff-zero succeeded against the existing index. Production, tests, resources and the index were not modified.

~~~diff
diff --git a/docs/discovery/templates/v2/coverage-ledger.json b/docs/discovery/templates/v2/coverage-ledger.json
new file mode 100644
index 0000000000000000000000000000000000000000..37c283f727f22f839a4e079b0a074ca89a1c3ef1
--- /dev/null
+++ b/docs/discovery/templates/v2/coverage-ledger.json
@@ -0,0 +1,12 @@
+{
+  "$schema": "urn:drm-copilot:discovery:2.0.0:coverage-ledger",
+  "schema_version": "2.0.0",
+  "artifact_kind": "coverage-ledger",
+  "id": "{{ledger_id}}",
+  "repository": "{{repository_id}}",
+  "revision": "{{revision}}",
+  "inventory_snapshot_refs": [],
+  "scope_ref": {"artifact_kind": "scope", "id": "{{scope_id}}"},
+  "components": [],
+  "extensions": {}
+}
diff --git a/docs/discovery/templates/v2/domain-profile.yaml b/docs/discovery/templates/v2/domain-profile.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..28385f28193886b7352c795f7cf3912054af4021
--- /dev/null
+++ b/docs/discovery/templates/v2/domain-profile.yaml
@@ -0,0 +1,34 @@
+$schema: urn:drm-copilot:discovery:2.0.0:domain-profile
+schema_version: 2.0.0
+artifact_kind: domain-profile
+id: "{{profile_id}}"
+profile_version: 2
+profile_state: draft
+system: {id: "{{system_id}}", name: "{{system_name}}", role: "{{role}}"}
+repository: {id: "{{repository_id}}", vcs: git, revision: "{{revision}}", revision_policy: working-tree-at-pin}
+production_roots: "{{production_roots}}"
+test_roots: "{{test_roots}}"
+project_entry_points: []
+documentation_roots: "{{documentation_roots}}"
+evidence_roots: "{{evidence_roots}}"
+repositories: []
+clients: []
+required_platforms: []
+required_modes: [online]
+required_feature_dimensions: []
+runtime: {capability: none, required_feature_ids: []}
+analyzers: {enabled: [], options: {}, ignored_paths: [], extension_result_manifests: []}
+excluded_paths: []
+artifacts: "{{artifacts}}"
+completion_gates:
+  require_confirmed_scope: true
+  require_current_inventory: true
+  require_all_dispositions: true
+  require_feature_evidence: true
+  require_acceptance_scenarios: true
+  require_runtime_for_declared_features: true
+  block_on_unresolved_required_behavior: true
+  require_approved_deviations: true
+  planning_prerequisite: discovery-complete
+decision_owners: []
+extensions: {}
diff --git a/docs/discovery/templates/v2/parity-matrix.json b/docs/discovery/templates/v2/parity-matrix.json
new file mode 100644
index 0000000000000000000000000000000000000000..18948c540f7770196fed0f143161ecff854f7632
--- /dev/null
+++ b/docs/discovery/templates/v2/parity-matrix.json
@@ -0,0 +1,10 @@
+{
+  "$schema": "urn:drm-copilot:discovery:2.0.0:parity-matrix",
+  "schema_version": "2.0.0",
+  "artifact_kind": "parity-matrix",
+  "id": "{{parity_id}}",
+  "source_repositories": "{{source_repositories}}",
+  "target_repositories": "{{target_repositories}}",
+  "entries": [],
+  "extensions": {}
+}
diff --git a/docs/discovery/templates/v2/product-decisions.yaml b/docs/discovery/templates/v2/product-decisions.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..a36724a7dec163b67a383b107da2da24701591c7
--- /dev/null
+++ b/docs/discovery/templates/v2/product-decisions.yaml
@@ -0,0 +1,6 @@
+$schema: urn:drm-copilot:discovery:2.0.0:product-decision-collection
+schema_version: 2.0.0
+artifact_kind: product-decision-collection
+id: "{{decisions_id}}"
+records: []
+extensions: {}
diff --git a/docs/discovery/templates/v2/scope.yaml b/docs/discovery/templates/v2/scope.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..1a46b3dd61c76a42af6f465165f8f0315edc2381
--- /dev/null
+++ b/docs/discovery/templates/v2/scope.yaml
@@ -0,0 +1,16 @@
+$schema: urn:drm-copilot:discovery:2.0.0:scope
+schema_version: 2.0.0
+artifact_kind: scope
+id: "{{scope_id}}"
+status: draft
+repository: {id: "{{repository_id}}", revision: "{{revision}}"}
+included_roots: "{{production_roots}}"
+included_components: []
+included_features: []
+exclusions: []
+inventory_snapshot_refs: []
+confirmed_by: null
+required_coverage: {feature_refs: [], client_ids: [], modes: "{{required_modes}}"}
+disposition: in-scope
+no_scope_rationale: null
+extensions: {}
diff --git a/docs/discovery/templates/v2/unspecified-behaviors.yaml b/docs/discovery/templates/v2/unspecified-behaviors.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..f418f8f71dbaebbee7749f2cee328e3dc3d6179e
--- /dev/null
+++ b/docs/discovery/templates/v2/unspecified-behaviors.yaml
@@ -0,0 +1,6 @@
+$schema: urn:drm-copilot:discovery:2.0.0:unspecified-behavior-collection
+schema_version: 2.0.0
+artifact_kind: unspecified-behavior-collection
+id: "{{unresolved_id}}"
+records: []
+extensions: {}
diff --git a/packages/discovery-runtime/resource-manifest.json b/packages/discovery-runtime/resource-manifest.json
index 57aff5c41b8eb74f4344473e9ffb3f79d7dfd1fc..bf6cc878db0954d71d40df2f79a0db9f3a01edad 100644
--- a/packages/discovery-runtime/resource-manifest.json
+++ b/packages/discovery-runtime/resource-manifest.json
@@ -3,0 +4 @@
+    "docs/discovery/templates/v2",
@@ -7,0 +9,6 @@
+    "docs/discovery/templates/v2/coverage-ledger.json",
+    "docs/discovery/templates/v2/domain-profile.yaml",
+    "docs/discovery/templates/v2/parity-matrix.json",
+    "docs/discovery/templates/v2/product-decisions.yaml",
+    "docs/discovery/templates/v2/scope.yaml",
+    "docs/discovery/templates/v2/unspecified-behaviors.yaml",
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/coverage-ledger.json b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/coverage-ledger.json
new file mode 100644
index 0000000000000000000000000000000000000000..37c283f727f22f839a4e079b0a074ca89a1c3ef1
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/coverage-ledger.json
@@ -0,0 +1,12 @@
+{
+  "$schema": "urn:drm-copilot:discovery:2.0.0:coverage-ledger",
+  "schema_version": "2.0.0",
+  "artifact_kind": "coverage-ledger",
+  "id": "{{ledger_id}}",
+  "repository": "{{repository_id}}",
+  "revision": "{{revision}}",
+  "inventory_snapshot_refs": [],
+  "scope_ref": {"artifact_kind": "scope", "id": "{{scope_id}}"},
+  "components": [],
+  "extensions": {}
+}
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/domain-profile.yaml b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/domain-profile.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..28385f28193886b7352c795f7cf3912054af4021
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/domain-profile.yaml
@@ -0,0 +1,34 @@
+$schema: urn:drm-copilot:discovery:2.0.0:domain-profile
+schema_version: 2.0.0
+artifact_kind: domain-profile
+id: "{{profile_id}}"
+profile_version: 2
+profile_state: draft
+system: {id: "{{system_id}}", name: "{{system_name}}", role: "{{role}}"}
+repository: {id: "{{repository_id}}", vcs: git, revision: "{{revision}}", revision_policy: working-tree-at-pin}
+production_roots: "{{production_roots}}"
+test_roots: "{{test_roots}}"
+project_entry_points: []
+documentation_roots: "{{documentation_roots}}"
+evidence_roots: "{{evidence_roots}}"
+repositories: []
+clients: []
+required_platforms: []
+required_modes: [online]
+required_feature_dimensions: []
+runtime: {capability: none, required_feature_ids: []}
+analyzers: {enabled: [], options: {}, ignored_paths: [], extension_result_manifests: []}
+excluded_paths: []
+artifacts: "{{artifacts}}"
+completion_gates:
+  require_confirmed_scope: true
+  require_current_inventory: true
+  require_all_dispositions: true
+  require_feature_evidence: true
+  require_acceptance_scenarios: true
+  require_runtime_for_declared_features: true
+  block_on_unresolved_required_behavior: true
+  require_approved_deviations: true
+  planning_prerequisite: discovery-complete
+decision_owners: []
+extensions: {}
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/parity-matrix.json b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/parity-matrix.json
new file mode 100644
index 0000000000000000000000000000000000000000..18948c540f7770196fed0f143161ecff854f7632
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/parity-matrix.json
@@ -0,0 +1,10 @@
+{
+  "$schema": "urn:drm-copilot:discovery:2.0.0:parity-matrix",
+  "schema_version": "2.0.0",
+  "artifact_kind": "parity-matrix",
+  "id": "{{parity_id}}",
+  "source_repositories": "{{source_repositories}}",
+  "target_repositories": "{{target_repositories}}",
+  "entries": [],
+  "extensions": {}
+}
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/product-decisions.yaml b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/product-decisions.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..a36724a7dec163b67a383b107da2da24701591c7
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/product-decisions.yaml
@@ -0,0 +1,6 @@
+$schema: urn:drm-copilot:discovery:2.0.0:product-decision-collection
+schema_version: 2.0.0
+artifact_kind: product-decision-collection
+id: "{{decisions_id}}"
+records: []
+extensions: {}
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/scope.yaml b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/scope.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..1a46b3dd61c76a42af6f465165f8f0315edc2381
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/scope.yaml
@@ -0,0 +1,16 @@
+$schema: urn:drm-copilot:discovery:2.0.0:scope
+schema_version: 2.0.0
+artifact_kind: scope
+id: "{{scope_id}}"
+status: draft
+repository: {id: "{{repository_id}}", revision: "{{revision}}"}
+included_roots: "{{production_roots}}"
+included_components: []
+included_features: []
+exclusions: []
+inventory_snapshot_refs: []
+confirmed_by: null
+required_coverage: {feature_refs: [], client_ids: [], modes: "{{required_modes}}"}
+disposition: in-scope
+no_scope_rationale: null
+extensions: {}
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/unspecified-behaviors.yaml b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/unspecified-behaviors.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..f418f8f71dbaebbee7749f2cee328e3dc3d6179e
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/unspecified-behaviors.yaml
@@ -0,0 +1,6 @@
+$schema: urn:drm-copilot:discovery:2.0.0:unspecified-behavior-collection
+schema_version: 2.0.0
+artifact_kind: unspecified-behavior-collection
+id: "{{unresolved_id}}"
+records: []
+extensions: {}
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json
index e47bffc283707b5a9a8efb51eba25a494c6123db..dc50f81eee078941fb18a0203fadb73f7d72085c 100644
--- a/packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json
@@ -3,0 +4,30 @@
+    {
+      "path": "docs/discovery/templates/v2/coverage-ledger.json",
+      "sha256": "21b7d9d211d0d943062e3802703e3c1a63dd4ceb0117e5292a3391cf1564071a",
+      "size": 364
+    },
+    {
+      "path": "docs/discovery/templates/v2/domain-profile.yaml",
+      "sha256": "c04bd95b1827f73f47aecf9dae3e33b9715ead0899e1c8cc5d8bd591298499da",
+      "size": 1225
+    },
+    {
+      "path": "docs/discovery/templates/v2/parity-matrix.json",
+      "sha256": "e40f3c72fa288331cf3775ab17d1306ad2832db7e4581116525ca889d67d0b99",
+      "size": 296
+    },
+    {
+      "path": "docs/discovery/templates/v2/product-decisions.yaml",
+      "sha256": "4644fffb292e210dde77959d31ce5f043a4a5467bc42e372cecc988376b30aba",
+      "size": 184
+    },
+    {
+      "path": "docs/discovery/templates/v2/scope.yaml",
+      "sha256": "89bd691ebdd070f890bc80eac95397e1c0d3813655adace0f170123ce219d2b5",
+      "size": 479
+    },
+    {
+      "path": "docs/discovery/templates/v2/unspecified-behaviors.yaml",
+      "sha256": "aaa963c7abe7470a3b343098df2e4821b665396973de76f37dd6ebe503d7791d",
+      "size": 193
+    },
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py b/packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py
new file mode 100644
index 0000000000000000000000000000000000000000..e22a3de877c58b68eb3b7bce3ff0ef12029abd13
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py
@@ -0,0 +1,481 @@
+"""Plan and initialize honest v2 drafts through a root-bound trusted I/O adapter."""
+
+from __future__ import annotations
+
+from dataclasses import dataclass
+from hashlib import sha256
+from typing import TYPE_CHECKING
+
+from drm_copilot_discovery.init_models import EXPECTED_TEMPLATE_RELATIVE_PATHS
+from drm_copilot_discovery.init_projection import (
+    ARTIFACT_TEMPLATES,
+    InitializationConflict,
+    InitializationOutput,
+    InitializationRequest,
+    InitializationResult,
+    InitializationTemplates,
+    artifact_values,
+    profile_proposal,
+    require_compatible,
+)
+from drm_copilot_discovery.mutation_io import GuardedMutationWriter, commit_mutation
+from drm_copilot_discovery.mutation_plan import (
+    MutationChange,
+    MutationError,
+    plan_mutation,
+)
+from drm_copilot_discovery.path_models import PathPolicyError, WriteGrant
+from drm_copilot_discovery.path_policy import FILE_KEYS
+from drm_copilot_discovery.profile_v2 import ProfileError
+
+if TYPE_CHECKING:
+    from collections.abc import Mapping
+    from pathlib import Path
+
+    from drm_copilot_discovery.init_io import InitializationIO
+    from drm_copilot_discovery.init_models import FileSystem
+    from drm_copilot_discovery.init_projection import InitializationCapture
+    from drm_copilot_discovery.mutation_plan import MutationPlan
+
+
+@dataclass(frozen=True, kw_only=True)
+class InitializationPlan:
+    """Bind a validated graph to actual physical inputs and exact draft bytes.
+
+    The mutation plan's baseline is virtual and is never committed. Bootstrap
+    must produce an equivalent real capture before ordinary artifact mutations.
+    """
+
+    request: InitializationRequest
+    templates: InitializationTemplates
+    capture: InitializationCapture
+    profile_bytes: bytes
+    directories: tuple[str, ...]
+    mutation: MutationPlan
+
+
+def _plan_initialization(
+    request: InitializationRequest,
+    *,
+    io: InitializationIO,
+    templates: InitializationTemplates | None = None,
+) -> InitializationPlan:
+    """
+    Validate the complete creation graph before writes, preserving valid existing
+    bytes.
+    """
+    selected = templates or InitializationTemplates.load()
+    repository = io.available_repository()
+    identity = repository.identity() if repository is not None else None
+    if identity is not None and identity.id != request.repository_id:
+        raise ValueError("Local Git identity differs from the requested repository")
+    fallback = profile_proposal(
+        request,
+        templates=selected,
+        catalog=io.catalog,
+        revision=identity.revision if identity else None,
+    )
+    profile_path = str(request.artifact_paths()["profile"])
+    initial = io.capture(profile_path=profile_path, profile_bytes=fallback)
+    profile = initial.proposal_base.snapshot.profile
+    require_compatible(request, profile)
+    profile_bytes = initial.proposal_base.snapshot.file(profile_path).content
+    # Only configured directory categories belong to root bootstrap publication.
+    directories = tuple(
+        sorted(
+            str(value)
+            for key, value in profile.artifacts.data.items()
+            if key not in FILE_KEYS
+        )
+    )
+    captured = io.capture(
+        profile_path=profile_path, profile_bytes=profile_bytes, directories=directories
+    )
+    # The second complete capture must retain the effective profile selection.
+    require_compatible(request, captured.proposal_base.snapshot.profile)
+    if captured.proposal_base.snapshot.file(profile_path).content != profile_bytes:
+        raise OSError("Profile changed while preparing initialization")
+    snapshot = captured.proposal_base.snapshot
+    if not snapshot.ok:
+        raise InitializationConflict(
+            profile_path,
+            "Existing initialization inputs are invalid; correct the reported paths",
+            findings=snapshot.findings,
+        )
+    # Existing validated records retain their IDs and exact original bytes.
+    originals = {item.path: item for item in snapshot.artifacts}
+    scope = originals.get(profile.artifacts["scope"])
+    scope_id = (
+        str(scope.document["id"])
+        if scope and scope.document
+        else "scope-" + profile.system.id
+    )
+    values = artifact_values(profile, scope_id=scope_id)
+    changes: list[MutationChange] = []
+    # Source-only workspaces have no target parity artifact to initialize.
+    for key, kind, template in ARTIFACT_TEMPLATES:
+        if key == "parity_matrix" and profile.system.role == "legacy-source":
+            continue
+        path = profile.artifacts[key]
+        original = originals.get(path)
+        if original is not None and original.document is None:
+            raise InitializationConflict(
+                path, f"Existing initialization artifact is invalid: {path}", kind=kind
+            )
+        content = (
+            snapshot.file(path).content
+            if original
+            else selected.render(template, values)
+        )
+        document = original.document if original else None
+        artifact_id = (
+            str(document["id"])
+            if document
+            else {
+                "scope": scope_id,
+                "coverage_ledger": values["ledger_id"],
+                "unspecified_behaviors": values["unresolved_id"],
+                "product_decisions": values["decisions_id"],
+                "parity_matrix": values["parity_id"],
+            }[key]
+        )
+        changes.append(
+            MutationChange(
+                artifact_kind=kind,
+                artifact_id=str(artifact_id),
+                path=path,
+                content=content,
+                expected_sha256=sha256(content).hexdigest() if original else None,
+            )
+        )
+    mutation = plan_mutation(
+        captured.proposal_base,
+        tuple(changes),
+        # Each publication is restricted to its exact projected kind, ID and path.
+        grants=tuple(
+            WriteGrant(
+                artifact_kind=item.artifact_kind,
+                artifact_id=item.artifact_id,
+                path=item.path,
+            )
+            for item in changes
+        ),
+    )
+    return InitializationPlan(
+        request=request,
+        templates=selected,
+        capture=captured,
+        profile_bytes=profile_bytes,
+        directories=directories,
+        mutation=mutation,
+    )
+
+
+def plan_initialization(
+    request: InitializationRequest,
+    *,
+    io: InitializationIO,
+    templates: InitializationTemplates | None = None,
+) -> InitializationPlan:
+    """Expose typed existing-input conflicts without allowing any preflight writes."""
+    path = str(request.artifact_paths()["profile"])
+    try:
+        return _plan_initialization(request, io=io, templates=templates)
+    except PathPolicyError as error:
+        raise InitializationConflict(error.path, str(error)) from error
+    except (ProfileError, MutationError) as error:
+        raise InitializationConflict(
+            path, str(error), findings=error.findings
+        ) from error
+
+
+def _outputs(plan: InitializationPlan) -> tuple[InitializationOutput, ...]:
+    """
+    Project deterministic intended dispositions from physical absence, not virtual
+    flags.
+    """
+    physical = dict(plan.capture.physical_metadata)
+    profile = plan.capture.proposal_base.snapshot.profile
+    directories = set(plan.directories)
+    # Keep intermediate parents visible in dry-run and partial-effect reports.
+    for path in (
+        *plan.directories,
+        profile.artifacts["profile"],
+        *(write.change.path for write in plan.mutation.writes),
+    ):
+        parts = path.split("/")
+        directories.update("/".join(parts[:index]) for index in range(1, len(parts)))
+    outputs = [
+        InitializationOutput(
+            path=profile.artifacts["profile"],
+            kind="domain-profile",
+            status="planned" if plan.capture.profile_missing else "skipped",
+            sha256=sha256(plan.profile_bytes).hexdigest(),
+        )
+    ]
+    # Synthetic directory existence never changes a physical planned disposition.
+    outputs.extend(
+        InitializationOutput(
+            path=path,
+            kind="directory",
+            status="planned" if physical[path].kind == "missing" else "skipped",
+        )
+        for path in sorted(directories)
+    )
+    # Ordinary artifact dispositions come from the accepted mutation projection.
+    outputs.extend(
+        InitializationOutput(
+            path=write.change.path,
+            kind=write.change.artifact_kind,
+            status="skipped" if write.skipped else "planned",
+            sha256=sha256(write.change.content).hexdigest(),
+        )
+        for write in plan.mutation.writes
+    )
+    return tuple(sorted(outputs, key=lambda item: item.path))
+
+
+def commit_initialization(
+    plan: InitializationPlan,
+    *,
+    io: InitializationIO,
+    dry_run: bool = False,
+    force: bool = False,
+) -> InitializationResult:
+    """
+    Recheck physical inputs, bootstrap root paths, then use accepted artifact
+    mutations.
+
+    Dry-run performs no directory, file, activation, receipt or revocation writes.
+    force is a deprecated compatibility argument and never permits replacement.
+    """
+    notes = (
+        ("force is deprecated; initialization preserves existing valid content.",)
+        if force
+        else ()
+    )
+    outputs = _outputs(plan)
+    revoked = False
+    try:
+        rebuilt = plan_initialization(plan.request, io=io, templates=plan.templates)
+        plan.capture.require_same(rebuilt.capture)
+        if (
+            plan.profile_bytes != rebuilt.profile_bytes
+            or plan.directories != rebuilt.directories
+            or plan.mutation != rebuilt.mutation
+        ):
+            raise ValueError(
+                "Initialization plan differs from its validated reconstruction"
+            )
+        if dry_run:
+            return InitializationResult(
+                ok=True,
+                outputs=outputs,
+                validation=plan.mutation.validation,
+                authority_invalidated=False,
+                notes=notes,
+            )
+        bootstrap = io.bootstrap(
+            plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
+        )
+        revoked = bootstrap.authority_invalidated
+        # Bootstrap effects remain visible even when a later stage fails.
+        outputs = tuple(
+            InitializationOutput(
+                path=item.path,
+                kind=item.kind,
+                status=(
+                    "created"
+                    if item.path in bootstrap.created
+                    else "conflict" if item.path in bootstrap.conflicts else item.status
+                ),
+                sha256=item.sha256,
+            )
+            for item in outputs
+        )
+        if not bootstrap.ok:
+            return InitializationResult(
+                ok=False,
+                outputs=outputs,
+                validation=plan.mutation.validation,
+                authority_invalidated=revoked,
+                uncertain_paths=bootstrap.uncertain,
+                error=bootstrap.error,
+                notes=notes,
+            )
+        profile_path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
+        physical = io.physical_capture(profile_path)
+        if (
+            physical != bootstrap.physical
+            or physical.snapshot.sha256 != plan.capture.proposal_base.snapshot.sha256
+        ):
+            raise OSError(
+                "Physical bootstrap inputs differ from the validated proposal"
+            )
+        current = plan_mutation(
+            physical,
+            tuple(write.change for write in plan.mutation.writes),
+            grants=plan.mutation.grants,
+        )
+        if current.prospective.sha256 != plan.mutation.prospective.sha256:
+            raise OSError("Physical creation graph differs from the validated proposal")
+        result = commit_mutation(
+            current,
+            writer=GuardedMutationWriter(
+                capture=lambda: io.physical_capture(profile_path),
+                invalidate_authority=io.invalidate_authority,
+                primitives=io.primitives,
+            ),
+        )
+        # Report only parents implied by confirmed ordinary artifact creation.
+        statuses = {item.path: item.status for item in result.artifacts}
+        # Successful children prove creation of their previously absent parents.
+        created_parents = {
+            item.path
+            for item in outputs
+            if item.kind == "directory"
+            and item.status == "planned"
+            and any(
+                output.status == "created" and output.path.startswith(item.path + "/")
+                for output in result.artifacts
+            )
+        }
+        # Merge exact file outcomes without upgrading unperformed planned writes.
+        outputs = tuple(
+            InitializationOutput(
+                path=item.path,
+                kind=item.kind,
+                status=(
+                    "created"
+                    if statuses.get(item.path) == "created"
+                    or item.path in created_parents
+                    else (
+                        "conflict"
+                        if statuses.get(item.path) == "conflict"
+                        else item.status
+                    )
+                ),
+                sha256=item.sha256,
+            )
+            for item in outputs
+        )
+        return InitializationResult(
+            ok=result.ok,
+            outputs=outputs,
+            validation=result.validation,
+            authority_invalidated=revoked or result.authority_invalidated,
+            uncertain_paths=result.uncertain_paths,
+            error="; ".join(finding.message for finding in result.findings) or None,
+            notes=notes,
+        )
+    except (OSError, ValueError) as error:
+        if isinstance(error, InitializationConflict):
+            # Typed conflicts retain their exact paths through the result adapter.
+            conflicts = {item.path for item in error.outputs}
+            # Preserve all unaffected dispositions when a freshness check fails.
+            outputs = tuple(
+                InitializationOutput(
+                    path=item.path,
+                    kind=item.kind,
+                    status="conflict" if item.path in conflicts else item.status,
+                    sha256=item.sha256,
+                )
+                for item in outputs
+            )
+        if not dry_run and not revoked:
+            try:
+                io.invalidate_authority()
+                revoked = True
+            except OSError as invalidation_error:
+                error = OSError(
+                    f"{error}; authority invalidation failed: {invalidation_error}"
+                )
+        return InitializationResult(
+            ok=False,
+            outputs=outputs,
+            validation=plan.mutation.validation,
+            authority_invalidated=revoked,
+            error=str(error),
+            notes=notes,
+        )
+
+
+def initialize_workspace(
+    request: InitializationRequest,
+    *,
+    io: InitializationIO,
+    templates: InitializationTemplates | None = None,
+    dry_run: bool = False,
+    force: bool = False,
+) -> InitializationResult:
+    """
+    Provide the typed root entrypoint; invalid existing content fails before writes.
+    """
+    plan = plan_initialization(request, io=io, templates=templates)
+    return commit_initialization(plan, io=io, dry_run=dry_run, force=force)
+
+
+def validate_template_set(template_root: Path, fs: FileSystem) -> None:
+    """
+    Preserve the legacy helper's complete missing-template diagnostics without writes.
+    """
+    # Report every missing legacy template in one actionable diagnostic.
+    missing = (
+        [str(template_root)]
+        if not fs.exists(template_root)
+        else [
+            str(path)
+            for path in EXPECTED_TEMPLATE_RELATIVE_PATHS
+            if not fs.exists(template_root / path)
+        ]
+    )
+    if missing:
+        raise FileNotFoundError(
+            "Missing required discovery template path(s): " + ", ".join(missing)
+        )
+
+
+def validate_target_path(target_dir: Path, fs: FileSystem, *, force: bool) -> None:
+    """Preserve path-type diagnostics; a nonempty directory alone is not a conflict."""
+    del force
+    if not fs.exists(target_dir.parent):
+        raise FileNotFoundError(
+            f"Target directory's parent does not exist: {target_dir.parent}"
+        )
+    if fs.exists(target_dir) and not fs.is_dir(target_dir):
+        raise NotADirectoryError(
+            f"Target path exists and is not a directory: {target_dir}"
+        )
+
+
+def substitute_placeholders(text: str, tokens: Mapping[str, str] | None = None) -> str:
+    """
+    Retain the legacy literal substitution helper, separate from typed v2 rendering.
+    """
+    # Legacy callers rely on literal token substitution with no parsing semantics.
+    for token, value in (tokens or {}).items():
+        text = text.replace(token, value)
+    return text
+
+
+def create_discovery_workspace(
+    target_dir: Path,
+    template_root: Path,
+    fs: FileSystem,
+    *,
+    force: bool = False,
+) -> None:
+    """Reject unsafe legacy writes with actionable v2 migration instructions.
+
+    Import/helper/template-error compatibility remains. FileSystem.write_text
+    cannot prove exclusive creation or native authority, and force cannot fix it.
+    """
+    validate_template_set(template_root, fs)
+    validate_target_path(target_dir, fs, force=force)
+    raise ValueError(
+        "Legacy initialization lacks explicit v2 identity/configuration "
+        "and trusted writes. Use initialize_workspace(InitializationRequest(...), "
+        "io=InitializationIO.local(...)) with system ID/name, repository ID, "
+        "role and source roots or explicit draft_configuration. "
+        "force never permits overwriting existing content."
+    )
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/init_io.py b/packages/discovery-runtime/src/drm_copilot_discovery/init_io.py
new file mode 100644
index 0000000000000000000000000000000000000000..a47d5ac41e8e16beae0bd77e9fe889ae2202d6d6
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/init_io.py
@@ -0,0 +1,401 @@
+"""Compose root-owned initialization over the accepted native mutation primitives.
+
+Virtual profile/directory metadata is used only to validate a proposal. Physical
+captures retain actual absence and identities for guarded freshness checks. This
+boundary serializes cooperating writers; it is not a multi-file transaction or
+an authorization mechanism for clients that can bypass native tool restrictions.
+"""
+
+from __future__ import annotations
+
+from contextlib import ExitStack
+from dataclasses import dataclass, replace
+from pathlib import Path
+from typing import TYPE_CHECKING
+
+from drm_copilot_discovery.init_projection import (
+    InitializationCapture,
+    InitializationConflict,
+    ProposalInputs,
+)
+from drm_copilot_discovery.mutation_filesystem import (
+    LocalMutationPrimitives,
+    open_local_directory,
+)
+from drm_copilot_discovery.mutation_io import capture_workspace
+from drm_copilot_discovery.path_models import WriteGrant
+from drm_copilot_discovery.path_policy import FILE_KEYS, PathPolicy
+
+if TYPE_CHECKING:
+    from collections.abc import Callable
+    from contextlib import AbstractContextManager
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_filesystem import Directory
+    from drm_copilot_discovery.mutation_io import MutationPrimitives
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+    from drm_copilot_discovery.path_models import PathMetadataReader, ResolvedPath
+    from drm_copilot_discovery.repository_reader import RepositoryReader
+    from drm_copilot_discovery.snapshot_io import WorkspaceBytes
+
+
+@dataclass(frozen=True, kw_only=True)
+class BootstrapResult:
+    """
+    Report exact completed paths and bounded uncertainty without claiming authority.
+    """
+
+    ok: bool
+    created: tuple[str, ...]
+    uncertain: tuple[str, ...]
+    authority_invalidated: bool
+    error: str | None = None
+    physical: CapturedWorkspace | None = None
+    conflicts: tuple[str, ...] = ()
+
+
+class InitializationIO:
+    """
+    Bind trusted native readers, guard and directory handles before processing inputs.
+
+    A host must authenticate root and bind these capabilities independently of
+    request data. Legacy FileSystem objects are deliberately not accepted here.
+    Unit tests supply memory implementations of the same narrow primitives.
+    """
+
+    def __init__(
+        self,
+        *,
+        workspace_root: str,
+        catalog: SchemaCatalog,
+        metadata: PathMetadataReader,
+        read_bytes: WorkspaceBytes,
+        primitives: MutationPrimitives,
+        open_directory: Callable[[], AbstractContextManager[Directory]],
+        invalidate_authority: Callable[[], None],
+        repository: RepositoryReader | None = None,
+    ) -> None:
+        """Store trusted collaborators without granting authority or performing I/O."""
+        self.workspace_root, self.catalog = workspace_root, catalog
+        self.metadata, self.read_bytes = metadata, read_bytes
+        self.primitives, self.open_directory = primitives, open_directory
+        self.invalidate_authority, self.repository = invalidate_authority, repository
+
+    @classmethod
+    def local(
+        cls,
+        *,
+        workspace_root: str,
+        lock_path: str,
+        catalog: SchemaCatalog,
+        invalidate_authority: Callable[[], None],
+        repository: RepositoryReader | None = None,
+    ) -> InitializationIO:
+        """Wire the accepted Windows/POSIX provider and externally provisioned lock."""
+        primitives = LocalMutationPrimitives(
+            workspace_root=workspace_root, lock_path=lock_path
+        )
+        return cls(
+            workspace_root=workspace_root,
+            catalog=catalog,
+            metadata=primitives.metadata,
+            read_bytes=primitives.read_bytes,
+            primitives=primitives,
+            open_directory=lambda: open_local_directory(Path(workspace_root)),
+            invalidate_authority=invalidate_authority,
+            repository=repository,
+        )
+
+    def capture(
+        self,
+        *,
+        profile_path: str,
+        profile_bytes: bytes,
+        directories: tuple[str, ...] = (),
+    ) -> InitializationCapture:
+        """
+        Load a complete proposal and separately freeze actual bytes and identities.
+        """
+        inputs = ProposalInputs(self, profile_path, profile_bytes, directories)
+        proposal = capture_workspace(
+            workspace_root=self.workspace_root,
+            profile_path=profile_path,
+            metadata=inputs.inspect,
+            read_bytes=inputs.read,
+            catalog=self.catalog,
+            repository=self.available_repository(),
+        )
+        # Recheck physical inputs after the virtual loader's own consistency checks.
+        for path in tuple(inputs.metadata):
+            inputs.physical(path)
+        # A successful virtual load cannot conceal a later physical byte change.
+        for path, content in tuple(inputs.files.items()):
+            if self.read_bytes(path, limit=max(1, len(content))) != content:
+                raise OSError("Initialization bytes changed after capture")
+        return InitializationCapture(
+            proposal_base=proposal,
+            physical_metadata=tuple(sorted(inputs.metadata.items())),
+            physical_files=tuple(sorted(inputs.files.items())),
+            profile_missing=inputs.profile_missing,
+        )
+
+    def physical_capture(self, profile_path: str) -> CapturedWorkspace:
+        """
+        Read only actual inputs after bootstrap; no proposal can reach mutation commit.
+        """
+        return capture_workspace(
+            workspace_root=self.workspace_root,
+            profile_path=profile_path,
+            metadata=self.metadata,
+            read_bytes=self.read_bytes,
+            catalog=self.catalog,
+            repository=self.available_repository(),
+        )
+
+    def available_repository(self) -> RepositoryReader | None:
+        """Treat unavailable local Git as absent; never infer or fetch a revision."""
+        if self.repository is not None:
+            try:
+                self.repository.identity()
+            except OSError:
+                return None
+        return self.repository
+
+    def _directory(
+        self,
+        target: ResolvedPath,
+        anchors: ExitStack,
+        created: list[str],
+        opened: dict[str, str],
+        *,
+        parents_only: bool = False,
+    ) -> None:
+        """
+        Exclusively create missing directories and pin checked identities through
+        postcheck.
+        """
+        directory = anchors.enter_context(self.open_directory())
+        if directory.identity() != target.observations[0].identity:
+            raise OSError("Opened initialization workspace identity changed")
+        opened["."] = directory.identity()
+        stamps = target.observations[1:-1] if parents_only else target.observations[1:]
+        # Retain each opened ancestor so publication cannot adopt a changed parent.
+        for stamp in stamps:
+            current = self.metadata(stamp.path)
+            if (current.kind, current.identity, current.resolved_path) != (
+                stamp.kind,
+                stamp.identity,
+                stamp.resolved_path,
+            ):
+                raise OSError("Initialization parent changed before directory creation")
+            directory = anchors.enter_context(
+                directory.child(
+                    stamp.path.split("/")[-1], create=stamp.kind == "missing"
+                )
+            )
+            if stamp.kind != "missing" and directory.identity() != stamp.identity:
+                raise OSError("Opened initialization directory identity changed")
+            identity = directory.identity()
+            if opened.setdefault(stamp.path, identity) != identity:
+                raise OSError("Retained initialization directory identity changed")
+            if stamp.kind == "missing":
+                created.append(stamp.path)
+
+    def bootstrap(
+        self,
+        expected: InitializationCapture,
+        *,
+        profile_bytes: bytes,
+        directories: tuple[str, ...],
+    ) -> BootstrapResult:
+        """
+        Publish only the root profile and configured empty directories under one guard.
+
+        Every ordinary artifact is published later by the accepted mutation engine.
+        A partial failure retains completed paths, revokes authority and never rolls
+        back over a concurrent writer. Synthetic identities are never native stamps.
+        """
+        profile = expected.proposal_base.snapshot.profile
+        profile_path = profile.artifacts["profile"]
+        if profile_bytes != expected.proposal_base.snapshot.file(profile_path).content:
+            raise ValueError(
+                "Bootstrap profile bytes differ from the validated proposal"
+            )
+        # Bootstrap accepts exactly the configured directory categories.
+        allowed = tuple(
+            sorted(
+                str(value)
+                for key, value in profile.artifacts.data.items()
+                if key not in FILE_KEYS
+            )
+        )
+        if tuple(sorted(directories)) != allowed:
+            raise ValueError(
+                "Bootstrap directories must exactly match configured "
+                "artifact directories"
+            )
+        created: list[str] = []
+        opened: dict[str, str] = {}
+        active_path: str | None = None
+        uncertain: tuple[str, ...] = ()
+        revoked = False
+        try:
+            with self.primitives.guard(), ExitStack() as anchors:
+                expected.require_same(
+                    self.capture(
+                        profile_path=profile_path,
+                        profile_bytes=profile_bytes,
+                        directories=directories,
+                    )
+                )
+                policy = PathPolicy(
+                    profile, workspace_root=self.workspace_root, metadata=self.metadata
+                )
+                policy.validate_configuration()
+                needs_write = expected.profile_missing or any(
+                    self.metadata(path).kind == "missing" for path in directories
+                )
+                if needs_write:
+                    self.invalidate_authority()
+                    revoked = True
+                    expected.require_same(
+                        self.capture(
+                            profile_path=profile_path,
+                            profile_bytes=profile_bytes,
+                            directories=directories,
+                        )
+                    )
+                if expected.profile_missing:
+                    target = policy.resolve_read(profile_path, allow_missing=True)
+                    if target.observations[-1].kind != "missing":
+                        raise FileExistsError("The proposed profile now exists; reload")
+                    # A failure may leave only these previously absent ancestors.
+                    uncertain = tuple(
+                        stamp.path
+                        for stamp in target.observations
+                        if stamp.kind == "missing"
+                    )
+                    active_path = profile_path
+                    self._directory(target, anchors, created, opened, parents_only=True)
+                    target = policy.resolve_read(profile_path, allow_missing=True)
+                    uncertain = (profile_path,)
+                    # Root-only profile publication is separate from analyst output
+                    # grants.
+                    target = replace(
+                        target,
+                        grant=WriteGrant(
+                            artifact_kind="domain-profile",
+                            artifact_id=profile.id,
+                            path=profile_path,
+                        ),
+                    )
+                    self.primitives.create_exclusive(target, profile_bytes)
+                    created.append(profile_path)
+                    uncertain = ()
+                # Empty configured directories are effects even without file output.
+                for path in directories:
+                    active_path = path
+                    target = policy.resolve_read(path, allow_missing=True)
+                    # Bound partial uncertainty to the currently attempted route.
+                    uncertain = tuple(
+                        stamp.path
+                        for stamp in target.observations
+                        if stamp.kind == "missing"
+                    )
+                    self._directory(target, anchors, created, opened)
+                    uncertain = ()
+                current = self.capture(
+                    profile_path=profile_path,
+                    profile_bytes=profile_bytes,
+                    directories=directories,
+                )
+                self._after_bootstrap(expected, current, created, profile_bytes, opened)
+            return BootstrapResult(
+                ok=True,
+                created=tuple(sorted(created)),
+                uncertain=(),
+                authority_invalidated=revoked,
+                physical=current.proposal_base,
+            )
+        except (OSError, ValueError) as error:
+            if not revoked:
+                try:
+                    self.invalidate_authority()
+                    revoked = True
+                except OSError as invalidation_error:
+                    error = OSError(
+                        f"{error}; authority invalidation failed: {invalidation_error}"
+                    )
+            return BootstrapResult(
+                ok=False,
+                created=tuple(sorted(set(created))),
+                uncertain=uncertain,
+                authority_invalidated=revoked,
+                error=str(error),
+                conflicts=(
+                    tuple(item.path for item in error.outputs)
+                    if isinstance(error, InitializationConflict)
+                    else (active_path,) if active_path is not None else ()
+                ),
+            )
+
+    def _after_bootstrap(
+        self,
+        before: InitializationCapture,
+        after: InitializationCapture,
+        created: list[str],
+        profile_bytes: bytes,
+        opened: dict[str, str],
+    ) -> None:
+        """
+        Allow exactly new configured directories/profile while preserving prior inputs.
+        """
+        files = dict(before.physical_files)
+        profile_path = before.proposal_base.snapshot.profile.artifacts["profile"]
+        if before.profile_missing:
+            files[profile_path] = profile_bytes
+        if (
+            files != dict(after.physical_files)
+            or before.proposal_base.snapshot.sha256
+            != after.proposal_base.snapshot.sha256
+        ):
+            raise OSError("Initialization bootstrap changed unexpected input bytes")
+        actual = dict(after.physical_metadata)
+        if after.profile_missing or any(
+            path not in actual
+            or actual[path].kind != "directory"
+            or actual[path].identity != identity
+            for path, identity in opened.items()
+        ):
+            raise OSError(
+                "Opened initialization directory identity changed after creation"
+            )
+        # Only explicitly created paths and their parent child lists may change.
+        for path, old in before.physical_metadata:
+            new = actual.get(path)
+            if new is None:
+                raise OSError("Initialization lost a previously observed input path")
+            if path in created:
+                if old.kind != "missing" or new.kind != (
+                    "file" if path == profile_path else "directory"
+                ):
+                    raise OSError("Initialization created an unexpected path kind")
+                continue
+            prefix = "" if path == "." else path + "/"
+            # Admit only names introduced by the recorded bootstrap effects.
+            children = set(old.children) | {
+                item[len(prefix) :].split("/")[0]
+                for item in created
+                if item.startswith(prefix) and item != path
+            }
+            if (
+                replace(
+                    old,
+                    children=tuple(sorted(children)) if old.kind == "directory" else (),
+                )
+                != new
+            ):
+                raise OSError(
+                    "Initialization changed an unrelated filesystem "
+                    "identity or namespace"
+                )
diff --git a/packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py b/packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py
new file mode 100644
index 0000000000000000000000000000000000000000..531991f151e4227f5d3f0ddbabc653919225812c
--- /dev/null
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py
@@ -0,0 +1,466 @@
+"""Render caller-owned draft inputs without treating templates as observations."""
+
+from __future__ import annotations
+
+from dataclasses import dataclass, replace
+from pathlib import PurePosixPath, PureWindowsPath
+from typing import TYPE_CHECKING, Literal, cast
+
+from drm_copilot_discovery.findings import Finding
+from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
+from drm_copilot_discovery.parsing import parse_document
+from drm_copilot_discovery.path_models import (
+    PathMetadata,
+    check_path_collisions,
+    relative_path,
+)
+from drm_copilot_discovery.profile_v2 import ProfileV2
+from drm_copilot_discovery.repository_reader import RepositoryIdentity
+from drm_copilot_discovery.resources import read_resource
+from drm_copilot_discovery.snapshot import repository_pins
+
+if TYPE_CHECKING:
+    from collections.abc import Callable, Mapping
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.init_io import InitializationIO
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+    from drm_copilot_discovery.profile_models import ArtifactKey
+    from drm_copilot_discovery.validation import SnapshotValidation
+
+TEMPLATE_ROOT = "docs/discovery/templates/v2"
+TEMPLATE_NAMES = (
+    "domain-profile.yaml",
+    "scope.yaml",
+    "coverage-ledger.json",
+    "unspecified-behaviors.yaml",
+    "product-decisions.yaml",
+    "parity-matrix.json",
+)
+ARTIFACT_TEMPLATES: tuple[tuple[ArtifactKey, str, str], ...] = (
+    ("scope", "scope", "scope.yaml"),
+    ("coverage_ledger", "coverage-ledger", "coverage-ledger.json"),
+    (
+        "unspecified_behaviors",
+        "unspecified-behavior-collection",
+        "unspecified-behaviors.yaml",
+    ),
+    ("product_decisions", "product-decision-collection", "product-decisions.yaml"),
+    ("parity_matrix", "parity-matrix", "parity-matrix.json"),
+)
+_DIRECTORIES = (
+    "feature_contracts",
+    "characterization",
+    "evidence",
+    "inventory",
+    "acceptance",
+    "reports",
+    "source_snapshots",
+    "implementation_records",
+)
+
+
+@dataclass(frozen=True, kw_only=True)
+class InitializationRequest:
+    """Require explicit consumer identity and roots or an explicit unconfigured draft.
+
+    These values are configuration, not a native principal or a write capability.
+    Existing compatible profile bytes remain authoritative for optional settings.
+    """
+
+    system_id: str
+    system_name: str
+    role: Literal["legacy-source", "modernization-target", "combined"]
+    repository_id: str
+    production_roots: tuple[str, ...] = ()
+    draft_configuration: bool = False
+    test_roots: tuple[str, ...] = ()
+    documentation_roots: tuple[str, ...] = ()
+    artifact_root: str = "docs/migration/discovery"
+    artifact_overrides: tuple[tuple[ArtifactKey, str], ...] = ()
+
+    def __post_init__(self) -> None:
+        """Reject ambiguous identities, roots and duplicate overrides before reads."""
+        RepositoryIdentity(id=self.system_id, revision=None)
+        RepositoryIdentity(id=self.repository_id, revision=None)
+        if not self.system_name.strip() or self.role not in {
+            "legacy-source",
+            "modernization-target",
+            "combined",
+        }:
+            raise ValueError("Initialization requires a system name and explicit role")
+        if not self.production_roots and not self.draft_configuration:
+            raise ValueError(
+                "Supply source roots or explicitly select draft_configuration"
+            )
+        relative_path(self.artifact_root)
+        # Normalize each caller-owned root group before profile rendering.
+        for name in ("production_roots", "test_roots", "documentation_roots"):
+            object.__setattr__(self, name, check_path_collisions(getattr(self, name)))
+        overrides = tuple(sorted(self.artifact_overrides))
+        if len(dict(overrides)) != len(overrides):
+            raise ValueError("Artifact overrides require unique keys")
+        # Reject unsafe spellings before any override can become a destination.
+        for _, path in overrides:
+            relative_path(path)
+        object.__setattr__(self, "artifact_overrides", overrides)
+
+    def artifact_paths(self) -> JsonObject:
+        """Project destinations; ProfileV2 remains responsible for semantic checks."""
+        # Derive the closed template and directory destinations from one root.
+        paths: dict[str, JsonValue] = {
+            "root": self.artifact_root,
+            "profile": self.artifact_root + "/domain-profile.yaml",
+            **{
+                key: self.artifact_root + "/" + name
+                for key, _, name in ARTIFACT_TEMPLATES
+            },
+            **{
+                key: self.artifact_root + "/" + key.replace("_", "-")
+                for key in _DIRECTORIES
+            },
+        }
+        # Explicit overrides may select named destinations but cannot add kinds.
+        for key, value in self.artifact_overrides:
+            if key not in paths or key == "root":
+                raise ValueError(
+                    "Override only named artifact paths; use artifact_root for root"
+                )
+            paths[key] = value
+        return JsonObject(tuple(paths.items()))
+
+
+@dataclass(frozen=True, kw_only=True)
+class InitializationTemplates:
+    """Retain six parsed immutable production templates with typed value slots."""
+
+    documents: tuple[tuple[str, JsonObject], ...]
+
+    def __post_init__(self) -> None:
+        """Require the complete exact template set without accepting duplicate names."""
+        documents = tuple(sorted(self.documents))
+        if tuple(name for name, _ in documents) != tuple(sorted(TEMPLATE_NAMES)):
+            raise ValueError("Initialization requires all six distinct v2 templates")
+        object.__setattr__(self, "documents", documents)
+
+    @classmethod
+    def load(
+        cls, *, read: Callable[[str], bytes] = read_resource
+    ) -> InitializationTemplates:
+        """Read declared package resources through an injectable bounded parser seam."""
+        documents: list[tuple[str, JsonObject]] = []
+        # Parse the complete declared set before any draft is rendered.
+        for name in TEMPLATE_NAMES:
+            parsed = parse_document(read(TEMPLATE_ROOT + "/" + name), format="yaml")
+            if parsed.value is None:
+                raise ValueError(f"Invalid initialization template: {name}")
+            documents.append((name, parsed.value))
+        return cls(documents=tuple(documents))
+
+    def render(self, name: str, values: Mapping[str, JsonValue]) -> bytes:
+        """Substitute complete typed slots, so quotes/newlines remain ordinary data."""
+
+        def substitute(value: JsonValue) -> JsonValue:
+            """Recursively retain structure and reject missing named template values."""
+            # Recurse through structures; only complete string slots substitute.
+            if isinstance(value, JsonObject):
+                # Preserve member names while replacing their typed child values.
+                return JsonObject(
+                    tuple((key, substitute(child)) for key, child in value.members)
+                )
+            if isinstance(value, tuple):
+                # Array order remains the template's declared order.
+                return tuple(substitute(child) for child in value)
+            if (
+                isinstance(value, str)
+                and value.startswith("{{")
+                and value.endswith("}}")
+            ):
+                key = value[2:-2]
+                if key not in values:
+                    raise ValueError(f"Missing initialization template value: {key}")
+                return values[key]
+            return value
+
+        return canonical_json(substitute(dict(self.documents)[name]))
+
+
+def profile_proposal(
+    request: InitializationRequest,
+    *,
+    templates: InitializationTemplates,
+    catalog: SchemaCatalog,
+    revision: str | None,
+) -> bytes:
+    """Render a draft whose only repository pin is an explicitly observed local one."""
+    RepositoryIdentity(id=request.repository_id, revision=revision)
+    paths = request.artifact_paths()
+    content = templates.render(
+        "domain-profile.yaml",
+        {
+            "profile_id": "profile-" + request.system_id,
+            "system_id": request.system_id,
+            "system_name": request.system_name,
+            "role": request.role,
+            "repository_id": request.repository_id,
+            "revision": revision,
+            "production_roots": request.production_roots,
+            "test_roots": request.test_roots,
+            "documentation_roots": request.documentation_roots
+            or (request.artifact_root,),
+            "evidence_roots": (paths["evidence"],),
+            "artifacts": paths,
+        },
+    )
+    profile = ProfileV2(content, catalog=catalog)
+    if profile.profile_state != "draft":
+        raise ValueError(
+            "Initialization templates must produce an honest draft profile"
+        )
+    return content
+
+
+def require_compatible(request: InitializationRequest, profile: ProfileV2) -> None:
+    """Preserve settings only when identity and explicit requested roots agree."""
+    paths = request.artifact_paths()
+    identity = (
+        profile.system.id,
+        profile.system.name,
+        profile.system.role,
+        profile.repository.id,
+    )
+    expected = (
+        request.system_id,
+        request.system_name,
+        request.role,
+        request.repository_id,
+    )
+    if (
+        identity != expected
+        or tuple(sorted(profile.production_roots)) != request.production_roots
+    ):
+        raise InitializationConflict(
+            profile.artifacts["profile"],
+            "Existing profile conflicts with requested identity or source roots",
+        )
+    if request.test_roots and tuple(sorted(profile.test_roots)) != request.test_roots:
+        raise InitializationConflict(
+            profile.artifacts["profile"],
+            "Existing profile conflicts with requested test roots",
+        )
+    if (
+        request.documentation_roots
+        and tuple(sorted(profile.documentation_roots)) != request.documentation_roots
+    ):
+        raise InitializationConflict(
+            profile.artifacts["profile"],
+            "Existing profile conflicts with requested documentation roots",
+        )
+    # Preserve unspecified profile settings while honoring explicit destinations.
+    for key in ("root", "profile", *(key for key, _ in request.artifact_overrides)):
+        if profile.artifacts[cast("ArtifactKey", key)] != paths[key]:
+            raise InitializationConflict(
+                profile.artifacts["profile"],
+                f"Existing profile conflicts with requested artifact path: {key}",
+            )
+
+
+def artifact_values(profile: ProfileV2, *, scope_id: str) -> dict[str, JsonValue]:
+    """Populate empty draft collections from the effective consumer profile only."""
+    source, target = repository_pins(profile)
+    return {
+        "system_id": profile.system.id,
+        "repository_id": profile.repository.id,
+        "revision": profile.repository.revision,
+        "production_roots": profile.production_roots,
+        "required_modes": profile.required_modes,
+        "scope_id": scope_id,
+        "ledger_id": "ledger-" + profile.system.id,
+        "unresolved_id": "unresolved-" + profile.system.id,
+        "decisions_id": "decisions-" + profile.system.id,
+        "parity_id": "parity-" + profile.system.id,
+        # Role selection determines which honest pins belong to each side.
+        "source_repositories": tuple(
+            JsonObject(tuple(pin.to_dict().items())) for pin in source
+        ),
+        # Target pins remain null when local identity has no observed revision.
+        "target_repositories": tuple(
+            JsonObject(tuple(pin.to_dict().items())) for pin in target
+        ),
+    }
+
+
+@dataclass(frozen=True, kw_only=True)
+class InitializationCapture:
+    """Separate a validation-only proposal from exact observed physical inputs."""
+
+    proposal_base: CapturedWorkspace
+    physical_metadata: tuple[tuple[str, PathMetadata], ...]
+    physical_files: tuple[tuple[str, bytes], ...]
+    profile_missing: bool
+
+    def require_same(self, other: InitializationCapture) -> None:
+        """
+        Reject any changed byte, checkout, namespace, absence or physical identity.
+        """
+        if (
+            self.physical_metadata != other.physical_metadata
+            or self.physical_files != other.physical_files
+            or self.proposal_base.snapshot.sha256 != other.proposal_base.snapshot.sha256
+            or self.proposal_base.workspace_root != other.proposal_base.workspace_root
+            or self.profile_missing != other.profile_missing
+        ):
+            before, after = dict(self.physical_metadata), dict(other.physical_metadata)
+            # Prefer concrete changed paths in the typed conflict response.
+            paths = sorted(
+                path
+                for path in before.keys() | after.keys()
+                if path != "." and before.get(path) != after.get(path)
+            )
+            raise InitializationConflict(
+                (
+                    paths[0]
+                    if paths
+                    else self.proposal_base.snapshot.profile.artifacts["profile"]
+                ),
+                "Initialization inputs changed; reload the complete proposal",
+            )
+
+
+class ProposalInputs:
+    """Overlay explicit proposals while separately recording every actual inspection."""
+
+    def __init__(
+        self,
+        owner: InitializationIO,
+        profile_path: str,
+        profile_bytes: bytes,
+        directories: tuple[str, ...],
+    ) -> None:
+        """Retain one transient overlay; never reuse it for another capture."""
+        self.owner, self.profile_path, self.profile_bytes = (
+            owner,
+            profile_path,
+            profile_bytes,
+        )
+        self.metadata: dict[str, PathMetadata] = {}
+        self.files: dict[str, bytes] = {}
+        self.profile_missing = self.physical(profile_path).kind == "missing"
+        self.directories: set[str] = set()
+        # Include only ancestors of proposed outputs, never invent source inputs.
+        for path in (*directories, profile_path if self.profile_missing else ""):
+            if path:
+                parts = relative_path(path).split("/")
+                count = len(parts) - (path == profile_path)
+                self.directories.update(
+                    "/".join(parts[:index]) for index in range(1, count + 1)
+                )
+
+    def physical(self, path: str) -> PathMetadata:
+        """Record exact stable observations before adding any virtual children."""
+        value = self.owner.metadata(path)
+        value = replace(value, children=tuple(sorted(value.children)))
+        if self.metadata.setdefault(path, value) != value:
+            raise OSError("Initialization metadata changed during capture")
+        return value
+
+    def inspect(self, path: str) -> PathMetadata:
+        """Expose virtual entries only where the physical reader proved absence."""
+        value = self.physical(path)
+        virtual_file = self.profile_missing and path == self.profile_path
+        if value.kind == "missing" and (path in self.directories or virtual_file):
+            root = (
+                PureWindowsPath(self.owner.workspace_root)
+                if ":" in self.owner.workspace_root
+                or self.owner.workspace_root.startswith("\\\\")
+                else PurePosixPath(self.owner.workspace_root)
+            )
+            value = PathMetadata(
+                kind="file" if virtual_file else "directory",
+                identity="initialization-proposal:" + path,
+                resolved_path=root.joinpath(path).as_posix(),
+            )
+        if value.kind == "directory":
+            prefix = "" if path == "." else path + "/"
+            proposed = set(self.directories)
+            if self.profile_missing:
+                proposed.add(self.profile_path)
+            # Add immediate proposed children without inventing source entries.
+            names = {
+                item[len(prefix) :].split("/")[0]
+                for item in proposed
+                if item.startswith(prefix) and item != path
+            }
+            value = replace(value, children=tuple(sorted(set(value.children) | names)))
+        return value
+
+    def read(self, path: str, *, limit: int) -> bytes:
+        """Never record synthetic profile bytes as an observed physical input."""
+        if self.profile_missing and path == self.profile_path:
+            if len(self.profile_bytes) > limit:
+                raise OSError("Proposed profile exceeds the read limit")
+            return self.profile_bytes
+        value = self.owner.read_bytes(path, limit=limit)
+        if self.files.setdefault(path, value) != value:
+            raise OSError("Initialization bytes changed during capture")
+        return value
+
+
+@dataclass(frozen=True, kw_only=True)
+class InitializationOutput:
+    """Describe one file/directory disposition without implying completion authority."""
+
+    path: str
+    kind: str
+    status: Literal["planned", "created", "skipped", "conflict"]
+    sha256: str | None = None
+
+
+@dataclass(frozen=True, kw_only=True)
+class InitializationResult:
+    """
+    Report structural validity and exact partial effects, never a completion receipt.
+    """
+
+    ok: bool
+    outputs: tuple[InitializationOutput, ...]
+    validation: SnapshotValidation
+    authority_invalidated: bool
+    uncertain_paths: tuple[str, ...] = ()
+    error: str | None = None
+    notes: tuple[str, ...] = ()
+
+
+class InitializationConflict(ValueError):
+    """Expose exact conflicting paths and findings without parsing exception prose."""
+
+    def __init__(
+        self,
+        path: str,
+        message: str,
+        *,
+        kind: str = "artifact",
+        findings: tuple[Finding, ...] = (),
+    ) -> None:
+        """Retain a compatible ValueError and deterministic typed conflict outputs."""
+        # Accepted validator paths take precedence over the caller's fallback path.
+        paths = tuple(
+            sorted(
+                {item.artifact_path for item in findings if item.artifact_path}
+                or {path}
+            )
+        )
+        # Stable ordering gives callers deterministic structured conflict output.
+        self.outputs = tuple(
+            InitializationOutput(path=item, kind=kind, status="conflict")
+            for item in paths
+        )
+        self.findings = findings or (
+            Finding(
+                code="INITIALIZATION_CONFLICT",
+                artifact_path=path,
+                message=message,
+                next_action="Correct existing content and reload initialization.",
+            ),
+        )
+        super().__init__(message)
diff --git a/scripts/dev_tools/discovery/init_flow.py b/scripts/dev_tools/discovery/init_flow.py
index 4a43de2ad143d518b6978879315bf02d0345ccbe..e65a6929d1a86e0e9134940fce3301ad010f0861 100644
--- a/scripts/dev_tools/discovery/init_flow.py
+++ b/scripts/dev_tools/discovery/init_flow.py
@@ -1 +1 @@
-"""Pure orchestration for discovery-workspace initialization.
+"""Preserve legacy imports while the installed runtime owns initialization."""
@@ -3,11 +3,5 @@
-Contains no `argparse` or `print` calls, so it is directly unit-testable
-against the injected `FileSystem` protocol.
-"""
-
-from __future__ import annotations
-
-from typing import TYPE_CHECKING
-
-from scripts.dev_tools.discovery.init_models import (
-    EXPECTED_TEMPLATE_RELATIVE_PATHS,
-    OUTPUT_RELATIVE_PATHS,
+from drm_copilot_discovery.init_flow import (
+    create_discovery_workspace,
+    substitute_placeholders,
+    validate_target_path,
+    validate_template_set,
@@ -16,76 +10,6 @@ from scripts.dev_tools.discovery.init_models import (
-if TYPE_CHECKING:
-    from collections.abc import Mapping
-    from pathlib import Path
-
-    from scripts.dev_tools.discovery.init_models import FileSystem
-
-
-def validate_template_set(template_root: Path, fs: FileSystem) -> None:
-    """Raise `FileNotFoundError` naming every missing expected template path."""
-    missing: list[str] = []
-    if not fs.exists(template_root):
-        missing.append(str(template_root))
-    else:
-        for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
-            if not fs.exists(template_root / relative_path):
-                missing.append(str(relative_path))
-
-    if missing:
-        raise FileNotFoundError(
-            "Missing required discovery template path(s): " + ", ".join(missing)
-        )
-
-
-def validate_target_path(target_dir: Path, fs: FileSystem, *, force: bool) -> None:
-    """Raise fail-fast errors for an invalid discovery-workspace target path."""
-    if not fs.exists(target_dir.parent):
-        raise FileNotFoundError(
-            f"Target directory's parent does not exist: {target_dir.parent}"
-        )
-
-    if fs.exists(target_dir):
-        if not fs.is_dir(target_dir):
-            raise NotADirectoryError(
-                f"Target path exists and is not a directory: {target_dir}"
-            )
-        if fs.list_dir(target_dir) and not force:
-            raise FileExistsError(
-                f"Target directory is non-empty: {target_dir}. "
-                "Pass force=True to proceed anyway."
-            )
-
-
-def substitute_placeholders(text: str, tokens: Mapping[str, str] | None = None) -> str:
-    """Replace each token key in `text` with its value via literal `str.replace`."""
-    if not tokens:
-        return text
-    result = text
-    for token, value in tokens.items():
-        result = result.replace(token, value)
-    return result
-
-
-def create_discovery_workspace(
-    target_dir: Path,
-    template_root: Path,
-    fs: FileSystem,
-    *,
-    force: bool = False,
-) -> None:
-    """Scaffold a discovery workspace at `target_dir` from `template_root`.
-
-    Validates the template set and the target path before writing any file, so
-    a partial or otherwise invalid input never produces a partial scaffold.
-    """
-    validate_template_set(template_root, fs)
-    validate_target_path(target_dir, fs, force=force)
-
-    fs.ensure_dir(target_dir)
-    fs.ensure_dir(target_dir / "artifacts")
-
-    for template_relative, output_relative in zip(
-        EXPECTED_TEMPLATE_RELATIVE_PATHS, OUTPUT_RELATIVE_PATHS, strict=True
-    ):
-        template_text = fs.read_text(template_root / template_relative)
-        rendered_text = substitute_placeholders(template_text)
-        fs.write_text(target_dir / output_relative, rendered_text)
+__all__ = [
+    "create_discovery_workspace",
+    "substitute_placeholders",
+    "validate_target_path",
+    "validate_template_set",
+]
diff --git a/tests/discovery_runtime/initialization_test_support.py b/tests/discovery_runtime/initialization_test_support.py
new file mode 100644
index 0000000000000000000000000000000000000000..015a920d9cb37f650c6239a0d158907c7834e556
--- /dev/null
+++ b/tests/discovery_runtime/initialization_test_support.py
@@ -0,0 +1,141 @@
+"""Share immutable templates/catalogs and fresh in-memory initialization boundaries."""
+
+from __future__ import annotations
+
+from dataclasses import replace
+from pathlib import Path
+from typing import TYPE_CHECKING
+
+import pytest
+from drm_copilot_discovery.catalog import load_catalog
+from drm_copilot_discovery.init_flow import plan_initialization
+from drm_copilot_discovery.init_io import InitializationIO
+from drm_copilot_discovery.init_projection import (
+    InitializationCapture,
+    InitializationRequest,
+    InitializationTemplates,
+)
+from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
+
+from tests.discovery_runtime.mutation_test_support import MemoryDisk
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.init_flow import InitializationPlan
+    from drm_copilot_discovery.profile_models import SystemRole
+
+ROOT = Path(__file__).resolve().parents[2]
+
+
+@pytest.fixture(scope="module")
+def initialization_catalog() -> SchemaCatalog:
+    """Reuse only immutable accepted schemas; mutable stores are never shared."""
+    return load_catalog()
+
+
+@pytest.fixture(scope="module")
+def initialization_templates() -> InitializationTemplates:
+    """
+    Load immutable committed fixtures; output operations remain entirely in memory.
+    """
+    return InitializationTemplates.load(read=lambda path: (ROOT / path).read_bytes())
+
+
+def request_for(role: SystemRole = "legacy-source") -> InitializationRequest:
+    """Use explicit synthetic consumer identity and a selected source root."""
+    return InitializationRequest(
+        system_id="consumer-system",
+        system_name="Consumer system",
+        role=role,
+        repository_id="consumer-repository",
+        production_roots=("application",),
+        test_roots=("verification",),
+        documentation_roots=("docs",),
+    )
+
+
+@pytest.fixture(scope="module")
+def initialization_plan(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+) -> InitializationPlan:
+    """Share only an immutable proposal; every behavior test creates a fresh disk."""
+    case = InitializationCase(initialization_catalog)
+    return plan_initialization(
+        request_for(), io=case.io, templates=initialization_templates
+    )
+
+
+def seed_proposal(case: InitializationCase, plan: InitializationPlan) -> None:
+    """Copy immutable projected bytes into a fresh test-owned physical workspace."""
+    # Seed empty configured directories independently of artifact presence.
+    for path in plan.directories:
+        case.disk.store.metadata.add(path, kind="directory")
+    # Copy immutable graph bytes into this invocation's fresh mutable store.
+    for item in plan.mutation.prospective.manifest.files:
+        case.disk.store.put(item.path, item.content)
+
+
+def bootstrap_capture(
+    case: InitializationCase, plan: InitializationPlan
+) -> InitializationCapture:
+    """Bind actual memory metadata to an unchanged immutable profile-only graph."""
+    # Bind current memory identities while reusing only immutable graph values.
+    metadata = tuple(
+        (path, case.disk.store.metadata(path))
+        for path, _ in plan.capture.physical_metadata
+    )
+    return InitializationCapture(
+        proposal_base=replace(plan.capture.proposal_base, metadata=metadata),
+        physical_metadata=metadata,
+        physical_files=tuple(sorted(case.disk.store.files.items())),
+        profile_missing=False,
+    )
+
+
+class InitializationCase:
+    """Keep all mutable memory/native-seam state local to one test invocation."""
+
+    def __init__(self, catalog: SchemaCatalog) -> None:
+        """Bind real guarded algorithms to memory-only kernel primitives."""
+        self.disk = MemoryDisk()
+        self.disk.store.metadata.add("application", kind="directory")
+        self.revocations = 0
+        self.io = InitializationIO(
+            workspace_root=self.disk.root,
+            catalog=catalog,
+            metadata=self.disk.store.metadata,
+            read_bytes=self.disk.store.read,
+            primitives=self.disk.provider(),
+            open_directory=self.disk.open,
+            invalidate_authority=self.invalidate,
+        )
+
+    def invalidate(self) -> None:
+        """Record protected-store revocation without writing receipts or activations."""
+        self.revocations += 1
+
+
+class MemoryRepository:
+    """Serve deterministic local checkout pins and blobs without a process."""
+
+    def __init__(
+        self, *, revision: str | None = "a" * 40, available: bool = True
+    ) -> None:
+        """Retain fresh test-owned objects with an optional unavailable Git state."""
+        self.checkout = RepositoryIdentity(id="consumer-repository", revision=revision)
+        self.available = available
+        self.files: dict[str, bytes] = {}
+
+    def identity(self) -> RepositoryIdentity:
+        """Expose verified local identity or an explicit availability failure."""
+        if not self.available:
+            raise OSError("Local Git unavailable")
+        return self.checkout
+
+    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
+        """Require a matching immutable pin and a bounded existing memory blob."""
+        content = self.files[path]
+        if revision != self.checkout.revision or len(content) > limit:
+            raise OSError("Invalid pinned memory read")
+        return RepositoryFile(repository=self.checkout, path=path, content=content)
diff --git a/tests/discovery_runtime/test_initialization.py b/tests/discovery_runtime/test_initialization.py
new file mode 100644
index 0000000000000000000000000000000000000000..4453d57902f911674a98142e435aa650da2c9a3e
--- /dev/null
+++ b/tests/discovery_runtime/test_initialization.py
@@ -0,0 +1,427 @@
+"""Verify caller-owned drafts and complete guarded initialization in memory."""
+
+from __future__ import annotations
+
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.init_flow import (
+    commit_initialization,
+    initialize_workspace,
+    plan_initialization,
+)
+from drm_copilot_discovery.init_io import BootstrapResult, InitializationIO
+from drm_copilot_discovery.init_projection import (
+    InitializationRequest,
+    InitializationTemplates,
+    profile_proposal,
+    require_compatible,
+)
+from drm_copilot_discovery.models import JsonObject
+from drm_copilot_discovery.profile_v2 import ProfileV2
+from drm_copilot_discovery.snapshot import repository_pins
+from drm_copilot_discovery.validation import validate_snapshot
+
+from tests.discovery_runtime.initialization_test_support import (
+    InitializationCase,
+    MemoryRepository,
+    request_for,
+)
+from tests.discovery_runtime.initialization_test_support import (
+    initialization_catalog as initialization_catalog,
+)
+from tests.discovery_runtime.initialization_test_support import (
+    initialization_plan as initialization_plan,
+)
+from tests.discovery_runtime.initialization_test_support import (
+    initialization_templates as initialization_templates,
+)
+from tests.discovery_runtime.mutation_test_support import constant
+
+if TYPE_CHECKING:
+    from contextlib import AbstractContextManager
+    from pathlib import Path
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.init_flow import InitializationPlan
+    from drm_copilot_discovery.mutation_filesystem import Directory
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+    from drm_copilot_discovery.profile_models import ArtifactKey, SystemRole
+    from drm_copilot_discovery.snapshot_io import WorkspaceBytes
+
+
+@pytest.mark.parametrize("role", ["legacy-source", "modernization-target", "combined"])
+def test_each_role_projects_a_complete_honest_structural_draft(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+    role: SystemRole,
+) -> None:
+    """
+    Validate exact role-specific file sets and pins without fabricated completion.
+    """
+    case = InitializationCase(initialization_catalog)
+    request = request_for(role)
+
+    plan = plan_initialization(request, io=case.io, templates=initialization_templates)
+    snapshot = plan.mutation.prospective
+    paths = request.artifact_paths()
+    # Exact role-specific output closure excludes fabricated feature artifacts.
+    expected = {
+        str(paths[key])
+        for key in (
+            "profile",
+            "scope",
+            "coverage_ledger",
+            "unspecified_behaviors",
+            "product_decisions",
+        )
+    }
+    if role != "legacy-source":
+        expected.add(str(paths["parity_matrix"]))
+    assert {item.path for item in snapshot.manifest.files} == expected
+    assert len(expected) == (5 if role == "legacy-source" else 6)
+    assert snapshot.profile.repository.revision is None
+    assert snapshot.profile.profile_state == "draft"
+    assert validate_snapshot(snapshot, mode="structural").ok
+    assert not validate_snapshot(snapshot, mode="discovery-complete").ok
+    assert snapshot.profile.system.role == role
+    source, target = repository_pins(snapshot.profile)
+    assert tuple(pin.id for pin in source) == (
+        () if role == "modernization-target" else (request.repository_id,)
+    )
+    assert tuple(pin.id for pin in target) == (
+        () if role == "legacy-source" else (request.repository_id,)
+    )
+    assert all(pin.revision is None for pin in (*source, *target))
+    assert len(plan.directories) == 9
+    assert all(
+        plan.capture.proposal_base.inspect(path).kind == "directory"
+        for path in plan.directories
+    )
+    assert case.disk.store.files == {} and case.revocations == 0
+
+
+def test_first_combined_initialization_publishes_parity_through_real_writer(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """Publish the complete combined draft and release every native memory handle."""
+    case = InitializationCase(initialization_catalog)
+    request = request_for("combined")
+    result = initialize_workspace(
+        request, io=case.io, templates=initialization_templates
+    )
+    assert result.ok, result.error
+    assert all(item.status in {"created", "skipped"} for item in result.outputs)
+    assert (
+        len(case.disk.store.files) == 6
+        and str(request.artifact_paths()["parity_matrix"]) in case.disk.store.files
+    )
+    assert case.disk.held == 0 and not case.disk.locked
+    assert all(
+        case.disk.store.metadata(item.path).kind == "directory"
+        for item in result.outputs
+        if item.kind == "directory"
+    )
+    assert not any(
+        "activation" in path or "receipt" in path for path in case.disk.store.files
+    )
+
+
+def test_dry_run_is_repeatable_and_retains_exact_physical_absence(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """
+    A virtual profile validates a proposal but cannot become a physical observation.
+    """
+    case = InitializationCase(initialization_catalog)
+    before = dict(case.disk.store.metadata.entries)
+    plan = plan_initialization(
+        request_for(), io=case.io, templates=initialization_templates
+    )
+
+    first = commit_initialization(plan, io=case.io, dry_run=True)
+    second = commit_initialization(plan, io=case.io, dry_run=True)
+
+    assert first == second and first.ok
+    assert case.disk.store.files == {} and case.revocations == 0
+    assert case.disk.store.metadata.entries == before
+    assert plan.capture.profile_missing and plan.capture.physical_files == ()
+    profile_path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
+    assert dict(plan.capture.physical_metadata)[profile_path].kind == "missing"
+    assert plan.capture.proposal_base.inspect(profile_path).kind == "file"
+
+
+@pytest.mark.parametrize(
+    "field,value",
+    [
+        ("system_id", "Invalid ID"),
+        ("system_name", " "),
+        ("role", "invalid"),
+        ("repository_id", "../invalid"),
+        ("production_roots", ()),
+        ("artifact_root", "../invalid"),
+        ("artifact_overrides", (("scope", "docs/a"), ("scope", "docs/b"))),
+    ],
+)
+def test_request_rejects_ambiguous_configuration(field: str, value: object) -> None:
+    """Malformed consumer configuration fails before any workspace I/O."""
+    arguments = {field: value}
+    with pytest.raises(ValueError):
+        replace(request_for(), **arguments)
+
+
+@pytest.mark.parametrize("key", ["root", "unknown"])
+def test_only_named_artifact_paths_may_be_overridden(key: str) -> None:
+    """Root selection has one explicit field and unknown output categories fail."""
+    request = replace(
+        request_for(), artifact_overrides=((cast("ArtifactKey", key), "docs/new"),)
+    )
+    with pytest.raises(ValueError, match="Override only named"):
+        request.artifact_paths()
+
+
+def test_explicit_draft_and_custom_paths_preserve_caller_values(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """Empty source roots require explicit draft mode; typed slots escape user text."""
+    request = InitializationRequest(
+        system_id="draft-system",
+        system_name='Quoted "name"\nnext',
+        role="combined",
+        repository_id="draft-repository",
+        draft_configuration=True,
+        artifact_root="notes/discovery",
+        artifact_overrides=(("scope", "notes/custom/scope.yaml"),),
+    )
+    raw = profile_proposal(
+        request,
+        templates=initialization_templates,
+        catalog=initialization_catalog,
+        revision=None,
+    )
+    profile = ProfileV2(raw, catalog=initialization_catalog)
+    require_compatible(request, profile)
+    assert profile.system.name == request.system_name
+    assert profile.production_roots == () and profile.repository.revision is None
+    assert profile.documentation_roots == ("notes/discovery",)
+    assert profile.artifacts["scope"] == "notes/custom/scope.yaml"
+    assert profile.required_modes == ("online",)
+    assert raw == profile_proposal(
+        request,
+        templates=initialization_templates,
+        catalog=initialization_catalog,
+        revision=None,
+    )
+
+
+@pytest.mark.parametrize(
+    "field,value",
+    [
+        ("system_name", "different"),
+        ("production_roots", ("different",)),
+        ("test_roots", ("different",)),
+        ("documentation_roots", ("different",)),
+        ("artifact_overrides", (("scope", "docs/different.yaml"),)),
+    ],
+)
+def test_existing_profile_conflicts_are_explicit(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+    field: str,
+    value: object,
+) -> None:
+    """Compatibility never silently rewrites requested identity or root bindings."""
+    request = request_for()
+    raw = profile_proposal(
+        request,
+        templates=initialization_templates,
+        catalog=initialization_catalog,
+        revision=None,
+    )
+    profile = ProfileV2(raw, catalog=initialization_catalog)
+    with pytest.raises(ValueError, match="conflicts"):
+        require_compatible(replace(request, **{field: value}), profile)
+
+
+def test_template_loader_requires_complete_valid_structures(
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """Malformed or missing templates and unresolved slots remain actionable errors."""
+    with pytest.raises(ValueError, match="all six distinct"):
+        InitializationTemplates(documents=initialization_templates.documents[:-1])
+    with pytest.raises(ValueError, match="Invalid initialization template"):
+        InitializationTemplates.load(read=lambda path: b"[invalid")
+    with pytest.raises(ValueError, match="Missing initialization template value"):
+        initialization_templates.render("scope.yaml", {})
+
+
+def test_template_cannot_claim_a_configured_profile(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """
+    Even schema-valid configured profile templates cannot bypass draft initialization.
+    """
+    documents = dict(initialization_templates.documents)
+    value = dict(documents["domain-profile.yaml"])
+    value["profile_state"] = "configured"
+    documents["domain-profile.yaml"] = JsonObject(tuple(value.items()))
+    templates = InitializationTemplates(documents=tuple(documents.items()))
+    with pytest.raises(ValueError, match="honest draft"):
+        profile_proposal(
+            request_for(),
+            templates=templates,
+            catalog=initialization_catalog,
+            revision="a" * 40,
+        )
+
+
+@pytest.mark.parametrize("available", [False, True])
+def test_local_repository_identity_is_observed_or_left_null(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+    available: bool,
+) -> None:
+    """An unavailable local Git adapter never produces a fabricated revision."""
+    case = InitializationCase(initialization_catalog)
+    repository = MemoryRepository(available=available)
+    case.io.repository = repository
+    plan = plan_initialization(
+        request_for(), io=case.io, templates=initialization_templates
+    )
+    profile = plan.capture.proposal_base.snapshot.profile
+    assert profile.repository.revision == ("a" * 40 if available else None)
+    assert profile.profile_state == "draft" and case.disk.store.files == {}
+
+
+def test_wrong_local_git_repository_identity_is_rejected(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """A local adapter cannot silently bind the request to a different repository."""
+    case = InitializationCase(initialization_catalog)
+    repository = MemoryRepository()
+    repository.checkout = replace(repository.checkout, id="other")
+    case.io.repository = repository
+    with pytest.raises(ValueError, match="Local Git identity differs"):
+        plan_initialization(
+            request_for(), io=case.io, templates=initialization_templates
+        )
+    assert case.disk.store.files == {}
+
+
+def test_local_adapter_wires_only_injected_native_boundaries(
+    initialization_catalog: SchemaCatalog,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """Local wiring retains trusted primitives without opening a real workspace."""
+    case = InitializationCase(initialization_catalog)
+    provider = case.disk.provider()
+    monkeypatch.setattr(
+        "drm_copilot_discovery.init_io.LocalMutationPrimitives", constant(provider)
+    )
+
+    def open_directory(path: Path) -> AbstractContextManager[Directory]:
+        """Resolve the fixed workspace root to a fresh retained memory handle."""
+        assert path.as_posix() == case.disk.root
+        return case.disk.open()
+
+    monkeypatch.setattr(
+        "drm_copilot_discovery.init_io.open_local_directory", open_directory
+    )
+    io = InitializationIO.local(
+        workspace_root=case.disk.root,
+        lock_path="external-lock",
+        catalog=initialization_catalog,
+        invalidate_authority=case.invalidate,
+    )
+    assert io.primitives is provider and io.catalog is initialization_catalog
+    with io.open_directory() as directory:
+        assert directory.identity() == case.disk.store.metadata(".").identity
+    assert case.disk.held == 0 and case.disk.store.files == {}
+
+
+@pytest.mark.parametrize(
+    "failure", ["reconstruction", "bootstrap", "graph", "revocation"]
+)
+def test_commit_failure_dispositions_preserve_guarded_boundary(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+    failure: str,
+) -> None:
+    """Inject failed stage results to verify orchestration without repeating I/O."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    accepted = plan.capture.proposal_base
+    monkeypatch.setattr(
+        "drm_copilot_discovery.init_flow.plan_initialization", constant(plan)
+    )
+    bootstrap = BootstrapResult(
+        ok=failure != "bootstrap",
+        created=(),
+        uncertain=("docs/uncertain",) if failure == "bootstrap" else (),
+        authority_invalidated=failure != "revocation",
+        error="bootstrap interrupted" if failure == "bootstrap" else None,
+        physical=accepted,
+    )
+    monkeypatch.setattr(case.io, "bootstrap", constant(bootstrap))
+    monkeypatch.setattr(case.io, "physical_capture", constant(accepted))
+    monkeypatch.setattr(
+        "drm_copilot_discovery.init_flow.plan_mutation",
+        constant(replace(plan.mutation, prospective=accepted.snapshot)),
+    )
+    # Each case fails at its named stage before ordinary artifact publication.
+    if failure in {"reconstruction", "revocation"}:
+        plan = replace(plan, profile_bytes=b"changed proposed profile")
+    if failure == "revocation":
+
+        def fail_revoke() -> None:
+            """Expose invalidation failure without granting a completed result."""
+            raise OSError("protected state unavailable")
+
+        case.io.invalidate_authority = fail_revoke
+
+    result = commit_initialization(plan, io=case.io)
+
+    assert not result.ok and case.disk.store.files == {} and case.disk.held == 0
+    assert result.authority_invalidated is (failure != "revocation")
+    expected = {
+        "reconstruction": "validated reconstruction",
+        "bootstrap": "bootstrap interrupted",
+        "graph": "Physical creation graph differs",
+        "revocation": "authority invalidation failed: protected state unavailable",
+    }
+    assert expected[failure] in str(result.error)
+    assert result.uncertain_paths == bootstrap.uncertain
+
+
+def test_capture_rechecks_physical_bytes_after_virtual_loader_returns(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """A final changed-byte read fails even when the loader returned its snapshot."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    path = "application/code.txt"
+    case.disk.store.put(path, b"original")
+
+    def loaded(**arguments: object) -> CapturedWorkspace:
+        """Record one real read, then simulate a change after loader consistency."""
+        read = cast("WorkspaceBytes", arguments["read_bytes"])
+        assert read(path, limit=8) == b"original"
+        case.disk.store.files[path] = b"modified"
+        return plan.capture.proposal_base
+
+    monkeypatch.setattr("drm_copilot_discovery.init_io.capture_workspace", loaded)
+    with pytest.raises(OSError, match="Initialization bytes changed after capture"):
+        case.io.capture(
+            profile_path=plan.capture.proposal_base.snapshot.profile.artifacts[
+                "profile"
+            ],
+            profile_bytes=plan.profile_bytes,
+        )
+    assert case.revocations == 0 and case.disk.held == 0
diff --git a/tests/discovery_runtime/test_initialization_conflicts.py b/tests/discovery_runtime/test_initialization_conflicts.py
new file mode 100644
index 0000000000000000000000000000000000000000..cc932753f3b940c282db5bdd0e2ba5972af30d10
--- /dev/null
+++ b/tests/discovery_runtime/test_initialization_conflicts.py
@@ -0,0 +1,457 @@
+"""Exercise prewrite conflicts, bootstrap races and bounded failures with memory I/O."""
+
+from __future__ import annotations
+
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.init_flow import (
+    commit_initialization,
+    initialize_workspace,
+)
+from drm_copilot_discovery.init_io import BootstrapResult
+from drm_copilot_discovery.init_projection import (
+    InitializationConflict,
+    ProposalInputs,
+)
+
+from tests.discovery_runtime.initialization_test_support import (
+    InitializationCase,
+    bootstrap_capture,
+    request_for,
+    seed_proposal,
+)
+from tests.discovery_runtime.initialization_test_support import (
+    initialization_catalog as initialization_catalog,
+)
+from tests.discovery_runtime.initialization_test_support import (
+    initialization_plan as initialization_plan,
+)
+from tests.discovery_runtime.initialization_test_support import (
+    initialization_templates as initialization_templates,
+)
+from tests.discovery_runtime.mutation_test_support import constant
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.init_flow import InitializationPlan
+    from drm_copilot_discovery.init_projection import (
+        InitializationCapture,
+        InitializationTemplates,
+    )
+    from drm_copilot_discovery.profile_models import ArtifactKey
+
+
+@pytest.mark.parametrize(
+    "conflict",
+    [
+        "profile",
+        "scope",
+        "coverage_ledger",
+        "unspecified_behaviors",
+        "product_decisions",
+        "parity_matrix",
+        "identity",
+        "directory",
+        "unknown-artifact",
+    ],
+)
+def test_invalid_or_incompatible_existing_content_aborts_before_any_write(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    initialization_templates: InitializationTemplates,
+    conflict: str,
+) -> None:
+    """
+    Existing bad bytes remain visible; no profile/directory is created around them.
+    """
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    profile = plan.capture.proposal_base.snapshot.profile
+    request = request_for()
+    if conflict == "profile":
+        case.disk.store.put(profile.artifacts["profile"], b"invalid: true")
+    elif conflict in {
+        "scope",
+        "coverage_ledger",
+        "unspecified_behaviors",
+        "product_decisions",
+        "parity_matrix",
+    }:
+        case.disk.store.put(
+            profile.artifacts[cast("ArtifactKey", conflict)], b"invalid: true"
+        )
+    elif conflict == "directory":
+        case.disk.store.put(profile.artifacts["reports"], b"occupied directory")
+    elif conflict == "unknown-artifact":
+        case.disk.store.put(
+            profile.artifacts["feature_contracts"] + "/wrong.yaml", b"invalid: true"
+        )
+    else:
+        case.disk.store.put(profile.artifacts["profile"], plan.profile_bytes)
+        request = replace(request, system_name="Different consumer")
+    before = (dict(case.disk.store.files), dict(case.disk.store.metadata.entries))
+
+    with pytest.raises(InitializationConflict) as caught:
+        initialize_workspace(
+            request, io=case.io, templates=initialization_templates, force=True
+        )
+
+    assert caught.value.outputs and caught.value.findings
+    assert all(item.status == "conflict" for item in caught.value.outputs)
+    if conflict in {
+        "scope",
+        "coverage_ledger",
+        "unspecified_behaviors",
+        "product_decisions",
+        "parity_matrix",
+    }:
+        assert {item.path for item in caught.value.outputs} == {
+            profile.artifacts[cast("ArtifactKey", conflict)]
+        }
+    assert (case.disk.store.files, case.disk.store.metadata.entries) == before
+    assert case.revocations == 0 and case.disk.held == 0
+
+
+def test_partial_workspace_recovers_and_repeat_preserves_all_valid_bytes(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """
+    Rerun fills missing outputs, retaining compatible IDs, raw whitespace and unrelated
+    docs.
+    """
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    profile = plan.capture.proposal_base.snapshot.profile
+    scope = next(
+        item.change
+        for item in plan.mutation.writes
+        if item.change.artifact_kind == "scope"
+    )
+    case.disk.store.put(profile.artifacts["profile"], plan.profile_bytes)
+    case.disk.store.put(scope.path, b" \n" + scope.content)
+    case.disk.store.put("docs/notes.txt", b"unrelated raw\r\nbytes")
+
+    result = initialize_workspace(
+        request_for(), io=case.io, templates=initialization_templates, force=True
+    )
+
+    assert result.ok, result.error
+    assert result.notes and case.disk.store.files[scope.path] == b" \n" + scope.content
+    assert case.disk.store.files["docs/notes.txt"] == b"unrelated raw\r\nbytes"
+    before, revoked = dict(case.disk.store.files), case.revocations
+    repeated = initialize_workspace(
+        request_for(), io=case.io, templates=initialization_templates
+    )
+    assert repeated.ok and all(item.status == "skipped" for item in repeated.outputs)
+    assert case.disk.store.files == before and case.revocations == revoked
+
+
+@pytest.mark.parametrize("change", ["collision", "parent-identity", "source-byte"])
+def test_stale_physical_inputs_invalidate_a_prepared_plan(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    change: str,
+) -> None:
+    """
+    Virtual profile bytes never waive a real absence, identity or complete-input check.
+    """
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
+    if change == "collision":
+        case.disk.store.put(path, plan.profile_bytes)
+    elif change == "parent-identity":
+        old = case.disk.store.metadata.entries["docs"]
+        case.disk.store.metadata.entries["docs"] = replace(old, identity="replaced")
+    else:
+        case.disk.store.put("application/changed.txt", b"new input")
+    before = dict(case.disk.store.files)
+
+    result = commit_initialization(plan, io=case.io)
+
+    assert not result.ok and result.authority_invalidated
+    assert case.disk.store.files == before and case.disk.held == 0
+
+
+@pytest.mark.parametrize(
+    "failure", ["profile-publish", "directory-open", "guard-busy", "revocation"]
+)
+def test_bootstrap_failures_report_partial_effects_and_release_handles(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    failure: str,
+) -> None:
+    """Every guarded failure stops further creation without silently rolling back."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    if failure == "profile-publish":
+        case.disk.fail_publish = True
+    elif failure == "directory-open":
+
+        def fail_open(path: str) -> None:
+            """Fail after a configured directory is exclusively created."""
+            if path.endswith("/acceptance"):
+                raise OSError("directory open failed")
+
+        case.disk.before_open = fail_open
+    elif failure == "guard-busy":
+        case.disk.locked = True
+    else:
+
+        def fail_revoke() -> None:
+            """Fail protected-state invalidation before any workspace write."""
+            raise OSError("revocation failed")
+
+        case.io.invalidate_authority = fail_revoke
+
+    result = case.io.bootstrap(
+        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
+    )
+
+    assert not result.ok and result.error
+    assert case.disk.held == 0
+    assert not any(".drm-mutation-" in path for path in case.disk.store.files)
+    if failure == "directory-open":
+        assert result.created and result.uncertain
+        assert any(path.endswith("domain-profile.yaml") for path in result.created)
+    elif failure == "profile-publish":
+        assert result.uncertain and case.disk.store.files == {}
+    elif failure == "revocation":
+        assert not result.authority_invalidated and case.disk.store.files == {}
+    else:
+        assert result.authority_invalidated and case.disk.store.files == {}
+
+
+def test_bootstrap_rejects_unconfigured_directories(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+) -> None:
+    """Root bootstrap cannot be used as a blanket directory-creation capability."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    with pytest.raises(ValueError, match="exactly match"):
+        case.io.bootstrap(
+            plan.capture, profile_bytes=plan.profile_bytes, directories=("outside",)
+        )
+    assert case.disk.store.files == {} and case.revocations == 0
+
+
+@pytest.mark.parametrize("path", [".", "docs"])
+def test_opened_directory_identity_must_match_retained_parent_stamp(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    path: str,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """
+    A parent swap between inspection and open is rejected before creating descendants.
+    """
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    monkeypatch.setattr(case.io, "capture", constant(plan.capture))
+
+    def swap(opened: str) -> None:
+        """Replace the opened directory identity without changing its spelling."""
+        if opened == path:
+            old = case.disk.store.metadata.entries[path]
+            case.disk.store.metadata.entries[path] = replace(old, identity="substitute")
+
+    case.disk.before_open = swap
+    result = case.io.bootstrap(
+        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
+    )
+    assert not result.ok and "identity changed" in str(result.error)
+    assert case.disk.held == 0 and case.disk.store.files == {}
+
+
+def test_metadata_changes_after_capture_are_detected_by_physical_reader(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+) -> None:
+    """Normalization of child order never permits a changed physical identity."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    inputs = ProposalInputs(
+        case.io, "docs/migration/discovery/domain-profile.yaml", plan.profile_bytes, ()
+    )
+    inputs.physical("docs")
+    old = case.disk.store.metadata.entries["docs"]
+    case.disk.store.metadata.entries["docs"] = replace(old, identity="replacement")
+    with pytest.raises(OSError, match="metadata changed"):
+        inputs.physical("docs")
+
+
+def test_virtual_reads_are_bounded_and_do_not_hide_changed_physical_bytes(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+) -> None:
+    """
+    Synthetic bytes honor limits and existing input bytes retain their original value.
+    """
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
+    inputs = ProposalInputs(case.io, path, plan.profile_bytes, ())
+    with pytest.raises(OSError, match="read limit"):
+        inputs.read(path, limit=1)
+    case.disk.store.put("application/code.txt", b"before")
+    assert inputs.read("application/code.txt", limit=10) == b"before"
+    case.disk.store.files["application/code.txt"] = b"after"
+    with pytest.raises(OSError, match="bytes changed"):
+        inputs.read("application/code.txt", limit=10)
+
+
+def test_changed_parent_metadata_before_open_is_rejected(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """A substitution after resolution is rejected before opening a descendant."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    monkeypatch.setattr(case.io, "capture", constant(plan.capture))
+
+    def swap(path: str) -> None:
+        """Change a child after the policy has captured its original stamp."""
+        if path == ".":
+            old = case.disk.store.metadata.entries["docs"]
+            case.disk.store.metadata.entries["docs"] = replace(old, identity="changed")
+
+    case.disk.before_open = swap
+    result = case.io.bootstrap(
+        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
+    )
+    assert not result.ok and "parent changed" in str(result.error)
+    assert case.disk.held == 0
+
+
+def test_existing_graph_preservation_without_writes(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """Same-content initialization skips even when force is passed."""
+    case = InitializationCase(initialization_catalog)
+    seed_proposal(case, initialization_plan)
+    before = (dict(case.disk.store.files), dict(case.disk.store.metadata.entries))
+    result = initialize_workspace(
+        request_for(), io=case.io, templates=initialization_templates, force=True
+    )
+    assert result.ok and all(item.status == "skipped" for item in result.outputs)
+    assert (case.disk.store.files, case.disk.store.metadata.entries) == before
+    assert case.revocations == 0
+
+
+@pytest.mark.parametrize(
+    "change", ["none", "identity", "bytes", "lost-path", "kind", "namespace"]
+)
+def test_new_directory_identity_is_bound_through_guarded_postcapture(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+    change: str,
+) -> None:
+    """Postcapture cannot adopt a replacement of a newly opened empty directory."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    path = plan.capture.proposal_base.snapshot.profile.artifacts["evidence"]
+
+    def capture(**kwargs: object) -> InitializationCapture:
+        """Supply stable graph bytes while exercising real guard and directory I/O."""
+        del kwargs
+        if case.disk.store.metadata(path).kind == "missing":
+            return plan.capture
+        assert case.disk.held > 0 and case.disk.locked
+        if change == "identity":
+            old = case.disk.store.metadata.entries[path]
+            case.disk.store.metadata.entries[path] = replace(
+                old, identity="replaced-after-open"
+            )
+        captured = bootstrap_capture(case, plan)
+        metadata = dict(captured.physical_metadata)
+        profile_path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
+        if change == "bytes":
+            return replace(captured, physical_files=((profile_path, b"changed"),))
+        if change == "lost-path":
+            metadata.pop("verification")
+        elif change == "kind":
+            metadata[profile_path] = replace(metadata[profile_path], kind="directory")
+        elif change == "namespace":
+            metadata["application"] = replace(
+                metadata["application"], children=("unexpected",)
+            )
+        return replace(captured, physical_metadata=tuple(metadata.items()))
+
+    monkeypatch.setattr(case.io, "capture", capture)
+    result = case.io.bootstrap(
+        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
+    )
+    assert result.ok is (change == "none"), result.error
+    assert result.authority_invalidated and case.disk.held == 0
+    if change != "none":
+        assert result.physical is None and result.error
+    else:
+        assert result.physical is not None
+        assert (
+            dict(result.physical.metadata)[path].identity
+            == case.disk.store.metadata(path).identity
+        )
+
+
+def test_bootstrap_handoff_rejects_same_bytes_with_changed_parent_identity(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """The ordinary mutation planner never receives an adopted concurrent parent."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    accepted = plan.capture.proposal_base
+    metadata = dict(accepted.metadata)
+    metadata["docs"] = replace(metadata["docs"], identity="different-parent")
+    changed = replace(accepted, metadata=tuple(metadata.items()))
+    monkeypatch.setattr(
+        "drm_copilot_discovery.init_flow.plan_initialization", constant(plan)
+    )
+    monkeypatch.setattr(
+        case.io,
+        "bootstrap",
+        constant(
+            BootstrapResult(
+                ok=True,
+                created=(),
+                uncertain=(),
+                authority_invalidated=True,
+                physical=accepted,
+            )
+        ),
+    )
+    monkeypatch.setattr(case.io, "physical_capture", constant(changed))
+
+    def prohibit(*args: object, **kwargs: object) -> None:
+        """Fail if unsafe freshness reaches the ordinary planner."""
+        raise AssertionError("Changed parent reached artifact planning")
+
+    monkeypatch.setattr("drm_copilot_discovery.init_flow.plan_mutation", prohibit)
+    result = commit_initialization(plan, io=case.io)
+    assert not result.ok and result.authority_invalidated
+    assert "Physical bootstrap inputs differ" in str(result.error)
+    assert case.disk.store.files == {}
+
+
+def test_concurrent_profile_creation_has_typed_conflict_path(
+    initialization_catalog: SchemaCatalog,
+    initialization_plan: InitializationPlan,
+    monkeypatch: pytest.MonkeyPatch,
+) -> None:
+    """A cooperative bootstrap collision retains a path without parsing prose."""
+    case, plan = InitializationCase(initialization_catalog), initialization_plan
+    path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
+    case.disk.store.put(path, plan.profile_bytes)
+    # Preserve every prior observation except the concurrent profile appearance.
+    changed = replace(
+        plan.capture,
+        physical_metadata=tuple(
+            (key, case.disk.store.metadata(key) if key == path else value)
+            for key, value in plan.capture.physical_metadata
+        ),
+    )
+    monkeypatch.setattr(case.io, "capture", constant(changed))
+    result = case.io.bootstrap(
+        plan.capture, profile_bytes=plan.profile_bytes, directories=plan.directories
+    )
+    assert not result.ok and result.conflicts == (path,)
+    assert result.created == () and case.disk.store.files == {path: plan.profile_bytes}
diff --git a/tests/scripts/dev_tools/discovery/test_domain_neutrality.py b/tests/scripts/dev_tools/discovery/test_domain_neutrality.py
index e3ce27d1a6b680274cd8ea6d210549528f9a0a92..5441560e3fb6b095965c13d89400ab8903792246 100644
--- a/tests/scripts/dev_tools/discovery/test_domain_neutrality.py
+++ b/tests/scripts/dev_tools/discovery/test_domain_neutrality.py
@@ -1 +1 @@
-"""Domain-neutrality regression tests for discovery templates and rendered output."""
+"""Keep v1 fixtures neutral and verify caller-owned v2 draft projection."""
@@ -6,0 +7 @@ from pathlib import Path
+from typing import TYPE_CHECKING
@@ -8,4 +9,5 @@ from pathlib import Path
-from scripts.dev_tools.discovery.init_flow import create_discovery_workspace
-from scripts.dev_tools.discovery.init_models import (
-    EXPECTED_TEMPLATE_RELATIVE_PATHS,
-    OUTPUT_RELATIVE_PATHS,
+from drm_copilot_discovery.init_projection import (
+    ARTIFACT_TEMPLATES,
+    TEMPLATE_NAMES,
+    artifact_values,
+    profile_proposal,
@@ -12,0 +15 @@ from scripts.dev_tools.discovery.init_models import (
+from drm_copilot_discovery.profile_v2 import ProfileV2
@@ -14,28 +17,8 @@ from scripts.dev_tools.discovery.init_models import (
-DISALLOWED_TOKEN_PATTERN = re.compile(r"TaskMaster|TMW|Outlook|VSTO", re.IGNORECASE)
-
-_REPO_ROOT = Path(__file__).resolve().parents[4]
-_TEMPLATE_ROOT = _REPO_ROOT / "docs" / "discovery" / "templates"
-
-
-class _FakeFileSystem:
-    """In-memory `FileSystem` test double with no real disk I/O."""
-
-    def __init__(self) -> None:
-        self.files: dict[Path, str] = {}
-        self.dirs: set[Path] = set()
-
-    def exists(self, path: Path) -> bool:
-        return path in self.files or path in self.dirs
-
-    def is_dir(self, path: Path) -> bool:
-        return path in self.dirs
-
-    def list_dir(self, path: Path) -> list[Path]:
-        return [
-            candidate
-            for candidate in {*self.files, *self.dirs}
-            if candidate != path and candidate.parent == path
-        ]
-
-    def ensure_dir(self, path: Path) -> None:
-        self.dirs.add(path)
+from scripts.dev_tools.discovery.init_models import EXPECTED_TEMPLATE_RELATIVE_PATHS
+from tests.discovery_runtime.initialization_test_support import (
+    initialization_catalog as initialization_catalog,
+)
+from tests.discovery_runtime.initialization_test_support import (
+    initialization_templates as initialization_templates,
+)
+from tests.discovery_runtime.initialization_test_support import request_for
@@ -43,2 +26,3 @@ class _FakeFileSystem:
-    def read_text(self, path: Path) -> str:
-        return self.files[path]
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.init_projection import InitializationTemplates
@@ -46,2 +30,2 @@ class _FakeFileSystem:
-    def write_text(self, path: Path, content: str) -> None:
-        self.files[path] = content
+DISALLOWED_TOKEN_PATTERN = re.compile(r"TaskMaster|TMW|Outlook|VSTO", re.IGNORECASE)
+_TEMPLATE_ROOT = Path(__file__).resolve().parents[4] / "docs/discovery/templates"
@@ -51,23 +35,7 @@ def test_domain_neutrality_templates_contain_no_disallowed_tokens() -> None:
-    """Every discovery template file contains none of the disallowed tokens."""
-    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
-        text = (_TEMPLATE_ROOT / relative_path).read_text(encoding="utf-8")
-        assert not DISALLOWED_TOKEN_PATTERN.search(
-            text
-        ), f"Disallowed token found in template {relative_path}"
-
-
-def test_domain_neutrality_rendered_output_contains_no_disallowed_tokens() -> None:
-    """Every file `create_discovery_workspace` writes contains no disallowed tokens."""
-    fs = _FakeFileSystem()
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-    fs.dirs.add(_TEMPLATE_ROOT)
-    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
-        fs.files[_TEMPLATE_ROOT / relative_path] = (
-            _TEMPLATE_ROOT / relative_path
-        ).read_text(encoding="utf-8")
-
-    create_discovery_workspace(target_dir, _TEMPLATE_ROOT, fs)
-
-    for output_relative in OUTPUT_RELATIVE_PATHS:
-        rendered = fs.files[target_dir / output_relative]
+    """Preserve the frozen v1 check and cover all six production v2 templates."""
+    paths = (
+        *EXPECTED_TEMPLATE_RELATIVE_PATHS,
+        *(Path("v2") / name for name in TEMPLATE_NAMES),
+    )
+    # Apply the same frozen domain-neutrality contract to every declared template.
+    for path in paths:
@@ -75,2 +43,37 @@ def test_domain_neutrality_rendered_output_contains_no_disallowed_tokens() -> No
-            rendered
-        ), f"Disallowed token found in rendered output {output_relative}"
+            (_TEMPLATE_ROOT / path).read_text(encoding="utf-8")
+        ), path
+
+
+def test_rendered_v2_drafts_use_only_caller_identity_and_empty_knowledge(
+    initialization_catalog: SchemaCatalog,
+    initialization_templates: InitializationTemplates,
+) -> None:
+    """
+    Production projection contains no example-domain facts or generated feature IDs.
+    """
+    request = request_for("combined")
+    content = profile_proposal(
+        request,
+        templates=initialization_templates,
+        catalog=initialization_catalog,
+        revision=None,
+    )
+    profile = ProfileV2(content, catalog=initialization_catalog)
+    values = artifact_values(profile, scope_id="scope-" + request.system_id)
+    # Render each role-capable artifact from the same explicit consumer identity.
+    outputs = (
+        content,
+        *(
+            initialization_templates.render(name, values)
+            for _, _, name in ARTIFACT_TEMPLATES
+        ),
+    )
+
+    assert profile.system.id == request.system_id
+    assert profile.repository.id == request.repository_id
+    assert profile.required_modes == ("online",)
+    assert profile.clients == () and profile.repositories == ()
+    # Caller-owned identity must remain independent of every example domain.
+    for output in outputs:
+        assert not DISALLOWED_TOKEN_PATTERN.search(output.decode())
+        assert "example" not in output.decode().lower()
diff --git a/tests/scripts/dev_tools/discovery/test_init_cli.py b/tests/scripts/dev_tools/discovery/test_init_cli.py
index 77a4289f4fa0ff51e09283d9aaee40df32c4de1f..d52c8a481aed0318bc23c2196f24eb1680e40011 100644
--- a/tests/scripts/dev_tools/discovery/test_init_cli.py
+++ b/tests/scripts/dev_tools/discovery/test_init_cli.py
@@ -6 +5,0 @@ from pathlib import Path
-from typing import Any
@@ -39 +38 @@ def test_main_success_path_invokes_create_discovery_workspace(
-    calls: list[dict[str, Any]] = []
+    calls: list[dict[str, object]] = []
@@ -47,0 +47 @@ def test_main_success_path_invokes_create_discovery_workspace(
+        """Record delegated arguments without opening the supplied filesystem."""
@@ -79 +79,2 @@ def test_main_honors_template_root_override(monkeypatch: pytest.MonkeyPatch) ->
-    ) -> None:  # noqa: ARG001
+    ) -> None:
+        """Capture only the selected template root for the override assertion."""
@@ -107,0 +109 @@ def test_main_exits_1_on_fail_fast_exception(
+        """Raise the selected boundary failure without producing any output files."""
@@ -129,0 +132,24 @@ def test_console_script_registered_in_pyproject() -> None:
+
+
+def test_legacy_cli_reports_explicit_v2_migration_without_writes(
+    monkeypatch: pytest.MonkeyPatch,
+    capsys: pytest.CaptureFixture[str],
+) -> None:
+    """Preserve old flags but require root context before initialization writes."""
+    from tests.scripts.dev_tools.discovery.test_init_flow import (
+        FakeFileSystem,
+        seed_templates,
+    )
+
+    fs, root, target = FakeFileSystem(), Path("/templates"), Path("/consumer/discovery")
+    fs.dirs.add(target.parent)
+    seed_templates(fs, root)
+    before = (dict(fs.files), set(fs.dirs))
+    monkeypatch.setattr(mod.init_models, "RealFileSystem", lambda: fs)
+
+    with pytest.raises(SystemExit) as failure:
+        mod.main([str(target), "--template-root", str(root), "--force"])
+
+    assert failure.value.code == 1
+    assert "initialize_workspace" in capsys.readouterr().err
+    assert (fs.files, fs.dirs) == before
diff --git a/tests/scripts/dev_tools/discovery/test_init_flow.py b/tests/scripts/dev_tools/discovery/test_init_flow.py
index 247fa94b27e2a51f6492b8ab87c48f2c2e8b3ae7..9f40f0b65bbbe1797e26fffc5768451a0c041441 100644
--- a/tests/scripts/dev_tools/discovery/test_init_flow.py
+++ b/tests/scripts/dev_tools/discovery/test_init_flow.py
@@ -1 +1 @@
-"""Tests for `scripts.dev_tools.discovery.init_flow`."""
+"""Retain legacy diagnostics/imports while rejecting unchecked v1 initialization."""
@@ -5 +4,0 @@ from __future__ import annotations
-import json
@@ -7 +5,0 @@ from pathlib import Path
-from typing import TYPE_CHECKING
@@ -9 +6,0 @@ from typing import TYPE_CHECKING
-import jsonschema
@@ -10,0 +8 @@ import pytest
+from drm_copilot_discovery import init_flow as runtime
@@ -13,10 +11 @@ from scripts.dev_tools.discovery import init_flow as mod
-from scripts.dev_tools.discovery.domain_profile import parse_domain_profile_text
-from scripts.dev_tools.discovery.init_models import (
-    DOMAIN_PROFILE_RELATIVE_PATH,
-    EXPECTED_TEMPLATE_RELATIVE_PATHS,
-    OUTPUT_RELATIVE_PATHS,
-    resolve_default_template_root,
-)
-
-if TYPE_CHECKING:
-    from scripts.dev_tools.discovery.init_models import FileSystem
+from scripts.dev_tools.discovery.init_models import EXPECTED_TEMPLATE_RELATIVE_PATHS
@@ -26 +15 @@ class FakeFileSystem:
-    """In-memory `FileSystem` test double with no real disk I/O."""
+    """Represent the legacy unchecked interface entirely in test-owned memory."""
@@ -28,0 +18 @@ class FakeFileSystem:
+        """Start with no files, directories or writes from another test."""
@@ -32,0 +23 @@ class FakeFileSystem:
+        """Read this test's exact namespace membership."""
@@ -35,0 +27 @@ class FakeFileSystem:
+        """Distinguish files from directories without native filesystem calls."""
@@ -39,5 +31,7 @@ class FakeFileSystem:
-        children: list[Path] = []
-        for candidate in {*self.files, *self.dirs}:
-            if candidate != path and candidate.parent == path:
-                children.append(candidate)
-        return children
+        """Enumerate complete immediate memory children."""
+        # Exclude descendants so parent checks see the same shape as native reads.
+        return [
+            item
+            for item in {*self.files, *self.dirs}
+            if item != path and item.parent == path
+        ]
@@ -45,0 +40 @@ class FakeFileSystem:
+        """Expose the old unchecked capability so rejection can prove it is unused."""
@@ -48,0 +44 @@ class FakeFileSystem:
+        """Return exact fixture text or the established missing-file error."""
@@ -53,0 +50 @@ class FakeFileSystem:
+        """Model the overwrite capability that must never grant v2 authority."""
@@ -57,74 +54,6 @@ class FakeFileSystem:
-def _seed_template_root(fs: FakeFileSystem, template_root: Path) -> None:
-    """Seed `fs` with a complete, 8-file expected template set under `template_root`."""
-    fs.dirs.add(template_root)
-    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
-        fs.files[template_root / relative_path] = f"template:{relative_path}"
-
-
-def test_substitute_placeholders_no_tokens_returns_unchanged() -> None:
-    """With `tokens=None`, the input text is returned unchanged."""
-    text = "<legacy-source-path> stays intact"
-    assert mod.substitute_placeholders(text) == text
-    assert mod.substitute_placeholders(text, None) == text
-
-
-def test_substitute_placeholders_replaces_every_occurrence() -> None:
-    """Every occurrence of each mapped token is replaced by its value."""
-    text = "<a> and <a> and <b>"
-    result = mod.substitute_placeholders(text, {"<a>": "1", "<b>": "2"})
-    assert result == "1 and 1 and 2"
-
-
-def test_create_discovery_workspace_success_full_layout() -> None:
-    """A complete template set scaffolds exactly the 8 expected output files."""
-    fs = FakeFileSystem()
-    template_root = Path("/templates")
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-    _seed_template_root(fs, template_root)
-
-    mod.create_discovery_workspace(target_dir, template_root, fs)
-
-    written = {path for path in fs.files if path != template_root}
-    expected_paths = {
-        target_dir / output_relative for output_relative in OUTPUT_RELATIVE_PATHS
-    }
-    assert written.issuperset(expected_paths)
-    assert len(expected_paths) == 8
-    for template_relative, output_relative in zip(
-        EXPECTED_TEMPLATE_RELATIVE_PATHS, OUTPUT_RELATIVE_PATHS, strict=True
-    ):
-        assert fs.files[target_dir / output_relative] == f"template:{template_relative}"
-
-
-def test_create_discovery_workspace_template_root_override() -> None:
-    """An alternate template root is read from, instead of any default root."""
-    fs = FakeFileSystem()
-    default_root = Path("/default-templates")
-    alternate_root = Path("/alternate-templates")
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-    _seed_template_root(fs, default_root)
-    fs.dirs.add(alternate_root)
-    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
-        fs.files[alternate_root / relative_path] = f"alternate:{relative_path}"
-
-    mod.create_discovery_workspace(target_dir, alternate_root, fs)
-
-    for template_relative, output_relative in zip(
-        EXPECTED_TEMPLATE_RELATIVE_PATHS, OUTPUT_RELATIVE_PATHS, strict=True
-    ):
-        assert (
-            fs.files[target_dir / output_relative] == f"alternate:{template_relative}"
-        )
-
-
-def test_target_path_not_a_directory_raises() -> None:
-    """A target path that exists as a file raises `NotADirectoryError`."""
-    fs = FakeFileSystem()
-    template_root = Path("/templates")
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-    fs.files[target_dir] = "not a directory"
-    _seed_template_root(fs, template_root)
-    pre_seeded_files = set(fs.files)
+def seed_templates(fs: FakeFileSystem, root: Path) -> None:
+    """Retain the complete legacy template shape for helper compatibility tests."""
+    fs.dirs.add(root)
+    # Preserve every old declared path for diagnostics without reading disk.
+    for path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
+        fs.files[root / path] = "legacy fixture"
@@ -132,2 +60,0 @@ def test_target_path_not_a_directory_raises() -> None:
-    with pytest.raises(NotADirectoryError):
-        mod.create_discovery_workspace(target_dir, template_root, fs)
@@ -135 +62,5 @@ def test_target_path_not_a_directory_raises() -> None:
-    assert set(fs.files) == pre_seeded_files
+def test_public_exports_are_thin_runtime_aliases() -> None:
+    """Every supported old import resolves to the authoritative runtime function."""
+    # Verify the whole explicit export contract instead of one representative name.
+    for name in mod.__all__:
+        assert getattr(mod, name) is getattr(runtime, name)
@@ -138,12 +69,7 @@ def test_target_path_not_a_directory_raises() -> None:
-def test_target_parent_missing_raises() -> None:
-    """A target whose parent directory does not exist raises `FileNotFoundError`."""
-    fs = FakeFileSystem()
-    template_root = Path("/templates")
-    target_dir = Path("/consumer/discovery")
-    _seed_template_root(fs, template_root)
-    pre_seeded_files = set(fs.files)
-
-    with pytest.raises(FileNotFoundError):
-        mod.create_discovery_workspace(target_dir, template_root, fs)
-
-    assert set(fs.files) == pre_seeded_files
+@pytest.mark.parametrize("tokens", [None, {}, {"<a>": "one", "<b>": "two"}])
+def test_literal_substitution_helper_remains_compatible(
+    tokens: dict[str, str] | None,
+) -> None:
+    """Repeated literal replacements remain independent of typed v2 rendering."""
+    result = mod.substitute_placeholders("<a> <a> <b>", tokens)
+    assert result == ("one one two" if tokens else "<a> <a> <b>")
@@ -152,2 +78,6 @@ def test_target_parent_missing_raises() -> None:
-def test_target_non_empty_without_force_raises() -> None:
-    """A non-empty target without `force` raises `FileExistsError`."""
+@pytest.mark.parametrize("force", [False, True])
+@pytest.mark.parametrize("nonempty", [False, True])
+def test_legacy_calls_require_explicit_v2_context_and_never_write(
+    force: bool, nonempty: bool
+) -> None:
+    """Deprecated force cannot turn the unchecked legacy FileSystem into authority."""
@@ -155,121 +85,50 @@ def test_target_non_empty_without_force_raises() -> None:
-    template_root = Path("/templates")
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-    fs.dirs.add(target_dir)
-    pre_seeded = target_dir / "existing.txt"
-    fs.files[pre_seeded] = "already here"
-    _seed_template_root(fs, template_root)
-    pre_seeded_files = set(fs.files)
-
-    with pytest.raises(FileExistsError):
-        mod.create_discovery_workspace(target_dir, template_root, fs)
-
-    assert set(fs.files) == pre_seeded_files
-
-
-def test_target_non_empty_with_force_succeeds() -> None:
-    """A non-empty target with `force=True` succeeds and writes the full output set."""
-    fs = FakeFileSystem()
-    template_root = Path("/templates")
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-    fs.dirs.add(target_dir)
-    pre_seeded = target_dir / "existing.txt"
-    fs.files[pre_seeded] = "already here"
-    _seed_template_root(fs, template_root)
-
-    mod.create_discovery_workspace(target_dir, template_root, fs, force=True)
-
-    expected_paths = {
-        target_dir / output_relative for output_relative in OUTPUT_RELATIVE_PATHS
-    }
-    assert expected_paths.issubset(set(fs.files))
-    assert pre_seeded in fs.files
-
-
-def test_missing_template_root_raises() -> None:
-    """A wholly missing template root raises `FileNotFoundError` and writes nothing."""
-    fs: FileSystem = FakeFileSystem()
-    template_root = Path("/templates")
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-
-    with pytest.raises(FileNotFoundError):
-        mod.create_discovery_workspace(target_dir, template_root, fs)
-
-    assert not fs.files
-
-
-def test_partial_template_set_raises() -> None:
-    """A template root missing one file raises `FileNotFoundError` naming it."""
-    fs = FakeFileSystem()
-    template_root = Path("/templates")
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-    _seed_template_root(fs, template_root)
-    missing_relative = EXPECTED_TEMPLATE_RELATIVE_PATHS[-1]
-    del fs.files[template_root / missing_relative]
-    pre_seeded_files = set(fs.files)
-
-    with pytest.raises(FileNotFoundError) as excinfo:
-        mod.create_discovery_workspace(target_dir, template_root, fs)
-
-    assert str(missing_relative) in str(excinfo.value)
-    assert set(fs.files) == pre_seeded_files
-
-
-def test_domain_profile_template_parses_with_real_loader() -> None:
-    """The bundled domain-profile template parses under the real #360 loader.
-
-    Reads the in-repo domain-profile template, renders it both with no tokens and
-    with a representative domain-neutral token mapping, and asserts the real
-    ``parse_domain_profile_text`` returns a ``DomainProfile`` with
-    ``profile_version == 1`` in each case. The only filesystem access is reading
-    the in-repo template file.
-    """
-    template_path = resolve_default_template_root() / DOMAIN_PROFILE_RELATIVE_PATH
-    template_text = template_path.read_text(encoding="utf-8")
-    tokens = {
-        "<legacy-source-path>": "legacy/src",
-        "<target-path>": "modern/src",
-        "<technology-stack>": "example-runtime",
-        "<artifact-output-dir>": "discovery/artifacts",
-    }
-
-    for rendered in (
-        mod.substitute_placeholders(template_text),
-        mod.substitute_placeholders(template_text, tokens),
-    ):
-        profile = parse_domain_profile_text(rendered)
-        assert profile.profile_version == 1
-
-
-def test_generated_artifacts_conform_to_real_schemas() -> None:
-    """Each generated artifact validates against its merged v1 JSON schema.
-
-    Seeds an in-memory filesystem with the real bundled template texts, scaffolds
-    a workspace via `create_discovery_workspace`, then loads each of the seven
-    rendered artifact instances and validates it against the corresponding merged
-    schema file under `schemas/discovery/v1/`. The only filesystem access is
-    reading the in-repo template and schema files.
-    """
-    template_root = resolve_default_template_root()
-    schema_root = template_root.parents[2] / "schemas" / "discovery" / "v1"
-    fs = FakeFileSystem()
-    fs.dirs.add(template_root)
-    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
-        fs.files[template_root / relative_path] = (
-            template_root / relative_path
-        ).read_text(encoding="utf-8")
-    target_dir = Path("/consumer/discovery")
-    fs.dirs.add(target_dir.parent)
-
-    mod.create_discovery_workspace(target_dir, template_root, fs)
-
-    # OUTPUT_RELATIVE_PATHS[0] is the non-JSON domain-profile.yaml; the remaining
-    # seven entries are the artifact JSON instances validated here.
-    for output_relative in OUTPUT_RELATIVE_PATHS[1:]:
-        instance = json.loads(fs.files[target_dir / output_relative])
-        schema_name = output_relative.stem + ".schema.json"
-        schema = json.loads((schema_root / schema_name).read_text(encoding="utf-8"))
-        jsonschema.validate(instance=instance, schema=schema)
+    target, root = Path("/consumer/discovery"), Path("/templates")
+    fs.dirs.update((target.parent, target))
+    seed_templates(fs, root)
+    if nonempty:
+        fs.files[target / "keep.txt"] = "preserve original bytes"
+    before = (dict(fs.files), set(fs.dirs))
+
+    with pytest.raises(ValueError, match="initialize_workspace") as failure:
+        mod.create_discovery_workspace(target, root, fs, force=force)
+
+    assert "system ID/name" in str(failure.value)
+    assert "force never permits overwriting" in str(failure.value)
+    assert (fs.files, fs.dirs) == before
+
+
+def test_template_override_and_complete_missing_template_diagnostics() -> None:
+    """Helpers retain caller-selected roots and report every missing template."""
+    fs, root = FakeFileSystem(), Path("/alternate-templates")
+    with pytest.raises(FileNotFoundError, match="alternate-templates"):
+        mod.validate_template_set(root, fs)
+    seed_templates(fs, root)
+    mod.validate_template_set(root, fs)
+    missing = EXPECTED_TEMPLATE_RELATIVE_PATHS[-2:]
+    # Remove two independent declarations to prove diagnostics are complete.
+    for path in missing:
+        del fs.files[root / path]
+    with pytest.raises(FileNotFoundError) as failure:
+        mod.validate_template_set(root, fs)
+    assert all(str(path) in str(failure.value) for path in missing)
+
+
+def test_target_type_and_parent_errors_remain_actionable() -> None:
+    """An invalid parent or file target fails before the migration diagnostic."""
+    fs, target = FakeFileSystem(), Path("/consumer/discovery")
+    with pytest.raises(FileNotFoundError, match="parent"):
+        mod.validate_target_path(target, fs, force=False)
+    fs.dirs.add(target.parent)
+    fs.files[target] = "existing file"
+    with pytest.raises(NotADirectoryError, match="not a directory"):
+        mod.validate_target_path(target, fs, force=True)
+
+
+@pytest.mark.parametrize("force", [False, True])
+def test_nonempty_target_is_not_itself_a_conflict(force: bool) -> None:
+    """Conflict assessment belongs to complete v2 artifact validation."""
+    fs, target = FakeFileSystem(), Path("/consumer/discovery")
+    fs.dirs.update((target.parent, target))
+    fs.files[target / "unrelated.txt"] = "keep"
+    mod.validate_target_path(target, fs, force=force)
+    assert fs.files[target / "unrelated.txt"] == "keep"
diff --git a/tests/scripts/dev_tools/discovery/test_init_models.py b/tests/scripts/dev_tools/discovery/test_init_models.py
index 33f8b8917e9e98af9b9fb19ebb85b8e2ea60a52f..b0d420860fd71cd52dd93268ae52887fea89ce9b 100644
--- a/tests/scripts/dev_tools/discovery/test_init_models.py
+++ b/tests/scripts/dev_tools/discovery/test_init_models.py
@@ -22,0 +23 @@ def test_real_file_system_delegates_to_pathlib(
+        """Record the existence query without inspecting a real path."""
@@ -26,0 +28 @@ def test_real_file_system_delegates_to_pathlib(
+        """Return the fixture's directory classification without disk access."""
@@ -30,0 +33 @@ def test_real_file_system_delegates_to_pathlib(
+        """Supply immutable child names and record the enumeration request."""
@@ -34,0 +38 @@ def test_real_file_system_delegates_to_pathlib(
+        """Record directory creation while leaving the real filesystem untouched."""
@@ -37,0 +42 @@ def test_real_file_system_delegates_to_pathlib(
+        """Return fixed text through the adapter's normal read interface."""
@@ -43,0 +49 @@ def test_real_file_system_delegates_to_pathlib(
+        """Record publication without writing the supplied text anywhere."""
@@ -75 +81 @@ def test_expected_template_relative_paths_has_eight_entries() -> None:
-    """The template/output path constants have the expected, index-aligned shape."""
+    """Frozen v1 constants remain import-compatible; they do not select v2 outputs."""
@@ -82,0 +89 @@ def test_expected_template_relative_paths_has_eight_entries() -> None:
+    # Preserve the frozen v1 path correspondence independently of v2 projection.
@@ -97,0 +105,10 @@ def test_resolve_default_template_root_returns_expected_path() -> None:
+
+
+def test_v2_template_layout_is_separate_from_frozen_legacy_constants() -> None:
+    """The new root workflow selects six closed templates without changing v1 paths."""
+    from drm_copilot_discovery.init_projection import ARTIFACT_TEMPLATES, TEMPLATE_NAMES
+
+    assert len(TEMPLATE_NAMES) == 6
+    assert TEMPLATE_NAMES[0] == "domain-profile.yaml"
+    assert {name for _, _, name in ARTIFACT_TEMPLATES} == set(TEMPLATE_NAMES[1:])
+    assert not any("feature-contract" in name for name in TEMPLATE_NAMES)
~~~
