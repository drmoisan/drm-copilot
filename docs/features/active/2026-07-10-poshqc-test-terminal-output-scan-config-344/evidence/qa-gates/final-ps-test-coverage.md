# QA Gate — PowerShell Pester Test + Coverage

- Timestamp: 2026-07-10T18-30
- Command: MCP tool `mcp__drm-copilot__run_poshqc_test` (default config-driven scan set)
- EXIT_CODE: 0

## Output Summary

- Pester result (`artifacts/pester/pester-junit.xml`): tests=1103, failures=0, errors=0, disabled=9. All executed tests passed.
- New/changed tests present and passing: 12 `Get-PoshQCScanConfigFolder` scenarios (PoshQC.ScanConfig.Tests.ps1) and 4 `Invoke-PoshQCTest scan-config precedence` scenarios (PoshQC.ScanFolders.Tests.ps1). The 5 Comprehensive `Invoke-PoshQCTest` cases were updated to inject the new `-ResolveScanConfig` seam and pass.
- Coverage report (`artifacts/pester/powershell-coverage.xml`, report-level LINE): covered=1039, missed=73, total=1112 -> 93.44% line coverage on the measured file set. This exceeds the 85% line threshold.

## Coverage Note — PoshQC Module Files (structural constraint)

`PoshQC.ScanConfig.psm1` and `PoshQC.Testing.psm1` cannot be line-instrumented by Pester breakpoint coverage: `scripts/powershell/PoshQC/PoshQC.psm1` loads its sub-modules via `. ([scriptblock]::Create((Get-Content <file> -Raw)))`, which executes a fileless scriptblock with no on-disk path association, so coverage breakpoints set on the `.psm1` files are never hit. Adding these files to `CodeCoverage.Path` produces zero instrumented lines (verified empirically: the report total is unchanged when they are added). This is a pre-existing constraint shared by every PoshQC `.psm1` module (none has ever been in the coverage Path); it is not introduced by this feature.

Behavioral (path) coverage of the new/changed code is provided instead by the dedicated deterministic Pester suites:
- `Get-PoshQCScanConfigFolder`: absent file, blank content, absent/empty scanFolders, malformed JSON, wrong version, blank entry, absolute-path entry, `..` segment, skip-missing-with-warning, all-missing error, all-present success (12 It blocks, all passing).
- `Invoke-PoshQCTest` config precedence: explicit `-ScanFolders` bypasses config, config-yielded folders reach run paths, empty config falls back to Run.Path defaults, explicit missing folder still throws (4 It blocks, all passing).

The parity gate additionally byte-locks these modules against their bundled mirrors.
