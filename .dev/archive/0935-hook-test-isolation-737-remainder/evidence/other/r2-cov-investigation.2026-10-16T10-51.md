# R2 COV-1 Investigation Derivation (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T10-51
Task: [P2-T10]
Derivation: `COV-1 Investigation Derivation` of `FEATURE/remediation-plan.2026-10-16T07-55.md`, applied to the Phase 2 run artifacts below.

## Phase 2 runs

| Task | Artifact | Unit set (reverted to `b6be46b5e`) | Validity | `WorktreeResolution.psm1` covered | credited (of 30) | Classification |
|---|---|---|---|---|---|---|
| P2-T1 | `r2-cov-lib-only.2026-10-16T09-33.md` | none; scan `tests/scripts/claude-lib/worktree-resolution` only | VALID | 142 | 30 | H0 input |
| P2-T2 | `r2-cov-head.2026-10-16T09-49.md` | none (HEAD) | VALID | 127 | 18 | covered_HEAD |
| P2-T3 | `r2-cov-base.2026-10-16T10-05.md` | U1, U2, U3, U4, U5 (18 paths) | VALID | 142 | 30 | covered_BASE |
| P2-T5 | `r2-cov-iso-u2.2026-10-16T10-20.md` | U2 | VALID | 127 | 18 | `U2: NO-EFFECT` |
| P2-T6 | `r2-cov-iso-u1.2026-10-16T10-36.md` | U1 | VALID | 127 | 18 | `U1: NO-EFFECT` |
| P2-T7 | `r2-cov-iso-u4.2026-10-16T10-50.md` | U4 | VALID | 142 | 30 | `U4: RESTORES` |
| P2-T8 | `r2-cov-iso-u3.2026-10-16T10-51.md` | none (skipped) | not run | n/a | n/a | `ISOLATION: SKIPPED-BY-PLAN-RULE (PRIOR-UNIT-RESTORES)` |
| P2-T9 | `r2-cov-iso-u5.2026-10-16T10-51.md` | none (skipped) | not run | n/a | n/a | `ISOLATION: SKIPPED-BY-PLAN-RULE (PRIOR-UNIT-RESTORES)` |

Reproduction (P2-T4, `r2-cov-reproduction.2026-10-16T10-05.md`): `REPRODUCTION: REPRODUCED` (127 < 142).

P0-T5 `UseBreakpoints` results: repository `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` count 0; installed extension copy (`undefined_publisher.drm-copilot-0.0.1`) count 0. Both local and CI runs use Pester breakpoint coverage; no `INSTALLED-SETTINGS-NOT-BREAKPOINT`.

## Step A — conditions

- C1 `HEAD-NOT-MEASURED`: not held (P2-T2 VALID)
- C2 `BASE-NOT-MEASURED`: not held (P2-T3 VALID)
- C3 `NOT-REPRODUCED`: not held (127 < 142)
- C4 `REPRODUCED`: held (both VALID, 127 < 142)
- C5 `U2-RESTORES`: not held (U2 is `NO-EFFECT`)
- C6 `U2-NOT-MEASURED`: not held (U2 run VALID)
- C7 `OTHER-UNIT-RESTORES`: held [U4]
- C8 `EXACT-CI-PAIR`: not held (covered_HEAD 127, not 112; covered_BASE 142)

## Step B — held conditions and hypotheses

COV-1-INVESTIGATION-CONDITIONS: REPRODUCED, OTHER-UNIT-RESTORES [U4]

H0: REFUTED (P2-T1 VALID; all 30 lines credited, so every one executes and is attributable when no earlier suite compiled the module; NOT-TESTED set empty)
H1: SUPPORTED (P2-T2 and P2-T3 VALID; covered_HEAD 127 < covered_BASE 142 with identical production files)
H2: REFUTED (U2 NO-EFFECT; covered_U2 127 <= covered_HEAD 127)
H3-U1: REFUTED (U1 NO-EFFECT; covered_U1 127 <= covered_HEAD 127)
H3-U4: SUPPORTED (U4 RESTORES; covered_U4 142 >= covered_BASE 142)
H3-U3: NOT-TESTED (skipped by plan rule, PRIOR-UNIT-RESTORES)
H3-U5: NOT-TESTED (skipped by plan rule, PRIOR-UNIT-RESTORES)
H4: REFUTED (H1 SUPPORTED; exactly one measured unit, U4, is RESTORES)

## Step C — outcome (first matching rule)

Rule 1 (C1 or C2): no. Rule 2 (C3): no. Rule 3 (C5): no. Rule 4 (C6): no. Rule 5 (otherwise): applies.

COV-1-INVESTIGATION-OUTCOME: REPRODUCED-U2-DOES-NOT-RESTORE
COV-1-ROUTE: BLOCKED

`git status --porcelain -- tests` at the time of writing: empty.
