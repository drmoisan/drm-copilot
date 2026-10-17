# R4 Trim-Only Token Cases: discovery Suite (P2-T2)

Timestamp: 2026-10-16T01-16

Command: sh SCRATCH/issue-929/P2-T2-1.sh
Script: `Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1' -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'FAILED_BLOCKS=' + $r.FailedBlocksCount; 'FAILED_CONTAINERS=' + $r.FailedContainersCount; 'PASSED=' + $r.PassedCount; exit [int]($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount)`
EXIT_CODE: 0

Output Summary: `FAILED=0`, `FAILED_BLOCKS=0`, `FAILED_CONTAINERS=0`, `PASSED=34`. The nine required complete lines are present (whole-line fixed-string comparison; none missing) (AC-05, AC-06):
- Passed | R4 returns no reference for a lone backtick token
- Passed | R4 returns no reference for an empty-after-trim token
- Passed | R4 skips a lone backtick token and returns the following discovery reference
- Passed | R4 skips the trim-only token () and returns the discovery reference
- Passed | R4 skips the trim-only token [] and returns the discovery reference
- Passed | R4 skips the trim-only token '' and returns the discovery reference
- Passed | R4 skips the trim-only token , and returns the discovery reference
- Passed | R4 skips the trim-only token ; and returns the discovery reference
- Passed | R4 gate allows a message containing only a lone backtick without invoking the validator

P2-T1 structure check: `git diff HEAD -U0` shows one hunk `@@ -356,0 +357,70 @@` (70 inserted lines, 0 deleted); the R4 Context holds 6 `It` blocks; the existing `It 'R4 skips a token that is empty after trimming'` is unchanged.

Full output:
```
Passed | returns Ok = $true and invokes the validator exactly once
Passed | returns Ok = $false with the validator text embedded verbatim
Passed | returns Ok = $true without invoking the validator
Passed | returns Ok = $true without invoking the validator when the seam reports absent
Passed | returns Ok = $false with a payload anomaly message for empty input text
Passed | returns Ok = $false with a payload anomaly message for malformed input text
Passed | returns Ok = $false identically to any other non-conforming result
Passed | contains no TaskMaster/TMW/Outlook/VSTO token in its own source text
Passed | returns Ok = $true without invoking the validator when last_assistant_message is an empty string
Passed | reports Present = $true with the declaration when the profile reader returns a value
Passed | returns Ok = $true when the validator reports success with EMPTY output
Passed | returns Ok = $false when the validator reports success but emits a success line
Passed | returns Ok = $true when the validator reports success with whitespace-only output
Passed | exits 2 with a DISCOVERY_ARTIFACT_GATE_BLOCKED reason on stderr when last_assistant_message references a failing artifact
Passed | exits 0 when last_assistant_message references a conforming artifact
Passed | exits 0 when last_assistant_message carries no discovery artifact reference
Passed | exits 0 when last_assistant_message is an empty string
Passed | exits 0 when the required-artifact declaration is absent
Passed | blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
Passed | exits 2 with a payload anomaly reason for empty stdin
Passed | exits 2 with a payload anomaly reason for malformed stdin
Passed | exits 2 with a payload anomaly reason when last_assistant_message is absent
Passed | keeps validating when stop_hook_active is true
Passed | exits 2 in a separate process when stdin is not a JSON envelope
Passed | R4 skips a token that is empty after trimming
Passed | R4 returns no reference for a lone backtick token
Passed | R4 returns no reference for an empty-after-trim token
Passed | R4 skips a lone backtick token and returns the following discovery reference
Passed | R4 skips the trim-only token () and returns the discovery reference
Passed | R4 skips the trim-only token [] and returns the discovery reference
Passed | R4 skips the trim-only token '' and returns the discovery reference
Passed | R4 skips the trim-only token , and returns the discovery reference
Passed | R4 skips the trim-only token ; and returns the discovery reference
Passed | R4 gate allows a message containing only a lone backtick without invoking the validator
FAILED=0
FAILED_BLOCKS=0
FAILED_CONTAINERS=0
PASSED=34
```
