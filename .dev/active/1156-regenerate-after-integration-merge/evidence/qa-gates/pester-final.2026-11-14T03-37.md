# Pester Final Gate, run 2 — [P6-T2]

Timestamp: 2026-11-14T03-37
Command: sh SCRATCH/issue-1156-pester-gate.sh (pwsh 7 from the item worktree root: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; launcher exits with the returned ExitCode)
EXIT_CODE: 0
Output Summary: one Invoke-PoshQCParallelTest run at the pushed fix head (orchestrator decision AD-1 applied), workers=8, all 8 shards exit 0, wall-clock 601.8 s; merged JUnit and coverage written at the end of this run. artifacts/pester/pester-junit.xml: 23310 tests, 0 failures, 0 errors, 10 skipped, 23300 passed. Repo-wide line coverage 95.83% (39710 covered, 1727 missed) against the Phase 0 baseline 95.80%. Every named file passes; 74 row cases R01-R74 pass; per-file coverage below.

Run 1 (`pester-final.2026-11-14T03-18.md`) failed three tests; failures 1 and 2 were fixed in the closure-isolation suites, and failure 3 (the no-Python scan of the process seam default) was fixed under orchestrator decision AD-1 (`evidence/other/task-check.P6-T2.2026-11-14T03-25.md`). This run is the one gate re-run after those fixes.

## Named suites (from the JUnit file)

| Suite | Tests | Failures | Errors | Skipped |
|---|---|---|---|---|
| tests/scripts/claude-lib/regeneration/RegenerationConfig.Tests.ps1 | 44 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/RegenerationClassifier.Tests.ps1 | 21 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/RegenerationDelta.Tests.ps1 | 38 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1 | 116 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Merge.Tests.ps1 | 37 | 0 | 0 | 0 |
| tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tip.Tests.ps1 | 24 | 0 | 0 | 0 |
| tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | 3 | 0 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | 54 | 0 | 0 | 0 |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | 12 | 0 | 0 | 0 |
| tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | 743 | 0 | 0 | 0 |
| tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 35 | 0 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1 | 38 | 0 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1 | 18 | 0 | 0 | 0 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 | 0 |
| tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1 | 52 | 0 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 553 | 0 | 0 | 0 |

Result-table rows in `Invoke-RegenerationPath.Tests.ps1`: 74 test cases whose names carry the row IDs R01 through R74, 74 distinct IDs, 0 failed. Structure checks: 4 cases, 0 failed. The renamed check (h) `(h) the process -Invoker default starts one ProcessStartInfo with UseShellExecute false, forwards output to [Console]::Error.WriteLine and returns ExitCode`: 1 case, passed.

## Per-file line coverage (artifacts/pester/powershell-coverage.xml)

| File | Covered | Missed | Line % | Phase 0 baseline |
|---|---|---|---|---|
| .claude/lib/regeneration/Invoke-RegenerationPath.ps1 | 269 | 32 | 89.37 | new file |
| .claude/lib/regeneration/RegenerationConfig.psm1 | 98 | 2 | 98.00 | new file |
| .claude/lib/regeneration/RegenerationClassifier.psm1 | 30 | 0 | 100.00 | new file |
| .claude/lib/regeneration/RegenerationDelta.psm1 | 102 | 0 | 100.00 | new file |
| .claude/hooks/enforce-epic-merge-gate-regeneration.ps1 | 39 | 5 | 88.64 | new file |
| .claude/hooks/hook-epic-regeneration.ps1 | 89 | 2 | 97.80 | new file |
| .codex/hooks/enforce-epic-merge-gate-regeneration.ps1 | 43 | 1 | 97.73 | new file |
| .codex/hooks/hook-epic-regeneration.ps1 | 89 | 2 | 97.80 | new file |
| .claude/hooks/enforce-epic-merge-gate.ps1 | 144 | 2 | 98.63 | 98.63 |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 177 | 1 | 99.44 | 99.43 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 129 | 3 | 97.73 | 97.66 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 148 | 3 | 98.01 | 97.96 |

Every new file is at or above 85%; no edited entry file is below its Phase 0 baseline. The process seam default of `Invoke-RegenerationPath.ps1` is not executed by any test (tests inject `-Invoker` or mock the wrapper, and start no process); its shape is pinned by the AST check (h).
