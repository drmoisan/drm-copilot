# PowerShell static baseline (P0-T1)

Timestamp: 2026-11-14T20-44
Command: pwsh -NoProfile -File SCRATCH/issue-1188-static.ps1 -ListFile SCRATCH/issue-1188-p0-files.txt
EXIT_CODE: 0
Output Summary: format 0 findings (check-only, nothing rewritten), PSScriptAnalyzer 0 findings, leak scan 0 failures.

Scope (policy order read per `.claude/skills/policy-compliance-order/SKILL.md`): the four epic-scope files

- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`

Steps:

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| Format (check-only) | `Invoke-Formatter -ScriptDefinition <CRLF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, compared with the input, no write | 0 | 0 (four `Already formatted:` lines) |
| Lint | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information` | 0 | 0 |
| Leak scan | `Invoke-PoshQCLeakScan -Root <worktree>` (branch-current `scripts/powershell/PoshQC/PoshQC.psd1`) | 0 | 0 failures (836 files, 78 findings, 76 exempt, 2 allowlisted) |
| Type check | not applicable to PowerShell | - | - |

No-change observation: the formatter printed `Already formatted:` for all four files and wrote nothing. No Python, TypeScript, or C# file is in scope.
