# P0-T28 Coverage baseline CG-PREM

Timestamp: 2026-10-08T23-49
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 -CoveragePath .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 -CoverageOutputPath SCRATCH/cov-prem-base.xml -ReportPath SCRATCH/cov-prem-base.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=151
  PassedCount=151
  FailedCount=0
  COVERAGE file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 AnalyzedLines=109 CoveredLines=101 LinePercent=92.66
  Baseline failure set (CG-PREM): empty
  Baseline container set (CG-PREM): empty
  BASEPCT PREM (.claude/hooks/enforce-parallel-worktree-removal-gate.ps1): 92.66

## Full output

```text
Pester v5.6.1

Starting discovery in 5 files.
Discovery found 151 tests in 241ms.
Starting code coverage.
Code Coverage preparation finished after 155 ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1
 Context commands outside scope are allowed unconditionally
 62ms (42ms|21ms)
 11ms (11ms|1ms)
 53ms (52ms|0ms)
 12ms (11ms|1ms)
 19ms (18ms|1ms)
 11ms (11ms|0ms)
 Context allow when the matched item merge_status is terminal
 91ms (90ms|1ms)
 20ms (19ms|0ms)
 33ms (33ms|1ms)
 Context deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status
 29ms (27ms|1ms)
 26ms (26ms|0ms)
 24ms (24ms|1ms)
 24ms (23ms|1ms)
 21ms (20ms|0ms)
 23ms (22ms|0ms)
 21ms (21ms|0ms)
 Context deny fail-closed on an unusable checkpoint or an unmatched path
 26ms (25ms|1ms)
 21ms (20ms|0ms)
 38ms (38ms|0ms)
 23ms (23ms|1ms)
 Context read seam binding (the mocked seam value determines the decision)
 55ms (54ms|1ms)
 31ms (31ms|0ms)
 9ms (9ms|0ms)
 Context path normalization
 21ms (20ms|1ms)
 23ms (22ms|1ms)
 21ms (20ms|1ms)
 Context Resolve-CommandLineInvocationTarget for the parallel gate
 8ms (8ms|1ms)
 7ms (6ms|0ms)
 Context Find-ParallelWorktreeItemRecord helper
 7ms (6ms|1ms)
 5ms (5ms|0ms)
 5ms (4ms|0ms)
 5ms (4ms|0ms)
 9ms (9ms|0ms)
 Context Test-ParallelWorktreeRemovalAllowed helper
 8ms (7ms|1ms)
 5ms (5ms|1ms)
 11ms (11ms|1ms)
 Context real Test-Path read seam
 46ms (46ms|1ms)
 27ms (27ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 22ms (21ms|1ms)
 14ms (14ms|0ms)
 8ms (8ms|0ms)
 8ms (7ms|0ms)
 8ms (7ms|0ms)
 22ms (21ms|0ms)
 65ms (64ms|0ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest branch
 56ms (55ms|1ms)
 23ms (23ms|0ms)
 28ms (28ms|0ms)
 10ms (10ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1 epic authorization
 Context epic authorization branch (issue #688)
 28ms (25ms|3ms)
 47ms (47ms|1ms)
 28ms (28ms|1ms)
 32ms (31ms|1ms)
 39ms (38ms|1ms)
 38ms (37ms|1ms)
 52ms (51ms|1ms)
 56ms (55ms|1ms)
 66ms (65ms|1ms)
 53ms (52ms|1ms)
 68ms (66ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate trigger scoping (issue #545)
 Context operand resolution - the --force flag never becomes the path
 17ms (14ms|3ms)
 Context under-match removal - a relocating spelling is now in scope
 54ms (52ms|2ms)
 Context over-match removal - a quoted mention is not an invocation
 16ms (14ms|2ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing parallel worktree-removal gate run-target resolution
 89ms (87ms|2ms)
 51ms (50ms|1ms)
 53ms (53ms|1ms)
 45ms (45ms|1ms)
 49ms (48ms|1ms)
 11ms (10ms|1ms)

Running tests from 'tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix
 73ms (71ms|2ms)
 30ms (29ms|1ms)
 43ms (42ms|1ms)
 36ms (35ms|1ms)
 33ms (32ms|1ms)
 36ms (36ms|1ms)
 41ms (40ms|1ms)
 32ms (31ms|1ms)
 33ms (32ms|1ms)
 31ms (30ms|1ms)
 31ms (30ms|1ms)
 45ms (44ms|1ms)
 33ms (32ms|1ms)
 31ms (30ms|1ms)
 28ms (28ms|1ms)
 30ms (30ms|1ms)
 32ms (31ms|1ms)
 30ms (29ms|1ms)
 33ms (32ms|1ms)
 33ms (32ms|1ms)
 38ms (37ms|1ms)
 33ms (32ms|1ms)
 35ms (34ms|1ms)
 33ms (32ms|1ms)
 35ms (32ms|3ms)
 40ms (39ms|1ms)
 35ms (34ms|1ms)
 34ms (33ms|1ms)
 31ms (30ms|1ms)
 33ms (32ms|1ms)
 31ms (30ms|1ms)
 32ms (32ms|1ms)
 46ms (45ms|1ms)
 33ms (32ms|1ms)
 37ms (36ms|1ms)
 29ms (28ms|1ms)
 38ms (37ms|1ms)
 29ms (28ms|1ms)
 28ms (27ms|1ms)
 60ms (59ms|1ms)
 51ms (50ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix
 32ms (30ms|2ms)
 22ms (21ms|1ms)
 22ms (21ms|1ms)
 23ms (22ms|1ms)
 23ms (22ms|1ms)
 25ms (25ms|1ms)
 22ms (21ms|1ms)
 24ms (23ms|1ms)
 22ms (21ms|1ms)
 24ms (24ms|1ms)
 23ms (23ms|1ms)
 25ms (24ms|1ms)
 23ms (22ms|1ms)
 31ms (31ms|1ms)
 24ms (24ms|1ms)
 26ms (25ms|1ms)
 30ms (29ms|1ms)
 31ms (30ms|1ms)
 28ms (27ms|1ms)
 33ms (32ms|1ms)
 34ms (33ms|1ms)
 42ms (41ms|1ms)
 39ms (38ms|1ms)
 52ms (50ms|2ms)
 52ms (50ms|1ms)
 51ms (50ms|1ms)
 57ms (56ms|1ms)
 67ms (66ms|1ms)
 51ms (49ms|2ms)
 48ms (47ms|1ms)
 43ms (42ms|1ms)
 46ms (45ms|1ms)
 41ms (40ms|1ms)
 34ms (33ms|1ms)
 28ms (27ms|1ms)
 28ms (27ms|1ms)
 25ms (24ms|1ms)
 27ms (26ms|1ms)
 24ms (23ms|1ms)
 42ms (42ms|1ms)
 42ms (41ms|1ms)
Tests completed in 6.65s
Tests Passed: 151, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 453 ms.
Covered 91.33% / 75%. 150 analyzed Commands in 1 File.
Missed commands:

File                                       Class Function                                             Line Command
----                                       ----- --------                                             ---- -------
enforce-parallel-worktree-removal-gate.ps1                                                              54 $script:Para…
enforce-parallel-worktree-removal-gate.ps1       Get-ParallelWorktreeRemovalGateEpicCheckpointContent  105 return (Get-…
enforce-parallel-worktree-removal-gate.ps1       Get-ParallelWorktreeRemovalGateEpicCheckpointContent  105 Get-Content …
enforce-parallel-worktree-removal-gate.ps1       Invoke-ParallelWorktreeRemovalGateDecision            324 return Get-P…
enforce-parallel-worktree-removal-gate.ps1       Invoke-ParallelWorktreeRemovalGateDecision            327 return Get-P…
enforce-parallel-worktree-removal-gate.ps1                                                             459 $entryPointR…
enforce-parallel-worktree-removal-gate.ps1                                                             459 Invoke-Paral…
enforce-parallel-worktree-removal-gate.ps1                                                             460 if ($entryPo…
enforce-parallel-worktree-removal-gate.ps1                                                             461 $entryPointR…
enforce-parallel-worktree-removal-gate.ps1                                                             461 $entryPointR…
enforce-parallel-worktree-removal-gate.ps1                                                             461 Write-Output
enforce-parallel-worktree-removal-gate.ps1                                                             464 ([int]$entry…
enforce-parallel-worktree-removal-gate.ps1                                                             464 [int]$entryP…


TotalCount=151
PassedCount=151
FailedCount=0
COVERAGE file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 AnalyzedLines=109 CoveredLines=101 LinePercent=92.66
HIT file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 Lines=37,40,45,46,49,51,57,60,76,77,79,102,103,126,148,149,150,151,152,153,155,157,161,162,163,195,196,198,199,200,203,207,208,209,212,213,214,217,237,238,240,241,242,244,252,253,254,255,268,269,270,271,272,293,294,295,299,300,301,302,303,307,308,309,315,316,322,323,326,329,330,331,332,335,359,360,361,362,363,366,368,369,370,383,385,386,387,400,401,402,406,407,408,410,438,441,442,445,446,448,452
MISSED file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 Lines=54,105,324,327,459,460,461,464
```
