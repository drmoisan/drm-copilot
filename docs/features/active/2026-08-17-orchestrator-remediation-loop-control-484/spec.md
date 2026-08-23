# 2026-08-17-orchestrator-remediation-loop-control (Spec)

- **Issue:** #484
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-17T07-06
- **Status:** Ready for Planning
- **Version:** 0.1

## Context
The orchestration state machine treats every non-PASS review as actionable remediation, including external runtime incompatibilities and unavailable coverage metrics. This causes unnecessary remediation plans, commits, re-reviews, inconsistent cycle numbering, and cycle consumption when no corrective candidate was applied.

Environment:
- OS/version: Windows 11 / PowerShell workspace
- Python version: 3.13.12 through Poetry
- Node/npm version: Node 24.14.0 / npm 11.9.0
- Command/flags used: Codex `orchestrate` workflow with authoritative MCP orchestration validation
- Data source or fixture: issue #467 checkpoint, review artifacts, published `@danmoisan/drm-copilot-mcp@1.0.24`, and repository-local validators

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run a feature review that returns a blocker which cannot be changed by repository remediation, such as an immutable MCP runtime mismatch or unavailable source-attributable coverage metric.
2. Observe that the reviewer can return only `PASS` or `REMEDIATION_REQUIRED` and that the orchestrator unconditionally enters R1-R5 for `REMEDIATION_REQUIRED`.
3. Let remediation execution return an external/runtime failure with no candidate applied and the checkpoint restored byte-for-byte.
4. Observe that the outer workflow still stages evidence, commits, re-reviews, increments the pass counter, and consumes a remediation cycle.
5. Compare repository-local and published MCP routing inventories when a new Codex agent family was added after the package version was published.

Expected:
The reviewer classifies whether a blocking condition is autonomously remediable. External runtime mismatches, policy decisions, awaiting-CI states, and human-decision requirements halt or wait without creating a remediation plan or consuming a remediation cycle. Cycle accounting counts completed remediation attempts consistently, and runtime capability/version incompatibility is detected before execution.

Actual:
The binary review contract forced every blocker into remediation. The pass counter alternated between current and completed semantics, an unexecuted pass occupied a number, and pass 7 was consumed after `PRE_R5_STATUS: ACTIVE_RUNTIME_INCOMPATIBILITY` with `candidate_applied: false`. The published MCP 1.0.24 validator rejected valid repository `commit-steward` routing receipts, while an unrelated legacy routing gate also generated missing-receipt diagnostics.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: issue #467 records seven audit rounds, six completed remediation re-reviews, eight execution/resume delegations, one unexecuted numbered pass, and no pass 8. The final candidate passed the repository validator but could not change the immutable published MCP resolver.


## Scope & Non-Goals
- In scope: Repository orchestration, validation, distribution, and release contracts required to make remediation-loop behavior deterministic.
  - Separate the review delivery verdict from autonomous remediation actionability across canonical orchestration instructions, generated agent profiles, review outputs, checkpoint state, and Python, TypeScript, and MCP validators.
  - Replace ambiguous pass numbering with a canonical, versioned `remediation_loop` object that records execution attempts separately from completed remediation cycles and validates counts, identifiers, ordering, and transitions.
  - Add pre-R4 terminal handling for `NO_CANDIDATE`, `EXTERNAL_RUNTIME`, `AWAITING_CI`, and `HUMAN_DECISION` outcomes so they do not stage, commit, re-audit, or consume a completed remediation cycle.
  - Detect unchanged blocker fingerprints after a completed remediation cycle and stop for stagnation instead of generating another equivalent plan.
  - Bind any approved one-time exception to one issue, blocker fingerprint, routing-policy digest, allowed transition, and attempt; reject reuse or wildcard bindings.
  - Separate the legacy model-routing gate from Codex topology and Codex model-routing gates, expose PR-creation readiness through the TypeScript/MCP surface, and emit each selected-gate diagnostic once.
  - Add an MCP runtime compatibility preflight covering validator contract version, supported validation flags, package version, bundle identity, and routing-policy digest before remediation execution.
  - Keep canonical, generated, mirrored, built, and published orchestration/MCP surfaces synchronized, including correction of retired `artifacts/research/` references.
  - Add Python, TypeScript, MCP, contract, integration, generated-surface, bundle-parity, and release-boundary regression coverage.
- Out of scope / non-goals: Unrelated route/model policy and application behavior remain unchanged.
  - Changing route selection, model selection, review finding severity, the three-cycle safety limit, or the underlying implementation engineer toolchains except where required to consume the new contracts.
  - Automatically resolving external runtime availability, CI results, policy decisions, or human approvals.
  - Reconstructing historical cycle records when existing artifacts do not prove whether a candidate was applied, committed, and re-audited.
  - Publishing an MCP package, changing an installed package pin, creating a release tag, or calling an external registry as part of this issue's implementation branch.
- Explicitly excluded systems, integrations, or datasets: Application-domain code and third-party service internals are excluded.
  - Application-domain source code outside repository automation, customization generation, validation, and release tooling.
  - Third-party CI providers and package registries other than treating their reported state as an external input.
  - Checkpoints for epic or parallel orchestration except shared validator utilities that are directly affected and covered by non-regression tests.

## Root Cause Analysis
- Review output combines delivery verdict and remediation action into one binary field.
- The remediation loop lacks a terminal pre-R4 transition when no delta is applied.
- Canonical `remediation_loop.cycles[]` accounting is optional and bypassed by ad hoc fields.
- The legacy `require_model_routing` gate is incorrectly applied to Codex-native checkpoints.
- Published MCP bundle capability is not compared with repository routing policy before remediation.
- Codex receipt validation runs twice under strict mode, duplicating diagnostics.


## Proposed Fix

### Design summary (what changes where):

Introduce a versioned review and remediation contract. Reviewers emit `REVIEW_VERDICT: PASS|BLOCKED` independently from `REMEDIATION_ACTION: NONE|AUTONOMOUS|NO_CANDIDATE|EXTERNAL_RUNTIME|AWAITING_CI|HUMAN_DECISION`, plus `BLOCKER_FINGERPRINT: NONE|sha256:<64-lowercase-hex>`. `PASS` is valid only with `NONE`; `BLOCKED` with `AUTONOMOUS` requires both remediation artifact paths; every other blocked action requires both remediation artifact paths to be `NONE`.

Persist `remediation_loop.schema_version: 2`, attempts, and completed cycles in `artifacts/orchestration/orchestrator-state.json`. An attempt begins only when R3 execution is delegated after clear preflight. A completed cycle exists only after an attempt applies a candidate, the candidate is committed, and R4 re-audit completes. Preflight revision iterations do not create attempts. An attempt with no applied candidate remains auditable but never creates or consumes a cycle.

Use the following transition contract:

| Current result | Required transition | Attempt effect | Completed-cycle effect |
|---|---|---:|---:|
| `PASS` + `NONE` | Validate PR-creation readiness and leave remediation | none | none |
| `BLOCKED` + `AUTONOMOUS` | Enter R1 using the returned inputs and plan | none until R3 | none until R4 completes |
| `BLOCKED` + `NO_CANDIDATE` | Stop as `blocked_no_candidate` before R1 | none | none |
| `BLOCKED` + `EXTERNAL_RUNTIME` | Stop as `blocked_external_runtime` before R1 | none | none |
| `BLOCKED` + `AWAITING_CI` | Persist `awaiting_ci` and wait for external state change | none | none |
| `BLOCKED` + `HUMAN_DECISION` | Persist `blocked_human_decision` and stop | none | none |
| R3 result with `candidate_applied: false` and a terminal disposition | Record the attempt, stop before staging/commit/R4, and preserve the last review | increment | none |
| R3 result with `candidate_applied: true` and `execution_status: complete` | Stage, commit, and run R4 re-audit | increment | none until re-audit completes |
| R4 `PASS` | Append the completed cycle with `exit_condition_met: true`; continue to PR readiness | unchanged | increment |
| R4 `BLOCKED` with changed fingerprint and `AUTONOMOUS` | Append the completed cycle; return to R1 when below the limit | unchanged | increment |
| R4 `BLOCKED` with unchanged fingerprint | Append the completed cycle and stop as `blocked_stagnation` | unchanged | increment |
| R4 `BLOCKED` after three completed cycles | Stop as `blocked_remediation_loop_limit` | unchanged | remains three |

Before R1, compare the active MCP runtime's declared validator capabilities with repository requirements. Missing capabilities, an unsupported contract/schema version, a package/bundle identity mismatch, or a routing-policy digest mismatch produces `EXTERNAL_RUNTIME` and prevents plan creation or cycle consumption.

### Boundaries and invariants to preserve:

- `remediation_loop.attempt_count` equals `attempts.length`; `completed_cycle_count` equals `cycles.length`; `remediation-pass`, while retained for compatibility, equals `completed_cycle_count` and never denotes an in-progress attempt.
- `attempt_id` and `cycle_id` are one-based, unique, gap-free, strictly increasing integers in array order. Each cycle references exactly one earlier attempt, and an attempt can be referenced by at most one cycle.
- A cycle's referenced attempt must have `preflight.final_status: clear`, `execution_status: complete`, and `candidate_applied: true`. Attempts with `candidate_applied: false` must use a non-candidate terminal disposition and must not have a commit or cycle reference.
- A cycle is appended only after a non-empty commit SHA and re-audit artifact path exist. `exit_condition_met: true` requires `review_verdict: PASS`, `remediation_action: NONE`, and `blocking_count: 0`.
- The maximum is three completed cycles. Preflight revisions, CI polling, resume delegations, and terminal attempts with no candidate do not consume this limit.
- The blocker fingerprint is SHA-256 over UTF-8 canonical JSON containing sorted blocking findings with stable `audit_kind`, `rule_id`, normalized workspace-relative `path`, and normalized `message` fields. Timestamps, generated artifact names, and ordering are excluded. The stored form is `sha256:<64-lowercase-hex>`.
- If `blocker_fingerprint_after` equals `blocker_fingerprint_before` after a completed cycle, the loop stops as stagnated. No new remediation plan, attempt, or cycle may be created without a materially different review fingerprint or an exactly bound exception.
- Evidence remains under `<FEATURE>/evidence/<kind>/`; research remains under the tracked feature-local `research/` folder or `docs/research/`. `artifacts/research/` is not reintroduced.
- Legacy Claude `model_routing_receipts` validation and Codex `codex_model_routing_receipts`/`codex_topology_receipts` validation remain independent opt-in gates.
- `require_pr_creation_ready` remains independent of `require_complete`. PR readiness excludes `pr_gate`, `ci_gate`, and `pr-author` receipt requirements; completion continues to require route-appropriate final PR/CI and phase-completeness gates.
- Existing safety requirements for preflight clearance, automated QA, acceptance-criteria tracking, exact-head CI, and no silent model fallback remain unchanged.

### Dependencies or blocked work:

- Repository-local implementation and validation are not blocked by the incomplete narrative portion of the research artifact; its material findings identify the current contracts and affected module families.
- Published MCP packages are immutable external runtimes. Source changes must be merged, built, tested, and published before any consumer pin can reference the new version.
- Runtime compatibility depends on the MCP server exposing the capability object defined below. An older runtime that cannot expose it is incompatible for strict remediation and must produce the external-runtime terminal disposition rather than an automated remediation attempt.
- Generated and mirrored customization resources must be regenerated from canonical inputs before package build and parity validation.

### Implementation strategy (what changes, not sequencing):

Normalize review output into the two-axis contract, validate the matrix, and route non-actionable results directly to terminal/wait states. Replace ad hoc pass tracking with schema-versioned attempt/cycle records and central transition validation shared semantically by Python and TypeScript. Add a capability handshake and digest comparison at the MCP boundary, then update customization generation, package build inputs, and release checks so every distributed surface carries the same contract.
	
#### Files/modules to change:

- Canonical orchestration/review policy: `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.github/agents/orchestrator.agent.md`, and the feature-review output contract surfaces that emit the review result.
- Python validation/CLI: `scripts/dev_tools/validate_orchestrator_state.py`, `scripts/dev_tools/validate_orchestration_artifacts.py`, and the dedicated legacy/Codex routing validator modules they compose.
- TypeScript validation: `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`, `orchestrator-state-core.ts`, `orchestration-artifacts.ts`, completion/routing modules, and their option types.
- MCP transport and service adapters: `extensions/drm-copilot/src/mcp-server.ts`, MCP tool input/definition handlers, repository automation service calls, and the `validate_orchestration_artifacts` request/response contract.
- Canonical and mirrored routing/package inputs: `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json`, `packages/mcp-server/esbuild-mcp-server.cjs`, `packages/mcp-server/prepack.cjs`, and package manifests when a publishable version is prepared.
- Canonical/generated/mirrored customization surfaces: `.agents/skills/**`, `.codex/agents/**`, applicable `.github/agents/**` and `.github/prompts/**`, Claude mirrors, and `extensions/drm-copilot/resources/codex-and-agents-customizations/**`.
- Research-location corrections: `.agents/skills/research-issue/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, generated `task-researcher*.toml` and `orchestrator*.toml` profiles, and their packaged mirrors.
- Tests: `tests/scripts/dev_tools/**`, `extensions/drm-copilot/test/lib/validate/**`, MCP handler/service/contract tests, customization push-down tests, package-build smoke tests, and release workflow contract tests.

#### Functions/classes/CLI commands impacted:

- Python `validate_orchestrator_state_text`, `_validate_remediation_loop`, `_validate_remediation_cycle`, and the `orchestrator-state` branch of `validate_orchestration_artifacts.py`.
- TypeScript `validateOrchestratorStateText`, `validateRemediationLoop`, and orchestration-artifact dispatch/options.
- MCP `validate_orchestration_artifacts` input schema, handler, service-call builder, and initialize capability response.
- CLI flags `--require-pr-creation-ready`, `--require-complete`, `--require-model-routing`, `--require-codex-model-routing`, and `--require-codex-topology`; MCP uses the corresponding snake-case input properties.
- Reviewer terminal output parsing and the orchestrator R1-R5/pre-R4 transition logic across canonical and generated profiles.
- Customization generation/push-down and MCP `prepack`/bundle build commands used by release workflows.

#### Data flow and validation changes:

1. The reviewer emits verdict, action, fingerprint, audit paths, and action-dependent remediation paths.
2. The orchestrator validates the output matrix and, for `AUTONOMOUS`, performs the runtime capability/version/policy-digest preflight before accepting a plan.
3. R1/R2 operate on one plan path; preflight revisions do not affect attempt or cycle counts.
4. R3 creates the next attempt record. The executor result sets `execution_status`, `candidate_applied`, and `terminal_disposition`.
5. The pre-R4 gate validates candidate state. A false candidate terminates or waits without staging, commit, R4, or cycle creation. A true completed candidate proceeds to commit and R4.
6. R4 computes the post-review fingerprint and appends one completed cycle linked to the attempt.
7. R5 evaluates PASS, stagnation, terminal action, changed actionable blockers, and the three-cycle limit in that order.
8. Python, TypeScript, and MCP validators return the same ordered diagnostic codes and messages for the same JSON fixture. Each selected routing gate executes once.

Structural validation must reject non-object loops, non-array attempt/cycle collections, unknown schema versions, invalid enums, missing fields, non-contiguous identifiers, mismatched counts, duplicate attempt references, impossible transitions, reused exceptions, malformed fingerprints, and completion/PR-readiness gate leakage.

#### Error handling and logging updates:

- Prefix deterministic errors with stable codes: `ORCH_REMEDIATION_SCHEMA`, `ORCH_REMEDIATION_SEQUENCE`, `ORCH_REMEDIATION_COUNT`, `ORCH_REMEDIATION_TRANSITION`, `ORCH_REMEDIATION_STAGNATION`, `ORCH_EXCEPTION_BINDING_INVALID`, `ORCH_EXCEPTION_BINDING_REUSED`, `ORCH_ROUTING_GATE_LEGACY`, `ORCH_ROUTING_GATE_CODEX_MODEL`, `ORCH_ROUTING_GATE_CODEX_TOPOLOGY`, `ORCH_VALIDATOR_CAPABILITY_MISSING`, `ORCH_VALIDATOR_VERSION_INCOMPATIBLE`, and `ORCH_ROUTING_POLICY_DIGEST_MISMATCH`.
- De-duplicate diagnostics by `(gate, phase-or-record-id, error-code, subject)` while retaining deterministic first-occurrence order. Do not collapse distinct gate failures.
- Log one transition record containing issue number, attempt/cycle identifiers, prior and next loop status, verdict, action, candidate state, blocker fingerprints, and diagnostic code. Do not log secrets or full exception payloads.
- Capability failures state expected and actual contract version, package version, supported flag set, and routing digest when available, then stop before remediation mutation.
- Invalid or incomplete state fails closed; validators do not infer candidate application, cycle completion, exception use, or external release state.

#### Rollback/feature-flag considerations (if applicable):

The safety contract is schema-versioned rather than feature-flagged. Writers emit schema version 2 and dual-write the deprecated `remediation-pass` alias during the compatibility window. Plain validation continues to accept legacy checkpoints that have never entered remediation; strict resume, PR-readiness, and completion validation require an evidence-backed migration before mutating a legacy remediation loop. Rollback may stop new version-2 writes, but must not rewrite or discard existing attempts/cycles. A published package rollback must select a previously published version whose declared routing digest matches the repository policy used by that consumer.

### Technical specifications (interfaces/contracts):

Canonical review output fields are:

```text
REVIEW_VERDICT: PASS | BLOCKED
REMEDIATION_ACTION: NONE | AUTONOMOUS | NO_CANDIDATE | EXTERNAL_RUNTIME | AWAITING_CI | HUMAN_DECISION
BLOCKER_FINGERPRINT: NONE | sha256:<64-lowercase-hex>
REMEDIATION_INPUTS: <feature-local-path> | NONE
REMEDIATION_PLAN: <feature-local-path> | NONE
```

The canonical checkpoint object is:

```json
{
  "remediation_loop": {
    "schema_version": 2,
    "status": "idle|active|awaiting_ci|blocked_no_candidate|blocked_external_runtime|blocked_human_decision|blocked_stagnation|blocked_remediation_loop_limit|resolved",
    "max_completed_cycles": 3,
    "attempt_count": 0,
    "completed_cycle_count": 0,
    "last_blocker_fingerprint": null,
    "attempts": [],
    "cycles": []
  }
}
```

The status enum and transition table use the exact executable value `blocked_remediation_loop_limit` for the unresolved third-completed-cycle stop. `blocked_cycle_limit` is rejected legacy input only; updated writers and transition logic MUST NOT emit or execute it.

Each attempt contains `attempt_id`, `source_review_fingerprint`, `plan_path`, `preflight.final_status` (`pending|revisions_required|clear`), `execution_status` (`not_started|in_progress|complete|failed|awaiting_ci|blocked`), `candidate_applied` (boolean), `terminal_disposition` (`candidate_applied|no_candidate|external_runtime|awaiting_ci|human_decision|execution_failed`), `started_at`, `finished_at`, and `exception_binding` (object or null). Each completed cycle contains `cycle_id`, `attempt_id`, `commit_sha`, `re_audit_path`, `review_verdict`, `remediation_action`, `blocker_fingerprint_before`, `blocker_fingerprint_after`, `blocking_count`, `exit_condition_met`, and `completed_at`.

An exception binding contains exactly `exception_id`, `issue_number`, `blocker_fingerprint`, `routing_policy_sha256`, `allowed_transition`, `single_use: true`, `consumed_at`, and `consumed_by_attempt_id`. The issue, fingerprint, digest, and transition must match the active state. `consumed_at` and `consumed_by_attempt_id` are both null before use and both non-null after one use. Reuse, partial binding, wildcard values, or binding to another issue/attempt is invalid.

#### Inputs/outputs and formats:

- Python CLI input remains UTF-8 checkpoint JSON. `--require-pr-creation-ready` is available only for `orchestrator-state` and may be combined with routing gates; `--require-complete` remains the final lifecycle gate. If both readiness and completion are requested, validators return the deterministic union without suppressing either class of error.
- MCP `validate_orchestration_artifacts` accepts optional booleans `require_pr_creation_ready`, `require_complete`, `require_model_routing`, `require_codex_model_routing`, `require_codex_topology`, and existing artifact-specific flags. Omitted values default to `false`; unknown properties remain rejected.
- MCP initialize output adds `capabilities.experimental["drm-copilot/validator"]` with `validator_contract_version`, `remediation_loop_schema_versions`, `supported_artifact_types`, `supported_validation_flags`, `routing_policy_sha256`, `package_version`, and `bundle_sha256`.
- `serverInfo.version`, capability `package_version`, and the packaged manifest version must agree. `routing_policy_sha256` is SHA-256 of the canonical UTF-8 bytes distributed in the bundle. `bundle_sha256` identifies the executable bundle validated by package smoke tests.
- Validator output remains a deterministic ordered list of error strings plus the existing success/failure envelope. Python, source TypeScript, built MCP, and packed MCP return identical codes and substantive messages for shared fixtures.

#### Required configuration keys and defaults:

- `remediation_loop.schema_version` is `2` for all new writes.
- `remediation_loop.max_completed_cycles` defaults to and may not exceed `3` without a separately approved policy change.
- `attempt_count` and `completed_cycle_count` default to `0`; `attempts` and `cycles` default to empty arrays; `last_blocker_fingerprint` defaults to null.
- Validator contract version and supported remediation schema versions are build-time constants carried into source, built, mirrored, and packaged MCP surfaces.
- The expected routing-policy digest is derived from `config/orchestration-routing.json`; it is not hand-authored independently in generated files.
- Routing flags remain opt-in and default to `false`. Orchestrator strict calls explicitly select Codex gates for Codex checkpoints and the legacy gate only for legacy checkpoints.

#### Backward-compatibility expectations:

- A checkpoint without `remediation_loop` remains valid under non-strict validation when no remediation evidence exists. Once remediation starts, version-2 state is mandatory.
- Legacy review output maps `REVIEW_STATUS: PASS` to `PASS/NONE`. `REVIEW_STATUS: REMEDIATION_REQUIRED` maps to `BLOCKED/AUTONOMOUS` only when both remediation artifact paths are present; it cannot represent a non-actionable result and must not be emitted by updated writers.
- Legacy loop objects remain readable under non-strict validation using their existing three invariants. Strict resume, PR-readiness, or completion rejects ambiguous legacy state with `ORCH_REMEDIATION_SCHEMA` until evidence-backed migration is completed.
- The deprecated top-level `remediation-pass` remains readable and is dual-written as `completed_cycle_count`; a mismatch is an error. New code never uses it to allocate an attempt or cycle identifier.
- Existing callers that omit `require_pr_creation_ready` retain current behavior. Adding the optional MCP property is backward compatible for updated servers; an older server is detected by capability preflight before use.
- Legacy and Codex routing receipt schemas are not converted into one another. Each gate reads only its own receipt family and diagnostic namespace.

#### Performance constraints (latency/throughput/memory):

- Validation remains linear in checkpoint records and review findings: `O(attempts + cycles + receipts + findings)` time and `O(findings)` transient memory for fingerprint canonicalization.
- Each review computes a blocker fingerprint once; each strict orchestration transition performs at most one capability comparison and one invocation per selected routing gate.
- On repository fixtures, Python and TypeScript validator p95 duration must not regress by more than 10% from the Phase 0 baseline, excluding process startup and package-build time.
- Capability and digest checks use local handshake/package data and local files; no registry or network lookup occurs during ordinary validation.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): Review findings expose stable rule identifiers and workspace-relative paths; the orchestrator can persist checkpoint changes atomically; package smoke tests can launch the locally packed MCP server; canonical routing policy is available at build and validation time.
- Constraints (budget, performance, compatibility): The change is a large cross-cutting Python/TypeScript effort; generated surfaces must not be edited without synchronizing their canonical source; validators must maintain exact cross-runtime semantics and deterministic diagnostics; test code may not use temporary files; evidence must use canonical feature-local locations; repository line coverage must remain at least 80%, new modules/classes/methods must reach at least 90%, and changed lines must not lose coverage.
- External dependencies (services, libraries, releases): Node/npm and Poetry toolchains; the MCP protocol initialize handshake; GitHub Actions for exact-head CI and tagged package publication; the npm registry only at the release verification boundary. No new third-party runtime library is required.

## Data / API / Config Impact
- User-facing or API changes: Review handoffs gain verdict/action/fingerprint fields; MCP validation gains `require_pr_creation_ready`; initialize capabilities expose validator compatibility metadata; validation failures gain stable diagnostic codes.
- Data or migration considerations: `orchestrator-state.json` gains schema-versioned remediation attempts/cycles. Migration is evidence-backed and non-destructive; ambiguous historical passes are preserved as legacy state and fail strict mutation rather than being guessed. No database migration is required.
- Logging/telemetry updates (if any): Structured transition logs record terminal reason, count changes, fingerprints, selected gates, and capability mismatch details. CI and package smoke artifacts record source/bundle/package versions and digests. Sensitive values and full exception documents are excluded.
- Compatibility notes (CLI flags, config schemas, versioning): Optional flags default false; schema version 2 is mandatory for new remediation; dual-read/dual-write support is limited to the documented compatibility window; MCP package version changes only when a publishable artifact is prepared and is never pinned before publication.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas
  - Review outcome/actionability matrix and remediation artifact requirements
  - Canonical remediation-cycle schema, transitions, count arithmetic, and blocker fingerprints
  - Pre-R4 no-candidate/runtime-incompatibility halt behavior
  - Legacy-versus-Codex routing gate separation and unique diagnostics
  - Human exception binding and one-time consumption
- [x] Integration scenario to retest
  - Python, TypeScript, and MCP validator parity on shared checkpoint fixtures
  - Source routing catalog versus built MCP bundle capability digest
  - Full orchestrator flow where an external blocker produces no remediation plan or cycle consumption
- [x] Manual verification notes
  - Publishing and pinning a new MCP package must occur only after the package is built, tested, and published; the branch must not pin an unpublished version.

- Regression tests to add or update: Add the following named unit, contract, integration, parity, generation, and release-boundary cases.
  - `tests/scripts/dev_tools/test_validate_orchestrator_state.py`: `test_non_actionable_review_does_not_create_cycle`, `test_no_candidate_attempt_does_not_complete_cycle`, `test_completed_cycle_counts_and_sequences_are_canonical`, `test_unchanged_fingerprint_stops_for_stagnation`, `test_exception_binding_is_single_use`, and legacy migration/alias cases.
  - `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`: independent PR-readiness/completion flags and unique legacy/Codex routing diagnostics.
  - `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation.test.ts`: the same schema, transition, count, fingerprint, and exception fixture matrix as Python.
  - TypeScript core completion, legacy model-routing, Codex model-routing, Codex topology, and orchestration-artifact tests: gate separation, one invocation per selected gate, `commit-steward` receipt acceptance, and PR-readiness parity.
  - MCP schema/handler/service tests: optional readiness input, capability object, missing/unsupported capabilities, version mismatch, routing digest mismatch, and deterministic terminal result.
  - Integration and package tests: shared checkpoint fixtures produce Python/source-TypeScript/built-MCP/packed-MCP parity; local JSON-RPC initialize and validation smoke verifies version/digest/bundle identity.
  - Customization tests: canonical/generated/mirrored files match and no active profile references `artifacts/research/`.
  - Release contract tests: only `mcp-server-v*` tags publish; build, tests, pack smoke, and registry publication precede any consumer pin update.
- Unit tests (pytest) for the fixed behavior and boundaries: Cover every enum value, zero/one/three-cycle boundaries, preflight retries, attempt/cycle ID gaps and duplicates, count mismatches, false-candidate terminal attempts, changed versus unchanged fingerprints, exact exception binding and reuse, legacy reads, strict migration rejection, and independent routing/readiness/completion gates.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): Non-object loops, non-array lists, unknown schema/enums, malformed hashes, absent timestamps, missing commit/re-audit evidence, cycle referencing a false-candidate attempt, more than three cycles, duplicate diagnostics, capability flag omission, package/digest disagreement, stale generated files, awaiting-CI resume without state change, and an unpublished target pin.
- Error handling and logging verification: Assert exact error codes, stable ordering, one diagnostic per gate/subject, no staging or commit invocation on pre-R4 terminal paths, no secret-bearing payloads, and unchanged checkpoint cycle count on capability failure.
- Coverage impact and targets for changed lines/modules: Preserve repository line coverage at or above 80%; reach at least 90% for every new module/class/method; cover all changed transition branches; and record baseline, post-change, and changed-code values in feature-local evidence with no negative changed-line delta.
- Toolchain commands to run (format → lint → type-check → test): Run the repository-defined Python Black → Ruff → Pyright → Pytest-with-coverage loop, then TypeScript Prettier → ESLint → TSC → Vitest-with-coverage loop. Restart each loop from formatting after a failure or file change. Run MCP build, pack, local initialize/validation smoke, contract/parity suites, customization generation checks, and release-workflow tests after language loops. If a PowerShell release script changes, also run the repository PoshQC format → analyze → Pester loop.
- Manual validation steps (if required): None. Runtime mismatch, CI waiting, human-decision, package publication, and pin eligibility are explicit machine-validated states. Publication itself remains a separately authorized tagged release action.


## Acceptance Criteria
- [ ] Updated reviewers emit `REVIEW_VERDICT`, `REMEDIATION_ACTION`, and `BLOCKER_FINGERPRINT`, and contract tests accept only the documented verdict/action/path matrix.
- [ ] A `PASS/NONE` review advances to PR-creation readiness with both remediation paths set to `NONE` and without creating an attempt or cycle.
- [ ] A `BLOCKED/AUTONOMOUS` review requires non-empty feature-local remediation inputs and plan paths before R1 begins.
- [ ] `BLOCKED/NO_CANDIDATE`, `BLOCKED/EXTERNAL_RUNTIME`, `BLOCKED/AWAITING_CI`, and `BLOCKED/HUMAN_DECISION` each enter their documented terminal/wait state without plan creation, R3 execution, or cycle consumption.
- [ ] An R3 result with `candidate_applied: false` records exactly one attempt and performs no `git add`, commit-context collection, commit, R4 review, or completed-cycle increment.
- [ ] New remediation state writes `remediation_loop.schema_version: 2` with all documented fields and rejects missing, unknown, or malformed values with `ORCH_REMEDIATION_SCHEMA`.
- [ ] `attempt_count == attempts.length`, attempt identifiers are one-based/gap-free/ordered, and preflight revision iterations do not change the attempt count.
- [ ] `completed_cycle_count == cycles.length`, cycle identifiers are one-based/gap-free/ordered, and every cycle uniquely references an eligible candidate-applied attempt.
- [ ] The compatibility field `remediation-pass` equals `completed_cycle_count`; validators reject any mismatch and never use it as the current attempt number.
- [ ] Validators reject execution before clear preflight, a false-candidate attempt with a cycle, a cycle without commit/re-audit evidence, and an exit condition with nonzero blockers.
- [ ] Three unresolved completed cycles produce only `blocked_remediation_loop_limit`; non-candidate attempts, preflight retries, CI polls, and resume delegations consume zero completed cycles, and `blocked_cycle_limit` is rejected legacy input rather than an executable transition.
- [ ] Python and TypeScript implementations compute the documented canonical blocker fingerprint identically for shared fixtures regardless of finding order or volatile timestamps.
- [ ] An unchanged post-cycle blocker fingerprint produces `blocked_stagnation` and prevents another automated remediation plan, attempt, or cycle.
- [ ] A one-time exception is accepted only when issue number, blocker fingerprint, routing-policy digest, allowed transition, and consuming attempt all match; reuse and wildcard/partial bindings are rejected.
- [ ] `require_model_routing` reads only legacy receipts, while `require_codex_model_routing` and `require_codex_topology` read only their Codex receipt families.
- [ ] A strict validator invokes each selected routing gate once, emits each gate/subject diagnostic once, and accepts valid Codex `commit-steward` routing receipts without requiring legacy receipts.
- [ ] TypeScript and MCP expose `require_pr_creation_ready` with the same default and errors as Python, and this gate does not require `pr_gate`, `ci_gate`, or a `pr-author` receipt.
- [ ] `require_complete` continues to enforce route-appropriate final PR/CI, phase completeness, preparation terminal state, and routing contracts independently of PR readiness.
- [ ] MCP initialize capabilities report validator contract version, supported remediation schema versions, supported flags/artifacts, routing-policy SHA-256, package version, and bundle SHA-256.
- [ ] Missing capabilities, unsupported contract/schema versions, package identity mismatch, or routing digest mismatch produces `EXTERNAL_RUNTIME` before R1/R3 and leaves attempt/cycle counts unchanged.
- [ ] Positive release-boundary parity covers the source Python and TypeScript implementations, generated configuration/customization mirrors, the locally built executing MCP bundle, and the locally packed candidate, which report identical routing-policy content/digest and validator capabilities; immutable published `@danmoisan/drm-copilot-mcp@1.0.24` is used only as a negative `EXTERNAL_RUNTIME` compatibility fixture and is never a positive parity target.
- [ ] All canonical, generated, Claude/Codex, extension-resource, and packaged customization surfaces carry the updated review/remediation contract and pass synchronization checks.
- [ ] Retired `artifacts/research/` references are removed from canonical skills, generated `task-researcher*`/`orchestrator*` profiles, and packaged mirrors; contract tests accept only feature-local `research/` or `docs/research/` destinations.
- [ ] Python tests in `test_validate_orchestrator_state.py` and `test_validate_orchestration_artifacts.py` cover the named positive, terminal, transition, count, stagnation, exception, compatibility, routing, and readiness cases and pass.
- [ ] TypeScript remediation, core, completion, routing, topology, orchestration-artifact, MCP handler, and service tests cover the equivalent matrix and pass with diagnostics matching Python fixtures.
- [ ] MCP source, built bundle, and locally packed-package JSON-RPC smoke tests return identical capability and validation results without network access.
- [ ] Integration and contract tests prove non-actionable blockers do not create remediation plans or cycles, candidate-applied blockers complete exactly one cycle, and unchanged blockers stop for stagnation.
- [ ] Repository coverage remains at least 80%, every new module/class/method reaches at least 90%, changed transition branches are covered, and baseline/post-change/changed-code evidence records no regression.
- [ ] Python and TypeScript format → lint → type-check → coverage-test loops pass in one clean pass, followed by MCP build/pack, parity, customization, and release-contract tests.
- [ ] Validator performance on repository fixtures remains within 10% of the Phase 0 p95 baseline, or an approved evidence-backed waiver is recorded before review.
- [ ] Legacy checkpoints without remediation remain readable, ambiguous legacy remediation state fails strict mutation with a migration diagnostic, and updated writers never emit legacy-only review output.
- [ ] Release workflow tests enforce `SOURCE_READY -> BUILT -> TESTED -> PUBLISHED -> PINNED` ordering and restrict publication to the authorized `mcp-server-v*` tag workflow.
- [ ] No repository manifest, lockfile, runtime configuration, generated surface, or orchestration checkpoint pins an MCP package version until registry evidence confirms that exact version is published.
- [ ] Documentation, validator help/schema text, generated profiles, and release instructions describe the same field names, enums, transition order, diagnostics, research paths, and PR-readiness/completion boundary.

## Risks & Mitigations
- Technical or operational risks: The principal risks are cross-runtime drift, ambiguous legacy state, unstable fingerprints, stale bundle metadata, duplicate gates, and premature package pins.
  - Python, TypeScript, and packaged MCP implementations could drift and accept different state.
  - Legacy checkpoints may not contain enough evidence for lossless attempt/cycle migration.
  - Volatile review text could cause false fingerprint changes or false stagnation.
  - Capability metadata could describe source policy while the executable bundle contains different resources.
  - Overlapping readiness/completion or routing gates could duplicate diagnostics or block a valid Codex checkpoint.
  - A package pin could land before the corresponding immutable package is available.
- Mitigations and rollbacks: Use shared fixtures, fail-closed migration, stable fingerprint inputs, bundle smoke checks, independent gate tests, and published-version-only rollback targets.
  - Use shared JSON fixtures, exact diagnostic contract tests, generated-surface checks, and source/built/packed smoke parity.
  - Fail strict mutation for ambiguous legacy state and preserve the original checkpoint; never synthesize historical cycles.
  - Fingerprint stable normalized finding fields and exclude timestamps/artifact-order noise.
  - Compute digests during build, verify them from the launched packed bundle, and compare server/package versions.
  - Keep gates independent, test invocation counts, and de-duplicate only identical gate/subject/code results.
  - Separate source, build, test, publish, and pin states; rollback consumers only to an already published digest-compatible version.

## Rollout & Follow-up
- Release/rollout steps: Advance through source validation, generated-surface synchronization, local package verification, merge, publication, and a separate consumer-pin update.
  1. Implement and validate canonical Python/TypeScript contracts and shared fixtures without changing a package pin.
  2. Regenerate and verify Claude, Codex, extension-resource, and MCP package mirrors from canonical sources.
  3. Build and locally pack the MCP server; launch the packed artifact and verify initialize capabilities, routing digest, bundle identity, and validator parity.
  4. Merge source only after repository QA, feature review, PR-readiness, exact-head CI, and completion gates pass.
  5. In the separately authorized release workflow, tag only after build/test/pack evidence exists; publish and verify the exact registry version.
  6. Update consumer pins only in a subsequent change after publication evidence exists, then rerun runtime compatibility and orchestration validation.
- Post-fix monitoring or clean-up tasks: Track terminal dispositions, stagnation stops, cycle-limit stops, capability mismatches, and duplicate-diagnostic counts in structured CI/orchestration logs; remove the deprecated `REVIEW_STATUS`/`remediation-pass` compatibility path only in a separately planned breaking release after active checkpoints have migrated.
- Links: issue #484; `docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/issue.md`; `docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/research/2026-08-17T07-25-orchestrator-remediation-loop-control-research.md`; related issue #467 checkpoint evidence.
