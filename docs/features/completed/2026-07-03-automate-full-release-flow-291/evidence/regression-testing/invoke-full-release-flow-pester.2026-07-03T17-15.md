Timestamp: 2026-07-03T17-40
Issue: #291
Command: pwsh -NoLogo -NoProfile -Command "$coveragePath = 'docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/regression-testing/invoke-full-release-flow-coverage.xml'; $config = New-PesterConfiguration; $config.Run.Path = 'tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1'; $config.Run.PassThru = $true; $config.Output.Verbosity = 'Detailed'; $config.CodeCoverage.Enabled = $true; $config.CodeCoverage.Path = 'scripts/dev-tools/Invoke-FullReleaseFlow.ps1'; $config.CodeCoverage.OutputFormat = 'JaCoCo'; $config.CodeCoverage.OutputPath = $coveragePath; $result = Invoke-Pester -Configuration $config"
EXIT_CODE: 0
Output Summary:
- PASS: Focused Pester run for `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`.
- Pester result: 25 tests discovered; 25 passed; 0 failed; 0 skipped; 0 inconclusive; 0 not run.
- Numeric coverage for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: 92.97% (119/128 analyzed commands covered; 9 missed).
- Transient coverage XML was removed after recording numeric coverage to preserve the Phase 1 owned write scope.
