# QA Gate — Aggregation and Completion Wiring (P9-T6) — Issue #475

Timestamp: 2026-08-15T23-30

Command:

1. `mcp__drm-copilot__run_poshqc_format` with `scan_folders: [".claude/lib/orchestrator-state", "tests/scripts/claude-lib/orchestrator-state"]`
2. `mcp__drm-copilot__run_poshqc_analyze` with the same narrowing
3. `Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib/orchestrator-state') -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`
4. Regression scope for the shared module change:
   `Invoke-PoshQCTest ... -ScanFolders @('tests/scripts/claude-hooks')`
5. Coverage capture across the whole library surface:
   `Invoke-PoshQCTest ... -ScanFolders @('tests/scripts/claude-lib')`

`scan_folders` is narrowed on every invocation so the guard's repository-scan `It`s —
legitimately red from Phase 1 until Phase 11 — are not pulled into this gate.

EXIT_CODE: 0

Output Summary:

- **Format**: clean and idempotent on re-run (zero files changed on the second pass).
- **Analyze**: 0 findings.
- **Tests**:
  - orchestrator-state library folder: **373 passed, 0 failed, 0 skipped** (twelve suites).
  - claude-hooks regression scope: **774 passed, 0 failed, 0 skipped**. This scope was
    run because the shared `OrchestratorState.psm1` was hardened in this phase (see
    below) and both the PR-author preflight and the completion hook consume it.
  - whole claude-lib scope: **864 passed, 0 failed, 0 skipped**.
  - New in this phase: 24 `It`s in `OrchestratorStateUnconditional.Tests.ps1` and 13
    added to `OrchestratorStateCompletion.Tests.ps1` (M2, PD-2 single emission, M3
    reuse, and complete-parity composition).
- **Coverage** (read from `artifacts/pester/powershell-coverage.xml`, not inferred from
  the exit code):

| File | Metric | Covered | Missed | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | LINE | 28 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | INSTRUCTION | 43 | 0 | 100.00% | — | — |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` (extended) | LINE | 96 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` (extended) | INSTRUCTION | 156 | 2 | 98.73% | — | — |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` (hardened) | LINE | 103 | 3 | 97.17% | >= 85% | Met |

Branch coverage is NOT emitted by this toolchain (Pester 5's JaCoCo exporter records no
`BRANCH` counter), established with proof in
`evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md`. No threshold is relaxed.

File sizes are within the 500-line cap: `OrchestratorStateUnconditional.psm1` 166 lines,
`OrchestratorStateCompletion.psm1` 432 lines (from 243),
`OrchestratorStateCompletion.Tests.ps1` 469 lines (from 184). `OrchestratorState.psm1`
remains at 497 lines; the hardening was line-neutral by design, since that file is at the
cap and Phase 11 must still fit its own edits.

## Gate Hashes:

SHA-256 for every production module verified by this gate. These are the baseline
reference points P15-T10 compares against.

```
.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 = 6AE47AAEEF39315D46FB41CB875046D929C4A8235834281647E1B5827B379112
.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 = 342075359C450CA7A581841851E7CED325E0EFC2EBA052E9A2780F1CE2D3EB67
.claude/lib/orchestrator-state/OrchestratorState.psm1 = EC3E366FBB43FB27C9563ED8C4E335C22BECFA6A50378581B2186385226BD288
```

The third module is not one this task creates, but it was modified here (see the hardening
note) so its post-Phase-9 hash is recorded for P15-T10.

## Parity Coverage — the U-family aggregation and the M family

`Get-OrchestratorStateUnconditionalError` composes, in the Python reference's order:
base presence (U2-U4), delegation receipts (U5), then the six key-gated optional families
(U6.R, U6.H, U6.C, U6.M, U6.X, U6.T). Its suite pins three properties:

1. **Every family surfaces** through the single entry point — one fixture per family, six
   in total, plus a multi-family fixture.
2. **Key-gated semantics hold** — an absent optional key contributes zero errors and never
   produces a "must be a list when present" message, while a PRESENT key holding null IS
   validated. Both directions are asserted, for two different families.
3. **A fully valid checkpoint yields zero errors.**

`Test-OrchestratorStateCompletionReadiness` is now the complete-parity completion
validation. Rows added in this phase:

| Row | Check | Fixtures |
| --- | --- | --- |
| M2.1 | complexity assessment missing for a matched receipt phase | wrong-phase, absent-array, unmatched-receipt-does-not-require, and a passing fixture |
| M3 | per-entry re-validation of U6.C and U6.M | two reuse assertions, below |

## PD-2 single emission — implemented as the spec records it

The Python reference emits each U6.C and U6.M per-entry error TWICE under the hook's flag
pair: once in the unconditional block and again inside the model-routing gate's M3 re-run.
This port emits each string exactly once.

The M3 reuse requirement is satisfied by INVOKING the same per-entry validator
implementation, not by re-emitting its output:
`Get-OrchestratorStateModelRoutingGateError` calls
`Get-OrchestratorStateModelRoutingReceiptError` and
`Get-OrchestratorStateComplexityAssessmentError` from `OrchestratorStateModelReceipts.psm1`,
key-gated exactly as the Python gate is. The entry point then merges the gate's output
through `Add-OrchestratorStateErrorOnce`, which appends only strings the accumulated result
does not already carry.

Three fixtures pin the divergence:

- a malformed `model_routing_receipts` entry produces its exact error string exactly once
  under the completion call;
- a malformed `complexity_assessments` entry likewise;
- a checkpoint failing several families at once produces zero duplicate lines anywhere in
  the output.

Two further fixtures pin the reuse: each per-entry validator is mocked inside the
`OrchestratorStateCompletion` module scope, the mocked sentinel string is proved to reach
the completion output, and `Should -Invoke ... -Times 1 -Exactly` confirms the gate calls
it. A re-implementation would ignore the mock and fail both.

## Two defects found and fixed, not worked around

**1. Empty-collection parameter binding.** `Add-OrchestratorStateErrorOnce` rejected an
empty accumulated list, because PowerShell's mandatory-parameter validation treats an empty
collection as unbound. Fixed with `[AllowEmptyCollection()]`. Without it, every clean
checkpoint would have thrown at the M-family merge.

**2. Strict-mode throw on a zero-property checkpoint.** `OrchestratorState.psm1` enumerated
`$State.PSObject.Properties.Name` in three places. Under `Set-StrictMode -Version Latest`
that expression throws `The property 'Name' cannot be found on this object` when the object
carries zero properties, so a checkpoint of exactly `{}` produced a terminating error
instead of the 22 missing-required-key errors the contract requires. The aggregation made
the defect reachable and a Phase 9 test caught it.

Fixed by projecting the names one property at a time
(`@($State.PSObject.Properties | ForEach-Object { $_.Name })`) at all three sites. The edit
is line-neutral, so `OrchestratorState.psm1` stays at 497 lines and Phase 11 retains its
margin under the 500-line cap. The fix hardens the fail-closed path rather than weakening
any check, and the whole claude-hooks scope (774 tests) was re-run to confirm no regression
in the PR-author preflight or the completion hook.

## Declared consequence — the existing completion fixture had to become contract-compliant

`Test-OrchestratorStateCompletionReadiness` changed from a presence-level subset to
complete parity, so a checkpoint that reaches `ExitCode 0` must now satisfy the whole C
family as well. The pre-existing fixture builder in `OrchestratorStateCompletion.Tests.ps1`
declared `path_selected = 'short'`, which is not a routing-matrix route, and carried no
required-list declarations, no skill or MCP receipts, and no `ci_gate`. Under complete
parity that checkpoint is correctly rejected.

Only fixture DATA was brought up to the contract; **no assertion in that file was changed,
weakened, or removed**. The builder now produces a compliant `remediation`-route
checkpoint (smallest required set, no `pr_gate` needed). One `It` — the delegation-free
case asserting `ExitCode 0` — additionally switched its `delegation_receipts` to the object
namespace form, which still evidences every required agent for the routing contract while
contributing zero delegated agents to the model-routing gate, so the behaviour under test
is exercised unchanged and the `ExitCode 0` assertion still holds. This follows the
"correct the checkpoint, never the check" principle applied to test data.

## Acceptance

- Suites green: yes (373/373 in the gate scope, 774/774 in the regression scope, 864/864
  across the library surface; zero failures anywhere).
- Numeric coverage recorded from the coverage XML: yes (100.00% line on both the new
  module and the extended completion module; 97.17% on the hardened shared module).
- Floors met: line floor met with at least 12.17 points of headroom on every file; branch
  unmeasurable by this instrument, recorded with proof.
- `Gate Hashes:` block present with one SHA-256 line per production module verified by
  this gate: yes (three lines).
