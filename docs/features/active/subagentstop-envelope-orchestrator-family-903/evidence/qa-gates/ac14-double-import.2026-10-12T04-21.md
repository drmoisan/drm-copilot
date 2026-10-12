# AC-14 Double Import, Static Re-run ([P7-T8] re-run of [P6-T5])

Timestamp: 2026-10-12T04-21
Command: rg -n "OrchestratorState\.psm1'\)" .claude/hooks/validate-orchestrator-output.ps1
EXIT_CODE: 0
Output Summary: exactly one match line (62), which contains -Global.

62:try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorState.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'OrchestratorState.psm1' -ErrorRecord $_ }
