---
name: orchestrate
description: Route a repository request through the deterministic orchestration workflow for feature, bug, research, planning, execution, and review handoffs.
---

# Orchestrate Skill

This skill frames root-session intake and deterministic deployment for end-to-end feature or bug delivery.

## Entry-Point Contract

The root session owns the read-only intake, production-file budget estimate, route selection,
and deployment decision. Work inside the applicable language budget remains a single-feature
small route, but implementation is delegated to the complexity-specific typed-engineer profile.
Over-budget, cross-cutting, mixed-language, or unsupported standalone work is deployed to the
complexity-specific `orchestrator-<profile>` agent, which owns checkpoint updates, lifecycle
sequencing, specialist delegation, and completion gating. Epic planning and execution use only
the forced `epic-planner` and `epic-orchestrator` personas through their root skills.

Agent profile selection is operational, not advisory. Do not execute a large standalone route in
the root thread and do not implement a small route in the coordinating thread.

## Prerequisites

Before proceeding, the orchestrator must:

1. Read `AGENTS.md` for repository tone policy and architectural context.
2. Read applicable `.agents/skills/` files for the languages in scope.
3. Read the policy files listed in the compliance reading order section of `AGENTS.md`.

## Checkpoint Handling

On every invocation, the main session must:

1. Read `artifacts/orchestration/orchestrator-state.json` to check for existing state.
2. If a valid checkpoint exists with a matching objective, resume from the recorded `next_step`.
3. If no checkpoint exists or the objective is new, begin the orchestration lifecycle from the start.
4. Read `config/orchestration-routing.json` before route selection and copy the
   selected route's required agents, skills, and MCP tools into checkpoint
   state.

## Epic Entry Boundary

This standalone workflow must not invoke `epic-planner` or `epic-orchestrator`. If intake names
an epic manifest, requests epic planning, or requires multi-feature epic execution, stop before
delegation and report exactly `EPIC_ENTRY_REQUIRES_ROOT`. Direct the user to root-session
`epic-plan`, `epic-run`, or `epic-orchestrate` as appropriate. Both epic personas delegate to
ordinary orchestrators; permitting an orchestrator-originated epic invocation would create an
invalid recursive delegation chain. The Codex root-provenance hooks enforce the stronger
root-only policy and use `EPIC_INVOCATION_ORIGIN_BLOCKED` for unauthorized starts.

## Axis 1 Deployment Topology

Apply the deterministic production-file axis before model selection:

- Inside the applicable language budget: use the small route and delegate implementation to
  `python-typed-engineer-<profile>`, `powershell-typed-engineer-<profile>`,
  or `csharp-typed-engineer-<profile>`. The typed-engineer delegation and result must have a
  receipt. TypeScript has no canonical direct-mode budget, so standalone TypeScript work fails
  closed to the large orchestrator topology.
- Outside the applicable budget, cross-cutting, mixed-language, or unsupported: deploy
  `orchestrator-<profile>` and let that agent run the large path.
- Epic planning: deploy the forced `epic-planner` Sol/Ultra persona.
- Prepared or manual epic execution: deploy the forced `epic-orchestrator` Sol/Ultra persona.

Only the production-file limit selects inside versus outside the language topology budget. The
test-file estimate remains in the receipt and governs typed-engineer batching; it does not change
the selected topology. The `<profile>` is produced by the independent C1-C4 resolver after the
topology is known. File count does not choose a model, and complexity does not change the
small/large result.
Persist the deterministic topology resolver output in `codex_topology_receipts[]` before running
the model resolver or spawning the selected logical agent.

## Preparation Mode

A parent prompt containing the literal marker `Preparation mode: true` selects only
`route_id: preparation`. This route is the planning phase of `epic-plan`, not a reduced execution
route.

- Copy the exact required agents, skills, and MCP tools from the central `preparation` route.
- Perform promotion through the MCP surface, research, `spec.md`, `user-story.md`, atomic
  planning, and atomic-executor preflight only.
- Iterate revisions against the same plan path until `PREFLIGHT: ALL CLEAR`.
- Commit the prepared feature folder and approved plan to the worktree branch.
- Stop with `completed_steps` containing `S3_promotion` and `S4_atomic_planning`,
  `next_step: "S5_atomic_execution"`, all execution-through-CI step statuses exactly
  `not-applicable`, and `blocked_reason: "none"`.
- Do not edit production code, execute the plan, author or edit a PR, run feature review, monitor
  CI, set `next_step: "complete"`, record `S12_complete`, or claim feature completion.

Only the literal JSON Boolean `false` in the route configuration disables the CI requirement.
Missing, malformed, string-valued, or unknown route data fails closed. The preparation mutation
hook is a deterrent; the MCP completion validator is authoritative.

## Codex Model Deployment

The deterministic size route selects topology. The independent C1-C4 assessment selects the
checked-in Codex deployment agent. Before every delegation:

1. Resolve and persist the topology receipt from languages, file counts, context, and route
   markers before selecting the logical agent.
2. Record the phase assessment, deterministic floor, signals, rationale, execution context, and
   monotonic orchestration complexity ceiling.
3. Resolve and persist the provider-aware model-routing receipt with logical and deployment agents,
   model, reasoning effort, and C3 overlay fields.
4. Spawn the exact deployment agent recorded in the receipts.
5. Require the `SubagentStart` model attestation to match the receipt before accepting mutation
   or completion.

C3 defaults to Terra/High when it is the standalone orchestration ceiling. It elevates to
Sol/High only for epic preparation/execution children or when a C4 sibling sets the ceiling to
C4. If the required model/profile is unavailable, record `model_unavailable` and stop without a
silent fallback.

## Read-Only Intake and Route Selection Gate

Before any lifecycle MCP call, the main session must complete a read-only scope
assessment. This gate is the read-only scope assessment for orchestration
intake. It includes policy reads, checkpoint reads, route config reads,
objective and scope assessment, language/file assessment, route selection, and
route metadata persistence.

The route-selection gate must be complete before calling any of:

- `new_potential_entry`
- `new_potential_bug_entry`
- `potential_to_issue`
- `new_active_feature_folder`

Until this gate is complete, the main session may read repository files and
checkpoint state, but must not create lifecycle entries, promote issues, create
active feature folders, edit implementation files, run formatters or tests,
stage files, commit files, or delegate implementation.

## Route-Derived Work Mode

The main session must derive `${work-mode}` from the selected route before
lifecycle automation starts:

- small route -> `minor-audit`
- large feature route -> `full-feature`
- large bug route -> `full-bug`

The selected `route_id`, exact route metadata, and derived `${work-mode}` must
be persisted in `artifacts/orchestration/orchestrator-state.json` before any
lifecycle MCP call or implementation action. Route metadata must include the
selected route's `required_agents`, `required_skills`, and
`required_mcp_tools` copied from `config/orchestration-routing.json`.

## Lifecycle Branch Sequencing

After route metadata is persisted and before potential entry creation, the main
session must create or verify a slug-only pre-issue branch:

- `${pre-issue-branch}`: `${promotion-type}/${short-name}`

The pre-issue branch must be derived only from `${promotion-type}` and
`${short-name}` because no numeric issue number exists yet. The main session
must create or verify this branch before calling `new_potential_entry` or
`new_potential_bug_entry`.

After potential entry creation, `potential_to_issue` must return a numeric
`${issue-num}` before the main session renames the branch to the final issue
branch:

- `${final-branch}`: `${promotion-type}/${short-name}-${issue-num}`

The branch rename to `${final-branch}` must complete before calling
`new_active_feature_folder`.

## Pre-Implementation Gate

The pre-implementation gate must pass before any edits, formatters, tests,
staging, commits, or implementation delegation. This gate covers edits, formatters, tests, staging, commits, and implementation delegation. The main session must verify and persist all of the following before implementation can begin:

- checkpoint route metadata is present and matches the selected route;
- selected `${work-mode}` is present and matches the selected route;
- lifecycle readiness is complete for the selected path;
- branch state records `${pre-issue-branch}`, `${final-branch}`, and branch
  rename status where lifecycle setup is required;
- required MCP receipts exist for completed lifecycle operations.

If any required item is missing, implementation is blocked until the checkpoint
and lifecycle state are corrected.

## Plan-Path Resolution Gate

After active feature folder creation and before any planning delegation, the
main session must resolve `${plan-path}` from the active feature folder:

1. Enumerate existing `${feature-folder}/plan*.md` files in deterministic
   filename order.
2. If one or more files exist, persist `${plan-path}` as the first existing
   file and require every planner and executor handoff to use that exact path.
3. If no `plan*.md` file exists, create exactly one canonical target path using
   the repository's feature-folder plan naming convention, persist that path,
   and reuse it for all revisions.
4. Do not default to `${feature-folder}/plan.md` when a timestamped scaffolded
   plan already exists.
5. If checkpoint state names a different plan path than the resolved existing
   plan file, correct the checkpoint before planner delegation. Do not create a
   second plan artifact to satisfy an incorrect checkpoint value.

## Pre-Implementation Violation Handling

If an implementation action is attempted before a required orchestration gate
passes, the main session must stop implementation and persist a blocked
checkpoint state. The required checkpoint outcome is blocked checkpoint state.
The checkpoint or companion artifact must record:

- violated gate name;
- attempted action;
- known mutated files, if any;
- corrective next step;
- current route metadata, lifecycle, branch, and MCP receipt state.

After a pre-implementation gate violation, the main session must not continue
implementation. It may only record the violation, restore or reconcile state
when policy permits, and resume from the corrective orchestration step.

## Hard Enforcement Boundary

The hard completion boundary for Codex orchestration is the deterministic
orchestrator-state validator exposed through the `drm-copilot` MCP server, not
a Codex lifecycle hook. Before any DONE transition, PR creation gate, or final
completion report, the orchestrator must validate the canonical checkpoint with
`validate_orchestration_artifacts` on the `drm-copilot` MCP server using
`artifact_type: "orchestrator-state"`,
`artifact_path: "artifacts/orchestration/orchestrator-state.json"`, and
`require_complete: true`.

There is no fallback. If the MCP server or validation tool is unavailable, or
if validation fails, the orchestrator must update blocked state and stop rather
than reporting completion.

No CI workflow performs this validation. The `artifacts/` directory is gitignored,
so the orchestrator-state checkpoint is never present in a CI checkout; a prior
CI gate (`validate-orchestrator-state.yml`) that attempted this check was a
structural no-op for that reason and has been removed. The MCP-server-based
validation described above is this ecosystem's enforcement mechanism for the
orchestrator-state checkpoint.

Completion validation requires the checkpoint to prove mandatory handoffs and
skill use. The checkpoint must include:

- `route_id`: the selected route key from `config/orchestration-routing.json`
- `required_agents`: exactly the selected route's `required_agents`
- `required_skills`: exactly the selected route's `required_skills`
- `required_mcp_tools`: exactly the selected route's `required_mcp_tools`
- `delegation_receipts`: one receipt for each required agent
- `skill_receipts`: one required receipt for each required skill, with evidence
- `mcp_call_receipts`: one successful receipt for each required MCP tool
- `local_execution_overrides`: an empty list at completion
- `delegation_bypasses`: an empty list at completion
- `lifecycle_operations`: any lifecycle operation must record `surface: "mcp"`

If any required handoff, skill receipt, MCP receipt, or empty bypass list is
missing, `validate_orchestration_artifacts --require-complete` fails and the
orchestrator must not report DONE.

## Autonomous-Execution Mandate

The orchestrator must achieve all actions agentically with no unrecorded manual
dependency. Every unautomatable requirement must be detected early, resolved by
exactly one of the permitted responses below, and recorded in checkpoint state
under `human_interaction.requirements[]`.

Permitted responses:

- `scope_change`: change scope to remove the manual dependency.
- `exception`: permit an exception only when a runbook exists and its path is
  recorded in `runbook_path`.
- `halt`: halt until further instruction. A `halt` blocks DONE while present.

The checkpoint validator enforces the `human_interaction` invariants. An
unresolved response, invalid response value, `halt`, or exception without an
existing runbook path blocks completion.

## Delegation Model

After reading `artifacts/orchestration/orchestrator-state.json`, the main session delegates work exclusively through configured workers:

- `atomic-planner` — generates phased implementation plans
- `atomic-executor` — executes approved plans task-by-task
- `feature-reviewer` — produces policy, code, and feature audit artifacts by
  applying the `feature-review` workflow skill
- `task-researcher` — performs deep research in the exact tracked output root supplied by the orchestrator: `<feature-folder>/research/` for feature-associated work or `docs/research/` for one-off work
- `prd-feature` — produces issue, specification, and user-story artifacts when required by the selected workflow
- `staged-review` — reviews staged changes when a pre-commit review is required
- `epic-review` — reviews epic-level artifacts when the work item is an epic
- `status-updater` — produces status update artifacts when the workflow requires status synchronization
- `python-typed-engineer` — performs delegated Python implementation work
- `powershell-typed-engineer` — performs delegated PowerShell implementation work
- `csharp-typed-engineer` — performs delegated C# implementation work
- `typescript-engineer` — performs delegated TypeScript implementation work

Every `task-researcher` handoff MUST include exactly one resolved research root. Derive feature-associated research from the checkpoint's tracked `feature-folder` as `<feature-folder>/research/`; use `docs/research/` only when the work is not associated with a feature. Do not delegate research with an inferred or artifacts-rooted output directory.
- `commit-steward` — writes commit messages from commit-context artifacts

The orchestrator does not perform deep implementation itself. It coordinates, tracks state, and enforces completion.

For a small route, resolve the language-specific generated typed-engineer deployment profile,
delegate all implementation and changed-scope QA to that agent, and persist its routing and
delegation receipts. Direct coordinating-thread implementation is prohibited. For a large route,
the root session must deploy the generated `orchestrator-<profile>` before this delegation model
is applied.

Every worker listed above must exist as a native Codex agent under `.codex/agents/`.
For required delegated steps, missing agent configuration, failed spawn, missing
receipt, or missing required artifact output is a hard block. The orchestrator
must persist blocked state and stop rather than performing that step locally.

Every required skill listed in the selected route must be acknowledged in
`skill_receipts[]` with:

- `skill`
- `required: true`
- `acknowledged_at_phase`
- `evidence`

The evidence value must point to objective evidence: a checkpoint field, MCP
receipt, artifact path, validator output, or test result. A bare narrative
statement is not sufficient.

## Evidence Location Authority

All evidence artifacts produced during orchestration MUST comply with the canonical scheme defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`. Evidence MUST be written to `<FEATURE>/evidence/<kind>/` only.

Permitted `artifacts/`-rooted sub-paths (non-evidence orchestration use only):
- `artifacts/orchestration/` — orchestrator state and checkpoints
- `artifacts/pr_context` — PR context artifacts
- `artifacts/reviews/` — review staging artifacts
- `artifacts/status/` — status update artifacts
- `artifacts/python/` — Python coverage and lcov outputs
- `artifacts/pester/` — Pester coverage outputs
- `artifacts/csharp/` — C# coverage outputs

Research outputs are tracked documentation, not evidence or orchestration state. Write them only to `<feature-folder>/research/` or `docs/research/`, as resolved and supplied in the researcher handoff.

All other `artifacts/` sub-paths (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`) are FORBIDDEN for evidence output and will be blocked by the `enforce-evidence-locations.ps1` PreToolUse hook.

## Completion Requirements

The orchestrator must not report completion until:

1. All required artifacts for the selected workflow path are present on disk.
2. All validation gates (toolchain, acceptance criteria, audit artifacts) have passed.
3. The checkpoint file at `artifacts/orchestration/orchestrator-state.json` reflects the completed state.
4. The orchestrator-state validator passes with `--require-complete`.

## Pre-Review Commit

Before delegating to the `feature-reviewer` agent, the orchestrator must:

1. Stage all modified and new files: `git add -A`.
2. Run MCP tool `collect_commit_context` and capture the returned on-disk artifact path.
3. Delegate to `commit_steward` using that commit-context artifact as the authoritative staged-change input.
4. Commit using the generated message: `git commit -m "<generated message>"`.
5. Only after a successful commit may the orchestrator proceed to the
   `feature-reviewer` delegation.

The review subagent compares against a base branch; uncommitted changes are invisible to the diff tool and cannot be audited.

## Post-Review Outcome Evaluation

After each `feature-reviewer` delegation returns:

1. Read the exact `REVIEW_VERDICT`, `REMEDIATION_ACTION`, `BLOCKER_FINGERPRINT`, `REMEDIATION_INPUTS`, and `REMEDIATION_PLAN` terminal lines from the review result.
2. Fail closed if any field is missing, duplicated, malformed, or outside the canonical verdict/action/path matrix.
3. For `REVIEW_VERDICT: PASS`, require all of the following exact companion values:
   - `REMEDIATION_ACTION: NONE`
   - `BLOCKER_FINGERPRINT: NONE`
   - `REMEDIATION_INPUTS: NONE`
   - `REMEDIATION_PLAN: NONE`
4. Validate PR-creation readiness through `validate_orchestration_artifacts` with `artifact_type: "orchestrator-state"` and `require_pr_creation_ready: true`. Advance to the PR creation gate only when this validation passes.
5. The `PASS` plus `NONE` transition exits remediation without creating or resolving a remediation plan, allocating an attempt, appending a completed cycle, or incrementing `attempt_count`, `completed_cycle_count`, or the compatibility `remediation-pass` field.
6. A canonical `BLOCKED` result proceeds to the action-specific evaluation below; it MUST NOT use the `PASS` transition.

### Pre-R1 Blocked Terminal and Wait Transitions

For every row below, require `REVIEW_VERDICT: BLOCKED`, the listed action, a complete aggregate `BLOCKER_FINGERPRINT`, and both `REMEDIATION_INPUTS: NONE` and `REMEDIATION_PLAN: NONE`:

| `REMEDIATION_ACTION` | Persisted transition |
|---|---|
| `NO_CANDIDATE` | `blocked_no_candidate` |
| `EXTERNAL_RUNTIME` | `blocked_external_runtime` |
| `AWAITING_CI` | `awaiting_ci` |
| `HUMAN_DECISION` | `blocked_human_decision` |

Each transition occurs before R1 and preserves the latest review as the terminal or waiting evidence. It forbids remediation-input or plan creation, R1/R2 work, R3 delegation, staging, commit-context collection, commit, R4 review, attempt allocation, completed-cycle creation, and attempt/cycle count consumption. `awaiting_ci` may resume only after an observed external-state change; a poll, retry, or resume without that change consumes no attempt or cycle.

### Pre-R1 MCP Runtime Compatibility Gate

Before accepting or creating a remediation plan, revising a plan, entering R1, or mutating attempt/cycle state, read the active local MCP initialize response and require `capabilities.experimental["drm-copilot/validator"]`. Validate all compatibility data in one local, read-only decision:

1. The capability object and every required field exist: `validator_contract_version`, `remediation_loop_schema_versions`, `supported_artifact_types`, `supported_validation_flags`, `routing_policy_sha256`, `package_version`, and `bundle_sha256`.
2. `validator_contract_version` equals the repository-required contract version and `remediation_loop_schema_versions` includes schema version `2`.
3. `supported_validation_flags` includes every flag selected by the current route, including `require_pr_creation_ready`, and `supported_artifact_types` includes every artifact type required by the current workflow, including `orchestrator-state`.
4. `serverInfo.version`, capability `package_version`, and the active package manifest version are identical.
5. Capability `bundle_sha256` is a valid SHA-256 and equals the digest of the executing MCP bundle.
6. Capability `routing_policy_sha256` equals the SHA-256 of canonical `config/orchestration-routing.json` and the executing bundle's distributed routing policy.

Map every capability comparison code to the same non-remediable result:

| Capability comparison code | Review result | Persisted transition |
|---|---|---|
| `ORCH_VALIDATOR_CAPABILITY_MISSING` | `BLOCKED` + `EXTERNAL_RUNTIME` | `blocked_external_runtime` |
| `ORCH_VALIDATOR_VERSION_INCOMPATIBLE:CONTRACT` | `BLOCKED` + `EXTERNAL_RUNTIME` | `blocked_external_runtime` |
| `ORCH_VALIDATOR_VERSION_INCOMPATIBLE:SCHEMA` | `BLOCKED` + `EXTERNAL_RUNTIME` | `blocked_external_runtime` |
| `ORCH_VALIDATOR_CAPABILITY_MISSING:FLAG` | `BLOCKED` + `EXTERNAL_RUNTIME` | `blocked_external_runtime` |
| `ORCH_VALIDATOR_CAPABILITY_MISSING:ARTIFACT` | `BLOCKED` + `EXTERNAL_RUNTIME` | `blocked_external_runtime` |
| `ORCH_VALIDATOR_VERSION_INCOMPATIBLE:PACKAGE` | `BLOCKED` + `EXTERNAL_RUNTIME` | `blocked_external_runtime` |
| `ORCH_VALIDATOR_VERSION_INCOMPATIBLE:BUNDLE` | `BLOCKED` + `EXTERNAL_RUNTIME` | `blocked_external_runtime` |
| `ORCH_ROUTING_POLICY_DIGEST_MISMATCH` | `BLOCKED` + `EXTERNAL_RUNTIME` | `blocked_external_runtime` |

Every mapped result sets both remediation paths to `NONE` and stops before plan creation or revision, R1/R2, R3 delegation, staging, commit, or R4. Leave `attempt_count`, `completed_cycle_count`, `attempts`, `cycles`, and the prior review unchanged. Do not query a registry, silently fall back to another runtime, allocate an attempt or cycle, or consume an attempt or cycle.

### R1 Entry Gate — Autonomous Review Result

Only `REVIEW_VERDICT: BLOCKED` plus `REMEDIATION_ACTION: AUTONOMOUS` may enter R1. Before any remediation mutation:

1. Require `BLOCKER_FINGERPRINT: sha256:<64-lowercase-hex>` over the complete blocker aggregate.
2. Require exactly one `REMEDIATION_INPUTS` line containing a non-`NONE` path and exactly one `REMEDIATION_PLAN` line containing a non-`NONE` path.
3. Normalize each path relative to the workspace root, resolve it without following the path outside the workspace, and require both resolved paths to be files beneath the active feature folder.
4. Treat the resolved `REMEDIATION_PLAN` path as the single plan of record. Reject alternate, sibling, newly substituted, or multiple plan paths for the same remediation loop.
5. Fail closed when either field is absent, duplicated, `NONE`, malformed, missing on disk, or not feature-local. This failure occurs before R1, plan creation or revision, checkpoint mutation, attempt allocation, cycle allocation, staging, or delegation.

## Remediation Loop (R1–R5)

A bounded loop consisting of five steps. Identifiers and compatibility counts are derived only from the persisted arrays:

- Before R3 delegation, validate that existing `attempt_id` values equal the one-based, gap-free sequence `1..attempts.length`. After clear preflight, allocate the current attempt as `attempts.length + 1` in the same checkpoint mutation that starts R3; never reserve an identifier during R1, R2, a preflight revision, a poll, or a resume.
- Before appending a completed cycle after R4, validate that existing `cycle_id` values equal the one-based, gap-free sequence `1..cycles.length`. Allocate the new cycle as `cycles.length + 1` in the same atomic append and link it to the eligible current attempt.
- After every mutation, require `attempt_count == attempts.length` and `completed_cycle_count == cycles.length`.
- `remediation-pass` is a deprecated compatibility mirror of `completed_cycle_count` only. It MUST NOT identify the current attempt, seed either identifier, reserve work, or control loop continuation.

- **R1 — Remediation plan of record:** Use only the exact, validated, feature-local `REMEDIATION_PLAN: <path>` returned by the review as the single plan of record for the loop. Keep that path unchanged across all preflight revisions.
- **R2 — Preflight clearance:** Delegate to `atomic-executor` for precondition validation only (no implementation). If the executor does not return `PREFLIGHT: ALL CLEAR`, return to R1 by re-delegating to `atomic-planner` against the same remediation-plan path with the required-changes output from the executor. Only after `PREFLIGHT: ALL CLEAR` may the orchestrator advance to R3.
- **R3 — Remediation execution:** Delegate to `atomic-executor` with full execution authorization. Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping.
- **Pre-R4 candidate gate:** Require the R3 result to state `execution_status`, `candidate_applied`, and `terminal_disposition` before any staging operation.
  - When `candidate_applied: false`, finish and record the current attempt exactly once with its non-candidate terminal disposition. Increment `attempt_count` once for that recorded attempt, but do not append a cycle or increment `completed_cycle_count` or `remediation-pass`.
  - A false candidate MUST stop before `git add`, commit-context collection, commit, PR-context refresh, or R4 review. It MUST NOT allocate a replacement attempt, create a completed-cycle record, or continue to R5.
  - Persist the matching terminal or waiting status from `no_candidate`, `external_runtime`, `awaiting_ci`, `human_decision`, or `execution_failed`; retain the last completed review and execution receipt as evidence.
  - When `candidate_applied: true`, require `execution_status: complete` and `terminal_disposition: candidate_applied`. Any other execution status fails closed before staging and cannot create a cycle.
- **Pre-R4 commit:** Only for `candidate_applied: true` plus `execution_status: complete`, finish the current attempt, stage all changes (`git add -A`), run MCP tool `collect_commit_context`, delegate to `commit_steward` using the resulting artifact, and commit with the generated message. Require and persist a nonempty commit SHA before advancing to R4.
- **R4 — Re-audit:** Refresh PR context via MCP tool `collect_pr_context`, then delegate to `feature-reviewer` with the same inputs as the original review (resolved base branch, feature folder, refreshed PR context artifacts, acceptance-criteria source). No scope narrowing. The canonical issue number line must be included. Require the completed re-audit's feature-local artifact path. Only after both the nonempty commit SHA and re-audit path exist may the orchestrator append exactly one completed cycle linked to the current attempt and increment `completed_cycle_count` and `remediation-pass` exactly once.
- **R5 — Loop-exit decision:** Evaluate the re-audit recorded in that completed cycle. If it returns the canonical `PASS` plus `NONE` result with `BLOCKER_FINGERPRINT`, `REMEDIATION_INPUTS`, and `REMEDIATION_PLAN` all `NONE`, exit the loop and advance to the PR creation gate. Otherwise, return to the action-specific decision without appending a second cycle for the same attempt.

### Canonical Post-R4 Fingerprint and Exception Gate

`.agents/skills/orchestrate/SKILL.md` is the sole owner of exception evaluation. Other skills and generated orchestrator surfaces MUST delegate to this gate and MUST NOT copy, weaken, or independently reinterpret its algorithm.

After R4 has produced the complete aggregate review and the completed cycle has been appended, perform these steps before creating another remediation plan or allocating another attempt:

1. Read `blocker_fingerprint_before` from the source review and `blocker_fingerprint_after` from the complete R4 aggregate. Both values MUST use `sha256:<64-lowercase-hex>` for a blocked review.
2. If the fingerprints differ, no stagnation exception is required; continue only through the action-specific R5 transition.
3. If the fingerprints are equal, calculate the next gap-free `attempt_id` without allocating it and evaluate whether one exact unused exception authorizes the documented unchanged-fingerprint continuation to R1.
4. The exception object MUST contain exactly `exception_id`, `issue_number`, `blocker_fingerprint`, `routing_policy_sha256`, `allowed_transition`, `single_use`, `consumed_at`, and `consumed_by_attempt_id`. Require:
   - `issue_number` equals the canonical issue number;
   - `blocker_fingerprint` equals both compared fingerprints;
   - `routing_policy_sha256` equals the current SHA-256 of `config/orchestration-routing.json`;
   - `allowed_transition` exactly names the pending unchanged-fingerprint continuation;
   - `single_use` is exactly `true`;
   - `consumed_at` and `consumed_by_attempt_id` are both null before use;
   - `exception_id` has never appeared in any prior attempt, cycle, or exception-consumption record.
5. Reject missing or extra fields, null or empty required values, wildcard or pattern values, partial bindings, issue/fingerprint/digest/transition mismatches, inconsistent consumption fields, an already-consumed binding, or any reused `exception_id`. Rejection allocates no new plan, attempt, or cycle and leaves the just-appended completed-cycle counts unchanged.
6. When no exact unused valid exception exists, persist `blocked_stagnation` and stop before any new remediation plan, preflight, attempt, execution, staging, commit, or R4 review.
7. For one exact unused valid exception, atomically set `consumed_at` to the consumption timestamp and `consumed_by_attempt_id` to the calculated next attempt ID in the same checkpoint update that binds the exception to that attempt. Only after this atomic write may the orchestrator permit the documented continuation to R1 once. The consumed exception can never authorize another transition.

**Termination guard:** After the R4 cycle is appended and the PASS, terminal-action, fingerprint, and exception decisions are evaluated, an unresolved third completed cycle (`completed_cycle_count == max_completed_cycles == 3`) transitions only to `blocked_remediation_loop_limit`, records `step6_status: "blocked_remediation_loop_limit"`, and halts. Preflight revisions, retries, CI polls, resume delegations, and attempts with `candidate_applied: false` consume zero completed cycles. The compatibility `remediation-pass` mirrors `completed_cycle_count` and is never the limit authority or an attempt identifier. `blocked_cycle_limit` is rejected legacy input only and MUST NOT be emitted or executed by updated writers.

## Release-Boundary Validator Parity

Positive parity MUST compare the same review/remediation contract, schema, validation flags, routing-policy content and SHA-256, package identity, bundle identity, ordered diagnostics, and substantive validation result across all of these locally controlled surfaces:

1. The repository source Python and TypeScript validator implementations.
2. Generated configuration and customization mirrors derived from canonical sources.
3. The locally built MCP bundle launched as the executing JSON-RPC runtime.
4. The locally packed candidate installed or launched from the produced package archive.

Each positive surface MUST execute locally and report matching capability and validation values; file-presence or static-string checks alone are insufficient for the built bundle and packed candidate. Immutable published `@danmoisan/drm-copilot-mcp@1.0.24` is a negative `EXTERNAL_RUNTIME` compatibility fixture only. Its expected incompatibility verifies the pre-R1 terminal path and consumes no remediation attempt or cycle; it MUST NOT be treated as a positive parity target or changed in place.

## Issue Number Consistency

The canonical issue number is derived once from the active feature folder name: extract the trailing integer from the folder base name (e.g., `2026-04-26-push-down-claude-customizations-162` yields `162`). Record as `issue_num` in the checkpoint.

Every delegation prompt to `atomic-planner`, `atomic-executor`, and
`feature-reviewer` must include the line:

> `Canonical issue number for this feature is <issue_num>. All artifact content, file paths, and cross-references must use this number.`

If a subagent artifact references a different issue number, the orchestrator rejects it, requests correction, and records the discrepancy under `artifact_errors` in the checkpoint.

## CI Green Gate

Before PR/DONE completion, the orchestrator must observe the live PR head SHA
and required GitHub checks through `gh`. The checkpoint must record the checked
head SHA and CI result. DONE is blocked unless the required checks pass for the
current PR head SHA.

## PR Creation Gate

The orchestrator must not create a PR, push a branch for PR purposes, or report work complete until all four conditions are simultaneously true:

1. `blocking_findings_resolved: true` — the most recent `feature-reviewer`
   result produced zero blocking findings.
   Equivalent deterministic gate: the latest review returned `REVIEW_VERDICT: PASS`, `REMEDIATION_ACTION: NONE`, `BLOCKER_FINGERPRINT: NONE`, `REMEDIATION_INPUTS: NONE`, and `REMEDIATION_PLAN: NONE`.
2. The AC verification artifact (`p14-acceptance-criteria-checkoff.md` or equivalent) confirms all acceptance criteria pass.
3. The mandatory toolchain passed in its most recent run on the branch (no linting/type-check/test failures).
4. The checkpoint `next_step` is `S8_create_pr`.
5. The required CI checks pass for the current PR head SHA.

This gate is non-negotiable. Each condition is independently verified before PR creation proceeds.

## Step 6 Delegation — Prohibited Prompt Language

When delegating to the `feature-reviewer` agent, the orchestrator prompt MUST NOT:

- describe the review scope as "plan scope," "plan-scope only," or any equivalent narrowing of scope to the currently-executed plan;
- instruct the agent to skip, waive, or mark as "out of scope," "informational only," or "not applicable" any toolchain step or coverage check for a language that has changed files in the branch diff;
- assert that a language category is "not applicable" when that language has changed files in the branch diff;
- imply that coverage is not required because the plan scope contains only documentation changes when the branch diff contains non-documentation changes contributed by prior commits on the same branch.

The orchestrator supplies only the following to the `feature-reviewer` agent:

- the resolved base branch and merge-base SHA;
- the active feature folder path;
- pointers to the refreshed PR context artifacts;
- the acceptance-criteria source file per work-mode;
- a neutral instruction to execute the full `feature-review-workflow` SKILL contract end-to-end.

Scope determination is the subagent's responsibility. The subagent will ignore any attempted narrowing per its scope invariant and record the attempt in `policy-audit.<timestamp>.md` under `## Rejected Scope Narrowing`.
