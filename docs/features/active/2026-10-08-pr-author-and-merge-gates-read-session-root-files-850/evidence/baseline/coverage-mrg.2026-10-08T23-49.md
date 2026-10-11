# P0-T26 Coverage baseline CG-MRG

Timestamp: 2026-10-08T23-49
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 -CoveragePath .claude/hooks/enforce-epic-merge-gate.ps1,.claude/hooks/enforce-epic-merge-gate-resolution.ps1 -CoverageOutputPath SCRATCH/cov-mrg-base.xml -ReportPath SCRATCH/cov-mrg-base.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=141
  PassedCount=141
  FailedCount=0
  COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1 AnalyzedLines=125 CoveredLines=120 LinePercent=96
  COVERAGE file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 AnalyzedLines=36 CoveredLines=32 LinePercent=88.89
  Baseline failure set (CG-MRG): empty
  Baseline container set (CG-MRG): empty
  BASEPCT MRG (.claude/hooks/enforce-epic-merge-gate.ps1): 96
  BASEPCT MRGR (.claude/hooks/enforce-epic-merge-gate-resolution.ps1): 88.89

## Full output

```text
Pester v5.6.1

Starting discovery in 6 files.
Discovery found 141 tests in 277ms.
Starting code coverage.
Code Coverage preparation finished after 201 ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1'
Describing enforce-epic-merge-gate.ps1
 Context commands outside scope
 59ms (36ms|23ms)
 85ms (84ms|1ms)
 28ms (27ms|1ms)
 16ms (15ms|1ms)
 Context allow via child-feature checkpoint (epic_mode + step9_status passed)
 170ms (169ms|2ms)
 77ms (75ms|1ms)
 Context allow via epic-integration checkpoint (ci_gate success + matching PR number)
 60ms (59ms|1ms)
 57ms (56ms|1ms)
 Context deny on non-matching PR number
 67ms (65ms|2ms)
 Context deny on non-success ci_gate.conclusion
 53ms (51ms|1ms)
 Context deny on missing/unreadable checkpoints (fail closed)
 50ms (48ms|1ms)
 59ms (58ms|1ms)
 Context allow via parallel-orchestrator checkpoint (route_id parallel + ci_green + matching PR)
 62ms (60ms|2ms)
 Context deny via parallel-orchestrator checkpoint (fail closed)
 39ms (38ms|1ms)
 40ms (39ms|1ms)
 45ms (44ms|1ms)
 38ms (38ms|1ms)
 45ms (45ms|1ms)
 41ms (39ms|1ms)
 Context Get-EpicMergeGateCommandPrNumber extractor (flag-order forms)
 8ms (7ms|1ms)
 8ms (8ms|1ms)
 11ms (11ms|1ms)
 Context real Test-Path read seam for the parallel checkpoint
 52ms (51ms|1ms)
 35ms (35ms|1ms)
 Context Test-ParallelCheckpointAllowsMerge helper (direct branch coverage)
 5ms (4ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 3ms (2ms|0ms)
 Context real Test-Path read seams
 21ms (20ms|1ms)
 25ms (24ms|1ms)
 12ms (12ms|1ms)
 25ms (25ms|1ms)
 Context Test-ChildCheckpointAllowsEpicMerge helper (direct branch coverage)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 Context Test-EpicCheckpointAllowsMerge helper (direct branch coverage)
 16ms (2ms|14ms)
 6ms (6ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 Context Invoke-EpicMergeGateDecision - command field absent
 5ms (3ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 26ms (25ms|1ms)
 11ms (11ms|0ms)
 14ms (14ms|0ms)
 13ms (12ms|1ms)
 15ms (14ms|1ms)
 10ms (10ms|0ms)
 43ms (43ms|0ms)
 27ms (26ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1'
Describing enforce-epic-merge-gate.ps1 standalone authorization (issue #670)
 Context decision matrix
 79ms (76ms|3ms)
 35ms (34ms|1ms)
 39ms (38ms|1ms)
 43ms (42ms|1ms)
 69ms (68ms|1ms)
 47ms (46ms|1ms)
 40ms (39ms|1ms)
 41ms (39ms|1ms)
 50ms (49ms|1ms)
 54ms (53ms|1ms)
 23ms (22ms|1ms)
 Context reason text and branch order
 36ms (35ms|1ms)
 46ms (46ms|1ms)
 52ms (51ms|1ms)
 Context the pr_number matcher is unchanged
 51ms (50ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1'
Describing enforce-epic-merge-gate-authorization.ps1 predicates (issue #670)
 Context blocks that are not PR specific
 7ms (5ms|2ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 11ms (11ms|1ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 Context field shape failures on the matched record
 9ms (8ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 7ms (6ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 5ms (5ms|1ms)
 Context valid records and session binding
 7ms (6ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|0ms)
 5ms (5ms|1ms)
 6ms (5ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|1ms)
 6ms (5ms|1ms)
 Context checkpoint-level verdicts
 10ms (8ms|2ms)
 4ms (4ms|1ms)
 5ms (4ms|1ms)
 7ms (6ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-merge-gate.ps1 trigger scoping (issue #545)
 Context PR-number extraction comes from the matched segment only
 23ms (21ms|2ms)
 8ms (8ms|1ms)
 6ms (5ms|0ms)
 10ms (9ms|0ms)
 Context scope filter separates a mention from an invocation
 27ms (26ms|1ms)
 43ms (42ms|1ms)
 Context the false-allow direction of the whole-line PR-number defect
 24ms (22ms|1ms)
 52ms (51ms|1ms)
 52ms (52ms|1ms)
 Context R-2.a wrapper-led segments stay in scope
 50ms (49ms|1ms)
 18ms (18ms|1ms)
 51ms (50ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1'
Describing epic merge gate run-target resolution
 87ms (86ms|1ms)
 46ms (45ms|0ms)
 43ms (43ms|1ms)
 34ms (33ms|1ms)
 32ms (32ms|1ms)
 46ms (45ms|1ms)
 39ms (39ms|0ms)
 43ms (43ms|1ms)
 43ms (42ms|1ms)
 7ms (7ms|0ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 57ms (56ms|2ms)
 Context AT-2 - the issue #591 operand mis-parse
 15ms (14ms|1ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 38ms (37ms|1ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 20ms (19ms|1ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 11ms (10ms|1ms)
 Context AT-6 - the wrapper deny pin
 47ms (46ms|1ms)
 Context AT-7 - the cross-runtime operand divergence
 8ms (7ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 11ms (10ms|1ms)
 5ms (5ms|0ms)
 4ms (4ms|0ms)
 10ms (9ms|0ms)
Tests completed in 5.29s
Tests Passed: 141, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 430 ms.
Covered 94.07% / 75%. 236 analyzed Commands in 2 Files.
Missed commands:

File                                   Class Function                          Line Command
----                                   ----- --------                          ---- -------
enforce-epic-merge-gate-resolution.ps1                                           35 $script:EpicMergeGateResolutionImpo…
enforce-epic-merge-gate-resolution.ps1       Test-ChildCheckpointPrGateBinding  182 return $true
enforce-epic-merge-gate-resolution.ps1       Test-ChildCheckpointPrGateBinding  186 return $false
enforce-epic-merge-gate-resolution.ps1       Get-EpicMergeGateUnresolvedReason  213 return $null
enforce-epic-merge-gate-resolution.ps1       Get-EpicMergeGateUnresolvedReason  219 $ParallelTarget.ReasonCode
enforce-epic-merge-gate.ps1                  Invoke-EpicMergeGateDecision       348 $hasMergeFlag = $true
enforce-epic-merge-gate.ps1                                                     454 $entryPointResult = @(Invoke-EpicMe…
enforce-epic-merge-gate.ps1                                                     454 Invoke-EpicMergeGateEntryPoint
enforce-epic-merge-gate.ps1                                                     455 if ($entryPointResult.Count -gt 1) …
enforce-epic-merge-gate.ps1                                                     456 $entryPointResult[0..($entryPointRe…
enforce-epic-merge-gate.ps1                                                     456 $entryPointResult.Count - 2
enforce-epic-merge-gate.ps1                                                     456 Write-Output
enforce-epic-merge-gate.ps1                                                     459 ([int]$entryPointResult[-1])
enforce-epic-merge-gate.ps1                                                     459 [int]$entryPointResult[-1]


TotalCount=141
PassedCount=141
FailedCount=0
COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1 AnalyzedLines=125 CoveredLines=120 LinePercent=96
HIT file=.claude/hooks/enforce-epic-merge-gate.ps1 Lines=61,64,65,67,69,86,87,90,92,128,129,130,134,135,136,139,158,159,161,162,163,165,166,168,193,194,196,197,198,200,201,202,203,205,206,207,213,214,215,217,218,219,221,222,226,252,253,255,256,257,261,262,264,265,268,269,272,273,276,277,280,283,284,286,289,315,316,317,320,321,322,323,324,328,329,330,342,343,344,345,346,353,354,357,358,362,363,364,365,370,371,372,373,374,375,376,377,378,381,382,383,386,387,388,393,394,395,396,397,400,401,402,405,433,436,437,440,441,443,447
MISSED file=.claude/hooks/enforce-epic-merge-gate.ps1 Lines=348,454,455,456,459
COVERAGE file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 AnalyzedLines=36 CoveredLines=32 LinePercent=88.89
HIT file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 Lines=30,32,49,50,52,53,71,72,74,91,92,94,111,112,114,128,149,174,175,177,178,180,181,184,185,188,212,215,216,217,219,220
MISSED file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 Lines=35,182,186,213
```
