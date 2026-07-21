# P3-T4 Seam-Injection Fix for Koverage-Copy Tests (Issue #392)

Timestamp: 2026-07-21T18-01
Command:
1. `git diff -- tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`
2. `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 -Output Detailed -PassThru"`
EXIT_CODE: 0 (both)
Output Summary:
- Diff audit: exactly 3 lines changed, each adding `-InvokePester { param($Config) Invoke-Pester -Configuration $Config }` to the `Invoke-PoshQCTest` call under test. No other lines changed; the `BeforeAll` guard and all other blocks are untouched. Every existing assertion (`Should -Invoke Invoke-Pester -Times 1`, `Convert-PoshQCCoverageToRelative` assertions) is preserved.
- The 3 named tests now pass:
  - `Should generate Koverage copy by default when coverage is enabled`
  - `Should skip Koverage copy when DisableKoverageCopy is set`
  - `Should use custom KoverageOutputPath when provided`
- File-scoped Pester result: Passed=26, Failed=0, Skipped=7.
- Rationale: the injected `$InvokePester` is defined in the test's `InModuleScope` context (module-bound), so the existing module-scope `Mock Invoke-Pester` intercepts it exactly as before the v1.1 seam-default fix, bypassing the global-hosting trampoline default for these 3 unit tests only. Production behavior is unchanged (the default trampoline still hosts real runs globally).
