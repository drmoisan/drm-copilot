# P8-T8 Coverage CG-LIB final

Timestamp: 2026-10-09T00-54
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-lib/worktree-resolution -CoveragePath .claude/lib/worktree-resolution/WorktreeRunResolution.psm1,.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 -CoverageOutputPath SCRATCH/cov-lib-final.xml -ReportPath SCRATCH/cov-lib-final.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=266
  PassedCount=266
  FailedCount=0
  COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 AnalyzedLines=149 CoveredLines=149 LinePercent=100
  COVERAGE file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 AnalyzedLines=136 CoveredLines=131 LinePercent=96.32

## Full output

```text
Pester v5.6.1

Starting discovery in 11 files.
Discovery found 266 tests in 311ms.
Starting code coverage.
Code Coverage preparation finished after 233 ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1'
Describing Get-EpicPrCreationReadinessFailure
 51ms (33ms|18ms)
 8ms (6ms|2ms)
 3ms (2ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)

Describing Get-EpicCommandLegReadinessFailure
 15ms (14ms|1ms)
 6ms (4ms|1ms)
 2ms (2ms|0ms)
 4ms (3ms|0ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint run-target location
 179ms (178ms|2ms)
 51ms (49ms|1ms)
 51ms (50ms|0ms)
 44ms (43ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint epic-scope matches
 27ms (26ms|1ms)
 20ms (20ms|1ms)
 31ms (30ms|1ms)
 24ms (23ms|1ms)
 24ms (20ms|3ms)

Describing Resolve-EpicScopeCheckpoint fail-closed non-matches
 16ms (15ms|1ms)
 22ms (22ms|0ms)
 17ms (16ms|0ms)
 16ms (16ms|0ms)
 18ms (18ms|0ms)
 18ms (17ms|0ms)
 19ms (18ms|0ms)
 30ms (30ms|0ms)
 18ms (17ms|1ms)

Describing Resolve-EpicScopeCheckpoint checkpoint path composition
 29ms (28ms|1ms)
 40ms (39ms|1ms)
 26ms (26ms|1ms)

Describing EpicScopeResolution read seams
 18ms (17ms|1ms)
 20ms (20ms|1ms)
 11ms (10ms|0ms)
 11ms (10ms|0ms)
 18ms (17ms|0ms)

Describing Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2)
 34ms (32ms|1ms)
 24ms (24ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1'
Describing Resolve-WorktreeItemTargetByPrNumber
 42ms (40ms|1ms)
 15ms (15ms|0ms)
 12ms (11ms|1ms)
 23ms (22ms|1ms)
 36ms (36ms|1ms)
 8ms (7ms|0ms)
 12ms (12ms|1ms)
 10ms (9ms|1ms)
 10ms (9ms|1ms)
 9ms (9ms|1ms)
 25ms (25ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1'
Describing WorktreeItemResolution checkpoint path
 4ms (3ms|1ms)
 18ms (17ms|1ms)
 3ms (3ms|1ms)

Describing WorktreeItemResolution issue signals
 19ms (18ms|1ms)
 4ms (3ms|1ms)
 8ms (7ms|1ms)
 9ms (8ms|1ms)

Describing WorktreeItemResolution checkpoint reader
 13ms (12ms|1ms)
 24ms (24ms|1ms)

Describing WorktreeItemResolution liveness seam
 39ms (37ms|1ms)
 15ms (15ms|1ms)

Describing WorktreeItemResolution target resolution
 17ms (15ms|2ms)
 25ms (24ms|1ms)
 16ms (15ms|1ms)
 21ms (20ms|1ms)
 17ms (17ms|1ms)
 17ms (17ms|1ms)
 17ms (17ms|1ms)
 25ms (24ms|1ms)
 13ms (12ms|1ms)
 16ms (15ms|1ms)
 17ms (16ms|1ms)
 10ms (9ms|1ms)
 17ms (16ms|1ms)
 15ms (14ms|1ms)
 11ms (10ms|1ms)
 31ms (30ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1'
Describing WorktreeResolution core.json manifest membership
 12ms (9ms|3ms)
 7ms (6ms|1ms)
 5ms (4ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 9ms (9ms|1ms)
 9ms (8ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 12ms (12ms|1ms)

Describing WorktreeResolution bundle mirror byte identity
 13ms (11ms|2ms)
 7ms (6ms|1ms)
 2ms (2ms|1ms)
 2ms (2ms|0ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1'
Describing WorktreeResolution seam default bodies
 7ms (6ms|1ms)
 6ms (6ms|1ms)
 25ms (24ms|1ms)

Describing WorktreeResolution
 Context path normalisation
 8ms (4ms|4ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 3ms (2ms|1ms)
 2ms (1ms|1ms)
 1ms (1ms|1ms)
 6ms (4ms|2ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 2ms (1ms|1ms)
 Context root marker
 10ms (8ms|1ms)
 11ms (10ms|1ms)
 16ms (15ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 6ms (5ms|1ms)
 Context upward ascent
 11ms (10ms|1ms)
 19ms (18ms|1ms)
 13ms (12ms|1ms)
 24ms (23ms|1ms)
 14ms (14ms|1ms)
 5ms (4ms|1ms)
 Context worktree enumeration
 30ms (29ms|1ms)
 23ms (22ms|1ms)
 23ms (22ms|1ms)
 11ms (10ms|1ms)
 10ms (9ms|1ms)
 6ms (5ms|1ms)
 13ms (12ms|1ms)
 6ms (6ms|1ms)
 14ms (14ms|1ms)
 11ms (11ms|1ms)
 23ms (21ms|2ms)
 18ms (17ms|1ms)
 19ms (17ms|2ms)
 22ms (21ms|1ms)
 Context repo-relative normalisation
 34ms (32ms|1ms)
 6ms (5ms|1ms)
 5ms (5ms|1ms)
 14ms (14ms|1ms)
 4ms (3ms|1ms)
 8ms (7ms|1ms)
 Context reason code
 4ms (3ms|1ms)
 13ms (13ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 34ms (33ms|1ms)
 19ms (18ms|1ms)
 18ms (17ms|1ms)
 16ms (15ms|1ms)
 17ms (16ms|1ms)
 18ms (18ms|1ms)
 19ms (19ms|1ms)
 12ms (12ms|1ms)
 13ms (12ms|1ms)
 14ms (13ms|1ms)
 29ms (28ms|1ms)
 16ms (15ms|1ms)
 12ms (11ms|1ms)
 17ms (16ms|1ms)

Describing Resolve-WorktreeOperandTarget
 20ms (18ms|2ms)
 10ms (9ms|1ms)
 11ms (11ms|1ms)
 9ms (8ms|1ms)
 13ms (12ms|1ms)

Describing Run resolver result contract
 35ms (34ms|2ms)
 31ms (30ms|1ms)
 28ms (27ms|1ms)
 23ms (22ms|1ms)
 30ms (29ms|1ms)

Describing Run resolver purity (parse-tree scan)
 25ms (23ms|2ms)
 23ms (22ms|1ms)
 50ms (49ms|1ms)

Describing Resolver module exports
 7ms (5ms|1ms)
 3ms (2ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1'
Describing Find-WorktreeRunIdentitySignal
 7ms (6ms|1ms)
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 6ms (6ms|0ms)

Describing Get-WorktreeRunCheckpointText
 5ms (3ms|1ms)
 3ms (3ms|1ms)
 6ms (5ms|1ms)
 47ms (46ms|1ms)

Describing Get-WorktreeRunCheckpointPath
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|0ms)
 11ms (10ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1'
Describing Resolve-WorktreeEpicTarget
 24ms (22ms|1ms)
 17ms (17ms|1ms)
 13ms (13ms|0ms)
 14ms (13ms|1ms)
 16ms (16ms|1ms)
 20ms (19ms|1ms)
 17ms (17ms|1ms)
 19ms (19ms|1ms)
 28ms (28ms|1ms)
 16ms (15ms|1ms)
 11ms (11ms|1ms)
 12ms (11ms|1ms)
 12ms (11ms|1ms)
 12ms (12ms|1ms)
 12ms (11ms|1ms)

Describing Resolve-WorktreeParallelTarget
 13ms (12ms|1ms)
 16ms (15ms|0ms)
 16ms (16ms|1ms)
 19ms (18ms|1ms)
 10ms (9ms|1ms)
 11ms (10ms|1ms)
 12ms (11ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1'
Describing WorktreeTargetResolution
 Context result factory and field invariants
 11ms (9ms|2ms)
 6ms (5ms|1ms)
 7ms (6ms|1ms)
 5ms (4ms|1ms)
 5ms (5ms|1ms)
 9ms (9ms|1ms)
 11ms (10ms|1ms)
 28ms (28ms|1ms)
 13ms (12ms|1ms)
 Context signal extraction
 4ms (3ms|1ms)
 4ms (3ms|1ms)
 2ms (1ms|1ms)
 4ms (3ms|1ms)
 1ms (1ms|1ms)
 2ms (1ms|1ms)
 4ms (3ms|1ms)
 2ms (1ms|1ms)
 3ms (3ms|1ms)
 1ms (1ms|1ms)
 1ms (1ms|1ms)
 2ms (1ms|1ms)
 Context required matrix
 29ms (28ms|1ms)
 20ms (19ms|1ms)
 25ms (22ms|3ms)
 23ms (22ms|1ms)
 31ms (30ms|1ms)
 15ms (14ms|1ms)
 21ms (20ms|1ms)
 13ms (12ms|1ms)
 21ms (20ms|1ms)
 18ms (17ms|1ms)
 22ms (21ms|1ms)
 16ms (15ms|1ms)
 Context ambiguity, no target, and Ruling B
 30ms (28ms|2ms)
 23ms (23ms|1ms)
 25ms (24ms|1ms)
 29ms (28ms|1ms)
 32ms (32ms|1ms)
 46ms (45ms|1ms)
 14ms (13ms|1ms)
 14ms (14ms|1ms)
 54ms (53ms|1ms)
 33ms (32ms|1ms)
 39ms (38ms|1ms)
 8ms (7ms|1ms)
 60ms (60ms|1ms)
 Context path composition
 6ms (4ms|1ms)
 2ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 6ms (5ms|1ms)
Tests completed in 5.71s
Tests Passed: 266, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 784 ms.
Covered 95.87% / 75%. 460 analyzed Commands in 2 Files.
Missed commands:

File                        Class Function                             Line Command
----                        ----- --------                             ---- -------
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText        147 if ([string]::IsNullOrWhiteSpace($Path)) { …
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText        147 return $null
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText        148 if (-not (Test-Path -LiteralPath $Path -Pat…
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText        148 Test-Path -LiteralPath $Path -PathType Leaf…
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText        148 return $null
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText        149 return [System.IO.File]::ReadAllText($Path)
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText        149 return $null
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointIssue       175 return $null
WorktreeItemResolution.psm1       Get-WorktreeItemLiveRoot              207 Get-WorktreeResolutionWorktreeRoot -Session…
WorktreeItemResolution.psm1       Resolve-WorktreeItemTarget            372 (Get-Location).ProviderPath
WorktreeItemResolution.psm1       Resolve-WorktreeItemTarget            372 Get-Location
WorktreeItemResolution.psm1       Test-WorktreeItemCheckpointRecordsPr  412 return $false
WorktreeItemResolution.psm1       Resolve-WorktreeItemTargetByPrNumber  451 (Get-Location).ProviderPath
WorktreeItemResolution.psm1       Resolve-WorktreeItemTargetByPrNumber  451 Get-Location
WorktreeItemResolution.psm1       Resolve-WorktreeItemTargetByPrNumber  454 return (New-WorktreeResolutionTargetResult …
WorktreeItemResolution.psm1       Resolve-WorktreeItemTargetByPrNumber  454 New-WorktreeResolutionTargetResult -Status …
WorktreeRunResolution.psm1        Test-WorktreeRunPathEqual             352 return $false
WorktreeRunResolution.psm1        Test-WorktreeRunPrNumberEqual         371 return $false
WorktreeRunResolution.psm1        Resolve-WorktreeOperandTarget         471 $sessionWorktree = ConvertTo-WorktreeResolu…


TotalCount=266
PassedCount=266
FailedCount=0
COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 AnalyzedLines=149 CoveredLines=149 LinePercent=100
HIT file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 Lines=28,29,31,32,33,36,37,40,41,44,47,48,49,52,64,65,66,68,69,71,72,91,92,93,94,95,114,115,117,118,140,141,142,154,155,156,158,159,172,173,174,187,188,189,190,191,204,205,208,210,223,224,225,227,228,229,231,233,260,261,262,265,266,267,268,269,270,271,272,273,277,278,279,280,282,287,288,289,291,292,293,297,298,299,300,301,302,304,306,329,330,331,333,334,335,336,337,339,352,353,354,355,356,357,369,370,371,372,386,387,388,389,391,392,393,396,397,398,400,402,432,433,434,435,436,437,438,440,441,442,443,444,445,447,470,471,472,473,474,477,478,479,481,482,483,484,486,487,490
MISSED file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 Lines=
COVERAGE file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 AnalyzedLines=136 CoveredLines=131 LinePercent=96.32
HIT file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 Lines=29,30,32,33,37,41,44,57,76,96,97,98,100,101,102,103,122,125,126,127,129,169,170,171,172,175,176,177,200,201,203,204,210,211,212,214,245,248,249,250,251,253,254,255,256,272,273,275,276,277,279,280,282,285,286,287,288,291,292,295,296,297,298,300,301,302,307,308,309,310,312,313,314,315,317,332,333,334,335,339,340,341,343,344,345,347,349,372,374,375,376,377,381,382,383,385,386,387,393,394,396,409,410,411,412,414,415,416,417,419,420,421,422,424,426,451,452,453,457,458,459,460,461,463,464,466,467,468,470,471,474
MISSED file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 Lines=147,148,149,207,454
```
