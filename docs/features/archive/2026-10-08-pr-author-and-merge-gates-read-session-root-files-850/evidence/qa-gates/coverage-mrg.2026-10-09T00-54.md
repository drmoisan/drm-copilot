# P8-T5 Coverage CG-MRG final

Timestamp: 2026-10-09T00-54
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 -CoveragePath .claude/hooks/enforce-epic-merge-gate.ps1,.claude/hooks/enforce-epic-merge-gate-resolution.ps1 -CoverageOutputPath SCRATCH/cov-mrg-final.xml -ReportPath SCRATCH/cov-mrg-final.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=160
  PassedCount=160
  FailedCount=0
  COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1 AnalyzedLines=130 CoveredLines=125 LinePercent=96.15
  COVERAGE file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 AnalyzedLines=50 CoveredLines=45 LinePercent=90

## Full output

```text
Pester v5.6.1

Starting discovery in 7 files.
Discovery found 160 tests in 281ms.
Starting code coverage.
Code Coverage preparation finished after 196 ms.
Running tests.

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1'
Describing enforce-epic-merge-gate.ps1
 Context commands outside scope
 70ms (50ms|20ms)
 52ms (52ms|1ms)
 48ms (47ms|1ms)
 8ms (7ms|1ms)
 Context allow via child-feature checkpoint (epic_mode + step9_status passed)
 79ms (78ms|1ms)
 34ms (33ms|1ms)
 Context allow via epic-integration checkpoint (ci_gate success + matching PR number)
 60ms (59ms|1ms)
 37ms (37ms|1ms)
 Context deny on non-matching PR number
 42ms (42ms|1ms)
 Context deny on non-success ci_gate.conclusion
 32ms (31ms|1ms)
 Context deny on missing/unreadable checkpoints (fail closed)
 34ms (33ms|1ms)
 42ms (41ms|0ms)
 Context allow via parallel-orchestrator checkpoint (route_id parallel + ci_green + matching PR)
 37ms (35ms|1ms)
 Context deny via parallel-orchestrator checkpoint (fail closed)
 32ms (31ms|1ms)
 31ms (30ms|0ms)
 32ms (32ms|0ms)
 36ms (35ms|0ms)
 32ms (32ms|0ms)
 26ms (26ms|0ms)
 Context Get-EpicMergeGateCommandPrNumber extractor (flag-order forms)
 10ms (9ms|1ms)
 7ms (7ms|0ms)
 9ms (9ms|0ms)
 Context real Test-Path read seam for the parallel checkpoint
 41ms (40ms|1ms)
 21ms (20ms|0ms)
 Context Test-ParallelCheckpointAllowsMerge helper (direct branch coverage)
 4ms (3ms|1ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 3ms (2ms|0ms)
 Context real Test-Path read seams
 11ms (10ms|1ms)
 23ms (22ms|1ms)
 12ms (12ms|1ms)
 18ms (18ms|0ms)
 Context Test-ChildCheckpointAllowsEpicMerge helper (direct branch coverage)
 3ms (2ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 Context Test-EpicCheckpointAllowsMerge helper (direct branch coverage)
 2ms (1ms|1ms)
 2ms (2ms|0ms)
 2ms (2ms|0ms)
 2ms (1ms|0ms)
 2ms (1ms|0ms)
 14ms (13ms|1ms)
 Context Invoke-EpicMergeGateDecision - command field absent
 17ms (16ms|1ms)
 Context entry-point exit code and emitted decision (AC-4, no child process)
 21ms (20ms|1ms)
 11ms (11ms|0ms)
 10ms (10ms|0ms)
 10ms (10ms|0ms)
 10ms (10ms|0ms)
 9ms (9ms|0ms)
 27ms (27ms|0ms)
 26ms (26ms|0ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1'
Describing enforce-epic-merge-gate.ps1 standalone authorization (issue #670)
 Context decision matrix
 50ms (47ms|2ms)
 30ms (29ms|1ms)
 34ms (33ms|1ms)
 26ms (25ms|1ms)
 56ms (55ms|1ms)
 35ms (34ms|1ms)
 39ms (38ms|1ms)
 40ms (39ms|1ms)
 54ms (53ms|1ms)
 49ms (49ms|1ms)
 20ms (19ms|1ms)
 Context reason text and branch order
 40ms (38ms|2ms)
 43ms (42ms|1ms)
 63ms (63ms|1ms)
 Context the pr_number matcher is unchanged
 59ms (58ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1'
Describing enforce-epic-merge-gate-authorization.ps1 predicates (issue #670)
 Context blocks that are not PR specific
 6ms (5ms|2ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 6ms (6ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 Context field shape failures on the matched record
 9ms (8ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 8ms (7ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 5ms (4ms|1ms)
 10ms (5ms|5ms)
 Context valid records and session binding
 5ms (3ms|1ms)
 5ms (4ms|1ms)
 4ms (3ms|1ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 6ms (5ms|1ms)
 Context checkpoint-level verdicts
 11ms (9ms|2ms)
 3ms (2ms|1ms)
 8ms (7ms|1ms)
 3ms (2ms|1ms)
 5ms (4ms|1ms)
 6ms (5ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1'
Describing enforce-epic-merge-gate.ps1 trigger scoping (issue #545)
 Context PR-number extraction comes from the matched segment only
 29ms (27ms|2ms)
 11ms (10ms|1ms)
 8ms (7ms|1ms)
 10ms (10ms|1ms)
 Context scope filter separates a mention from an invocation
 31ms (30ms|1ms)
 46ms (45ms|1ms)
 Context the false-allow direction of the whole-line PR-number defect
 17ms (15ms|1ms)
 58ms (57ms|1ms)
 57ms (56ms|1ms)
 Context R-2.a wrapper-led segments stay in scope
 53ms (52ms|1ms)
 20ms (20ms|1ms)
 48ms (48ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1'
Describing epic merge gate run-target resolution
 106ms (105ms|1ms)
 60ms (60ms|1ms)
 61ms (60ms|1ms)
 45ms (44ms|1ms)
 69ms (69ms|1ms)
 66ms (65ms|1ms)
 40ms (39ms|1ms)
 55ms (55ms|1ms)
 54ms (53ms|1ms)
 8ms (8ms|1ms)

Running tests from 'tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1'
Describing hook-command-parser acceptance cases (issue #545)
 Context AT-1 - the mandatory latent-bypass case
 66ms (65ms|2ms)
 Context AT-2 - the issue #591 operand mis-parse
 19ms (18ms|1ms)
 Context AT-3 - the promotion-hook over-match on receipt values
 45ms (44ms|1ms)
 Context AT-4 - the merge-gate over-match on quoted prose
 24ms (23ms|1ms)
 Context AT-5 - the promotion-hook gh relocation bypass
 14ms (13ms|1ms)
 Context AT-6 - the wrapper deny pin
 54ms (53ms|1ms)
 Context AT-7 - the cross-runtime operand divergence
 8ms (7ms|1ms)
 Context paired negatives that must hold alongside the acceptance cases
 13ms (12ms|1ms)
 7ms (6ms|1ms)
 5ms (5ms|1ms)
 10ms (10ms|1ms)

Running tests from 'tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1'
Describing epic merge gate item-worktree resolution
 57ms (55ms|1ms)
 53ms (52ms|1ms)
 39ms (38ms|1ms)
 30ms (29ms|1ms)
 53ms (52ms|1ms)
 46ms (45ms|1ms)
 34ms (33ms|1ms)
 40ms (39ms|1ms)
 36ms (35ms|1ms)
 6ms (5ms|1ms)
 Context child checkpoint pull request binding
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 6ms (5ms|2ms)
 2ms (1ms|1ms)
 3ms (3ms|1ms)
 4ms (3ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (2ms|0ms)
Tests completed in 5.57s
Tests Passed: 160, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 490 ms.
Covered 94.74% / 75%. 266 analyzed Commands in 2 Files.
Missed commands:

File                                   Class Function                          Line Command
----                                   ----- --------                          ---- -------
enforce-epic-merge-gate-resolution.ps1                                           43 $script:EpicMergeGateResolutionImpo…
enforce-epic-merge-gate-resolution.ps1                                           49 if (-not $script:EpicMergeGateResol…
enforce-epic-merge-gate-resolution.ps1                                           50 $script:EpicMergeGateResolutionImpo…
enforce-epic-merge-gate-resolution.ps1       Test-ChildCheckpointPrGateBinding  222 return $false
enforce-epic-merge-gate-resolution.ps1       Get-EpicMergeGateUnresolvedReason  266 return $null
enforce-epic-merge-gate.ps1                  Invoke-EpicMergeGateDecision       350 $hasMergeFlag = $true
enforce-epic-merge-gate.ps1                                                     465 $entryPointResult = @(Invoke-EpicMe…
enforce-epic-merge-gate.ps1                                                     465 Invoke-EpicMergeGateEntryPoint
enforce-epic-merge-gate.ps1                                                     466 if ($entryPointResult.Count -gt 1) …
enforce-epic-merge-gate.ps1                                                     467 $entryPointResult[0..($entryPointRe…
enforce-epic-merge-gate.ps1                                                     467 $entryPointResult.Count - 2
enforce-epic-merge-gate.ps1                                                     467 Write-Output
enforce-epic-merge-gate.ps1                                                     470 ([int]$entryPointResult[-1])
enforce-epic-merge-gate.ps1                                                     470 [int]$entryPointResult[-1]


TotalCount=160
PassedCount=160
FailedCount=0
COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1 AnalyzedLines=130 CoveredLines=125 LinePercent=96.15
HIT file=.claude/hooks/enforce-epic-merge-gate.ps1 Lines=63,66,67,69,71,88,89,92,94,130,131,132,136,137,138,141,160,161,163,164,165,167,168,170,195,196,198,199,200,202,203,204,205,207,208,209,215,216,217,219,220,221,223,224,228,254,255,257,258,259,263,264,266,267,270,271,274,275,278,279,282,285,286,288,291,317,318,319,322,323,324,325,326,330,331,332,344,345,346,347,348,355,356,359,360,366,367,368,369,370,372,373,374,375,380,381,382,383,384,385,386,387,388,391,392,393,396,397,398,403,404,405,406,407,411,412,413,416,444,447,448,451,452,454,458
MISSED file=.claude/hooks/enforce-epic-merge-gate.ps1 Lines=350,465,466,467,470
COVERAGE file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 AnalyzedLines=50 CoveredLines=45 LinePercent=90
HIT file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 Lines=38,40,46,65,66,68,69,87,88,90,107,108,110,127,128,130,144,165,183,211,212,214,215,217,218,219,220,221,224,226,227,229,230,233,234,237,265,268,269,270,271,272,275,276,277
MISSED file=.claude/hooks/enforce-epic-merge-gate-resolution.ps1 Lines=43,49,50,222,266
```
