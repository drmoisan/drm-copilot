# P8-T7 Coverage CG-PREM final

Timestamp: 2026-10-09T00-54
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 -CoveragePath .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 -CoverageOutputPath SCRATCH/cov-prem-final.xml -ReportPath SCRATCH/cov-prem-final.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=152
  PassedCount=152
  FailedCount=0
  COVERAGE file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 AnalyzedLines=109 CoveredLines=101 LinePercent=92.66

## Full output

```text
Pester v5.6.1

Starting discovery in 5 files.
Discovery found 152 tests in 234ms.
Starting code coverage.
Code Coverage preparation finished after 147 ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1
 Context commands outside scope are allowed unconditionally
 64ms (43ms|21ms)
 12ms (11ms|1ms)
 50ms (50ms|1ms)
 12ms (11ms|1ms)
 18ms (17ms|1ms)
 10ms (10ms|0ms)
 Context allow when the matched item merge_status is terminal
 90ms (89ms|1ms)
 20ms (20ms|0ms)
 30ms (30ms|0ms)
 Context deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status
 29ms (27ms|2ms)
 25ms (25ms|0ms)
 25ms (24ms|0ms)
 23ms (23ms|1ms)
 22ms (21ms|0ms)
 31ms (31ms|0ms)
 21ms (20ms|0ms)
 Context deny fail-closed on an unusable checkpoint or an unmatched path
 25ms (24ms|1ms)
 21ms (20ms|0ms)
 27ms (27ms|0ms)
 22ms (22ms|0ms)
 Context read seam binding (the mocked seam value determines the decision)
 54ms (53ms|1ms)
 30ms (29ms|0ms)
 10ms (9ms|0ms)
 Context path normalization
 22ms (21ms|1ms)
 19ms (19ms|1ms)
 19ms (19ms|0ms)
 Context Resolve-CommandLineInvocationTarget for the parallel gate
 18ms (17ms|1ms)
 6ms (6ms|0ms)
 Context Find-ParallelWorktreeItemRecord helper
 7ms (6ms|1ms)
 4ms (4ms|0ms)
 4ms (4ms|0ms)
 5ms (4ms|0ms)
 7ms (7ms|0ms)
 Context Test-ParallelWorktreeRemovalAllowed helper
 7ms (6ms|1ms)
 5ms (4ms|0ms)
 6ms (5ms|0ms)
 Context real Test-Path read seam
 47ms (46ms|1ms)
 24ms (23ms|0ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 19ms (18ms|1ms)
 17ms (16ms|0ms)
 8ms (8ms|0ms)
 7ms (7ms|0ms)
 7ms (6ms|0ms)
 22ms (21ms|0ms)
 20ms (19ms|0ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest branch
 83ms (82ms|1ms)
 22ms (22ms|0ms)
 29ms (28ms|0ms)
 11ms (10ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate.ps1 epic authorization
 Context epic authorization branch (issue #688)
 26ms (24ms|2ms)
 22ms (22ms|0ms)
 27ms (26ms|0ms)
 27ms (27ms|0ms)
 31ms (31ms|1ms)
 31ms (31ms|1ms)
 41ms (40ms|1ms)
 31ms (30ms|1ms)
 31ms (30ms|1ms)
 31ms (30ms|0ms)
 31ms (30ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-parallel-worktree-removal-gate trigger scoping (issue #545)
 Context operand resolution - the --force flag never becomes the path
 13ms (11ms|2ms)
 Context under-match removal - a relocating spelling is now in scope
 39ms (37ms|1ms)
 Context over-match removal - a quoted mention is not an invocation
 13ms (12ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing parallel worktree-removal gate run-target resolution
 96ms (95ms|2ms)
 57ms (56ms|1ms)
 45ms (45ms|1ms)
 41ms (40ms|1ms)
 46ms (46ms|1ms)
 12ms (11ms|1ms)
 40ms (39ms|1ms)

Running tests from 'tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix
 66ms (65ms|2ms)
 48ms (38ms|10ms)
 33ms (32ms|1ms)
 28ms (27ms|1ms)
 41ms (40ms|1ms)
 31ms (30ms|1ms)
 38ms (37ms|1ms)
 32ms (31ms|1ms)
 34ms (34ms|1ms)
 33ms (32ms|1ms)
 38ms (38ms|1ms)
 33ms (33ms|1ms)
 36ms (35ms|1ms)
 39ms (38ms|1ms)
 34ms (34ms|1ms)
 40ms (40ms|1ms)
 31ms (30ms|1ms)
 36ms (35ms|1ms)
 39ms (38ms|1ms)
 35ms (31ms|3ms)
 40ms (39ms|1ms)
 32ms (32ms|1ms)
 41ms (40ms|1ms)
 42ms (41ms|1ms)
 40ms (39ms|1ms)
 35ms (34ms|1ms)
 36ms (35ms|1ms)
 34ms (33ms|1ms)
 35ms (35ms|1ms)
 39ms (39ms|1ms)
 36ms (36ms|1ms)
 36ms (35ms|1ms)
 40ms (39ms|1ms)
 29ms (28ms|1ms)
 30ms (29ms|1ms)
 34ms (34ms|1ms)
 37ms (36ms|1ms)
 35ms (34ms|1ms)
 34ms (33ms|1ms)
 56ms (55ms|1ms)
 68ms (67ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix
 35ms (34ms|2ms)
 33ms (32ms|1ms)
 24ms (24ms|1ms)
 31ms (30ms|1ms)
 28ms (27ms|1ms)
 37ms (36ms|1ms)
 27ms (26ms|1ms)
 34ms (33ms|1ms)
 30ms (29ms|1ms)
 26ms (25ms|1ms)
 30ms (29ms|1ms)
 26ms (25ms|1ms)
 25ms (24ms|1ms)
 33ms (32ms|1ms)
 31ms (31ms|1ms)
 32ms (30ms|1ms)
 28ms (27ms|1ms)
 33ms (32ms|1ms)
 30ms (29ms|1ms)
 29ms (28ms|1ms)
 25ms (25ms|1ms)
 30ms (29ms|1ms)
 28ms (27ms|1ms)
 27ms (26ms|1ms)
 31ms (30ms|1ms)
 27ms (26ms|1ms)
 32ms (31ms|1ms)
 31ms (30ms|1ms)
 25ms (24ms|1ms)
 31ms (30ms|1ms)
 29ms (28ms|1ms)
 28ms (27ms|1ms)
 30ms (29ms|1ms)
 33ms (32ms|1ms)
 31ms (30ms|1ms)
 33ms (32ms|1ms)
 30ms (29ms|1ms)
 32ms (32ms|1ms)
 33ms (33ms|1ms)
 55ms (54ms|1ms)
 53ms (53ms|1ms)
Tests completed in 6.27s
Tests Passed: 152, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 365 ms.
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


TotalCount=152
PassedCount=152
FailedCount=0
COVERAGE file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 AnalyzedLines=109 CoveredLines=101 LinePercent=92.66
HIT file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 Lines=37,40,45,46,49,51,57,60,76,77,79,102,103,126,148,149,150,151,152,153,155,157,161,162,163,195,196,198,199,200,203,207,208,209,212,213,214,217,237,238,240,241,242,244,252,253,254,255,268,269,270,271,272,293,294,295,299,300,301,302,303,307,308,309,315,316,322,323,326,329,330,331,332,335,359,360,361,362,363,366,368,369,370,383,385,386,387,400,401,402,406,407,408,410,438,441,442,445,446,448,452
MISSED file=.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 Lines=54,105,324,327,459,460,461,464
```
