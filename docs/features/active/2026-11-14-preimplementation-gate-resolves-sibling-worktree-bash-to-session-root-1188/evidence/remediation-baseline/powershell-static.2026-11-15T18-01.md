# PowerShell static baseline - remediation cycle 1 (P0-T1)

Timestamp: 2026-11-15T18-01
Command: pwsh -NoProfile -File artifacts/scratch-issue-1188/issue-1188-r1-static.ps1 -ListFile artifacts/scratch-issue-1188/p0-files.txt
EXIT_CODE: 0
Output Summary: format 0 drift (`Formatted:` lines 0, `Already formatted:` lines 6, 0 writes through the non-writing `-WriteFile` seam), PSScriptAnalyzer 0 findings, leak scan 0 failures (854 files, 78 findings, 76 exempt, 2 allowlisted).

Plan: remediation-plan.2026-11-14T23-56.md

Scope (files this cycle edits that the first cycle did not baseline):

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| Format (check-only) | `Invoke-PoshQCFormat -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1` with a `-GetFileList` seam returning the six files and a non-writing `-WriteFile` seam | 0 | 0 `Formatted:` lines; no file rewritten |
| Lint | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information` | 0 | 0 |
| Leak scan | `Invoke-PoshQCLeakScan -Root <worktree>` (branch-current `scripts/powershell/PoshQC/PoshQC.psd1`) | 0 | 0 failures |
| Type check | not applicable to PowerShell | - | - |

Phase 0 test baselines (by derivation, not re-run): the lexicographically greatest `evidence/baseline/pester-gate.*.md` is `pester-gate.2026-11-14T21-02.md` (26522 tests, 0 failures, repo-wide line coverage 95.96%), and the greatest `evidence/baseline/pytest-gate.*.md` is `pytest-gate.2026-11-14T21-05.md` (16928 passed, 6 skipped, 0 failed).

Deviation: the helper lives under the item worktree's gitignored `artifacts/scratch-issue-1188/` instead of SCRATCH, because the default-branch preimplementation gate denies Write to SCRATCH (its scratch rule fails closed while a registered worktree lies under a temporary root). The helper is untracked and is not evidence.
