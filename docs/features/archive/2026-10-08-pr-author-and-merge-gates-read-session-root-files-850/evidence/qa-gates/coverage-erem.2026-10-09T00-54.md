# P8-T6 Coverage CG-EREM final

Timestamp: 2026-10-09T00-54
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 -CoveragePath .claude/hooks/enforce-epic-worktree-removal-gate.ps1,.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 -CoverageOutputPath SCRATCH/cov-erem-final.xml -ReportPath SCRATCH/cov-erem-final.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=162
  PassedCount=162
  FailedCount=0
  COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 AnalyzedLines=112 CoveredLines=106 LinePercent=94.64
  COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 AnalyzedLines=57 CoveredLines=55 LinePercent=96.49

## Full output

```text
Pester v5.6.1

Starting discovery in 6 files.
Discovery found 162 tests in 271ms.
Starting code coverage.
Code Coverage preparation finished after 186 ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1
 Context commands outside scope
 62ms (41ms|21ms)
 8ms (8ms|1ms)
 47ms (47ms|1ms)
 13ms (12ms|1ms)
 Context allow on merge_status merged
 90ms (89ms|2ms)
 Context allow on merge_status worktree_removed
 28ms (27ms|1ms)
 Context deny on unreadable checkpoint
 35ms (34ms|1ms)
 34ms (33ms|1ms)
 Context deny on no matching record
 44ms (42ms|2ms)
 Context deny on other merge_status
 25ms (24ms|1ms)
 Context path normalization
 21ms (20ms|1ms)
 Context Resolve-CommandLineInvocationTarget for the epic gate
 6ms (5ms|1ms)
 4ms (3ms|0ms)
 Context Find-EpicWorktreeFeatureRecord helper
 5ms (5ms|1ms)
 3ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Test-EpicWorktreeRemovalAllowed helper
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 Context real Test-Path read seam
 54ms (53ms|1ms)
 22ms (21ms|0ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 21ms (20ms|1ms)
 9ms (8ms|0ms)
 8ms (8ms|0ms)
 8ms (8ms|0ms)
 7ms (7ms|0ms)
 21ms (21ms|0ms)
 27ms (26ms|0ms)
 Context parallel branch allow (AC-1, AC-2, AC-3)
 29ms (28ms|1ms)
 34ms (34ms|1ms)
 19ms (18ms|0ms)
 Context parallel branch fail-closed deny (AC-4)
 23ms (22ms|1ms)
 19ms (19ms|0ms)
 27ms (27ms|0ms)
 32ms (24ms|8ms)
 25ms (24ms|1ms)
 21ms (21ms|1ms)
 20ms (20ms|0ms)
 18ms (18ms|0ms)
 Context branch precedence and check ordering (AC-5, AC-7)
 21ms (20ms|1ms)
 15ms (15ms|0ms)
 Context Test-ParallelCheckpointAllowsWorktreeRemoval direct branch coverage (AC-8)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context real Test-Path parallel read seam (AC-9)
 9ms (8ms|1ms)
 19ms (18ms|0ms)

Describing enforce-epic-worktree-removal-gate.ps1 manifest branch
 58ms (56ms|1ms)
 26ms (26ms|0ms)
 70ms (70ms|1ms)
 12ms (12ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-worktree-removal-gate trigger scoping (issue #545)
 Context under-match removal - a relocating spelling is now in scope
 34ms (32ms|2ms)
 Context operand resolution - the --force flag never becomes the path
 8ms (7ms|1ms)
 11ms (11ms|1ms)
 Context over-match removal and scope narrowing
 15ms (14ms|1ms)
 13ms (13ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1'
Describing epic worktree-removal gate run-target resolution
 97ms (96ms|2ms)
 51ms (50ms|1ms)
 48ms (47ms|1ms)
 49ms (48ms|1ms)
 58ms (57ms|1ms)
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1'
Describing enforce-epic-worktree-removal-gate.ps1 manifest fail-closed matrix
 49ms (47ms|2ms)
 43ms (42ms|1ms)
 39ms (38ms|1ms)
 38ms (37ms|1ms)
 34ms (33ms|1ms)
 29ms (28ms|1ms)
 40ms (37ms|3ms)
 36ms (35ms|1ms)
 39ms (38ms|1ms)
 40ms (39ms|1ms)
 39ms (39ms|1ms)
 32ms (31ms|1ms)
 31ms (31ms|1ms)
 36ms (35ms|1ms)
 35ms (34ms|1ms)
 35ms (34ms|1ms)
 42ms (41ms|1ms)
 34ms (33ms|1ms)
 40ms (39ms|1ms)
 38ms (37ms|1ms)
 34ms (33ms|1ms)
 37ms (37ms|1ms)
 37ms (36ms|1ms)
 40ms (39ms|1ms)
 39ms (39ms|1ms)
 34ms (33ms|1ms)
 30ms (29ms|1ms)
 41ms (40ms|1ms)
 37ms (36ms|1ms)
 34ms (33ms|1ms)
 38ms (37ms|1ms)
 34ms (33ms|1ms)
 43ms (42ms|1ms)
 29ms (28ms|1ms)
 38ms (37ms|1ms)
 38ms (37ms|1ms)
 35ms (34ms|1ms)
 39ms (38ms|1ms)
 38ms (37ms|1ms)
 64ms (63ms|1ms)
 63ms (62ms|1ms)

Describing enforce-parallel-worktree-removal-gate.ps1 manifest fail-closed matrix
 53ms (52ms|2ms)
 29ms (28ms|1ms)
 34ms (33ms|1ms)
 30ms (29ms|1ms)
 27ms (26ms|1ms)
 25ms (24ms|1ms)
 36ms (36ms|1ms)
 33ms (32ms|1ms)
 35ms (34ms|1ms)
 27ms (27ms|1ms)
 30ms (29ms|1ms)
 29ms (29ms|1ms)
 26ms (25ms|1ms)
 35ms (35ms|1ms)
 35ms (34ms|1ms)
 34ms (31ms|3ms)
 34ms (33ms|1ms)
 30ms (30ms|1ms)
 33ms (32ms|1ms)
 29ms (28ms|1ms)
 33ms (32ms|1ms)
 31ms (30ms|1ms)
 30ms (29ms|1ms)
 28ms (27ms|1ms)
 28ms (27ms|1ms)
 27ms (26ms|1ms)
 25ms (25ms|1ms)
 33ms (32ms|1ms)
 32ms (31ms|1ms)
 23ms (23ms|1ms)
 30ms (29ms|1ms)
 31ms (30ms|1ms)
 33ms (32ms|1ms)
 27ms (27ms|1ms)
 31ms (30ms|1ms)
 29ms (28ms|1ms)
 36ms (35ms|1ms)
 31ms (30ms|1ms)
 38ms (37ms|1ms)
 54ms (53ms|1ms)
 57ms (56ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 33ms (31ms|2ms)
 Context AT-2 - the issue #591 operand mis-parse
 26ms (24ms|1ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 38ms (37ms|1ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 40ms (39ms|1ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 13ms (12ms|1ms)
 Context AT-6 - the wrapper deny pin
 64ms (63ms|1ms)
 Context AT-7 - the cross-runtime operand divergence
 12ms (11ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 9ms (8ms|1ms)
 6ms (6ms|1ms)
 5ms (5ms|1ms)
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1'
Describing epic worktree-removal gate deny diagnostics
 48ms (47ms|1ms)
 43ms (42ms|1ms)
 33ms (33ms|1ms)
 47ms (46ms|1ms)
 30ms (29ms|1ms)
 Context diagnostics builder and read result
 23ms (22ms|1ms)
 18ms (17ms|1ms)
 18ms (18ms|1ms)
Tests completed in 7.07s
Tests Passed: 162, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 527 ms.
Covered 94.94% / 75%. 237 analyzed Commands in 2 Files.
Missed commands:

File                                              Class Function                                Line Command
----                                              ----- --------                                ---- -------
enforce-epic-worktree-removal-gate-resolution.ps1                                                 38 $script:EpicWorktr…
enforce-epic-worktree-removal-gate-resolution.ps1       Find-EpicWorktreeGateParallelItemRecord  181 return $null
enforce-epic-worktree-removal-gate.ps1                  Invoke-EpicWorktreeRemovalGateDecision   327 return Get-EpicWor…
enforce-epic-worktree-removal-gate.ps1                  Invoke-EpicWorktreeRemovalGateDecision   330 return Get-EpicWor…
enforce-epic-worktree-removal-gate.ps1                                                           454 $entryPointResult …
enforce-epic-worktree-removal-gate.ps1                                                           454 Invoke-EpicWorktre…
enforce-epic-worktree-removal-gate.ps1                                                           455 if ($entryPointRes…
enforce-epic-worktree-removal-gate.ps1                                                           456 $entryPointResult[…
enforce-epic-worktree-removal-gate.ps1                                                           456 $entryPointResult.…
enforce-epic-worktree-removal-gate.ps1                                                           456 Write-Output
enforce-epic-worktree-removal-gate.ps1                                                           459 ([int]$entryPointR…
enforce-epic-worktree-removal-gate.ps1                                                           459 [int]$entryPointRe…


TotalCount=162
PassedCount=162
FailedCount=0
COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 AnalyzedLines=112 CoveredLines=106 LinePercent=94.64
HIT file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 Lines=72,75,78,79,81,82,85,105,106,109,111,135,136,138,139,140,143,147,148,149,152,153,154,157,177,178,180,181,182,184,213,214,216,219,220,222,223,226,230,231,234,235,238,239,242,243,245,248,256,257,258,259,272,273,274,275,276,297,298,299,302,303,304,305,306,310,311,312,318,319,325,326,329,332,333,334,335,338,362,363,364,365,366,369,371,372,373,376,377,378,391,392,393,394,400,401,402,404,405,433,436,437,440,441,443,447
MISSED file=.claude/hooks/enforce-epic-worktree-removal-gate.ps1 Lines=327,330,454,455,456,459
COVERAGE file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 AnalyzedLines=57 CoveredLines=55 LinePercent=96.49
HIT file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 Lines=33,35,52,53,55,56,74,75,77,94,95,97,118,141,142,143,144,145,146,147,149,150,151,152,180,183,184,185,188,189,190,193,194,197,198,199,202,232,233,234,235,236,238,239,242,243,246,248,249,250,252,253,256,259,261
MISSED file=.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 Lines=38,181
```
