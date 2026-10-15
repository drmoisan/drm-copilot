# PowerShell Analyze (P8-T2)

Timestamp: 2026-09-28T22-17
Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root = repository root, scan_folders = .claude/lib/ci-gate, tests/scripts/claude-lib/ci-gate, scripts/powershell/PoshQC/settings) ; sh SCRATCH/run-ps.sh SCRATCH/pssa-count.ps1 .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary: The MCP analyze call returned without raising (`ok: true`). A9 printed `PSSA-SUMMARY DiagnosticCount=0` for the four files, with repo settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
