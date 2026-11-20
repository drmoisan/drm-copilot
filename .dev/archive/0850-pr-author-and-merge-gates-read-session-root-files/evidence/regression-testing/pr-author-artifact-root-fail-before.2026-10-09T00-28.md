# P6-T3 [expect-fail] T-PRA-IAR fail-before run

Timestamp: 2026-10-09T00-28
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
EXIT_CODE: 0
Output Summary:
  Failed: 12, 
  TotalCount=15
  PassedCount=3
  FailedCount=12
  FAILED: enforce-pr-author-skill.ps1 item artifact root.allows an OtherWorktree target whose artifacts exist only in the item worktree
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.ignores session-root PR artifacts when the target is another worktree
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.reads summary, body, receipt and summary timestamp beneath the resolved item root
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.compares receipt freshness against the item worktree summary
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.resolves the target once and reuses it for artifacts, preflight and Check 6
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.denies a relative body path for an OtherWorktree target and names the absolute path
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.keeps SessionRoot behavior with absolute artifact paths
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.reads epic-scope PR artifacts beneath the epic checkpoint worktree
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
  FAILED: enforce-pr-author-skill.ps1 item artifact root.denies when the epic checkpoint path does not end with the epic checkpoint suffix
  FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1

Note: Expected outcome: FAILED lines include the eleven rows P6-T3 names (the gate still reads artifacts relative to the process directory and resolves after Case C).

## Full output

```text
Pester v5.6.1

Starting discovery in 1 files.
Discovery found 15 tests in 110ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1'
Describing enforce-pr-author-skill.ps1 item artifact root
  [-] allows an OtherWorktree target whose artifacts exist only in the item worktree
 259ms (239ms|20ms)
   at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:111
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:111
   Expected strings to be the same, but they were different.
   Expected length: 5
   Actual length:   4
   Strings differ at index 0.
   Expected: 'allow'
   But was:  'deny'
              ^
  [-] ignores session-root PR artifacts when the target is another worktree
 452ms (451ms|1ms)
   at $reason | Should -BeLike 'PR_CONTEXT_MISSING*', tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:127
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:127
   Expected like wildcard 'PR_CONTEXT_MISSING*' to match 'PR_BODY_PATH_NONCANONICAL: `--body-file` must reference a canonical `artifacts/pr_body_<N>.md` file produced by the pr-author skill. The path supplied does not match `artifacts/pr_body_<N>.md`.', but it did not match.
  [-] reads summary, body, receipt and summary timestamp beneath the resolved item root
 314ms (313ms|0ms)
   at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:140
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:140
   Expected strings to be the same, but they were different.
   Expected length: 5
   Actual length:   4
   Strings differ at index 0.
   Expected: 'allow'
   But was:  'deny'
              ^
  [-] compares receipt freshness against the item worktree summary
 337ms (337ms|1ms)
   at $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_AUTHOR_RECEIPT_STALE*', tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:164
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:164
   Expected like wildcard 'PR_AUTHOR_RECEIPT_STALE*' to match 'PR_BODY_PATH_NONCANONICAL: `--body-file` must reference a canonical `artifacts/pr_body_<N>.md` file produced by the pr-author skill. The path supplied does not match `artifacts/pr_body_<N>.md`.', but it did not match.
  [-] resolves the target once and reuses it for artifacts, preflight and Check 6
 366ms (366ms|1ms)
   at $script:CapturedEpicPath | Should -Be $script:ItemCheckpointPath, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:191
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:191
   Expected '/synthetic-worktrees/item-a/artifacts/orchestration/orchestrator-state.json', but got $null.
  [-] denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING
 32ms (32ms|1ms)
   at $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:NoTargetCode), tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:205
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:205
   Expected like wildcard 'TARGET_WORKTREE_NOT_DERIVABLE*' to match 'PR_CONTEXT_MISSING: `artifacts/pr_context.summary.txt` is absent. Run `mcp__drm-copilot__collect_pr_context` before creating or editing the PR body.', but it did not match.
  [-] denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING
 41ms (40ms|1ms)
   at $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ("{0}*" -f $script:AmbiguityCode), tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:219
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:219
   Expected like wildcard 'TARGET_WORKTREE_AMBIGUOUS*' to match 'PR_CONTEXT_MISSING: `artifacts/pr_context.summary.txt` is absent. Run `mcp__drm-copilot__collect_pr_context` before creating or editing the PR body.', but it did not match.
  [-] denies a relative body path for an OtherWorktree target and names the absolute path
 388ms (388ms|1ms)
   at $reason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*', tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:233
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:233
   Expected like wildcard 'PR_BODY_PATH_NONCANONICAL*' to match $null, but it did not match.
 382ms (381ms|1ms)
  [-] applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison
 323ms (323ms|1ms)
   at $decision.hookSpecificOutput.permissionDecision | Should -Be $case.Expected -Because "root '$($case.Root)' against body '$($case.Body)'", tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:260
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:260
   Expected strings to be the same, because root 'C:/Repo/Item-A' against body 'c:/repo/item-a/artifacts/pr_body_1.md', but they were different.
   Expected length: 5
   Actual length:   4
   Strings differ at index 0.
   Expected: 'allow'
   But was:  'deny'
              ^
  [-] keeps SessionRoot behavior with absolute artifact paths
 347ms (347ms|1ms)
   at $path.StartsWith('/synthetic-worktrees/session/artifacts/') | Should -BeTrue -Because "every artifact read is beneath the session root ($path)", tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:279
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:279
   Expected $true, because every artifact read is beneath the session root (), but got $false.
  [-] reads epic-scope PR artifacts beneath the epic checkpoint worktree
 64ms (64ms|0ms)
   at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:292
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:292
   Expected strings to be the same, but they were different.
   Expected length: 5
   Actual length:   4
   Strings differ at index 0.
   Expected: 'allow'
   But was:  'deny'
              ^
 41ms (41ms|1ms)
  [-] denies when the epic checkpoint path does not end with the epic checkpoint suffix
 50ms (49ms|1ms)
   at $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*', tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:327
   at <ScriptBlock>, tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1:327
   Expected like wildcard 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*' to match 'PR_BODY_PATH_NONCANONICAL: `--body-file` must reference a canonical `artifacts/pr_body_<N>.md` file produced by the pr-author skill. The path supplied does not match `artifacts/pr_body_<N>.md`.', but it did not match.
 335ms (334ms|1ms)
Tests completed in 4.43s
Tests Passed: 3, 
Failed: 12, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
TotalCount=15
PassedCount=3
FailedCount=12
FAILED: enforce-pr-author-skill.ps1 item artifact root.allows an OtherWorktree target whose artifacts exist only in the item worktree
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.ignores session-root PR artifacts when the target is another worktree
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.reads summary, body, receipt and summary timestamp beneath the resolved item root
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.compares receipt freshness against the item worktree summary
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.resolves the target once and reuses it for artifacts, preflight and Check 6
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.denies a relative body path for an OtherWorktree target and names the absolute path
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.keeps SessionRoot behavior with absolute artifact paths
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.reads epic-scope PR artifacts beneath the epic checkpoint worktree
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
FAILED: enforce-pr-author-skill.ps1 item artifact root.denies when the epic checkpoint path does not end with the epic checkpoint suffix
FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
```
