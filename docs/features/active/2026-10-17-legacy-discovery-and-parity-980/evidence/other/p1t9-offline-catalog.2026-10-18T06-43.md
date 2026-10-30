# P1-T9 offline catalog handoff

Timestamp: 2026-10-18T06-43
Command: poetry run python SCRATCH/issue-980-p1t9-task-audit.py
EXIT_CODE: 0
Output Summary: Nine exact staged paths; 1882 focused tests and 223 changed-test cases in reversed module order passed; 346/346 production lines and 144/144 branch arcs covered; all callable/class ranges have 100% line coverage.

## Scope and compatibility disposition

Approved P1-T9 changed only:

- packages/discovery-runtime/src/drm_copilot_discovery/catalog.py
- packages/discovery-runtime/src/drm_copilot_discovery/schema_validation.py
- scripts/dev_tools/validate_discovery_schema_artifacts.py
- tests/discovery_runtime/test_catalog.py
- tests/discovery_runtime/test_schema_formats.py
- tests/discovery_runtime/test_schema_validation.py
- tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py
- tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py
- tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py

The two runtime modules are new. The existing adapter now delegates to the authoritative runtime. Its seven public text functions retain their names and cache_dir keyword, default explicitly to frozen 1.0.0, and accept a trusted schema_version keyword for 2.0.0. cache_dir is unused and never written. The retained load_schema export permits only registered offline aliases. Arbitrary artifact-selected schemas and remote/cache retrieval are deliberately rejected as the approved security correction.

The caller supplies expected_kind and exact expected_version. Artifact metadata cannot choose or weaken validation. Successful v1 runtime results explicitly expose compatibility_only=true; neither v1 nor structural v2 success grants completion or approval authority. The activation four-key envelope and service-result result_version envelope retain their intentional header exceptions.

Set B dispositions: the two schema-wrapper test modules now use actual valid v1 examples and required-field failures instead of permissive artifact-selected schema mocks. Dispatch tests retain wrapper/error behavior and use actual feature contracts for the two schema-dependent CLI cases. Existing profile and all-type probing assertions remain unchanged for their named later tasks. Frozen v1 schemas/examples/invalid fixtures and test_v1_schema_documents.py/test_v1_fixtures.py are byte-identical to HEAD (23 tracked paths).

## Delivered boundary

The catalog contains seven frozen v1 schemas and 26 v2 documents, including shared definitions. Only the three existing v1 spellings per kind and exact v2 URNs are registered; shared common definitions cannot validate an artifact. Every installed resource is manifest/hash checked. Required jsonschema/referencing imports, schema dialect/metaschema, identity, complete local reference closure and required formats fail closed without a reduced fallback or network retrieval.

Configured extension inputs carry a namespaced identifier, workspace-relative diagnostic path, immutable bytes and exact SHA-256. Extensions use Draft 2020-12, assigned content-bound resource IDs and local fragment references only. They cannot substitute core documents. Unsupported declared formats fail explicitly. Runtime registry construction strengthens the common extensions schema, so constraints apply at every schema-defined embedded position, including records and environments. Arbitrary JSON values inside domain payloads are not treated as new core extension locations. Non-consuming recursive evaluation produces an actionable blocking finding; finite recursive payloads remain supported.

The instance-local format checker implements the established RFC 3339 calendar/offset/leap-second contract and the RFC 3986/RFC 9110 HTTP(S) evidence-URI contract using the standard library. Required checker availability is asserted. Known leap-second insertions end at 2016-12-31; future announced insertions require a code/data update. The URI checker is intentionally scoped to HTTP(S) evidence references, not every URI scheme. No dependency was added.

All 33 resource bytes and both manifests already satisfy the task's catalog requirement, so no artificial manifest edit was made. The existing builder's stage-only/check mode verifies complete closure and runtime dependency packaging.

## Verification

Phase 0 remains 7,336 tests passed, six existing skips, zero failures; repository baseline line coverage 94.111715% and branch coverage 88.783742%. Full repository QA remains assigned to the final feature phase.

The clean ordered pass is pass 5: Black unchanged for nine files; Ruff zero findings; full Pyright zero errors/warnings; focused Pytest 1882 passed with no failures. The run includes every runtime and discovery-schema test plus the three changed adapter/dispatch consumers. Reversed changed-test module order passes 223 cases. The branch-coverage run took 212.58 seconds, primarily repeated real catalog construction and schema checks.

| Production file | Covered lines | Covered branch arcs | Baseline line percent |
| --- | --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/catalog.py | 167/167 | 82/82 | new |
| packages/discovery-runtime/src/drm_copilot_discovery/schema_validation.py | 146/146 | 60/60 | new |
| scripts/dev_tools/validate_discovery_schema_artifacts.py | 33/33 | 2/2 | 100.0 |

There is no coverage regression in the existing adapter. Every new/touched callable/class range reaches 100%. Tracked tier classification passes 26/26 projects. The exact staged diff is whitespace-clean, 144 prior task paths retain their accepted hashes, and the maximum owned file is 382 physical lines.

Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t9-coverage.2026-10-18T06-43.json
Numerical scope/coverage/AST-unit evidence: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t9-coverage-metrics.2026-10-18T06-43.json

Command records:
- p1t9-black-pass1.2026-10-18T06-35.md
- p1t9-black-pass2.2026-10-18T06-35.md
- p1t9-black-pass3.2026-10-18T06-36.md
- p1t9-black-pass4.2026-10-18T06-36.md
- p1t9-black-pass5.2026-10-18T06-37.md
- p1t9-pyright-pass4.2026-10-18T06-36.md
- p1t9-pyright-pass5.2026-10-18T06-37.md
- p1t9-resource-closure.2026-10-18T06-41.md
- p1t9-ruff-corrections.2026-10-18T06-36.md
- p1t9-ruff-pass2.2026-10-18T06-35.md
- p1t9-ruff-pass3.2026-10-18T06-36.md
- p1t9-ruff-pass4.2026-10-18T06-36.md
- p1t9-ruff-pass5.2026-10-18T06-37.md
- p1t9-tests-pass5.2026-10-18T06-41.md
- p1t9-tests-reversed.2026-10-18T06-43.md
- p1t9-tracked-tiers.2026-10-18T06-42.md

## Corrections and retained failures

The executor's consolidated review found three extension defects: an unregistered date format was silently accepted; a self-reference raised RecursionError; and embedded decision extensions were not validated. All three were corrected within the catalog/validation component and have direct regressions. The executor independently confirmed the corrected behavior before the clean test pass. Its operational reproducer is SCRATCH/issue-980-probe-p1t9-review.py; final independent acceptance remains executor-owned.

Initial Black formatted nine files. Restarted Ruff found I001, F401 and eight E501 diagnostics; two automatic fixes and line-length corrections resolved them. A subsequent pass retained one E501 and then cleared it. Full Pyright initially found reportUnnecessaryIsInstance for the defensive bytes guard and reportUnusedFunction for the retained metadata helper; an object-typed guard and actual compatibility lookup use resolved both without suppressions or new dependencies. All failed command records remain in canonical evidence.

A structured apply_patch attempt was rejected before mutation: 'apply_patch verification failed: invalid patch: multiple operations target .../scripts/dev_tools/validate_discovery_schema_artifacts.py'. It attempted Delete/Add of the same adapter path. A single Update patch completed the authorized replacement; this was a tool patch-shape rejection, not a hook bypass. No files were mutated by the rejected call.

No plan, acceptance-criteria or orchestration checkpoint edits were made by this worker. No P1-T10 production work has begun. Profile loading, filesystem authorization, graph claims and later CLI integration remain in their approved subsequent tasks.
