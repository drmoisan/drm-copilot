# Phase Gate - Phase 2 - [P2-T11]

Timestamp: 2026-11-19T11-32
Command: sh SCRATCH/issue-1049-gate.sh issue-1049-p2gate (stages 1 to 6 of the plan preamble gate loop, run once from 11:03Z to 11:31Z; test suites through sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh with re-runs only on exit 75)
EXIT_CODE: 0
Output Summary: One clean pass of stages 1 to 6 with no failure and no auto-fix. Pester ExitCode 0 (29272 tests, 0 failed), pytest 17122 passed 0 failed, Jest extension 6142 passed 0 failed, Jest root 6159 passed 0 failed. No failing test outside the pre-existing sets of [P0-T6], [P0-T8] and [P0-T9] (all empty). The three new or extended Pester files are in the merged JUnit. Invoke-PoshQCLeakScan exit 0.

## Stages

| Stage | Command | Exit | Counts |
| --- | --- | --- | --- |
| 1 format | PoshQC Invoke-PoshQCFormat over scripts, tests/scripts (git status --porcelain before and after) | 0 | PORCELAIN: identical; FORMATTED_COUNT 0; ALREADY_FORMATTED_COUNT 985 |
| 1 format | npx prettier --check src test (extensions/drm-copilot) | 0 | `All matched files use Prettier code style!` |
| 1 format | poetry run black --check . | 0 | `1071 files would be left unchanged.` |
| 2 lint | Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 | 0 | 0 findings |
| 2 lint | npm run lint | 0 | 0 problems |
| 2 lint | poetry run ruff check . | 0 | `All checks passed!` |
| 3 type check | npm run typecheck | 0 | 0 `error TS` |
| 3 type check | poetry run pyright | 0 | `0 errors, 0 warnings, 0 informations` |
| 4 architecture | no dependency-cruiser configuration; boundary Pester suites run in stage 5 | n/a | n/a |
| 5 unit | launcher `pester` (attempts 1 to 3 exit 75 queue timeout; attempt 4 ran) | 0 | ExitCode 0; workers 8; 859 suites, 29272 tests, 29254 passed, 0 failed, 18 skipped (merged JUnit); repo line coverage 96.78% |
| 5 unit | launcher `pytest` | 0 | 17122 passed, 6 skipped, 0 failed |
| 5 unit | launcher `jest-extension --coverage` | 0 | 371 suites, 6142 tests passed, 0 failed |
| 5 unit | launcher `jest` (root; attempt 1 exit 75) | 0 | 374 suites, 6159 tests passed, 0 failed |
| 6 contract | generate_codex_agent_variants --check | 0 | no output |
| 6 contract | Invoke-HarnessGeneration.ps1 -Surface all -Check | 0 | `harness-generation: no drift` |
| 6 contract | Invoke-PoshQCLeakScan -Root | 0 | `Leak scan: 898 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.` |

## New or extended Pester files in the merged JUnit

| Test file | Tests | Failures | Errors |
| --- | --- | --- | --- |
| tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.Tests.ps1 | 45 | 0 | 0 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingVendoredReport.Tests.ps1 | 5 | 0 | 0 |
| tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1 | 27 | 0 | 0 |

Informational per-file line coverage from this gate run: PoshQC.VendoredCoverage.psm1 99.09%, PoshQC.Coverage.psm1 94.92%, PoshQC.Testing.psm1 94.30%, PoshQC.psm1 88.52%. The final comparison is [P4-T5].
