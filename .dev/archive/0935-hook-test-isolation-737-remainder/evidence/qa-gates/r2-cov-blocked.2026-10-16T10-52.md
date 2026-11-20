# R2 COV-1 BLOCKED Record (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T10-52
Task: [P3-T1]
Route source: `FEATURE/evidence/other/r2-cov-investigation.2026-10-16T10-51.md` (`COV-1-ROUTE: BLOCKED`; `COV-1-INVESTIGATION-OUTCOME: REPRODUCED-U2-DOES-NOT-RESTORE`)
Trigger units: taken from the `RESTORES` lines of P2-T6 to P2-T9 (`U1: NO-EFFECT`; `U4: RESTORES`; U3 and U5 skipped by plan rule).

COV-1-BLOCKED: root cause outside the write set; likely mechanism (per #936 research, not experimentally verified): Pester 5 single-hit line breakpoints bound to the first compiled instance of .claude/lib/worktree-resolution/WorktreeResolution.psm1, with scripts/powershell/PoshQC/settings/pester.runsettings.psd1 setting no UseBreakpoints key; trigger units: U4; reason: REPRODUCED-U2-DOES-NOT-RESTORE

No code file was edited for COV-1. `git status --porcelain -- tests .claude .codex scripts config`: empty.
