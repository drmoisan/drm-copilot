# P4-T1 three-finding correction

Baseline: checked WIP `34278a5db7fed0653886c46e599304691628a4b9`. Exactly three owned paths changed.

```diff
--- a/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py
+++ b/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py
@@ -109,12 +109,17 @@
     and ProfileError for draft configuration; performs no I/O or mutation.
     """
     rules = exclusion_rules(snapshot.profile)
-    # Retain only selected repository inputs; artifact payloads have separate roles.
-    inputs = [
-        InventoryInput(path=file.path, status="inspected", file=file)
-        for file in snapshot.manifest.files
-        if file.category in {"source", "test", "documentation"}
-    ]
+    inputs: list[InventoryInput] = []
+    # Documentation captures can contain generated views; exclude them before claims.
+    for file in snapshot.manifest.files:
+        if file.category not in {"source", "test", "documentation"}:
+            continue
+        reason = exclusion_reason(file.path, rules)
+        inputs.append(
+            InventoryInput(path=file.path, status="excluded", rationale=reason)
+            if reason is not None
+            else InventoryInput(path=file.path, status="inspected", file=file)
+        )
     # Every omitted frontier must remain explainable from the current configuration.
     for path in snapshot.excluded_paths:
         reason = exclusion_reason(path, rules)
@@ -177,9 +182,12 @@
         + profile.project_entry_points
         + profile.documentation_roots
     )
-    pending = list(check_path_collisions(sorted(set(roots))))
+    selected = check_path_collisions(sorted(set(roots)))
+    if len(selected) > profile.limits.source_files:
+        raise ValueError("Analyzer root enumeration limit exceeded")
+    pending = list(selected)
     heapq.heapify(pending)
-    visited: set[str] = set()
+    discovered = set(selected)
     inputs: list[InventoryInput] = []
     rules = exclusion_rules(profile)
     total_bytes = 0
@@ -191,11 +199,6 @@
     # Ordinal traversal makes both successful input order and bounded failures stable.
     while pending:
         path = heapq.heappop(pending)
-        if path in visited:
-            continue
-        visited.add(path)
-        if len(visited) > profile.limits.source_files:
-            raise ValueError("Analyzer entry enumeration limit exceeded")
         reason = exclusion_reason(path, rules)
         # Prune configured frontiers before probing descendants or opening bytes.
         if reason is not None:
@@ -210,7 +213,14 @@
                 raise ValueError("Analyzer directory enumeration limit exceeded")
             # Keep all immediate children, including hidden and unfamiliar filenames.
             for child in entry.children:
-                heapq.heappush(pending, f"{path}/{child}")
+                child_path = f"{path}/{child}"
+                # Overlapping roots cost one entry; reject new allocation at the bound.
+                if child_path in discovered:
+                    continue
+                if len(discovered) >= profile.limits.source_files:
+                    raise ValueError("Analyzer aggregate entry limit exceeded")
+                discovered.add(child_path)
+                heapq.heappush(pending, child_path)
             continue
         try:
             content = cast(
@@ -293,6 +303,9 @@
                 "Inventory repository reader returned an unexpected object"
             )
         objects.append(source)
+    # A checkout change during the final blob read invalidates the whole capture.
+    if repository.identity() != identity:
+        raise ValueError("Inventory repository identity changed during source capture")
     return replace(
         workspace, snapshot=replace(snapshot, repository_files=tuple(objects))
     )
--- a/tests/discovery_runtime/analyzer/test_input_capture.py
+++ b/tests/discovery_runtime/analyzer/test_input_capture.py
@@ -323,6 +323,7 @@
         self.files = files
         self.calls: list[str] = []
         self.wrong_path = False
+        self.change_after_read = False

     def identity(self) -> RepositoryIdentity:
         """Return the configured synthetic checkout identity without inferring it.
@@ -343,26 +344,31 @@

         Returns RepositoryFile containing exact immutable fixture bytes. Raises
         FileNotFoundError for absent blobs or AssertionError for invalid requests;
-        appends only to the fixture call list.
+        records calls and may change its synthetic checkout identity.
         """
         assert revision == self.local.revision and limit > 0
         self.calls.append(path)
         if path not in self.files:
             raise FileNotFoundError(path)
-        return RepositoryFile(
+        result = RepositoryFile(
             repository=self.local,
             path="docs/wrong" if self.wrong_path else path,
             content=self.files[path],
         )
-
-
+        # Simulate a valid last blob followed by an independently changed checkout.
+        if self.change_after_read:
+            self.local = RepositoryIdentity(id=self.local.id, revision="b" * 40)
+        return result
+
+
+@pytest.mark.parametrize("change_during_read", [False, True])
 def test_pin_capture_preserves_existing_objects_and_refuses_missing_or_foreign_pins(
-    analyzer_catalog: SchemaCatalog,
+    analyzer_catalog: SchemaCatalog, change_during_read: bool
 ) -> None:
     """Publication precapture is idempotent and never substitutes working-copy bytes.

     Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
-    fixture.
+    fixture. change_during_read (bool): inject a checkout change during its last read.

     Returns None. Raises AssertionError when the asserted contract differs; uses
     only test-local memory and immutable schema fixtures.
@@ -379,6 +385,13 @@
         metadata=((".", store.metadata(".")),),
     )
     repository = MemoryRepository(profile, {source.path: source.content})
+    repository.change_after_read = change_during_read
+    # Even an otherwise valid final object cannot authorize a stale checkout capture.
+    if change_during_read:
+        with pytest.raises(ValueError, match="identity changed during source capture"):
+            pin_inventory_sources(workspace, repository)
+        assert repository.calls == [source.path]
+        return
     first = pin_inventory_sources(workspace, repository)
     assert first.snapshot.repository_files[0].content == source.content
     assert pin_inventory_sources(first, repository) == first
@@ -393,3 +406,46 @@
     repository.local = RepositoryIdentity(id="other", revision="b" * 40)
     with pytest.raises(ValueError, match="configured local pin"):
         pin_inventory_sources(workspace, repository)
+
+
+def test_branching_frontier_is_bounded_before_descendant_reads(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Reject cumulative entries even when every directory individually fits.
+
+    analyzer_catalog (SchemaCatalog) supplies immutable schemas. Returns None;
+    assertion failure identifies unbounded traversal. Uses only local memory.
+    """
+    profile = inventory_profile(
+        analyzer_catalog, documentation_roots=[], limits={"source_files": 4}
+    )
+    store = MemoryStore()
+    # Each directory is individually small, but their combined frontier is too large.
+    for name in ("a", "b", "c"):
+        store.put(f"src/{name}/one", b"first")
+        store.put(f"src/{name}/two", b"second")
+    with pytest.raises(ValueError, match="aggregate entry limit"):
+        read_capture(profile, store)
+    assert not store.calls, "Traversal must fail before reading queued descendants"
+
+
+def test_overlapping_roots_share_one_discovered_entry_budget(
+    analyzer_catalog: SchemaCatalog,
+) -> None:
+    """Preserve deterministic deduplication when configured roots overlap.
+
+    analyzer_catalog (SchemaCatalog) supplies immutable schemas. Returns None;
+    assertion failure indicates duplicate allocation or reads. Uses only memory.
+    """
+    profile = inventory_profile(
+        analyzer_catalog,
+        production_roots=["src", "src/nested"],
+        project_entry_points=["src/nested/a.cs"],
+        documentation_roots=[],
+        limits={"source_files": 3},
+    )
+    store = MemoryStore()
+    store.put("src/nested/a.cs", b"class A {}")
+    result = read_capture(profile, store)
+    assert [item.path for item in result.inputs] == ["src/nested/a.cs"]
+    assert len(store.calls) == 2, "Only original and freshness reads are permitted"
--- a/tests/discovery_runtime/analyzer/test_pipeline.py
+++ b/tests/discovery_runtime/analyzer/test_pipeline.py
@@ -5,7 +5,7 @@
 from __future__ import annotations

 from dataclasses import replace
-from typing import TYPE_CHECKING, cast
+from typing import TYPE_CHECKING, Literal, cast

 import pytest
 from drm_copilot_discovery.analyzer.emitter import inventory_result
@@ -94,10 +94,12 @@

 def publication_case(
     catalog: SchemaCatalog,
+    generated: tuple[Literal["reports", "acceptance"], str] | None = None,
 ) -> tuple[InventoryWriter, CapturedWorkspace, InventoryResult, WriteGrant]:
     """Create an incomplete workspace whose first inventory includes a real document.

-    Parameters: catalog (SchemaCatalog): trusted immutable schema catalog.
+    Parameters: catalog (SchemaCatalog): trusted immutable schema catalog. generated
+    (tuple[str, str] | None): optional output-root key and generated document name.

     Returns tuple[InventoryWriter, CapturedWorkspace, InventoryResult, WriteGrant]
     for guarded publication. Reads and mutates only a new memory store; validation
@@ -108,6 +110,10 @@
     store.put(profile.artifacts["profile"], canonical_json(profile.document))
     store.put("src/main.cs", b"class Main {}\r\n")
     store.put("docs/guide.md", b"Observed guide.\n")
+    # Existing generated views are output artifacts even inside documentation roots.
+    if generated is not None:
+        kind, name = generated
+        store.put(profile.artifacts[kind] + "/" + name, b"Generated output.\n")
     repository = MemoryRepository(
         profile,
         {"src/main.cs": b"class Main {}\r\n", "docs/guide.md": b"Observed guide.\n"},
@@ -150,19 +156,37 @@
     assert len(first.ledger_components) == 2


+@pytest.mark.parametrize(
+    "generated",
+    [None, ("reports", "coverage-report.md"), ("acceptance", "criteria.feature")],
+)
 def test_inventory_publication_is_explicit_idempotent_and_scope_preserving(
     analyzer_catalog: SchemaCatalog,
+    generated: tuple[Literal["reports", "acceptance"], str] | None,
 ) -> None:
     """First publication passes real schema/graph/CAS gates and creates only
     inventory.

     Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
-    fixture.
-
-    Returns None. Raises AssertionError when the asserted contract differs; uses
-    only test-local memory and immutable schema fixtures.
-    """
-    writer, baseline, result, grant = publication_case(analyzer_catalog)
+    fixture. generated (tuple[str, str] | None): optional existing generated output.
+
+    Returns None. Raises AssertionError when the asserted contract differs; uses
+    only test-local memory and immutable schema fixtures.
+    """
+    writer, baseline, result, grant = publication_case(analyzer_catalog, generated)
+    # Output bytes may be documentation to the loader but never analyzer sources.
+    if generated is not None:
+        kind, name = generated
+        output_path = baseline.snapshot.profile.artifacts[kind] + "/" + name
+        excluded = next(
+            item
+            for item in capture_snapshot(baseline.snapshot).inputs
+            if item.path == output_path
+        )
+        assert excluded.status == "excluded" and excluded.rationale
+        assert excluded.file is None and excluded.sha256 is None
+        assert output_path not in writer.repository.calls
+        assert output_path not in {item["path"] for item in result.ledger_components}
     before = dict(writer.store.files)
     plan = plan_inventory(baseline, result, grants=(grant,))
     assert dict(writer.store.files) == before

```
