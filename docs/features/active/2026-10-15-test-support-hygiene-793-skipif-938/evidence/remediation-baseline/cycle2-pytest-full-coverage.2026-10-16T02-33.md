# Cycle 2 baseline: full pytest suite with coverage

Timestamp: 2026-10-16T02-33

## Run A: the plan command, verbatim

Command: poetry run pytest -q -p no:cacheprovider --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary:
16 errors in 13.20s (collection interrupted: `ModuleNotFoundError: No module named 'typer'` raised from `scripts/dev_tools/codex_native_converter/cli.py:28` while collecting the 16 modules under `tests/scripts/dev_tools/codex_native_converter/`). No test ran and no coverage table printed. This is a pre-existing environment condition (the `typer` package is not installed in the poetry environment of this worktree), unrelated to the four files in scope. Reported to the caller.
Table header: not printed
TOTAL row: not printed

## Run B: supplementary run so that pass counts and coverage can be compared

Command: poetry run pytest -q -p no:cacheprovider --continue-on-collection-errors --tb=no --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing:skip-covered
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
7034 passed, 6 skipped, 16 errors in 175.22s (0:02:55)
Table header: `Name                                                               Stmts   Miss Branch BrPart  Cover   Missing`
TOTAL row: `TOTAL                                                              17638   2024   6368    470    87%`
(The 16 collection errors are the same typer ImportError modules; their modules under scripts/dev_tools/codex_native_converter are measured at 0% and lower the combined total from the cycle 0 value of 92%.)
BaselineFullPassed: 7034
BaselineFullSkipped: 6
BaselineFullFailingNodes: ERROR tests/scripts/dev_tools/codex_native_converter/test_classifier.py; test_cli_apply.py; test_cli_entrypoints.py; test_cli_review.py; test_end_to_end.py; test_intermediate_state.py; test_inventory.py; test_mapping.py; test_parser.py; test_prompt_decomposition_end_to_end.py; test_reporting.py; test_reporting_topology_end_to_end.py; test_rewrites.py; test_section_classifier.py; test_section_intent.py; test_validation.py (all under tests/scripts/dev_tools/codex_native_converter/)
BaselineTotalStmts: 17638
BaselineTotalMiss: 2024
BaselineTotalBranch: 6368
BaselineTotalBrPart: 470
BaselineTotalCover: 87%

Note: cycle 1 recorded `7094 passed, 6 skipped`; this environment passes 7034 because the 16 codex_native_converter modules (60 tests) cannot be collected without `typer`.
