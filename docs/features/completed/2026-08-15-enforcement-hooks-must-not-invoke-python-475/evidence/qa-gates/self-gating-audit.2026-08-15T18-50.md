# Self-Gating Audit — [P15-T10] (AC-29 audit leg)

Timestamp: 2026-08-15T18-50

Command:

- Clause (a): `Get-FileHash -Algorithm SHA256` recomputed over each audited file in the final tree, compared line by line against the `Gate Hashes:` blocks recorded in the Phase 2/4/5/6/7/8/9 verification evidence artifacts.
- Clauses (b) and (c): `git diff b1a86fd3 -- <paths>`, `git diff --stat b1a86fd3 -- <paths>`, and `git diff --name-only b1a86fd3`, using the pre-run HEAD `b1a86fd3` as the single git baseline. This run creates no intermediate commits, so `git log -p` carries no in-run history and was not relied on.

EXIT_CODE: 0

Output Summary: **PASS on all three clauses. Zero accommodation changes.** Clause (a): 13 of 13 audited files byte-identical to their green verification gates — zero hash deltas, so the A5 formatting carve-out is not exercised. Clause (b): the Phase 10-11 edits are exactly the planned changes of `[P10-T2]` and `[P11-T2]`; zero checks removed, zero error strings weakened, zero thresholds relaxed. Clause (c): reconciliation touched only `artifacts/orchestration/orchestrator-state.json`, and the failing check IDs are recorded verbatim in the `[P10-T6]` and `[P11-T5]` evidence artifacts.

## The Invariant, Quoted Verbatim

> **The reconciliation branch corrects the checkpoint, never the check.**

If a newly enforced check fails against real checkpoint state, that is the gate working
correctly, not a defect in the check. The only permitted response is to correct
`artifacts/orchestration/orchestrator-state.json` and record the failing check IDs in the
phase's evidence artifact. Adjusting a check to accommodate the checkpoint, weakening a row to
make this run pass, or relaxing a threshold is PROHIBITED. Rationale: a validator that a run
edits to let itself through is worse than no validator — it certifies compliance while
enforcing nothing.

## Clause (a) — Parity Modules Byte-Identical Between Their Green Gates and the Final Tree

Thirteen files audited: the eleven new parity modules named in the Module Decomposition, the
extended `OrchestratorStateCompletion.psm1`, and `OrchestratorStateCheckpointValue.psm1` (the
sibling helper created under the pre-authorized production split, which also carries recorded
gate hashes).

| # | File | Gate (recording artifact) | Gate hash | Final-tree hash | Match |
| --- | --- | --- | --- | --- | --- |
| 1 | `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | `[P2-T8]` | A8E5F295…FDD3 | A8E5F295…FDD3 | YES |
| 2 | `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | `[P4-T6]` | 59D0C480…9D5D | 59D0C480…9D5D | YES |
| 3 | `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | `[P4-T6]` | 798B6761…FBEA | 798B6761…FBEA | YES |
| 4 | `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` | `[P6-T6]` (supersedes `[P4-T6]`) | F23A9E29…69AF | F23A9E29…69AF | YES |
| 5 | `.claude/lib/codex-routing/CodexDeployment.psm1` | `[P5-T6]` | BDDEACA7…DAA2 | BDDEACA7…DAA2 | YES |
| 6 | `.claude/lib/codex-routing/CodexTopology.psm1` | `[P5-T6]` | 3DAC4066…B520 | 3DAC4066…B520 | YES |
| 7 | `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` | `[P6-T6]` | EB4B21F2…BE72 | EB4B21F2…BE72 | YES |
| 8 | `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` | `[P6-T6]` | B4695143…75AF | B4695143…75AF | YES |
| 9 | `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` | `[P7-T6]` | 20D33729…CA91 | 20D33729…CA91 | YES |
| 10 | `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | `[P7-T6]` | C7825018…8777 | C7825018…8777 | YES |
| 11 | `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | `[P8-T4]` | D5A41B64…66CE | D5A41B64…66CE | YES |
| 12 | `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | `[P9-T6]` | 6AE47AAE…9112 | 6AE47AAE…9112 | YES |
| 13 | `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` (extended) | `[P9-T6]` | 34207535…EB67 | 34207535…EB67 | YES |

**Hash deltas: 0 of 13.**

### Superseding Note on `OrchestratorStateCheckpointValue.psm1`

This module was hashed twice because Phase 6 extended it: `[P4-T6]` recorded
`E8E34115…CFF2` and `[P6-T6]` recorded `F23A9E29…69AF`. **The `[P6-T6]` value supersedes the
`[P4-T6]` value**, and the final tree matches the `[P6-T6]` value exactly. The `[P4-T6]` value
is superseded by a planned Phase 6 extension, not by an accommodation change.

### A5 Formatting Carve-Out — Not Exercised

The carve-out permits a hash delta **attributable to the `[P15-T1]` formatting pass**, as named
in that task's own evidence artifact, to be recorded as a formatting normalization rather than
an accommodation change. `[P15-T1]` changed **zero files** — its changed-file list is empty,
independently confirmed by modification times (newest PowerShell file mtime `18:10:27`, format
run at ~`18:21`) and by re-hashing. **No hash delta exists, so no attribution is required and
the carve-out is not exercised.** The stricter reading holds trivially: any delta would have
had no formatting attribution and would have triggered the halt path.

### Additional Corroboration — `OrchestratorState.psm1`

`OrchestratorState.psm1` is not one of the thirteen clause-(a) files; it falls under clause (b)
as a Phase 11 planned edit. For completeness: `[P9-T6]` recorded its post-Phase-9 hash as
`EC3E366F…D288` and the final tree is `204B9882…81D4`. That delta is fully attributable to
`[P11-T2]`, the planned preflight collapse and probe deletion, which is audited under clause
(b) below.

## Clause (b) — Phase 10-11 Edits Are Exactly the Planned Changes

`git diff --stat b1a86fd3 --` over the two files:

```
 .claude/hooks/validate-orchestrator-output.ps1     | 163 +++++++++++++++------
 .../lib/orchestrator-state/OrchestratorState.psm1  | 125 ++++++++--------
 2 files changed, 175 insertions(+), 113 deletions(-)
```

### What Was Removed

Inspection of every removed line in both files shows the deletions are confined to:

1. The Python capability probe `Test-PythonOrchestratorValidatorAvailable` — its definition,
   its `& python -c 'import scripts.dev_tools.validate_orchestration_artifacts'` body, and its
   export entry. This is `[P11-T2]` clause (b), planned.
2. The `& python -m scripts.dev_tools.validate_orchestration_artifacts ... --require-complete
   --require-model-routing` leg in `Invoke-RoutingContractValidation`. This is `[P10-T2]`,
   planned.
3. The `& python -m ... --require-pr-creation-ready` leg in
   `Invoke-OrchestratorStatePreflight`. This is `[P11-T2]` clause (a), planned.
4. The `if (Test-PythonOrchestratorValidatorAvailable) { ... } else { ... }` branch scaffolding
   around both legs, collapsing each to the single portable path.
5. Doc-comment prose describing the removed Python behavior, plus two `$names = @($State.PSObject.Properties.Name)`
   lines refactored into the `OrchestratorStateCheckpointValue.psm1` helper.

### What Was NOT Removed — the Accommodation Test

| Probe | Result |
| --- | --- |
| Removed lines matching an error-string template (`Checkpoint (missing\|has\|completion\|delegation\|model_routing\|complexity\|PR-creation\|local_execution\|root\|file)`) | **0** |
| Check rows removed relative to the 85-row inventory mapping in the `[P13-T1]` parity-coverage artifact | **0** — that artifact maps 85/85 rows to an implementation and a test, with 0 unmapped and 0 deferred |
| Error strings weakened | **0** |
| Thresholds relaxed | **0** — `CoveragePercentTarget` unchanged; no coverage target removed; no blocking-status set narrowed |
| `[scriptblock] $Invoker` seams retained | YES on both `Invoke-RoutingContractValidation` and `Invoke-OrchestratorStatePreflight` |
| `Test-HumanInteractionShape` (stricter hook-internal check) | byte-unchanged, still runs for all artifact types |
| Four verdict prefixes | unchanged (`[P15-T9]` clause (d)) |

Strictness moved in one direction only: `[P10-T2]` replaced a presence-level portable fallback
with the complete-parity `Test-OrchestratorStateCompletionReadiness`, and `[P11-T2]` added the
`Get-OrchestratorStateUnconditionalError` block to the preflight path. The completion gate
enforces 79 more checks after this change than before it, and the `[P10-T6]` reconciliation
record shows those checks firing against real checkpoint state and being honored rather than
softened.

### Full Tracked-Change Inventory vs `b1a86fd3` (non-`docs/`)

21 tracked files changed. Every one is accounted for by a named plan task:

| File(s) | Plan task |
| --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `validate-discovery-artifact-gate.ps1` | `[P3-T2]`, `[P3-T3]` |
| `.claude/hooks/validate-orchestrator-output.ps1` | `[P10-T2]` |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | `[P11-T2]` |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | `[P9-T4]` |
| 5 files under `extensions/.../claude-customizations/.claude/` | `[P12-T2]`, `[P12-T3]` mirror batches |
| `extensions/.../pack-manifests/core.json` | `[P12-T8]` |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror | `[P2-T7]`, `[P4-T6]`, `[P5-T6]`, `[P6-T6]`, `[P7-T6]`, `[P8-T4]`, `[P9-T6]` coverage-target registration |
| 5 test files under `tests/scripts/claude-hooks/` | `[P3-T4]`, `[P10-T3]`, `[P10-T4]`, `[P11-T4]` |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | `[P11-T3]` |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1` | `[P9-T5]` |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | `[P12-T9]` |

No unplanned file was modified.

## Clause (c) — Reconciliation Touched Only the Checkpoint

`artifacts/orchestration/orchestrator-state.json` is untracked by git in this worktree
(`git ls-files --error-unmatch` reports it is not known to git), so a `git diff` baseline is
unavailable for the checkpoint itself. The audit therefore establishes clause (c) by the
complementary route, which is sufficient and stronger:

1. **Nothing else was touched.** The complete tracked-change inventory above is 21 files, each
   attributable to a named plan task. No file outside that set was modified during
   reconciliation.
2. **The failing check IDs are recorded verbatim** in the two reconciliation phases' evidence
   artifacts, as the invariant requires.

### `[P10-T6]` — 42 failures, partitioned and recorded

**Class A (shape failures, checkpoint corrected):** `U2` missing required keys `relativeFile`,
`long-name`, `work-mode`; `U5.1`-`U5.8` `delegation_receipts` shape (28 errors across receipts
#0-#3); `C6.4`-`C6.6` routing-contract declared lists; `C6.11` `delegation_bypasses` absent;
`C6.9` missing `validate_orchestration_artifacts` MCP receipt. Each was fixed **in the
checkpoint**, never in the check. A data-fabrication guard was applied: keys whose values this
run does not actually record were set to `null` (U5 tests key presence, mirroring the Python
`key not in receipt` test) rather than invented, and `collect_pr_context` was deliberately NOT
fabricated because no independent evidence existed for it.

**Class B (completion-state failures, left standing):** 11 checks reporting that the run is not
finished — `step6_status`/`step7_status`/`step10_status` pending, `pr_gate` and `ci_gate`
absent (no PR exists; the run's stop condition forbids creating one), missing `feature-review`
and `pr-author` agent receipts, missing `pr-context-artifacts` and
`pr-base-branch-merge-base` skill receipts, missing `collect_pr_context` MCP receipt, and
`local_execution_overrides must be empty at completion`.

### The Standing `local_execution_overrides` Item — Correctly Left Standing

The check `Checkpoint local_execution_overrides must be empty at completion.` (and its
PR-readiness analogue `Checkpoint PR-creation readiness validation failed:
local_execution_overrides must be an empty list when present.`) fails because `LEO-1` — the
batch-budget reset — is a **real, declared, coordinator-approved override**, sanctioned by the
hook's own remedy at `.claude/hooks/enforce-powershell-batch-budget.ps1:137`.

This audit confirms the correct handling was applied at every point:

- The override record was **not deleted**. Deleting it would falsify the checkpoint and is
  exactly the accommodation the invariant prohibits.
- The check was **not weakened**. `Get-CompletionEmptyListError` in
  `OrchestratorStateRoutingContract.psm1` retains both message variants and the present-key
  semantics of Python `C6.10`/`C6.11`, and `Get-OrchestratorStatePrCreationReadinessError`
  in `OrchestratorState.psm1` is unchanged.
- The failure is **recorded** in both `[P10-T6]` and `[P11-T5]` evidence artifacts and is
  reported at plan completion. Its reconciliation is the orchestrator's at run completion, not
  the executor's mid-run.

### `[P11-T5]` — preflight reconciliation

The Phase 11 preflight run reported the same `local_execution_overrides` item plus the U2/U5
defects already corrected under `[P10-T6]`. No check was adjusted. All listed suites returned
green and the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` prefix is unchanged.

### Mid-Run Incompleteness Is Not an Accommodation Trigger

Every Class B failure is the accurate report of an unfinished run. Per the governing
directive, a `--require-complete` failure stating that phases are incomplete or a step status
is still pending is the expected state for a run in progress: it is neither an accommodation
trigger nor a halt condition. No case arose in which a failure could not be resolved either by
correcting the checkpoint or by correctly classifying it as completion state, so the halt path
was never entered.

## Verdict

| Clause | Finding |
| --- | --- |
| (a) parity modules byte-identical between green gates and the final tree | **PASS** — 13/13 match, 0 hash deltas, A5 carve-out not exercised |
| (b) Phase 10-11 edits are exactly the planned changes | **PASS** — 0 checks removed, 0 error strings weakened, 0 thresholds relaxed; 21/21 tracked changes attributable to named tasks |
| (c) reconciliation modified only the checkpoint, failing check IDs recorded | **PASS** — no non-checkpoint file touched by reconciliation; all failing check IDs recorded verbatim in `[P10-T6]` and `[P11-T5]` |

**Zero accommodation changes were found. The self-gating audit passes.**

Scope note: this audit covers AC-29 — that no check, row, or threshold was adjusted to let
this run pass. It is independent of the coverage-floor finding recorded in `[P15-T8]`, which
is a genuine floor failure left standing and reported rather than accommodated. That finding
is itself evidence of compliance with this invariant: the floor was not relaxed to make the
run pass.
