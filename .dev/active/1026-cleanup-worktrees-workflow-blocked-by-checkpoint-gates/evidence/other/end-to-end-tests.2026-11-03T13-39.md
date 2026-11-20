# End-to-End and Manifest Suites (Issue #1026, P6-T2)

Timestamp: 2026-11-03T13-39
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt @SCRATCH/issue-1026-list-p6.txt (Invoke-Pester over the 5 suites below in one process, JUnit to artifacts/pester/pester-junit.xml, coverage disabled); git -C <item worktree> diff --stat MERGE_BASE -- tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
EXIT_CODE: 0
Output Summary: JUnit testcases 164, passed 164, failed 0, skipped 0. The new suite tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 contributes 12 testcases. The diff of the two existing manifest suites against MERGE_BASE is empty, so both are byte-unchanged.

Suites run:

- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (new)
- `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`
- `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`

End-to-end coverage of AC11 and AC12: one `Context` per workflow step (report, manifest Write, `--preserve`, `git commit`, `git push`, `Agent(pr-author)` delegation, receipt Write, `gh pr create`, `--apply`, manifest-authorized removal), each asserting `allow` from every composed hook registered for that tool call; `allows git worktree remove of the SAFE_TO_DELETE path in both removal gates with no checkpoint` (AC11), with the control `denies git worktree remove of a path the manifest does not authorize in both removal gates`; and the inventory row `lists every hook registered for the Bash, Write|Edit, and Agent matchers as composed or exempted`, which reads `.claude/settings.json` (5 composed hooks, 21 exempted hooks, each with a stated reason).

Structure note: the five composed hooks are loaded once in the outermost `BeforeAll`, because the epic-state isolation guard requires every read seam of the suite's loaded closure to be null-mocked there and a Pester mock of a hook-defined seam needs the hook loaded first. A probe measured that the five hooks define no function name with two different bodies and that their shared script variables carry identical values, so one scope composes them; each `Context` arranges only its step. The guard derives no probe seam for this suite (0 findings), so it carries no probe row.

Defect found and fixed in this task: `Test-OrchestrationCleanupScratchWrite` read the temporary-root seam with `@(...)`, so a seam result delivered as one nested array (the shape `, [string[]] @(...)` that the end-to-end mock and the baseline helper mock both return) failed parameter binding inside the leg, and the leg's `catch` answered `$false`. The read now flattens the seam output (`[string[]]@(Get-OrchestrationGateTemporaryRoot | ForEach-Object { $_ })`) in both byte-identical copies; the Claude Cleanup, Codex cleanup, and end-to-end suites were re-run afterwards: 85 passed, 0 failed.
