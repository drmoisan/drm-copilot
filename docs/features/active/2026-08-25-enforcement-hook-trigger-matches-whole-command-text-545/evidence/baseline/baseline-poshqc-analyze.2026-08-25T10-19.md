# Phase 0 — Baseline PoshQC analyze (issue #545)

Timestamp: 2026-08-25T10-19

Task: [P0-T6]

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` =
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5`
(no `scan_folders` argument, so the run covers the repository).

EXIT_CODE: 0

Raw tool result:

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5","summary":"Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5'."}
```

## Provenance of the figures below (mandatory disclosure)

`Invoke-PoshQCAnalyze` collects Error, Warning, and Information severities into a single result
set and throws on any non-empty result; it prints no counts on the success path. The run returned
a success status, therefore total = 0, Error = 0, Warning = 0, Information = 0, and the per-file
diagnostic list is empty. These figures are derived from the tool's pass/fail semantics, not read
from tool output.

The semantics were verified against the implementation at
`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` lines 83-185. The analyzer invokes
`Invoke-ScriptAnalyzer -Path $Path -Settings $Settings -Severity Error, Warning, Information`
per file, accumulates every returned record into one `$results` array, and then executes:

```powershell
if ($results.Count -gt 0) {
    $results | Format-Table -AutoSize
    throw "PSScriptAnalyzer reported $($results.Count) issue(s)."
}
& $Logger "PSScriptAnalyzer passed: no findings under $Root"
```

A non-empty result set therefore raises, and the MCP wrapper would not have returned `ok: true`.
There is no success-path count to read.

## Repository-wide total

- Total diagnostic count: **0**
- Error severity: **0**
- Warning severity: **0**
- Information severity: **0**

## Per-file diagnostic list, restricted to the twelve in-scope files that exist at baseline

The four `hook-command-scanner.ps1` locations from [P0-T4] do not exist at baseline and are
excluded from this list.

| # | Path | Diagnostics at baseline |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| 2 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| 5 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | 0 |
| 6 | `.codex/hooks/enforce-promotion-mcp-only.ps1` | 0 |
| 7 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | 0 |
| 8 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | 0 |
| 9 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 0 |
| 10 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 0 |
| 11 | `.claude/hooks/enforce-pr-author-skill.ps1` | 0 |
| 12 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | 0 |

The list is empty in the sense that no file carries a diagnostic. It is recorded per file so that
[P11-T2] has a named per-file comparison set rather than having to assert an absolute
repository-wide zero, which this change could not move.

## Output Summary

Repository-wide analyze passed with a success status. Derived from the tool's throw-on-any-finding
semantics: total diagnostic count 0, comprising 0 Error, 0 Warning, and 0 Information. The per-file
list for the twelve in-scope baseline files carries zero diagnostics on every file. The final
analyze gate in [P11-T2] therefore compares against a repository-wide baseline total of 0 and a
per-changed-file requirement of zero error-severity diagnostics.
