# P0-T29 Coverage baseline CG-LIB

Timestamp: 2026-10-08T23-50
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1  -TestPath tests/scripts/claude-lib/worktree-resolution -CoveragePath .claude/lib/worktree-resolution/WorktreeRunResolution.psm1,.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 -CoverageOutputPath SCRATCH/cov-lib-base.xml -ReportPath SCRATCH/cov-lib-base.txt
EXIT_CODE: 0
Output Summary:
  Failed: 0, 
  TotalCount=254
  PassedCount=254
  FailedCount=0
  COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 AnalyzedLines=149 CoveredLines=149 LinePercent=100
  COVERAGE file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 AnalyzedLines=106 CoveredLines=102 LinePercent=96.23
  Baseline failure set (CG-LIB): empty
  Baseline container set (CG-LIB): empty
  BASEPCT WRR (.claude/lib/worktree-resolution/WorktreeRunResolution.psm1): 100
  BASEPCT WIR (.claude/lib/worktree-resolution/WorktreeItemResolution.psm1): 96.23

## Full output

```text
Pester v5.6.1

Starting discovery in 10 files.
Discovery found 254 tests in 315ms.
Starting code coverage.
Code Coverage preparation finished after 243 ms.
Running tests.

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1'
Describing Get-EpicPrCreationReadinessFailure
 50ms (32ms|18ms)
 9ms (7ms|2ms)
 16ms (15ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)

Describing Get-EpicCommandLegReadinessFailure
 5ms (3ms|1ms)
 5ms (4ms|1ms)
 2ms (2ms|0ms)
 4ms (4ms|1ms)
 3ms (3ms|0ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)
 3ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint run-target location
 195ms (193ms|2ms)
 38ms (37ms|1ms)
 50ms (50ms|1ms)
 50ms (50ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1'
Describing Resolve-EpicScopeCheckpoint epic-scope matches
 28ms (27ms|1ms)
 29ms (28ms|0ms)
 34ms (33ms|1ms)
 32ms (31ms|1ms)
 22ms (22ms|1ms)

Describing Resolve-EpicScopeCheckpoint fail-closed non-matches
 26ms (25ms|1ms)
 28ms (27ms|1ms)
 21ms (20ms|1ms)
 24ms (23ms|1ms)
 20ms (19ms|1ms)
 22ms (22ms|1ms)
 26ms (26ms|1ms)
 17ms (16ms|1ms)
 20ms (19ms|1ms)

Describing Resolve-EpicScopeCheckpoint checkpoint path composition
 27ms (25ms|1ms)
 24ms (23ms|1ms)
 40ms (39ms|1ms)

Describing EpicScopeResolution read seams
 21ms (19ms|2ms)
 22ms (22ms|1ms)
 12ms (12ms|1ms)
 12ms (12ms|0ms)
 23ms (22ms|0ms)

Describing Resolve-EpicScopeCheckpoint head matching ignores a text branch signal (issue #663 remediation CR-2)
 27ms (25ms|1ms)
 30ms (29ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1'
Describing WorktreeItemResolution checkpoint path
 4ms (3ms|1ms)
 16ms (16ms|1ms)
 3ms (3ms|1ms)

Describing WorktreeItemResolution issue signals
 21ms (20ms|1ms)
 3ms (2ms|0ms)
 6ms (5ms|1ms)
 6ms (6ms|0ms)

Describing WorktreeItemResolution checkpoint reader
 14ms (13ms|2ms)
 18ms (18ms|0ms)

Describing WorktreeItemResolution liveness seam
 35ms (34ms|1ms)
 13ms (13ms|0ms)

Describing WorktreeItemResolution target resolution
 13ms (12ms|1ms)
 34ms (34ms|0ms)
 12ms (12ms|1ms)
 16ms (15ms|0ms)
 16ms (16ms|0ms)
 15ms (15ms|1ms)
 21ms (20ms|1ms)
 16ms (16ms|1ms)
 9ms (8ms|0ms)
 11ms (11ms|0ms)
 37ms (37ms|1ms)
 9ms (8ms|1ms)
 12ms (12ms|1ms)
 11ms (11ms|0ms)
 8ms (8ms|0ms)
 36ms (36ms|0ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1'
Describing WorktreeResolution core.json manifest membership
 9ms (7ms|2ms)
 4ms (4ms|1ms)
 4ms (4ms|0ms)
 6ms (5ms|1ms)
 4ms (4ms|1ms)
 7ms (6ms|1ms)
 7ms (6ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 4ms (3ms|1ms)
 14ms (13ms|1ms)

Describing WorktreeResolution bundle mirror byte identity
 17ms (14ms|3ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)
 5ms (4ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1'
Describing WorktreeResolution seam default bodies
 17ms (14ms|2ms)
 9ms (8ms|1ms)
 42ms (41ms|1ms)

Describing WorktreeResolution
 Context path normalisation
 19ms (11ms|8ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 9ms (7ms|1ms)
 5ms (2ms|3ms)
 4ms (2ms|1ms)
 9ms (6ms|2ms)
 4ms (2ms|2ms)
 3ms (2ms|1ms)
 4ms (2ms|1ms)
 Context root marker
 15ms (13ms|2ms)
 19ms (18ms|1ms)
 24ms (22ms|1ms)
 10ms (9ms|1ms)
 10ms (9ms|1ms)
 9ms (8ms|1ms)
 Context upward ascent
 19ms (17ms|2ms)
 28ms (28ms|1ms)
 19ms (18ms|1ms)
 29ms (28ms|1ms)
 21ms (21ms|1ms)
 6ms (6ms|1ms)
 Context worktree enumeration
 38ms (37ms|1ms)
 27ms (26ms|1ms)
 26ms (26ms|1ms)
 12ms (11ms|1ms)
 11ms (10ms|1ms)
 9ms (8ms|1ms)
 18ms (17ms|1ms)
 10ms (10ms|1ms)
 18ms (17ms|1ms)
 14ms (14ms|1ms)
 22ms (21ms|2ms)
 17ms (14ms|3ms)
 22ms (20ms|2ms)
 22ms (22ms|1ms)
 Context repo-relative normalisation
 41ms (40ms|2ms)
 7ms (7ms|1ms)
 6ms (5ms|1ms)
 19ms (18ms|1ms)
 5ms (4ms|1ms)
 9ms (8ms|1ms)
 Context reason code
 8ms (6ms|1ms)
 11ms (10ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1'
Describing Resolve-WorktreeRunTargetByRecord
 38ms (37ms|1ms)
 20ms (19ms|1ms)
 16ms (15ms|1ms)
 16ms (15ms|1ms)
 16ms (15ms|1ms)
 16ms (15ms|1ms)
 15ms (15ms|1ms)
 11ms (11ms|1ms)
 14ms (14ms|1ms)
 17ms (16ms|1ms)
 17ms (16ms|1ms)
 19ms (18ms|1ms)
 14ms (13ms|1ms)

Describing Resolve-WorktreeOperandTarget
 22ms (20ms|1ms)
 12ms (11ms|1ms)
 13ms (12ms|1ms)
 7ms (7ms|1ms)
 12ms (11ms|1ms)

Describing Run resolver result contract
 24ms (23ms|1ms)
 31ms (31ms|1ms)
 21ms (20ms|1ms)
 15ms (14ms|1ms)
 30ms (30ms|1ms)

Describing Run resolver purity (parse-tree scan)
 25ms (23ms|1ms)
 34ms (34ms|1ms)
 50ms (49ms|1ms)

Describing Resolver module exports
 7ms (5ms|2ms)
 4ms (3ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1'
Describing Find-WorktreeRunIdentitySignal
 8ms (7ms|1ms)
 4ms (4ms|1ms)
 4ms (4ms|1ms)
 4ms (3ms|1ms)
 3ms (3ms|1ms)
 4ms (4ms|1ms)
 3ms (2ms|1ms)
 3ms (3ms|1ms)
 6ms (5ms|1ms)

Describing Get-WorktreeRunCheckpointText
 5ms (3ms|2ms)
 3ms (3ms|1ms)
 5ms (4ms|1ms)
 51ms (50ms|1ms)

Describing Get-WorktreeRunCheckpointPath
 4ms (3ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 10ms (10ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1'
Describing Resolve-WorktreeEpicTarget
 14ms (13ms|1ms)
 22ms (21ms|1ms)
 14ms (14ms|1ms)
 14ms (13ms|1ms)
 15ms (14ms|1ms)
 15ms (15ms|0ms)
 16ms (16ms|0ms)
 19ms (19ms|1ms)
 18ms (18ms|1ms)
 22ms (22ms|1ms)
 10ms (9ms|1ms)
 11ms (10ms|1ms)
 14ms (13ms|1ms)
 12ms (11ms|1ms)
 12ms (11ms|1ms)

Describing Resolve-WorktreeParallelTarget
 14ms (13ms|2ms)
 16ms (15ms|1ms)
 17ms (17ms|1ms)
 19ms (18ms|1ms)
 23ms (22ms|1ms)
 21ms (19ms|1ms)
 24ms (23ms|1ms)

Running tests from 'tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1'
Describing WorktreeTargetResolution
 Context result factory and field invariants
 27ms (23ms|4ms)
 11ms (9ms|1ms)
 16ms (15ms|1ms)
 17ms (15ms|1ms)
 11ms (10ms|1ms)
 17ms (16ms|1ms)
 20ms (19ms|1ms)
 50ms (49ms|1ms)
 23ms (22ms|1ms)
 Context signal extraction
 7ms (5ms|2ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 7ms (6ms|1ms)
 3ms (2ms|1ms)
 6ms (5ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 3ms (2ms|1ms)
 Context required matrix
 58ms (56ms|2ms)
 36ms (35ms|1ms)
 39ms (37ms|1ms)
 35ms (33ms|1ms)
 43ms (42ms|1ms)
 23ms (22ms|1ms)
 27ms (26ms|1ms)
 24ms (23ms|1ms)
 20ms (19ms|1ms)
 15ms (14ms|1ms)
 18ms (17ms|1ms)
 14ms (13ms|1ms)
 Context ambiguity, no target, and Ruling B
 26ms (24ms|2ms)
 19ms (19ms|1ms)
 15ms (14ms|1ms)
 18ms (18ms|1ms)
 22ms (21ms|1ms)
 28ms (27ms|1ms)
 8ms (7ms|0ms)
 9ms (9ms|1ms)
 32ms (32ms|1ms)
 29ms (28ms|1ms)
 41ms (40ms|1ms)
 8ms (7ms|1ms)
 55ms (54ms|1ms)
 Context path composition
 5ms (4ms|1ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 1ms (1ms|0ms)
 8ms (7ms|1ms)
Tests completed in 5.95s
Tests Passed: 254, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Code Coverage result processed in 962 ms.
Covered 96.52% / 75%. 402 analyzed Commands in 2 Files.
Missed commands:

File                        Class Function                        Line Command
----                        ----- --------                        ---- -------
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText   146 if ([string]::IsNullOrWhiteSpace($Path)) { retur…
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText   146 return $null
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText   147 if (-not (Test-Path -LiteralPath $Path -PathType…
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText   147 Test-Path -LiteralPath $Path -PathType Leaf -Err…
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText   147 return $null
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText   148 return [System.IO.File]::ReadAllText($Path)
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointText   148 return $null
WorktreeItemResolution.psm1       Get-WorktreeItemCheckpointIssue  174 return $null
WorktreeItemResolution.psm1       Get-WorktreeItemLiveRoot         206 Get-WorktreeResolutionWorktreeRoot -SessionRoot …
WorktreeItemResolution.psm1       Resolve-WorktreeItemTarget       371 (Get-Location).ProviderPath
WorktreeItemResolution.psm1       Resolve-WorktreeItemTarget       371 Get-Location
WorktreeRunResolution.psm1        Test-WorktreeRunPathEqual        352 return $false
WorktreeRunResolution.psm1        Test-WorktreeRunPrNumberEqual    371 return $false
WorktreeRunResolution.psm1        Resolve-WorktreeOperandTarget    471 $sessionWorktree = ConvertTo-WorktreeResolutionN…


TotalCount=254
PassedCount=254
FailedCount=0
COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 AnalyzedLines=149 CoveredLines=149 LinePercent=100
HIT file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 Lines=28,29,31,32,33,36,37,40,41,44,47,48,49,52,64,65,66,68,69,71,72,91,92,93,94,95,114,115,117,118,140,141,142,154,155,156,158,159,172,173,174,187,188,189,190,191,204,205,208,210,223,224,225,227,228,229,231,233,260,261,262,265,266,267,268,269,270,271,272,273,277,278,279,280,282,287,288,289,291,292,293,297,298,299,300,301,302,304,306,329,330,331,333,334,335,336,337,339,352,353,354,355,356,357,369,370,371,372,386,387,388,389,391,392,393,396,397,398,400,402,432,433,434,435,436,437,438,440,441,442,443,444,445,447,470,471,472,473,474,477,478,479,481,482,483,484,486,487,490
MISSED file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 Lines=
COVERAGE file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 AnalyzedLines=106 CoveredLines=102 LinePercent=96.23
HIT file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 Lines=28,29,31,32,36,40,43,56,75,95,96,97,99,100,101,102,121,124,125,126,128,168,169,170,171,174,175,176,199,200,202,203,209,210,211,213,244,247,248,249,250,252,253,254,255,271,272,274,275,276,278,279,281,284,285,286,287,290,291,294,295,296,297,299,300,301,306,307,308,309,311,312,313,314,316,331,332,333,334,338,339,340,342,343,344,346,348,371,373,374,375,376,380,381,382,384,385,386,392,393,395,398
MISSED file=.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 Lines=146,147,148,206
```
