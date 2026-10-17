# R3 Coverage Delta Record (P4-T7)

Timestamp: 2026-10-16T15-50

## CI figures (quoted by P0-T5 from CI evidence the orchestrator read; not local measurements)
- CI run 38890188058 (head `988ed2210`): root LINE 90.17% (covered 16383, missed 1787); `WorktreeResolution.psm1` 112 covered / 32 missed.
- Baseline: 90.42% (`adb9aa5f0`, run 38730332356).
- Main at `b6be46b5e`: 90.44%; `WorktreeResolution.psm1` 142 covered / 2 missed.

## Local per-file values, `.claude/lib/worktree-resolution/WorktreeResolution.psm1` covered
| Source | Task | Value |
|---|---|---|
| N1 HEAD repo-scope | P1-T2 (`r3-cov-n1-head.2026-10-16T13-08.md`) | 127 |
| TARGET (lib-only N0) | P1-T1 (`r3-cov-n0-lib-only.2026-10-16T12-50.md`) | 142 |
| Trial 1 FX-1 | P3-T2 (`r3-cov-fix-trial-1.2026-10-16T14-39.md`) | 127 |
| Trial 2 FX-2 | P3-T3 (`r3-cov-fix-trial-2.2026-10-16T14-56.md`) | 127 |
| Trial 3 FX-23 | P3-T4 (`r3-cov-fix-trial-3.2026-10-16T15-15.md`) | 127 |
| Final repo-scope | P4-T4 (`r3-ps-test-repo.2026-10-16T15-50.md`) | 127 |

## Local three-folder values (local three-folder population; not comparable with CI)
| Source | Root covered | Root missed | Root total | Root pct | File covered | File missed | File credited |
|---|---|---|---|---|---|---|---|
| P0-T8 baseline (`evidence/baseline/r3-ps-test.2026-10-16T12-48.md`) | 8113 | 4186 | 12299 | 65.96 | 127 | 17 | 18 |
| P4-T3 final (`evidence/qa-gates/r3-ps-test.2026-10-16T15-32.md`) | 8113 | 4186 | 12299 | 65.96 | 127 | 17 | 18 |

## Post-change coverage
- Post-change CI coverage: PENDING-CI (orchestrator, S9, AC-24)
- New and changed production-line coverage: n/a: no production file changed (every changed file is under `tests/`, outside the `config/poshqc-coverage.json` roots)

COV-1-FINAL-STATUS: human_decision_required (NO-WRITE-SET-CANDIDATE-RESTORES)

This record does not state an AC-24 outcome; AC-24 is decided by the orchestrator from the PR CI coverage file at S9.
