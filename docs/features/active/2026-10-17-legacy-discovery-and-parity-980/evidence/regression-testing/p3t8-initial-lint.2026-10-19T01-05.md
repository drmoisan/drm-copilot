# p3t8-initial-lint

Timestamp: 2026-10-19T01-05
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/source_read_models.py packages/discovery-runtime/src/drm_copilot_discovery/source_reads.py tests/discovery_runtime/test_source_reads.py tests/discovery_runtime/test_source_read_limits.py
EXIT_CODE: 1
Output Summary: FAIL scoped P3-T8 stage 2; duration 1.176 seconds. Exact source hashes are in the paired JSON receipt.

```text
F401 [*] `drm_copilot_discovery.path_models.PathMetadata` imported but unused
  --> tests\discovery_runtime\test_source_read_limits.py:10:47
   |
 9 | import pytest
10 | from drm_copilot_discovery.path_models import PathMetadata, PathPolicyError
   |                                               ^^^^^^^^^^^^
11 | from drm_copilot_discovery.profile_v2 import parse_profile_v2
12 | from drm_copilot_discovery.repository_reader import RepositoryIdentity
   |
help: Remove unused import: `drm_copilot_discovery.path_models.PathMetadata`

F401 [*] `tests.discovery_runtime.test_source_reads.read_catalog` imported but unused
  --> tests\discovery_runtime\test_source_read_limits.py:35:5
   |
33 |     install_transport,
34 |     make_reader,
35 |     read_catalog,
   |     ^^^^^^^^^^^^
36 |     read_profile,
37 | )
   |
help: Remove unused import

F401 [*] `tests.discovery_runtime.test_source_reads.read_profile` imported but unused
  --> tests\discovery_runtime\test_source_read_limits.py:36:5
   |
34 |     make_reader,
35 |     read_catalog,
36 |     read_profile,
   |     ^^^^^^^^^^^^
37 | )
38 | from tests.schemas.discovery.v2_schema_test_support import as_object
   |
help: Remove unused import

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\test_source_read_limits.py:193:9
    |
191 |     grant = ReadGrant(path="src/a")
192 |     with pytest.raises(FrozenInstanceError):
193 |         setattr(grant, "path", "src/b")
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
194 |     span = SourceSpan(line=1, column_start=1, column_end=1)
195 |     assert span.column_start == span.column_end
    |
help: Replace `setattr` with assignment

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:217:5
    |
215 | )
216 | def test_independent_limits_fail_without_partial_output(
217 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
218 |     read_catalog: SchemaCatalog,
219 |     axis: str,
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:218:5
    |
216 | def test_independent_limits_fail_without_partial_output(
217 |     read_profile: ProfileV2,
218 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
219 |     axis: str,
220 |     value: int,
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:236:5
    |
235 | def test_match_and_line_limits_are_aggregate_across_files(
236 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
237 |     read_catalog: SchemaCatalog,
238 | ) -> None:
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:237:5
    |
235 | def test_match_and_line_limits_are_aggregate_across_files(
236 |     read_profile: ProfileV2,
237 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
238 | ) -> None:
239 |     """Prevent per-file resets from bypassing global observation bounds."""
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:258:5
    |
256 | )
257 | def test_enumeration_is_bounded_before_any_bytes_are_read(
258 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
259 |     read_catalog: SchemaCatalog,
260 |     fault: str,
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:259:5
    |
257 | def test_enumeration_is_bounded_before_any_bytes_are_read(
258 |     read_profile: ProfileV2,
259 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
260 |     fault: str,
261 | ) -> None:
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:290:5
    |
288 | )
289 | def test_physical_path_failures_cannot_cross_workspace_boundaries(
290 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
291 |     read_catalog: SchemaCatalog,
292 |     fault: str,
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:291:5
    |
289 | def test_physical_path_failures_cannot_cross_workspace_boundaries(
290 |     read_profile: ProfileV2,
291 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
292 |     fault: str,
293 | ) -> None:
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F821 Undefined name `PathKind`
   --> tests\discovery_runtime\test_source_read_limits.py:299:48
    |
297 |     # Metadata is the only seam altered; no test creates a physical link or file.
298 |     if fault in {"symlink", "reparse"}:
299 |         store.metadata.add("src/a", kind=cast("PathKind", fault))
    |                                                ^^^^^^^^
300 |     elif fault == "alias":
301 |         store.metadata.add("src/a", actual="/elsewhere/a")
    |

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:314:5
    |
313 | def test_json_output_budget_pages_complete_rows_without_loss(
314 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
315 |     read_catalog: SchemaCatalog,
316 | ) -> None:
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:315:5
    |
313 | def test_json_output_budget_pages_complete_rows_without_loss(
314 |     read_profile: ProfileV2,
315 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
316 | ) -> None:
317 |     """Return only complete rows fitting actual UTF-8 JSON, then continue exactly."""
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:339:5
    |
337 | @pytest.mark.parametrize("change", ("bytes", "request", "selection", "offset"))
338 | def test_continuation_rejects_changed_content_authority_or_request(
339 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
340 |     read_catalog: SchemaCatalog,
341 |     change: str,
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:340:5
    |
338 | def test_continuation_rejects_changed_content_authority_or_request(
339 |     read_profile: ProfileV2,
340 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
341 |     change: str,
342 | ) -> None:
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:376:5
    |
374 | )
375 | def test_snapshot_integrity_reads_apply_bounds_to_every_member(
376 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
377 |     read_catalog: SchemaCatalog,
378 |     fault: str,
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:377:5
    |
375 | def test_snapshot_integrity_reads_apply_bounds_to_every_member(
376 |     read_profile: ProfileV2,
377 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
378 |     fault: str,
379 | ) -> None:
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:415:5
    |
414 | def test_entry_addition_during_read_fails_freshness_without_partial_page(
415 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
416 |     read_catalog: SchemaCatalog,
417 | ) -> None:
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:416:5
    |
414 | def test_entry_addition_during_read_fails_freshness_without_partial_page(
415 |     read_profile: ProfileV2,
416 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
417 | ) -> None:
418 |     """Detect changed parent enumeration using only an injected in-memory read."""
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F811 Redefinition of unused `read_profile` from line 36
   --> tests\discovery_runtime\test_source_read_limits.py:434:5
    |
433 | def test_invalid_typed_reader_inputs_are_rejected_before_io(
434 |     read_profile: ProfileV2,
    |     ^^^^^^^^^^^^ `read_profile` redefined here
435 |     read_catalog: SchemaCatalog,
436 | ) -> None:
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:36:5
    |
 34 |     make_reader,
 35 |     read_catalog,
 36 |     read_profile,
    |     ------------ previous definition of `read_profile` here
 37 | )
 38 | from tests.schemas.discovery.v2_schema_test_support import as_object
    |
help: Remove definition: `read_profile`

F811 Redefinition of unused `read_catalog` from line 35
   --> tests\discovery_runtime\test_source_read_limits.py:435:5
    |
433 | def test_invalid_typed_reader_inputs_are_rejected_before_io(
434 |     read_profile: ProfileV2,
435 |     read_catalog: SchemaCatalog,
    |     ^^^^^^^^^^^^ `read_catalog` redefined here
436 | ) -> None:
437 |     """Reject wrapper misuse at the native reader boundary without coercion."""
    |
   ::: tests\discovery_runtime\test_source_read_limits.py:35:5
    |
 33 |     install_transport,
 34 |     make_reader,
 35 |     read_catalog,
    |     ------------ previous definition of `read_catalog` here
 36 |     read_profile,
 37 | )
    |
help: Remove definition: `read_catalog`

F401 [*] `tests.schemas.discovery.v2_schema_test_support.as_object` imported but unused
  --> tests\discovery_runtime\test_source_reads.py:25:60
   |
23 | from tests.discovery_runtime.test_profile_v2 import profile_document
24 | from tests.discovery_runtime.test_snapshot_io import MemoryStore
25 | from tests.schemas.discovery.v2_schema_test_support import as_object
   |                                                            ^^^^^^^^^
26 |
27 | if TYPE_CHECKING:
   |
help: Remove unused import: `tests.schemas.discovery.v2_schema_test_support.as_object`

E501 Line too long (89 > 88)
  --> tests\discovery_runtime\test_source_reads.py:70:89
   |
68 | def install_transport(store: MemoryStore, route: TransportRoute) -> ReadSelection:
69 |     """Install inert committed-header members in memory; return explicit selection."""
70 |     # Every member is declared and independently hashed by the accepted transport helper.
   |                                                                                         ^
71 |     for member in route.members:
72 |         store.put(
   |

F821 Undefined name `ReadOperation`
   --> tests\discovery_runtime\test_source_reads.py:254:25
    |
252 |     store.put("src/empty", b"")
253 |     request = SourceReadRequest(
254 |         operation=cast("ReadOperation", operation),
    |                         ^^^^^^^^^^^^^
255 |         paths=("src/empty",),
256 |         query="value" if operation == "search" else None,
    |

Found 26 errors.
[*] 5 fixable with the `--fix` option.
```
