# R3 COV-1 Status (P3-T5)

Timestamp: 2026-10-16T15-15
Terminal: T-U4-NO-LONGER (`evidence/other/r3-cov-bisection.2026-10-16T14-13.md`)
TARGET: 142 (TARGET-SOURCE: lib-only; `evidence/other/r3-cov-n0-lib-only.2026-10-16T12-50.md`)
FIX-ORDER: FX-1, FX-2, FX-23 (`evidence/qa-gates/r3-cov-fix-order.2026-10-16T14-25.md`)
HEAD-REPO-RUN (N1): returned (`evidence/other/r3-cov-n1-head.2026-10-16T13-08.md`)

Trial lines:
- TRIAL-1: FX-1 FIX-NOT-RESTORED (`evidence/qa-gates/r3-cov-fix-trial-1.2026-10-16T14-39.md`; covered 127)
- TRIAL-2: FX-2 FIX-NOT-RESTORED (`evidence/qa-gates/r3-cov-fix-trial-2.2026-10-16T14-56.md`; covered 127)
- TRIAL-3: FX-23 FIX-NOT-RESTORED (`evidence/qa-gates/r3-cov-fix-trial-3.2026-10-16T15-15.md`; covered 127)

Condition evaluation:
- S1 TERMINAL-NOT-MEASURED: terminal is T-U4-NO-LONGER -> does not hold.
- S2 TERMINAL-NOT-REPRODUCED: terminal is T-U4-NO-LONGER -> does not hold.
- S3 CANDIDATE-RESTORED: no trial recorded FIX-RESTORED -> does not hold.
- S4 HEAD-REPO-RUN-RAISED: N1 records `HEAD-REPO-RUN: returned` -> does not hold.
- S5 NO-CANDIDATE-RESTORED: the order was not NONE and no trial recorded FIX-RESTORED -> holds.

COV-1-STATUS-CONDITIONS: NO-CANDIDATE-RESTORED
COV-1-STATUS: human_decision_required (NO-WRITE-SET-CANDIDATE-RESTORES)

COV-1-TRIGGER: not localised (T-U4-NO-LONGER)
COV-1-MECHANISM: not identified (no Write Set candidate restored or no local reproduction); suspected location: Pester 5 breakpoint binding and the PowerShell script-block cache, outside the Write Set

## Basis

- At the merged head (after `origin/main` was merged at `1d364d0c1`), the local repo-scope run reproduces the loss: `WorktreeResolution.psm1` covered 127 against TARGET 142 (lib-only run 142, 30 of 30 listed lines credited).
- Reverting every U4 subset the tree reached, and all nine U4 paths together (N5), leaves covered at 127. The cycle-2 observation that the U4 revert restores 142 (`evidence/other/r2-cov-iso-u4.2026-10-16T10-50.md`) predates the merge and does not hold at the merged head.
- None of the three fixed Write Set candidates (FX-1, FX-2, FX-23) changed the per-file value (127 in each trial).
- The trigger is therefore not localised to a Write Set file at the merged head. The mechanism is not identified by this cycle; the suspected mechanism remains the one recorded in the #936 research (`## Root Cause`, status "likely, not experimentally verified").

## Decision options (human decision required)

1. Accept the attribution loss against AC-24.
2. Authorize `CodeCoverage.UseBreakpoints = $false` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its extension mirror.
3. Authorize a change outside the Write Set, such as a claude-lib suite.

The `COV-1-STATUS-CONDITIONS:` line does not include `HEAD-REPO-RUN-RAISED`, so no N1 error text and no resolve-the-failing-suite option apply.

`git status --porcelain -- tests`: empty.
