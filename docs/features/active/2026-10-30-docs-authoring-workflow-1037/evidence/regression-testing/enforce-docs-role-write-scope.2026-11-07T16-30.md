# enforce-docs-role-write-scope Suite (P2-T2)

Timestamp: 2026-11-07T16-30
Command: sh SCRATCH/issue-1037-pester-parallel.sh phase2 (`Invoke-PoshQCParallelTest -Root <worktree>`, 8 workers); per-suite counts read from the merged `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1037-junit-suites.ps1; per-file coverage read from the merged `artifacts/pester/powershell-coverage.xml`
EXIT_CODE: 0
Output Summary: `tests/scripts/claude-hooks/enforce-docs-role-write-scope.Tests.ps1`: 55 tests, 55 passed, 0 failed. Line coverage of `.claude/hooks/enforce-docs-role-write-scope.ps1`: 100.00% (68 of 68 lines). Whole run: 17411 tests, 0 failed, 10 skipped; ExitCode 0.

Owner directive 2026-11-07: parallel test gates only

Cases cover rule 5 for the profile path and each of the five `artifact_paths` values, rule 4 for a `.json` page and a notebook, rule 6 for each of the four customization directories, rule 3 for an absolute path outside the root, two `..` escapes and a missing target, rule 1 for each Write-class tool by each of the three read-only roles (12 rows), rule 2 for each role, allowed author writes, pass-through for no `agent_type`, a non-docs `agent_type`, a case variant and an unparseable payload, the absent, unparseable, array and unreadable profile cases, a dependency failure, the two seams, and four entry-tail rows run in process through the `&` route with `[Console]::SetIn` and `CLAUDE_HOOK_INPUT` restored in `finally`.
