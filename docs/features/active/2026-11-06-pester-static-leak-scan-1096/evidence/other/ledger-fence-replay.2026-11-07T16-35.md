# Ledger Fence Replay: Entry 0001 on the Merged Tree (Remediation Cycle 1, P1-T3)

Timestamp: 2026-11-07T16-35
Command: sh SCRATCH/issue-1096-c1-replay.sh (pwsh imports scripts/dev-tools/ProcessReductionLedger.psm1, reads the `## Prior Text` section with Get-ProcessReductionSection and its blocks with Get-ProcessReductionRevertBlock, passes each target's text to Invoke-ProcessReductionRevert in memory, then runs Test-ProcessReductionLedger on Read-ProcessReductionLedger; exits 1 on any throw or an invalid ledger)
EXIT_CODE: 0
Output Summary: 26 blocks, 26 rows, all OK; LEDGER-VALID=True. A second step (sh SCRATCH/issue-1096-c1-replay-main.sh) applied every block of five paths in sequence and compared the result with the origin/main copy: all five equal, EXIT_CODE 0.

## Replay Rows

| Row | Path | Result |
|---|---|---|
| 1 | .claude/skills/execution-environment/SKILL.md | OK |
| 2 | .claude/skills/atomic-plan-contract/SKILL.md | OK |
| 3 | .agents/skills/atomic-plan-contract/SKILL.md | OK |
| 4 | .github/skills/atomic-plan-contract/SKILL.md | OK |
| 5 | .claude/skills/execution-environment/SKILL.md | OK |
| 6 | .vscode/tasks.json | OK |
| 7 | .vscode/tasks.json | OK |
| 8 | .vscode/tasks.json | OK |
| 9 | .vscode/tasks.json | OK |
| 10 | scripts/dev_tools/fix_all_branches.py | OK |
| 11 | scripts/dev_tools/fix_all_branches.py | OK |
| 12 | scripts/dev_tools/fix_all_branches_extra.py | OK |
| 13 | scripts/dev_tools/atomic_executor/cli_preflight.py | OK |
| 14 | scripts/dev_tools/atomic_executor/cli_preflight.py | OK |
| 15 | scripts/dev_tools/atomic_executor/prompt_builder.py | OK |
| 16 | scripts/dev_tools/atomic_executor/qc_runner.py | OK |
| 17 | scripts/dev_tools/atomic_executor/qc_runner.py | OK |
| 18 | scripts/dev_tools/atomic_executor/qc_toolchain.py | OK |
| 19 | tests/scripts/dev_tools/atomic_executor/test_cli_part3.py | OK |
| 20 | tests/scripts/dev_tools/atomic_executor/test_cli_part3.py | OK |
| 21 | tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py | OK |
| 22 | tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py | OK |
| 23 | tests/scripts/dev_tools/atomic_executor/test_qc_runner.py | OK |
| 24 | tests/scripts/dev_tools/atomic_executor/test_qc_runner.py | OK |
| 25 | tests/scripts/dev_tools/test_fix_all_branches.py | OK |
| 26 | tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1 | OK |

Row count 26 equals the block count 26.

## Sequential Revert Against origin/main

| Path | Blocks | Equal to origin/main |
|---|---|---|
| scripts/dev_tools/atomic_executor/cli_preflight.py | 2 | True |
| scripts/dev_tools/atomic_executor/prompt_builder.py | 1 | True |
| scripts/dev_tools/atomic_executor/qc_runner.py | 2 | True |
| scripts/dev_tools/atomic_executor/qc_toolchain.py | 1 | True |
| tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py | 1 | True |

A revert of these paths therefore restores main's `--cov=scripts/dev_tools` text exactly and never the stale package coverage flag.

## Changes to the Entry

- `Current` fences updated to the merged text: the `QCRunner.FULL_TEST` block of `qc_runner.py` and the `test_run_full_runs_all_tools_on_entire_codebase` list block of `test_qc_runner.py` now hold `--cov=scripts/dev_tools`.
- `Prior` fences of the `cli_preflight.py` (2), `prompt_builder.py`, `qc_runner.py` (2), `qc_toolchain.py`, and `test_qc_runner.py` list blocks now equal their `Current` with only `-n`, `auto` removed.
- Two blocks removed: the coverage-arguments block of `.vscode/tasks.json` and the second block of `fix_all_branches_extra.py`. After the merge their text is identical on the branch and on `origin/main` (main's PR #1108 made the same coverage-flag removal), so they are no longer part of the reduction; a block with `Prior` equal to `Current` would revert nothing. `## Files Changed` now reads "with a Revert Block" for `fix_all_branches_extra.py`.
- New block for the module constant `_PYTEST_STEP` in `test_cli_part3.py`: `Current` carries `-n`, `auto`; `Prior` is main's constant.
- The block of the moved case now names `tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py`; its `Current` holds the class `TestPreflightParallelCommand` anchored on the preceding line, with that line as `Prior`, so the revert leaves the file equal to origin/main (an unanchored block at end of file left one extra newline). The empty-`Prior` block for the case in `test_cli_part3.py` is gone.
- `## Files Changed` adds `tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py` as a contract test with a Revert Block. `## Revert Steps` step 5 names the `_PYTEST_STEP` restoration and the moved case's file, and step 6 names `test_cli_part2_part2.py`. The six step labels, `## Revert Signals`, and the README index are unchanged.
- Every remaining `src/lexile_corpus_tuner` occurrence in the entry (4) is a `not in` assertion inside a `Current` fence of a test block (`test_cli_part2_part2.py`, `test_qc_runner.py` twice, `test_fix_all_branches.py`).

## Test Changes in the Same Commit

- `test_cli_part3.py`: `_PYTEST_STEP` gains `-n`, `auto` after `pytest`; `test_preflight_pytest_step_runs_xdist_workers` moved out. File is 687 lines.
- `test_cli_part2_part2.py`: new class `TestPreflightParallelCommand` holds the moved case unchanged. File is 158 lines.
- Debugging run of both files (sh SCRATCH/issue-1096-debug-py.sh; not a gate): Black unchanged, Ruff clean, 32 passed.
- Lines added outside the entry contain neither `LeakScan` nor `leak scan` (0 matches, case-insensitive).
