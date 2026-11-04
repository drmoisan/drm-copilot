# [P6-T7] Push-down contract tests and existing Pester suites after the final format pass (issue #1022)

Timestamp: 2026-11-04T03-22
Command: (1) pwsh -NoProfile -File SCRATCH/issue-1022-p5t4-pytest.ps1, which runs `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -p no:randomly -o addopts='' -q -rA` from the item worktree (the worktree Poetry environment lacks pytest-cov, so the project addopts are cleared); (2) pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite <the seven [P5-T3] suites> -Verbosity None (Invoke-Pester with scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, no coverage, JUnit to artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Push-down contract tests: 34 passed, 0 failed (PYTEST_EXIT_CODE 0), including `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_claude_manifest_powershell_dependency_closure` and `test_every_psscriptroot_occurrence_is_recognized` (each PASSED). Pester gate over the seven suites: 180 passed, 0 failed, 0 errored, 0 skipped; count source `artifacts/pester/pester-junit.xml` (well-formed, tests=180 failures=0 errors=0 skipped=0), equal to the result object.

## Pester counts per suite

| Suite | Tests | Passed | Failed | Errors | Skipped |
|---|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` | 7 | 7 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` | 53 | 53 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1` | 30 | 30 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | 46 | 46 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | 6 | 6 | 0 | 0 | 0 |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 33 | 33 | 0 | 0 | 0 |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | 5 | 5 | 0 | 0 | 0 |

Named cases: `ships an empty allowlist` Passed; `reports no Python invocation beyond the allowlist across the guarded tree` Passed; `reports zero ratchet violations against config/file-size-baseline.json` Passed.

CI: `poshqc / PowerShell QC` (windows-latest shards); `quality-checks7 / Code Quality & Tests (3.11)` through `(3.13)`.
