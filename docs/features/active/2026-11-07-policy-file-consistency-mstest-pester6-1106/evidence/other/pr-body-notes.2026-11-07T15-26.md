# PR Body Notes — Issue #1106 (P5-T6)

Timestamp: 2026-11-07T15-26

## Owner authorization (state in the PR body)

The owner explicitly authorized editing the canonical `.github/instructions` policy files and their mirrors (`.claude/rules`, `.agents/skills`, and the bundle copies under `extensions/drm-copilot/resources/`) for issue #1106 only. This overrides, for this issue only, the standing `CLAUDE.md` rule and the `policy-compliance-order` constraint that those files must not be modified. The authorization is recorded in the orchestrator checkpoint `artifacts/orchestration/orchestrator-state.json` (decision text beginning `Owner authorized editing canonical`; confirmed present by `grep -c`, count 1).

## D3 Python behavior change (state in the PR body)

The atomic-executor QC paths and `scripts/dev_tools/fix_all_branches_extra.py` no longer pass `--cov=src/lexile_corpus_tuner`, a package that does not exist in this repository. Coverage now targets the existing `scripts/dev_tools` package:

- `QCRunner.FULL_TEST` in `scripts/dev_tools/atomic_executor/qc_runner.py`, where the stray path was the only `--cov` argument, now passes `--cov=scripts/dev_tools`, so the full-run pytest step measures existing code where it previously measured nothing.
- The `full_test` argv in `qc_runner.py`, `PYTHON_TOOLCHAIN_COMMANDS["pytest"]` in `qc_toolchain.py`, the preflight `pytest` step and fix-prompt text in `cli_preflight.py`, the constraints text in `prompt_builder.py`, and the `include_coverage` extension in `fix_all_branches_extra.py` drop the stray argument; the following `--cov=scripts/dev_tools` remains.
- `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` (`test_run_full_runs_all_tools_on_entire_codebase`) asserts the new argv.
