# P1-T7 control envelope schema handoff

Timestamp: 2026-10-18T06-09
Command: poetry run python SCRATCH/issue-980-p1t7-task-audit.py
EXIT_CODE: 0
Output Summary: Exact 23 staged paths; 1,368 focused and 294 reversed-order tests passed; 33 resources match canonical bytes; unchanged resource code retains 100% line/branch coverage.

## Delivered contract and exact scope

Approved P1-T7 only: nine closed Draft 2020-12 control schemas, fresh in-memory valid/invalid test data, two schema-test modules and a scoped fixture helper, explicit resource allowlist and generated resources. Existing assertions and common schema bytes are unchanged.

Activation uses exactly schema_version, enabled, profile_path and required_runtime_major. Service-result uses exactly the ten specified result_version wire fields. These specifically enumerated envelopes do not receive the general artifact header; the remaining seven schemas retain exact schema_version, artifact_kind and catalog identity.

Service requests expose the canonical closed operation and mode sets, bounded workspace-relative inputs and opaque invocation/authorization references. Caller-selected principals, roles, executables, command strings and receipt destinations are rejected. Explicit draft init accepts omitted or empty production_roots; other init requires nonempty roots. Responses preserve exit-code consistency, actionable findings, projected artifacts, input manifests, runtime/schema/build/policy bindings and separate validation outcomes.

Invocations bind trusted host/session/agent context, exact analyst role, deployment and routing identities, scope/input hashes, expected outputs and state transitions. Output manifests specify artifact identity, path, format and existing-content hash without granting authority. Capability attestations distinguish supported hosts with all three native events, seven required controls and a denied sentinel from honestly unsupported capability. Tool authorization describes exact request/tool/operation/invocation bindings and issued, consumed or revoked state.

Validation receipts use the approved closed principal union. Native-root identity requires host/session/agent/request and explicit null analyst fields; root receipts cannot satisfy analyst-stop mode. Discovery-agent identity requires one of four exact roles and invocation/output binding; analyst receipts cannot satisfy planning. Local-user CLI identity and missing or ambiguous principal kinds are rejected. A structurally valid reviewer output can report validation failure without claiming a passing gate. Passing completion source/target references require immutable pins.

Migration reports retain source/destination mappings, old/new hashes, unresolved references and unmapped data, and forbid implicit activation switching. Dry-run mappings cannot claim created files. No schema-valid document constitutes protected-store authority, runtime permission or a verified artifact.

- packages/discovery-runtime/resource-manifest.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/activation.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/capability-attestation.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/discovery-invocation.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/migration-report.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/required-output-manifest.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/service-request.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/service-result.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/tool-authorization.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/validation-receipt.schema.json
- schemas/discovery/v2/activation.schema.json
- schemas/discovery/v2/capability-attestation.schema.json
- schemas/discovery/v2/discovery-invocation.schema.json
- schemas/discovery/v2/migration-report.schema.json
- schemas/discovery/v2/required-output-manifest.schema.json
- schemas/discovery/v2/service-request.schema.json
- schemas/discovery/v2/service-result.schema.json
- schemas/discovery/v2/tool-authorization.schema.json
- schemas/discovery/v2/validation-receipt.schema.json
- tests/schemas/discovery/test_v2_authority_schemas.py
- tests/schemas/discovery/test_v2_control_schemas.py
- tests/schemas/discovery/v2_control_test_support.py

Thirteen authored/configured paths and ten generated paths are staged with current bytes. Maximum physical length is 430; every task file meets the 500-line limit. All 115 prior-task paths outside the allowlist/manifest overlap retain recorded hashes. Frozen v1 schema/fixture/assertion bytes, existing helpers, dependencies and production implementation are unchanged. Unit tests use fresh in-memory values and immutable repository resources, without temporary files, subprocesses or network calls.

## Verification evidence

| Step | Result | Evidence under regression-testing |
| --- | --- | --- |
| Black, pass 3 | Exit 0; three unchanged files | p1t7-format-pass3.2026-10-18T06-08.md |
| Ruff, pass 3 | Exit 0; zero findings | p1t7-lint-pass3.2026-10-18T06-08.md |
| Full Pyright, pass 3 | Exit 0; zero diagnostics | p1t7-types-pass3.2026-10-18T06-08.md |
| Focused Pytest, pass 3 | Exit 0; 1,368 passed | p1t7-tests-pass3.2026-10-18T06-09.md |
| Reversed new test modules | Exit 0; 294 passed | p1t7-tests-reversed.2026-10-18T06-07.md |
| Read-only resource check | Exit 0; 33 exact resources | p1t7-stage-check-final.2026-10-18T06-09.md |

The retained initial Ruff pass reported one S105 hardcoded-password-name diagnostic for the synthetic TOKEN constant. Renaming it OPAQUE_REFERENCE removed the diagnostic without a suppression or assertion change. The whole ordered sequence restarted at Black and passed. The first log contains terminal OSC hyperlink output around the rule identifier; this note preserves the actionable rule and correction. No Pytest failure occurred.

The first final audit, p1t7-task-audit.2026-10-18T06-08.md, failed staged whitespace checking because eight new canonical schemas and their generated copies contained a blank line at EOF. Only those terminal blank lines were removed, resources regenerated, and the complete ordered pass 3 repeated successfully. Reversed tests from before this byte-only normalization remain applicable; schema semantics and test bytes did not change. The final audit retains zero staged whitespace findings and verifies current resource hashes.

resources.py: 103/103 executable lines, 34/34 branch arcs. Resource builder: 209/209 lines, 98/98 arcs. Aggregate 312/312 lines and 132/132 arcs; zero coverage regression. This schema/test task introduces zero executable production lines, so a new-code production percentage is not applicable. Final repository-wide QA remains assigned to the final phase.

Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t7-coverage.2026-10-18T06-09.json
Exact scope/line-count/prior-byte metrics: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t7-coverage-metrics.2026-10-18T06-09.json
Resource manifest SHA-256: c286991d90a71c5e043eee1417839672bb007b6887cc3a10811826a14d3e6ccf

## Operational incident attribution

The P1-T2 build-prerequisite command used an unquoted poetry-core>=1.9.0 argument. PowerShell interpreted the greater-than character as redirection, so the actual recorded installation argv was pip install poetry-core and its recorder stdout created workspace-root file 1.9.0. Existing evidence is ../regression-testing/p1t2-build-prerequisite.2026-10-18T04-45.md. Installed poetry-core 2.5.0 satisfies the unchanged >=1.9.0 build constraint.

After attribution, the coordinator preserved the 730-byte stdout artifact at SCRATCH/issue-980-p1t2-build-prerequisite-stdout.log, SHA-256 16c6ee5d1a1398a95db9ccb41e9728b7e63fd36a7dd4c3592745fceda029b1f7, and recorded the action in the checkpoint. No production dependency or lockfile changed and no successful build gate was repeated. Version constraints must be shell-quoted or passed as literal argv. All P1-T7 operational Python helpers are files under SCRATCH.

## Sequential boundary and remaining runtime obligations

TASK_READY_FOR_VERIFICATION applies only to P1-T7. Executor owns independent verification/checkoff; coordinator owns staging/checkpoints. P1-T8 is not released.

Later runtime tasks must verify protected-store provenance, actual native start/tool/stop attribution, exact identity and request/input/output hashes, role/operation/path permissions, capability configuration freshness, expiry/clock ordering, atomic one-use authorization consumption and receipt reuse compatibility. Caller data cannot mint these authorities. Actual policy-version compatibility is evaluated against trusted routing policy, not inferred from document shape. Service semantic validation must additionally bind operation-specific inputs and outcomes. The installed catalog/format implementation remains P1-T9; schema tests do not substitute for it.

No policy, plan/AC checkbox, checkpoint, consumer repository, production validator, analyzer or dependency was modified by this task.
