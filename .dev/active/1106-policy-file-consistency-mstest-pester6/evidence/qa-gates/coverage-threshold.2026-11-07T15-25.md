# Coverage Thresholds and Baseline Comparison — Issue #1106 (P5-T5)

Timestamp: 2026-11-07T15-25
Command: PY SCRATCH/issue-1106-covsum.py SCRATCH/issue-1106-pytest-final.json; git diff -U0 MB HEAD -- the five D3 modules; comparison of failing-test lists from SCRATCH/issue-1106-pytest-baseline.xml, SCRATCH/issue-1106-pytest-final.xml, SCRATCH/baseline/pester-junit.xml, and artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: All five modules meet 85% line and 75% branch coverage in the single P5-T3 run. No changed line is missing from coverage. No test fails in P5-T3 or P5-T4; the baselines had no failures. PowerShell changed-line comparison is not applicable. No FAIL row.

## Per-module thresholds (from the P5-T3 run)

Line percent = covered_lines / num_statements; branch percent = covered_branches / num_branches.

| Module | Line | Branch | Result |
|---|---|---|---|
| scripts.dev_tools.atomic_executor.qc_runner | 96/103 = 93.20% | 14/18 = 77.78% | PASS |
| scripts.dev_tools.atomic_executor.qc_toolchain | 15/15 = 100.00% | 0/0 (module has no branches) | PASS |
| scripts.dev_tools.atomic_executor.cli_preflight | 153/153 = 100.00% | 77/78 = 98.72% | PASS |
| scripts.dev_tools.atomic_executor.prompt_builder | 124/124 = 100.00% | 44/44 = 100.00% | PASS |
| scripts.dev_tools.fix_all_branches_extra | 85/85 = 100.00% | 24/24 = 100.00% | PASS |

Remedy applied: the P0-T3 baseline showed `cli_preflight` at 99/153 lines and 36/78 branches, and `prompt_builder` at 92/124 lines and 26/44 branches, both below the thresholds. Under this task's remedy clause, tests for the uncovered behavior were added to the existing test files `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` (class `TestPreflightQCBranches`) and `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` (class `TestPromptBuilderOptionalSections`) in commit "test(atomic-executor): cover preflight gating and prompt sections". The tests were added before the final loop started at P5-T1, so the single P5-T3 run measured them.

## Comparisons

| Comparison | Evidence | Result |
|---|---|---|
| Changed lines executed (added lines from `git diff -U0 MB HEAD`: qc_runner.py new line 86, cli_preflight.py new line 377, prompt_builder.py new line 303; the other changes are deletions) are absent from the final `missing_lines` | qc_runner final missing 152, 195, 300, 301, 477, 509, 564; cli_preflight and prompt_builder final missing: none | PASS |
| No pytest test failing in P5-T3 that passed in P0-T3 | P0-T3: 0 failures, 0 errors; P5-T3: 0 failures, 0 errors | PASS |
| No Pester test failing in P5-T4 that passed in P0-T4 | P0-T4: 0 failed of 15553; P5-T4: 0 failed of 15571 | PASS |
| PowerShell changed-line coverage | No production PowerShell file changed; the only PowerShell file added is test code (`tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1`) | N/A (not applicable) |
