# Correction: root cause of the V3 miss (P1-T3)

Timestamp: 2026-11-15T18-51
Command: pwsh -NoProfile -File artifacts/scratch-issue-1188/probe-seg.ps1 (dot-sources each surface's gate and prints `Test-ImplementationCommand`, the `Read-CommandLineSegment` records, and `Test-OrchestrationGateInvocationConfirmed -PatternIndex 2` and `-PatternIndex 3` for `npm --prefix $(pwd) run lint`)
EXIT_CODE: 0
Output Summary: `Test-ImplementationCommand` returns False; the scanner yields three records, `npm --prefix ` (delimiter `$(`), `pwd` (delimiter `)`), and ` run lint`; stage 2 returns True for index 2 and for index 3.

Corrects: `fail-before-v3.2026-11-14T22-09.md` (not edited; this file is the append-only correction).

The earlier record attributed the V3 miss to stage 2 (`Test-OrchestrationGateInvocationConfirmed` dropping the stage-1 hit). That attribution is wrong. Stage 1 of `Test-ImplementationCommand` matches its patterns per `Read-CommandLineSegment` scan segment, and the scanner splits the unquoted `$(` word into `npm --prefix `, `pwd`, and ` run lint`. No segment holds both `npm` and the script word `lint`, so the npm pattern (index 2) never matches and stage 2 is never reached. `Test-OrchestrationGateInvocationConfirmed` returns True for every pattern index of this command. The quoted form `npm --prefix "$(pwd)" run lint` is one scan segment and is classified, which is why the quoted V3 row denied while the unquoted one was allowed.

Remediation R1 classifies the unquoted form through the joined-word supplement of `enforce-orchestration-preimplementation-gate-classify.ps1`, after which `Get-OrchestrationGateCommandTargetOperand` returns `Unresolved` and the gate denies `TARGET_WORKTREE_NOT_DERIVABLE` before any listing or checkpoint read.
