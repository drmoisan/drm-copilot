# Remediation Cycle 1 - Test Rows Added ([P1-T2])

Timestamp: 2026-09-27T05-02

Command: sh <SCRATCHPAD>/c1-port.sh (R-PORT-C1, launcher `exec pwsh -NoProfile -File "$(dirname "$0")/c1-port.ps1"`)

EXIT_CODE: 0

Output Summary: The three section-4 deny rows were inserted after the `an escaped single quote near a dollar sign` row with the Edit tool. TEST_FILE_LINES: 102; CR_PRESENT: False; NON_ASCII_BYTES 0; `Label = 'a typographic` matches=3 (lines 90, 91, 92); `[char]0x2019` matches=3; `[char]0x2018` matches=3; `[char]0x201C` matches=1; `[char]0x201D` matches=1. R-FMTPROBE: FORMAT_STABLE: True, FORMATTED_LINE_COUNT: 102.

## R-PORT-C1 output

```text
TEST_FILE_LINES: 102
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
TOKEN: Test-ImplementationCommand matches=1 lines=96
TOKEN: It 'admits matches=1 lines=42
TOKEN: It 'denies matches=1 lines=67
TOKEN: Describe ' matches=1 lines=13
TOKEN: [char]0x2018 matches=3 lines=90,91,92
TOKEN: [char]0x2019 matches=3 lines=90,91,92
TOKEN: [char]0x201C matches=1 lines=91
TOKEN: [char]0x201D matches=1 lines=91
TOKEN: Label = 'a typographic matches=3 lines=90,91,92
REGEX: [A-Za-z]:[\\/] matches=0
CALL_GIT_REGEX: (^|[^&])&\s*git\b matches=0
BARE_GIT_REGEX: ^\s*(\$[A-Za-z_]\w*\s*=\s*)?git(\.exe)?\s matches=0
```

## R-FMTPROBE output

Command: sh <SCRATCHPAD>/x713-fmtprobe-test.sh (EXIT_CODE: 0)

```text
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
FORMAT_STABLE: True
FORMATTED_LINE_COUNT: 102
```
