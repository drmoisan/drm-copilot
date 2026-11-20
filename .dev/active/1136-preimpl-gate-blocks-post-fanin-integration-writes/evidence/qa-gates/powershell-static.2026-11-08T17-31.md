# PowerShell Final Static Loop ([P5-T1])

Timestamp: 2026-11-08T17-31
Command: sh SCRATCH/issue-1136-static-final.sh (pwsh 7: Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with file text, check-only; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <worktree root>; @(Get-Content -LiteralPath <file>).Count)
EXIT_CODE: 0
Output Summary:
- Step 1, formatter (Invoke-Formatter check-only): EXIT_CODE 0; drift count 0 over 12 files (four `hook-epic-fan-in.ps1` copies, four `enforce-orchestration-preimplementation-gate-epic-scope.ps1` copies, `enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`, `hook-epic-fan-in.Tests.ps1`, the Codex `enforce-orchestration-preimplementation-gate-epic-fan-in.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`). No file changed, so no restart.
- Step 2, analyzer (Invoke-ScriptAnalyzer with repo settings): EXIT_CODE 0; finding count 0 on each of the 12 files.
- Step 3, type check: not applicable to PowerShell.
- Leak scan: Invoke-PoshQCLeakScan reported "706 files, 73 findings, 71 exempt, 2 allowlisted, 0 failures"; no throw. `config/poshqc-leak-allowlist.json` is unchanged against HEAD and against the merge base of origin/main and HEAD.
- Line counts versus [P0-T2] (powershell-static.2026-11-08T16-52.md):
  - `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 473 (baseline 473, equal)
  - `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: 493 (baseline 493, equal)
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`: 481 (baseline 481, equal)
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 396 (baseline 387; +1 guarded dot-source, +6 scriptblock, +2 description)
  - `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 456 (baseline 447; same +9 composition)
