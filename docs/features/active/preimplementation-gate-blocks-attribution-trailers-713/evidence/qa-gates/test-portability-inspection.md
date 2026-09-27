# P1-T4 Portability and Structure Inspection (AC11)

Timestamp: 2026-09-27T03-43
Command: sh <SCRATCHPAD>/x713-port.sh (R-PORT on tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1)
EXIT_CODE: 0
Output Summary: All eleven hygiene tokens and the drive-letter regex report matches=0; both git-invocation regexes report matches=0. Join-Path 2, $PSScriptRoot 1, the decision seam 1. `Get-AttributionTrailerDecision` appears on line 21 (its `function Get-AttributionTrailerDecision {` definition) and line 62, which lies between the `It 'admits` line 42 and the `It 'denies` line 67, so the deny rows never call the decision seam. `Test-ImplementationCommand` is on line 93, after the `It 'denies` line.

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
TOKEN: Test-ImplementationCommand matches=1 lines=93
TOKEN: It 'admits matches=1 lines=42
TOKEN: It 'denies matches=1 lines=67
TOKEN: Describe ' matches=1 lines=13
REGEX: [A-Za-z]:[\\/] matches=0
CALL_GIT_REGEX: (^|[^&])&\s*git\b matches=0
BARE_GIT_REGEX: ^\s*(\$[A-Za-z_]\w*\s*=\s*)?git(\.exe)?\s matches=0
```

Line 21 text: `        function Get-AttributionTrailerDecision {`.
