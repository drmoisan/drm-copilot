# PowerShell Coverage Delta — Issue #312

Timestamp: 2026-07-05T13-15
Command: compare evidence/baseline/poshqc-test.2026-07-05T13-15.md vs evidence/qa-gates/poshqc-test.2026-07-05T13-15.md; authoritative new-module coverage via repo pester.runsettings.psd1 (New-PesterConfiguration -Hashtable).
EXIT_CODE: 0

Output Summary:
- Baseline aggregate line coverage: 92.93% (covered=999, missed=76, total=1075). New module did not yet exist.
- Post-change aggregate line coverage: 92.93% (covered=999, missed=76, total=1075). Unchanged, because the MCP tool's bundled coverage allowlist does not list the new module.
- New / changed-code coverage (the new module .claude/lib/model-routing/ModelRouting.psm1): line/command = 100.0% (45 analyzed, 45 executed, 0 missed). Branch: the JaCoCo/CoverageGutters export emits no separate BRANCH counter; 100% command coverage exercises every branch of both pure functions (empty vs non-empty floor input; preferred-overlay match vs base-table; disabled-clamp vs no-clamp; out-of-table-band throw). This satisfies >= 85% line and >= 75% branch.
- Regression check: no regression on changed lines. The only changed production code is the new module, which is at 100%. The pre-existing aggregate figure is unchanged.
- Repo-side coverage measurement: the new module is added to scripts/powershell/PoshQC/settings/pester.runsettings.psd1 CodeCoverage.Path so the repo/CI Pester run measures it (per the coverage-exclusion policy: no production file excluded).
