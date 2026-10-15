# AC-14 Double Import ([P6-T5])

Timestamp: 2026-10-12T04-08
Command: rg -n "OrchestratorState\.psm1'\)" .claude/hooks/validate-orchestrator-output.ps1
EXIT_CODE: 0
Output Summary: exactly one match line (62), which contains -Global (baseline MATCHES-AC-14: 2, lines 51 and 59).

Match lines:
62:try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorState.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'OrchestratorState.psm1' -ErrorRecord $_ }
