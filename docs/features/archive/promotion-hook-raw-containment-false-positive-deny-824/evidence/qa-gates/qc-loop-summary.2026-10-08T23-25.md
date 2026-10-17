# QC Loop Summary ([P10-T18])

Timestamp: 2026-10-08T23-25

Final clean pass: **2**

## Pass history

- Pass 1: [P10-T1]..[P10-T6] passed; [P10-T7] failed with `UNCOVERED_CHANGED_TOTAL: 20` (`qc-pass-1-changed-line-coverage.2026-10-08T23-02.md`). Fix: nine covering test rows (14 executions) were added to six plan-created test files (PY-25..PY-27, EW-40, PW-40, CW-40, PA-23, PA-24, AL-38). No production file changed, so rule 6 required no mirror run. The loop restarted at [P10-T1].
- Pass 2: every task [P10-T1]..[P10-T17] passed; [P10-T2] reported no rewritten write-set path (every recomputed hash equal to its [P10-T1] value) and no restored path outside the write set.

## Pass 2 artifacts (all under `FEATURE/evidence/qa-gates/`)

| Task | Artifact | Result |
|---|---|---|
| [P10-T1] | qc-pass-2-porcelain-before.2026-10-08T23-05.md | EXIT_CODE 0; six write-set test paths hashed |
| [P10-T2] | qc-pass-2-format.2026-10-08T23-06.md | MCP returned; FORMAT_DRIFT_COUNT: 0; hashes unchanged; no restore |
| [P10-T3] | qc-pass-2-analyze.2026-10-08T23-07.md | MCP returned; PSSA_FINDING_COUNT: 0 |
| [P10-T4] | qc-pass-2-mcp-test.2026-10-08T23-11.md | MCP disposition recorded (error, exit 2; no count read) |
| [P10-T5] | qc-pass-2-pester-full-run.2026-10-08T23-19.md | FULL_RUN_EXIT_CODE 2 (B_FULL only); both XML files rewritten |
| [P10-T6] | qc-pass-2-pester-full-coverage.2026-10-08T23-19.md | failures = B_FULL; 19 files >= 85.00; COVERAGE_BELOW_85: NONE |
| [P10-T7] | qc-pass-2-changed-line-coverage.2026-10-08T23-19.md | UNCOVERED_CHANGED_TOTAL: 0 |
| [P10-T8] | coverage-delta.2026-10-08T23-20.md | 19 rows; no decrease vs baseline |
| [P10-T9] | qc-pass-2-issue824.2026-10-08T23-21.md | 689 passed, 0 failed |
| [P10-T10] | qc-pass-2-pytest-parity.2026-10-08T23-22.md | 27 passed |
| [P10-T11] | qc-pass-2-jest-parity.2026-10-08T23-22.md | Tests: 42 passed, 42 total |
| [P10-T12] | qc-pass-2-lines.2026-10-08T23-22.md | OVER_500: NONE; legacy-codex-hook-contracts 497 |
| [P10-T13] | qc-pass-2-no-python.2026-10-08T23-23.md; qc-pass-2-parity-pester.2026-10-08T23-23.md | PYTHON_INVOCATION_COUNT: 0; 157 passed, 0 failed |
| [P10-T14] | qc-pass-2-parity-hashes.2026-10-08T23-24.md | 16 groups, all DISTINCT=1 |
| [P10-T15] | qc-pass-2-scope.2026-10-08T23-24.md | OUT_OF_SET_COUNT: 0; ADDENDUM2_COUNT: 0 |
| [P10-T16] | qc-pass-2-deny-tokens.2026-10-08T23-24.md | NEW_TOKEN_COUNT: 2 (permitted set) |
| [P10-T17] | qc-pass-2-validate-bash-unchanged.2026-10-08T23-24.md | EXIT_CODE 0 |

Pass 2 is clean: every task has a passing artifact, and [P10-T2] reports no rewritten write-set path.
