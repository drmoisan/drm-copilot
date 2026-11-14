# Final QC - Static PowerShell (P3-T1)

Timestamp: 2026-11-14T21-05
Command: sh SCRATCH/issue-1187-final-static.sh (pwsh -NoProfile -File SCRATCH/issue-1187-final-static.ps1 over the 11 changed and new .ps1 files)
EXIT_CODE: 0
Output Summary: format rewrote 0 of 11 files, PSScriptAnalyzer reported 0 findings, Invoke-PoshQCLeakScan reported 0 failures; one clean pass, no restart.

Files (11): .claude/hooks/invoke-pretooluse-dispatch.ps1; .codex/hooks/invoke-pretooluse-dispatch.ps1; extensions/drm-copilot/resources/claude-customizations/.claude/hooks/invoke-pretooluse-dispatch.ps1; extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/invoke-pretooluse-dispatch.ps1; tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1; tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1; tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1; tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1; tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1; tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1; tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1.

Step 1 - format
- Command: per file, SHA-256 before; Invoke-Formatter -ScriptDefinition <LF-normalized content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; the file is written only when the formatted text differs; SHA-256 after.
- EXIT_CODE: 0
- Finding count: 0 files rewritten. Success observation: the before and after SHA-256 of every file is equal (for example the Claude dispatcher and its bundle copy 1E51663518D5..., the Codex dispatcher and its bundle copy 2BB17AE770DD...).

Step 2 - lint
- Command: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, per file
- EXIT_CODE: 0
- Finding count: 0.

Step 3 - type check: not applicable for PowerShell.

Step 4 - leak scan
- Command: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <worktree>
- EXIT_CODE: 0
- Finding count: 0 failures (837 files, 78 findings, 76 exempt, 2 allowlisted). The scan warned that the configured folder tests/powershell does not exist under the root and was skipped; that is configuration state of config/poshqc-scan.json, not a change of this item.
