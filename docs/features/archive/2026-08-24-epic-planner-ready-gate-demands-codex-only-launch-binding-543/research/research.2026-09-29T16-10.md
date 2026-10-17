# Research: epic-planner ready gate demands Codex-only launch binding (Issue #543)

- Timestamp: 2026-09-29T16-10
- Issue: #543 (work mode `full-bug`)
- Branch: `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`
- Sources: `issue.md` and `spec.md` in this feature folder; `docs/features/potential/promoted/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding.md`; the #524 completed folder `docs/features/completed/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/`.
- Method limitation: this research session had file read/search tools only. No shell command (git, pytest, jest) was executed. Git history for #524 was reconstructed from the #524 feature folder and the current code, not from `git log`. Baseline pytest/jest pass-fail state was **not observed**.

All line citations below were re-derived from the current tree in this worktree.

---

## 1. Current State Analysis

### 1.1 The defect site (Python)

`scripts/dev_tools/validate_epic_planner_state.py` (354 lines):

- Signature, lines 279-284: `validate_epic_planner_state_text(text, *, require_ready_for_execution=False, readiness_context=None)`. No Codex flags are accepted.
- Ready block, lines 320-347. Line 331 is the unconditional call `errors.extend(validate_epic_planner_child_launch_bindings(features))`.
- Line 346 calls `validate_epic_readiness_integrity(state, text, readiness_context)` whenever a context is supplied.

`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` (298 lines):

- `_GENERATED_ORCHESTRATOR_AGENTS`, lines 15-23 (five Codex-generated names).
- `_carries_launch_path(feature)`, lines 202-205: key-membership test for `launch_receipt_path` or `launch_status_path`.
- `_validate_launch_bindings(..., require_launch_paths=False)`, lines 208-256; the per-feature skip is at lines 228-229.
- `validate_epic_planner_child_launch_bindings(features)`, lines 259-271: passes `require_generated_orchestrator=True`, `skip_not_started=False`, `require_launch_paths=False`.

### 1.2 A second Codex-only launch-evidence demand not named in the issue

The issue names only line 331. The ready gate also contains a second launch-evidence check:

- `scripts/dev_tools/epic_planner_readiness.py:354` calls `validate_epic_planner_launch_evidence(state, context)` from inside `validate_epic_readiness_integrity`. That call runs under the ready gate whenever `readiness_context` is supplied, and the CLI always supplies one under `--require-ready-for-execution` (`scripts/dev_tools/validate_orchestration_artifacts.py:433-436`).
- `scripts/dev_tools/epic_planner_launch_evidence.py:298-345` iterates every feature. It calls `_validate_receipt` (line 312), which calls `_launch_path(feature.get("launch_receipt_path"), ...)` (lines 203-205). It also calls `_launch_path(item.get("launch_status_path"), ...)` (lines 314-318). `_launch_path` (lines 37-55) returns `"... must identify a launch artifact in this repository."` for a missing or empty value (lines 42-43).
- Consequence: a Claude-shaped feature with no launch keys produces two further launch-evidence errors per feature through this path, even after line 331 is conditioned. A fix limited to line 331 leaves the ready gate emitting launch errors for Claude checkpoints. **The fix must condition both call sites on the same predicate.**

TS twin: `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts:341` calls `validateEpicPlannerLaunchEvidence(state, context)`. `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts:393-455` has the same per-feature loop.

### 1.3 Other Codex-only demands in the ready gate (out of scope; recorded for a follow-up)

These are not launch evidence. They remain unsatisfiable for a Claude-prepared checkpoint after this fix:

- `_validate_ready_features` (`validate_epic_planner_state.py:241-275`) runs `validate_codex_model_routing_receipts([feature.get("model_routing_receipt")])` and `_validate_child_topology_receipt(feature.get("topology_receipt"))` for every feature. A missing receipt yields `... must be an object.` (`scripts/dev_tools/_orchestrator_state_codex_model_routing.py:80`, `scripts/dev_tools/_orchestrator_state_codex_topology.py:97`).
- `_validate_planner_topology_receipt(state.get("topology_receipt"))` (`validate_epic_planner_state.py:332`) requires the forced Codex `epic-planner` topology receipt.
- The Claude epic planner's checkpoint contract (`.claude/agents/epic-planner.md:106-110`) lists no `model_routing_receipt`, `topology_receipt`, or launch keys.

The issue's expected behaviour is scoped to launch evidence ("zero launch-binding errors"), so these items are not part of the #543 fix. After this fix, the Claude-runtime ready gate is still not end-to-end passable. A follow-up issue is recommended.

### 1.4 Surfaces and plumbing

- Python CLI: the `epic-planner-state` subparser (`validate_orchestration_artifacts.py:301-312`) exposes only `path`, `--workspace-root`, and `--require-ready-for-execution`. Dispatch at lines 431-441 passes only `require_ready_for_execution` and `readiness_context`. By contrast, the `epic-orchestrator-state` subparser (lines 284-300) carries `--require-codex-model-routing` and `--require-codex-topology`, and dispatch threads them at lines 422-430.
- MCP (TypeScript, in-process): the tool schema already declares `require_codex_model_routing`, `require_codex_topology`, and `require_ready_for_execution` generically (`extensions/drm-copilot/src/mcp-tool-definitions.ts:440-454`; `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts:385-399`). `resolveValidateOrchestrationArtifactsToolInput` maps all three (`extensions/drm-copilot/src/mcp-tool-inputs.ts:460-481`). `validateOrchestrationServiceCall` forwards them (`extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts:87-101`). The only point where the Codex flags are dropped for this artifact type is the `epic-planner-state` case of `dispatchValidatorErrors` (`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:315-335`). It forwards only `requireReadyForExecution` and `readinessContext`.

---

## 2. Research Question Answers

### Q1. How #524 fixed the epic-orchestrator gate

Evidence source: `docs/features/completed/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/plan.2026-08-23T23-24.md` (tasks P3-T1 through P3-T4 are all checked), cross-checked against the current code. `git log --grep 524` was not run (no shell access).

Current predicate, `_epic_orchestrator_state_launch_binding.py:283-298`:

```python
if not (require_codex_model_routing or require_codex_topology or require_complete):
    return []
...
return _validate_launch_bindings(
    ...,
    require_generated_orchestrator=False,
    skip_not_started=not require_complete,
    require_launch_paths=not (
        require_codex_model_routing or require_codex_topology
    ),
)
```

The per-feature key gate is at lines 228-229: `if require_launch_paths and not _carries_launch_path(feature): continue`. `_carries_launch_path` (lines 202-205) is `"launch_receipt_path" in feature or "launch_status_path" in feature`. It tests key membership, so a present key with an empty or null value still arms the gate, and a partial binding still fails.

Semantics, as recorded in `.claude/rules/orchestrator-state.md:109-123` ("Epic Launch-Binding Activation Scope"):

- Unconditional under `require_codex_model_routing` or `require_codex_topology`.
- Key-gated per feature under `require_complete` alone.
- Either-key presence, so a partial binding still fails.
- No error string was added or reworded.

The #524 plan's P3-T2 left `validate_epic_planner_child_launch_bindings` at `require_launch_paths=False` explicitly. Its "Explicitly out of scope" section scoped the planner out and mandated this #543 filing.

TS port of #524: `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`:

- `featureCarriesLaunchPath`: lines 234-237, not exported.
- `LaunchBindingContext.requireLaunchPaths`: line 244.
- Skip: lines 261-263.
- Planner wrapper passes `requireLaunchPaths: false`: lines 288-298.
- Execution wrapper passes `requireLaunchPaths: options.requireCodexModelRouting !== true && options.requireCodexTopology !== true`: lines 321-323.

### Q2. Current signature and flags; MCP mapping

- Python `validate_epic_planner_state_text` accepts only `require_ready_for_execution` and `readiness_context` (lines 279-284). It accepts **no** Codex flags.
- The Python CLI `epic-planner-state` subparser accepts no Codex flags (`validate_orchestration_artifacts.py:301-312`).
- TS `ValidateEpicPlannerStateOptions` (`epic-planner-state-core.ts:51-56`) has only `requireReadyForExecution` and `readinessContext`.
- MCP: `require_codex_model_routing` and `require_codex_topology` are already accepted and carried to `validateArtifact`, but dropped at `orchestration-artifacts.ts:315-335` for `epic-planner-state`. A Codex caller could pass them today, and they would have no effect on this artifact type.

### Q3. TypeScript port

- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:430-432` carries the same unconditional call, `...validateEpicPlannerChildLaunchBindings(featureResult.features)`, inside `if (options.requireReadyForExecution === true)` (line 418).
- The TS planner wrapper is `validateEpicPlannerChildLaunchBindings` (`epic-orchestrator-state-launch-binding.ts:288-298`), with `requireGeneratedOrchestrator: true` and `requireLaunchPaths: false`.
- The second path is `epic-planner-readiness-integrity.ts:341` → `epic-planner-launch-evidence.ts:393-455`.
- Matching TS tests (verified locations):
  - `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` (twin of the Python planner launch-binding tests)
  - `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts`
  - `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`
  - `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts`
  - `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts` (the #524 twin)
  - `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` (dispatch; `threads requireReadyForExecution into epic-planner-state` at line 246)

### Q4. Callers of the epic-planner ready gate

Production callers that pass the ready flag for `epic-planner-state` (see the numeric derivation below):

| Surface | Line | Codex flags passed? |
|---|---|---|
| `.agents/skills/epic-plan/SKILL.md` | 183-185 | No. Only `require_ready_for_execution: true` and the workspace root. |
| `.agents/skills/epic-run/SKILL.md` | 24-26 | No |
| `.codex/agents/epic-orchestrator.toml` | 42-44 | No |
| Bundle mirrors of the three above under `extensions/drm-copilot/resources/codex-and-agents-customizations/` | same lines | No |

Code callers:

- `scripts/dev_tools/validate_orchestration_artifacts.py:437` (CLI dispatch)
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:334` (MCP dispatch)

`.claude/**` and `.github/**` have no ready-gate caller for `epic-planner-state`. The `.claude/**` hits for `require_ready_for_execution` are all parallel-planner (`.claude/skills/parallel-plan/SKILL.md:175,461,467,503`; `.claude/rules/parallel-orchestration.md:90-619`). This confirms the issue's "latent" claim.

By contrast, the Codex epic-orchestrator gate callers already pass both Codex flags: `.codex/agents/epic-orchestrator.toml:81-82` and `.agents/skills/epic-orchestrate/SKILL.md:169`.

**Non-regression finding:** the Codex planner-gate callers pass no Codex flag. A fix that makes launch evidence unconditional only under a Codex flag therefore moves every Codex caller into the key-gated mode unless those callers are updated:

- Codex checkpoints still carry both keys, because the Codex planner is instructed to persist the launcher receipt and status paths (`.codex/agents/epic-planner.toml:51-54`, `.agents/skills/epic-plan/SKILL.md:176-179`). Those features remain fully validated, including the generated-agent check.
- One weakening remains without caller updates: a Codex feature that omits **both** keys would be skipped silently.
- To keep Codex enforcement unconditional, the three Codex caller surfaces and their bundle mirrors must add `require_codex_topology: true` and `require_codex_model_routing: true`. This matches the epic-orchestrator convention at `.codex/agents/epic-orchestrator.toml:81-82`.

### Q5. Bundled mirrors and parity tests

- Python sources: no mirror exists. Search: Glob `**/{validate_epic_planner_state.py,_epic_orchestrator_state_launch_binding.py,epic_planner_launch_evidence.py,epic_planner_readiness.py}` returned only the four `scripts/dev_tools/` paths. A Grep for those module names under `extensions/drm-copilot/` matched only prose in `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.
- TS sources: no copies. A Glob for the four TS basenames with `.ts/.js/.cjs/.mjs` extensions returned only `extensions/drm-copilot/src/lib/validate/*`.
- No automated Python↔TS execution parity test was found for the epic planner (Grep `epic.planner|epicPlanner` in `**/*parity*` matched only `docs/` evidence files). Parity is maintained by twin tests asserting byte-identical error strings. The issue's reference to "a TypeScript/Python parity test" is not confirmed by the tree.
- Mirrored guidance files that this fix would touch:
  - `.agents/skills/epic-plan/SKILL.md` ↔ `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`
  - `.agents/skills/epic-run/SKILL.md` ↔ `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md`
  - `.codex/agents/epic-orchestrator.toml` ↔ `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`
  - Byte-identity is enforced by Pester `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:162-170` (`keeps root and tracked bundle runtime copies byte-identical`, SHA-256 comparison; RuntimePaths lines 10-34 include all three). `pack-manifests/core.json` carries no hashes (Grep `sha256|hash`: 0 matches), so no manifest update is needed.
- **Source-text contract test that pins the defect:** `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:368-403` (`test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged`). It slices `validate_epic_planner_state.py` from `"if require_ready_for_execution:"` and asserts `"validate_epic_planner_child_launch_bindings(features)" in ready_gate` (line 403). Its docstring says it leaves "#467/#543 behavior unchanged". The guard came from #614, where `spec.md:32-35,378` names #543 as sole owner of this behaviour. Any change to the call text breaks this assertion, so the assertion and docstring must be updated in this fix.

### Q6. Existing tests and file sizes

Python tests that assert launch-binding errors under `require_ready_for_execution`:

- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`:
  - `test_launch_evidence_is_required_only_for_execution_readiness` (lines 93-113) pops all five binding keys, including both launch path keys, and asserts `features[0] launch binding.branch_name` and `...delegation_receipt must be an object` errors with no Codex flag. **This test pins the defect and fails after the fix.** It must be rewritten: keep the assertions under a Codex flag, and add the key-gated counterpart.
  - `test_rejects_invalid_branch_or_launch_path`, `test_rejects_invalid_delegation_binding` (including `agent_name` → `must name a generated orchestrator agent.`), `test_rejects_invalid_model_receipt_binding`, and `test_requires_unique_branch_and_delegation_identifiers` keep both launch keys present, so they are expected to pass unchanged under key gating.
  - `test_complete_launch_evidence_reaches_repository_context_gate`: unchanged.
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py`: `_ready_state` features carry launch keys (lines 32, 58-59). `test_ready_checkpoint_passes_execution_readiness` (line 87) is expected to be unaffected. `test_cli_dispatches_planner_readiness_flag` (lines 329-360) uses a stub whose signature is exactly `(_text, *, require_ready_for_execution=False, readiness_context=None)`. It would raise `TypeError` only if the CLI dispatch began passing new keyword arguments (see the §3 CLI decision).
- `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py`: no test deletes a launch key and asserts the missing-path error (Grep for `must identify a launch artifact` across `tests/**` and `extensions/drm-copilot/test/**`: 0 matches). Expected to be unaffected with a default of "validate all".
- `tests/scripts/dev_tools/test_epic_planner_readiness.py`: fixtures carry launch evidence. Expected to be unaffected.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:403`: see Q5. Must change.

TS tests that pin the defect:

- `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts`, `it("activates only for execution readiness")` (lines 93-120): the direct twin of the Python test above. Must be rewritten the same way.

Line counts (Grep `^` count; 500-line limit):

| File | Lines | Headroom note |
|---|---|---|
| `scripts/dev_tools/validate_epic_planner_state.py` | 354 | ample |
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | 298 | ample |
| `scripts/dev_tools/epic_planner_launch_evidence.py` | 345 | ample |
| `scripts/dev_tools/epic_planner_readiness.py` | 371 | ample |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | **495** | two argparse flags plus threading would exceed 500 |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | 460 | ~40 lines |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` | 325 | ample |
| `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts` | 455 | ~45 lines |
| `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts` | 364 | ample |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 363 | ample |
| `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | 224 | ample |
| `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py` | 271 | ample |
| `tests/scripts/dev_tools/test_validate_epic_planner_state.py` | 360 | ample |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | 416 | edit is in place |
| `tests/scripts/dev_tools/test_epic_planner_readiness.py` | 491 | **do not add tests here** |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` | 220 | ample |
| `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts` | 223 | ample |
| `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts` | 495 | **do not add tests here** |
| `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` | **508** | already over the limit; **do not add tests here** |
| `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` | 166 | suitable home for a dispatch-threading test |
| `.agents/skills/epic-plan/SKILL.md` | 230 | Markdown (exempt) |
| `.agents/skills/epic-run/SKILL.md` | 39 | Markdown (exempt) |
| `.codex/agents/epic-orchestrator.toml` | 96 | under the Pester 500-line check (`codex-epic-runtime-contracts.Tests.ps1:172-183`) |

---

## 3. Candidate Approaches

### A. Codex-flag-or-key gate on both launch-evidence call sites; thread Codex flags through the TS/MCP route; update Codex callers (Recommended)

Description:

- Add `require_codex_model_routing` and `require_codex_topology` to the planner validator in both runtimes.
- Compute `key_gated = not (require_codex_model_routing or require_codex_topology)`.
- Pass `require_launch_paths=key_gated` to `validate_epic_planner_child_launch_bindings`. Pass the same value to `validate_epic_planner_launch_evidence` through `validate_epic_readiness_integrity`.
- Thread the flags in the TS `epic-planner-state` dispatch case.
- Update the three Codex caller surfaces and their mirrors to pass both flags.

Advantages:

- Implements both disjuncts of the issue's expected behaviour: Codex flag, or feature carries launch keys.
- Mirrors #524 exactly, including either-key presence and partial-binding failure.
- Codex enforcement stays unconditional once callers pass the flags.
- The MCP schema and input plumbing already carry the flags, so the change is confined to the dispatch case.

Limitations:

- Touches the Codex guidance files and their byte-identical mirrors.
- The Python CLI cannot gain the flags without exceeding 500 lines (see below).

### B. Key gate only; no new flags (Rejected)

Condition both call sites with `require_launch_paths=True` unconditionally. This is smaller, but it drops the Codex-flag disjunct the issue requires. It also silently weakens Codex enforcement for a feature missing both keys, and there is no way for a caller to restore unconditional mode.

### C. Remove launch evidence from the planner ready gate (Rejected)

This deletes a Codex safety property that the Codex planner contract depends on (`.agents/skills/epic-plan/SKILL.md:176-181`). It also contradicts the #524 precedent that a partial binding must still fail.

### Recommendation: Approach A, with these explicit decisions

1. **`require_generated_orchestrator` stays `True` for every feature that is validated.** A feature is validated only when a Codex flag is asserted or it carries a launch key. Launch keys have exactly one production writer, the Codex launcher (`.claude/rules/orchestrator-state.md:113`). So every validated feature has Codex provenance, and the Codex-generated agent-name restriction is correct for it. A Claude feature carries no launch keys and is never reached. This also keeps Codex-produced checkpoints validated exactly as today even if a Codex caller omits the flag. The issue asked for this policy question to be answered explicitly: the planner launch-binding surface is Codex-only by provenance, and activation (not the agent-name rule) is what becomes scoped.
2. **Python CLI flags are deferred.** `validate_orchestration_artifacts.py` is at 495 lines. No production caller uses the Python CLI for `epic-planner-state`; all three Codex callers go through the MCP (TS) route. Without the flags, Python CLI callers get the key-gated mode, which is the correct Claude-runtime behaviour. Record this asymmetry in the spec as a deliberate deviation. If the planner requires CLI parity, it must pair the addition with a line-neutral extraction. That would be an additional scoped refactor, not part of the minimal fix.
3. **No `.claude/rules/*.md` edit.** The existing "Epic Launch-Binding Activation Scope" section describes the epic-orchestrator gate only and is not made false by this change. Editing a policy rule file requires explicit authorization (#524 recorded one; #543 has none).
4. **No error string is added, removed, or reworded** in either runtime.

---

## 4. Behaviour Semantics (target)

Under `require_ready_for_execution=True`:

| Case | Codex flag asserted | Feature launch keys | Launch-binding + launch-evidence result |
|---|---|---|---|
| Claude-prepared feature | no | neither key | skipped; zero launch errors from either call site |
| Codex-prepared feature | no | both keys | validated as today, including the generated-agent check |
| Partial binding | no | one key only | validated; the absent key yields its existing error |
| Any feature | yes | any | validated for every feature (current behaviour) |

Without `require_ready_for_execution`, nothing changes; launch validation never ran there.

Ordering and indexing: the skip is applied per feature inside the existing loops, so the error prefix `Epic planner checkpoint features[{index}] ...` keeps the original index. Filtering the list before the call would renumber indices and must not be used.

Shared-status rule (`epic_planner_launch_evidence.py:320-327`): a skipped feature contributes no status path, so "must share one launch_status_path" compares only among validated features.

---

## 5. Requirements Mapping: files to write

Production (Python):

1. `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`
   - Add keyword `require_launch_paths: bool = False` to `validate_epic_planner_child_launch_bindings` and forward it. Keep `require_generated_orchestrator=True`.
   - Expose a public predicate, for example `feature_carries_launch_path`, for reuse. `_carries_launch_path` can delegate to it or be renamed with its caller updated.
2. `scripts/dev_tools/epic_planner_launch_evidence.py`
   - Add keyword `require_launch_paths: bool = False` to `validate_epic_planner_launch_evidence`.
   - In the loop after the `_is_record` check (line 310), add `if require_launch_paths and not feature_carries_launch_path(item): continue`.
3. `scripts/dev_tools/epic_planner_readiness.py`
   - Add keyword `require_launch_paths: bool = False` to `validate_epic_readiness_integrity` and forward it at line 354.
4. `scripts/dev_tools/validate_epic_planner_state.py`
   - Add keyword-only `require_codex_model_routing: bool = False` and `require_codex_topology: bool = False`.
   - In the ready block, compute `key_gated`. Pass `require_launch_paths=key_gated` at line 331 and at line 346.

Production (TypeScript):

5. `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`
   - Export `featureCarriesLaunchPath`.
   - Add an optional `options: { requireLaunchPaths?: boolean } = {}` (or a boolean parameter) to `validateEpicPlannerChildLaunchBindings` and forward it.
6. `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts`
   - Add an optional `requireLaunchPaths` parameter and the same per-feature skip after `isRecord` (line 405).
7. `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts`
   - Add an optional `requireLaunchPaths` parameter to `validateEpicReadinessIntegrity` and forward it at line 341.
8. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`
   - Add `requireCodexModelRouting?` and `requireCodexTopology?` to `ValidateEpicPlannerStateOptions` (lines 51-56).
   - Compute the key gate and pass it at lines 430-432 and 450-454.
9. `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`
   - Thread `requireCodexModelRouting` and `requireCodexTopology` in the `epic-planner-state` case (lines 315-335), following the conditional-spread pattern at lines 306-311.

Codex guidance (byte-identical pairs):

10. `.agents/skills/epic-plan/SKILL.md` (lines 183-185) and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`: add `require_codex_topology: true` and `require_codex_model_routing: true` to the `epic-planner-state` invocation.
11. `.agents/skills/epic-run/SKILL.md` (lines 24-26) and its bundle mirror: same edit.
12. `.codex/agents/epic-orchestrator.toml` (lines 42-44) and its bundle mirror: same edit.

The guidance edits must keep the existing Pester regexes in `codex-epic-runtime-contracts.Tests.ps1:106-116` matching. Those assertions target other phrases and are not affected by an additive flag mention.

Tests (Python):

13. `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`
    - Rewrite `test_launch_evidence_is_required_only_for_execution_readiness` so the error assertions run with `require_codex_topology=True`.
    - Add `test_ready_gate_skips_launch_binding_for_feature_without_launch_paths`. Pop `branch_name`, `worktree_path`, `delegation_receipt`, `launch_receipt_path`, and `launch_status_path` from one feature to produce the Claude shape. Assert no error contains `" launch binding"`.
    - Add `test_ready_gate_rejects_partial_launch_binding`. Pop only `launch_status_path`. Assert the launch-binding errors equal exactly `["Epic planner checkpoint features[0] launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/."]`.
    - Add `test_codex_flag_keeps_launch_binding_unconditional`, parametrized over each Codex flag.
14. `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py`
    - Add a test that `validate_epic_planner_launch_evidence(state, context, require_launch_paths=True)` returns no errors for a feature whose two launch keys are removed.
    - Add a test that a partial key still yields the `launch status path must identify a launch artifact in this repository.` error.
15. `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`
    - Update line 403 to assert the new call text, for example `"validate_epic_planner_child_launch_bindings(\n"` or the exact new literal.
    - Update the docstring at line 369 so it no longer claims #543 behaviour is unchanged.

Tests (TypeScript):

16. `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts`: twins of item 13. The partial-binding string must be byte-identical to the Python assertion.
17. `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts`: twins of item 14.
18. `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (166 lines): add one test proving that `requireCodexTopology` reaches the `epic-planner-state` route. Do **not** add it to `orchestration-artifacts.test.ts`, which is already at 508 lines.

Not changed:

- `scripts/dev_tools/validate_orchestration_artifacts.py`: CLI flags deferred (495 lines).
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py`: its CLI stub is unaffected while the CLI is unchanged.
- MCP tool definitions: already declare the flags.
- `.claude/**` and `.github/**`.
- `jest.config.cjs`: no new threshold entry is required, because only existing files change. `orchestration-artifacts.ts` keeps its existing 85/75 entry at lines 77-80.

---

## 6. Testing Implications and Commands

Commands the executor should run. None were run in this session.

Python targeted run (dotted `--cov`; a `.py` path measures nothing):

```
poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_launch_evidence.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov=scripts.dev_tools._epic_orchestrator_state_launch_binding --cov=scripts.dev_tools.epic_planner_launch_evidence --cov=scripts.dev_tools.epic_planner_readiness --cov-branch --cov-report=term-missing
```

Regression-first node ids:

- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_ready_gate_skips_launch_binding_for_feature_without_launch_paths`. It must fail before the fix, because the current code emits launch-binding errors for that feature.

Whole-suite Python gate, as used by #524:

```
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing
```

TypeScript, run from `extensions/drm-copilot/`:

- Targeted, without `--coverage`, because per-file `coverageThreshold` entries fail a subset run:

  ```
  node run-jest.cjs test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-launch-evidence.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/epic-orchestrator-state-launch-binding.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts
  ```

- Full coverage run:

  ```
  node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary
  ```

PowerShell (byte-identity of the guidance mirrors):

```
Invoke-Pester tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
```

This can also run through the repository's PoshQC route. PoshQC MCP results carry no output text, so no numeric claim should be planned from them.

Scenario coverage required by policy:

- Positive: a Claude shape with no keys passes the launch portion.
- Negative: partial binding; Codex flag with a keyless feature.
- Boundary: key present with an empty string or null value still arms the gate.
- Unchanged Codex path: the existing parametrized invalid-field tests.

---

## 7. Numeric Derivation Evidence

Numeric claim: the number of production caller surfaces that invoke the `epic-planner-state` ready gate. This is proposed only as research context, not as a spec acceptance criterion.

- Complete Family: every non-`docs/` file instructing or implementing a `validate_orchestration_artifacts` call for `epic-planner-state` with the ready flag.
- Exhaustive Search Scope: `.codex/**`, `.agents/**`, `.github/**`, `.claude/**`, `extensions/drm-copilot/resources/**`, `scripts/**`, `extensions/drm-copilot/src/**`.
- Inclusion Rules: a guidance or code site that invokes or dispatches the planner validator with the ready flag.
- Exclusion Rules: tests, `docs/`, and parallel-planner references.
- Primary Search Strategy: Grep `epic-planner-state` restricted to `{.codex,.agents,.github,.claude,extensions/drm-copilot/resources}/**`, keeping the validate-invocation lines.
- Primary Member Set: `.agents/skills/epic-run/SKILL.md:24`, `.agents/skills/epic-plan/SKILL.md:183`, `.codex/agents/epic-orchestrator.toml:42`, plus their three bundle mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/` (same lines).
- Primary Count: 6 guidance sites (3 root, 3 mirror).
- Cross-check Search Strategy: Grep `require-ready-for-execution|requireReadyForExecution|require_ready_for_execution|RequireReadyForExecution` over the whole tree excluding `docs/**`, filtered to non-test, non-parallel production and guidance files.
- Cross-check Member Set: `.agents/skills/epic-run/SKILL.md:25`, `.agents/skills/epic-plan/SKILL.md:184`, `.codex/agents/epic-orchestrator.toml:43`, and the mirrors at the same lines. Code dispatch sites `scripts/dev_tools/validate_orchestration_artifacts.py:433-439` and `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:317-319` are counted separately as code callers.
- Cross-check Count: 6 guidance sites.
- Member-set Comparison: the normalized sets (file identity) are identical: the same three root files and three mirrors. The line offset of +1 arises because the flag text wraps to the following line. `.claude/**` and `.github/**` contribute zero members in both searches.

---

## 8. Automation Feasibility

No human interaction is required. Every change is a source, test, or guidance edit plus deterministic tool runs: pytest, jest, Pester, formatters, and linters. There is no external-service or credential dependency. The single judgment call, keeping `require_generated_orchestrator=True`, is resolved in §3 with evidence. The Python CLI deferral is a recorded scope decision that the planner can adopt without user input.

---

## 9. Follow-up (outside #543 scope)

File a separate issue. After this fix, the epic-planner ready gate still requires Codex-only per-feature `model_routing_receipt` and `topology_receipt` and a top-level forced `topology_receipt` (`validate_epic_planner_state.py:241-275, 332`). The Claude epic planner does not write any of these (`.claude/agents/epic-planner.md:106-110`), so the Claude-runtime ready gate remains unsatisfiable end to end if any Claude surface begins passing `require_ready_for_execution`.
