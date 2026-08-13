<!-- markdownlint-disable-file -->
# Task Research Notes: Codex-Native Parallel Orchestration

## Research Executed

### Objective and Scope

Recommend an additive Codex-native architecture that is behaviorally and mechanically equivalent to the delivered Claude parallel-orchestration surface, while preserving `.claude/` unchanged. This is a standalone parallel feature, not an epic invocation. Research was read-only except for this single required artifact.

### File Analysis

- Read `AGENTS.md`, `.github/agents/task-researcher.agent.md`, `.agents/skills/research-issue/SKILL.md`, and `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` before analysis.
- Read `docs/features/epics/parallel-orchestration/{epic.md,epic-kickoff.md,epic-status.md}` and the linked delivered feature documents for schemas, blast radius, cohorts, planner, orchestrator, mutations, hooks, drift, and correction work.
- Read `docs/research/2026-08-07-parallel-orchestration-design-research.md` as the consolidated delivered behavior.
- Read `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/`, including its specification, final audits, and evidence. The feature records 34/34 accepted criteria, 245 passing Bats assertions, 92.3 percent Bash line coverage, and byte parity for 16 root/bundle Claude pairs.
- Read `.claude/skills/parallel-{plan,run,orchestrate,add,remove,close}/SKILL.md`, `.claude/agents/parallel-{planner,orchestrator}.md`, the parallel rule, `.claude/settings.json`, and the registered parallel cohort, drift, worktree-removal, abandon, invocation-origin, and completion hooks.
- Read the shared Python blast-radius, manifest, kickoff, cohort/batch, mutation, drift, and planner/orchestrator validation modules and tests.
- Read the TypeScript MCP parallel validator cores, records, structures, cohort barrier, tool definitions/dispatch, and tests.
- Read Codex epic-native root skills, planner/orchestrator profiles, checkpoint and authority hooks, model/topology resolvers, launch/receipt/worktree scripts, completion gates, and process/runtime tests.
- Read `.codex/config.toml` registrations. Codex hooks and multi-agent execution are enabled, but no Codex parallel runtime is registered.
- Read the root and extension Python/TypeScript Codex customization publishers, filesystem/pack helpers, bundle resources, manifests, and parity tests.
- Read `.agents/skills/translate-claude-to-codex/SKILL.md`. Its named basis `artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md` is absent. The verified correction used here is `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`.

### Code Search Results

- There are no Codex parallel entry skills, parallel planner/orchestrator profiles, parallel hooks, or parallel child-launch scripts.
- `config/orchestration-routing.json` contains a parallel route, but Codex topology/model policy defines standalone and epic contexts only. The route is not presently executable as a Codex parallel surface.
- Python orchestrator validation calls mutation-protocol, semantic drift-gate, and cohort-barrier validation. TypeScript/MCP performs structure and cohort checks but lacks the Python mutation completeness/mode invariants and semantic drift gate.
- The two verified gaps are documented in `docs/features/potential/2026-08-09-parallel-drift-gate-typescript-parity-divergence.md` and `docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md`.
- The Codex epic launcher already persists immutable launch specs, exact agent/model/reasoning and permission data, hashes, child status, isolated `CODEX_HOME`, and worktree identity. It is epic-prefixed and includes integration-branch assumptions, so a shared core must be extracted instead of reused verbatim.
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` provides the registered-process pattern for native stdin, poisoned `CLAUDE_TOOL_INPUT` and `CLAUDE_SESSION_ID`, allow/deny, malformed input, stdout, stderr, and exit codes.
- Both Codex publishers currently deliver `.codex/`, `.agents/`, and shared orchestration routing. They do not select the parallel Bash/blast-radius payload or `config/blast-radius.json`.
- Root/bundle tests require byte-identical Codex customization pairs; pack tests require membership or an explicit justified exclusion.

### External Research

- #fetch:https://developers.openai.com/codex/hooks — Official documentation verifies native stdin JSON hook transport, native deny envelopes, exit behavior, PreToolUse coverage, `Agent` matching, and SubagentStop continuation. It also states that hooks are guardrails rather than a complete security boundary.
- #fetch:https://developers.openai.com/codex/config-reference — Official documentation verifies trusted project `.codex/config.toml`, custom agent profiles, and concurrency configuration.
- #fetch:https://developers.openai.com/codex/multi-agent — Official documentation verifies native parallel agents and inherited runtime/sandbox settings, and cautions that write-heavy parallelism needs coordination.
- #githubRepo:"openai/codex" hooks configuration — The official repository `docs/config.md` and `codex-rs/config/src/config_toml.rs` were checked for current configuration and concurrency vocabulary.
- External sources were used only to verify Codex primitives. Repository behavior and gaps were derived from repository files and tests.

### Project Conventions

- Keep shared algorithms single-sourced; PowerShell hooks are transport/admission adapters, not alternate state machines.
- Python is presently the semantic authority; TypeScript/MCP parity is required before MCP can gate completion.
- Codex root personas require deterministic topology/model receipts and prohibit silent fallback.
- Isolated write-heavy children use the external `codex exec` worktree launcher pattern; native agent spawning does not bind a child process to a distinct worktree.
- Codex hooks consume native stdin and must ignore `CLAUDE_*` variables.
- Standalone parallel state belongs under `docs/features/parallel/<slug>/` with parallel planner/orchestrator checkpoints, never epic checkpoints or an integration branch.
- `.claude/` is an independent delivered runtime and is immutable for this feature.

## Key Discoveries

### Delivered Semantics

- `parallel-plan` prepares every item through validated preflight and stops before implementation. `parallel-run` executes a prepared committed kickoff; `parallel-orchestrate` executes a valid manual manifest.
- Each item starts from `origin/main`, owns one isolated worktree and branch, opens one PR to `main`, requires exact-head green CI, merges independently, and removes its worktree before terminal completion.
- Conflict edges derive from normalized blast-radius/shared-surface overlap. Welsh-Powell ordering is `(-degree, item_key)`, smallest available color wins, cohorts execute in ascending color, and batches use ascending `item_key` bounded by manifest `max_concurrency`.
- A conflicting later cohort cannot start until required predecessor items are both merged and worktree-removed; green CI is insufficient.
- Drift compares observed pre-review files with the declaration, records a blocking event, quiesces scheduling, recomputes, halts later-started conflicts rather than the drifting item, and requeues deterministically.
- Add/remove recomputation pins in-flight items. In-flight removal requires explicit detach/abandon; merged removal is rejected. Open mode requires explicit close; closed mode has terminal completion invariants; close is rejected with in-flight work.
- Resume reconciles checkpoint cache against Git, GitHub, worktree, launch, mutation, and drift truth before scheduling.

### Mechanical Enforceability Ledger

`PRESERVED` means a direct shared or Codex-native mechanical control can enforce the invariant. `DEGRADED` means Codex lacks an identical primitive but a tested mechanical compensating-control pattern exists and parallel-specific tests are mandatory. `LOST` means no mechanical enforcement remains and blocks release.

| ID | Claude gate | Codex-native mapping | Status |
|---|---|---|---|
| G01 | Root invocation/provenance | Extend tested Codex authority store and root gate with distinct parallel authorities; reject ordinary/epic roots. | PRESERVED |
| G02 | Per-agent tool allowlist | Forced agent profile, permission profile, sandbox, PreToolUse gates, and sealed external launch spec; existing epic attestation/process suites verify the compensating pattern. | DEGRADED |
| G03 | Planning-only and ready kickoff boundary | Separate root skills/personas/checkpoints plus planning-only and `requireReadyForExecution` validation. | PRESERVED |
| G04 | Manifest, blast radius, deterministic cohorts/batches, maximum concurrency | Reuse Python authority, issue-462 Bash, and parity-complete MCP validation; Codex thread order is never the scheduler. | PRESERVED |
| G05 | Isolated item worktree and child identity | Generalize tested epic launcher, immutable launch/status receipts, sandbox preflight, attestation, and worktree binding. | PRESERVED |
| G06 | Per-item PR to main, exact-head CI, merge without fan-in | Validate base/head/SHA/checks/merge per item and reject integration-branch state. | PRESERVED |
| G07 | Durable checkpoint/resume reconciliation | Separate parallel checkpoints plus tested receipt persistence and authoritative Git/GitHub/worktree reconciliation. | PRESERVED |
| G08 | Layer-1 cohort admission before delegation | Native PreToolUse on external launch and Agent calls validates current predecessor merge/removal state. | PRESERVED |
| G09 | Layer-2 cohort state validation | Existing shared Python and TypeScript cohort barriers run on transitions/completion. | PRESERVED |
| G10 | Drift detection, quiescence, halt, recolor, requeue | Reuse Python algorithms and add exact TypeScript semantic parity; hook and scheduler consume persisted resolution. | PRESERVED |
| G11 | Layer-1 unresolved-drift admission | Native Codex drift hook calls the shared validator through native stdin. | PRESERVED |
| G12 | Layer-2 semantic drift completion gate | Python exists; verified TypeScript gap must be closed and differential-tested before acceptance. | PRESERVED |
| G13 | Mutation protocol, pinning, open/closed completion, abandon | Reuse Python and port complete field-set/sequence/mode invariants to MCP; mutation skills are validated clients. | PRESERVED |
| G14 | Matching merged-item worktree removal only | Port Claude gate to native transport and reuse Codex worktree command/binding pattern. | PRESERVED |
| G15 | Exact explicit abandon operation | Native exact-token gate requires item/worktree identity and confirmation, then validates mutation/final state. | PRESERVED |
| G16 | Stop cannot succeed on invalid output/checkpoint | Codex SubagentStop continuation plus full transition validator, root refusal without completion receipt, and CI contracts; existing completion tests verify the compensating pattern. | DEGRADED |
| G17 | Deterministic topology/model/delegation/launch receipts | Add forced parallel contexts/personas and validate immutable receipts before launch/resume. | PRESERVED |
| G18 | Registrations, publishing, parity, packs, destination, CI | Fixed selection, byte parity, pack membership, process tests, payload-only tests, and CI contracts. | PRESERVED |

**Ledger total: 16 PRESERVED, 2 DEGRADED with tested mechanical compensating-control patterns, 0 LOST.** Any omitted or failing parity, transport, launch-binding, publishing, or CI control changes the affected gate to LOST and blocks the recommendation.

### Recommended Architecture

Build a Codex root-controller surface that composes the delivered parallel semantic core with a generalized Codex external child launcher:

1. Add explicit `parallel-plan`, `parallel-run`, `parallel-orchestrate`, `parallel-add`, `parallel-remove`, and `parallel-close` root skills.
2. Add forced root `parallel-planner` and `parallel-orchestrator` profiles. Ordinary and epic orchestrators cannot invoke them.
3. Keep the parent as the sole deterministic cohort/batch scheduler.
4. Extract the epic launcher's immutable spec, isolated `CODEX_HOME`, exact profile/model/reasoning/permission binding, worktree identity, status persistence, hashing, and resume logic into a surface-neutral core. Keep thin epic and parallel adapters; the parallel adapter requires `main` and forbids integration fan-in.
5. Reuse Python/Bash/TypeScript algorithms. Close TypeScript mutation/drift parity before enabling runtime completion.
6. Register native Codex provenance, cohort, drift, worktree-removal, abandon, routing/model, child-binding, and SubagentStop gates.
7. Publish new Codex-native files through root/bundle mirrors and publish existing portable assets through a fixed cross-runtime allowlist, without copying or changing `.claude/`.

### Existing Assets to Reuse

- Python: `compute_blast_radius.py` and helpers; `parallel_cohort_computation.py`; `parallel_manifest_contract.py`; `parallel_kickoff_contract.py`; `parallel_mutation_protocol.py` and support modules; `parallel_drift_detection.py` and support modules; `validate_parallel_planner_state.py`; `validate_parallel_orchestrator_state.py` and helpers.
- TypeScript/MCP: parallel planner/orchestrator state cores, records/structures/cohort barrier/kickoff validators, existing tool definitions, input types, dispatch, and integration tests.
- Codex: root authority store/authorizer, routing/model attestations, epic launch contract/runtime/persistence/sandbox modules, child launch/resume/post-session flow, worktree binding, wave/merge/removal patterns, and process/runtime contract suites.
- Portable issue-462 assets:
  - `.claude/lib/bash/{compute-cohorts.sh,compute-concurrency-batches.sh,parallel-cohorts.sh,parallel-common.sh,parallel-items-validate.sh,parallel-manifest-validate.sh,parallel-yaml-emit.sh,parallel-yaml-scan.sh,validate-parallel-manifest.sh}`
  - `.claude/lib/blast-radius/{BlastRadius.psm1,BlastRadiusConfig.psm1,BlastRadiusExtraction.psm1,BlastRadiusGlob.psm1,BlastRadiusValidation.psm1}`
  - `config/blast-radius.json`

### Complete Examples

Proposed launch record shape, reusing verified epic receipt fields with parallel identity:

```json
{
  "schema_version": 1,
  "surface": "parallel",
  "parallel_slug": "sample",
  "item_key": "P-02",
  "cohort": 1,
  "batch": 0,
  "base_branch": "main",
  "head_branch": "feature/sample-p-02",
  "worktree_path": "C:/worktrees/sample-p-02",
  "agent": "python-orchestrator-c3",
  "model": "gpt-5.6-terra",
  "reasoning_effort": "high",
  "topology_receipt_path": "artifacts/orchestration/receipts/P-02/topology.json",
  "model_routing_receipt_path": "artifacts/orchestration/receipts/P-02/model-routing.json",
  "launch_status_path": "artifacts/orchestration/receipts/P-02/launch-status.json",
  "launch_spec_sha256": "<sealed-sha256>"
}
```

Native hook transport contract:

```text
stdin JSON -> parse hook/tool/tool_input -> load checkpoint and receipt
           -> call shared semantic validator
allow      -> exit 0; stdout empty; stderr empty
deny       -> exit 0; one native JSON deny envelope; stderr empty
malformed  -> exit 2; stdout empty; diagnostic on stderr
```

### Source, Bundle, Publisher, and Pack Requirements

- Add every new `.agents/` and `.codex/` source to the root and a byte-identical counterpart under `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- Keep issue-462 files canonical in `.claude/lib/` and `extensions/drm-copilot/resources/claude-customizations/`; Codex publisher adapters select only the listed cross-runtime assets. Do not duplicate them into the Codex bundle and do not publish all of `.claude/`.
- Extend both Python and TypeScript Codex publishers with identical fixed selection and collision rules.
- Reuse/generalize the TypeScript routing merge used by the Claude publisher and add equivalent Python additive merge so destination-owned routes survive. Preserve the issue-462 generic-default behavior for `config/blast-radius.json`.
- Update `core.json` and applicable language pack manifests. Full and selected packs must carry required assets; tests must reject missing membership and unrelated `.claude` selection.
- Enforce root/bundle SHA parity, publisher-output parity, registration existence, pack completeness, and destination payload-only execution in CI.

### Likely Production File Inventory

Add:

- `.agents/skills/parallel-{plan,run,orchestrate,add,remove,close}/SKILL.md`
- `.codex/agents/parallel-{planner,orchestrator}.toml`
- `.codex/hooks/authorize-root-parallel-invocation.ps1`
- `.codex/hooks/enforce-parallel-{root-invocation,cohort-barrier,drift-gate,worktree-removal-gate,abandon-gate}.ps1`
- `.codex/hooks/validate-parallel-agent-output.ps1`
- Surface-neutral child-launch core modules and thin `.codex/scripts/parallel-child-launch-contract.ps1`, `launch-parallel-child-batch.ps1`, and `resume-parallel-child.ps1`; split to remain below 500 lines.
- Focused TypeScript mutation and semantic drift modules adjacent to existing parallel orchestrator validators.
- All byte-identical Codex bundle mirrors.

Modify:

- `AGENTS.md` and bundle mirror.
- `.codex/config.toml` and bundle mirror.
- Root and extension `config/orchestration-routing.json`.
- Codex authority, routing/model attestation, child launch-attestation, and worktree-binding helpers to accept a surface discriminator while retaining epic behavior.
- Existing epic launcher files to thin adapters over the shared core.
- Python `resolve_codex_topology.py`, `resolve_codex_deployment.py`, parallel state validators, and the epic-only launch-binding helper generalized for shared use.
- TypeScript topology resolver, model-routing validator, parallel state validators, and MCP inputs/definitions/dispatch only where new Codex validation options require them.
- Python `scripts/dev_tools/push_down_codex_and_agents_customizations.py` and supporting filesystem/pack selectors.
- TypeScript `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` and supporting selectors/merge adapters.
- Codex pack manifests and test-discovery/CI configuration only where current discovery does not cover new tests.

### Test Inventory and Mandatory Matrix

- Pester: parallel provenance, execution gates, child launch attestation, worktree launch/resume, launch hardening, and Codex parallel runtime contracts.
- Every newly registered Codex hook must be launched as a process through the actual `.codex/config.toml` registration and cover allow, deny, malformed/missing stdin, poisoned `CLAUDE_TOOL_INPUT`, poisoned `CLAUDE_SESSION_ID`, exact stdout, exact stderr, and exact exit code.
- Python: forced contexts/personas, monotonic ceilings, receipt and launch binding, resume, mutation, drift, mode completion, and Claude backward compatibility.
- TypeScript/MCP: mutation field completeness/sequence, open/closed invariants, semantic drift, cohort barriers, receipt requirements, and differential fixtures against Python.
- Launcher: immutable hashes, invalid profile/model, repository/branch/worktree mismatch, corrupt status, interrupted resume, bounded concurrency, and deterministic ascending-item batch launch.
- Bats: published payload-only manifest/cohort/batch behavior without Python or Poetry and exact cross-runtime asset selection.
- Publisher/parity: Python/TypeScript output equality, additive routing merge, blast-radius delivery, full/selected packs, collision behavior, no unrelated `.claude`, root/bundle byte parity, and registered-script existence.
- Regression: all existing epic and Claude suites; verify no `.claude/` source diff.

## Recommended Approach

Use the root-controller/shared-launcher architecture above. It preserves all delivered gates, keeps parallel state separate from epic fan-in, reuses tested Codex isolation/receipt mechanisms, and avoids duplicate algorithms or portable assets.

### Rejected Alternatives

- Literal Claude translation plus native agent spawning: rejected because it cannot bind write-heavy children to distinct worktree processes and Codex lacks an identical per-agent tool allowlist.
- Copy/rename the epic runtime: rejected because it duplicates security/launch logic and imports integration-branch semantics that conflict with per-item PRs to `main`.
- Copy issue-462 assets into the Codex bundle: rejected because it creates another source of truth.

### Implementation Sequence

1. Port Python mutation and drift semantics to TypeScript/MCP with differential tests; treat failure as release-blocking.
2. Add parallel topology/model contexts and extract a surface-neutral launcher with full epic regression coverage.
3. Add root skills and forced planner/orchestrator profiles.
4. Add/register native hooks and complete every registered-process transport matrix.
5. Bind topology/model/delegation/launch/worktree receipts and authoritative resume reconciliation into parallel validators.
6. Extend both publishers, bundle mirrors, packs, and fixed cross-runtime selection.
7. Run formatting, linting, typing, unit/integration, Pester, Bats, parity, pack, registration, destination, and CI contract gates in one clean pass.

### Risks

- Current MCP false acceptance of unresolved drift or incomplete mutations: close before runtime enablement.
- Epic regression during launcher extraction: retain thin epic adapters and all existing launch/hardening tests.
- Timing-dependent scheduling: persist deterministic batches; Codex thread capacity is only an upper resource ceiling.
- Hook compatibility contamination: poison `CLAUDE_*` values in registered-process tests.
- Destination policy overwrite or broad Claude publication: additive merge plus exact allowlist/collision tests.
- Stale resume state: reconcile Git, GitHub, worktree, receipt, mutation, and drift truth first.

### Invariants

- `.claude/` remains unchanged.
- Parallel never uses an epic integration branch/checkpoint.
- One item owns one isolated worktree, branch, and PR to `main`.
- Identical normalized inputs yield identical cohorts and batches.
- No conflicting later cohort starts before predecessor merge and worktree removal.
- Unresolved drift, invalid mutation/abandon, missing receipts, and residual worktrees block completion.
- In-flight items stay pinned.
- Exact profile/model/reasoning/authority/worktree receipts precede launch; no fallback.
- Python, TypeScript/MCP, and Bash agree over shared domains.
- Every root Codex customization has a bundle mirror and pack membership.

### Acceptance-Criteria-Ready Requirements

1. Root plan/run/manual entry resolves only its forced authorized persona and persists topology/model receipts.
2. Ordinary and epic orchestrators are mechanically rejected as parallel roots.
3. Planning cannot implement; execution requires a committed validated ready kickoff.
4. Python, TypeScript/MCP, and Bash produce identical deterministic conflicts/cohorts/batches.
5. Each item launches in a distinct verified `origin/main` worktree with sealed exact-profile receipts.
6. Each item has one PR to `main`; exact-head checks, merge, and worktree removal gate completion.
7. Both cohort layers reject premature admission.
8. Drift quiesces, records, recomputes, halts only later-started conflicts, and requeues deterministically.
9. Python and MCP accept/reject identical drift and mutation fixtures.
10. Add/remove/close/abandon enforces complete ordered records, pinning, mode invariants, and exact confirmation.
11. Resume rejects corrupt/stale/mismatched external and receipt state before scheduling.
12. Every new hook passes the required allow/deny/malformed/poisoned/stdout/stderr/exit process matrix.
13. SubagentStop and root completion refuse invalid output until full validation succeeds.
14. Existing epic/Claude suites pass and `.claude/` has no source change.
15. Root/bundle byte parity and pack membership cover every new Codex file.
16. Both publishers agree, merge routing additively, deliver blast-radius config, and select only the fixed shared assets.
17. A published payload-only destination performs planning validation/cohort/batch computation without Python or Poetry.
18. All language, parity, registration, pack, destination, and CI gates pass with zero LOST gates.

### Named Planning Constraints and Open Questions

- **PC-01 — Exact hook matcher syntax:** derive final matcher tables from the repository's current `.codex/config.toml` schema during planning and validate every registration through process tests; do not infer syntax from Claude settings.
- **PC-02 — Final launcher module boundaries:** inventory current epic script line counts and dependency seams before choosing filenames; keep every reusable script below 500 lines and preserve epic public parameters.
- **PC-03 — Parallel receipt schema placement:** decide through schema compatibility tests whether Codex fields are additive shared fields guarded by `runtime: codex` or a referenced Codex launch record; Claude fixtures must remain valid.
- **PC-04 — Pack membership by language:** compute each parallel skill's dependency closure before editing `core.json` or language packs; every published path must have one justified membership outcome.
- **PC-05 — CI discovery:** verify whether existing recursive discovery includes each new suite before changing workflows; modify CI only for a demonstrated gap.
- **PC-06 — Research-location policy inconsistency:** the task-researcher source requires `artifacts/research/`, while `.codex/hooks/enforce-evidence-locations.ps1` describes research as `docs/research/` or feature research and rejects the former. Planning must reconcile the canonical agent contract and hook policy; this research follows the explicit handoff and source-agent output requirement.

## Implementation Guidance

- **Objectives:** deliver standalone Codex parallel planning, execution, mutation, resume, and completion with 0 LOST gates; preserve both existing runtimes.
- **Key Tasks:** close MCP parity first; generalize launch/receipts; add skills/personas/hooks; extend publishing; validate all regressions and destination behavior.
- **Dependencies:** shared Python and TypeScript validators, issue-462 portable assets, Codex epic launch/attestation patterns, routing configuration, and the corrected research basis `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`.
- **Success Criteria:** all 18 acceptance-ready requirements pass; ledger remains 16 PRESERVED, 2 DEGRADED with tested compensating controls, 0 LOST; no `.claude/` source changes or duplicated semantic authority exist.
