# [P5-T3] Pester gate: existing suites that scan LIB, the bundle or CORE (issue #1022)

Timestamp: 2026-11-04T01-55
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1,tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1,tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1,tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1,tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1,tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1,tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml; one process; none of the seven suites is edited)
EXIT_CODE: 0
Output Summary: 180 passed, 0 failed, 0 errored, 0 skipped (result object Passed=180 Failed=0 Skipped=0; JUnit well-formed, counts read from it, zero `<failure>` elements). The run follows the [P5-T1] mirror copy and the [P5-T2] `core.json` append.

## Counts per suite (JUnit `testsuite` elements)

| Suite | tests | failures | errors | skipped | passed |
|---|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` | 7 | 0 | 0 | 0 | 7 |
| `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` | 53 | 0 | 0 | 0 | 53 |
| `tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1` | 30 | 0 | 0 | 0 | 30 |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` | 46 | 0 | 0 | 0 | 46 |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | 6 | 0 | 0 | 0 | 6 |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 33 | 0 | 0 | 0 | 33 |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | 5 | 0 | 0 | 0 | 5 |

## Named tests

- `It 'ships an empty allowlist'` (`enforcement hooks must not invoke Python.allowlist policy`): `status="Passed"`.
- `It 'reports no Python invocation beyond the allowlist across the guarded tree'` (`enforcement hooks must not invoke Python.repository scan`): `status="Passed"`; the guarded tree now holds the eighteen new `.claude/lib/docs/` modules and their bundle copies.

## Acceptance criteria checked off

- spec S19 (no file under `.claude/lib/docs/` contains an interpreter invocation or an `&` call through a variable, member or expression: `enforcement-hooks-no-python-invocation.Tests.ps1` passes with its empty allowlist): proven by this task.

CI: `poshqc / PowerShell QC` (windows-latest shards).
