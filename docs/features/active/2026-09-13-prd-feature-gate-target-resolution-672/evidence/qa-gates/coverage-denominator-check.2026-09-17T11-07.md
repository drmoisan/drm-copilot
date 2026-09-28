# Coverage Denominator Check for the New Sibling

Timestamp: 2026-09-17T11-07

Command:
1. `mcp__drm-copilot__run_poshqc_test` with `workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40` (returned `ok:false, "Command exited with code 2."`; it carries no coverage value, so the determination is made from the emitted report)
2. `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner-helpers.ps1' -Path 'artifacts/pester/powershell-coverage.xml'`
3. `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner.ps1' -Path 'artifacts/pester/powershell-coverage.xml'` (the control)

Commands 2 and 3 ran from the worktree root through the scratchpad wrapper `sh runps.sh p2t8.ps1`.

EXIT_CODE: 0 for the two searches; 2 for the MCP test invocation.

Provenance of the searched report: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` was modified at 11:02:49 by `[P2-T6]`; `artifacts/pester/powershell-coverage.xml` was written at 11:06:33 and `artifacts/pester/pester-junit.xml` at 11:07:20, both after that edit and both by the MCP invocation above. The searched report therefore post-dates the repository-side settings change.

Output Summary:

- Sibling match count (`enforce-prd-feature-before-planner-helpers.ps1`): **0**
- Control match count (`enforce-prd-feature-before-planner.ps1`): **2** — non-zero, so the search mechanism matches when the token is present and the zero result above is evidence rather than an unmatchable search. The control is listed in the repository-side settings at line 239 (the plan cites 237; F1's merged coverage entries shifted the file from 293 to 302 lines, and the drift is recorded in `evidence/baseline/baseline-file-size-ledger.2026-09-17T10-29.md`).

## MCP-READS-REPO-SETTINGS: NO

The sibling count is zero while the control count is non-zero. The MCP runner is not reading the repository-side runsettings edited by `[P2-T6]`; it resolves its Pester run settings from the installed VS Code extension, which carries pre-change settings for the whole of this feature because `spec.md` lines 732-733 assign the extension rebuild, reinstall, and push-down to the epic's delivery feature and not to this one.

This is a determination and not a gate. Neither outcome blocks progress, and this outcome changes no downstream routing: the plan preamble section `### MCP PoshQC result surface, and the unconditional direct measurement route` already makes the direct route unconditional for every measurement task. `[P2-T10]`, `[P6-T3]`, and `[P6-T5]` therefore run, verbatim and unconditionally:

`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

No placeholder coverage value is recorded anywhere, and the per-file figures required by `spec.md` line 667 are read per file from the coverage report produced by that direct run.
