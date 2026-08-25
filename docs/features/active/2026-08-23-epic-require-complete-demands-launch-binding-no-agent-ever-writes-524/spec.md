# 2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes (Spec)

- **Issue:** #524
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug

## Context

The epic-orchestrator-state completion gate demands a per-feature launch binding whose `launch_receipt_path` and `launch_status_path` resolve under `artifacts/orchestration/epic-child-launches/`. On the Claude runtime no producer writes that directory, so the gate emits five errors per feature and cannot pass, however clean the epic run was. Two separate epics in a destination repository recorded the failure rather than closed it, which is the correct operator response and is also proof the gate is unsatisfiable there.

A gate that cannot pass carries no information: it fails identically for a complete run and a broken one, so it cannot distinguish them. The observed operator workaround — record and proceed — is the harm, because a genuine completion defect now arrives indistinguishable from the standing errors.

Environment:

- OS/version: Windows 11 Pro 10.0.26200
- Reported command/flags: epic completion validation with `require_complete`, via the MCP `validate_orchestration_artifacts` surface and the completion hook.
- Data source: destination repository `drmoisan/TaskMaster`, epics `quickfiler-suite-determinism-foundation` and `build-ci-coverage-gate-fidelity`.

Correction to the issue's own environment note, recorded here because a later reader would otherwise trust it: the issue attributes the failing surface to the portable PowerShell validators under `.claude/lib/orchestrator-state/`. Research verified that a content search across the whole `.claude/` tree for `launch_binding`, `launch_receipt_path`, `launch_status_path`, `epic-child-launches`, and `LaunchBinding` returns zero matches. Those PowerShell modules implement no part of this gate, and there is no Pester coverage of it, so the PowerShell runtime is unaffected by this bug and by its fix. The failing surface on the Claude side is the MCP TypeScript validator shipped in the VS Code extension; the authoritative logic is the Python module in `scripts/dev_tools/`.

Impact / Severity:

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High rather than Blocker: it blocks no merge and breaks no build, because operators record the failure and proceed.

## Repro & Evidence

Steps to reproduce:

1. Run an epic to completion: children prepared, executed, fanned in, final PR merged, `epic-status.md` current.
2. Validate the epic-orchestrator-state checkpoint with `require_complete`.
3. Read the error list.
4. Look for `artifacts/orchestration/epic-child-launches/` on disk, and search the epic-orchestrator agent and skill for any write to it.

Expected: an epic whose features all reached a terminal state, whose final PR merged, and whose status document is current satisfies `require_complete`.

Actual: `require_complete` fails with 21 errors on `quickfiler-suite-determinism-foundation`. One is a genuine finding (a deliberately descoped child). The other 20 are five per feature across four features. The earlier `build-ci-coverage-gate-fidelity` epic produced 25 errors in the same repository. Plain validation without `require_complete` passes in both cases, which isolates the gate as the sole source.

The five errors per feature, enumerated from the Python source:

| # | Error | Cause |
| --- | --- | --- |
| 1 | `worktree_path` must be a non-empty canonical absolute path | `_is_canonical_worktree_path` requires a pure-backslash Windows path; a checkpoint written with forward slashes fails |
| 2 | `launch_receipt_path` must be under `artifacts/orchestration/epic-child-launches/` | key absent |
| 3 | `launch_status_path` must be under `artifacts/orchestration/epic-child-launches/` | key absent |
| 4 | `delegation_receipt` must be an object | key absent; short-circuits three sub-checks |
| 5 | `model_routing_receipt` must be an object | key absent; short-circuits three sub-checks |

Evidence qualification: the destination checkpoints were not available to the research session, so the attribution of the fifth error to `worktree_path` rather than to `branch_name` is an **inference**, not a verified reading. It is the stronger inference because `branch_name` is in the documented Claude epic feature schema while the canonicality predicate for `worktree_path` rejects any value containing a forward slash once a drive letter is present. The count is five either way, because exactly one of the two path-shape checks fires. Nothing in the fix depends on which one it is.

## Scope & Non-Goals

In scope:

- The activation condition of `validate_epic_child_launch_bindings` in `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`.
- The behaviourally identical activation condition in the TypeScript parity port `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`.
- Unit tests for both runtimes.
- A prose record of the corrected activation scope in `.claude/rules/orchestrator-state.md` and its byte-identical bundle twin.

Out of scope / non-goals:

- **The epic planner surface.** `scripts/dev_tools/validate_epic_planner_state.py` calls `validate_epic_planner_child_launch_bindings` unconditionally inside its `require_ready_for_execution` block, and that helper additionally sets `require_generated_orchestrator=True`, restricting `agent_name` to five Codex-generated persona names that do not exist in the Claude runtime. This is the same defect shape but is **latent**: neither `.claude/agents/epic-planner.md` nor `.claude/skills/epic-plan/SKILL.md` mentions `require_ready_for_execution`, so no Claude skill or agent passes the flag and no symptom reproduces. It is explicitly excluded from issue #524 and must be filed as a separate issue. Folding it in would widen the diff to the planner validator, its TypeScript core, and four further test files without a reproducing symptom to verify against.
- Changing what the Codex runtime enforces. The Codex epic orchestrator passes both Codex flags, and under either flag the gate stays unconditional and byte-identical to today.
- Any change under `.claude/lib/orchestrator-state/`, which implements none of this gate.
- Any change to `.claude/hooks/validate-orchestrator-output.ps1`, which for the epic artifact type performs a structural check only and never passes `require_complete`.
- Any change to `.codex/**`, `.agents/**`, the MCP tool definitions, or `scripts/dev_tools/validate_orchestration_artifacts.py`. The epic subparser already carries and dispatches all three flags.
- Making the gate always pass. A change that removes the ability to fail is worse than the current state.

Explicitly excluded systems: PowerShell validators and their Pester suites; the Codex launcher `.codex/scripts/launch-epic-child-wave.ps1` and its attestation hook.

## Root Cause Analysis

### Defect site

`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`, in `validate_epic_child_launch_bindings`:

```python
if not (require_codex_model_routing or require_codex_topology or require_complete):
    return []
```

`require_complete` is the generic completion flag every runtime passes. Admitting it into what is otherwise a Codex-specific activation set made Codex-only launch evidence a universal completion requirement. The following statement, `skip_not_started=not require_complete`, then removes the only escape hatch: under `require_complete` even a feature whose `merge_status` is `not_started` is subjected to the full five-check set.

The TypeScript port reproduces both statements exactly, which is why the defect is present on the MCP surface as well.

### Why no producer exists on the Claude runtime

The evidence the gate demands has exactly one production writer: `.codex/scripts/launch-epic-child-wave.ps1`. It computes the wave status path and the per-child receipt path under the launch root, writes the receipt with an exclusive-create write before the child OS process starts, and hands the receipt path to the child only through the environment. `.codex/hooks/codex-epic-child-launch-attestation.ps1` then reads that receipt from inside the running child and requires exact equality across three path pairs and seven identity pairs.

The Claude `epic-orchestrator` starts children in-process through the `Agent` tool with worktree isolation. There is no launcher script, no environment handoff, and no attestation hook. Its documented checkpoint-persistence instruction lists `features[]` with `merge_status` and four lifecycle timestamps plus the three top-level receipt arrays, and names no launch receipt, no per-feature `delegation_receipt`, and no per-feature `model_routing_receipt`. A search of the entire `.claude/` tree for the launch-binding identifiers returns zero matches.

The gate therefore cannot pass on the Claude runtime, and no Claude-side producer change can make it pass without introducing self-attestation.

### What the launch binding was intended to prove

Git history was unavailable to the research session, and no feature folder under `docs/` documents the introduction of this requirement; `.claude/rules/orchestrator-state.md` is silent about the epic checkpoint entirely. The original epic specification documents `require_complete` as exactly two conditions — every feature `merged` or `worktree_removed`, and a non-empty `epic_merge_pr.merge_commit_sha` — with no launch binding, which places the launch-binding extension after that specification.

The intent below is therefore **reconstructed from the consumer, and is labelled inference rather than verified history**: the launch binding proves a cross-process binding that `delegation_receipts[]` structurally cannot. The receipt is written to disk by a launcher before the child process starts, handed to the child only through the environment, and verified from inside the child by a hook the child does not control, making it an independent witness that a specific process, in a specific worktree, under a specific agent-profile hash, model, and reasoning effort, corresponds to a specific delegation id. `delegation_receipts[]` is written by the orchestrator into the orchestrator's own checkpoint after the fact and carries agent names only; it is self-attestation.

On the strongest available inference, the launch binding was designed for the Codex epic runtime, where children are separate OS processes and the binding problem is real. On the Claude runtime the binding the receipt exists to prove is supplied by the `Agent` tool itself. The defect is that the activation condition admitted the generic completion flag rather than restricting the gate to the two Codex-specific flags that accompany the runtime where the producer lives.

## Proposed Fix

### Design summary (what changes where)

Scope the gate to evidence a producer actually writes:

- Under `require_complete` **alone**, validate a feature's launch binding **only when that feature carries `launch_receipt_path` or `launch_status_path`**.
- Under `require_codex_model_routing` or `require_codex_topology`, the gate remains unconditional and byte-identical to today, including the existing `skip_not_started` behaviour.

This is the key-gated additive pattern already documented several times in `.claude/rules/orchestrator-state.md` for `remediation_loop`, `human_interaction`, `complexity_assessments`, `model_routing_receipts`, and the `require_model_routing` mode: the block applies only when the checkpoint carries the key, and is otherwise byte-identical to a plain call.

The per-feature presence test is deliberately **either key**, not both. A checkpoint that records a partial launch binding re-arms the full five-check set and still fails, which is what distinguishes this fix from a plain removal of `require_complete` from the activation set.

### Rejected alternatives (recorded so they are not reopened)

- **Make `epic-orchestrator` write the launch receipt.** Rejected. On the Claude runtime the same agent would write both the receipt and the checkpoint it is checked against, so the artifact is self-attestation and proves nothing that `delegation_receipts[]` does not. The Codex receipt derives its value from being written by a separate launcher process and verified from inside the child; that cross-process structure does not exist for an in-process `Agent` delegation. It would also require the agent to synthesise six coupled fields specified only in validator code, with no producer-side test — the same prose-to-validator drift that produced this bug.
- **Point the gate at `delegation_receipts[]`.** Rejected on discriminating power. That top-level array has no per-feature key, so a per-feature cross-check against it reduces to a single boolean for the whole epic that is true for every epic that ever delegated anything. That is the always-passes property the issue explicitly identifies as worse than the status quo.
- **Remove `require_complete` from the activation set outright, with no presence gate.** Not rejected on correctness — it fixes the defect and touches the same files — but rejected as second-best, because it discards the residual discrimination the presence gate retains for a Codex checkpoint validated with `require_complete` alone.

### Boundaries and invariants to preserve

- `_validate_completion` still fails on any feature not `merged` or `worktree_removed` and on a missing or empty `epic_merge_pr.merge_commit_sha`.
- The wave-barrier invariant, `merge_status` enum membership, dependency-cycle rejection, `waves[]` consistency, the bounded concurrency cap, and the required-key set all run unconditionally and are untouched.
- Behaviour under either Codex flag is unchanged, including the `skip_not_started` filter and every parametrised shape, uniqueness, and mismatch case.
- Error strings remain byte-identical between the Python module and the TypeScript port.
- The default remains off: with no flag set, the gate returns no errors.

### Dependencies or blocked work

None. The change is self-contained within two validator modules, their tests, and one rule file plus its bundle twin.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

Production:

- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` — authoritative logic.
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` — parity port; identical error strings for identical inputs.
- `.claude/rules/orchestrator-state.md` — add a short section recording that the epic launch-binding block is unconditional under the Codex enforcement flags and key-gated under `require_complete`.
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` — byte-identical mirror of the preceding file, required in the same commit or `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` fails.

Tests:

- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts`

#### Functions/classes/CLI commands impacted

- Python `validate_epic_child_launch_bindings` (activation condition and per-feature applicability).
- Python `_validate_launch_bindings` (receives the per-feature applicability decision; the existing `skip_not_started` parameter is retained unchanged).
- TypeScript `validateEpicChildLaunchBindings` and its shared per-feature loop.
- No CLI surface changes. `scripts/dev_tools/validate_orchestration_artifacts.py` already carries and dispatches all three flags.

#### Data flow and validation changes

The checkpoint shape is unchanged. No key is added, renamed, or removed. The only change is which features the existing checks are applied to, under one flag combination.

#### Error handling and logging updates

None. No new error string is introduced; existing strings are unchanged in text and in ordering.

#### Rollback/feature-flag considerations

No feature flag. The change is a behavioural narrowing of one gate under one flag; rollback is a revert of the two production modules and their tests.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

Both entry points keep their present signatures: a parsed checkpoint mapping plus three boolean keyword flags, returning a list of error strings. Neither mutates its input. A non-list `features` value continues to return no errors.

#### Required configuration keys and defaults

None. All three flags continue to default to false.

#### Backward-compatibility expectations

- A checkpoint validated with no flag produces a byte-identical result to today.
- A checkpoint validated with either Codex flag produces a byte-identical result to today.
- A checkpoint validated with `require_complete` alone that carries at least one launch path key on a feature produces a byte-identical result to today for that feature.
- Only the case of a feature carrying neither launch path key under `require_complete` alone changes, and only by producing fewer errors.

#### Performance constraints

None. Both modules are pure functions over in-memory JSON with no I/O; the change adds one per-feature key lookup.

## Assumptions, Constraints, Dependencies

Assumptions:

- The destination checkpoints exhibiting the 21-error and 25-error results are not available in this repository; regression evidence must be produced from constructed fixtures that reproduce the destination shape (a four-feature epic with no launch path keys).
- The attribution of the fifth per-feature error to `worktree_path` is an inference (see Repro & Evidence). No acceptance criterion depends on it.
- The reconstruction of the launch binding's original intent is an inference from its Codex consumer, not verified history.

Constraints:

- Parity between the Python module and the TypeScript port is byte-identical error strings, per the parity obligation stated in the `orchestration-artifacts.ts` module docstring.
- `.claude/**` files and their bundle twins under `extensions/drm-copilot/resources/claude-customizations/.claude/` must be byte-identical.
- `quality-tiers.yml` is absent from the repository root, so the uniform thresholds of `.claude/rules/quality-tiers.md` apply with no tier-specific overlay: line coverage at or above 85 percent and branch coverage at or above 75 percent for both Python and TypeScript.
- Evidence artifacts are written under the feature folder's `evidence/` tree per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: none. The MCP `validate_orchestration_artifacts` input schema, its property-key set, and the `require_complete` description are unchanged.
- Data or migration considerations: none. No checkpoint field is added, removed, or reinterpreted.
- Logging/telemetry updates: none.
- Compatibility notes: no CLI flag, config schema, or version change. The fix reaches a destination repository when the destination updates the VS Code extension; no destination-side `.claude` edit is involved, so no push-down sync destroys it.

## Test Strategy

Both changed modules are pure functions over in-memory JSON text, so every case is a unit test with no filesystem access, no clock, and no temporary files, per `.claude/rules/general-unit-test.md`.

Four scenario groups, covered in both runtimes with byte-identical error strings:

1. **Positive, Claude shape.** A completion-ready checkpoint whose features carry neither `launch_receipt_path` nor `launch_status_path` returns an empty error list under `require_complete` alone. This is the destination reproduction.
2. **Positive, Codex shape.** A completion-ready checkpoint carrying full launch bindings returns an empty error list under `require_complete` alone and under each Codex flag, proving the change is a no-op for a well-formed Codex checkpoint.
3. **Negative, partial binding.** A checkpoint carrying `launch_receipt_path` but missing `launch_status_path` still fails under `require_complete` alone. This is what keeps the presence gate from becoming an exemption.
4. **Negative, genuine incompleteness.** A checkpoint whose feature is not `merged` or `worktree_removed`, and separately one with an absent `epic_merge_pr.merge_commit_sha`, still fail under `require_complete`. The existing tests carrying this must be left intact; they are the evidence that the fix did not make the gate always pass.

Tests that must change:

- Python `test_require_complete_requires_binding_for_every_feature` asserts the defect as intended behaviour and must be replaced by a presence-gated pair.
- TypeScript `requires evidence for every feature under requireComplete` is its direct twin and must be replaced the same way.

Tests that must remain unmodified and passing:

- Python `test_model_routing_gate_accepts_complete_launch_binding`, `test_topology_gate_activates_launch_binding_validation`, `test_unlaunched_feature_does_not_require_binding_under_routing_gate`, `test_launch_binding_is_dormant_without_an_enforcement_gate`, `test_require_complete_accepts_complete_persisted_binding`, `test_require_complete_rejects_unmerged_feature`, `test_require_complete_rejects_missing_merge_commit_sha`, `test_require_complete_remains_disabled_by_default`, and every parametrised case using a Codex flag.
- TypeScript `accepts complete evidence under the model-routing gate`, `activates under the topology gate`, `does not require evidence before the feature launches`, `remains dormant without a routing or completion gate`, `accepts complete persisted evidence at completion`, `rejects requireComplete when a feature is not merged/worktree_removed`, `rejects requireComplete when epic_merge_pr.merge_commit_sha is missing`, `accepts a fully complete checkpoint under requireComplete`, and `defaults requireComplete to false (backward-compatible)`.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` builds a fully-populated epic fixture including both launch paths, so the gate stays armed for it and its expectations are unchanged.

Regression evidence: validate a constructed four-feature epic checkpoint with no launch path keys before and after the change, recording the launch-binding error count in each run; and validate a variant with one deliberately unmerged feature, recording that it produces exactly one completion error in both runs.

Toolchain: format, lint, type-check, architecture-boundary, unit, contract, integration — repeated until all stages pass in a single pass, per `.claude/rules/general-code-change.md`.

## Acceptance Criteria

- [x] A new Python test in `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` asserts that `validate_epic_child_launch_bindings` returns an empty list for a checkpoint whose features carry neither `launch_receipt_path` nor `launch_status_path`, when called with `require_complete=True` and both Codex flags left at their defaults.
  - Evidence: test `test_require_complete_skips_feature_without_launch_paths`; passing run recorded in `evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md`.
- [x] A new Jest test in `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts` asserts the same empty result for the same checkpoint shape under `requireComplete` alone.
  - Evidence: test `skips launch binding for a feature with no launch paths under requireComplete`; passing run recorded in `evidence/regression-testing/preserved-typescript-tests.2026-08-24T22-56.md`.
- [x] A new Python test asserts that a feature carrying `launch_receipt_path` but omitting `launch_status_path` still produces the `launch_status_path` launch-artifact error under `require_complete` alone, so a partial binding is not exempted.
  - Evidence: test `test_require_complete_rejects_partial_launch_binding`; passing run recorded in `evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md`.
- [x] A new Jest test asserts the same partial-binding failure and its error string is byte-identical to the string the Python test asserts.
  - Evidence: test `rejects a partial launch binding under requireComplete`; passing run recorded in `evidence/regression-testing/preserved-typescript-tests.2026-08-24T22-56.md`. Both runtimes assert `Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.`
- [x] The Python test `test_require_complete_requires_binding_for_every_feature` no longer asserts that a feature with no launch evidence fails under `require_complete` alone, and the Jest test `requires evidence for every feature under requireComplete` no longer asserts the same, so no test pins the defect as intended behaviour.
  - Evidence: `git grep -n -F "test_require_complete_requires_binding_for_every_feature" -- tests/ scripts/` and `git grep -n -F "requires evidence for every feature under requireComplete" -- extensions/` both return no match (exit 1).
- [x] The Python tests `test_model_routing_gate_accepts_complete_launch_binding`, `test_topology_gate_activates_launch_binding_validation`, and `test_unlaunched_feature_does_not_require_binding_under_routing_gate` pass with no change to their bodies, and every parametrised rejection case that supplies `require_codex_model_routing=True` passes unmodified.
  - Evidence: `evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md` (50 passed, 0 failed).
- [x] The Jest tests `accepts complete evidence under the model-routing gate`, `activates under the topology gate`, and `does not require evidence before the feature launches` pass with no change to their bodies.
  - Evidence: `evidence/regression-testing/preserved-typescript-tests.2026-08-24T22-56.md` (46 suites, 885 tests passed, 0 failed).
- [x] The Python test `test_require_complete_accepts_complete_persisted_binding` and the Jest test `accepts a fully complete checkpoint under requireComplete` pass with no change to their bodies, confirming a well-formed Codex-shaped checkpoint is unaffected.
  - Evidence: `evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md` and `evidence/regression-testing/preserved-typescript-tests.2026-08-24T22-56.md`.
- [x] The Python tests `test_require_complete_rejects_unmerged_feature` and `test_require_complete_rejects_missing_merge_commit_sha` pass with no change to their bodies, and are named in the completion report as the evidence that the completion gate can still fail on a genuinely incomplete epic.
  - Evidence: `evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md`; corroborated at fixture level by `evidence/regression-testing/after-one-unmerged.2026-08-24T23-05.md` (exit 1, one completion error preserved).
- [x] The Jest tests `rejects requireComplete when a feature is not merged/worktree_removed` and `rejects requireComplete when epic_merge_pr.merge_commit_sha is missing` pass with no change to their bodies, as the TypeScript half of the same discrimination guarantee.
  - Evidence: `evidence/regression-testing/preserved-typescript-tests.2026-08-24T22-56.md`.
- [x] The Python tests `test_launch_binding_is_dormant_without_an_enforcement_gate` and `test_require_complete_remains_disabled_by_default`, and the Jest tests `remains dormant without a routing or completion gate` and `defaults requireComplete to false (backward-compatible)`, all pass unmodified.
  - Evidence: `evidence/regression-testing/preserved-python-tests.2026-08-24T22-52.md` and `evidence/regression-testing/preserved-typescript-tests.2026-08-24T22-56.md`.
- [x] `.claude/rules/orchestrator-state.md` gains a section stating that the epic launch-binding validation is unconditional under the two Codex enforcement flags and key-gated per feature under `require_complete`, and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` is updated so that `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
  - Evidence: `git grep -n -F "Epic Launch-Binding Activation Scope"` matches line 85 of both files; contract-test run recorded in `evidence/other/push-down-contract-verification.2026-08-24T22-45.md`.
- [x] A regression artifact under the feature folder's `evidence/regression-testing/` directory records validation of a constructed four-feature epic checkpoint carrying no launch path keys, showing 20 launch-binding errors before the change and 0 after, and records that a variant with one deliberately unmerged feature produces exactly one completion error in both runs.
  - Evidence: `evidence/regression-testing/launch-binding-regression.2026-08-24T23-06.md`, citing the four per-run artifacts.
- [ ] The diff touches only the four production files and two test files named in the Implementation strategy section; in particular `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `.claude/lib/orchestrator-state/`, `.claude/hooks/validate-orchestrator-output.ps1`, `.codex/`, and `.agents/` are unmodified.
  - Remaining: awaiting the [P6-T11] scope-verification run; this criterion is ticked only against that artifact.
- [x] A separate GitHub issue is filed for the latent `require_ready_for_execution` launch-binding defect in `scripts/dev_tools/validate_epic_planner_state.py`, and its issue number is recorded in this spec's Rollout section.
  - Evidence: issue #543 (https://github.com/drmoisan/drm-copilot/issues/543); local record `evidence/issue-updates/planner-followup-issue.2026-08-24T23-07.md`; number recorded in `## Rollout & Follow-up` above.
- [ ] The full seven-stage toolchain completes without errors in a single pass, and coverage for the two changed production modules is at or above 85 percent line and at or above 75 percent branch with no regression on changed lines.
  - Remaining: awaiting the Phase 6 final QA loop ([P6-T1] through [P6-T9]) and the [P6-T10] coverage-delta verification; this criterion is ticked only against those artifacts.

## Risks & Mitigations

Technical and operational risks:

- **Over-narrowing.** A presence test written as "both keys present" instead of "either key present" would exempt a partial Codex binding and reduce discriminating power. Mitigated by the dedicated partial-binding acceptance criteria in both runtimes.
- **Parity drift.** The Python module and the TypeScript port are hand-maintained twins, not a generated copy. Mitigated by requiring byte-identical error strings in the new tests on both sides.
- **Push-down desynchronisation.** Amending the rule file without updating the bundle twin fails the resource-contract test. Mitigated by making the twin update an explicit acceptance criterion.
- **Silencing a genuine finding.** The integration expectation is that the launch-binding errors disappear while the one genuine descoped-child error remains. Mitigated by preserving the four negative-path tests unmodified and by the regression artifact recording the single completion error in both runs.
- **Latent planner defect misread as fixed.** The planner-side gate is out of scope and remains defective. Mitigated by the explicit scope statement and by the separate-issue acceptance criterion.

Mitigations and rollback: the change is a behavioural narrowing of one conditional in each runtime; rollback is a revert of the two production modules, their tests, and the rule-file pair.

## Rollout & Follow-up

- Release/rollout: the fix reaches destination repositories through a VS Code extension update, since the failing surface there is the MCP TypeScript validator. No destination-side edit is required and no push-down sync destroys it.
- Post-fix verification: re-validate the two destination epic checkpoints (`quickfiler-suite-determinism-foundation` and `build-ci-coverage-gate-fidelity`) with `require_complete` after the extension update. The expected result is that the 20 and 25 launch-binding errors disappear while the single genuine descoped-child error on `quickfiler-suite-determinism-foundation` remains.
- Follow-up: the planner-surface issue described in Scope & Non-Goals is filed as **issue #543** (https://github.com/drmoisan/drm-copilot/issues/543), titled `Bug: epic-planner-ready-gate-demands-codex-only-launch-binding`. Local record: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/issue-updates/planner-followup-issue.2026-08-24T23-07.md`.
- Links: issue #524 (https://github.com/drmoisan/drm-copilot/issues/524); observed-in destination issue drmoisan/TaskMaster#598; research artifact `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/research/2026-08-23T23-45-epic-launch-binding-gate-research.md`.
