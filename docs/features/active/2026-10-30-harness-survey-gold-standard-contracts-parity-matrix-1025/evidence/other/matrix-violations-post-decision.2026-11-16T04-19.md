# Matrix Violations After Decisions (P1-T3)

Timestamp: 2026-11-16T04-19
Command: pwsh -NoProfile -File SCRATCH/issue-1025-matrix-results.ps1 (plan B `## Decision Application Rules` rules 4 to 9; PlanAMatrix read with git show <PlanBStart>:config/harness-parity-matrix.json, PlanBStart from the latest phase0b-branch-snapshot.*.md; writes config/harness-parity-matrix.json; counts the ten counters over the written matrix; Get-HarnessParityMatrixViolation against Get-HarnessInventory of the live tree)
EXIT_CODE: 0
Output Summary: 655 entries: approved 339, provisional 316 (deferred runbook 314, pending-source 2); Violations 0; every counter 0: True.

PlanBStart source: evidence/baseline/phase0b-branch-snapshot.2026-11-16T03-56.md

Runbooks:
- E1: deferred (rules 4 to 8 change no value)
- E2: deferred (rules 4 to 8 change no value)
- E3: deferred (rules 4 to 8 change no value)
- E4: deferred (rules 4 to 8 change no value)
- E6: deferred (rules 4 to 8 change no value)

Violations: 0
Approved: 339
Provisional: 316
Provisional (deferred runbook): 314
Provisional (pending-source): 2

UnsettledWithoutReason: 0
SettledNotApproved: 0
DeferredRefMismatch: 0
OverrideDispositionMismatch: 0
NativeOverrideWithTargets: 0
NativeOverrideUnsettled: 0
DroppedOverrideMismatch: 0
E3DispositionMismatch: 0
ConsumersMismatch: 0
NotesMismatch: 0
