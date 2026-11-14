Timestamp: 2026-11-05T05-10
Command: group complete native Pester6 stdout failures and inspect closed JUnit/JaCoCo reports
EXIT_CODE: 1
Output Summary: native Pester 6.2.0; 14298 discovered cases across 507 files; 13977 passed, 311 failed, 10 skipped, 0 Inconclusive, 0 NotRun. Test phase 1073.67 seconds. Reports retain 271 production files, LINE 22791/24365. This run is failed evidence, not acceptance.  The 28 file groups below account for all 311 failures. Candidate source correction list is the 27 directly failing fixture files excluding FileSizePolicy.RepoGate.Tests.ps1. Each fixture will be inspected before editing; no blanket null/success fallback, assertion weakening, skip, production exclusion, or global strict-mock compatibility switch is authorized.  The ignored/untracked MCP payload predates this task (May 7 creation/March 15 content timestamp). It remains untouched. Final CI-equivalent full validation uses a clean current-source projection with the same production/test selection, not a weakened file-size gate.  After one precise batch: ordered format/analyze; targeted native 6.2 test pass; clean full serial profiler/JaCoCo pass; required concurrent shards/completeness/merge; reuse matching full results for overlapping isolation/contracts.  Pester 6 migration authority: https://pester.dev/docs/migrations/v5-to-v6 (unmatched filtered mocks no longer invoke the real command).  Raw complete stdout: SCRATCH/issue-1082-powershell-full-tests-final.log Raw full failures: SCRATCH/issue-1082-full-failures.json Closed reports: SCRATCH/issue-1082-full-pester-junit.xml and SCRATCH/issue-1082-full-pester-coverage.xml
| Failing file | Cases | Disposition |
| --- | ---: | --- |
| tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | 1 | Pre-existing ignored generated payload; no gate edit; clean source projection |
| tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1 | 4 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 | 6 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1 | 22 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | 2 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | 12 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | 6 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | 2 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | 11 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | 6 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 108 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | 3 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 15 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | 8 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | 6 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | 1 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 83 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 2 | Inspect and repair precise reader/resolver/fault fixture; retain behavior/count assertions |
| tests/scripts/host-tools.manifest.Tests.ps1 | 4 | Update committed-baseline expectations and matching fake versions |

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
