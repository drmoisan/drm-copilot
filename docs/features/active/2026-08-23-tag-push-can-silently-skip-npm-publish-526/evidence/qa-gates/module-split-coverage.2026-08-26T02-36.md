# Module-Split Coverage Measurement (Remediation Cycle 2026-08-26T02-36)

Timestamp: 2026-08-26T03-19

Stamp substitution: the plan fixes the evidence filename stamp at `2026-08-26T02-36`; the `Timestamp:`
field records the actual execution stamp.

Command: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path'`

EXIT_CODE: 0

CoverageFloorBranch: NO_ACTION

Measurement route: the direct self-hosted PoshQC invocation, per the plan's mandatory coverage route.
The MCP test tool was not used. Per-file rows were parsed by keying on the enclosing `package` element
(the full directory path) and selecting the `sourcefile` by name within it.

Output Summary:

Suite result
- Passed: 3641
- Failed: 0
- Skipped: 9
- Pester command-coverage headline: 95.52 percent over 9,773 analyzed commands in 85 files (the file
  count rose by one because the new helpers module is now registered in the coverage allow-list)

Repository-wide line coverage
- Covered: 6793, missed: 279, total measured: 7072, percent: 96.0549

Per-file line coverage, `scripts/dev-tools/Invoke-ReleaseVerification.ps1`
- Covered: 56
- Missed: 9
- Total measured: 65
- Percent: 86.1538
- Uncovered line numbers: 64, 65, 81, 82, 99, 359, 370, 371, 372

Per-file line coverage, `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`
- Covered: 28
- Missed: 0
- Total measured: 28
- Percent: 100

Branch decision. The measured percent for `scripts/dev-tools/Invoke-ReleaseVerification.ps1` is
86.1538, which is at or above the absolute constant 85.0, so the recorded branch is `NO_ACTION`. The
alternative branch `RELOCATE_GET_CODEXPINNEDMCPVERSION` is not taken and no file is changed by P1-T9.

Uncovered-line classification for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`. The set is
unchanged in membership from the pre-split file; only the line numbers moved, because the extraction
removed source above them.

| Line | Text | Region |
|---|---|---|
| 64 | `$output = & gh @GhArgs 2>&1` | `Invoke-GhExe` seam body |
| 65 | `return @{ Output = @($output); ExitCode = $LASTEXITCODE }` | `Invoke-GhExe` seam body |
| 81 | `$output = & npm @NpmArgs 2>&1` | `Invoke-NpmExe` seam body |
| 82 | `return @{ Output = @($output); ExitCode = $LASTEXITCODE }` | `Invoke-NpmExe` seam body |
| 99 | `Start-Sleep -Seconds $Seconds` | `Invoke-Sleep` seam body |
| 359 | `$verification = Invoke-TagPublishVerification \`` | entry-point block |
| 370 | `Write-Output "State: ..."` | entry-point block |
| 371 | `Write-Output "Instruction: ..."` | entry-point block |
| 372 | `exit $verification.ExitCode` | entry-point block |

The count of uncovered lines falling outside the `Invoke-GhExe`, `Invoke-NpmExe`, `Invoke-Sleep`, and
entry-point regions is 0. Every one of the nine is uncoverable under AC21 and AC22, which prohibit a
real external process and a real wall-clock wait in tests.

Note on comparison discipline: the figures above are post-split and are compared only against the
absolute constant 85.0 and against a missed-line count of exactly 0 for the helpers file. No pre-split
figure appears as the right-hand side of any condition in this artifact.
