# P4-T1 candidate patch

Accepted baseline: `a94c44fa31e66d830d01203ee9cc068fce2deef1`. Only analyzer-owned files are included; the separately owned loader prerequisite is excluded.

```diff
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/__init__.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/__init__.py
@@ -0,0 +1 @@
+"""Provide typed, read-only discovery analyzers with explicit guarded publication."""
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py
@@ -0,0 +1,228 @@
+"""Evidence Reference v1 serialization for the analyzer framework.
+
+Purpose:
+    Turn an ``EvidenceRecord`` into a discovery v1 Evidence Reference JSON
+    document string. This module owns the ``$schema`` relative-path computation
+    and deterministic serialization; the record owns the field-set assembly.
+
+Invariants / Constraints:
+    - ``$schema`` is a scheme-less relative POSIX path from the emitted instance
+      file to the schema file. It never contains a drive letter or a leading
+      ``/`` (absolute Windows paths are prohibited).
+    - Serialization is deterministic: ``json.dumps(..., sort_keys=True,
+      indent=2)``.
+    - Standard library only; no domain-specific identifiers.
+
+Side Effects:
+    None. Writing instances to disk is the caller's responsibility (via the
+    filesystem seam).
+"""
+
+from __future__ import annotations
+
+import hashlib
+import json
+import os
+from pathlib import PurePosixPath
+from typing import TYPE_CHECKING, cast
+
+from drm_copilot_discovery.analyzer.findings import row, seed_component, stable_id, tool
+from drm_copilot_discovery.analyzer.models import InventoryResult
+from drm_copilot_discovery.coverage_scope_rules import inventory_configuration_digest
+from drm_copilot_discovery.models import JsonObject, canonical_json
+from drm_copilot_discovery.schema_validation import validate_document
+
+if TYPE_CHECKING:
+    from pathlib import Path
+
+    from drm_copilot_discovery.analyzer.models import (
+        Analysis,
+        EvidenceRecord,
+        InventoryCapture,
+    )
+    from drm_copilot_discovery.catalog import SchemaCatalog
+
+
+def compute_schema_ref(instance_path: Path, schema_path: Path) -> str:
+    """Compute the scheme-less relative POSIX ``$schema`` path.
+
+    Args:
+        instance_path: Path of the emitted instance file.
+        schema_path: Path of the discovery v1 Evidence Reference schema file.
+
+    Returns:
+        A relative POSIX path from the instance file's directory to the schema
+        file, with no drive letter and no leading ``/``.
+
+    Raises:
+        ValueError: When a scheme-less relative path cannot be produced (for
+            example the paths are on different drives, or the result would be
+            absolute).
+    """
+    try:
+        relative = os.path.relpath(str(schema_path), start=str(instance_path.parent))
+    except ValueError as exc:
+        raise ValueError(
+            f"cannot compute a relative $schema path from {instance_path} "
+            f"to {schema_path}: {exc}"
+        ) from exc
+    posix = PurePosixPath(relative.replace(os.sep, "/")).as_posix()
+    if posix.startswith("/") or ":" in posix.split("/", 1)[0]:
+        raise ValueError(
+            f"computed $schema path is not scheme-less relative: {posix!r}"
+        )
+    return posix
+
+
+def serialize_record(
+    record: EvidenceRecord, instance_path: Path, schema_path: Path
+) -> str:
+    """Build and deterministically serialize an Evidence Reference instance.
+
+    Args:
+        record: The evidence record to serialize.
+        instance_path: Path where the instance will be written (drives ``$schema``).
+        schema_path: Path of the schema file that the instance references.
+
+    Returns:
+        The JSON text of the Evidence Reference instance with sorted keys.
+    """
+    schema_ref = compute_schema_ref(instance_path, schema_path)
+    document = record.to_json_dict(schema_ref)
+    return json.dumps(document, sort_keys=True, indent=2)
+
+
+def _ordered(rows: tuple[JsonObject, ...], key: str) -> tuple[JsonObject, ...]:
+    """Reject ambiguous adapter identities before returning deterministic row order.
+
+    rows (tuple[JsonObject, ...]) supply immutable adapter rows; key (str) names
+    their identifier field. Returns a sorted tuple. Raises ValueError for missing or
+    duplicate IDs; performs no I/O or mutation.
+    """
+    # Reject missing IDs before sorting can obscure an ambiguous adapter result.
+    keys = [item.get(key) for item in rows]
+    if any(not isinstance(key, str) for key in keys):
+        raise ValueError(f"Missing analyzer identifier: {key}")
+    if len(set(keys)) != len(keys):
+        raise ValueError(f"Duplicate analyzer identifier: {key}")
+    return tuple(sorted(rows, key=lambda item: cast("str", item[key])))
+
+
+def inventory_result(
+    capture: InventoryCapture,
+    analyses: tuple[Analysis, ...],
+    *,
+    analyzer_ids: tuple[str, ...],
+    timestamp: str,
+    author_or_agent: JsonObject,
+    catalog: SchemaCatalog,
+) -> InventoryResult:
+    """Validate complete deterministic inventory JSON and separate ledger proposals.
+
+    Required capture metadata is caller-supplied. Stable identity excludes it;
+    content hashes come from the retained input bytes used by the adapters.
+    Schema and cross-row failures raise ValueError; this function performs no I/O.
+
+    capture (InventoryCapture) supplies input hashes and configuration; analyses
+    (tuple[Analysis, ...]) contains adapter rows. analyzer_ids (tuple[str, ...]),
+    timestamp (str), author_or_agent (JsonObject), and catalog (SchemaCatalog) bind
+    implementation and provenance. Returns InventoryResult with immutable document
+    and ledger proposals. Raises ValueError for row, reference, limit or schema
+    failures; performs no I/O or mutation.
+    """
+    # Aggregate each row family independently while rejecting duplicate identities.
+    components = _ordered(
+        tuple(item for analysis in analyses for item in analysis.components),
+        "component_id",
+    )
+    # Findings retain their own stable IDs, separate from owning component IDs.
+    findings = _ordered(
+        tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
+    )
+    # Relationship order is independent of adapter execution or source walk order.
+    relationships = _ordered(
+        tuple(item for analysis in analyses for item in analysis.relationships),
+        "relationship_id",
+    )
+    # Stable diagnostic IDs let unavailable file rows point to exact failures.
+    diagnostics = _ordered(
+        tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
+    )
+    if (
+        sum(map(len, (components, findings, relationships, diagnostics)))
+        > capture.profile.limits.artifact_records
+    ):
+        raise ValueError("Analyzer result exceeds the configured record limit")
+    # References can bind only the components actually present in this result.
+    component_ids = {item["component_id"] for item in components}
+    # A detection may refer only to a component actually returned in this run.
+    for item in findings + relationships:
+        references = (
+            item.get("component_id"),
+            item.get("from_component_id"),
+            item.get("to_component_id"),
+        )
+        if any(
+            value is not None and value not in component_ids for value in references
+        ):
+            raise ValueError("Analyzer result contains a broken component reference")
+    # Preserve every selected/excluded/unreadable input with its captured digest.
+    files = tuple(
+        row(
+            path=item.path,
+            status=item.status,
+            sha256=item.sha256,
+            size=len(item.file.content) if item.file else None,
+            rationale=item.rationale,
+            # Associate errors with the input without inventing unavailable bytes.
+            diagnostic_ids=tuple(
+                d["id"] for d in diagnostics if d.get("path") == item.path
+            ),
+        )
+        for item in capture.inputs
+    )
+    # Semantic data excludes observation metadata so clock changes do not change IDs.
+    values = row(
+        **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
+        schema_version="2.0.0",
+        artifact_kind="inventory-snapshot",
+        repository=capture.profile.repository.id,
+        revision=capture.profile.repository.revision,
+        tool=tool("discovery-inventory"),
+        analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
+        scan_configuration_sha256=inventory_configuration_digest(capture.profile),
+        files=files,
+        components=components,
+        findings=findings,
+        relationships=relationships,
+        diagnostics=diagnostics,
+        exclusions=capture.exclusions,
+        extensions=row(),
+    )
+    document = JsonObject(
+        values.members
+        + (
+            ("id", stable_id("inventory", values)),
+            ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
+        )
+    )
+    # Validate the closed wire contract before exposing JSON or coverage proposals.
+    checked = validate_document(
+        canonical_json(document),
+        expected_kind="inventory-snapshot",
+        expected_version="2.0.0",
+        format="json",
+        catalog=catalog,
+        limits=capture.profile.limits.parse_limits(),
+    )
+    if not checked.ok:
+        raise ValueError(
+            "Invalid analyzer inventory: "
+            + "; ".join(finding.message for finding in checked.findings)
+        )
+    # Coverage proposals preserve detections without upgrading inspection state.
+    return InventoryResult(
+        document=document,
+        ledger_components=tuple(seed_component(item) for item in components),
+        semantic_sha256=hashlib.sha256(canonical_json(values)).hexdigest(),
+    )
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py
@@ -0,0 +1,142 @@
+"""Build deterministic analyzer identities and source-bound inert result rows.
+
+These helpers describe captured syntax and provenance. They never classify legacy
+feature behavior, decide target requirements, inspect a workspace, or write files.
+"""
+
+from __future__ import annotations
+
+import hashlib
+from typing import TYPE_CHECKING, cast
+
+from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
+
+
+def row(**values: JsonValue) -> JsonObject:
+    """Freeze one schema-shaped object, rejecting mutable/non-JSON descendants.
+
+    values (JsonValue keyword members) supply immutable schema fields. Returns a
+    JsonObject; raises ValueError for non-JSON descendants. Performs no I/O or input
+    mutation.
+    """
+    return JsonObject(tuple(values.items()))
+
+
+def stable_id(prefix: str, value: JsonValue) -> str:
+    """Bind a portable identifier to canonical semantic data, never timestamps.
+
+    prefix (str) labels the identifier; value (JsonValue) contains semantic fields.
+    Returns str containing the prefix and SHA-256. Invalid JSON raises ValueError;
+    no I/O or mutation occurs.
+    """
+    return prefix + "-" + hashlib.sha256(canonical_json(value)).hexdigest()
+
+
+def tool(identifier: str) -> JsonObject:
+    """Identify a built-in adapter implementation independently of caller labels.
+
+    identifier (str) is the fixed registered adapter name. Returns a JsonObject with
+    id and implementation version. Performs no I/O or mutation.
+    """
+    return row(id=identifier, version="2.0.0")
+
+
+def source_reference(capture: InventoryCapture, item: InventoryInput) -> JsonObject:
+    """Bind one inspected source to retained bytes and its configured full revision.
+
+    The separate provenance diagnostic retains an unverified pin; this reference
+    alone never proves the current working copy equals its immutable Git source.
+
+    capture (InventoryCapture) supplies the configured repository pin; item
+    (InventoryInput) supplies exact retained bytes. Returns a JsonObject source
+    descriptor. Raises ValueError for unavailable inputs; performs no I/O or
+    mutation.
+    """
+    if item.file is None or item.sha256 is None:
+        raise ValueError("Source references require inspected captured bytes")
+    return row(
+        repository=capture.profile.repository.id,
+        revision=capture.profile.repository.revision,
+        path=item.path,
+        sha256=item.sha256,
+    )
+
+
+def pinned_matches(capture: InventoryCapture, item: InventoryInput) -> bool:
+    """Compare retained bytes with matching pinned Git input; no hash rereads or I/O.
+
+    capture (InventoryCapture) holds previously captured Git objects; item
+    (InventoryInput) is the input to compare. Returns bool, false when bytes or
+    matching provenance are absent. Performs no I/O or mutation.
+    """
+    # All identity dimensions and exact bytes must agree before confidence increases.
+    return item.file is not None and any(
+        source.repository.id == capture.profile.repository.id
+        and source.repository.revision == capture.profile.repository.revision
+        and source.path == item.path
+        and source.content == item.file.content
+        for source in capture.repository_files
+    )
+
+
+def diagnostic(
+    code: str,
+    path: str | None,
+    message: str,
+    *,
+    analyzer: str = "repository",
+    blocking: bool = True,
+) -> JsonObject:
+    """Create a stable actionable diagnostic without OS-specific exception text.
+
+    code, message and analyzer (str) describe a fixed failure; path (str | None)
+    identifies its source and blocking (bool) selects severity. Returns a JsonObject
+    diagnostic. Performs no I/O or mutation.
+    """
+    identity = row(code=code, path=path, analyzer=analyzer)
+    return row(
+        id=stable_id("diagnostic", identity),
+        code=code,
+        severity="error" if blocking else "warning",
+        path=path,
+        message=message,
+        analyzer_id=analyzer,
+        blocking=blocking,
+        extensions=row(),
+    )
+
+
+def seed_component(component: JsonObject) -> JsonObject:
+    """Propose an uninspected, unassigned ledger row without changing authored scope.
+
+    The caller must align ledger inventory references with root-authored scope
+    before proposing publication. Detection never checks off discovery coverage.
+
+    component (JsonObject) must be a schema-valid detected component. Returns a
+    JsonObject coverage proposal with no feature assignments. Missing required
+    fields raise KeyError; performs no I/O or mutation.
+    """
+    source = cast("JsonObject", component["source"])
+    return row(
+        component_id=component["component_id"],
+        component_type=component["component_type"],
+        path=source["path"],
+        source_sha256=source["sha256"],
+        inspection_status="uninspected",
+        disposition="unassigned",
+        feature_refs=(),
+        tests_found=(),
+        runtime_validation_requirement="undetermined",
+        runtime_rationale=None,
+        exclusion_rationale=None,
+        exclusion_scope_ref=None,
+        supporting_rationale=None,
+        blocked_reason=None,
+        responsible_workflow="inventory-legacy-system",
+        responsible_agent=None,
+        last_updated_evidence_refs=(),
+        extensions=row(),
+    )
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py
@@ -0,0 +1,298 @@
+"""Capture bounded analyzer inputs without changing strict discovery snapshot loads.
+
+Only supplied metadata and byte readers perform I/O. Excluded frontiers are never
+descended; failed reads remain explicit rows with no fabricated file content.
+"""
+
+from __future__ import annotations
+
+import heapq
+from dataclasses import replace
+from fnmatch import fnmatchcase
+from typing import TYPE_CHECKING, cast
+
+from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
+from drm_copilot_discovery.models import JsonObject, canonical_json
+from drm_copilot_discovery.path_models import check_path_collisions
+from drm_copilot_discovery.snapshot import SnapshotFile
+from drm_copilot_discovery.snapshot_io import SnapshotIO, within_roots
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+    from drm_copilot_discovery.path_models import PathMetadataReader
+    from drm_copilot_discovery.profile_v2 import ProfileV2
+    from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryReader
+    from drm_copilot_discovery.snapshot import DiscoverySnapshot, InputCategory
+    from drm_copilot_discovery.snapshot_io import WorkspaceBytes
+
+MAX_CAPTURE_BYTES = 268435456
+
+
+def exclusion_rules(profile: ProfileV2) -> tuple[JsonObject, ...]:
+    """Return deterministic authored and output exclusions; no paths are read.
+
+    Generated discovery artifacts and evidence payloads cannot become production
+    inventory merely because a documentation root contains their output folders.
+
+    profile (ProfileV2) supplies validated selectors and output locations. Returns
+    tuple[JsonObject, ...] with deterministic unique exclusion rules. Performs no
+    I/O or profile mutation.
+    """
+    rules = list(profile.excluded_paths + profile.analyzers.ignored_paths)
+    outputs = cast("JsonObject", profile.document["artifacts"])
+    # Shared output locations require one exclusion regardless of artifact role.
+    paths = {cast("str", path) for path in outputs.values()}
+    paths.update(profile.evidence_roots)
+    # Preserve the configured boundary and reason instead of silently hiding it.
+    for path in sorted(paths):
+        rules.append(
+            JsonObject(
+                (
+                    ("path_or_glob", path),
+                    ("rationale", "Discovery artifact or evidence output."),
+                )
+            )
+        )
+    return tuple(sorted(set(rules), key=canonical_json))
+
+
+def exclusion_reason(path: str, rules: tuple[JsonObject, ...]) -> str | None:
+    """Match portable case-sensitive selectors and directory frontiers; pure.
+
+    A trailing /** also excludes the directory itself, so dependency/output trees
+    can be pruned before enumeration rather than after their descendants are read.
+
+    path (str) is a portable relative input; rules (tuple[JsonObject, ...]) are
+    validated exclusion selectors. Returns str rationale for the first deterministic
+    match, or None. Performs no I/O or mutation.
+    """
+    # Ordered matching makes overlapping authored reasons deterministic.
+    for rule in rules:
+        pattern = cast("str", rule["path_or_glob"])
+        prefix = pattern[:-3] if pattern.endswith("/**") else pattern
+        if (
+            fnmatchcase(path, pattern)
+            or fnmatchcase(path, prefix)
+            or (
+                not any(char in pattern for char in "*?[")
+                and path.startswith(pattern + "/")
+            )
+        ):
+            return cast("str", rule["rationale"])
+    return None
+
+
+def _category(path: str, profile: ProfileV2) -> InputCategory:
+    """Preserve selected source/test/documentation roles without inferring behavior.
+
+    path (str) is the selected relative input and profile (ProfileV2) defines root
+    ownership. Returns InputCategory for source, test or documentation. Unsafe path
+    syntax raises PathPolicyError; performs no I/O.
+    """
+    # Production/project ownership precedes tests, matching snapshot classification.
+    if (
+        within_roots(path, profile.production_roots)
+        or path in profile.project_entry_points
+    ):
+        return "source"
+    return "test" if within_roots(path, profile.test_roots) else "documentation"
+
+
+def capture_snapshot(snapshot: DiscoverySnapshot) -> InventoryCapture:
+    """Reuse exact accepted snapshot bytes and Git objects without additional reads.
+
+    Artifact/replica payloads retain their own categories and are not inventoried.
+    Exclusions must still resolve to current profile rules; unknown omissions fail.
+
+    snapshot (DiscoverySnapshot) supplies captured input categories, bytes and Git
+    objects. Returns InventoryCapture. Raises ValueError for unexplained exclusions
+    and ProfileError for draft configuration; performs no I/O or mutation.
+    """
+    rules = exclusion_rules(snapshot.profile)
+    # Retain only selected repository inputs; artifact payloads have separate roles.
+    inputs = [
+        InventoryInput(path=file.path, status="inspected", file=file)
+        for file in snapshot.manifest.files
+        if file.category in {"source", "test", "documentation"}
+    ]
+    # Every omitted frontier must remain explainable from the current configuration.
+    for path in snapshot.excluded_paths:
+        reason = exclusion_reason(path, rules)
+        if reason is None:
+            raise ValueError(f"Captured exclusion has no configured rationale: {path}")
+        inputs.append(InventoryInput(path=path, status="excluded", rationale=reason))
+    return InventoryCapture(
+        profile=snapshot.profile,
+        inputs=tuple(inputs),
+        exclusions=rules,
+        repository_files=snapshot.repository_files,
+    )
+
+
+def capture_inputs(
+    profile: ProfileV2,
+    *,
+    workspace_root: str,
+    metadata: PathMetadataReader,
+    read_bytes: WorkspaceBytes,
+    repository_files: tuple[RepositoryFile, ...] = (),
+) -> InventoryCapture:
+    """Read a configured tree through PathPolicy, keeping bounded failure accounting.
+
+    Missing/unreadable inputs become blocking analyzer rows. Unsafe paths, aliases,
+    resource exhaustion and inputs that change during capture fail the whole call.
+    Repository objects must already have been captured through the pinned reader.
+    This function never writes or launches processes, including during dry runs.
+
+    profile (ProfileV2) supplies scope and limits; workspace_root (str) is the
+    absolute trusted root. metadata (PathMetadataReader) and read_bytes
+    (WorkspaceBytes) are non-following injected readers. repository_files
+    (tuple[RepositoryFile, ...]) supplies retained pinned objects. Returns
+    InventoryCapture. Raises PathPolicyError, ProfileError, ValueError or OSError
+    for unsafe, incomplete, changed or over-budget state. Effects are bounded reads
+    through these seams only.
+    """
+    profile.require_configured()
+
+    def bounded_read(path: str, *, limit: int) -> bytes:
+        """Reject a broken byte adapter before SnapshotIO can retain partial state.
+
+        path (str) identifies the selected file and limit (int) bounds its
+        allocation. Returns immutable bytes. Raises OSError for adapter/type/size
+        failures; performs one injected read and never writes.
+        """
+        content = read_bytes(path, limit=limit)
+        if not isinstance(cast("object", content), bytes) or len(content) > limit:
+            raise OSError("Analyzer input exceeded its immutable-byte contract")
+        return content
+
+    # Bind non-following scope before allocating scan state or reading any bytes.
+    io = SnapshotIO(
+        workspace_root=workspace_root, metadata=metadata, read_bytes=bounded_read
+    )
+    io.bind(profile)
+    roots = (
+        profile.production_roots
+        + profile.test_roots
+        + profile.project_entry_points
+        + profile.documentation_roots
+    )
+    pending = list(check_path_collisions(sorted(set(roots))))
+    heapq.heapify(pending)
+    visited: set[str] = set()
+    inputs: list[InventoryInput] = []
+    rules = exclusion_rules(profile)
+    total_bytes = 0
+    # Bound aggregate allocation even when each selected file fits its own limit.
+    byte_budget = min(
+        profile.limits.source_files * profile.analyzers.max_file_bytes,
+        MAX_CAPTURE_BYTES,
+    )
+    # Ordinal traversal makes both successful input order and bounded failures stable.
+    while pending:
+        path = heapq.heappop(pending)
+        if path in visited:
+            continue
+        visited.add(path)
+        if len(visited) > profile.limits.source_files:
+            raise ValueError("Analyzer entry enumeration limit exceeded")
+        reason = exclusion_reason(path, rules)
+        # Prune configured frontiers before probing descendants or opening bytes.
+        if reason is not None:
+            inputs.append(
+                InventoryInput(path=path, status="excluded", rationale=reason)
+            )
+            continue
+        entry = io.inspect(path)
+        if entry.kind == "directory":
+            # Check the complete frontier before allocating or descending another tree.
+            if len(entry.children) > profile.limits.source_files:
+                raise ValueError("Analyzer directory enumeration limit exceeded")
+            # Keep all immediate children, including hidden and unfamiliar filenames.
+            for child in entry.children:
+                heapq.heappush(pending, f"{path}/{child}")
+            continue
+        try:
+            content = cast(
+                "bytes", io.read(path, limit=profile.analyzers.max_file_bytes)
+            )
+        except OSError:
+            inputs.append(
+                InventoryInput(
+                    path=path,
+                    status="unreadable",
+                    rationale="Input unavailable within the configured byte limit.",
+                )
+            )
+            continue
+        total_bytes += len(content)
+        if total_bytes > byte_budget:
+            raise ValueError("Analyzer aggregate byte limit exceeded")
+        inputs.append(
+            InventoryInput(
+                path=path,
+                status="inspected",
+                file=SnapshotFile(
+                    path=path, content=content, category=_category(path, profile)
+                ),
+            )
+        )
+    io.verify_unchanged()
+    return InventoryCapture(
+        profile=profile,
+        inputs=tuple(inputs),
+        exclusions=rules,
+        repository_files=repository_files,
+    )
+
+
+def pin_inventory_sources(
+    workspace: CapturedWorkspace, repository: RepositoryReader
+) -> CapturedWorkspace:
+    """Capture missing inventory Git objects using a trusted bounded local reader.
+
+    Apply this same explicit selection to every mutation writer capture, including
+    freshness reads before the first inventory exists. Ordinary snapshot loading
+    remains unchanged. A missing/mismatched Git object raises before publication;
+    working-copy bytes are never substituted for an unavailable repository blob.
+
+    workspace (CapturedWorkspace) supplies the complete baseline and repository
+    (RepositoryReader) supplies bounded pinned blobs. Returns a new
+    CapturedWorkspace preserving existing objects. Raises ValueError for reader
+    mismatch and OSError for inaccessible Git objects; reads only explicit local
+    repository paths and never writes.
+    """
+    snapshot = workspace.snapshot
+    capture = capture_snapshot(snapshot)
+    identity = repository.identity()
+    if (
+        identity.id != snapshot.profile.repository.id
+        or identity.revision != snapshot.profile.repository.revision
+    ):
+        raise ValueError(
+            "Inventory repository reader differs from the configured local pin"
+        )
+    objects = list(snapshot.repository_files)
+    # Reuse exact existing identities so repeated writer captures remain comparable.
+    existing = {(value.repository, value.path) for value in objects}
+    # Fetch only missing selected inputs; excluded and unavailable entries have no blob.
+    for item in capture.inputs:
+        if item.file is None or (identity, item.path) in existing:
+            continue
+        source = repository.read_file(
+            revision=cast("str", identity.revision),
+            path=item.path,
+            limit=snapshot.profile.analyzers.max_file_bytes,
+        )
+        if (
+            source.repository != identity
+            or source.path != item.path
+            or len(source.content) > snapshot.profile.analyzers.max_file_bytes
+        ):
+            raise ValueError(
+                "Inventory repository reader returned an unexpected object"
+            )
+        objects.append(source)
+    return replace(
+        workspace, snapshot=replace(snapshot, repository_files=tuple(objects))
+    )
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py
@@ -0,0 +1,328 @@
+"""The repository/project inventory analyzer and its pure helpers.
+
+Purpose:
+    Implement the first concrete ``Analyzer``: a language-neutral inventory of a
+    consumer repository's source tree. The four stages are:
+
+    - ``parse``: fail fast on an unreachable source root, then walk the tree via
+      the filesystem seam and return consumer-relative POSIX paths in
+      deterministic order.
+    - ``classify``: apply include/exclude glob filtering, then tag each surviving
+      unit with a neutral ``UnitType`` from a marker pattern table.
+    - ``map``: build one ``EvidenceRecord`` per inventoried unit.
+    - ``emit``: reject obsolete unguarded publication with an actionable error.
+
+Invariants / Constraints:
+    - Domain specificity is never hardcoded: classification markers are data
+      (injectable, defaulting to a generic, extensible pattern table), and the
+      source root and globs come from the run context. Generic project suffixes
+      imply only structural categories, never product behavior.
+    - ``AnalyzerError`` is a distinct ``ValueError`` subclass, separate from the
+      profile loader's ``DomainProfileError``.
+    - The filter and classification helpers are pure (no filesystem access).
+    - Matching uses ``fnmatch.fnmatchcase`` so results are deterministic and
+      platform-independent.
+
+Side Effects:
+    Legacy stage methods read through the injected seam. V2 analysis is pure.
+"""
+
+from __future__ import annotations
+
+import hashlib
+from fnmatch import fnmatchcase
+from pathlib import PurePosixPath
+from typing import TYPE_CHECKING
+
+from drm_copilot_discovery.analyzer.findings import (
+    diagnostic,
+    pinned_matches,
+    row,
+    source_reference,
+    stable_id,
+    tool,
+)
+from drm_copilot_discovery.analyzer.models import (
+    Analysis,
+    ClassifiedUnit,
+    ClassifyResult,
+    EvidenceRecord,
+    ParseResult,
+    UnitType,
+)
+from drm_copilot_discovery.analyzer.pipeline import RealAnalyzerFileSystem
+
+if TYPE_CHECKING:
+    from pathlib import Path
+
+    from drm_copilot_discovery.analyzer.models import AnalyzerContext, InventoryCapture
+    from drm_copilot_discovery.analyzer.pipeline import AnalyzerFileSystem
+    from drm_copilot_discovery.models import JsonObject
+
+# Generic, extensible marker table mapping a filename glob to a neutral unit
+# category. These filenames indicate build structure only. Consumers may supply
+# their own marker table without importing optional domain analyzers.
+DEFAULT_MARKERS: tuple[tuple[str, UnitType], ...] = (
+    ("*.sln", UnitType.SOLUTION),
+    ("*.slnx", UnitType.SOLUTION),
+    ("*.csproj", UnitType.PROJECT),
+    ("*.fsproj", UnitType.PROJECT),
+    ("*.vbproj", UnitType.PROJECT),
+    ("*.vcxproj", UnitType.PROJECT),
+    ("pyproject.toml", UnitType.PROJECT),
+    ("package.json", UnitType.PROJECT),
+    ("Cargo.toml", UnitType.PROJECT),
+    ("pom.xml", UnitType.PROJECT),
+    ("build.gradle", UnitType.PROJECT),
+)
+
+_DESCRIPTION = "Source file enumerated by the repository inventory analyzer."
+
+
+class AnalyzerError(ValueError):
+    """Raised when an analyzer cannot proceed (for example an unreachable root).
+
+    A distinct ``ValueError`` subclass so callers can catch it separately from
+    the profile loader's ``DomainProfileError``.
+    """
+
+
+def filter_paths(
+    paths: tuple[str, ...],
+    include: tuple[str, ...],
+    exclude: tuple[str, ...],
+) -> tuple[str, ...]:
+    """Apply include/exclude globs to consumer-relative POSIX paths (pure).
+
+    A path is retained when it matches at least one ``include`` pattern (or
+    ``include`` is empty, meaning all) and matches no ``exclude`` pattern. Order
+    is preserved.
+
+    Args:
+        paths: Ordered consumer-relative POSIX paths.
+        include: Include glob patterns; empty selects all.
+        exclude: Exclude glob patterns; empty excludes none.
+
+    Returns:
+        The filtered paths in their original order.
+    """
+    retained: list[str] = []
+    # Include first, then exclude, so explicit omissions always take precedence.
+    for path in paths:
+        included = not include or any(fnmatchcase(path, pat) for pat in include)
+        excluded = any(fnmatchcase(path, pat) for pat in exclude)
+        if included and not excluded:
+            retained.append(path)
+    return tuple(retained)
+
+
+def classify_unit(
+    relative_path: str, markers: tuple[tuple[str, UnitType], ...]
+) -> UnitType:
+    """Return the ``UnitType`` for one path from the marker table (pure).
+
+    The first marker whose glob matches the path's filename wins; a path that
+    matches no marker is a plain ``FILE``.
+
+    Args:
+        relative_path: Consumer-relative POSIX path.
+        markers: Ordered ``(filename_glob, UnitType)`` pairs.
+
+    Returns:
+        The matched ``UnitType`` or ``UnitType.FILE`` when no marker matches.
+    """
+    name = PurePosixPath(relative_path).name
+    # The first authored marker wins; unmatched paths remain ordinary files.
+    for pattern, unit_type in markers:
+        if fnmatchcase(name, pattern):
+            return unit_type
+    return UnitType.FILE
+
+
+def classify_paths(
+    paths: tuple[str, ...], markers: tuple[tuple[str, UnitType], ...]
+) -> tuple[ClassifiedUnit, ...]:
+    """Tag each path with its ``UnitType`` (pure)."""
+    # Preserve source order while attaching only the structural category.
+    return tuple(
+        ClassifiedUnit(relative_path=path, unit_type=classify_unit(path, markers))
+        for path in paths
+    )
+
+
+def _slug(relative_path: str) -> str:
+    """Return a stable identifier slug matching ``^[a-z0-9][a-z0-9._-]*$``."""
+    digest = hashlib.sha256(relative_path.encode("utf-8")).hexdigest()
+    return digest[:16]
+
+
+class InventoryAnalyzer:
+    """Language-neutral inventory analyzer implementing the ``Analyzer`` contract.
+
+    Args:
+        fs: Filesystem seam used by ``parse`` and ``map``; defaults to the real
+            filesystem implementation.
+        markers: Marker pattern table for classification; defaults to a generic,
+            extensible table.
+    """
+
+    name = "inventory"
+
+    def __init__(
+        self,
+        fs: AnalyzerFileSystem | None = None,
+        markers: tuple[tuple[str, UnitType], ...] | None = None,
+    ) -> None:
+        """Bind isolated legacy reads and caller-supplied structural markers.
+
+        fs (AnalyzerFileSystem | None) supplies reads; markers (tuple[tuple[str,
+        UnitType], ...] | None) overrides filename categories. Returns None and
+        initializes only instance-local state; performs no I/O.
+        """
+        self._fs: AnalyzerFileSystem = (
+            fs if fs is not None else RealAnalyzerFileSystem()
+        )
+        self._markers = markers if markers is not None else DEFAULT_MARKERS
+        self._ctx: AnalyzerContext | None = None
+
+    def _require_ctx(self) -> AnalyzerContext:
+        """Return the stashed run context, failing if ``parse`` did not run."""
+        if self._ctx is None:
+            raise AnalyzerError("analyzer context is unavailable; parse must run first")
+        return self._ctx
+
+    def parse(self, ctx: AnalyzerContext) -> ParseResult:
+        """Fail fast on an unreachable root, then walk and order the tree.
+
+        Args:
+            ctx: The resolved run context.
+
+        Returns:
+            Consumer-relative POSIX paths in deterministic POSIX-sorted order.
+
+        Raises:
+            AnalyzerError: When the source root does not exist or is not a
+                directory.
+        """
+        self._ctx = ctx
+        root = ctx.source_root
+        if not self._fs.exists(root) or not self._fs.is_dir(root):
+            raise AnalyzerError(f"source root is not reachable: {root}")
+        # Legacy consumers receive portable relative names instead of host paths.
+        relative_paths = [
+            file_path.relative_to(root).as_posix()
+            for file_path in self._fs.walk_files(root)
+        ]
+        return ParseResult(paths=tuple(sorted(relative_paths)))
+
+    def classify(self, parsed: ParseResult) -> ClassifyResult:
+        """Filter by include/exclude globs, then tag each surviving unit."""
+        ctx = self._require_ctx()
+        retained = filter_paths(parsed.paths, ctx.include, ctx.exclude)
+        return ClassifyResult(units=classify_paths(retained, self._markers))
+
+    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
+        """Build one ``EvidenceRecord`` per inventoried unit."""
+        ctx = self._require_ctx()
+        records: list[EvidenceRecord] = []
+        # Hash exactly the bytes read for each selected legacy record.
+        for unit in classified.units:
+            content = self._fs.read_bytes(ctx.source_root / unit.relative_path)
+            digest = hashlib.sha256(content).hexdigest()
+            records.append(
+                EvidenceRecord(
+                    id=f"inventory-{unit.unit_type.value}-{_slug(unit.relative_path)}",
+                    kind="file",
+                    location=unit.relative_path,
+                    captured_at=ctx.captured_at,
+                    description=_DESCRIPTION,
+                    content_hash=("sha256", digest),
+                    tool="dev.discovery.inventory",
+                    metadata=(
+                        ("unit_type", unit.unit_type.value),
+                        ("size_bytes", len(content)),
+                    ),
+                )
+            )
+        return tuple(records)
+
+    def emit(
+        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
+    ) -> tuple[Path, ...]:
+        """Reject legacy publication; v2 writes require an explicit mutation plan.
+
+        records (tuple[EvidenceRecord, ...]) and fs (AnalyzerFileSystem) are
+        compatibility inputs. This method always raises AnalyzerError instead of
+        returning paths. It performs no writes or other I/O.
+        """
+        raise AnalyzerError(
+            "Legacy emission is disabled; use guarded v2 inventory publication"
+        )
+
+
+class RepositoryAnalyzer:
+    """Detect repository/project units from captured names and bytes without I/O.
+
+    Structural filename classification is a detected fact, not feature semantics.
+    A pin mismatch remains a blocking diagnostic and never becomes verified proof.
+    """
+
+    identifier = "repository"
+
+    def analyze(self, capture: InventoryCapture) -> Analysis:
+        """Return source-bound components and explicit input/provenance failures.
+
+        capture (InventoryCapture) supplies sorted selected files and retained
+        provenance. Returns Analysis with component rows and diagnostics;
+        unavailable inputs never acquire component claims. Performs no I/O or
+        mutation.
+        """
+        components: list[JsonObject] = []
+        diagnostics: list[JsonObject] = []
+        # Keep unavailable inputs explicit; only retained bytes produce components.
+        for item in capture.inputs:
+            # Read failures block discovery; exclusions retain input accounting.
+            if item.status == "unreadable":
+                diagnostics.append(
+                    diagnostic(
+                        "input-unreadable",
+                        item.path,
+                        item.rationale or "Input unavailable.",
+                    )
+                )
+                continue
+            if item.file is None:
+                continue
+            source = source_reference(capture, item)
+            pinned = pinned_matches(capture, item)
+            if not pinned:
+                diagnostics.append(
+                    diagnostic(
+                        "source-revision-unverified",
+                        item.path,
+                        "Capture matching immutable repository bytes "
+                        "before publishing this inventory.",
+                    )
+                )
+            component_type = classify_unit(item.path, DEFAULT_MARKERS).value
+            identity = row(
+                repository=source["repository"],
+                path=item.path,
+                component_type=component_type,
+            )
+            components.append(
+                row(
+                    component_id=stable_id("component", identity),
+                    component_type=component_type,
+                    source=source,
+                    analyzer=tool(self.identifier),
+                    classification="detected",
+                    confidence="high" if pinned else "low",
+                    properties=(
+                        row(name="input-category", value=item.file.category),
+                        row(name="size-bytes", value=len(item.file.content)),
+                    ),
+                    extensions=row(),
+                )
+            )
+        return Analysis(components=tuple(components), diagnostics=tuple(diagnostics))
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py
@@ -0,0 +1,293 @@
+"""Freeze legacy compatibility records and versioned analyzer input/result values.
+
+Legacy carriers preserve import and serialization contracts. V2 inputs retain
+exact bytes and truthful unavailable-input accounting; outputs keep inventory
+separate from uninspected ledger proposals. Construction performs no I/O.
+"""
+
+from __future__ import annotations
+
+from dataclasses import dataclass, field
+from enum import Enum
+from typing import TYPE_CHECKING, Literal, cast
+
+from drm_copilot_discovery.models import JsonObject
+from drm_copilot_discovery.path_models import check_path_collisions, relative_path
+from drm_copilot_discovery.snapshot import SnapshotFile
+
+if TYPE_CHECKING:
+    from pathlib import Path
+
+    from drm_copilot_discovery.profile_v2 import ProfileV2
+    from drm_copilot_discovery.repository_reader import RepositoryFile
+
+# Value permitted for the emitted ``schema_version`` field; matches ^1\.\d+\.\d+$.
+SCHEMA_VERSION_V1 = "1.0.0"
+
+
+class UnitType(str, Enum):
+    """Neutral category of an enumerated inventory unit.
+
+    A ``str`` enum so members compare and serialize as their plain string value.
+    The three members are generic structural categories, not stack-specific
+    identifiers.
+    """
+
+    FILE = "file"
+    PROJECT = "project"
+    SOLUTION = "solution"
+
+
+@dataclass(frozen=True, slots=True)
+class AnalyzerContext:
+    """Resolved inputs for a single analyzer run.
+
+    Args:
+        source_root: Resolved consumer source root to enumerate.
+        include: Glob patterns selecting files; empty means all files.
+        exclude: Glob patterns excluding files; empty excludes none.
+        artifact_root: Resolved output root where instances are written.
+        schema_path: Path to the discovery v1 Evidence Reference schema file,
+            used to compute each instance's scheme-less relative ``$schema``.
+        captured_at: ISO-8601 timestamp supplied by an injected clock.
+    """
+
+    source_root: Path
+    include: tuple[str, ...]
+    exclude: tuple[str, ...]
+    artifact_root: Path
+    schema_path: Path
+    captured_at: str
+
+
+@dataclass(frozen=True, slots=True)
+class ParseResult:
+    """Ordered consumer-relative POSIX file paths produced by the walk.
+
+    Args:
+        paths: Deterministically ordered consumer-relative POSIX paths.
+    """
+
+    paths: tuple[str, ...]
+
+
+@dataclass(frozen=True, slots=True)
+class ClassifiedUnit:
+    """A single enumerated unit tagged with its neutral ``UnitType``.
+
+    Args:
+        relative_path: Consumer-relative POSIX path of the unit.
+        unit_type: Neutral structural category of the unit.
+    """
+
+    relative_path: str
+    unit_type: UnitType
+
+
+@dataclass(frozen=True, slots=True)
+class ClassifyResult:
+    """The filtered, classified units of one run.
+
+    Args:
+        units: Ordered classified units that survived include/exclude filtering.
+    """
+
+    units: tuple[ClassifiedUnit, ...]
+
+
+@dataclass(frozen=True, slots=True)
+class EvidenceRecord:
+    """A typed carrier for one Evidence Reference instance.
+
+    The ``$schema`` value is supplied at serialization time because it depends on
+    the emitted instance's own location relative to the schema file.
+
+    Args:
+        id: Stable identifier matching ``^[a-z0-9][a-z0-9._-]*$``.
+        kind: Evidence kind enum value (``"file"`` for enumerated source files).
+        location: Consumer-relative POSIX path of the referenced artifact.
+        captured_at: ISO-8601 timestamp supplied by an injected clock.
+        description: Domain-neutral human-readable summary.
+        schema_version: Instance schema version matching ``^1\\.\\d+\\.\\d+$``.
+        content_hash: Optional ``(algorithm, value)`` integrity digest.
+        tool: Optional label of the producing tool.
+        metadata: Optional ordered free-form ``(key, value)`` extras.
+    """
+
+    id: str
+    kind: str
+    location: str
+    captured_at: str
+    description: str
+    schema_version: str = SCHEMA_VERSION_V1
+    content_hash: tuple[str, str] | None = None
+    tool: str | None = None
+    metadata: tuple[tuple[str, str | int], ...] = field(default_factory=tuple)
+
+    def to_json_dict(self, schema_ref: str) -> dict[str, object]:
+        """Serialize this record to the Evidence Reference v1 field set.
+
+        Args:
+            schema_ref: Scheme-less relative POSIX path from the emitted instance
+                file to the schema file, computed by the emitter.
+
+        Returns:
+            A mapping with the required fields plus any present optional fields.
+            No field is emitted outside the schema's declared set except the
+            free-form ``metadata`` object.
+        """
+        document: dict[str, object] = {
+            "$schema": schema_ref,
+            "schema_version": self.schema_version,
+            "id": self.id,
+            "kind": self.kind,
+            "location": self.location,
+            "captured_at": self.captured_at,
+            "description": self.description,
+        }
+        if self.content_hash is not None:
+            algorithm, value = self.content_hash
+            document["content_hash"] = {"algorithm": algorithm, "value": value}
+        if self.tool is not None:
+            document["tool"] = self.tool
+        if self.metadata:
+            document["metadata"] = {key: value for key, value in self.metadata}
+        return document
+
+
+@dataclass(frozen=True, slots=True)
+class AnalyzerRunResult:
+    """The outcome of one ``run_analyzer`` invocation.
+
+    Args:
+        records: The evidence records built by the ``map`` stage.
+        written_paths: Empty for read-only legacy runs; publication moved to v2.
+    """
+
+    records: tuple[EvidenceRecord, ...]
+    written_paths: tuple[Path, ...]
+
+
+@dataclass(frozen=True, kw_only=True)
+class InventoryInput:
+    """Account for one selected input without inventing bytes for failed reads.
+
+    Construct after bounded capture. Only inspected inputs carry SnapshotFile;
+    excluded/unreadable inputs require a rationale. The cached digest describes
+    the exact bytes later analyzed. Construction performs no I/O or writes.
+    """
+
+    path: str
+    status: Literal["inspected", "excluded", "unreadable"]
+    file: SnapshotFile | None = None
+    rationale: str | None = None
+    sha256: str | None = field(init=False, default=None)
+
+    def __post_init__(self) -> None:
+        """Validate input state; raise ValueError for dishonest accounting; pure.
+
+        Uses the declared path (str), status (literal), file (SnapshotFile | None)
+        and rationale (str | None) fields. Returns None; raises ValueError for
+        contradictory state or unsafe paths. Initializes only the cached digest;
+        performs no I/O.
+        """
+        relative_path(self.path)
+        if self.status not in {"inspected", "excluded", "unreadable"}:
+            raise ValueError("Unknown inventory input status")
+        # Captured bytes and failed/excluded observations are mutually exclusive.
+        if self.status == "inspected":
+            if (
+                not isinstance(self.file, SnapshotFile)
+                or self.file.path != self.path
+                or self.rationale is not None
+            ):
+                raise ValueError("Inspected inputs require exact captured bytes")
+            object.__setattr__(self, "sha256", self.file.sha256)
+        elif (
+            self.file is not None
+            or not isinstance(self.rationale, str)
+            or not self.rationale.strip()
+        ):
+            raise ValueError("Unavailable inputs require rationale and no bytes")
+
+
+@dataclass(frozen=True, kw_only=True)
+class InventoryCapture:
+    """Freeze configured scan inputs, explicit omissions and pinned Git bytes.
+
+    Feed this value to registered analyzers. It describes reading, not feature
+    inspection or completion. Repository objects are retained only when already
+    captured; their absence never becomes a fabricated revision verification.
+    Construction sorts/detaches collections and has no external side effects.
+    """
+
+    profile: ProfileV2
+    inputs: tuple[InventoryInput, ...]
+    exclusions: tuple[JsonObject, ...] = ()
+    repository_files: tuple[RepositoryFile, ...] = ()
+
+    def __post_init__(self) -> None:
+        """Require configured profile and typed unique inputs; return None or fail.
+
+        Uses profile (ProfileV2), inputs (tuple[InventoryInput, ...]), exclusions
+        and repository_files from construction. Returns None; raises ValueError or
+        ProfileError for invalid scope, types, collisions or limits. Freezes only
+        this instance and performs no I/O.
+        """
+        from drm_copilot_discovery.profile_v2 import ProfileV2
+
+        if not isinstance(cast("object", self.profile), ProfileV2):
+            raise ValueError("Inventory requires a validated profile")
+        self.profile.require_configured()
+        inputs = tuple(self.inputs)
+        if any(not isinstance(cast("object", item), InventoryInput) for item in inputs):
+            raise ValueError("Inventory requires typed captured inputs")
+        check_path_collisions(item.path for item in inputs)
+        if len(inputs) > self.profile.limits.source_files:
+            raise ValueError("Inventory input count exceeds the configured limit")
+        object.__setattr__(
+            self, "inputs", tuple(sorted(inputs, key=lambda item: item.path))
+        )
+        object.__setattr__(self, "exclusions", tuple(self.exclusions))
+        object.__setattr__(self, "repository_files", tuple(self.repository_files))
+
+
+@dataclass(frozen=True, kw_only=True)
+class Analysis:
+    """Carry inert, schema-shaped adapter findings before aggregate validation.
+
+    Registered adapters return immutable rows; the runner validates their complete
+    inventory. No row changes coverage dispositions or authorizes publication.
+    """
+
+    components: tuple[JsonObject, ...] = ()
+    findings: tuple[JsonObject, ...] = ()
+    relationships: tuple[JsonObject, ...] = ()
+    diagnostics: tuple[JsonObject, ...] = ()
+
+    def __post_init__(self) -> None:
+        """Detach and type-check each row family; raise ValueError without I/O.
+
+        Uses the four tuple[JsonObject, ...] result fields. Returns None and freezes
+        their containers. Raises ValueError for untyped rows; performs no I/O and
+        never mutates caller containers.
+        """
+        # Adapters cannot retain mutable arrays inside a supposedly frozen result.
+        for name in ("components", "findings", "relationships", "diagnostics"):
+            rows = tuple(cast("tuple[JsonObject, ...]", getattr(self, name)))
+            if any(not isinstance(cast("object", row), JsonObject) for row in rows):
+                raise ValueError("Analyzer rows must be immutable JSON objects")
+            object.__setattr__(self, name, rows)
+
+
+@dataclass(frozen=True, kw_only=True)
+class InventoryResult:
+    """Keep validated inventory bytes and separate, unpublished coverage proposals.
+
+    Semantic identity excludes capture metadata, so repeated observations retain
+    identity. Neither this value nor its ledger rows grant mutation permission.
+    """
+
+    document: JsonObject
+    ledger_components: tuple[JsonObject, ...]
+    semantic_sha256: str
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py
@@ -0,0 +1,270 @@
+"""Analyzer pipeline abstraction, filesystem seam, and the thin runner.
+
+Purpose:
+    Define the host-neutral framework contract that concrete analyzers plug into:
+    the ``Analyzer`` protocol (four ordered stages), the ``AnalyzerFileSystem``
+    seam that isolates disk access, a read-only compatibility implementation, and the
+    ``run_analyzer`` runner that drives the stages deterministically.
+
+Invariants / Constraints:
+    - ``Analyzer`` is a ``typing.Protocol`` (multiple implementations expected):
+      this feature's inventory analyzer plus future stack-specific analyzers.
+    - Protocol stage bodies are ``...`` (type-only; excluded from coverage).
+    - ``run_analyzer`` invokes ``parse -> classify -> map`` in that fixed order.
+      Legacy emission is disabled; v2 publication requires a guarded mutation.
+    - Enumeration/classification logic depends on the seam or plain data so it is
+      testable without temporary files.
+
+Side Effects:
+    ``RealAnalyzerFileSystem`` reads the filesystem and rejects legacy writes.
+    V2 adapters consume retained bytes; mutation planning itself never writes.
+"""
+
+from __future__ import annotations
+
+from typing import TYPE_CHECKING, Protocol, cast, runtime_checkable
+
+from drm_copilot_discovery.analyzer.models import AnalyzerRunResult
+
+if TYPE_CHECKING:
+    from pathlib import Path
+
+    from drm_copilot_discovery.agent_output import InvocationContext
+    from drm_copilot_discovery.analyzer.models import (
+        AnalyzerContext,
+        ClassifyResult,
+        EvidenceRecord,
+        InventoryCapture,
+        InventoryResult,
+        ParseResult,
+    )
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.models import JsonObject
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
+    from drm_copilot_discovery.path_models import WriteGrant
+
+
+@runtime_checkable
+class AnalyzerFileSystem(Protocol):
+    """Disk-operation seam required by analyzers.
+
+    Existence/type checks, recursive walking and byte reads retain legacy call
+    compatibility. write_text remains in the protocol but the real adapter rejects
+    it; guarded v2 mutation owns publication. Tests use isolated memory stores.
+    """
+
+    def exists(self, path: Path) -> bool:
+        """Return whether ``path`` exists."""
+        ...
+
+    def is_dir(self, path: Path) -> bool:
+        """Return whether ``path`` is a directory."""
+        ...
+
+    def walk_files(self, root: Path) -> tuple[Path, ...]:
+        """Return every file path beneath ``root`` (directories excluded)."""
+        ...
+
+    def read_bytes(self, path: Path) -> bytes:
+        """Return the byte content of the file at ``path``."""
+        ...
+
+    def write_text(self, path: Path, content: str) -> None:
+        """Write ``content`` to ``path`` as UTF-8, creating parent directories."""
+        ...
+
+
+class Analyzer(Protocol):
+    """Legacy analyzer contract retained for existing stack adapters.
+
+    A concrete analyzer plugs into ``run_analyzer`` by implementing ``name`` and
+    its stage methods. The runner invokes only the three read stages; emit remains
+    a compatibility method and does not participate in automatic publication.
+    """
+
+    name: str
+
+    def parse(self, ctx: AnalyzerContext) -> ParseResult:
+        """Read inputs described by ``ctx`` and return the parse result."""
+        ...
+
+    def classify(self, parsed: ParseResult) -> ClassifyResult:
+        """Filter and tag the parsed units."""
+        ...
+
+    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
+        """Build one evidence record per classified unit."""
+        ...
+
+    def emit(
+        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
+    ) -> tuple[Path, ...]:
+        """Write one artifact per record via the seam and return their paths."""
+        ...
+
+
+class RealAnalyzerFileSystem:
+    """Filesystem seam backed by ``pathlib.Path`` operations."""
+
+    def exists(self, path: Path) -> bool:
+        """Return whether ``path`` exists on disk."""
+        return path.exists()
+
+    def is_dir(self, path: Path) -> bool:
+        """Return whether ``path`` is a directory on disk."""
+        return path.is_dir()
+
+    def walk_files(self, root: Path) -> tuple[Path, ...]:
+        """Return every file beneath ``root`` via an iterative directory walk."""
+        collected: list[Path] = []
+        stack: list[Path] = [root]
+        # Preserve the legacy read seam while returning files from every visited tree.
+        while stack:
+            current = stack.pop()
+            # Recurse into directories and retain ordinary file entries separately.
+            for child in current.iterdir():
+                if child.is_dir():
+                    stack.append(child)
+                else:
+                    collected.append(child)
+        return tuple(collected)
+
+    def read_bytes(self, path: Path) -> bytes:
+        """Return the byte content of the file at ``path``."""
+        return path.read_bytes()
+
+    def write_text(self, path: Path, content: str) -> None:
+        """Reject unguarded legacy writes before creating any file or directory.
+
+        path (Path) and content (str) are retained compatibility parameters. Always
+        raises ValueError, returning no result; performs no filesystem operations.
+        """
+        raise ValueError(
+            "Legacy writes are disabled; use guarded v2 inventory publication"
+        )
+
+
+def run_analyzer(
+    analyzer: Analyzer,
+    ctx: AnalyzerContext,
+    fs: AnalyzerFileSystem,
+    *,
+    dry_run: bool = False,
+) -> AnalyzerRunResult:
+    """Run legacy classification without emission, including explicit dry runs.
+
+    Args:
+        analyzer: The concrete analyzer to run.
+        ctx: The resolved run context.
+        fs: Retained compatibility parameter; never used for publication.
+        dry_run: Explicit read-only intent; the default is also read-only.
+
+    Returns:
+        Retained evidence records and an empty written_paths tuple.
+
+    Parameters analyzer (Analyzer), ctx (AnalyzerContext) and fs
+    (AnalyzerFileSystem) retain legacy call compatibility; dry_run (bool) cannot
+    enable writes. Returns AnalyzerRunResult. Adapter read/classification failures
+    propagate; only adapter-owned reads may occur.
+    """
+    parsed = analyzer.parse(ctx)
+    classified = analyzer.classify(parsed)
+    records = analyzer.map(classified)
+    return AnalyzerRunResult(records=records, written_paths=())
+
+
+def run_inventory(
+    capture: InventoryCapture,
+    *,
+    timestamp: str,
+    author_or_agent: JsonObject,
+    catalog: SchemaCatalog,
+    dry_run: bool = False,
+) -> InventoryResult:
+    """Run configured adapters over frozen bytes; default and dry-run never write.
+
+    Capture timestamp and author are explicit inputs. Neither invocation performs
+    repository reads or grants publication; failures propagate before any output.
+
+    capture (InventoryCapture) supplies immutable bytes; timestamp (str),
+    author_or_agent (JsonObject) and catalog (SchemaCatalog) provide validated
+    provenance/schema inputs. dry_run (bool) expresses read-only intent. Returns
+    InventoryResult; configuration or validation failures raise ValueError. Performs
+    no I/O or mutation.
+    """
+    from drm_copilot_discovery.analyzer.emitter import inventory_result
+    from drm_copilot_discovery.analyzer.registry import select_analyzers
+
+    adapters = select_analyzers(capture.profile)
+    # Execute only fixed selected adapters over the same immutable input bytes.
+    return inventory_result(
+        capture,
+        tuple(adapter.analyze(capture) for adapter in adapters),
+        analyzer_ids=tuple(adapter.identifier for adapter in adapters),
+        timestamp=timestamp,
+        author_or_agent=author_or_agent,
+        catalog=catalog,
+    )
+
+
+def plan_inventory(
+    baseline: CapturedWorkspace,
+    result: InventoryResult,
+    *,
+    grants: tuple[WriteGrant, ...],
+    invocation: InvocationContext | None = None,
+) -> MutationPlan:
+    """Plan one inventory publication using exact caller-authenticated grants.
+
+    Reconstruct results from the captured baseline before trusting their bytes.
+    Ledger seed rows remain proposals: analysts receive no scope-writing grant.
+    The returned plan is committed only via the existing commit_mutation boundary.
+
+    baseline (CapturedWorkspace) supplies the exact complete input state; result
+    (InventoryResult) is rederived from it. grants (tuple[WriteGrant, ...]) and
+    invocation (InvocationContext | None) must be authenticated by the caller.
+    Returns MutationPlan; raises MutationError or ValueError for changed inputs,
+    diagnostics, schema failures or unauthorized paths. Performs no I/O, publication
+    or authority changes.
+    """
+    from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
+    from drm_copilot_discovery.models import canonical_json
+    from drm_copilot_discovery.mutation_plan import (
+        MutationChange,
+        MutationError,
+        plan_mutation,
+    )
+
+    metadata = cast("JsonObject", result.document["capture"])
+    # Reconstruct accepted inputs before treating returned data as a request.
+    expected = run_inventory(
+        capture_snapshot(baseline.snapshot),
+        timestamp=cast("str", metadata["timestamp"]),
+        author_or_agent=cast("JsonObject", metadata["author_or_agent"]),
+        catalog=baseline.snapshot.catalog,
+    )
+    if result != expected:
+        raise MutationError(
+            "INVENTORY_INPUTS", "Inventory differs from the exact captured baseline"
+        )
+    if any(
+        diagnostic["blocking"]
+        for diagnostic in cast("tuple[JsonObject, ...]", result.document["diagnostics"])
+    ):
+        raise MutationError(
+            "INVENTORY_BLOCKED", "Resolve inventory diagnostics before publication"
+        )
+    identifier = cast("str", result.document["id"])
+    path = baseline.snapshot.profile.artifacts["inventory"] + "/" + identifier + ".json"
+    # Existing identical inventory content still carries its exact CAS precondition.
+    previous = next(
+        (file for file in baseline.snapshot.manifest.files if file.path == path), None
+    )
+    change = MutationChange(
+        artifact_kind="inventory-snapshot",
+        artifact_id=identifier,
+        path=path,
+        content=canonical_json(result.document),
+        expected_sha256=previous.sha256 if previous else None,
+    )
+    return plan_mutation(baseline, (change,), grants=grants, invocation=invocation)
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py
@@ -0,0 +1,57 @@
+"""Select explicit built-in analyzers without importing optional domain adapters.
+
+Profiles select inert identifiers; they cannot name executable Python modules.
+Additional approved adapters are registered at this boundary by later slices.
+"""
+
+from __future__ import annotations
+
+from typing import TYPE_CHECKING, Protocol
+
+from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture
+    from drm_copilot_discovery.profile_v2 import ProfileV2
+
+
+class InventoryAdapter(Protocol):
+    """Analyze one immutable capture and return source-bound rows without I/O."""
+
+    @property
+    def identifier(self) -> str:
+        """Expose the fixed registry identifier, not a caller-selected import path.
+
+        Returns str naming this adapter; takes no arguments and performs no I/O.
+        """
+        ...
+
+    def analyze(self, capture: InventoryCapture) -> Analysis:
+        """Return deterministic detections without altering capture or coverage.
+
+        capture (InventoryCapture) supplies immutable configured inputs. Returns
+        Analysis containing detections and diagnostics. Invalid adapter inputs raise
+        ValueError; implementations must not perform I/O or mutate inputs.
+        """
+        ...
+
+
+def select_analyzers(profile: ProfileV2) -> tuple[InventoryAdapter, ...]:
+    """Resolve configured built-ins or fail before any analysis/publication.
+
+    Unknown and not-yet-installed adapters never silently fall back to repository
+    analysis. Core enumeration imports no optional domain-specific packages.
+
+    profile (ProfileV2) supplies the validated configured selection. Returns a
+    sorted tuple of InventoryAdapter implementations. Raises ProfileError for draft
+    configuration and ValueError for unavailable selections; performs no I/O.
+    """
+    profile.require_configured()
+    enabled = tuple(sorted(profile.analyzers.enabled))
+    unsupported = set(enabled) - {"repository"}
+    if unsupported or not enabled:
+        raise ValueError(
+            "Unavailable analyzer selection; configure supported adapters: "
+            + ", ".join(sorted(unsupported))
+        )
+    return (RepositoryAnalyzer(),)
--- a/scripts/dev_tools/discovery/analyzer/emitter.py
+++ b/scripts/dev_tools/discovery/analyzer/emitter.py
@@ -1,80 +1,8 @@
-"""Evidence Reference v1 serialization for the analyzer framework.
+"""Preserve legacy imports while the installable discovery runtime owns behavior."""

-Purpose:
-    Turn an ``EvidenceRecord`` into a discovery v1 Evidence Reference JSON
-    document string. This module owns the ``$schema`` relative-path computation
-    and deterministic serialization; the record owns the field-set assembly.
-
-Invariants / Constraints:
-    - ``$schema`` is a scheme-less relative POSIX path from the emitted instance
-      file to the schema file. It never contains a drive letter or a leading
-      ``/`` (absolute Windows paths are prohibited).
-    - Serialization is deterministic: ``json.dumps(..., sort_keys=True,
-      indent=2)``.
-    - Standard library only; no domain-specific identifiers.
-
-Side Effects:
-    None. Writing instances to disk is the caller's responsibility (via the
-    filesystem seam).
-"""
-
-from __future__ import annotations
-
-import json
-import os
-from pathlib import PurePosixPath
-from typing import TYPE_CHECKING
-
-if TYPE_CHECKING:
-    from pathlib import Path
-
-    from scripts.dev_tools.discovery.analyzer.models import EvidenceRecord
-
-
-def compute_schema_ref(instance_path: Path, schema_path: Path) -> str:
-    """Compute the scheme-less relative POSIX ``$schema`` path.
-
-    Args:
-        instance_path: Path of the emitted instance file.
-        schema_path: Path of the discovery v1 Evidence Reference schema file.
-
-    Returns:
-        A relative POSIX path from the instance file's directory to the schema
-        file, with no drive letter and no leading ``/``.
-
-    Raises:
-        ValueError: When a scheme-less relative path cannot be produced (for
-            example the paths are on different drives, or the result would be
-            absolute).
-    """
-    try:
-        relative = os.path.relpath(str(schema_path), start=str(instance_path.parent))
-    except ValueError as exc:
-        raise ValueError(
-            f"cannot compute a relative $schema path from {instance_path} "
-            f"to {schema_path}: {exc}"
-        ) from exc
-    posix = PurePosixPath(relative.replace(os.sep, "/")).as_posix()
-    if posix.startswith("/") or ":" in posix.split("/", 1)[0]:
-        raise ValueError(
-            f"computed $schema path is not scheme-less relative: {posix!r}"
-        )
-    return posix
-
-
-def serialize_record(
-    record: EvidenceRecord, instance_path: Path, schema_path: Path
-) -> str:
-    """Build and deterministically serialize an Evidence Reference instance.
-
-    Args:
-        record: The evidence record to serialize.
-        instance_path: Path where the instance will be written (drives ``$schema``).
-        schema_path: Path of the schema file that the instance references.
-
-    Returns:
-        The JSON text of the Evidence Reference instance with sorted keys.
-    """
-    schema_ref = compute_schema_ref(instance_path, schema_path)
-    document = record.to_json_dict(schema_ref)
-    return json.dumps(document, sort_keys=True, indent=2)
+from drm_copilot_discovery.analyzer.emitter import (
+    compute_schema_ref as compute_schema_ref,
+)
+from drm_copilot_discovery.analyzer.emitter import (
+    serialize_record as serialize_record,
+)
--- a/scripts/dev_tools/discovery/analyzer/inventory.py
+++ b/scripts/dev_tools/discovery/analyzer/inventory.py
@@ -1,231 +1,20 @@
-"""The repository/project inventory analyzer and its pure helpers.
+"""Preserve legacy imports while the installable discovery runtime owns behavior."""

-Purpose:
-    Implement the first concrete ``Analyzer``: a language-neutral inventory of a
-    consumer repository's source tree. The four stages are:
-
-    - ``parse``: fail fast on an unreachable source root, then walk the tree via
-      the filesystem seam and return consumer-relative POSIX paths in
-      deterministic order.
-    - ``classify``: apply include/exclude glob filtering, then tag each surviving
-      unit with a neutral ``UnitType`` from a marker pattern table.
-    - ``map``: build one ``EvidenceRecord`` per inventoried unit.
-    - ``emit``: write one Evidence Reference instance per record via the seam.
-
-Invariants / Constraints:
-    - Domain specificity is never hardcoded: classification markers are data
-      (injectable, defaulting to a generic, extensible pattern table), and the
-      source root and globs come from the run context. No stack-specific literal
-      appears in this module.
-    - ``AnalyzerError`` is a distinct ``ValueError`` subclass, separate from the
-      profile loader's ``DomainProfileError``.
-    - The filter and classification helpers are pure (no filesystem access).
-    - Matching uses ``fnmatch.fnmatchcase`` so results are deterministic and
-      platform-independent.
-
-Side Effects:
-    Stage methods read and write through the injected filesystem seam only.
-"""
-
-from __future__ import annotations
-
-import hashlib
-from fnmatch import fnmatchcase
-from pathlib import PurePosixPath
-from typing import TYPE_CHECKING
-
-from scripts.dev_tools.discovery.analyzer.emitter import serialize_record
-from scripts.dev_tools.discovery.analyzer.models import (
-    ClassifiedUnit,
-    ClassifyResult,
-    EvidenceRecord,
-    ParseResult,
-    UnitType,
+from drm_copilot_discovery.analyzer.inventory import (
+    DEFAULT_MARKERS as DEFAULT_MARKERS,
 )
-from scripts.dev_tools.discovery.analyzer.pipeline import RealAnalyzerFileSystem
-
-if TYPE_CHECKING:
-    from pathlib import Path
-
-    from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext
-    from scripts.dev_tools.discovery.analyzer.pipeline import AnalyzerFileSystem
-
-# Generic, extensible marker table mapping a filename glob to a neutral unit
-# category. The tokens are the neutral structural category names themselves, not
-# any specific technology stack. Consumers may supply their own table.
-DEFAULT_MARKERS: tuple[tuple[str, UnitType], ...] = (
-    ("*.solution", UnitType.SOLUTION),
-    ("*.project", UnitType.PROJECT),
+from drm_copilot_discovery.analyzer.inventory import (
+    AnalyzerError as AnalyzerError,
 )
-
-_DESCRIPTION = "Source file enumerated by the repository inventory analyzer."
-
-
-class AnalyzerError(ValueError):
-    """Raised when an analyzer cannot proceed (for example an unreachable root).
-
-    A distinct ``ValueError`` subclass so callers can catch it separately from
-    the profile loader's ``DomainProfileError``.
-    """
-
-
-def filter_paths(
-    paths: tuple[str, ...],
-    include: tuple[str, ...],
-    exclude: tuple[str, ...],
-) -> tuple[str, ...]:
-    """Apply include/exclude globs to consumer-relative POSIX paths (pure).
-
-    A path is retained when it matches at least one ``include`` pattern (or
-    ``include`` is empty, meaning all) and matches no ``exclude`` pattern. Order
-    is preserved.
-
-    Args:
-        paths: Ordered consumer-relative POSIX paths.
-        include: Include glob patterns; empty selects all.
-        exclude: Exclude glob patterns; empty excludes none.
-
-    Returns:
-        The filtered paths in their original order.
-    """
-    retained: list[str] = []
-    for path in paths:
-        included = not include or any(fnmatchcase(path, pat) for pat in include)
-        excluded = any(fnmatchcase(path, pat) for pat in exclude)
-        if included and not excluded:
-            retained.append(path)
-    return tuple(retained)
-
-
-def classify_unit(
-    relative_path: str, markers: tuple[tuple[str, UnitType], ...]
-) -> UnitType:
-    """Return the ``UnitType`` for one path from the marker table (pure).
-
-    The first marker whose glob matches the path's filename wins; a path that
-    matches no marker is a plain ``FILE``.
-
-    Args:
-        relative_path: Consumer-relative POSIX path.
-        markers: Ordered ``(filename_glob, UnitType)`` pairs.
-
-    Returns:
-        The matched ``UnitType`` or ``UnitType.FILE`` when no marker matches.
-    """
-    name = PurePosixPath(relative_path).name
-    for pattern, unit_type in markers:
-        if fnmatchcase(name, pattern):
-            return unit_type
-    return UnitType.FILE
-
-
-def classify_paths(
-    paths: tuple[str, ...], markers: tuple[tuple[str, UnitType], ...]
-) -> tuple[ClassifiedUnit, ...]:
-    """Tag each path with its ``UnitType`` (pure)."""
-    return tuple(
-        ClassifiedUnit(relative_path=path, unit_type=classify_unit(path, markers))
-        for path in paths
-    )
-
-
-def _slug(relative_path: str) -> str:
-    """Return a stable identifier slug matching ``^[a-z0-9][a-z0-9._-]*$``."""
-    digest = hashlib.sha256(relative_path.encode("utf-8")).hexdigest()
-    return digest[:16]
-
-
-class InventoryAnalyzer:
-    """Language-neutral inventory analyzer implementing the ``Analyzer`` contract.
-
-    Args:
-        fs: Filesystem seam used by ``parse`` and ``map``; defaults to the real
-            filesystem implementation.
-        markers: Marker pattern table for classification; defaults to a generic,
-            extensible table.
-    """
-
-    name = "inventory"
-
-    def __init__(
-        self,
-        fs: AnalyzerFileSystem | None = None,
-        markers: tuple[tuple[str, UnitType], ...] | None = None,
-    ) -> None:
-        self._fs: AnalyzerFileSystem = (
-            fs if fs is not None else RealAnalyzerFileSystem()
-        )
-        self._markers = markers if markers is not None else DEFAULT_MARKERS
-        self._ctx: AnalyzerContext | None = None
-
-    def _require_ctx(self) -> AnalyzerContext:
-        """Return the stashed run context, failing if ``parse`` did not run."""
-        if self._ctx is None:
-            raise AnalyzerError("analyzer context is unavailable; parse must run first")
-        return self._ctx
-
-    def parse(self, ctx: AnalyzerContext) -> ParseResult:
-        """Fail fast on an unreachable root, then walk and order the tree.
-
-        Args:
-            ctx: The resolved run context.
-
-        Returns:
-            Consumer-relative POSIX paths in deterministic POSIX-sorted order.
-
-        Raises:
-            AnalyzerError: When the source root does not exist or is not a
-                directory.
-        """
-        self._ctx = ctx
-        root = ctx.source_root
-        if not self._fs.exists(root) or not self._fs.is_dir(root):
-            raise AnalyzerError(f"source root is not reachable: {root}")
-        relative_paths = [
-            file_path.relative_to(root).as_posix()
-            for file_path in self._fs.walk_files(root)
-        ]
-        return ParseResult(paths=tuple(sorted(relative_paths)))
-
-    def classify(self, parsed: ParseResult) -> ClassifyResult:
-        """Filter by include/exclude globs, then tag each surviving unit."""
-        ctx = self._require_ctx()
-        retained = filter_paths(parsed.paths, ctx.include, ctx.exclude)
-        return ClassifyResult(units=classify_paths(retained, self._markers))
-
-    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
-        """Build one ``EvidenceRecord`` per inventoried unit."""
-        ctx = self._require_ctx()
-        records: list[EvidenceRecord] = []
-        for unit in classified.units:
-            content = self._fs.read_bytes(ctx.source_root / unit.relative_path)
-            digest = hashlib.sha256(content).hexdigest()
-            records.append(
-                EvidenceRecord(
-                    id=f"inventory-{unit.unit_type.value}-{_slug(unit.relative_path)}",
-                    kind="file",
-                    location=unit.relative_path,
-                    captured_at=ctx.captured_at,
-                    description=_DESCRIPTION,
-                    content_hash=("sha256", digest),
-                    tool="dev.discovery.inventory",
-                    metadata=(
-                        ("unit_type", unit.unit_type.value),
-                        ("size_bytes", len(content)),
-                    ),
-                )
-            )
-        return tuple(records)
-
-    def emit(
-        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
-    ) -> tuple[Path, ...]:
-        """Write one Evidence Reference instance per record via the seam."""
-        ctx = self._require_ctx()
-        written: list[Path] = []
-        for record in records:
-            instance_path = ctx.artifact_root / f"{record.id}.json"
-            text = serialize_record(record, instance_path, ctx.schema_path)
-            fs.write_text(instance_path, text)
-            written.append(instance_path)
-        return tuple(written)
+from drm_copilot_discovery.analyzer.inventory import (
+    InventoryAnalyzer as InventoryAnalyzer,
+)
+from drm_copilot_discovery.analyzer.inventory import (
+    classify_paths as classify_paths,
+)
+from drm_copilot_discovery.analyzer.inventory import (
+    classify_unit as classify_unit,
+)
+from drm_copilot_discovery.analyzer.inventory import (
+    filter_paths as filter_paths,
+)
--- a/scripts/dev_tools/discovery/analyzer/models.py
+++ b/scripts/dev_tools/discovery/analyzer/models.py
@@ -1,174 +1,26 @@
-"""Frozen value objects and enums for the analyzer framework.
+"""Preserve legacy imports while the installable discovery runtime owns behavior."""

-Purpose:
-    Hold the immutable data carriers that flow between the four analyzer stages
-    (``parse -> classify -> map -> emit``) and the ``UnitType`` enum. These value
-    objects are host-neutral and carry no I/O behavior; the runner and the
-    concrete analyzer thread them from stage to stage.
-
-Invariants / Constraints:
-    - Every value object is ``@dataclass(frozen=True, slots=True)`` so instances
-      are immutable and cheap.
-    - Domain specificity is never encoded here; classification markers, source
-      roots, and globs are supplied at runtime.
-    - Only type-only imports (``pathlib.Path``) live under ``TYPE_CHECKING``;
-      annotations are strings under ``from __future__ import annotations``.
-
-Side Effects:
-    None.
-"""
-
-from __future__ import annotations
-
-from dataclasses import dataclass, field
-from enum import Enum
-from typing import TYPE_CHECKING
-
-if TYPE_CHECKING:
-    from pathlib import Path
-
-# Value permitted for the emitted ``schema_version`` field; matches ^1\.\d+\.\d+$.
-SCHEMA_VERSION_V1 = "1.0.0"
-
-
-class UnitType(str, Enum):
-    """Neutral category of an enumerated inventory unit.
-
-    A ``str`` enum so members compare and serialize as their plain string value.
-    The three members are generic structural categories, not stack-specific
-    identifiers.
-    """
-
-    FILE = "file"
-    PROJECT = "project"
-    SOLUTION = "solution"
-
-
-@dataclass(frozen=True, slots=True)
-class AnalyzerContext:
-    """Resolved inputs for a single analyzer run.
-
-    Args:
-        source_root: Resolved consumer source root to enumerate.
-        include: Glob patterns selecting files; empty means all files.
-        exclude: Glob patterns excluding files; empty excludes none.
-        artifact_root: Resolved output root where instances are written.
-        schema_path: Path to the discovery v1 Evidence Reference schema file,
-            used to compute each instance's scheme-less relative ``$schema``.
-        captured_at: ISO-8601 timestamp supplied by an injected clock.
-    """
-
-    source_root: Path
-    include: tuple[str, ...]
-    exclude: tuple[str, ...]
-    artifact_root: Path
-    schema_path: Path
-    captured_at: str
-
-
-@dataclass(frozen=True, slots=True)
-class ParseResult:
-    """Ordered consumer-relative POSIX file paths produced by the walk.
-
-    Args:
-        paths: Deterministically ordered consumer-relative POSIX paths.
-    """
-
-    paths: tuple[str, ...]
-
-
-@dataclass(frozen=True, slots=True)
-class ClassifiedUnit:
-    """A single enumerated unit tagged with its neutral ``UnitType``.
-
-    Args:
-        relative_path: Consumer-relative POSIX path of the unit.
-        unit_type: Neutral structural category of the unit.
-    """
-
-    relative_path: str
-    unit_type: UnitType
-
-
-@dataclass(frozen=True, slots=True)
-class ClassifyResult:
-    """The filtered, classified units of one run.
-
-    Args:
-        units: Ordered classified units that survived include/exclude filtering.
-    """
-
-    units: tuple[ClassifiedUnit, ...]
-
-
-@dataclass(frozen=True, slots=True)
-class EvidenceRecord:
-    """A typed carrier for one Evidence Reference instance.
-
-    The ``$schema`` value is supplied at serialization time because it depends on
-    the emitted instance's own location relative to the schema file.
-
-    Args:
-        id: Stable identifier matching ``^[a-z0-9][a-z0-9._-]*$``.
-        kind: Evidence kind enum value (``"file"`` for enumerated source files).
-        location: Consumer-relative POSIX path of the referenced artifact.
-        captured_at: ISO-8601 timestamp supplied by an injected clock.
-        description: Domain-neutral human-readable summary.
-        schema_version: Instance schema version matching ``^1\\.\\d+\\.\\d+$``.
-        content_hash: Optional ``(algorithm, value)`` integrity digest.
-        tool: Optional label of the producing tool.
-        metadata: Optional ordered free-form ``(key, value)`` extras.
-    """
-
-    id: str
-    kind: str
-    location: str
-    captured_at: str
-    description: str
-    schema_version: str = SCHEMA_VERSION_V1
-    content_hash: tuple[str, str] | None = None
-    tool: str | None = None
-    metadata: tuple[tuple[str, str | int], ...] = field(default_factory=tuple)
-
-    def to_json_dict(self, schema_ref: str) -> dict[str, object]:
-        """Serialize this record to the Evidence Reference v1 field set.
-
-        Args:
-            schema_ref: Scheme-less relative POSIX path from the emitted instance
-                file to the schema file, computed by the emitter.
-
-        Returns:
-            A mapping with the required fields plus any present optional fields.
-            No field is emitted outside the schema's declared set except the
-            free-form ``metadata`` object.
-        """
-        document: dict[str, object] = {
-            "$schema": schema_ref,
-            "schema_version": self.schema_version,
-            "id": self.id,
-            "kind": self.kind,
-            "location": self.location,
-            "captured_at": self.captured_at,
-            "description": self.description,
-        }
-        if self.content_hash is not None:
-            algorithm, value = self.content_hash
-            document["content_hash"] = {"algorithm": algorithm, "value": value}
-        if self.tool is not None:
-            document["tool"] = self.tool
-        if self.metadata:
-            document["metadata"] = {key: value for key, value in self.metadata}
-        return document
-
-
-@dataclass(frozen=True, slots=True)
-class AnalyzerRunResult:
-    """The outcome of one ``run_analyzer`` invocation.
-
-    Args:
-        records: The evidence records built by the ``map`` stage.
-        written_paths: The instance paths written by the ``emit`` stage.
-    """
-
-    records: tuple[EvidenceRecord, ...]
-    written_paths: tuple[Path, ...]
+from drm_copilot_discovery.analyzer.models import (
+    SCHEMA_VERSION_V1 as SCHEMA_VERSION_V1,
+)
+from drm_copilot_discovery.analyzer.models import (
+    AnalyzerContext as AnalyzerContext,
+)
+from drm_copilot_discovery.analyzer.models import (
+    AnalyzerRunResult as AnalyzerRunResult,
+)
+from drm_copilot_discovery.analyzer.models import (
+    ClassifiedUnit as ClassifiedUnit,
+)
+from drm_copilot_discovery.analyzer.models import (
+    ClassifyResult as ClassifyResult,
+)
+from drm_copilot_discovery.analyzer.models import (
+    EvidenceRecord as EvidenceRecord,
+)
+from drm_copilot_discovery.analyzer.models import (
+    ParseResult as ParseResult,
+)
+from drm_copilot_discovery.analyzer.models import (
+    UnitType as UnitType,
+)
--- a/scripts/dev_tools/discovery/analyzer/pipeline.py
+++ b/scripts/dev_tools/discovery/analyzer/pipeline.py
@@ -1,150 +1,14 @@
-"""Analyzer pipeline abstraction, filesystem seam, and the thin runner.
+"""Preserve legacy imports while the installable discovery runtime owns behavior."""

-Purpose:
-    Define the host-neutral framework contract that concrete analyzers plug into:
-    the ``Analyzer`` protocol (four ordered stages), the ``AnalyzerFileSystem``
-    seam that isolates disk access, a real seam implementation, and the
-    ``run_analyzer`` runner that drives the stages deterministically.
-
-Invariants / Constraints:
-    - ``Analyzer`` is a ``typing.Protocol`` (multiple implementations expected):
-      this feature's inventory analyzer plus future stack-specific analyzers.
-    - Protocol stage bodies are ``...`` (type-only; excluded from coverage).
-    - ``run_analyzer`` invokes ``parse -> classify -> map -> emit`` in that fixed
-      order and threads each stage's output into the next.
-    - Enumeration/classification logic depends on the seam or plain data so it is
-      testable without temporary files.
-
-Side Effects:
-    ``RealAnalyzerFileSystem`` reads and writes the real filesystem. The protocol
-    and the runner have no side effects of their own.
-"""
-
-from __future__ import annotations
-
-from typing import TYPE_CHECKING, Protocol, runtime_checkable
-
-from scripts.dev_tools.discovery.analyzer.models import AnalyzerRunResult
-
-if TYPE_CHECKING:
-    from pathlib import Path
-
-    from scripts.dev_tools.discovery.analyzer.models import (
-        AnalyzerContext,
-        ClassifyResult,
-        EvidenceRecord,
-        ParseResult,
-    )
-
-
-@runtime_checkable
-class AnalyzerFileSystem(Protocol):
-    """Disk-operation seam required by analyzers.
-
-    A minimal surface: existence and type checks, a recursive file walk, a byte
-    read (for integrity hashing), and a text write that creates parent
-    directories. Implementations may be backed by the real filesystem or by an
-    in-memory store in tests.
-    """
-
-    def exists(self, path: Path) -> bool:
-        """Return whether ``path`` exists."""
-        ...
-
-    def is_dir(self, path: Path) -> bool:
-        """Return whether ``path`` is a directory."""
-        ...
-
-    def walk_files(self, root: Path) -> tuple[Path, ...]:
-        """Return every file path beneath ``root`` (directories excluded)."""
-        ...
-
-    def read_bytes(self, path: Path) -> bytes:
-        """Return the byte content of the file at ``path``."""
-        ...
-
-    def write_text(self, path: Path, content: str) -> None:
-        """Write ``content`` to ``path`` as UTF-8, creating parent directories."""
-        ...
-
-
-class Analyzer(Protocol):
-    """Four-stage analyzer contract that concrete analyzers implement.
-
-    A concrete analyzer plugs into ``run_analyzer`` by implementing ``name`` and
-    the four stage methods. The stage bodies here are type-only.
-    """
-
-    name: str
-
-    def parse(self, ctx: AnalyzerContext) -> ParseResult:
-        """Read inputs described by ``ctx`` and return the parse result."""
-        ...
-
-    def classify(self, parsed: ParseResult) -> ClassifyResult:
-        """Filter and tag the parsed units."""
-        ...
-
-    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
-        """Build one evidence record per classified unit."""
-        ...
-
-    def emit(
-        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
-    ) -> tuple[Path, ...]:
-        """Write one artifact per record via the seam and return their paths."""
-        ...
-
-
-class RealAnalyzerFileSystem:
-    """Filesystem seam backed by ``pathlib.Path`` operations."""
-
-    def exists(self, path: Path) -> bool:
-        """Return whether ``path`` exists on disk."""
-        return path.exists()
-
-    def is_dir(self, path: Path) -> bool:
-        """Return whether ``path`` is a directory on disk."""
-        return path.is_dir()
-
-    def walk_files(self, root: Path) -> tuple[Path, ...]:
-        """Return every file beneath ``root`` via an iterative directory walk."""
-        collected: list[Path] = []
-        stack: list[Path] = [root]
-        while stack:
-            current = stack.pop()
-            for child in current.iterdir():
-                if child.is_dir():
-                    stack.append(child)
-                else:
-                    collected.append(child)
-        return tuple(collected)
-
-    def read_bytes(self, path: Path) -> bytes:
-        """Return the byte content of the file at ``path``."""
-        return path.read_bytes()
-
-    def write_text(self, path: Path, content: str) -> None:
-        """Write ``content`` as UTF-8 to ``path``, creating parent directories."""
-        path.parent.mkdir(parents=True, exist_ok=True)
-        path.write_text(content, encoding="utf-8")
-
-
-def run_analyzer(
-    analyzer: Analyzer, ctx: AnalyzerContext, fs: AnalyzerFileSystem
-) -> AnalyzerRunResult:
-    """Drive an analyzer through its four stages in fixed order.
-
-    Args:
-        analyzer: The concrete analyzer to run.
-        ctx: The resolved run context.
-        fs: The filesystem seam handed to the ``emit`` stage.
-
-    Returns:
-        An ``AnalyzerRunResult`` carrying the emitted records and written paths.
-    """
-    parsed = analyzer.parse(ctx)
-    classified = analyzer.classify(parsed)
-    records = analyzer.map(classified)
-    written = analyzer.emit(records, fs)
-    return AnalyzerRunResult(records=records, written_paths=written)
+from drm_copilot_discovery.analyzer.pipeline import (
+    Analyzer as Analyzer,
+)
+from drm_copilot_discovery.analyzer.pipeline import (
+    AnalyzerFileSystem as AnalyzerFileSystem,
+)
+from drm_copilot_discovery.analyzer.pipeline import (
+    RealAnalyzerFileSystem as RealAnalyzerFileSystem,
+)
+from drm_copilot_discovery.analyzer.pipeline import (
+    run_analyzer as run_analyzer,
+)
--- a/tests/discovery_runtime/analyzer/test_input_capture.py
+++ b/tests/discovery_runtime/analyzer/test_input_capture.py
@@ -0,0 +1,395 @@
+"""Exercise bounded, pruned analyzer reads using only isolated memory adapters."""
+
+from __future__ import annotations
+
+from dataclasses import replace
+from typing import TYPE_CHECKING
+
+import pytest
+from drm_copilot_discovery.analyzer import input_capture
+from drm_copilot_discovery.analyzer.input_capture import (
+    capture_inputs,
+    capture_snapshot,
+    pin_inventory_sources,
+)
+from drm_copilot_discovery.analyzer.models import InventoryInput
+from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+from drm_copilot_discovery.path_models import PathPolicyError
+from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
+from drm_copilot_discovery.snapshot import SnapshotFile
+
+from tests.discovery_runtime.analyzer.test_repository import (
+    analyzer_catalog as analyzer_catalog,
+)
+from tests.discovery_runtime.analyzer.test_repository import inventory_profile
+from tests.discovery_runtime.test_snapshot_io import MemoryStore
+from tests.discovery_runtime.validation_test_support import captured
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.analyzer.models import InventoryCapture
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.path_models import PathMetadata
+    from drm_copilot_discovery.profile_v2 import ProfileV2
+
+
+def read_capture(profile: ProfileV2, store: MemoryStore) -> InventoryCapture:
+    """Use the real capture boundary with test-local filesystem collaborators.
+
+    Parameters: profile (ProfileV2): validated local-source configuration. store
+    (MemoryStore): test-local memory filesystem.
+
+    Returns InventoryCapture from the actual runtime boundary; policy/read failures
+    propagate. Reads only memory seams.
+    """
+    return capture_inputs(
+        profile,
+        workspace_root=store.metadata.root.as_posix(),
+        metadata=store.metadata,
+        read_bytes=store.read,
+    )
+
+
+@pytest.mark.parametrize("workspace", ["/workspace", "C:/workspace"])
+def test_capture_prunes_outputs_and_dependencies_before_descent(
+    analyzer_catalog: SchemaCatalog, workspace: str
+) -> None:
+    """Excluded frontiers are accounted for without probing their child
+    metadata/bytes.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture. workspace (str): synthetic absolute platform root.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(
+        analyzer_catalog,
+        project_entry_points=["src/app.sln"],
+        test_roots=["tests"],
+        excluded_paths=[
+            {"path_or_glob": "src/vendor/**", "rationale": "External source."}
+        ],
+        analyzers={
+            "enabled": ["repository"],
+            "options": {},
+            "ignored_paths": [
+                {"path_or_glob": "src/generated", "rationale": "Build output."}
+            ],
+            "extension_result_manifests": [],
+        },
+    )
+    store = MemoryStore(workspace)
+    # Mix retained inputs with excluded descendants to detect late pruning.
+    for path in (
+        "src/.hidden",
+        "src/app.sln",
+        "src/vendor/private",
+        "src/generated/private",
+        "tests/test.cs",
+        "docs/guide.md",
+        profile.artifacts["inventory"] + "/old.json",
+    ):
+        store.put(path, path.encode())
+    forbidden = {
+        "src/vendor/private",
+        "src/generated/private",
+        profile.artifacts["inventory"] + "/old.json",
+    }
+    original = store.metadata
+    seen: list[str] = []
+
+    def metadata(path: str) -> PathMetadata:
+        """Reject descendant access after a configured exclusion frontier.
+
+        Parameters: path (str): workspace-relative input path.
+
+        Returns PathMetadata from the memory adapter; raises AssertionError for
+        excluded descendant reads and records the observed path in a local list.
+        """
+        assert path not in forbidden
+        seen.append(path)
+        return original(path)
+
+    result = capture_inputs(
+        profile, workspace_root=workspace, metadata=metadata, read_bytes=store.read
+    )
+    # Only successful retained bytes may participate in source classification.
+    inspected = {item.path: item for item in result.inputs if item.file}
+    assert set(inspected) == {
+        "src/.hidden",
+        "src/app.sln",
+        "tests/test.cs",
+        "docs/guide.md",
+    }
+    # Each pruned frontier remains visible with its explicit exclusion disposition.
+    assert {item.path for item in result.inputs if item.status == "excluded"} == {
+        "src/vendor",
+        "src/generated",
+        profile.artifacts["root"],
+    }
+    assert not forbidden.intersection(seen)
+    # Source ownership must match configured roots independently of walk ordering.
+    assert [item.file.category for item in inspected.values() if item.file] == [
+        "documentation",
+        "source",
+        "source",
+        "test",
+    ]
+    assert len(store.calls) == 8  # One original read and one freshness comparison each.
+
+
+def test_failed_oversized_and_missing_inputs_never_receive_fabricated_hashes(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Unreadable entries retain rationale while successful inputs remain analyzable.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(
+        analyzer_catalog,
+        test_roots=["tests"],
+        analyzers={
+            "enabled": ["repository"],
+            "options": {"max_file_bytes": 4},
+            "ignored_paths": [],
+            "extension_result_manifests": [],
+        },
+    )
+    store = MemoryStore()
+    store.put("src/good", b"ok")
+    store.put("src/large", b"12345")
+    store.put("src/denied", b"no")
+    store.failures.add("src/denied")
+    store.metadata.add("docs", kind="directory")
+    result = read_capture(profile, store)
+    # Failure accounting retains every unreadable path but never fake byte hashes.
+    failed = [item for item in result.inputs if item.status == "unreadable"]
+    assert [item.path for item in failed] == ["src/denied", "src/large", "tests"]
+    # All failure causes share the same absence-of-bytes invariant.
+    assert all(
+        item.file is None and item.sha256 is None and item.rationale for item in failed
+    )
+    # Successful reads remain independently usable despite other input failures.
+    assert next(
+        item for item in result.inputs if item.path == "src/good"
+    ).file == SnapshotFile(path="src/good", content=b"ok", category="source")
+
+
+@pytest.mark.parametrize(
+    "limits", [{"source_files": 1}, {"source_files": 2}, {"nesting_depth": 1}]
+)
+def test_entry_and_depth_limits_fail_closed(
+    analyzer_catalog: SchemaCatalog, limits: dict[str, int]
+) -> None:
+    """Directory breadth, total traversal and nesting are bounded before
+    continuation.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture. limits (dict[str, int]): finite profile limits for this case.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(analyzer_catalog, limits=limits)
+    store = MemoryStore()
+    # Exercise both directory breadth and total traversal ceilings on the same tree.
+    for path in ("src/a", "src/b", "src/c"):
+        store.put(path, b"x")
+    with pytest.raises((ValueError, OSError), match="limit|depth"):
+        read_capture(profile, store)
+
+
+def test_aggregate_bytes_and_changed_inputs_fail_without_partial_success(
+    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """Finite total allocation and freshness cannot be bypassed by small individual
+    files.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture. monkeypatch (pytest.MonkeyPatch): isolated patches restored by pytest.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(analyzer_catalog)
+    store = MemoryStore()
+    store.put("src/a", b"original")
+    store.metadata.add("docs", kind="directory")
+    monkeypatch.setattr(input_capture, "MAX_CAPTURE_BYTES", 4)
+    with pytest.raises(ValueError, match="aggregate byte"):
+        read_capture(profile, store)
+    monkeypatch.setattr(input_capture, "MAX_CAPTURE_BYTES", 1024)
+    calls = 0
+
+    def changed_read(path: str, *, limit: int) -> bytes:
+        """Change source bytes only at the explicit freshness comparison boundary.
+
+        Parameters: path (str): workspace-relative input path. limit (int): maximum
+        requested byte count.
+
+        Returns bytes selected by the local call counter; increments that counter
+        only. Performs no real I/O.
+        """
+        nonlocal calls
+        calls += 1
+        return b"original" if calls == 1 else b"modified"
+
+    with pytest.raises(OSError, match="changed"):
+        capture_inputs(
+            profile,
+            workspace_root="/workspace",
+            metadata=store.metadata,
+            read_bytes=changed_read,
+        )
+
+
+def test_path_aliases_and_links_are_rejected_without_dereference(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Unsafe namespace states cannot be represented as ordinary unreadable source
+    files.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(analyzer_catalog)
+    store = MemoryStore()
+    store.put("src/A.cs", b"a")
+    store.put("src/a.cs", b"b")
+    with pytest.raises(PathPolicyError):
+        read_capture(profile, store)
+    store = MemoryStore()
+    store.metadata.add("src/link", kind="symlink")
+    with pytest.raises(PathPolicyError, match="PATH_LINK"):
+        read_capture(profile, store)
+    assert not store.calls
+
+
+def test_snapshot_capture_retains_exclusions_without_inventing_payload_inputs(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Existing artifact/evidence bytes remain outside source inventory.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(
+        analyzer_catalog,
+        excluded_paths=[{"path_or_glob": "src/vendor/**", "rationale": "Dependency."}],
+    )
+    payload = SnapshotFile(
+        path="docs/migration/discovery/evidence/proof.bin",
+        content=b"proof",
+        category="evidence",
+    )
+    snapshot = replace(
+        captured(profile, analyzer_catalog, payloads=(payload,)),
+        excluded_paths=("src/vendor",),
+    )
+    result = capture_snapshot(snapshot)
+    assert result.inputs == (
+        InventoryInput(path="src/vendor", status="excluded", rationale="Dependency."),
+    )
+    with pytest.raises(ValueError, match="no configured rationale"):
+        capture_snapshot(replace(snapshot, excluded_paths=("src/unexplained",)))
+
+
+class MemoryRepository:
+    """Supply explicit immutable local Git inputs with no process or filesystem I/O."""
+
+    def __init__(self, profile: ProfileV2, files: dict[str, bytes]) -> None:
+        """Bind one independent repository identity and exact synthetic blob
+        dictionary.
+
+        Parameters: profile (ProfileV2): validated local-source configuration. files
+        (dict[str, bytes]): test-local immutable Git blob mapping.
+
+        Returns None; initializes only private synthetic reader state. Invalid
+        identities raise ValueError; no I/O occurs.
+        """
+        self.local = RepositoryIdentity(
+            id=profile.repository.id, revision=profile.repository.revision
+        )
+        self.files = files
+        self.calls: list[str] = []
+        self.wrong_path = False
+
+    def identity(self) -> RepositoryIdentity:
+        """Return the configured synthetic checkout identity without inferring it.
+
+        Takes no caller arguments.
+
+        Returns RepositoryIdentity retained by the fixture. No I/O or mutation
+        occurs.
+        """
+        return self.local
+
+    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
+        """Return exact pinned bytes and retain requested paths/limits for
+        assertions.
+
+        Parameters: revision (str): full configured Git revision. path (str):
+        workspace-relative input path. limit (int): maximum requested byte count.
+
+        Returns RepositoryFile containing exact immutable fixture bytes. Raises
+        FileNotFoundError for absent blobs or AssertionError for invalid requests;
+        appends only to the fixture call list.
+        """
+        assert revision == self.local.revision and limit > 0
+        self.calls.append(path)
+        if path not in self.files:
+            raise FileNotFoundError(path)
+        return RepositoryFile(
+            repository=self.local,
+            path="docs/wrong" if self.wrong_path else path,
+            content=self.files[path],
+        )
+
+
+def test_pin_capture_preserves_existing_objects_and_refuses_missing_or_foreign_pins(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Publication precapture is idempotent and never substitutes working-copy bytes.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(analyzer_catalog)
+    source = SnapshotFile(
+        path="docs/guide.md", content=b"guide", category="documentation"
+    )
+    snapshot = captured(profile, analyzer_catalog, payloads=(source,))
+    store = MemoryStore()
+    workspace = CapturedWorkspace(
+        workspace_root="/workspace",
+        snapshot=snapshot,
+        metadata=((".", store.metadata(".")),),
+    )
+    repository = MemoryRepository(profile, {source.path: source.content})
+    first = pin_inventory_sources(workspace, repository)
+    assert first.snapshot.repository_files[0].content == source.content
+    assert pin_inventory_sources(first, repository) == first
+    assert repository.calls == [source.path]
+    repository.wrong_path = True
+    with pytest.raises(ValueError, match="unexpected object"):
+        pin_inventory_sources(workspace, repository)
+    repository.wrong_path = False
+    repository.files.clear()
+    with pytest.raises(FileNotFoundError):
+        pin_inventory_sources(workspace, repository)
+    repository.local = RepositoryIdentity(id="other", revision="b" * 40)
+    with pytest.raises(ValueError, match="configured local pin"):
+        pin_inventory_sources(workspace, repository)
--- a/tests/discovery_runtime/analyzer/test_pipeline.py
+++ b/tests/discovery_runtime/analyzer/test_pipeline.py
@@ -0,0 +1,329 @@
+"""Test pure analyzer results and explicit guarded publication across real
+validators.
+"""
+
+from __future__ import annotations
+
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.analyzer.emitter import inventory_result
+from drm_copilot_discovery.analyzer.findings import row
+from drm_copilot_discovery.analyzer.input_capture import (
+    capture_snapshot,
+    pin_inventory_sources,
+)
+from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
+from drm_copilot_discovery.analyzer.pipeline import plan_inventory, run_inventory
+from drm_copilot_discovery.models import JsonObject, canonical_json
+from drm_copilot_discovery.mutation_io import capture_workspace, commit_mutation
+from drm_copilot_discovery.mutation_plan import MutationError
+from drm_copilot_discovery.path_models import WriteGrant
+
+from tests.discovery_runtime.analyzer.test_input_capture import MemoryRepository
+from tests.discovery_runtime.analyzer.test_repository import (
+    analyzer_catalog as analyzer_catalog,
+)
+from tests.discovery_runtime.analyzer.test_repository import (
+    inventory_capture,
+    inventory_profile,
+)
+from tests.discovery_runtime.test_mutation_commit import MemoryWriter
+from tests.discovery_runtime.test_snapshot_io import MemoryStore
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryResult
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
+
+
+def result_for(capture: InventoryCapture, catalog: SchemaCatalog) -> InventoryResult:
+    """Use fixed capture metadata so complete result bytes can be compared exactly.
+
+    Parameters: capture (InventoryCapture): immutable analyzer input set. catalog
+    (SchemaCatalog): trusted immutable schema catalog.
+
+    Returns InventoryResult with fixed provenance; validation failures propagate. No
+    I/O or mutation.
+    """
+    return run_inventory(
+        capture,
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=row(kind="tool", id="fixture"),
+        catalog=catalog,
+    )
+
+
+class InventoryWriter(MemoryWriter):
+    """Compose real guarded mutation with repeatable inventory source precapture."""
+
+    def __init__(
+        self, store: MemoryStore, catalog: SchemaCatalog, repository: MemoryRepository
+    ) -> None:
+        """Reuse accepted memory mutation primitives with one explicit local reader.
+
+        Parameters: store (MemoryStore): test-local memory filesystem. catalog
+        (SchemaCatalog): trusted immutable schema catalog. repository
+        (MemoryRepository): isolated pinned Git reader.
+
+        Returns None; initializes only isolated memory mutation state. No real I/O
+        occurs.
+        """
+        super().__init__(store, catalog)
+        self.repository = repository
+
+    def capture(self) -> CapturedWorkspace:
+        """Repeat complete exact capture and selected Git objects on every check.
+
+        Takes no caller arguments.
+
+        Returns CapturedWorkspace using actual loader and precapture contracts.
+        Policy/read failures propagate; reads only synthetic memory inputs.
+        """
+        baseline = capture_workspace(
+            workspace_root="/workspace",
+            profile_path="docs/migration/discovery/domain-profile.yaml",
+            metadata=self.store.metadata,
+            read_bytes=self.store.read,
+            repository=self.repository,
+            catalog=self.catalog,
+        )
+        return pin_inventory_sources(baseline, self.repository)
+
+
+def publication_case(
+    catalog: SchemaCatalog,
+) -> tuple[InventoryWriter, CapturedWorkspace, InventoryResult, WriteGrant]:
+    """Create an incomplete workspace whose first inventory includes a real document.
+
+    Parameters: catalog (SchemaCatalog): trusted immutable schema catalog.
+
+    Returns tuple[InventoryWriter, CapturedWorkspace, InventoryResult, WriteGrant]
+    for guarded publication. Reads and mutates only a new memory store; validation
+    failures propagate.
+    """
+    profile = inventory_profile(catalog)
+    store = MemoryStore()
+    store.put(profile.artifacts["profile"], canonical_json(profile.document))
+    store.put("src/main.cs", b"class Main {}\r\n")
+    store.put("docs/guide.md", b"Observed guide.\n")
+    repository = MemoryRepository(
+        profile,
+        {"src/main.cs": b"class Main {}\r\n", "docs/guide.md": b"Observed guide.\n"},
+    )
+    writer = InventoryWriter(store, catalog, repository)
+    baseline = writer.capture()
+    result = result_for(capture_snapshot(baseline.snapshot), catalog)
+    identifier = cast("str", result.document["id"])
+    grant = WriteGrant(
+        artifact_kind="inventory-snapshot",
+        artifact_id=identifier,
+        path=profile.artifacts["inventory"] + "/" + identifier + ".json",
+    )
+    return writer, baseline, result, grant
+
+
+def test_default_and_dry_run_analysis_are_identical_and_do_not_write(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Immutable capture inputs support both modes without a publication
+    collaborator.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    capture = inventory_capture(analyzer_catalog)
+    original = capture
+    first = result_for(capture, analyzer_catalog)
+    second = run_inventory(
+        capture,
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=row(kind="tool", id="fixture"),
+        catalog=analyzer_catalog,
+        dry_run=True,
+    )
+    assert first == second and capture == original
+    assert len(first.ledger_components) == 2
+
+
+def test_inventory_publication_is_explicit_idempotent_and_scope_preserving(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """First publication passes real schema/graph/CAS gates and creates only
+    inventory.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    writer, baseline, result, grant = publication_case(analyzer_catalog)
+    before = dict(writer.store.files)
+    plan = plan_inventory(baseline, result, grants=(grant,))
+    assert dict(writer.store.files) == before
+    preview = commit_mutation(plan, writer=writer, dry_run=True)
+    assert preview.ok and preview.artifacts[0].status == "planned"
+    assert writer.invalidations == writer.attempts == 0
+    assert dict(writer.store.files) == before
+    committed = commit_mutation(plan, writer=writer)
+    assert committed.ok, committed.findings
+    assert writer.attempts == writer.invalidations == 1
+    assert set(writer.store.files) == set(before) | {grant.path}
+    # Compare every pre-existing byte sequence, including documentation and profile.
+    assert all(writer.store.files[path] == data for path, data in before.items())
+    assert writer.store.files[grant.path] == canonical_json(result.document)
+    assert baseline.snapshot.profile.artifacts["scope"] not in writer.store.files
+    assert (
+        baseline.snapshot.profile.artifacts["coverage_ledger"] not in writer.store.files
+    )
+    refreshed = writer.capture()
+    repeated = plan_inventory(
+        refreshed,
+        result_for(capture_snapshot(refreshed.snapshot), analyzer_catalog),
+        grants=(grant,),
+    )
+    skipped = commit_mutation(repeated, writer=writer)
+    assert skipped.ok and skipped.artifacts[0].status == "skipped"
+    assert writer.attempts == writer.invalidations == 1
+
+
+def test_publication_rejects_wrong_grants_and_changed_inputs(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Valid result bytes alone cannot grant write authority or override freshness.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    writer, baseline, result, grant = publication_case(analyzer_catalog)
+    with pytest.raises((ValueError, MutationError)):
+        plan_inventory(baseline, result, grants=())
+    forged = replace(result, semantic_sha256="0" * 64)
+    with pytest.raises(MutationError, match="INVENTORY_INPUTS"):
+        plan_inventory(baseline, forged, grants=(grant,))
+    plan = plan_inventory(baseline, result, grants=(grant,))
+    writer.store.files["docs/guide.md"] = b"changed after planning"
+    stale = commit_mutation(plan, writer=writer)
+    assert not stale.ok and stale.findings[0].code == "MUTATION_FAILED"
+    assert "MUTATION_STALE" in stale.findings[0].message
+    assert writer.attempts == 0 and writer.invalidations == 1
+    assert stale.authority_invalidated
+
+
+def test_unverified_source_provenance_blocks_publication(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """A source with no immutable bytes remains an explicit blocking result.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    _, baseline, _, grant = publication_case(analyzer_catalog)
+    baseline = replace(
+        baseline, snapshot=replace(baseline.snapshot, repository_files=())
+    )
+    result = result_for(capture_snapshot(baseline.snapshot), analyzer_catalog)
+    with pytest.raises(MutationError, match="INVENTORY_BLOCKED"):
+        plan_inventory(baseline, result, grants=(grant,))
+
+
+@pytest.mark.parametrize(
+    "failure", ["duplicate", "reference", "schema", "timestamp", "limit", "identifier"]
+)
+def test_invalid_adapter_results_and_capture_metadata_fail_closed(
+    analyzer_catalog: SchemaCatalog, failure: str
+) -> None:
+    """Adapter bugs cannot produce publishable malformed or contradictory
+    inventories.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture. failure (str): selected invalid-result case.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    capture = inventory_capture(analyzer_catalog)
+    analysis = RepositoryAnalyzer().analyze(capture)
+    timestamp = "2026-10-19T01:00:00Z"
+    # Isolate identity, reference, shape, metadata and resource-limit failure classes.
+    if failure == "duplicate":
+        analysis = replace(
+            analysis, components=analysis.components + analysis.components
+        )
+    elif failure == "reference":
+        analysis = replace(
+            analysis, findings=(row(finding_id="bad", component_id="absent"),)
+        )
+    elif failure == "schema":
+        analysis = replace(analysis, diagnostics=(row(id="broken"),))
+    elif failure == "timestamp":
+        timestamp = "not-a-time"
+    elif failure == "identifier":
+        analysis = replace(analysis, diagnostics=(row(message="Missing identity"),))
+    else:
+        capture = replace(
+            capture,
+            profile=inventory_profile(analyzer_catalog, limits={"artifact_records": 1}),
+        )
+    with pytest.raises(ValueError):
+        inventory_result(
+            capture,
+            (analysis,),
+            analyzer_ids=("repository",),
+            timestamp=timestamp,
+            author_or_agent=row(kind="tool", id="fixture"),
+            catalog=analyzer_catalog,
+        )
+
+
+def test_null_relationship_target_preserves_unresolved_binding(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """A declared relationship may retain an unresolved destination without
+    inventing it.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    capture = inventory_capture(analyzer_catalog)
+    original = RepositoryAnalyzer().analyze(capture)
+    component = original.components[0]
+    relationship = row(
+        relationship_id="dependency-one",
+        from_component_id=component["component_id"],
+        to_component_id=None,
+        target_description="Unresolved external project",
+        kind="project-reference",
+        source=component["source"],
+        analyzer=component["analyzer"],
+        classification="detected",
+        confidence="low",
+        extensions=row(),
+    )
+    result = inventory_result(
+        capture,
+        (replace(original, relationships=(relationship,)),),
+        analyzer_ids=("repository",),
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=row(kind="tool", id="fixture"),
+        catalog=analyzer_catalog,
+    )
+    assert result.document["relationships"] == (relationship,)
+    assert (
+        cast("JsonObject", result.document["capture"])["timestamp"]
+        == "2026-10-19T01:00:00Z"
+    )
--- a/tests/discovery_runtime/analyzer/test_registry.py
+++ b/tests/discovery_runtime/analyzer/test_registry.py
@@ -0,0 +1,201 @@
+"""Verify explicit adapter selection and immutable input construction boundaries."""
+
+from __future__ import annotations
+
+import builtins
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.analyzer.findings import diagnostic, row, source_reference
+from drm_copilot_discovery.analyzer.models import (
+    Analysis,
+    InventoryCapture,
+    InventoryInput,
+)
+from drm_copilot_discovery.analyzer.registry import select_analyzers
+from drm_copilot_discovery.path_models import PathPolicyError
+from drm_copilot_discovery.profile_v2 import ProfileError, ProfileV2
+from drm_copilot_discovery.snapshot import SnapshotFile
+
+from tests.discovery_runtime.analyzer.test_repository import (
+    analyzer_catalog as analyzer_catalog,
+)
+from tests.discovery_runtime.analyzer.test_repository import (
+    inventory_capture,
+    inventory_profile,
+)
+
+if TYPE_CHECKING:
+    from types import ModuleType
+    from typing import Literal
+
+    from drm_copilot_discovery.catalog import SchemaCatalog
+    from drm_copilot_discovery.models import JsonObject
+
+
+def test_registry_loads_only_explicit_core_adapters(
+    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
+) -> None:
+    """Selecting core inventory performs no optional imports or executable dispatch.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture. monkeypatch (pytest.MonkeyPatch): isolated patches restored by pytest.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(analyzer_catalog)
+
+    original_import = builtins.__import__
+    seen: list[str] = []
+
+    def observe_import(
+        name: str,
+        globals: dict[str, object] | None = None,
+        locals: dict[str, object] | None = None,
+        fromlist: tuple[str, ...] = (),
+        level: int = 0,
+    ) -> ModuleType:
+        """Allow core typed views while observing any optional adapter import.
+
+        Parameters: name (str): requested import name. globals (dict[str, object] |
+        None): forwarded import global namespace. locals (dict[str, object] | None):
+        forwarded import local namespace. fromlist (tuple[str, ...]): forwarded
+        imported members. level (int): forwarded relative-import depth.
+
+        Returns ModuleType from the original importer. Raises AssertionError for
+        optional adapters; records names and uses the ordinary import cache.
+        """
+        seen.append(name)
+        # Core profile views are allowed; optional adapter imports remain observable.
+        assert not any(token in name for token in ("dotnet", "vsto", "lxml"))
+        return original_import(name, globals, locals, fromlist, level)
+
+    with monkeypatch.context() as context:
+        context.setattr(builtins, "__import__", observe_import)
+        selected = select_analyzers(profile)
+    assert [adapter.identifier for adapter in selected] == ["repository"]
+    assert seen and set(seen) == {"drm_copilot_discovery.profile_v2"}
+
+
+@pytest.mark.parametrize("enabled", [[], ["dotnet"], ["repository", "csharp-symbols"]])
+def test_registry_rejects_unavailable_selections_without_fallback(
+    analyzer_catalog: SchemaCatalog, enabled: list[str]
+) -> None:
+    """Unimplemented adapter identifiers never silently produce a partial inventory.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture. enabled (list[str]): explicit configured adapter names.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    profile = inventory_profile(
+        analyzer_catalog,
+        analyzers={
+            "enabled": enabled,
+            "options": {},
+            "ignored_paths": [],
+            "extension_result_manifests": [],
+        },
+    )
+    with pytest.raises(ValueError, match="Unavailable analyzer"):
+        select_analyzers(profile)
+
+
+@pytest.mark.parametrize(
+    "status,rationale,file",
+    [
+        ("bad", None, None),
+        ("inspected", None, None),
+        (
+            "inspected",
+            "Not allowed",
+            SnapshotFile(path="src/a", content=b"a", category="source"),
+        ),
+        ("excluded", None, None),
+        ("unreadable", " ", None),
+        (
+            "excluded",
+            "Excluded",
+            SnapshotFile(path="src/a", content=b"a", category="source"),
+        ),
+    ],
+)
+def test_input_model_rejects_dishonest_or_ambiguous_accounting(
+    status: str, rationale: str | None, file: SnapshotFile | None
+) -> None:
+    """Only inspected inputs carry bytes; every unavailable input has a reason.
+
+    Parameters: status (str): requested input state, including invalid cases.
+    rationale (str | None): authored unavailable-input reason. file (SnapshotFile |
+    None): optional retained source bytes.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    with pytest.raises(ValueError):
+        InventoryInput(
+            path="src/a",
+            status=cast("Literal['inspected', 'excluded', 'unreadable']", status),
+            rationale=rationale,
+            file=file,
+        )
+
+
+def test_models_reject_untyped_rows_profile_inputs_and_collisions(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Unsafe caller-constructed values cannot bypass the immutable analyzer
+    boundary.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    capture = inventory_capture(analyzer_catalog)
+    with pytest.raises(ValueError, match="validated profile"):
+        InventoryCapture(profile=cast("ProfileV2", object()), inputs=())
+    with pytest.raises(ValueError, match="typed captured"):
+        replace(capture, inputs=cast("tuple[InventoryInput, ...]", (object(),)))
+    with pytest.raises(PathPolicyError):
+        replace(capture, inputs=(capture.inputs[0], capture.inputs[0]))
+    with pytest.raises(ValueError, match="immutable JSON"):
+        Analysis(components=cast("tuple[JsonObject, ...]", ({},)))
+    with pytest.raises(ValueError, match="inspected captured bytes"):
+        source_reference(
+            capture,
+            InventoryInput(path="src/no", status="excluded", rationale="Excluded."),
+        )
+    assert (
+        diagnostic("notice", None, "Review this input.", blocking=False)["severity"]
+        == "warning"
+    )
+
+
+def test_draft_and_input_count_limits_fail_closed(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Incomplete configuration and excessive selected files cannot reach adapters.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    draft = inventory_profile(analyzer_catalog, profile_state="draft")
+    with pytest.raises(ProfileError):
+        InventoryCapture(profile=draft, inputs=())
+    profile = inventory_profile(analyzer_catalog, limits={"source_files": 1})
+    # Both typed rows are valid individually but exceed the configured total budget.
+    inputs = tuple(
+        InventoryInput(path=name, status="excluded", rationale="Excluded.")
+        for name in ("src/a", "src/b")
+    )
+    with pytest.raises(ValueError, match="input count"):
+        InventoryCapture(profile=profile, inputs=inputs)
+    assert Analysis(components=(row(id="one"),)).components == (row(id="one"),)
--- a/tests/discovery_runtime/analyzer/test_repository.py
+++ b/tests/discovery_runtime/analyzer/test_repository.py
@@ -0,0 +1,342 @@
+"""Verify truthful repository inventory, stable identity and unchanged source bytes."""
+
+from __future__ import annotations
+
+import hashlib
+import json
+from dataclasses import replace
+from typing import TYPE_CHECKING, cast
+
+import pytest
+from drm_copilot_discovery.analyzer.findings import row
+from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
+from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
+from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
+from drm_copilot_discovery.analyzer.pipeline import run_inventory
+from drm_copilot_discovery.catalog import load_catalog
+from drm_copilot_discovery.coverage_scope_rules import inventory_configuration_digest
+from drm_copilot_discovery.models import JsonObject, canonical_json
+from drm_copilot_discovery.profile_v2 import ProfileV2
+from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
+from drm_copilot_discovery.schema_validation import validate_document
+from drm_copilot_discovery.snapshot import SnapshotFile
+
+from tests.discovery_runtime.test_profile_v2 import profile_document
+from tests.discovery_runtime.validation_test_support import captured
+from tests.schemas.discovery.v2_schema_test_support import as_object
+
+if TYPE_CHECKING:
+    from drm_copilot_discovery.catalog import SchemaCatalog
+
+
+@pytest.fixture(scope="module")
+def analyzer_catalog() -> SchemaCatalog:
+    """Share immutable installed schemas while each test constructs isolated inputs.
+
+    Takes no caller arguments.
+
+    Returns SchemaCatalog containing immutable installed schemas; reads those
+    checked-in resources only.
+    """
+    return load_catalog()
+
+
+def inventory_profile(catalog: SchemaCatalog, **changes: object) -> ProfileV2:
+    """Build a neutral configured local-source profile with deterministic selectors.
+
+    Parameters: catalog (SchemaCatalog): trusted immutable schema catalog. changes
+    (object): explicit profile field overrides.
+
+    Returns ProfileV2 after schema validation; invalid overrides raise ProfileError.
+    No I/O or input mutation.
+    """
+    value = profile_document()
+    as_object(value["system"])["role"] = "legacy-source"
+    value.update(
+        repositories=[],
+        clients=[],
+        production_roots=["src"],
+        test_roots=[],
+        project_entry_points=[],
+        documentation_roots=["docs"],
+        excluded_paths=[],
+        analyzers={
+            "enabled": ["repository"],
+            "options": {},
+            "ignored_paths": [],
+            "extension_result_manifests": [],
+        },
+    )
+    value.update(changes)
+    return ProfileV2(json.dumps(value), format="json", catalog=catalog)
+
+
+def inventory_capture(
+    catalog: SchemaCatalog,
+    *,
+    names: tuple[str, ...] = ("src/app.sln", "src/main.cs"),
+    pinned: bool = True,
+) -> InventoryCapture:
+    """Capture synthetic source bytes and optional independently represented Git
+    blobs.
+
+    Parameters: catalog (SchemaCatalog): trusted immutable schema catalog. names
+    (tuple[str, ...]): synthetic relative source paths. pinned (bool): whether
+    independent Git blobs are provided.
+
+    Returns InventoryCapture with sorted source rows and optional pinned bytes. No
+    I/O or input mutation.
+    """
+    profile = inventory_profile(catalog)
+    # Preserve CRLF bytes so hashing cannot accidentally normalize source text.
+    files = tuple(
+        SnapshotFile(path=name, content=(name + "\r\n").encode(), category="source")
+        for name in names
+    )
+    identity = RepositoryIdentity(
+        id=profile.repository.id, revision=profile.repository.revision
+    )
+    snapshot = captured(profile, catalog, payloads=files)
+    # Git blobs are represented separately from working-copy input bytes.
+    snapshot = replace(
+        snapshot,
+        repository_files=(
+            tuple(
+                RepositoryFile(
+                    repository=identity, path=file.path, content=file.content
+                )
+                for file in files
+            )
+            if pinned
+            else ()
+        ),
+    )
+    return capture_snapshot(snapshot)
+
+
+def test_repository_detects_real_project_markers_without_claiming_inspection(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Build manifest names yield structural facts and only unassigned ledger
+    proposals.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    capture = inventory_capture(
+        analyzer_catalog,
+        names=(
+            "src/a.slnx",
+            "src/b.csproj",
+            "src/c.fsproj",
+            "src/d.vbproj",
+            "src/e.vcxproj",
+            "src/pyproject.toml",
+            "src/package.json",
+            "src/Cargo.toml",
+            "src/pom.xml",
+            "src/build.gradle",
+            "src/z.txt",
+        ),
+    )
+    result = run_inventory(
+        capture,
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=row(kind="tool", id="fixture"),
+        catalog=analyzer_catalog,
+    )
+    components = cast("tuple[JsonObject, ...]", result.document["components"])
+    assert len(components) == 11
+    # Real build filenames classify only generic structural units.
+    assert sorted(str(item["component_type"]) for item in components) == ["file"] + [
+        "project"
+    ] * 9 + ["solution"]
+    # Complete immutable provenance raises confidence without implying feature parity.
+    assert all(
+        item["classification"] == "detected" and item["confidence"] == "high"
+        for item in components
+    )
+    assert not result.document["diagnostics"]
+    # No detected component automatically acquires inspection or feature assignments.
+    assert all(
+        item["inspection_status"] == "uninspected"
+        and item["disposition"] == "unassigned"
+        and item["feature_refs"] == ()
+        for item in result.ledger_components
+    )
+    assert result.document[
+        "scan_configuration_sha256"
+    ] == inventory_configuration_digest(capture.profile)
+    assert validate_document(
+        canonical_json(result.document),
+        expected_kind="inventory-snapshot",
+        expected_version="2.0.0",
+        format="json",
+        catalog=analyzer_catalog,
+    ).ok
+
+
+def test_semantic_identity_ignores_capture_time_but_tracks_changed_bytes(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Clock metadata changes serialized bytes without changing semantic identity.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    capture = inventory_capture(analyzer_catalog)
+    author = row(kind="agent", id="fixture")
+    first = run_inventory(
+        capture,
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=author,
+        catalog=analyzer_catalog,
+    )
+    later = run_inventory(
+        capture,
+        timestamp="2026-10-19T02:00:00Z",
+        author_or_agent=author,
+        catalog=analyzer_catalog,
+        dry_run=True,
+    )
+    assert first.document["id"] == later.document["id"]
+    assert first.semantic_sha256 == later.semantic_sha256
+    assert canonical_json(first.document) != canonical_json(later.document)
+    changed = replace(
+        capture,
+        inputs=(
+            InventoryInput(
+                path="src/main.cs",
+                status="inspected",
+                file=SnapshotFile(
+                    path="src/main.cs", content=b"changed", category="source"
+                ),
+            ),
+        ),
+    )
+    different = run_inventory(
+        changed,
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=author,
+        catalog=analyzer_catalog,
+    )
+    assert different.semantic_sha256 != first.semantic_sha256
+
+
+def test_order_and_paths_are_portable_and_hashes_bind_exact_bytes(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Input ordering cannot affect inventory and CRLF hashes use original bytes.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    first = inventory_capture(analyzer_catalog, names=("src/z.cs", "src/État.cs"))
+    second = replace(first, inputs=tuple(reversed(first.inputs)))
+    one = run_inventory(
+        first,
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=row(kind="human", id="reviewer"),
+        catalog=analyzer_catalog,
+    )
+    two = run_inventory(
+        second,
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=row(kind="human", id="reviewer"),
+        catalog=analyzer_catalog,
+    )
+    assert one == two
+    files = cast("tuple[JsonObject, ...]", one.document["files"])
+    assert [item["path"] for item in files] == ["src/z.cs", "src/État.cs"]
+    assert files[0]["sha256"] == hashlib.sha256(b"src/z.cs\r\n").hexdigest()
+    assert files[0]["size"] == len(b"src/z.cs\r\n")
+
+
+def test_unavailable_and_unpinned_inputs_remain_visible_blockers(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Read failures and absent immutable proof cannot become verified source claims.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    capture = inventory_capture(analyzer_catalog, pinned=False)
+    capture = replace(
+        capture,
+        inputs=capture.inputs
+        + (
+            InventoryInput(
+                path="src/blocked.cs", status="unreadable", rationale="Access denied."
+            ),
+            InventoryInput(
+                path="src/vendor", status="excluded", rationale="External dependency."
+            ),
+        ),
+    )
+    result = run_inventory(
+        capture,
+        timestamp="2026-10-19T01:00:00Z",
+        author_or_agent=row(kind="tool", id="fixture"),
+        catalog=analyzer_catalog,
+    )
+    files = cast("tuple[JsonObject, ...]", result.document["files"])
+    # Select the explicit failed input instead of accepting an empty result.
+    blocked = next(item for item in files if item["status"] == "unreadable")
+    assert (
+        blocked["sha256"] is None
+        and blocked["size"] is None
+        and blocked["diagnostic_ids"]
+    )
+    assert len(cast("tuple[JsonObject, ...]", result.document["components"])) == 2
+    # Require both read-failure and immutable-source diagnostics to survive projection.
+    assert {
+        item["code"]
+        for item in cast("tuple[JsonObject, ...]", result.document["diagnostics"])
+    } == {"input-unreadable", "source-revision-unverified"}
+    # Missing immutable proof cannot silently receive high confidence.
+    assert all(
+        item["confidence"] == "low"
+        for item in cast("tuple[JsonObject, ...]", result.document["components"])
+    )
+
+
+def test_renamed_sources_and_changed_pins_do_not_match_retained_git_bytes(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Repository, revision, path and exact content must all identify the same input.
+
+    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
+    fixture.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    original = inventory_capture(analyzer_catalog)
+    # Alter each provenance dimension independently to catch partial identity checks.
+    for field, value in (
+        ("path", "src/other.cs"),
+        ("repository", RepositoryIdentity(id="other", revision="b" * 40)),
+        ("content", b"different"),
+    ):
+        # Keep all other source dimensions unchanged for each negative case.
+        sources = tuple(
+            replace(source, **{field: value}) for source in original.repository_files
+        )
+        analysis = RepositoryAnalyzer().analyze(
+            replace(original, repository_files=sources)
+        )
+        assert len(analysis.diagnostics) == 2
+        # Every affected component must retain the weakened confidence classification.
+        assert all(item["confidence"] == "low" for item in analysis.components)
--- a/tests/scripts/dev_tools/discovery/analyzer/test_cli.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_cli.py
@@ -4,8 +4,8 @@

 import json
 import re
-from pathlib import Path
 from typing import TYPE_CHECKING
+from unittest.mock import patch

 import pytest

@@ -21,6 +21,7 @@

 if TYPE_CHECKING:
     from collections.abc import Callable
+    from pathlib import Path


 def _fixed_clock() -> str:
@@ -64,13 +65,16 @@
     schema_path = mem_fs_path / "schemas" / "evidence-reference.schema.json"

     # Act (no clock injected -> production default provider runs)
-    exit_code = cli.main(["profile.yaml"], schema_path=schema_path)
+    with patch.object(cli, "run_analyzer", wraps=cli.run_analyzer) as run:
+        exit_code = cli.main(["profile.yaml"], schema_path=schema_path)

     # Assert
     assert exit_code == 0
-    written = next(iter((mem_fs_path / "out").iterdir()))
-    document = json.loads(written.read_text(encoding="utf-8"))
-    assert re.match(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$", document["captured_at"])
+    assert run.call_count == 1
+    assert re.match(
+        r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$", run.call_args.args[1].captured_at
+    )
+    assert not (mem_fs_path / "out").exists()


 def test_module_entry_point_imports_cli_main() -> None:
@@ -104,17 +108,17 @@
 # Exit-code group: successful run over an in-memory tree.


-def test_valid_run_exit_0_writes_instances_and_json_summary(
+def test_valid_run_exit_0_is_read_only_with_json_summary(
     mem_fs_path: Path,
     monkeypatch: pytest.MonkeyPatch,
     capsys: pytest.CaptureFixture[str],
 ) -> None:
-    """A valid run returns 0, writes instances, and prints a --json summary."""
+    """A valid run returns detected counts without implicitly publishing records."""
     # Arrange
     source_root = mem_fs_path / "src"
     (source_root).mkdir(parents=True, exist_ok=True)
     (source_root / "a.txt").write_text("aaa", encoding="utf-8")
-    (source_root / "app.solution").write_text("s", encoding="utf-8")
+    (source_root / "app.sln").write_text("s", encoding="utf-8")
     profile = _profile(str(source_root), str(mem_fs_path / "out"))
     monkeypatch.setattr(cli, "load_domain_profile", _stub_loader(profile))
     schema_path = mem_fs_path / "schemas" / "evidence-reference.schema.json"
@@ -128,9 +132,8 @@
     assert exit_code == 0
     summary = json.loads(capsys.readouterr().out)
     assert summary["record_count"] == 2
-    assert len(summary["written_paths"]) == 2
-    for written in summary["written_paths"]:
-        assert Path(written).exists()
+    assert summary["written_paths"] == []
+    assert not (mem_fs_path / "out").exists()


 def test_valid_run_output_dir_override(
@@ -147,16 +150,17 @@
     schema_path = mem_fs_path / "schemas" / "evidence-reference.schema.json"

     # Act
-    exit_code = cli.main(
-        ["profile.yaml", "--output-dir", str(override)],
-        clock=_fixed_clock,
-        schema_path=schema_path,
-    )
+    with patch.object(cli, "run_analyzer", wraps=cli.run_analyzer) as run:
+        exit_code = cli.main(
+            ["profile.yaml", "--output-dir", str(override)],
+            clock=_fixed_clock,
+            schema_path=schema_path,
+        )

     # Assert
     assert exit_code == 0
-    written = list(override.iterdir())
-    assert len(written) == 1
+    assert run.call_args.args[1].artifact_root == override
+    assert not override.exists()


 # Exit-code group: domain / analyzer errors map to exit code 1.
--- a/tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py
@@ -1,7 +1,7 @@
 """Domain-neutrality contract test over the analyzer production modules (scenario 8).

 The analyzer framework and inventory analyzer are epic-wide domain-neutral: no
-application- or stack-specific identifier may appear in their production source
+application- or optional-domain identifier may appear in their production source
 (code, field names, defaults, error messages, or docstrings).
 """

@@ -19,7 +19,7 @@
     / "analyzer"
 )

-# Case-insensitive banned identifiers plus stack literals.
+# Consumer and optional-domain identifiers remain banned in the reusable core.
 _BANNED_SUBSTRINGS = (
     "taskmaster",
     "tmw",
@@ -27,17 +27,11 @@
     "vsto",
     "email",
     "task-management",
-    ".csproj",
-    ".sln",
 )

-# Stack-specific analyzer modules delivered by feature #369. These modules are
-# stack-specific by charter, so the framework's stricter banned list (which bans
-# ``vsto``, ``.csproj``, ``.sln`` — legitimate pattern data for a .NET/VSTO
-# analyzer) must not be applied to them. Their consumer-neutrality is enforced by
-# the feature-scoped contract test ``test_stack_neutrality.py`` instead, per the
-# spec's Constraints & Risks scoping nuance. This framework test therefore scans
-# only #363's language-neutral modules.
+# Optional stack adapters retain their separate consumer-neutrality contract in
+# test_stack_neutrality.py. This scan includes both legacy adapters and canonical
+# reusable core modules; generic build filename markers are permitted structural data.
 _STACK_SPECIFIC_MODULES = frozenset(
     {
         "source_text.py",
@@ -56,9 +50,14 @@
     Stack-specific #369 modules are excluded because the framework's stricter
     banned list does not apply to them; see ``_STACK_SPECIFIC_MODULES``.
     """
+    runtime = (
+        Path(__file__).resolve().parents[5]
+        / "packages/discovery-runtime/src/drm_copilot_discovery/analyzer"
+    )
     return sorted(
         path
-        for path in _ANALYZER_DIR.glob("*.py")
+        for directory in (_ANALYZER_DIR, runtime)
+        for path in directory.glob("*.py")
         if path.name not in _STACK_SPECIFIC_MODULES
     )

--- a/tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py
@@ -19,6 +19,7 @@
     DotnetInventoryAnalyzer,
     classify_text,
 )
+from scripts.dev_tools.discovery.analyzer.emitter import serialize_record
 from scripts.dev_tools.discovery.analyzer.inventory import AnalyzerError
 from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext, ParseResult
 from scripts.dev_tools.discovery.analyzer.pipeline import (
@@ -371,9 +372,13 @@
         result = run_analyzer(analyzer, ctx, fs)

         # Assert
-        assert result.written_paths
-        for path in result.written_paths:
-            document = json.loads(path.read_text(encoding="utf-8"))
+        assert result.records and not result.written_paths
+        for record in result.records:
+            document = json.loads(
+                serialize_record(
+                    record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+                )
+            )
             validator.validate(document)
             top_level = set(document)
             assert _REQUIRED_TOP_LEVEL_KEYS <= top_level
@@ -399,12 +404,19 @@
         # Act
         first = run_analyzer(analyzer, ctx, fs)
         first_content = {
-            p.name: p.read_text(encoding="utf-8") for p in first.written_paths
+            record.id: serialize_record(
+                record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+            )
+            for record in first.records
         }
         second = run_analyzer(analyzer, ctx, fs)
         second_content = {
-            p.name: p.read_text(encoding="utf-8") for p in second.written_paths
+            record.id: serialize_record(
+                record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+            )
+            for record in second.records
         }

         # Assert
-        assert first_content == second_content
+        assert first_content and first_content == second_content
+        assert not ctx.artifact_root.exists()
--- a/tests/scripts/dev_tools/discovery/analyzer/test_emitter.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_emitter.py
@@ -159,8 +159,10 @@
     assert document["captured_at"] == clock()


-def test_emit_writes_instances_through_seam(mem_fs_path: Path) -> None:
-    """emit writes one JSON instance per record via the filesystem seam."""
+def test_emit_rejects_unguarded_writes_and_retains_serialization(
+    mem_fs_path: Path,
+) -> None:
+    """Legacy records still serialize, while direct publication fails before I/O."""
     # Arrange
     (mem_fs_path / "src").mkdir(parents=True, exist_ok=True)
     (mem_fs_path / "src" / "main.txt").write_text("abc", encoding="utf-8")
@@ -177,11 +179,17 @@

     # Act
     records = analyzer.map(analyzer.classify(analyzer.parse(ctx)))
-    written = analyzer.emit(records, fs)
-
-    # Assert
-    assert len(written) == 1
-    document = json.loads(written[0].read_text(encoding="utf-8"))
+    with pytest.raises(ValueError, match="guarded v2"):
+        analyzer.emit(records, fs)
+    with pytest.raises(ValueError, match="guarded v2"):
+        fs.write_text(ctx.artifact_root / "denied.json", "{}")
+
+    # Assert
+    assert len(records) == 1
+    assert not ctx.artifact_root.exists()
+    document = json.loads(
+        serialize_record(records[0], ctx.artifact_root / "record.json", ctx.schema_path)
+    )
     assert document["kind"] == "file"
     assert document["location"] == "src/main.txt"
     assert document["metadata"]["unit_type"] == UnitType.FILE.value
--- a/tests/scripts/dev_tools/discovery/analyzer/test_inventory.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_inventory.py
@@ -169,11 +169,11 @@
 @pytest.mark.parametrize(
     ("relative_path", "expected"),
     [
-        pytest.param("app.solution", UnitType.SOLUTION, id="solution-marker"),
-        pytest.param("lib.project", UnitType.PROJECT, id="project-marker"),
+        pytest.param("app.sln", UnitType.SOLUTION, id="solution-marker"),
+        pytest.param("lib.csproj", UnitType.PROJECT, id="project-marker"),
         pytest.param("src/main.txt", UnitType.FILE, id="plain-file"),
         pytest.param("nested/dir/notes.md", UnitType.FILE, id="non-matching"),
-        pytest.param("sub/core.solution", UnitType.SOLUTION, id="solution-in-subdir"),
+        pytest.param("sub/core.sln", UnitType.SOLUTION, id="solution-in-subdir"),
     ],
 )
 def test_classify_unit_uses_default_markers(
@@ -194,16 +194,16 @@

     # Act / Assert
     assert classify_unit("thing.pkg", custom) is UnitType.PROJECT
-    assert classify_unit("app.solution", custom) is UnitType.FILE
+    assert classify_unit("app.sln", custom) is UnitType.FILE


 def test_classify_paths_tags_every_unit() -> None:
     """classify_paths returns one classified unit per input path, in order."""
     # Act
-    units = classify_paths(("a.solution", "b.txt"), DEFAULT_MARKERS)
-
-    # Assert
-    assert tuple(u.relative_path for u in units) == ("a.solution", "b.txt")
+    units = classify_paths(("a.sln", "b.txt"), DEFAULT_MARKERS)
+
+    # Assert
+    assert tuple(u.relative_path for u in units) == ("a.sln", "b.txt")
     assert units[0].unit_type is UnitType.SOLUTION
     assert units[1].unit_type is UnitType.FILE

@@ -211,16 +211,16 @@
 def test_classify_stage_filters_then_tags(mem_fs_path: Path) -> None:
     """The classify stage applies include/exclude before tagging."""
     # Arrange
-    _write(mem_fs_path, "a.solution")
+    _write(mem_fs_path, "a.sln")
     _write(mem_fs_path, "b.txt")
     _write(mem_fs_path, "skip/c.txt")
     _write(mem_fs_path, "d.log")
     analyzer = InventoryAnalyzer(fs=RealAnalyzerFileSystem())
-    ctx = _context(mem_fs_path, include=("*.solution", "*.txt"), exclude=("skip/*",))
+    ctx = _context(mem_fs_path, include=("*.sln", "*.txt"), exclude=("skip/*",))

     # Act
     classified = analyzer.classify(analyzer.parse(ctx))

     # Assert
     tags = {u.relative_path: u.unit_type for u in classified.units}
-    assert tags == {"a.solution": UnitType.SOLUTION, "b.txt": UnitType.FILE}
+    assert tags == {"a.sln": UnitType.SOLUTION, "b.txt": UnitType.FILE}
--- a/tests/scripts/dev_tools/discovery/analyzer/test_inventory_e2e.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_inventory_e2e.py
@@ -13,6 +13,7 @@

 import pytest

+from scripts.dev_tools.discovery.analyzer.emitter import serialize_record
 from scripts.dev_tools.discovery.analyzer.inventory import InventoryAnalyzer
 from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext
 from scripts.dev_tools.discovery.analyzer.pipeline import (
@@ -30,10 +31,10 @@
     """Populate an in-memory consumer source tree."""
     source_root.mkdir(parents=True, exist_ok=True)
     (source_root / "a.txt").write_text("alpha", encoding="utf-8")
-    (source_root / "app.solution").write_text("sln", encoding="utf-8")
+    (source_root / "app.sln").write_text("sln", encoding="utf-8")
     sub = source_root / "sub"
     sub.mkdir(parents=True, exist_ok=True)
-    (sub / "b.project").write_text("proj", encoding="utf-8")
+    (sub / "b.csproj").write_text("proj", encoding="utf-8")


 def _context(source_root: Path, out_root: Path) -> AnalyzerContext:
@@ -62,15 +63,11 @@

     # Assert
     assert len(result.records) == 3
-    assert len(result.written_paths) == 3
-    kinds = {
-        json.loads(p.read_text(encoding="utf-8"))["kind"] for p in result.written_paths
-    }
+    assert result.written_paths == ()
+    assert not ctx.artifact_root.exists()
+    kinds = {record.kind for record in result.records}
     assert kinds == {"file"}
-    unit_types = {
-        json.loads(p.read_text(encoding="utf-8"))["metadata"]["unit_type"]
-        for p in result.written_paths
-    }
+    unit_types = {dict(record.metadata)["unit_type"] for record in result.records}
     assert unit_types == {"file", "solution", "project"}


@@ -85,14 +82,22 @@

     # Act
     first = run_analyzer(analyzer, ctx, fs)
-    first_content = {p.name: p.read_text(encoding="utf-8") for p in first.written_paths}
+    first_content = {
+        record.id: serialize_record(
+            record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+        )
+        for record in first.records
+    }
     second = run_analyzer(analyzer, ctx, fs)
     second_content = {
-        p.name: p.read_text(encoding="utf-8") for p in second.written_paths
+        record.id: serialize_record(
+            record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+        )
+        for record in second.records
     }

     # Assert
-    assert first_content == second_content
+    assert first_content and first_content == second_content


 @pytest.mark.skipif(
@@ -114,6 +119,11 @@
     result = run_analyzer(analyzer, ctx, fs)

     # Assert
-    for path in result.written_paths:
-        document = json.loads(path.read_text(encoding="utf-8"))
+    assert len(result.records) == 3 and not result.written_paths
+    for record in result.records:
+        document = json.loads(
+            serialize_record(
+                record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+            )
+        )
         jsonschema.validate(instance=document, schema=schema)
--- a/tests/scripts/dev_tools/discovery/analyzer/test_pipeline.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_pipeline.py
@@ -108,7 +108,9 @@


 def test_run_analyzer_invokes_stages_in_fixed_order_and_threads_outputs() -> None:
-    """run_analyzer calls parse -> classify -> map -> emit and returns their outputs."""
+    """run_analyzer calls parse -> classify -> map and returns records without
+    emission.
+    """
     # Arrange
     analyzer = _RecordingAnalyzer()
     fs = _ExplodingFileSystem()
@@ -117,9 +119,9 @@
     result = run_analyzer(analyzer, _context(), fs)

     # Assert
-    assert analyzer.calls == ["parse", "classify", "map", "emit"]
+    assert analyzer.calls == ["parse", "classify", "map"]
     assert result.records == analyzer.expected_records
-    assert result.written_paths == analyzer.expected_written
+    assert result.written_paths == ()


 def test_package_reexports_public_surface() -> None:
--- a/tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py
@@ -71,10 +71,10 @@
 class TestSuccessPaths:
     """Success-path behavior shared by both entry points."""

-    def test_success_writes_instances(
+    def test_success_keeps_default_run_read_only(
         self, entry: EntryPoint, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
     ) -> None:
-        """A valid run exits 0 and writes at least one instance."""
+        """A valid run exits 0 without creating artifacts."""
         # Arrange
         source_root = mem_fs_path / "consumer"
         out_root = mem_fs_path / "out"
@@ -91,9 +91,7 @@

         # Assert
         assert code == 0
-        written = list(out_root.iterdir())
-        assert written
-        assert all(p.name.endswith(".json") for p in written)
+        assert not out_root.exists()

     def test_json_summary(
         self,
@@ -120,7 +118,7 @@

         # Assert
         assert code == 0
-        assert summary["record_count"] == len(summary["written_paths"])
+        assert summary["written_paths"] == []
         assert summary["record_count"] >= 1

     def test_output_dir_override(
@@ -142,9 +140,9 @@
             schema_path=mem_fs_path / "schemas" / "s.json",
         )

-        # Assert: instances land under the override root, not the profile root.
+        # Assert: selecting an output root alone does not authorize publication.
         assert code == 0
-        assert list(override_out.iterdir())
+        assert not override_out.exists()
         assert not profile_out.exists()


--- a/tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py
+++ b/tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py
@@ -15,6 +15,7 @@

 import pytest

+from scripts.dev_tools.discovery.analyzer.emitter import serialize_record
 from scripts.dev_tools.discovery.analyzer.inventory import AnalyzerError
 from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext, ParseResult
 from scripts.dev_tools.discovery.analyzer.pipeline import (
@@ -435,9 +436,13 @@
         result = run_analyzer(analyzer, ctx, fs)

         # Assert
-        assert result.written_paths
-        for path in result.written_paths:
-            document = json.loads(path.read_text(encoding="utf-8"))
+        assert result.records and not result.written_paths
+        for record in result.records:
+            document = json.loads(
+                serialize_record(
+                    record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+                )
+            )
             validator.validate(document)
             top_level = set(document)
             assert _REQUIRED_TOP_LEVEL_KEYS <= top_level
@@ -463,12 +468,19 @@
         # Act
         first = run_analyzer(analyzer, ctx, fs)
         first_content = {
-            p.name: p.read_text(encoding="utf-8") for p in first.written_paths
+            record.id: serialize_record(
+                record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+            )
+            for record in first.records
         }
         second = run_analyzer(analyzer, ctx, fs)
         second_content = {
-            p.name: p.read_text(encoding="utf-8") for p in second.written_paths
+            record.id: serialize_record(
+                record, ctx.artifact_root / f"{record.id}.json", ctx.schema_path
+            )
+            for record in second.records
         }

         # Assert
-        assert first_content == second_content
+        assert first_content and first_content == second_content
+        assert not ctx.artifact_root.exists()

```
