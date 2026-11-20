# p4t9-core-focused2 ruff

Timestamp: 2026-10-19T13-03

Command: .\.venv\Scripts\python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/extension_validation.py packages/discovery-runtime/src/drm_copilot_discovery/extension_results.py tests/discovery_runtime/test_extension_results.py tests/discovery_runtime/test_extension_inventory_merge.py

EXIT_CODE: 1

Output Summary: Scoped ruff; elapsed 0.109 seconds. Exact stream hashes/lengths bind the path-sanitized presentation.

```text
TC001 Move application import `drm_copilot_discovery.models.JsonObject` into a type-checking block
  --> packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:28:42
   |
26 |     ValidatedExtension as ValidatedExtension,
27 | )
28 | from drm_copilot_discovery.models import JsonObject, canonical_json
   |                                          ^^^^^^^^^^
29 |
30 | if TYPE_CHECKING:
   |
help: Move into type-checking block

F401 [*] `drm_copilot_discovery.models.canonical_json` imported but unused
  --> packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:28:54
   |
26 |     ValidatedExtension as ValidatedExtension,
27 | )
28 | from drm_copilot_discovery.models import JsonObject, canonical_json
   |                                                      ^^^^^^^^^^^^^^
29 |
30 | if TYPE_CHECKING:
   |
help: Remove unused import: `drm_copilot_discovery.models.canonical_json`

E501 Line too long (93 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:92:89
   |
90 |             context.source(cast("JsonObject", item["source"]))
91 |             properties = cast("tuple[JsonObject, ...]", item.get("properties", ()))
92 |             # Duplicate names with different values are ambiguous despite distinct JSON rows.
   |                                                                                         ^^^^^
93 |             if len({value["name"] for value in properties}) != len(properties):
94 |                 raise ExtensionResultError("EXTENSION_COLLISION")
   |

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:175:89
    |
173 |     context: ExtensionValidation, manifest_paths: tuple[str, ...] | None
174 | ) -> tuple[ValidatedExtension, ...]:
175 |     """Select only configured manifests; return deterministic complete results or fail."""
    |                                                                                         ^^
176 |     configured = context.snapshot.profile.analyzers.extension_result_manifests
177 |     selected = configured if manifest_paths is None else manifest_paths
    |

E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:233:89
    |
231 |     for extension in extensions:
232 |         reservation.reserve(extension.adapter)
233 |         # All row families, including error diagnostics, consume the shared output ceiling.
    |                                                                                         ^^^
234 |         for family, key in _FAMILIES:
235 |             rows = cast("tuple[JsonObject, ...]", getattr(extension.analysis, family))
    |

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:271:89
    |
269 |         )
270 |         _merge_budget(context, core, extensions)
271 |         # Preflight completed before these collections or the emitted merge are allocated.
    |                                                                                         ^^
272 |         analyses = (_analysis(core.document),) + tuple(
273 |             item.analysis for item in extensions
    |

E501 Line too long (93 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_results.py:275:89
    |
273 |             item.analysis for item in extensions
274 |         )
275 |         # External versions come only from the validated descriptors, never runtime defaults.
    |                                                                                         ^^^^^
276 |         adapters = tuple(item.adapter for item in extensions)
277 |         # The emitter keeps built-in selection separate from external version authority.
    |

E501 Line too long (91 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:81:89
   |
79 |         self, *, max_bytes: int, max_records: int, max_nodes: int, max_depth: int
80 |     ) -> None:
81 |         """Accept positive exact integers; initialize counters or raise EXTENSION_LIMIT."""
   |                                                                                         ^^^
82 |         # Reject bool/float/unbounded user overrides before traversal or allocation.
83 |         for value in (max_bytes, max_records, max_nodes, max_depth):
   |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:105:89
    |
104 |     def _bytes(self, count: int) -> None:
105 |         """Charge count (int) before allocation; return None or raise the fixed limit."""
    |                                                                                         ^
106 |         self.bytes += count
107 |         if self.bytes > self.max_bytes:
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:156:89
    |
155 | def budget(limits: ProfileLimits) -> ExtensionBudget:
156 |     """Return a fresh reservation using validated profile units, without side effects."""
    |                                                                                         ^
157 |     return ExtensionBudget(
158 |         max_bytes=limits.document_bytes,
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:179:89
    |
178 |     def __init__(self, snapshot: DiscoverySnapshot) -> None:
179 |         """Build bounded indexes from snapshot; raise fixed errors on invalid capture."""
    |                                                                                         ^
180 |         if type(snapshot) is not DiscoverySnapshot or not snapshot.ok:
181 |             raise ExtensionResultError("EXTENSION_SNAPSHOT")
    |

E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:197:89
    |
195 |         self.inputs = object_rows(self.projection, "inputs")
196 |         self.input_index = {item.path: item for item in self.capture.inputs}
197 |         # Only source/test or exact project inputs can satisfy the current loader contract.
    |                                                                                         ^^^
198 |         self.sources = {
199 |             cast("str", item["path"]): item
    |

E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:204:89
    |
202 |             and (item["category"] in {"source", "test"} or item["entry_point"] is True)
203 |         }
204 |         # Pinned descriptors were derived from retained Git bytes by the shared projection.
    |                                                                                         ^^^
205 |         self.pins = {
206 |             cast("str", item["path"]): item
    |

E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:226:89
    |
225 |     def read(self, path: str, kind: str) -> tuple[SnapshotFile, JsonObject]:
226 |         """Validate bounded retained bytes for path/kind; return file and trusted document.
    |                                                                                         ^^^
227 |
228 |         Rejects reuse, missing files and unsupported schemas with fixed diagnostics.
    |

E501 Line too long (92 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:254:89
    |
253 |     def source_inputs(self, manifest: JsonObject) -> None:
254 |         """Require complete source/test descriptors and exact retained pins; return None."""
    |                                                                                         ^^^^
255 |         inputs = object_rows(manifest, "source_inputs")
256 |         if len(inputs) != len(self.sources):
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:273:89
    |
272 |     def source(self, value: JsonObject) -> None:
273 |         """Validate a row source against declared complete pinned inputs; return None."""
    |                                                                                         ^
274 |         path = cast("str", value["path"])
275 |         expected = self.sources.get(path)
    |

E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\extension_validation.py:301:89
    |
300 |     def unique(self, family: str, identifier: str) -> None:
301 |         """Reserve a family/identifier pair; return None or reject ambiguous identities."""
    |                                                                                         ^^^
302 |         key = (family, identifier)
303 |         if key in self.identifiers:
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_extension_inventory_merge.py:3:1
   |
 1 |   """Verify reconstruction, complete accounting and independent merge resource bounds."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import replace
 6 | | from typing import TYPE_CHECKING, cast
 7 | |
 8 | | import pytest
 9 | | from drm_copilot_discovery.analyzer.findings import diagnostic, row
10 | | from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
11 | | from drm_copilot_discovery.analyzer.models import Analysis
12 | | from drm_copilot_discovery.analyzer.pipeline import run_inventory
13 | | from drm_copilot_discovery.extension_inputs import extension_input_digest
14 | | from drm_copilot_discovery.extension_results import (
15 | |     ExtensionResultError,
16 | |     ValidatedExtension,
17 | |     merge_extension_inventory,
18 | |     validate_extension_results,
19 | | )
20 | | from drm_copilot_discovery.extension_validation import (
21 | |     ExtensionBudget,
22 | |     ExtensionValidation,
23 | |     object_rows,
24 | | )
25 | | from drm_copilot_discovery.findings import Finding
26 | | from drm_copilot_discovery.models import (
27 | |     JsonObject,
28 | |     JsonValue,
29 | |     canonical_json,
30 | |     to_plain_value,
31 | | )
32 | | from drm_copilot_discovery.profile_models import ProfileLimits
33 | | from drm_copilot_discovery.schema_validation import validate_document
34 | |
35 | | from tests.discovery_runtime.analyzer.test_repository import (
36 | |     analyzer_catalog as analyzer_catalog,
37 | | )
38 | | from tests.discovery_runtime.test_extension_results import (
39 | |     ADAPTER,
40 | |     AUTHOR,
41 | |     MANIFEST,
42 | |     MEMBER,
43 | |     STAMP,
44 | |     bundle as bundle,
45 | |     documents,
46 | |     edit_bundle,
47 | |     set_field,
48 | | )
49 | | from tests.schemas.discovery.v2_schema_test_support import as_object
   | |____________________________________________________________________^
50 |
51 |   if TYPE_CHECKING:
   |
help: Organize imports

F401 [*] `drm_copilot_discovery.analyzer.models.Analysis` imported but unused
  --> tests\discovery_runtime\test_extension_inventory_merge.py:11:51
   |
 9 | from drm_copilot_discovery.analyzer.findings import diagnostic, row
10 | from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
11 | from drm_copilot_discovery.analyzer.models import Analysis
   |                                                   ^^^^^^^^
12 | from drm_copilot_discovery.analyzer.pipeline import run_inventory
13 | from drm_copilot_discovery.extension_inputs import extension_input_digest
   |
help: Remove unused import: `drm_copilot_discovery.analyzer.models.Analysis`

F401 [*] `drm_copilot_discovery.extension_results.ValidatedExtension` imported but unused
  --> tests\discovery_runtime\test_extension_inventory_merge.py:16:5
   |
14 | from drm_copilot_discovery.extension_results import (
15 |     ExtensionResultError,
16 |     ValidatedExtension,
   |     ^^^^^^^^^^^^^^^^^^
17 |     merge_extension_inventory,
18 |     validate_extension_results,
   |
help: Remove unused import: `drm_copilot_discovery.extension_results.ValidatedExtension`

E501 Line too long (89 > 88)
  --> tests\discovery_runtime\test_extension_inventory_merge.py:58:89
   |
56 |     bundle: DiscoverySnapshot,
57 | ) -> None:
58 |     """Preserve core identity/accounting and external uncertainty with no publication."""
   |                                                                                         ^
59 |     core = run_inventory(
60 |         capture_snapshot(bundle),
   |

E501 Line too long (95 > 88)
  --> tests\discovery_runtime\test_extension_inventory_merge.py:71:89
   |
69 |     assert merged.document["files"] == core.document["files"]
70 |     assert merged.document["exclusions"] == core.document["exclusions"]
71 |     # Built-in rows and diagnostics remain present without replacement or confidence promotion.
   |                                                                                         ^^^^^^^
72 |     for family in ("components", "findings", "relationships", "diagnostics"):
73 |         assert set(object_rows(core.document, family)) <= set(
   |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:99:89
    |
 97 |     bundle: DiscoverySnapshot,
 98 | ) -> None:
 99 |     """Explicit no-extension merge is byte-identical to the accepted built-in pipeline."""
    |                                                                                         ^^
100 |     core = run_inventory(
101 |         capture_snapshot(bundle),
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:118:89
    |
116 |     bundle: DiscoverySnapshot, manifest_only: bool
117 | ) -> None:
118 |     """Accept valid incomplete analysis, retain blockers and emit no false completion."""
    |                                                                                         ^
119 |     manifest, member = documents(bundle)
120 |     problem = diagnostic(
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:126:89
    |
124 |         analyzer="local-example",
125 |     )
126 |     # A manifest-only failure is valid transport; member failures retain exact file links.
    |                                                                                         ^^
127 |     if manifest_only:
128 |         manifest["result_files"] = []
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:180:89
    |
178 |     bundle: DiscoverySnapshot,
179 | ) -> None:
180 |     """A missing documentation Git blob remains a core blocker after source-valid merge."""
    |                                                                                         ^^^
181 |     # Documentation still participates in input digest and full file accounting.
182 |     changed = replace(
    |

E501 Line too long (94 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:226:89
    |
224 |     bundle: DiscoverySnapshot, monkeypatch: pytest.MonkeyPatch
225 | ) -> None:
226 |     """Replacing public validation with forged proof cannot bypass internal reconstruction."""
    |                                                                                         ^^^^^^
227 |     import drm_copilot_discovery.extension_results as module
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:253:89
    |
251 |     bundle: DiscoverySnapshot,
252 | ) -> None:
253 |     """A failed workspace capture cannot be reinterpreted as incomplete adapter success."""
    |                                                                                         ^^^
254 |     changed = replace(
255 |         bundle,
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:282:89
    |
280 |     bundle: DiscoverySnapshot, field: str, value: object
281 | ) -> None:
282 |     """Reject malformed descriptive fields independently of authoritative revalidation."""
    |                                                                                         ^^
283 |     carrier = validate_extension_results(bundle)[0]
284 |     with pytest.raises(ExtensionResultError, match="EXTENSION_CARRIER"):
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:325:89
    |
323 | )
324 | def test_independent_traversal_record_and_numeric_limits(mode: str) -> None:
325 |     """Bound each work unit independently; a failure never returns a partial projection."""
    |                                                                                         ^^^
326 |     reservation = ExtensionBudget(
327 |         max_bytes=100,
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:332:89
    |
330 |         max_depth=1 if mode == "depth" else 10,
331 |     )
332 |     # Each branch exercises one distinct prospective boundary with a small fixed payload.
    |                                                                                         ^
333 |     value: JsonValue = ("child",) if mode in {"depth", "node"} else "value"
334 |     records = (
    |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_extension_inventory_merge.py:350:89
    |
348 |     bundle: DiscoverySnapshot,
349 | ) -> None:
350 |     """Two individually bounded retained documents cannot exceed the shared raw-byte cap."""
    |                                                                                         ^^^^
351 |     context = ExtensionValidation(bundle)
352 |     manifest, member = bundle.file(MANIFEST), bundle.file(MEMBER)
    |

E501 Line too long (89 > 88)
  --> tests\discovery_runtime\test_extension_results.py:46:89
   |
45 | def extension_snapshot(catalog: SchemaCatalog) -> DiscoverySnapshot:
46 |     """Return an isolated complete bundle over pinned source/docs; no I/O or mutation."""
   |                                                                                         ^
47 |     profile = inventory_profile(
48 |         catalog,
   |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_extension_results.py:191:89
    |
189 | @pytest.fixture(scope="module")
190 | def bundle(analyzer_catalog: SchemaCatalog) -> DiscoverySnapshot:
191 |     """Provide immutable source/member bytes shared read-only; return an isolated bundle."""
    |                                                                                         ^^^^
192 |     return extension_snapshot(analyzer_catalog)
    |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_extension_results.py:240:89
    |
238 |     document: dict[str, object], path: tuple[str | int, ...], value: object
239 | ) -> None:
240 |     """Assign one detached test leaf; return None, mutating only the provided dictionary."""
    |                                                                                         ^^^^
241 |     cursor: object = document
242 |     # Explicit paths keep parameterized negative cases readable without executable expressions.
    |

E501 Line too long (95 > 88)
   --> tests\discovery_runtime\test_extension_results.py:242:89
    |
240 |     """Assign one detached test leaf; return None, mutating only the provided dictionary."""
241 |     cursor: object = document
242 |     # Explicit paths keep parameterized negative cases readable without executable expressions.
    |                                                                                         ^^^^^^^
243 |     for part in path[:-1]:
244 |         cursor = (
    |

E501 Line too long (95 > 88)
   --> tests\discovery_runtime\test_extension_results.py:259:89
    |
257 |     bundle: DiscoverySnapshot,
258 | ) -> None:
259 |     """Return descriptive carriers with exact bytes and original inference; no side effects."""
    |                                                                                         ^^^^^^^
260 |     first = validate_extension_results(bundle)
261 |     assert first == validate_extension_results(bundle, manifest_paths=(MANIFEST,))
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_extension_results.py:329:89
    |
327 |     code: str,
328 | ) -> None:
329 |     """Rebind transport around one invalid claim and require the exact fixed category."""
    |                                                                                         ^
330 |     manifest, member = documents(bundle)
331 |     # Schema/integrity cases intentionally target different layers of the same transport.
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_extension_results.py:331:89
    |
329 |     """Rebind transport around one invalid claim and require the exact fixed category."""
330 |     manifest, member = documents(bundle)
331 |     # Schema/integrity cases intentionally target different layers of the same transport.
    |                                                                                         ^
332 |     set_field(manifest if target == "manifest" else member, path, value)
333 |     changed = edit_bundle(bundle, manifest, member)
    |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_extension_results.py:345:89
    |
343 |     bundle: DiscoverySnapshot, selection: object
344 | ) -> None:
345 |     """Reject malformed/duplicate/undeclared selections without granting arbitrary reads."""
    |                                                                                         ^^^^
346 |     with pytest.raises(ExtensionResultError, match="EXTENSION_SELECTION"):
347 |         validate_extension_results(
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_extension_results.py:396:89
    |
394 |         changed, code = edit_bundle(changed, manifest, member), "EXTENSION_SOURCE"
395 |     else:
396 |         # Faults alter only the member stream/category; other captured bytes remain exact.
    |                                                                                         ^^
397 |         files = tuple(file for file in bundle.manifest.files if file.path != MEMBER)
398 |         if fault == "category":
    |

E501 Line too long (94 > 88)
   --> tests\discovery_runtime\test_extension_results.py:412:89
    |
411 | def test_line_ranges_share_cached_physical_bounds(bundle: DiscoverySnapshot) -> None:
412 |     """Accept repeated exact first-line anchors over retained CRLF bytes without rewriting."""
    |                                                                                         ^^^^^^
413 |     manifest, member = documents(bundle)
414 |     # All three row families share one independently hashed physical source.
    |

Found 42 errors.
[*] 4 fixable with the `--fix` option (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
