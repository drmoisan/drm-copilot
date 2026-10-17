# Coverage configuration governing attribution (remediation cycle 1, R1, Phase 1)

Timestamp: 2026-10-16T15-39
Task: [P1-T3]
Command: git grep -n -e "UseBreakpoints" -- scripts/powershell/PoshQC config; then Read config/poshqc-coverage.json:1-10, scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27, scripts/powershell/PoshQC/PoshQC.Testing.psm1:349-364 and :397
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
COVERAGE_ROOTS=.claude/hooks,.claude/lib,.codex/hooks,.codex/scripts,scripts
USE_BREAKPOINTS_SET=false
PESTER_INVOCATIONS=1
COVERAGE_OUTPUT_FORMAT=CoverageGutters

Search output: (empty; no `UseBreakpoints` key is set, so Pester's default coverage mode applies)

Reads:
- `config/poshqc-coverage.json:3-9`: `"roots": [".claude/hooks", ".claude/lib", ".codex/hooks", ".codex/scripts", "scripts"]`.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27`: `CodeCoverage = @{ Enabled = $true; OutputFormat = 'CoverageGutters'; OutputPath = 'artifacts/pester/powershell-coverage.xml'; CoveragePercentTarget = 0 }`, with the comment that no Path list is set and the population is derived from the workspace (issue #527).
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1:349-364`: the coverage population is resolved from the workspace and assigned to `$config.CodeCoverage.Path`; an empty population disables coverage for the invocation.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1:397`: `$pesterResult = & $InvokePester $config` is the single Pester invocation, so every suite of a run shares one coverage session.

No file was edited.
