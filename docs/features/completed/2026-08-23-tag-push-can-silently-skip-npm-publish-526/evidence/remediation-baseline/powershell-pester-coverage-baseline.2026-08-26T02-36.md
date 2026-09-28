# Pester and Coverage Baseline (Remediation Cycle 2026-08-26T02-36)

Timestamp: 2026-08-26T03-19

Stamp substitution: the plan fixes the evidence filename stamp at `2026-08-26T02-36`; the `Timestamp:`
field records the actual execution stamp.

Command: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path'`

EXIT_CODE: 0

Measurement route: the direct self-hosted PoshQC invocation, as the plan's mandatory coverage route
requires. The MCP tool `mcp__drm-copilot__run_poshqc_test` was not used, because it resolves its
runsettings from the installed extension bundle and would emit no coverage row for a newly registered
file. Per-file rows below were parsed by keying on the enclosing `package` element (a directory path)
and selecting the `sourcefile` by name within it.

Output Summary:

Suite result
- Suite passed count: 3638
- Suite failed count: 0
- Skipped: 9
- Inconclusive: 0, NotRun: 0
- Duration: 111.19s
- Pester command-coverage headline: 95.52 percent over 9,771 analyzed commands in 84 files

Repository-wide line coverage
- Covered: 6792
- Missed: 279
- Total measured: 7071
- Percent: 96.0543

Per-file line coverage for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`
- Covered: 83
- Missed: 9
- Total measured: 92
- Percent: 90.2174
- Uncovered line numbers: 57, 58, 74, 75, 92, 485, 496, 497, 498

Adjacent release-tooling files, recorded for context
- `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`: covered 75, missed 2, total 77, 97.4026 percent
  (uncovered 74, 75)
- `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1`: covered 24, missed 3, total 27, 88.8889
  percent (uncovered 163, 164, 165)

Note on the nine uncovered lines of `Invoke-ReleaseVerification.ps1`: lines 57, 58, 74, 75, and 92 are
the `Invoke-GhExe`, `Invoke-NpmExe`, and `Invoke-Sleep` wrapper-seam bodies, and lines 485 and 496
through 498 are the dot-source-guarded entry-point block. Both regions are uncoverable under the
AC21 and AC22 prohibitions on a real external process and a real wall-clock wait. These values are a
historical pre-split record and are never used as the right-hand side of an acceptance condition in
this cycle.
