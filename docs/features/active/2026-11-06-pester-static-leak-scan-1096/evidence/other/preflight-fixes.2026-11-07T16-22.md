# Preflight Fixes: Remediation Cycle 1 (Issue #1096)

Timestamp: 2026-11-07T16-22
Plan: docs/features/active/2026-11-06-pester-static-leak-scan-1096/remediation-plan.2026-11-07T16-07.md
Result: PREFLIGHT: ALL CLEAR

## Fixes

- [P1-T3] | literal list inconsistent with the plan's own commit rule | The acceptance list for `git diff --name-only HEAD~1 HEAD` named only the entry, the two test files, and the plan. `## Execution Rules` (`Commits`) requires each task commit to stage the evidence it writes, so the `ledger-fence-replay` artifact is also in that commit. The list now names that artifact. The assertion's meaning (no path outside the task's own set) is unchanged.

## Checks Performed Without a Defect

- Trial merge of `origin/main` (after a fetch) reports content conflicts in exactly the four paths P0-T2 names, and auto-merges `.vscode/tasks.json`, the ledger entry 0001, `qc_toolchain.py`, `fix_all_branches_extra.py`, `test_cli_part3.py`, and `test_prompt_builder.py`.
- Each conflict hunk admits the P0-T2 expected resolution.
- `pyproject.toml` on main drops one Ruff per-file-ignore line only; no dependency change, and `poetry.lock` is unchanged.
- P1-T2: every case of `TestPreflightBranches` reaches a code branch also reached by `TestPreflightQCBranches` (main), including the unmatched-test-name and no-override branches of the Jest gate; every `TestPromptBuilderContext` case except `test_real_file_system_glob_sorts_matches` reaches a branch reached by `TestPromptBuilderOptionalSections`.
- P1-T3: `test_preflight_pytest_step_runs_xdist_workers` depends only on `mem_fs_path` (root `conftest.py`), `subprocess`, `Path`, and `MonkeyPatch`, all available in `test_cli_part2_part2.py`; main carries no `src/lexile_corpus_tuner` in any ledger target.
- P2-T1: merged `test_qc_runner.py` is about 712 lines after resolution; the two moved cases take it under 700. `mem_fs_path` is a root fixture.
- P2-T3: `Invoke-PoshQCLeakScan` has one `parse-error` catch around read and parse; the module is 212 lines.
- Main-plan references (`## Finding Classification Rule`, P0-T3 row keys, P5-T2, P6-T5, P6-T6, AC ordinal IDs) and the `poshqc-linux-hooks` job id resolve.
- Plan validator: MCP route and branch-current CLI route both pass with no warnings.
