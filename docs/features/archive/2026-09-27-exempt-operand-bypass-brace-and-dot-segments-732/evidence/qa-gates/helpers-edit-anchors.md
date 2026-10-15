# Helpers edit anchors (issue #732)

Timestamp: 2026-10-09T03-53
Task: [P2-T2]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/detect-task.sh (R-DETECT, spec p2-t2.spec)
EXIT_CODE: 0

## Output

```text
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 470
CR_PRESENT: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
PARSE_ERRORS: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
FUNCTION: Split-OrchestrationCommandLine start=63
FUNCTION: Test-OrchestrationCommandTextUnresolvable start=115
FUNCTION: ConvertTo-OrchestrationCommandToken start=164
FUNCTION: Test-ExemptOrchestrationOperand start=221
FUNCTION: Test-ExemptOrchestrationSelector start=251
FUNCTION: Test-ExemptOrchestrationSegmentToken start=312
FUNCTION: Test-ExemptOrchestrationStagingCommand start=411
ANCHOR: E1 mode=whole count=1 line=10 region=preamble
ANCHOR: K1 mode=whole count=0 line=0 region=none
ANCHOR: K2 mode=whole count=0 line=0 region=none
ANCHOR: K3 mode=whole count=0 line=0 region=none
ANCHOR: K4 mode=whole count=0 line=0 region=none
ANCHOR: K5 mode=whole count=0 line=0 region=none
ANCHOR: K6 mode=whole count=0 line=0 region=none
ANCHOR: E3a mode=whole count=0 line=0 region=none
ANCHOR: E3b mode=whole count=0 line=0 region=none
ANCHOR: B1 mode=whole count=0 line=0 region=none
ANCHOR: B2 mode=whole count=0 line=0 region=none
ANCHOR: E5a mode=whole count=0 line=0 region=none
ANCHOR: E6 mode=whole count=1 line=221 region=Test-ExemptOrchestrationOperand
ANCHOR: S1 mode=whole count=0 line=0 region=none
ANCHOR: S2 mode=whole count=0 line=0 region=none
ANCHOR: S3 mode=whole count=0 line=0 region=none
ANCHOR: K1-NEW mode=whole count=1 line=36 region=preamble
ANCHOR: K2-NEW mode=whole count=1 line=37 region=preamble
ANCHOR: K3-NEW mode=whole count=1 line=38 region=preamble
ANCHOR: K4-NEW mode=whole count=1 line=40 region=preamble
ANCHOR: K5-NEW mode=whole count=1 line=43 region=preamble
ANCHOR: K6-NEW mode=whole count=1 line=44 region=preamble
ANCHOR: B1-NEW mode=whole count=1 line=135 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: B2-NEW mode=whole count=1 line=136 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: S1-NEW mode=whole count=1 line=420 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: S2-NEW mode=whole count=1 line=440 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: S3-NEW mode=whole count=1 line=441 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: E6-NEW mode=whole count=1 line=237 region=Test-ExemptOrchestrationOperand
REGION_TOKEN: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 Test-ExemptOrchestrationOperand -replace lines=0
REGION_TOKEN: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 Test-ExemptOrchestrationOperand literalPrefix lines=0
REGION_TOKEN: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 Test-ExemptOrchestrationOperand PathspecWildcardCharacters lines=0
```

Output Summary: Observed PARSE_ERRORS 0 and 470 lines; replaced old anchors K1-K6, E3a, E3b, B1, B2, E5a, S1-S3 at count=0; retained E1 (preamble) and E6 (Test-ExemptOrchestrationOperand) at count=1; every new line at count=1; three REGION_TOKEN lines at lines=0. See the ANCHOR lines above for the observed values.

