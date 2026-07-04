# Baseline — PoshQC Pester Test Run (Issue #298)

Timestamp: 2026-07-03T21-35

Command: `mcp__drm-copilot__run_poshqc_test` (settings: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, scan_folders: `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`)

EXIT_CODE: 0

Output Summary:
- Test counts (from `artifacts/pester/pester-junit.xml`): 25 passed, 0 failed, 0 errors, 25 total, in `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`.
- Aggregate coverage (from `artifacts/pester/powershell-coverage.xml`, JaCoCo/CoverageGutters format): LINE counter `missed="1073" covered="0"` -> aggregate line coverage = 0.0% (0 / 1073). Aggregate branch coverage is not populated by this coverage exporter for this run: every line element's `mb`/`cb` (missed/covered branch) attribute is uniformly `0`, so no branch-level percentage is reported by the tool for this format.
- Zero-coverage caveat for this scoped run: this Pester invocation was scoped to a single test file (`tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`), per `pester.runsettings.psd1`'s `CodeCoverage.Path` allowlist (which lists `.claude/hooks/*.ps1` and four `scripts/dev-tools`/`scripts/powershell` release scripts, none of which is `Invoke-FullReleaseFlow.ps1`). Because only this one test file's `It` blocks executed, none of the allowlisted files' own dedicated test suites ran in this pass, so every allowlisted file reports 0 covered lines. This 0.0% aggregate is an artifact of the intentional single-file scope of this baseline run, not a real coverage regression against the full suite.
- Allowlist caveat (per plan's stated known pre-existing condition): `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s `CodeCoverage.Path` does not include `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`. Confirmed by grep: the in-scope production file does not appear anywhere in `artifacts/pester/powershell-coverage.xml`. The new test's exercise of `ConvertTo-CommandResult` will pass/fail correctly but will not move a per-file coverage number for `Invoke-FullReleaseFlow.ps1`, because that file is outside the measured set.
