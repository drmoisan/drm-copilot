# Baseline File-Size Ledger and Pre-Change Control Counts

Timestamp: 2026-09-17T10-29

Command: run from the worktree root through `sh runps.sh p0t3.ps1` (a scratchpad POSIX wrapper that does `cd <worktree root>` and then `pwsh -NoProfile -File <script>`; this wrapper is the host's equivalent of the PowerShell tool). The script executed:
- `(Get-Content -LiteralPath '<path>').Count` for each of the six paths below
- `Select-String -SimpleMatch -Pattern 'return $candidates[0]' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'`
- `Select-String -SimpleMatch -Pattern 'uses the earliest candidate' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1'`
- `Select-String -SimpleMatch -Pattern 'falls back to orchestrator-state.json' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1'`

EXIT_CODE: 0

Output Summary:
- 448 `.claude/hooks/enforce-prd-feature-before-planner.ps1` — comparison against the research record figure of 448: MATCHES
- 448 `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
- 431 `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
- 419 `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`
- 302 `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- 302 `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
- Control 1 (`return $candidates[0]` in the hook): 2 matches, at lines 290 and 307 — used by [P4-T8]
- Control 2 (`uses the earliest candidate` in the FolderResolution suite): 2 matches, at lines 97 and 105 — used by [P4-T15]
- Control 3 (`falls back to orchestrator-state.json` in the Tests suite): 1 match, at line 107 — used by [P4-T13]

Citation drift note: [P4-T20] states that both `pester.runsettings.psd1` copies are 293 lines; they measure 302 in this tree (F1, merged as PR #683, added coverage entries). The hook itself matches the plan, so hook line citations stand. Runsettings line citations (the parent entry cited at line 237) are re-derived before [P2-T6] and [P2-T8] run.
