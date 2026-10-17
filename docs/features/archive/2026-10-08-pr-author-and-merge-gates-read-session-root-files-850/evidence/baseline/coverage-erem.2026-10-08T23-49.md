# P0-T27 Coverage baseline CG-EREM

Timestamp: 2026-10-08T23-49
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 -CoveragePath .claude/hooks/enforce-epic-worktree-removal-gate.ps1,.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 -CoverageOutputPath SCRATCH/cov-erem-base.xml -ReportPath SCRATCH/cov-erem-base.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=154
  PassedCount=154
  FailedCount=0
  COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 AnalyzedLines=111 CoveredLines=105 LinePercent=94.59
  COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 AnalyzedLines=23 CoveredLines=22 LinePercent=95.65
  Baseline failure set (CG-EREM): empty
  Baseline container set (CG-EREM): empty
  BASEPCT EREM (.claude/hooks/enforce-epic-worktree-removal-gate.ps1): 94.59
  BASEPCT EREMR (.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1): 95.65

## Full output

```text
Pester v5.6.1

Starting discovery in 5 files.
Discovery found 154 tests in 279ms.
Starting code coverage.
Code Coverage preparation finished after 184 ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1
 Context commands outside scope
 89ms (61ms|27ms)
 16ms (15ms|1ms)
 122ms (121ms|2ms)
 22ms (21ms|1ms)
 Context allow on merge_status merged
 107ms (106ms|2ms)
 Context allow on merge_status worktree_removed
 30ms (28ms|2ms)
 Context deny on unreadable checkpoint
 61ms (60ms|1ms)
 43ms (42ms|1ms)
 Context deny on no matching record
 68ms (66ms|2ms)
 Context deny on other merge_status
 40ms (38ms|2ms)
 Context path normalization
 31ms (26ms|5ms)
 Context Resolve-CommandLineInvocationTarget for the epic gate
 11ms (9ms|2ms)
 7ms (6ms|1ms)
 Context Find-EpicWorktreeFeatureRecord helper
 8ms (7ms|1ms)
 5ms (4ms|1ms)
 3ms (3ms|1ms)
 Context Test-EpicWorktreeRemovalAllowed helper
 5ms (4ms|1ms)
 7ms (3ms|4ms)
 Context real Test-Path read seam
 61ms (60ms|1ms)
 29ms (29ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 27ms (26ms|1ms)
 21ms (21ms|1ms)
 11ms (11ms|1ms)
 11ms (10ms|1ms)
 10ms (9ms|1ms)
 31ms (31ms|1ms)
 47ms (47ms|1ms)
 Context parallel branch allow (AC-1, AC-2, AC-3)
 55ms (53ms|2ms)
 27ms (27ms|1ms)
 30ms (29ms|1ms)
 Context parallel branch fail-closed deny (AC-4)
 30ms (29ms|1ms)
 33ms (32ms|1ms)
 46ms (45ms|1ms)
 78ms (76ms|1ms)
 38ms (37ms|1ms)
 53ms (51ms|1ms)
 45ms (44ms|1ms)
 42ms (41ms|1ms)
 Context branch precedence and check ordering (AC-5, AC-7)
 30ms (28ms|2ms)
 34ms (33ms|1ms)
 Context Test-ParallelCheckpointAllowsWorktreeRemoval direct branch coverage (AC-8)
 5ms (3ms|2ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 Context real Test-Path parallel read seam (AC-9)
 23ms (16ms|8ms)
 22ms (22ms|1ms)

Describing enforce-epic-worktree-removal-gate.ps1 manifest branch
 73ms (72ms|2ms)
 34ms (34ms|1ms)
 61ms (60ms|0ms)
 15ms (14ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-worktree-removal-gate trigger scoping (issue #545)
 Context under-match removal - a relocating spelling is now in scope
 76ms (64ms|12ms)
 Context operand resolution - the --force flag never becomes the path
 16ms (14ms|2ms)
 14ms (13ms|1ms)
 Context over-match removal and scope narrowing
 32ms (30ms|2ms)
 29ms (28ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing epic worktree-removal gate run-target resolution
 147ms (145ms|2ms)
 66ms (65ms|1ms)
 66ms (65ms|1ms)
 49ms (48ms|1ms)
 40ms (39ms|1ms)
 11ms (10ms|1ms)

Running tests from 'tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix
 49ms (47ms|2ms)
 36ms (35ms|1ms)
 31ms (31ms|1ms)
 49ms (48ms|1ms)
 31ms (30ms|1ms)
 38ms (37ms|1ms)
 35ms (34ms|1ms)
 41ms (41ms|1ms)
 42ms (41ms|1ms)
 38ms (37ms|1ms)
 39ms (38ms|1ms)
 42ms (41ms|1ms)
 43ms (42ms|1ms)
 43ms (42ms|1ms)
 37ms (37ms|1ms)
 40ms (39ms|1ms)
 42ms (41ms|1ms)
 39ms (38ms|1ms)
 42ms (41ms|1ms)
 32ms (31ms|1ms)
 36ms (36ms|1ms)
 42ms (41ms|1ms)
 31ms (30ms|1ms)
 31ms (30ms|1ms)
 29ms (29ms|1ms)
 33ms (32ms|1ms)
 30ms (30ms|1ms)
 32ms (32ms|1ms)
 32ms (31ms|1ms)
 28ms (27ms|1ms)
 36ms (35ms|1ms)
 38ms (37ms|1ms)
 38ms (37ms|1ms)
 34ms (34ms|1ms)
 39ms (38ms|1ms)
 36ms (36ms|1ms)
 38ms (37ms|1ms)
 31ms (30ms|1ms)
 33ms (32ms|1ms)
 56ms (55ms|1ms)
 55ms (54ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix
 51ms (50ms|2ms)
 23ms (22ms|1ms)
 28ms (27ms|1ms)
 26ms (25ms|1ms)
 33ms (32ms|1ms)
 29ms (28ms|1ms)
 25ms (25ms|1ms)
 23ms (22ms|1ms)
 27ms (26ms|1ms)
 24ms (23ms|1ms)
 26ms (25ms|1ms)
 24ms (23ms|1ms)
 26ms (25ms|1ms)
 26ms (25ms|1ms)
 27ms (26ms|1ms)
 25ms (24ms|1ms)
 27ms (26ms|1ms)
 25ms (24ms|1ms)
 30ms (29ms|1ms)
 26ms (26ms|1ms)
 26ms (26ms|1ms)
 24ms (24ms|1ms)
 27ms (27ms|1ms)
 29ms (28ms|1ms)
 38ms (37ms|1ms)
 30ms (29ms|1ms)
 31ms (30ms|1ms)
 25ms (24ms|1ms)
 27ms (26ms|1ms)
 33ms (32ms|1ms)
 33ms (32ms|1ms)
 35ms (34ms|1ms)
 32ms (31ms|1ms)
 26ms (25ms|1ms)
 33ms (32ms|1ms)
 29ms (28ms|1ms)
 28ms (27ms|1ms)
 32ms (32ms|1ms)
 32ms (31ms|1ms)
 43ms (42ms|1ms)
 48ms (47ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 30ms (28ms|2ms)
 Context AT-2 - the issue #591 operand mis-parse
 22ms (21ms|1ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 39ms (38ms|1ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 35ms (34ms|1ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 12ms (11ms|1ms)
 Context AT-6 - the wrapper deny pin
 57ms (56ms|1ms)
 Context AT-7 - the cross-runtime operand divergence
 23ms (21ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 8ms (7ms|1ms)
 7ms (6ms|1ms)
 5ms (5ms|1ms)
 11ms (11ms|1ms)
Tests completed in 7.58s
Tests Passed: 154, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 434 ms.
Covered 94.05% / 75%. 185 analyzed Commands in 2 Files.
Missed commands:

File                                              Class Function                               Line Command
----                                              ----- --------                               ---- -------
enforce-epic-worktree-removal-gate-resolution.ps1                                                32 $script:EpicWorktre…
enforce-epic-worktree-removal-gate.ps1                  Invoke-EpicWorktreeRemovalGateDecision  323 return Get-EpicWork…
enforce-epic-worktree-removal-gate.ps1                  Invoke-EpicWorktreeRemovalGateDecision  326 return Get-EpicWork…
enforce-epic-worktree-removal-gate.ps1                                                          447 $entryPointResult =…
enforce-epic-worktree-removal-gate.ps1                                                          447 Invoke-EpicWorktree…
enforce-epic-worktree-removal-gate.ps1                                                          448 if ($entryPointResu…
enforce-epic-worktree-removal-gate.ps1                                                          449 $entryPointResult[0…
enforce-epic-worktree-removal-gate.ps1                                                          449 $entryPointResult.C…
enforce-epic-worktree-removal-gate.ps1                                                          449 Write-Output
enforce-epic-worktree-removal-gate.ps1                                                          452 ([int]$entryPointRe…
enforce-epic-worktree-removal-gate.ps1                                                          452 [int]$entryPointRes…


TotalCount=154
PassedCount=154
FailedCount=0
COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 AnalyzedLines=111 CoveredLines=105 LinePercent=94.59
HIT file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 Lines=68,71,74,75,77,78,81,101,102,105,107,131,132,134,135,136,139,143,144,145,148,149,150,153,173,174,176,177,178,180,209,210,212,215,216,218,219,222,226,227,230,231,234,235,238,239,241,244,252,253,254,255,268,269,270,271,272,293,294,295,298,299,300,301,302,306,307,308,314,315,321,322,325,328,329,330,331,334,358,359,360,361,362,365,367,368,369,372,373,374,387,388,389,390,394,395,396,398,426,429,430,433,434,436,440
MISSED file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 Lines=323,326,447,448,449,452
COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 AnalyzedLines=23 CoveredLines=22 LinePercent=95.65
HIT file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 Lines=27,29,46,47,49,50,68,69,71,88,89,91,112,133,134,135,136,137,138,140,141,142
MISSED file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 Lines=32
```
