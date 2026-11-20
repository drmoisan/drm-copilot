# PoshQC Test + Coverage (Final) (Issue #214)

Timestamp: 2026-06-19T21-18
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = repo root); per-file coverage
produced by Invoke-Pester against the in-repo coverage scope (see note below).
EXIT_CODE: 0
Output Summary:
- Tests passed: 677 (testsuites tests=686, failures=0, errors=0, disabled=9)
- Tests failed: 0
- Errors: 0
- Skipped/disabled: 9 (pre-existing disabled tests; unchanged from baseline)
- Line coverage (extended scope, overall): 94.85% (JaCoCo report-level LINE covered=552,
  missed=30, total=582 -> 552/582 = 94.85%)
- Instruction coverage (closest branch-coverage proxy; Pester emits no BRANCH counter):
  covered=784, missed=52, total=836 -> 93.78%
- Branch coverage: not emitted by the Pester coverage engine in this repository (the JaCoCo
  report contains INSTRUCTION/LINE/METHOD/CLASS counters only).

Per-file line coverage for the four changed/new scripts (all >= 85%):
- scripts/powershell/Publish-DrmCopilotExtension.ps1: 93.97% (covered=109, missed=7, total=116)
- scripts/dev-tools/Invoke-FullRelease.ps1: 91.67% (covered=66, missed=6, total=72)
- scripts/dev-tools/Invoke-MarketplacePublish.ps1: 90.32% (covered=56, missed=6, total=62)
- scripts/dev-tools/Invoke-ReleaseTagPush.ps1: 95.83% (covered=46, missed=2, total=48)

Coverage scope note (load-bearing): The repository Pester coverage configuration at
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (and its bundled mirror at
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1) was
extended in this remediation to add the four scripts changed/added in this feature to
CodeCoverage.Path (the five .claude/hooks/*.ps1 entries are retained; the addition is
additive). The four scripts are therefore now in the measured coverage denominator and
produce real per-file LINE counters.

The live MCP test runner in this session reads an installed extension copy of the runsettings
located outside the repository (~/.vscode*/extensions/...drm-copilot.../resources/powershell/
PoshQC/settings/pester.runsettings.psd1), which is regenerated only on extension build/install.
The two in-repo runsettings sources are updated, so a subsequent extension build produces these
per-file figures directly from the MCP tool. The numeric per-file values above were produced
deterministically by running the full PowerShell suite (tests/powershell + tests/scripts) with
the extended in-repo coverage scope; the resulting JaCoCo report is recorded at
docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/coverage-214-perfile-jacoco.2026-06-19T21-18.xml.

Source artifacts:
- artifacts/pester/pester-junit.xml (test totals)
- docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/coverage-214-perfile-jacoco.2026-06-19T21-18.xml (JaCoCo per-file coverage counters)
- scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (coverage scope; module-relative source)
- extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 (coverage scope; bundled source)
