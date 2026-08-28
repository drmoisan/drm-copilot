# PowerShell LINT Baseline (P0-T3)

Timestamp: 2026-08-28T11-36

Task: [P0-T3]
Issue: #573
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. MCP tool `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a691c7afb3cd3aa84`, no `scan_folders` restriction.
2. Numeric-breakdown companion (self-hosted module, see Runner artifact note):
   `pwsh -NoProfile -File <scratch>/run-analyze-observe.ps1 -Root C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a691c7afb3cd3aa84 -OutFile <scratch>/analyze-baseline-lines.txt`
   which imports `scripts/powershell/PoshQC/PoshQC.psd1` and calls `Invoke-PoshQCAnalyze` with a capturing `-Logger`.

EXIT_CODE: 0

## Runner artifact note

The MCP wrapper returned `{"ok":true, ... "summary":"Ran bundled PoshQC analyze against '<root>'."}` and surfaces no finding count. `Invoke-PoshQCAnalyze` signals findings by throwing `PSScriptAnalyzer reported N issue(s).` after printing a table, and signals a clean run by logging `PSScriptAnalyzer passed: no findings under <Root>`. The self-hosted module was invoked directly to observe which of the two happened and to obtain the numeric count the plan requires.

## Finding counts by severity

The analyzer is invoked with `-Severity Error, Warning, Information`, so all three severities are in scope of the scan.

| Severity | Baseline count |
| --- | --- |
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| **Total** | **0** |

Observed literal from the clean path:

```
PSScriptAnalyzer passed: no findings under C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a691c7afb3cd3aa84
```

No exception was thrown, so the `results.Count -gt 0` branch that emits `PSScriptAnalyzer reported N issue(s).` was not reached. The whole-run baseline finding count is therefore exactly 0, which is also the count [P5-T2] must not exceed.

Output Summary: Clean lint baseline. Whole-run PSScriptAnalyzer finding count is 0 across all three severities (Error 0, Warning 0, Information 0). The two in-scope hook files and the in-scope Pester suite are within that clean scan. The [P5-T2] acceptance ceiling is therefore 0 whole-run findings and 0 findings for the three in-scope files.
