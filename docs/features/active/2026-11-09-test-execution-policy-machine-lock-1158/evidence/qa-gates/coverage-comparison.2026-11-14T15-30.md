# Coverage Comparison: Phase 0 Baseline vs Final Gates (remediation cycle 1, P3-T5)

Timestamp: 2026-11-14T15-30
Command: comparison of the lexicographically greatest pester-suite.*.md, pytest-suite.*.md, and jest-extension-suite.*.md under evidence/baseline/ (pester-suite.2026-11-10T04-17.md, pytest-suite.2026-11-10T04-23.md, jest-extension-suite.2026-11-10T04-26.md) with the final gates under evidence/qa-gates/ (pester-suite.2026-11-14T15-28.md, pytest-suite.2026-11-14T15-28.md, jest-extension-suite.2026-11-14T15-28.md)
EXIT_CODE: 0
Output Summary: no gate has a new failing test after subtracting the integration-lane tests the baseline recorded (41 Pester, 11 pytest, 16 Jest); every baseline and final failure count is 0. No repo-wide or per-file coverage figure drops. Every changed production file is at or above 85% line (and 75% branch for Python), and every file new on the branch meets the thresholds. There is no FAIL row. evidence/other/lane-deviation.2026-11-14T15-30.md records the subtracted counts as a non-blocking deviation.

## Test Counts and Failures

| Gate | Baseline | Integration tests in baseline | Baseline after subtraction | Final | Baseline failures | Final failures | Verdict |
|---|---|---|---|---|---|---|---|
| Pester | 21311 (10 skipped) | 41 | 21270 | 26420 (18 skipped) | 0 | 0 | PASS |
| pytest | 16598 passed, 6 skipped | 11 | 16587 passed | 16927 passed, 6 skipped | 0 | 0 | PASS |
| Jest (extension) | 5476 in 340 suites | 16 in 4 suites | 5460 in 336 suites | 5616 in 340 suites | 0 | 0 | PASS |

Each final count exceeds its subtracted baseline because origin/main merges and this item added tests.

## Repo-Wide Coverage

| Gate | Baseline | Final | Delta | Verdict |
|---|---|---|---|---|
| Pester line | 95.80% (37558/39203) | 95.95% (43560/45399) | +0.15 pt | PASS |
| pytest, the seven changed modules: line | 72.91% (557/764) | 98.83% (846/856) | +25.92 pt | PASS |
| pytest, the seven changed modules: branch | 65.44% (178/272) | 96.41% (295/306) | +30.97 pt | PASS |
| pytest repo-wide (configured source) | N/A - no pre-change run (the baseline measured the seven modules) | 97.74% line, 95.13% branch | N/A | PASS (at or above 85% and 75%) |
| Jest | N/A - no TypeScript production change | N/A | N/A | N/A |

## Per-File Coverage: Changed Files

| File | Gate | Baseline | Final | Delta | Verdict |
|---|---|---|---|---|---|
| scripts/powershell/PoshQC/PoshQC.Parallel.psm1 | Pester | 97.37% (148/152) | 97.74% (173/177) | +0.37 pt | PASS |
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | Pester | 93.66% (192/205) | 94.17% (210/223) | +0.51 pt | PASS |
| scripts/dev-tools/run-poshqc-suite.ps1 | Pester | 0.00% (0/5) | 91.07% (51/56) | +91.07 pt | PASS |
| scripts/dev_tools/fix_all_runtime.py | pytest | 98.78% line, 95.45% branch | 98.80% line, 95.45% branch | +0.02 pt, 0 | PASS |
| scripts/dev_tools/fix_all_branches.py | pytest | 100.00%, 100.00% | 100.00%, 100.00% | 0 | PASS |
| scripts/dev_tools/fix_all_branches_extra.py | pytest | 100.00%, 100.00% | 100.00%, 100.00% | 0 | PASS |
| scripts/dev_tools/atomic_executor/qc_runner.py | pytest | 93.20% line, 77.78% branch | 93.58% line, 81.82% branch | +0.38 pt, +4.04 pt | PASS |
| scripts/dev_tools/atomic_executor/qc_runner_expectations.py | pytest | 43.53% line, 29.63% branch | 100.00% line, 97.14% branch | +56.47 pt, +67.51 pt | PASS |
| scripts/dev_tools/atomic_executor/cli_preflight.py | pytest | 100.00% line, 98.72% branch | 100.00% line, 98.78% branch | 0, +0.06 pt | PASS |
| scripts/dev_tools/atomic_executor/cli_task_runtime.py | pytest | 10.65% line, 0.00% branch | 98.84% line, 94.23% branch | +88.19 pt, +94.23 pt | PASS |

The scoped entry of this cycle (TestPath, ResolveTestFile, Resolve-PoshQCParallelTestFile) raised PoshQC.Parallel.psm1 from 154 measured lines at the earlier final gate to 177, with all 23 added lines covered; the 4 missed lines are unchanged default seam bodies.

## Per-File Coverage: Files New on the Branch (judged against the thresholds)

| File | Gate | Final line coverage | Meets 85% | Verdict |
|---|---|---|---|---|
| .claude/hooks/test-execution-policy.ps1 | Pester | 100.00% | yes | PASS |
| .claude/hooks/test-execution-lock-decision.ps1 | Pester | 100.00% | yes | PASS |
| .claude/hooks/test-execution-lock.ps1 | Pester | 91.30% | yes | PASS |
| .claude/hooks/test-execution-command-form.ps1 | Pester | 96.74% | yes | PASS |
| .claude/hooks/enforce-test-execution-policy.ps1 | Pester | 91.67% | yes | PASS |
| .codex/hooks/test-execution-policy.ps1 | Pester | 100.00% | yes | PASS |
| .codex/hooks/test-execution-lock-decision.ps1 | Pester | 100.00% | yes | PASS |
| .codex/hooks/test-execution-lock.ps1 | Pester | 95.65% | yes | PASS |
| .codex/hooks/test-execution-command-form.ps1 | Pester | 96.74% | yes | PASS |
| .codex/hooks/enforce-test-execution-policy.ps1 | Pester | 98.54% | yes | PASS |
| .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 | Pester | 92.93% | yes | PASS |
| .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1 | Pester | 94.74% | yes | PASS |
| .claude/skills/test-execution-policy/scripts/run-test-suite.sh | bats (kcov) | 100.00% (evidence/qa-gates/bats-suite.2026-11-14T10-59.md; this cycle changes no shell file) | yes | PASS |

The .agents and bundle copies of the launcher scripts and hooks are byte-identical to the files above and lie outside the Pester coverage roots.
