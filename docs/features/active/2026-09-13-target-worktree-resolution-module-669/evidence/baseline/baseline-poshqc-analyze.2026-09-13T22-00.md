# Baseline — PoshQC Analyze Stage

Timestamp: 2026-09-17T07:51:23-04:00
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c scan_folders=[".claude/lib", "tests/scripts/claude-lib", "scripts/powershell/PoshQC/settings", "extensions/drm-copilot/resources/claude-customizations/.claude/lib", "extensions/drm-copilot/resources/powershell/PoshQC/settings"] ; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; try { Invoke-PoshQCAnalyze -Root (Get-Location).Path -ScanFolders @('.claude/lib','tests/scripts/claude-lib','scripts/powershell/PoshQC/settings','extensions/drm-copilot/resources/claude-customizations/.claude/lib','extensions/drm-copilot/resources/powershell/PoshQC/settings') } catch { $_ | Out-String }
EXIT_CODE: 0
Output Summary: MCP gate ok=true. Self-hosted analyzer printed "PSScriptAnalyzer passed: no findings under ..." (the zero-branch literal at PoshQC.Analyzer.psm1:185). Baseline finding set: none.

## MCP result object (verbatim)

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c","summary":"Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c' with 5 selected scan folder(s)."}
```

## Self-hosted stdout (verbatim; process exit code 0)

```text
PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3a183dccbc73c30c
```

## Baseline finding set

none
