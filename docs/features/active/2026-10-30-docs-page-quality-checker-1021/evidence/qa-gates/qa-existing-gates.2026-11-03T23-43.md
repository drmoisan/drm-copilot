# QA Existing Gates on the Final Tree - Issue #1021

Timestamp: 2026-11-03T23-43
Task: [P6-T4]
Command: re-run of [P5-T3], [P5-T4] and [P5-T5] (three commands below)
EXIT_CODE: 0
Output Summary: [P5-T3] 105 of 105 passed; [P5-T4] 32 passed serial and 32 passed with `-n auto`, 0 failed; [P5-T5] 52 tests, 0 failures, 0 errors. `Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1` and `tests/scripts/dev_tools` show no diff from MERGE_BASE and no working-tree change.

## [P5-T3] 1020 contract suites

Timestamp: 2026-11-03T23-43
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1,tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1,tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1 issue-1021-p6-contracts.txt`
EXIT_CODE: 0
Output Summary: TOTAL=105 PASSED=105 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0.

## [P5-T4] Push-down contract tests

Timestamp: 2026-11-03T23-43
Command: `sh SCRATCH/issue-1021-pytest.sh` (serial, `--no-cov`) and `sh SCRATCH/issue-1021-pytest-xdist.sh` (`--strict-markers --strict-config -n auto`) over `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`
EXIT_CODE: 0
Output Summary: `32 passed` in each run; 0 failed.

## [P5-T5] Scanning suites

Timestamp: 2026-11-03T23-43
Command: `pwsh -NoProfile -File SCRATCH/issue-1021-junit.ps1` over `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` (JUnit to `artifacts/pester/pester-junit.xml`)
EXIT_CODE: 0
Output Summary: JUnit root `tests=52 failures=0 errors=0 skipped=0` (6, 33, 8 and 5 tests per suite, 0 failures each).
