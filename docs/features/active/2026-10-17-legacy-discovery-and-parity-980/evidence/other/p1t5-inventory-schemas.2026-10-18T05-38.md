# P1-T5 coverage, inventory and transport schema handoff

Timestamp: 2026-10-18T05-38
Command: poetry run python SCRATCH/issue-980-p1t5-task-audit.py
EXIT_CODE: 0
Output Summary: Exact 20 staged task paths; 805 focused tests and 186 reversed-order tests passed; 17 packaged resources match canonical bytes and hashes; unchanged production resource coverage remains 100% lines/branches.

## Scope and contract

Approved P1-T5 only: four strict Draft 2020-12 v2 schemas, four synthetic valid examples, four invalid fixtures, two focused test modules, explicit resource allowlist and generated resource bytes. Every schema requires the exact kind/version/URN, stable identity and closed core; extensions retain the established namespaced boundary.

The coverage ledger separates inspection from disposition and preserves path/symbol/span/hash, feature/test links, runtime requirement, exclusion/supporting/blocking rationale, scope linkage, responsible workflow/agent and update evidence. An empty ledger may retain a null revision only without components or inventory references. Populated ledgers require a full pin and typed snapshot links. Detection can seed uninspected/unassigned rows without pretending inspection occurred. Inspected and nonblocking disposition claims need evidence; exclusions link a scope record and rationale. Test relevance is detected/inferred data, never an execution result or line-coverage claim.

Inventory snapshots retain tool/analyzer versions, pinned source and scan configuration digest, inspected/excluded/unreadable input records, exact inspected-byte hashes/sizes, components, findings, relationships, diagnostics, exclusions and capture metadata. Detection and inference are independent from confidence. Unreadable/excluded files retain null hashes instead of invented bytes; unreadable inputs link diagnostics. Partial snapshots are structurally valid and do not establish completion. Source references retain optional symbols and inclusive spans. Unresolved target bindings remain null with descriptive text. Generic declaration properties are scalar records; structured domain data stays in namespaced extensions.

Source snapshot manifests identify a full source pin, exact v2 artifact kinds/versions, exported paths, SHA-256 values and sizes, evidence payloads, tool version, manifest digest and local-file transport metadata. Pending and recorded verified transport states are separate; recorded verification requires a timestamp and actor. Byte/digest verification is recomputed by later transport operations, never trusted from authored flags. V1 schema compatibility readers remain unchanged and cannot become v2 source completion transport.

External adapter manifests are data-only: adapter identity/version, pinned repository, input/result byte manifests, digest, capture metadata and diagnostics. Result files can contain only core inventory snapshots. Missing results require a blocking diagnostic rather than an empty success. Unknown execution/module/approval fields fail closed. The later import service validates referenced inventory content, exact bytes and full input accounting; no Python module path or command is executed from this record.

## Exact task-owned paths

- examples/discovery/v2/coverage-ledger.example.yaml
- examples/discovery/v2/extension-result-manifest.example.yaml
- examples/discovery/v2/inventory-snapshot.example.yaml
- examples/discovery/v2/source-snapshot-manifest.example.yaml
- packages/discovery-runtime/resource-manifest.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/coverage-ledger.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/extension-result-manifest.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/inventory-snapshot.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/source-snapshot-manifest.schema.json
- schemas/discovery/v2/coverage-ledger.schema.json
- schemas/discovery/v2/extension-result-manifest.schema.json
- schemas/discovery/v2/inventory-snapshot.schema.json
- schemas/discovery/v2/source-snapshot-manifest.schema.json
- tests/fixtures/discovery_schemas/v2/coverage-ledger.invalid.yaml
- tests/fixtures/discovery_schemas/v2/extension-result-manifest.invalid.yaml
- tests/fixtures/discovery_schemas/v2/inventory-snapshot.invalid.yaml
- tests/fixtures/discovery_schemas/v2/source-snapshot-manifest.invalid.yaml
- tests/schemas/discovery/test_v2_inventory_schemas.py
- tests/schemas/discovery/test_v2_transport_schemas.py

Fifteen authored/configured paths and five generated paths are staged with current bytes. The same-component split into test_v2_inventory_schemas.py and test_v2_transport_schemas.py keeps every file below 500 lines; maximum physical count is 366. Existing schema test support is unchanged. Tests use immutable local fixtures and fresh in-memory mutations, without temp files, subprocesses, network or mutable global setup.

The bounded audit verifies 66 prior-task paths retain their recorded hashes, including prior canonical/generated schemas, test helper, Python implementation, dependency declarations and lockfile. Only the existing resource allowlist/generated manifest change as this task's integration. Frozen v1 schemas, fixtures and assertions remain unchanged.

## Completed checks

| Step | Actual result | Evidence in regression-testing |
| --- | --- | --- |
| Black check | Exit 0; two unchanged files | p1t5-format-pass1.2026-10-18T05-36.md |
| Ruff | Exit 0; zero findings | p1t5-lint-pass1.2026-10-18T05-36.md |
| Full Pyright | Exit 0; zero errors/warnings | p1t5-types-pass1.2026-10-18T05-37.md |
| Focused Pytest | Exit 0; 805 passed | p1t5-tests-pass1.2026-10-18T05-37.md |
| Reversed new modules | Exit 0; 186 passed | p1t5-reversed-schema-modules.2026-10-18T05-37.md |
| Read-only resource check | Exit 0; 17 exact resources, no changes | p1t5-stage-check.2026-10-18T05-37.md |

No gate failure or test weakening occurred. Initial Black formatting was followed by one clean ordered pass. The 186 new cases cover exact kinds/versions, valid and invalid fixture repair, draft/populated ledgers, required fields, source pins/hashes/spans, inspection/disposition separation, runtime rationale, typed test references, partial inputs/diagnostics, detected/inferred records, source and adapter transport, supported digests/versions, pending/verified metadata and forbidden caller execution fields.

Resources.py remains 103/103 executable lines and 34/34 branch arcs. The resource builder remains 209/209 lines and 98/98 arcs. Aggregate: 312/312 lines and 132/132 arcs; coverage delta is zero. This task adds or changes zero executable production lines, so no new-code percentage is claimed. Final full-repository gates remain assigned to the plan's final QA phase.

Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t5-coverage.2026-10-18T05-38.json
Exact scope, prior-byte verification and coverage metrics: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t5-coverage-metrics.2026-10-18T05-38.json
Resource manifest SHA-256: 0ae4aa0f0a5b293f217f1cab881bcae84a232481f21eb420a2a2123f5941e602

## Sequential handoff and remaining semantic obligations

TASK_READY_FOR_VERIFICATION applies only to P1-T5. The executor owns independent verification and checkoff; the coordinator owns staging/checkpoints. P1-T6 is not released.

Schema validation establishes shape, not graph completeness. Later tasks must compare keyed identity uniqueness, sorted paths, span ordering, source hashes at pins, manifest digest/content, source-to-component accounting, analyzer identity and relationship targets, declared diagnostic severity versus required inputs, exclusion-scope coverage, transport counts and referenced file bytes. They must recompute all completion/verification claims. No policy, plan/AC checkbox, checkpoint, consumer repository, dependency, production validator or analyzer implementation changed in this task.
