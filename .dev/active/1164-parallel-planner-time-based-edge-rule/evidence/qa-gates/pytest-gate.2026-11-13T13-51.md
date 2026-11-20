# pytest Gate (remediation cycle 1, P2-T5, post-main-merge head)

Timestamp: 2026-11-13T13-43
Command: sh SCRATCH/issue-1164-pytest-gate.sh (in the item worktree: env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q -p no:cacheprovider --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-r1-final.json --junitxml=SCRATCH/issue-1164-pytest-final.junit.xml --cov); figures read by pwsh -File SCRATCH/issue-1164-pytest-extract.ps1; per-file comparison with the P0-T5 JSON report by pwsh -File SCRATCH/issue-1164-cov-diff.ps1 and SCRATCH/issue-1164-branch-diff.ps1
EXIT_CODE: 0
Output Summary:
- Run on head a27a608aa, whose non-docs tree equals the post-main-merge head 01547c4c7; final QA loop gate, one parallel run.
- Run 2026-11-13T13-43 to 13-48 UTC; summary line "16670 passed, 6 skipped in 263.59s (0:04:23)"; 0 failed. JUnit: 16676 tests, 0 failures, 0 errors, 6 skipped (P0-T5: 16667 passed, 0 failed).
- Repo-wide (JSON report totals): line 34525 / 35546 = 97.13% (P0-T5: 34525 / 35546 = 97.13%); branch 12758 / 13514 = 94.41% (P0-T5: 12759 / 13514 = 94.41%).
- Per-file (JSON report), each compared with P0-T5:
  - scripts/dev_tools/_blast_radius_scheduling.py: line 171/171 = 100.00%, branch 40/40 = 100.00% (P0-T5: 171/171, 40/40). No drop.
  - scripts/dev_tools/_parallel_state_records.py: line 191/191 = 100.00%, branch 96/96 = 100.00% (P0-T5: 191/191, 96/96). No drop.
- Per-file diff of the whole JSON report against P0-T5: one file differs, scripts/dev_tools/atomic_executor/cli_copilot_runtime.py, line 194/235 unchanged, branch 62/88 -> 61/88; the one arc absent from this run is 395->362, the return to the queue poll in the reader loop of the Copilot subprocess runner when an idle timeout is set and the process is still running, which depends on thread and queue timing. The file and its tests are absent from the merge-base diff and from the cycle's changes (two Python test files: test_blast_radius_access_weights.py and test_parallel_cohort_barrier_parity.py), so the one-branch difference is timing variance outside the branch, not a regression from this item; the rounded repo-wide branch figure is unchanged at 94.41%.
- Named suites (cases, failed): test_blast_radius_access_weights 18, 0; test_parallel_state_scheduling_parity 25, 0 (P0-T5 22; the three new stems reject-item-read-path-apostrophe-outside-radius, reject-overlap-reason-apostrophe, and reject-overlap-reason-both-quotes passed as test_validator_reproduces_the_expected_errors cases); test_push_down_claude_resource_contracts 14, 0; test_parallel_cohort_barrier_parity 33, 0.
- No failing test, so no failure is classified under the Execution Terms.
