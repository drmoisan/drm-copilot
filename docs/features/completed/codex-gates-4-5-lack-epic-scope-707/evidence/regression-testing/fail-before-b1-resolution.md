# Fail-Before: Suite A Before Either Sibling Exists ([P1-T3], expect-fail)

Timestamp: 2026-09-27T06-46
Command: sh <SCRATCHPAD>/x707p1-rscoped.sh tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 (R-SCOPED body of plan section 5, launched by route sh with working directory <WORKSPACE_ROOT>)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure observed. The Describe-level BeforeAll failed with CommandNotFoundException because .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 does not exist yet, so all 48 expanded tests failed. PassedCount 0, FailedCount 48, FailedBlocksCount 1, FailedContainersCount 0 (sum 49). Expanded names appear in template form because the tests never ran their data binding.

## Runner output (ANSI colour codes removed; host root replaced by `<WORKSPACE_ROOT>`)

```
RUN_START=2026-09-27T06-46

Starting discovery in 1 files.
Discovery found 48 tests in 138ms.
Running tests.
[-] Describe Codex epic-scope resolution sibling (issue #707) failed
 CommandNotFoundException: The term '<WORKSPACE_ROOT>\.codex\hooks\enforce-orchestration-preimplementation-gate-epic-scope.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
 Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
 at <ScriptBlock>, <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1:31
Tests completed in 404ms
Tests Passed: 0, 
Failed: 48, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
BeforeAll \ AfterAll failed: 1
  - Codex epic-scope resolution sibling (issue #707)
PassedCount: 0
FailedCount: 48
FailedBlocksCount: 1
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=0 | failed=48
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: resolves reason <Reason> for <Label>
FAILED: reports MergeInProgress <Expected> when the MERGE_HEAD probe returns <Expected>
FAILED: reports MergeInProgress <Expected> when the MERGE_HEAD probe returns <Expected>
FAILED: composes an absolute checkpoint path from the resolved session root
FAILED: consults the -C selector worktree HEAD and not the session-root HEAD when a selector is supplied
FAILED: declares the fixed head-match signature without Text or MatchWorktreeHead parameters
FAILED: returns null checkpoint text when the checkpoint file is absent
FAILED: returns the checkpoint text when the checkpoint file exists
FAILED: reads the HEAD branch of a linked worktree through its gitdir file
FAILED: reads the HEAD branch of a main checkout through its git directory
FAILED: resolves a relative gitdir target against the worktree root
FAILED: returns no HEAD branch for a detached HEAD
FAILED: returns no git directory for <Label>
FAILED: returns no git directory for <Label>
FAILED: returns no git directory for <Label>
FAILED: probes MERGE_HEAD in the worktree git directory and reports <Expected>
FAILED: probes MERGE_HEAD in the worktree git directory and reports <Expected>
FAILED: reports no merge in progress when the worktree has no git directory
FAILED: finds the worktree root by ascending to the first level that carries a git directory
FAILED: finds a linked worktree root whose git entry is a gitdir file
FAILED: returns no worktree root for <Label>
FAILED: returns no worktree root for <Label>
FAILED: normalises backslashes, repeated separators, a leading dot segment, and a trailing slash
FAILED: returns a null normalised path for blank input
FAILED: rejects a relative worktree root when composing a path
FAILED: returns null from the checkpoint parser for <Label>
FAILED: returns null from the checkpoint parser for <Label>
FAILED: returns null from the checkpoint parser for <Label>
FAILED: command-leg readiness passes for a ready epic checkpoint while a merge is in progress
FAILED: command-leg readiness names <Conjunct> for <Label>
FAILED: command-leg readiness names <Conjunct> for <Label>
FAILED: command-leg readiness names <Conjunct> for <Label>
FAILED: command-leg readiness names <Conjunct> for <Label>
FAILED: command-leg readiness names <Conjunct> for <Label>
FAILED: command-leg readiness names <Conjunct> for <Label>
FAILED: command-leg readiness names <Conjunct> for <Label>
FAILED: command-leg readiness reports the earliest failed conjunct when several fail
FAILED: command-leg readiness accepts a backslash-separated epic_manifest_path under the epics tree
EXIT_CODE=1
```
