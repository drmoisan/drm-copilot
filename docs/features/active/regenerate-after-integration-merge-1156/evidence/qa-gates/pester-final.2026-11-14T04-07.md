# Pester Final Gate, run 3 (QA loop re-run) — [P6-T2]

Timestamp: 2026-11-14T04-07
Command: sh SCRATCH/issue-1156-pester-gate.sh (pwsh 7 from the item worktree root: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; launcher exits with the returned ExitCode)
EXIT_CODE: 0
Output Summary: one Invoke-PoshQCParallelTest run at the head that holds the [P6-T8] coverage tests and the merge of origin/main (#1174), workers=8, all 8 shards exit 0, wall-clock 697.59 s; merged JUnit and coverage written at the end of this run. artifacts/pester/pester-junit.xml: 24326 tests, 0 failures, 0 errors, 10 skipped, 24316 passed. Repo-wide line coverage 95.90% (40284 covered, 1721 missed) against the Phase 0 baseline 95.80%. Every named file passes; 74 row cases R01-R74 pass; per-file coverage below.

The loop was re-run from [P6-T1] because [P6-T8] added tests (`evidence/other/task-check.P6-T8.2026-11-14T03-53.md`) and origin/main was merged; run 2 is `pester-final.2026-11-14T03-37.md`.

## Named suites (from the JUnit file)

| Suite | Tests | Failures | Errors | Skipped |
|---|---|---|---|---|
| tests/scripts/claude-lib/regeneration/RegenerationConfig.Tests.ps1 | 44 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/RegenerationClassifier.Tests.ps1 | 21 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/RegenerationDelta.Tests.ps1 | 38 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1 | 122 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Merge.Tests.ps1 | 37 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tip.Tests.ps1 | 24 | 0 | 0 | 0 |
| tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | 3 | 0 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | 54 | 0 | 0 | 0 |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | 12 | 0 | 0 | 0 |
| tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | 743 | 0 | 0 | 0 |
| tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 35 | 0 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1 | 38 | 0 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1 | 22 | 0 | 0 | 0 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 | 0 |
| tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1 | 52 | 0 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 567 | 0 | 0 | 0 |

Result-table rows in `Invoke-RegenerationPath.Tests.ps1`: 74 test cases carrying the row IDs R01 through R74, 74 distinct IDs, 0 failed. Structure checks: 4 cases, 0 failed. Check (h) for the process `-Invoker` default (orchestrator decision AD-1): 1 case, passed.

## Per-file line coverage (artifacts/pester/powershell-coverage.xml)

| File | Covered | Missed | Line % | Phase 0 baseline |
|---|---|---|---|---|
| .claude/lib/regeneration/Invoke-RegenerationPath.ps1 | 274 | 27 | 91.03 | new file |
| .claude/lib/regeneration/RegenerationConfig.psm1 | 98 | 2 | 98.00 | new file |
| .claude/lib/regeneration/RegenerationClassifier.psm1 | 30 | 0 | 100.00 | new file |
| .claude/lib/regeneration/RegenerationDelta.psm1 | 102 | 0 | 100.00 | new file |
| .claude/hooks/enforce-epic-merge-gate-regeneration.ps1 | 44 | 0 | 100.00 | new file |
| .claude/hooks/hook-epic-regeneration.ps1 | 89 | 2 | 97.80 | new file |
| .codex/hooks/enforce-epic-merge-gate-regeneration.ps1 | 43 | 1 | 97.73 | new file |
| .codex/hooks/hook-epic-regeneration.ps1 | 89 | 2 | 97.80 | new file |
| .claude/hooks/enforce-epic-merge-gate.ps1 | 144 | 2 | 98.63 | 98.63 |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 177 | 1 | 99.44 | 99.43 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 129 | 3 | 97.73 | 97.66 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 148 | 3 | 98.01 | 97.96 |

Every new file is at or above 90% (and therefore at or above the 85% threshold); no edited entry file is below its Phase 0 baseline. The 27 uncovered lines of `Invoke-RegenerationPath.ps1` are the seam defaults (`-TestPath`, `-ReadText`, the git and process `-Invoker` defaults, `-UtcNow`) and the guarded script body, which tests do not execute because they touch the file system, git, a process, or the clock.
