# Coverage Comparison: Phase 0 Baseline vs Final Gates (P7-T8)

Timestamp: 2026-11-14T11-21
Command: comparison of the `Phase 0 baseline` artifacts under `evidence/baseline/` with the final gate artifacts under `evidence/qa-gates/`. Baselines: `pester-suite.2026-11-10T04-17.md`, `pytest-suite.2026-11-10T04-23.md`, `jest-extension-suite.2026-11-10T04-26.md`, and `bats-suite.2026-11-10T04-26.md`. Finals: `pester-suite.2026-11-14T11-16.md`, `pytest-suite.2026-11-14T11-20.md`, `jest-extension-suite.2026-11-14T11-20.md`, and `bats-suite.2026-11-14T10-59.md`, whose result `bats-suite.2026-11-14T11-20.md` confirms is still valid.
EXIT_CODE: 0
Output Summary: no gate has a new failing test; every baseline and final failure count is 0. No repo-wide or per-file coverage figure for a changed file drops. Every new file meets the 85% line threshold and the 90% new-code rule, and every changed Python module meets the 75% branch threshold. The local gates exclude the integration-named tests (41 Pester, 11 pytest, 16 Jest) that the Phase 0 runs included. No coverage drop is attributable to that exclusion. `evidence/other/lane-deviation.2026-11-14T11-21.md` records the lane exclusion as a non-blocking deviation.

## Test Counts and Failures

| Gate | Baseline (all tests) | Integration tests in baseline | Baseline after lane subtraction | Final | Baseline failures | Final failures |
|---|---|---|---|---|---|---|
| Pester | 21311 (10 skipped) | 41 | 21270 | 26384 (18 skipped) | 0 | 0 |
| pytest | 16598 passed, 6 skipped | 11 | 16587 passed | 16927 passed, 6 skipped | 0 | 0 |
| Jest (extension) | 5476 in 340 suites | 16 in 4 suites | 5460 in 336 suites | 5616 in 340 suites | 0 | 0 |
| bats | not run (P0-T7 deviation: no bats or kcov on the host PATH) | n/a | n/a | 803 | n/a | 0 |

Each final count exceeds its lane-subtracted baseline because `origin/main` merges and this item added tests.

## Repo-Wide Coverage

| Gate | Baseline | Final | Delta |
|---|---|---|---|
| Pester line | 95.80% (37558/39203) | 95.95% (43537/45376) | +0.15 pt |
| pytest, the seven `--cov` modules: line | 72.91% (557/764) | 98.83% | +25.92 pt |
| pytest, the seven `--cov` modules: branch | 65.44% (178/272) | 96.41% | +30.97 pt |
| Jest | N/A - no TypeScript production change | N/A | N/A |
| bats line (kcov) | N/A - no pre-change run | 95.0% (3460/3643) | N/A |

## Per-File Coverage: Changed Files

| File | Baseline | Final | Delta | New or changed code |
|---|---|---|---|---|
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | 93.66% (192/205) | 94.17% (210/223) | +0.51 pt | 18 added lines, all covered |
| `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | 97.37% (148/152) | 97.40% (150/154) | +0.03 pt | 2 added lines, both covered |
| `scripts/dev-tools/run-poshqc-suite.ps1` | 0.00% (0/5) | 91.07% (51/56) | +91.07 pt | 91.07% of the file; the 5 missed lines are default seam bodies (lock directory, clock, sleep, stderr, helper import) |
| `scripts/dev_tools/fix_all_runtime.py` | 98.78% line, 95.45% branch | 98.80% line, 95.45% branch | +0.02 pt line, 0 branch | the only missed line (101) is unchanged |
| `scripts/dev_tools/fix_all_branches.py` | 100.00%, 100.00% | 100.00%, 100.00% | 0 | 100% |
| `scripts/dev_tools/fix_all_branches_extra.py` | 100.00%, 100.00% | 100.00%, 100.00% | 0 | 100% |
| `scripts/dev_tools/atomic_executor/qc_runner.py` | 93.20% line, 77.78% branch | 93.58% line, 81.82% branch | +0.38 pt line, +4.04 pt branch | the missed lines (157, 200, 305-306, 493, 525, 580) are all unchanged |
| `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` | 43.53% line, 29.63% branch | 100.00% line, 97.14% branch | +56.47 pt line, +67.51 pt branch | 100% of lines |
| `scripts/dev_tools/atomic_executor/cli_preflight.py` | 100.00% line, 98.72% branch | 100.00% line, 98.78% branch | 0 line, +0.06 pt branch | 100% of lines |
| `scripts/dev_tools/atomic_executor/cli_task_runtime.py` | 10.65% line, 0.00% branch | 98.84% line, 94.23% branch | +88.19 pt line, +94.23 pt branch | the missed lines (211-212) are unchanged |

## Per-File Coverage: New Files (judged against the thresholds)

| File | Final line coverage | Meets 85% | Meets 90% new-code rule |
|---|---|---|---|
| `.claude/hooks/test-execution-policy.ps1` | 100.00% | yes | yes |
| `.claude/hooks/test-execution-lock-decision.ps1` | 100.00% | yes | yes |
| `.claude/hooks/test-execution-lock.ps1` | 91.30% | yes | yes |
| `.claude/hooks/test-execution-command-form.ps1` | 96.74% | yes | yes |
| `.claude/hooks/enforce-test-execution-policy.ps1` | 91.67% | yes | yes |
| `.codex/hooks/test-execution-policy.ps1` | 100.00% | yes | yes |
| `.codex/hooks/test-execution-lock-decision.ps1` | 100.00% | yes | yes |
| `.codex/hooks/test-execution-lock.ps1` | 95.65% | yes | yes |
| `.codex/hooks/test-execution-command-form.ps1` | 96.74% | yes | yes |
| `.codex/hooks/enforce-test-execution-policy.ps1` | 98.54% | yes | yes |
| `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` | 92.93% | yes | yes |
| `.claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1` | 94.74% | yes | yes |
| `.claude/skills/test-execution-policy/scripts/run-test-suite.sh` | 100.00% (kcov) | yes | yes |

The `.agents` and bundle copies of the launcher scripts and hooks are byte-identical to the files above (the P3-T2 and P6-T2 hash checks and the mirror contract tests). They are outside the Pester coverage roots.

## Lane-Attributable Drops

None. The baseline runs included 41 Pester, 11 pytest, and 16 Jest integration tests, and the final runs exclude them. No file's coverage fell after that exclusion, and no repo-wide figure fell. The non-blocking deviation is recorded in `evidence/other/lane-deviation.2026-11-14T11-21.md`.
