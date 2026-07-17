# CI-Equivalent Coverage Verification — Issue #357

**Timestamp:** 2026-07-17T16:45:00Z
**Author:** orchestrator (main session)

## Purpose

Both remediation cycles observed that `mcp__drm-copilot__run_poshqc_test` produced a canonical `artifacts/pester/powershell-coverage.xml` with zero entries for `.claude/hooks/validate-planner-output.ps1`, even after cycle 1 correctly added the file to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s `CodeCoverage.Path`, and after cycle 2 additionally synced `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Cycle 2's execution report identified the root cause: `mcp__drm-copilot__run_poshqc_test` is served by the MCP server launched via `.mcp.json`'s `npx -y @danmoisan/drm-copilot-mcp`, which resolves a separately npm-published package cached under the local npx cache — independent of this workspace's source tree. Neither in-repo settings-file copy can reach that tool's actual runtime resolution.

This artifact records a direct, CI-equivalent verification that bypasses the MCP wrapper entirely, to determine whether the actual repository/CI-enforced coverage gate is satisfied.

## Method

`.github/workflows/_poshqc.yml` (the actual CI gate) does not use the MCP server or `npx`. Its "Test PowerShell" step runs:

```powershell
Import-Module "${{ github.workspace }}/scripts/powershell/PoshQC/PoshQC.psm1"
Invoke-PoshQCTest -Root "${{ github.workspace }}"
```

`scripts/powershell/PoshQC/PoshQC.psm1` resolves its Pester settings as `Join-Path $ModuleRoot 'settings/pester.runsettings.psd1'` — i.e., `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, the exact file cycle 1 updated. This is the canonical, CI-enforced settings file; it is unrelated to the MCP server's packaged copy.

**Command run (workspace root, matching CI verbatim):**

```powershell
Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force
Invoke-PoshQCTest -Root (Get-Location).Path
```

## Result

- **Tests:** 1286 passed, 0 failed, 9 skipped, 67.48s.
- **Overall coverage:** 89.02% (2,815 analyzed commands across 28 files).
- **`artifacts/pester/powershell-coverage.xml`** now contains a `<sourcefile name="validate-planner-output.ps1">` entry (previously absent under the MCP-wrapper invocation).
- **`.claude/hooks/validate-planner-output.ps1` line coverage:** 107/114 lines covered = **93.86%**, above the 85% uniform threshold (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`). This matches atomic-executor's independent ad hoc estimate of 94.23% (147/156 commands) from remediation cycle 2.

## Conclusion

The actual repository/CI-enforced coverage gate for `.claude/hooks/validate-planner-output.ps1` is satisfied by the state produced at the end of remediation cycle 2 (93.86% line coverage via the exact invocation CI uses). The "canonical artifact empty" symptom both remediation cycles chased was caused by the interactive `mcp__drm-copilot__run_poshqc_test` MCP tool resolving a stale, separately-published npm package (`@danmoisan/drm-copilot-mcp`) rather than this workspace's source — a pre-existing MCP-tooling staleness issue, unrelated to and not blocking on issue #357's actual code/test correctness. This MCP-tool/workspace drift is a distinct, separate defect and is recommended as a new potential-bug entry rather than further remediation under issue #357.
