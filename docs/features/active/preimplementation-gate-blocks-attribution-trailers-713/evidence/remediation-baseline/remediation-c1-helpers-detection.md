# Remediation Cycle 1 - P0-T5 Helpers Detection and Line Counts

Timestamp: 2026-09-27T04-50
Command: sh <SCRATCHPAD>/c1-port.sh (R-PORT-C1); also sh <SCRATCHPAD>/c1-detect.sh (R-DETECT-C1)
EXIT_CODE: 0
R_DETECT_C1_EXIT_CODE: 0
Output Summary: The four helpers copies are byte-identical (BYTE_IDENTICAL: True), 497 lines each, no CR, 0 non-ASCII bytes. O1 to O4 are in the preamble, O5 to O9 in Test-OrchestrationCommandTextUnresolvable, O10 and O11 in Test-ExemptOrchestrationStagingCommand, each count=1; N1 to N11 count=0; all eleven KEEP_ labels count=1 in their original regions. TOKEN_663_713_LINES 2, TOKEN_COMMENT_INTRODUCER_LINES 1, TOKEN_TYPOGRAPHIC_CONSTANT_LINES 0, REDIRECTION_REF_LINES 0. The test file has 99 lines, 0 non-ASCII bytes, and zero matches for the four [char] tokens and the typographic label token. All acceptance conditions hold.

PRE_EDIT_LINE_COUNT: 497

## R-DETECT-C1 output

```text
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 9E84AF141F7166F1BE27A2E62B53437CB1537E1AC4230CCC054C11295AF1BAE7
CR_PRESENT: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
NON_ASCII_BYTES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 9E84AF141F7166F1BE27A2E62B53437CB1537E1AC4230CCC054C11295AF1BAE7
CR_PRESENT: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
NON_ASCII_BYTES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 9E84AF141F7166F1BE27A2E62B53437CB1537E1AC4230CCC054C11295AF1BAE7
CR_PRESENT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
NON_ASCII_BYTES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 9E84AF141F7166F1BE27A2E62B53437CB1537E1AC4230CCC054C11295AF1BAE7
CR_PRESENT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
NON_ASCII_BYTES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
BYTE_IDENTICAL: True
FUNCTION: Split-OrchestrationCommandLine start=58
FUNCTION: Test-OrchestrationCommandTextUnresolvable start=110
FUNCTION: ConvertTo-OrchestrationCommandToken start=163
FUNCTION: Test-ExemptOrchestrationOperand start=220
FUNCTION: Test-ExemptOrchestrationSelector start=278
FUNCTION: Test-ExemptOrchestrationSegmentToken start=339
FUNCTION: Test-ExemptOrchestrationStagingCommand start=438
ANCHOR: O1 count=1 line=31 region=preamble
ANCHOR: O2 count=1 line=32 region=preamble
ANCHOR: O3 count=1 line=33 region=preamble
ANCHOR: O4 count=1 line=34 region=preamble
ANCHOR: O5 count=1 line=118 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: O6 count=1 line=119 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: O7 count=1 line=120 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: O8 count=1 line=130 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: O9 count=1 line=131 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: O10 count=1 line=467 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: O11 count=1 line=468 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: N1 count=0 line=0 region=none
ANCHOR: N2 count=0 line=0 region=none
ANCHOR: N3 count=0 line=0 region=none
ANCHOR: N4 count=0 line=0 region=none
ANCHOR: N5 count=0 line=0 region=none
ANCHOR: N6 count=0 line=0 region=none
ANCHOR: N7 count=0 line=0 region=none
ANCHOR: N8 count=0 line=0 region=none
ANCHOR: N9 count=0 line=0 region=none
ANCHOR: N10 count=0 line=0 region=none
ANCHOR: N11 count=0 line=0 region=none
ANCHOR: KEEP_K5 count=1 line=36 region=preamble
ANCHOR: KEEP_U1 count=1 line=115 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U2 count=1 line=116 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U3 count=1 line=117 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U5 count=1 line=138 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U6 count=1 line=140 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U7 count=1 line=156 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_S1 count=1 line=396 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: KEEP_S2 count=1 line=402 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: KEEP_S3 count=1 line=403 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: KEEP_S4 count=1 line=410 region=Test-ExemptOrchestrationSegmentToken
TOKEN_663_713_LINES: 2
TOKEN_COMMENT_INTRODUCER_LINES: 1
TOKEN_TYPOGRAPHIC_CONSTANT_LINES: 0
REDIRECTION_REF_LINES: 0
```

## R-PORT-C1 output

```text
TEST_FILE_LINES: 99
CR_PRESENT: False
NON_ASCII_BYTES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 0
TOKEN: origin/ matches=0 lines=none
TOKEN: artifacts/ matches=0 lines=none
TOKEN: .claude/state matches=0 lines=none
TOKEN: Set-Location matches=0 lines=none
TOKEN: TestDrive matches=0 lines=none
TOKEN: Start-Process matches=0 lines=none
TOKEN: New-TemporaryFile matches=0 lines=none
TOKEN: GetTempFileName matches=0 lines=none
TOKEN: $env:TEMP matches=0 lines=none
TOKEN: Mock matches=0 lines=none
TOKEN: Join-Path matches=2 lines=18,19
TOKEN: $PSScriptRoot matches=1 lines=18
TOKEN: Invoke-OrchestrationPreimplementationGateDecision matches=1 lines=36
TOKEN: Get-AttributionTrailerDecision matches=2 lines=21,62
TOKEN: Test-ImplementationCommand matches=1 lines=93
TOKEN: It 'admits matches=1 lines=42
TOKEN: It 'denies matches=1 lines=67
TOKEN: Describe ' matches=1 lines=13
TOKEN: [char]0x2018 matches=0 lines=none
TOKEN: [char]0x2019 matches=0 lines=none
TOKEN: [char]0x201C matches=0 lines=none
TOKEN: [char]0x201D matches=0 lines=none
TOKEN: Label = 'a typographic matches=0 lines=none
REGEX: [A-Za-z]:[\\/] matches=0
CALL_GIT_REGEX: (^|[^&])&\s*git\b matches=0
BARE_GIT_REGEX: ^\s*(\$[A-Za-z_]\w*\s*=\s*)?git(\.exe)?\s matches=0
```
