# Kickoff Sweep Before (Fail-Before) - Remediation Cycle 2 (Issue 1080)

Timestamp: 2026-11-06T00-34
Command: sh SCRATCH/issue-1080-kickoff-sweep.sh issue-1080-r2-p0t6.log
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Fail-before confirmed against the unchanged parser. SWEEP-FILES=9 SWEEP-ROWS=71 SWEEP-EMPTY-PLAN=9 SWEEP-ERRORS=0. Phantom rows with an empty plan path (issues 0, 1, 2 from the wave-summary table) appear in exactly the three kickoffs named by CR-1.

## Printed output

```
KICKOFF docs/features/epics/claude-runtime-portability/epic-kickoff.md rows=4 empty-plan=0 issues=598,596,597,599
KICKOFF docs/features/epics/cleanup-merged-worktrees-hardening/epic-kickoff.md rows=11 empty-plan=3 issues=630,631,632,545,633,635,634,637,0,1,2
KICKOFF docs/features/epics/enforcement-hook-precision/epic-kickoff.md rows=8 empty-plan=0 issues=565,736,824,732,787,850,737,786
KICKOFF docs/features/epics/legacy-discovery-and-parity/epic-kickoff.md rows=14 empty-plan=0 issues=360,359,361,362,363,365,364,366,367,368,369,370,372,371
KICKOFF docs/features/epics/orchestrator-state-contract-correctness/epic-kickoff.md rows=8 empty-plan=3 issues=405,464,509,523,484,0,1,2
KICKOFF docs/features/epics/parallel-orchestration/epic-kickoff.md rows=8 empty-plan=0 issues=447,445,444,443,441,442,440,446
KICKOFF docs/features/epics/push-down-payload-correctness/epic-kickoff.md rows=4 empty-plan=0 issues=507,763,508,621
KICKOFF docs/features/epics/subagentstop-envelope/epic-kickoff.md rows=4 empty-plan=0 issues=897,905,896,903
KICKOFF docs/features/epics/worktree-scoped-state-resolution/epic-kickoff.md rows=10 empty-plan=3 issues=669,670,671,675,672,673,674,0,1,2
SWEEP-FILES=9 SWEEP-ROWS=71 SWEEP-EMPTY-PLAN=9 SWEEP-ERRORS=0
EXIT_CODE=1
```

## Assessment

- `empty-plan` is above 0 for `docs/features/epics/cleanup-merged-worktrees-hardening/epic-kickoff.md` (3), `docs/features/epics/orchestrator-state-contract-correctness/epic-kickoff.md` (3), and `docs/features/epics/worktree-scoped-state-resolution/epic-kickoff.md` (3), and 0 for the other six files.
- `SWEEP-ERRORS=0`, as expected: no repository kickoff has a non-feature numeric-first row that aborts the parser.
- Baseline values for P1-T4: `SWEEP-ROWS=71`, `SWEEP-EMPTY-PLAN=9`. The expected pass-after `SWEEP-ROWS` is 71 - 9 = 62.
