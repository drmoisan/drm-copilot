# Coverage XML Post-Change Check (Issue #357, Remediation Cycle 1)

Timestamp: 2026-07-17T15-06

Command: `grep -n 'sourcefilename="validate-planner-output' artifacts/pester/powershell-coverage.xml`

EXIT_CODE: 1 (grep no-match exit code)

Output Summary: Direct inspection of the canonical `artifacts/pester/powershell-coverage.xml` (JaCoCo/CoverageGutters format) after the P2-T3 MCP test run confirms **zero** `<class>`/`<sourcefile>` entries reference `validate-planner-output.ps1`. This does not satisfy this task's expected outcome (a `<class>`/`<sourcefile>` entry with a `line-rate`/`LINE` counter).

Cause: as documented in `evidence/qa-gates/poshqc-test-remediation1-final.md`, the `mcp__drm-copilot__run_poshqc_test` tool sources its Pester settings from the bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, not from this cycle's budgeted `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Editing the bundled copy is outside this cycle's declared change budget ("any other file outside this budget" is explicitly prohibited), so it was not edited. Consequently the P1-T1 allowlist addition does not propagate to the canonical coverage artifact within this cycle's authorized scope. This is recorded as an unmet acceptance criterion for this task, not silently passed over.
