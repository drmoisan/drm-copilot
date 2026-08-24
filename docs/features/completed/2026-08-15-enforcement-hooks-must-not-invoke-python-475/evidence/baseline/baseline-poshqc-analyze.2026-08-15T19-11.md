# Baseline — PowerShell Lint (PoshQC / PSScriptAnalyzer) — Issue #475

Timestamp: 2026-08-15T19-11

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-afc9f4fd25ec235a5` (repo settings at `scripts/powershell/PoshQC/settings/`, default scan set from `config/poshqc-scan.json`)

EXIT_CODE: 0

Output Summary: PoshQC analyze completed successfully (`"ok": true`). Finding count: 0.

Basis for the finding count: `Invoke-PoshQCAnalyze` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:181-183` throws `"PSScriptAnalyzer reported $($results.Count) issue(s)."` whenever `$results.Count -gt 0`. A successful (`ok: true`, non-throwing) run therefore establishes that PSScriptAnalyzer reported zero issues across the scanned set at every severity (Error, Warning, Information) under the repo settings. This is the baseline that every post-change analyze run must match.
