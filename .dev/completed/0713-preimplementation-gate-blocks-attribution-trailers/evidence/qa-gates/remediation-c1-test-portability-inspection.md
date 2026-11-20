# Remediation Cycle 1 - Test Portability Inspection ([P1-T3], AC4, AC11)

Timestamp: 2026-09-27T05-03

Command: sh <SCRATCHPAD>/c1-port.sh (R-PORT-C1 output of [P1-T2], recorded in `evidence/other/remediation-c1-test-rows-added.md`)

EXIT_CODE: 0

Output Summary: All original [P1-T4] conditions hold. Prohibited tokens (`origin/`, `artifacts/`, `.claude/state`, `Set-Location`, `TestDrive`, `Start-Process`, `New-TemporaryFile`, `GetTempFileName`, `$env:TEMP`, `Mock`), the drive-letter regex, CALL_GIT_REGEX, and BARE_GIT_REGEX each matches=0. Join-Path matches=2; $PSScriptRoot matches=1; Invoke-OrchestrationPreimplementationGateDecision matches=1; Test-ImplementationCommand matches=1 at line 96, after the `It 'denies` line 67; Get-AttributionTrailerDecision matches=2 (line 21, the function definition, and line 62, strictly between `It 'admits` line 42 and `It 'denies` line 67). The three `Label = 'a typographic` lines (90, 91, 92) lie strictly between line 67 and line 96. Result: PASS.

## TOKEN lines

```text
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
```

## Regex lines

```text
REGEX: [A-Za-z]:[\\/] matches=0
CALL_GIT_REGEX: (^|[^&])&\s*git\b matches=0
BARE_GIT_REGEX: ^\s*(\$[A-Za-z_]\w*\s*=\s*)?git(\.exe)?\s matches=0
```

## Line-position checks

- Line 21: `function Get-AttributionTrailerDecision {` (definition).
- Line 62: `$decision = Get-AttributionTrailerDecision -Command $Command -Kind $PayloadKind` (42 < 62 < 67).
- Test-ImplementationCommand line 96 > `It 'denies` line 67.
- Typographic label lines 90, 91, 92: 67 < each < 96.
