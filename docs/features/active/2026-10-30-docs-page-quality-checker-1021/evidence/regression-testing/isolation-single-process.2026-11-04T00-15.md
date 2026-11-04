# Isolation: Fresh Single-Process Run over tests/scripts - Issue #1021

Timestamp: 2026-11-04T00-15
Task: [P6-T6]
Command: `sh SCRATCH/issue-1021-qa-full.sh` (PowerShell 7: `Import-Module scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts`, one fresh process, repository run settings with coverage; then the supplemental name pass `Invoke-Pester` over `tests/scripts` with the repository run settings, `Run.PassThru`, coverage and JUnit off); report from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` through `SCRATCH/issue-1021-report.ps1`; comparison through `sh SCRATCH/issue-1021-compare.sh`
EXIT_CODE: 255
ExpectedExitCode: 255
Output Summary: JUnit root `tests=14484 failures=409 errors=6 skipped=10`; supplemental pass `TOTAL=14484 PASSED=14065 FAILED=409 SKIPPED=10 NOTRUN=0 FAILED_BLOCKS=6 FAILED_CONTAINERS=0`. Overall line coverage 92.88% (22666 of 24403). The sorted set of 409 failing tests and 6 failed blocks is identical to the [P0-T8] baseline set (`baseline-pester-coverage.2026-11-03T22-19.md`): 0 new, 0 removed. No failing test and no failed block is under `tests/scripts/claude-lib/docs`. CI: CI-PESTER.

## Notes

- EXIT_CODE 255 is the process exit of `Invoke-PoshQCTest` under the repository run setting `Run.Exit = $true` with 409 failures (capped at 255), the same as the [P0-T8] baseline. Because the process exits inside `Invoke-PoshQCTest`, the report step was run separately on the written artifacts.
- `artifacts/pester/pester-junit.xml` is truncated (14,869 bytes, the same size as at baseline) at a failure message holding an escape character, a known Pester JUnit export defect on this host; the totals were read from the `testsuites` root element, which Pester writes first. The coverage XML was written completely. Failing names come from the supplemental pass.
- The pre-existing failures are the host failures the delegation names as out of scope: the `run-actionlint.Tests.ps1` `$env:PATH` leak (#1066), whose victims are the codex-hook and codex-script suites, and the Windows-style fixtures under `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` (#1067). None of those files is touched by this feature.
- Test count: 14484 against 14108 at baseline (+376, the new and extended docs suites).

## Comparison with the [P0-T8] baseline

| Measure | Baseline ([P0-T8]) | Final ([P6-T6]) |
|---|---|---|
| Tests | 14108 | 14484 |
| Failures | 409 | 409 |
| Errors (failed blocks) | 6 | 6 |
| Skipped | 10 | 10 |
| Failing tests and blocks, sorted set | 415 lines | 415 lines, identical (0 new, 0 removed) |
| Failures under `tests/scripts/claude-lib/docs` | 0 | 0 |
| Overall line coverage | 92.66% (21914 of 23651) | 92.88% (22666 of 24403) |

Failed blocks (identical in both runs): `Bundled Codex PreToolUse hooks run from the bundle location (issue #697)`; `Codex PreToolUse hooks honour the native stdin transport contract`; `Codex epic preparation, wave, merge, and worktree gates`; `Codex routing PowerShell wrappers match the Python CLI corpus (issue #697)`; `Every registered Codex PreToolUse handler accepts every tool name its matcher admits`; `Legacy Codex hooks use native lifecycle contracts`.

## Per-file line coverage (same run)

| File | Line coverage |
|---|---|
| `.claude/lib/docs/DocsPageMarkdown.psm1` | 100.00% (102 of 102) |
| `.claude/lib/docs/DocsPageFrontMatter.psm1` | 100.00% (180 of 180) |
| `.claude/lib/docs/DocsPageMetadata.psm1` | 100.00% (109 of 109) |
| `.claude/lib/docs/DocsPageLinks.psm1` | 100.00% (114 of 114) |
| `.claude/lib/docs/DocsPageDiataxis.psm1` | 100.00% (54 of 54) |
| `.claude/lib/docs/DocsPageOrphans.psm1` | 100.00% (28 of 28) |
| `.claude/lib/docs/DocsPageCheck.psm1` | 100.00% (157 of 157) |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 87.42% (132 of 151) |
| `.claude/lib/docs/DocsSchema.psm1` | 100.00% (129 of 129) |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 97.30% (72 of 74) |
