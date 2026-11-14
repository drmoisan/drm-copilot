# PowerShell static baseline — main-sync cycle 1 ([P0-T2])

Timestamp: 2026-11-14T07-08
Command: sh SCRATCH/issue-1159-taskcheck.sh <13 files> "" -- per file: Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file text (check mode, writes nothing), then Invoke-ScriptAnalyzer with the same settings
EXIT_CODE: 0
Output Summary: 13 files (the .ps1/.psm1 paths of the [P0-T1] list that are registered hooks, helpers a registered hook dot-sources, or modules such a file imports). Format step: exit 0, 0 files needing format, no file rewritten (git status --porcelain shows no tracked change). Analyzer step: exit 0, 0 findings. There is no pre-existing drift from origin/main in this set.

| Step | Command | Exit code | Finding count |
|---|---|---|---|
| Format (check mode) | Invoke-Formatter with pssa.settings.psd1, output compared with file text | 0 | 0 files needing format |
| Analyze | Invoke-ScriptAnalyzer with pssa.settings.psd1 | 0 | 0 |
| Type check | not applicable to PowerShell | n/a | n/a |

## File set
| File | Role |
|---|---|
| .claude/hooks/enforce-docs-complete-gate.ps1 | registered hook (Claude, Bash) |
| .claude/hooks/enforce-model-routing-receipt.ps1 | registered hook (Claude, Agent) |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | registered hook (Claude) |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | registered hook (Codex) |
| .claude/hooks/enforce-model-routing-receipt-docs.ps1 | helper dot-sourced by enforce-model-routing-receipt.ps1 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1 | helper dot-sourced by the Claude preimplementation gate |
| .codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1 | helper dot-sourced by the Codex preimplementation gate |
| .claude/hooks/hook-docs-estate-context.ps1 | helper dot-sourced by the two Claude -docs helpers |
| .codex/hooks/hook-docs-estate-context.ps1 | helper dot-sourced by the Codex -docs helper |
| .claude/hooks/hook-docs-only-diff.ps1 | helper dot-sourced by enforce-docs-complete-gate.ps1 and enforce-epic-merge-gate.ps1 |
| .codex/hooks/hook-docs-only-diff.ps1 | helper dot-sourced by the Codex enforce-epic-merge-gate.ps1 |
| .claude/lib/docs/DocsCompleteGate.psm1 | module imported by enforce-docs-complete-gate.ps1 |
| .claude/lib/docs/DocsReceiptRevision.psm1 | module imported by enforce-model-routing-receipt-docs.ps1 and nested by DocsCompleteGate.psm1 |

Not in the set: DocsLedgerCommands.psm1, DocsProfileCommands.psm1, DocsValidateCommands.psm1 and Invoke-DocsCommand.ps1. No registered hook or dot-sourced helper imports them. They are reached by the docs MCP tools only.
