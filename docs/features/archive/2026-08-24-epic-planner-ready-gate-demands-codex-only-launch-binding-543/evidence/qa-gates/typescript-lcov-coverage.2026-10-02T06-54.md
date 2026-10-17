# TypeScript lcov Coverage Verdict (Remediation Cycle 1, R1)

Timestamp: 2026-10-02T06-54
Task: P1-T5 of remediation-plan.2026-10-02T05-58.md
Command: poetry run python <scratchpad>/ts_coverage_543.py per-file; poetry run python <scratchpad>/ts_coverage_543.py added (consolidated from P1-T3 and P1-T4; each run alone from the worktree root)
EXIT_CODE: 0
Inputs:
- P1-T1: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-coverage-run.2026-10-02T06-52.md`
- P1-T2: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-lcov-file.2026-10-02T06-53.md`
- P1-T3: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-lcov-per-file.2026-10-02T06-54.md`
- P1-T4: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-added-line-coverage.2026-10-02T06-54.md`
- P0-T3: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/baseline-typescript-per-file-coverage.2026-10-02T06-51.md`
- lcov: `extensions/drm-copilot/coverage/lcov.info`, write time 2026-10-02T06-53-09 (P1-T2); gitignored tool output, cited and not committed.

Output Summary:

| File (`extensions/drm-copilot/src/lib/validate/`) | LF | LH | BRF | BRH | lcov line % | lcov branch % | Baseline % Lines | Baseline % Branch | P1-T1 text % Lines | P1-T1 text % Branch |
|---|---|---|---|---|---|---|---|---|---|---|
| `epic-orchestrator-state-launch-binding.ts` | 334 | 321 | 119 | 111 | 96.10 | 93.27 | 96 | 92.79 | 96.1 | 93.27 |
| `epic-planner-launch-evidence.ts` | 469 | 435 | 116 | 98 | 92.75 | 84.48 | 91.64 | 80.61 | 92.75 | 84.48 |
| `epic-planner-readiness-integrity.ts` | 370 | 339 | 70 | 59 | 91.62 | 84.28 | 91.48 | 82.81 | 91.62 | 84.28 |
| `epic-planner-state-core.ts` | 471 | 463 | 109 | 102 | 98.30 | 93.57 | 98.26 | 93.51 | 98.3 | 93.57 |
| `orchestration-artifacts.ts` | 369 | 369 | 82 | 80 | 100.00 | 97.56 | 100 | 97.43 | 100 | 97.56 |

Conditions:
- P1-T1 exit 0 with no failed test (`Tests: 3794 passed, 3794 total`; `Test Suites: 250 passed, 250 total`): met.
- P1-T2 lcov write time 2026-10-02T06-53-09 is at or after the P1-T1 `Timestamp:` 2026-10-02T06-52: met.
- Every file at or above 85% lines and 75% branches by the P1-T3 integer check (`SUMMARY files=5 failures=0`): met. Lowest values: 91.62% lines (`epic-planner-readiness-integrity.ts`), 84.28% branches (`epic-planner-readiness-integrity.ts`).
- Every lcov line % and branch % at or above its P0-T3 baseline value: met for all ten comparisons.
- P1-T4 `SUMMARY added_total=53 uncovered_total=0` (`added_total` greater than 0): met.

Verdict: PASS
