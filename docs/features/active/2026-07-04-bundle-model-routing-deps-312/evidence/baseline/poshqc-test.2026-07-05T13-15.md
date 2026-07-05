# PowerShell Test + Coverage Baseline — Issue #312

Timestamp: 2026-07-05T13-15
Command: mcp__drm-copilot__run_poshqc_test (Pester 5.x, settings scripts/powershell/PoshQC/settings/pester.runsettings.psd1, coverage enabled)
EXIT_CODE: 0

Output Summary:
- Tests: 988 total, 0 failures, 0 errors, 9 skipped/disabled (from artifacts/pester/pester-junit.xml testsuites: tests="988" failures="0" errors="0" disabled="9").
- Line coverage (report aggregate, JaCoCo LINE counter): covered=999, missed=76, total=1075 => 92.93% line coverage.
- Branch coverage: the Pester CoverageGutters/JaCoCo export emits LINE / INSTRUCTION / METHOD / CLASS counters only; it does not emit a separate BRANCH counter. Branch coverage is therefore not separately reported by the PoshQC pipeline. Line coverage is the authoritative Pester coverage metric here (92.93% >= 85%).
- Coverage scope: measured over the explicit CodeCoverage.Path allowlist in pester.runsettings.psd1 (15 files). The new module .claude/lib/model-routing/ModelRouting.psm1 does not yet exist and is not yet in the allowlist.

Note: The new ModelRouting module is added and measured in Phase 3/6; per the established convention in
pester.runsettings.psd1 (each issue appends its new production files to CodeCoverage.Path), the module is
added to the coverage allowlist so it is not excluded from coverage measurement.
