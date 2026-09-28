# B1 Scoped Pester: Suite A ([P1-T9])

Timestamp: 2026-09-27T06-51
Command: sh <SCRATCHPAD>/x707p1-rscoped.sh tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 (R-SCOPED body of plan section 5, route sh, working directory <WORKSPACE_ROOT>)
EXIT_CODE: 0
Output Summary: PassedCount 48, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. All 11 expanded A1 names and all 7 expanded A23 names appear on PASSED lines.

## Runner output (ANSI colour codes removed; host root replaced by `<WORKSPACE_ROOT>`)

```
RUN_START=2026-09-27T06-51

Starting discovery in 1 files.
Discovery found 48 tests in 138ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
 1.4s (920ms|356ms)
Tests completed in 1.41s
Tests Passed: 48, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 48
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=48 | failed=0
PASSED: resolves reason epic-scope for the session-root HEAD matching integration_branch
PASSED: resolves reason epic-scope for a -C selector worktree whose HEAD matches integration_branch
PASSED: resolves reason session-root-unresolved for a session root outside any worktree
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an absent epic checkpoint
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an unparseable epic checkpoint
PASSED: resolves reason epic-checkpoint-absent-or-unparseable for an array-shaped epic checkpoint
PASSED: resolves reason route_id for a route_id other than epic
PASSED: resolves reason integration_branch for an empty integration_branch
PASSED: resolves reason selector-unresolved for a -C selector outside any worktree
PASSED: resolves reason branch-mismatch for an effective HEAD that differs from integration_branch
PASSED: resolves reason branch-mismatch for a detached HEAD
PASSED: reports MergeInProgress True when the MERGE_HEAD probe returns True
PASSED: reports MergeInProgress False when the MERGE_HEAD probe returns False
PASSED: composes an absolute checkpoint path from the resolved session root
PASSED: consults the -C selector worktree HEAD and not the session-root HEAD when a selector is supplied
PASSED: declares the fixed head-match signature without Text or MatchWorktreeHead parameters
PASSED: returns null checkpoint text when the checkpoint file is absent
PASSED: returns the checkpoint text when the checkpoint file exists
PASSED: reads the HEAD branch of a linked worktree through its gitdir file
PASSED: reads the HEAD branch of a main checkout through its git directory
PASSED: resolves a relative gitdir target against the worktree root
PASSED: returns no HEAD branch for a detached HEAD
PASSED: returns no git directory for a missing git entry
PASSED: returns no git directory for a gitdir file without a gitdir line
PASSED: returns no git directory for a relative worktree root
PASSED: probes MERGE_HEAD in the worktree git directory and reports True
PASSED: probes MERGE_HEAD in the worktree git directory and reports False
PASSED: reports no merge in progress when the worktree has no git directory
PASSED: finds the worktree root by ascending to the first level that carries a git directory
PASSED: finds a linked worktree root whose git entry is a gitdir file
PASSED: returns no worktree root for a relative start path
PASSED: returns no worktree root for an ascent that reaches the filesystem root without a git entry
PASSED: normalises backslashes, repeated separators, a leading dot segment, and a trailing slash
PASSED: returns a null normalised path for blank input
PASSED: rejects a relative worktree root when composing a path
PASSED: returns null from the checkpoint parser for null text
PASSED: returns null from the checkpoint parser for whitespace text
PASSED: returns null from the checkpoint parser for a JSON scalar
PASSED: command-leg readiness passes for a ready epic checkpoint while a merge is in progress
PASSED: command-leg readiness names checkpoint-absent for a null checkpoint
PASSED: command-leg readiness names route_id for a route_id other than epic
PASSED: command-leg readiness names epic_feature_folder for a missing epic_feature_folder
PASSED: command-leg readiness names epic_manifest_path for an epic_manifest_path outside docs/features/epics/
PASSED: command-leg readiness names integration_branch for a missing integration_branch
PASSED: command-leg readiness names features for an empty features array
PASSED: command-leg readiness names merge-in-progress for no merge in progress
PASSED: command-leg readiness reports the earliest failed conjunct when several fail
PASSED: command-leg readiness accepts a backslash-separated epic_manifest_path under the epics tree
EXIT_CODE=0
```
