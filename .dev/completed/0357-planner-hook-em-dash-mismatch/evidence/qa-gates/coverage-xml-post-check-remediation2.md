# Coverage XML Post-Check — Remediation Cycle 2

**Timestamp:** 2026-07-17T16-28
**Command:** `grep -n "sourcefilename=\"validate-planner-output" artifacts/pester/powershell-coverage.xml`
**EXIT_CODE:** 1
**Output Summary:** Zero matches. No `<class>`/`<sourcefile>` entry exists for `validate-planner-output.ps1` in the canonical `artifacts/pester/powershell-coverage.xml` after this cycle's settings-file edit and after Phase 1's 14 additional covering tests. This does NOT match the task's expected outcome (a non-empty match with a numeric `line-rate`/`LINE` counter). Per `evidence/qa-gates/poshqc-test-remediation2-final.md`, the cause is that `mcp__drm-copilot__run_poshqc_test` is served by a separately npm-published MCP server package (`@danmoisan/drm-copilot-mcp`, resolved via `npx` per `.mcp.json`), whose cached `resources/powershell/PoshQC/settings/pester.runsettings.psd1` copy is entirely outside this workspace and was not, and cannot be, modified by this cycle's edit to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. This is a blocking condition outside the authorized change budget for this cycle.
