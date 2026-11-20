# P1-T3 shared profile and scope schema handoff

Timestamp: 2026-10-18T05-09
Command: poetry run python SCRATCH/issue-980-p1t3-task-audit.py
EXIT_CODE: 0
Output Summary: Exact 15 staged task paths; 359 focused tests and 176 reversed-order tests passed; resource boundaries retain 100% line/branch coverage; all ten resource bytes/digests match; no frozen v1 changes.

## Scope and design

Approved P1-T3 only. Added common, domain-profile and scope Draft 2020-12 schemas, two synthetic YAML examples, two invalid fixtures and focused tests. The shared schema defines strict IDs, full Git pins, SHA-256 digests, typed local/immutable foreign references, separate status axes, behavior dimensions and namespaced JSON extensions. Core objects are closed. The profile represents all requested roots, repository roles, multiple clients, explicit platform/mode/dimension requirements, runtime capability, bounded analyzer/parse settings, exclusions, output roots, approval owners and literal completion gates. Root-only configuration and semantic enforcement remain later plan tasks.

Draft profiles/scopes permit honest null pins. Configured profiles require full pins and production roots; configured target/combined profiles require clients. Confirmed scopes require a full pin and confirmation metadata. Empty confirmed scopes need an explicit no-scope rationale and cannot declare required feature coverage. Optional offline/mobile requirements are not injected. Profile/client requirement declarations are preserved for the P1-T10 union parser; schema conformance alone does not claim graph completion or valid host authority.

The test split into test_v2_common_schemas.py and v2_schema_test_support.py was approved inside the component because Black predicted 576 lines for a combined module. Shared test support only loads immutable schema/fixture inputs and constructs a typed offline validator. It performs no writes, external processes, network requests, or temp-file creation. Runtime resources use the existing P1-T2 builder and explicit allowlist; examples are not production templates or packaged consumer catalogs.

## Exact task-owned paths

- `examples/discovery/v2/domain-profile.example.yaml`
- `examples/discovery/v2/scope.example.yaml`
- `packages/discovery-runtime/resource-manifest.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/common.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/domain-profile.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/scope.schema.json`
- `schemas/discovery/v2/common.schema.json`
- `schemas/discovery/v2/domain-profile.schema.json`
- `schemas/discovery/v2/scope.schema.json`
- `tests/fixtures/discovery_schemas/v2/domain-profile.invalid.yaml`
- `tests/fixtures/discovery_schemas/v2/scope.invalid.yaml`
- `tests/schemas/discovery/test_v2_common_schemas.py`
- `tests/schemas/discovery/test_v2_profile_schemas.py`
- `tests/schemas/discovery/v2_schema_test_support.py`

Eleven files are authored/configured; four are generated (three canonical byte copies and the updated resource manifest). Frozen v1 canonical/generated schemas and existing v1 assertions remain unchanged. P1-T1/P1-T2 production implementation and dependency declarations are unchanged. All task files are at most 388 physical lines.

## Verification and corrections

Final ordered pass records under evidence/regression-testing/:

| Step | Result | Record |
| --- | --- | --- |
| Black check | Exit 0; three unchanged files | p1t3-format-pass3.2026-10-18T05-06.md |
| Ruff | Exit 0; zero findings | p1t3-lint-pass3.2026-10-18T05-06.md |
| Full Pyright | Exit 0; zero errors/warnings | p1t3-types-pass3.2026-10-18T05-07.md |
| Focused Pytest | Exit 0; 359 passed, no failures/skips | p1t3-tests-pass3.2026-10-18T05-07.md |
| Reversed new modules | Exit 0; 176 passed | p1t3-reversed-schema-modules.2026-10-18T05-08.md |
| Resource check | Exit 0; no changed paths, ten-schema closure | p1t3-stage-check.2026-10-18T05-08.md |
| ECMAScript regex proof | Exit 0; nine patterns compile, 40 terminator cases rejected | p1t3-regex-portability.2026-10-18T05-08.md |

The schema suite includes 176 new parameterized cases; the focused total also covers unchanged v1 schema/fixture and resource staging/loading tests. Resources.py retains 103/103 lines and 34/34 branches; build_discovery_runtime.py retains 209/209 lines and 98/98 branches. The total is 312/312 lines and 132/132 branches, with zero coverage delta from P1-T2. This task adds zero executable production lines, so its new-code coverage denominator is zero, not a claimed percentage. The Phase 0 full-repository baseline remains the reference for later final QA; this is an atomic task handoff, not full-feature completion.

The verifier found that a terminal regex dollar anchor admits a final newline. Shared lexical and namespace/property-name patterns now require the actual end of the string using an ECMAScript-compatible negative lookahead. Tests cover LF, CR, CRLF, U+2028 and U+2029, both through Draft202012Validator and Node v24.14.0. The resource manifest was regenerated after this correction. Initial Ruff found one annotation-only import; Pyright found two diagnostics in the library's unknown overload. A narrow test-only validator Protocol preserves typed errors without suppressions or explicit Any. Corrective gates restarted from Black. Failed gate records remain available. One patch-context mismatch made zero changes before a corrected patch was applied.

Manifest SHA-256: `85d41cc8162d3d9f567bca002341df72936889ceeea08a9ec0c1e258f478bbb4`. Raw numerical coverage: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t3-coverage.2026-10-18T05-09.json`. Exact tracked paths, counts and resource proof: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t3-coverage-metrics.2026-10-18T05-09.json`. No dependency, lock, policy, checkpoint, plan checkbox or consuming repository changed. No wheel rebuild is claimed in this schema-only task; P1-T2 established the installed-resource boundary and P10-T3 verifies the final resource package.

## Sequential handoff

TASK_READY_FOR_VERIFICATION applies only to P1-T3. The executor owns verification/checkoff and the coordinator owns staging/checkpoints. P1-T4 remains unreleased. Catalog dispatch, typed profile unions, resolved path safety and completion/claim graph gates remain in their approved later tasks; passing schema examples do not imply those gates are implemented.
