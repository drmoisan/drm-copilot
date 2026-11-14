# Merge Conflicts: origin/main into feature/pester-static-leak-scan-1096 (Remediation Cycle 1)

Timestamp: 2026-11-07T16-23
Command: git -C <item worktree> fetch origin; git -C <item worktree> merge --no-ff --no-commit origin/main
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: four content conflicts (the four paths below); six paths changed on both sides auto-merged; 281 paths staged from main without conflict.

Rule applied: both sides' intent survives. Branch side (stage 2, `HEAD`): `-n`, `auto` right after `pytest` in full-suite commands and prompt text. Main side (stage 3, `origin/main`, PR #1108, issue #1106): `--cov=scripts/dev_tools` as the coverage source and no `src/lexile_corpus_tuner` path.

## scripts/dev_tools/atomic_executor/cli_preflight.py

Hunk in `build_preflight_qc_fix_prompt` (Python command lines).

Branch side (stage 2):

```text
                "   - `poetry run pytest -n auto "
```

Main side (stage 3):

```text
                "   - `poetry run pytest "
```

Shared following line: `"--cov=scripts/dev_tools --cov-report=term-missing`",`

Resolved:

```text
                "   - `poetry run pytest -n auto "
                "--cov=scripts/dev_tools --cov-report=term-missing`",
```

The pytest step of `run_preflight_qc_with_capture` auto-merged; its resolved argv is checked after resolution (see `## Post-Resolution Checks`).

## scripts/dev_tools/atomic_executor/prompt_builder.py

Hunk in the toolchain text of `PromptBuilder.build`.

Branch side (stage 2):

```text
  - python -m poetry run pytest -n auto \\
```

Main side (stage 3):

```text
  - python -m poetry run pytest \\
```

Shared following lines: `--cov=scripts/dev_tools \\` and `--cov-report=term-missing`.

Resolved:

```text
  - python -m poetry run pytest -n auto \\
      --cov=scripts/dev_tools \\
      --cov-report=term-missing
```

## scripts/dev_tools/atomic_executor/qc_runner.py

Hunk 1, `QCRunner.FULL_TEST` (after `"--color=no",`).

Branch side (stage 2): empty (the branch removed `"--cov=src/lexile_corpus_tuner",` and added nothing).

Main side (stage 3):

```text
        "--cov=scripts/dev_tools",
```

Resolved list: `"poetry", "run", "pytest", "-n", "auto", "--color=no", "--cov=scripts/dev_tools", "--cov-report=xml", "--cov-report=term-missing"`. This resolution is the NB-2 change: `FULL_TEST` now names a coverage source.

Hunk 2, `full_test` in `run_full_loop_with_artifacts` (after `"pytest",`).

Branch side (stage 2):

```text
                "-n",
                "auto",
```

Main side (stage 3): empty (main removed `"--cov=src/lexile_corpus_tuner",`).

Resolved list: `"poetry", "run", "pytest", "-n", "auto", "--cov=scripts/dev_tools", "--cov-report=term-missing"`.

## tests/scripts/dev_tools/atomic_executor/test_qc_runner.py

Hunk in `test_run_full_runs_all_tools_on_entire_codebase`, expected `calls[3]` list (after `"--color=no",`).

Branch side (stage 2): empty.

Main side (stage 3):

```text
            "--cov=scripts/dev_tools",
```

Resolved expected list: `"poetry", "run", "pytest", "-n", "auto", "--color=no", "--cov=scripts/dev_tools", "--cov-report=xml", "--cov-report=term-missing"`, equal to the resolved `FULL_TEST`. The branch cases `test_full_loop_full_test_runs_xdist_workers` and `test_python_toolchain_pytest_command_runs_xdist_workers` are outside the hunk and stay.

## Auto-Merged Paths Changed on Both Sides

- `.vscode/tasks.json`
- `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`
- `scripts/dev_tools/atomic_executor/qc_toolchain.py`
- `scripts/dev_tools/fix_all_branches_extra.py`
- `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py`
- `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py`

## Post-Resolution Checks

Recorded after resolution, before the commit.

- `git ls-files -u` through `-C` printed nothing (0 unmerged entries).
- No conflict marker remains under `scripts/dev_tools/atomic_executor/` or `tests/scripts/dev_tools/atomic_executor/`.
- The pytest step of `run_preflight_qc_with_capture` (auto-merged) is `poetry`, `run`, `pytest`, `-n`, `auto`, `--color=no`, `--cov=scripts/dev_tools`, `--cov-report=term-missing`.
- No `src/lexile_corpus_tuner` occurrence remains in `scripts/dev_tools/atomic_executor/`, `scripts/dev_tools/fix_all_branches_extra.py`, or `.vscode/tasks.json`.
- `test_full_loop_full_test_runs_xdist_workers` and `test_python_toolchain_pytest_command_runs_xdist_workers` are both present in `test_qc_runner.py`.
- Known follow-up left to P1-T3: main's `_PYTEST_STEP` in `test_cli_part3.py` lacks `-n auto`, and entry 0001 fences are stale for the merged lines.
