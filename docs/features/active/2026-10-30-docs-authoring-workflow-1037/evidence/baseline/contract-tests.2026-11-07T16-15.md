# Contract and Regression Baseline (P0-T6)

Timestamp: 2026-11-07T16-15
Command: sh SCRATCH/issue-1037-contract.sh baseline (`env -u VIRTUAL_ENV poetry run pytest -n auto` over the twenty `tests/scripts/dev_tools/` modules listed in [P6-T6], then `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`); sh SCRATCH/issue-1037-pyfull.sh baseline (`env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=json:SCRATCH/issue-1037-pycov-baseline.json --cov-report=term`); sh SCRATCH/issue-1037-jest.sh baseline (`node run-jest.cjs` in `extensions/drm-copilot/`)
EXIT_CODE: 0
Output Summary: Contract tests (20 modules): 995 passed, 0 failed. Codex generator `--check`: exit 0. Full Python suite (one `pytest -n auto` run, quality-checks7 shape with line and branch coverage): 16350 passed, 6 skipped, 0 failed in 176.49 s; line coverage 96.84% (34071/35181), branch coverage 93.88% (12528/13344), combined 96.03% (coverage JSON totals). Full Jest suite in `extensions/drm-copilot/`: 334 suites and 5333 tests passed, 0 failed. Pre-existing failures: none in any suite.

Owner directive 2026-11-07: parallel test gates only

The full Python suite ran as one `pytest -n auto` run with coverage; Jest ran with its normal workers. The baseline was captured with the tree at the committed head: the in-progress Phase 1 and Phase 2 hook and test files were moved to SCRATCH for the duration of these runs (`git status --porcelain` empty) and restored afterwards, so the baseline describes the pre-change tree.
