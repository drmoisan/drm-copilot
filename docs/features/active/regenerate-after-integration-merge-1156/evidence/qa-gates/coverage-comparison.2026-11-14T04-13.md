# Coverage and Size Comparison, QA loop re-run — [P6-T7]

Timestamp: 2026-11-14T04-13
Command: figures read from the Phase 0 baselines (evidence/baseline/pester-parallel.2026-11-10T04-00.md, pytest-parallel.2026-11-10T03-53.md, jest.2026-11-10T03-53.md) and the re-run final gates (evidence/qa-gates/pester-final.2026-11-14T04-07.md, pytest-final.2026-11-14T04-11.md, jest-final.2026-11-14T04-12.md); sizes from pwsh SCRATCH/issue-1156-sizes.ps1 (Get-FileSizeLogicalLineCount and Test-FileSizeCoveredPath from .claude/lib/file-size-policy/FileSizePolicy.psm1 over the A/M files of git diff --name-status --no-renames between the merge base of origin/main and HEAD, which after the merge of origin/main is the tip of #1174; physical lines by @(Get-Content -LiteralPath <file>).Count and the same count of git show <merge base>:<file>)
EXIT_CODE: 0
Output Summary: outcome PASS. No new failing test in any gate (Pester 0, pytest 0, Jest 0 failures; baselines 0). Every new PowerShell file at or above 90% line coverage (and therefore at or above the 85% threshold); no edited entry file below its baseline; no repo-wide drop (Pester 95.90% vs 95.80%; pytest line 97.13% vs 97.11%, branch 94.42% vs 94.37%; Jest Statements 97.17% vs 97.15%, Branches 93.94% vs 93.87%, Functions 92.17% vs 92.11%, Lines 97.17% vs 97.15%). No covered file above 800 logical lines; the four physical-line files at or below 500. Advisory: `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` and its bundle copy are 711 logical lines, at the 700-line advisory tier (non-blocking Warning; no gate fails).

## PowerShell per-file line coverage

| File | Final line % | Baseline | Result |
|---|---|---|---|
| .claude/lib/regeneration/Invoke-RegenerationPath.ps1 | 91.03 | new file | threshold met |
| .claude/lib/regeneration/RegenerationConfig.psm1 | 98.00 | new file | threshold met |
| .claude/lib/regeneration/RegenerationClassifier.psm1 | 100.00 | new file | threshold met |
| .claude/lib/regeneration/RegenerationDelta.psm1 | 100.00 | new file | threshold met |
| .claude/hooks/enforce-epic-merge-gate-regeneration.ps1 | 100.00 | new file | threshold met |
| .claude/hooks/hook-epic-regeneration.ps1 | 97.80 | new file | threshold met |
| .codex/hooks/enforce-epic-merge-gate-regeneration.ps1 | 97.73 | new file | threshold met |
| .codex/hooks/hook-epic-regeneration.ps1 | 97.80 | new file | threshold met |
| .claude/hooks/enforce-epic-merge-gate.ps1 | 98.63 | 98.63 | not below |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 99.44 | 99.43 | not below |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 97.73 | 97.66 | not below |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.01 | 97.96 | not below |

## Logical line counts

Unchanged from `coverage-comparison.2026-11-14T03-45.md` except the two test files the [P6-T8] fix edited: `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1` 585 (was 531) and `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1` 359 (was 300). Largest covered files: `Invoke-RegenerationPath.ps1` 711 (and bundle copy), `RegenerationResultScenario.ps1` 625, `Invoke-RegenerationPath.Tests.ps1` 585. Files above 800: 0. `RegenerationResultTable.psd1` is outside the allowlist. `.claude/hooks/enforce-epic-merge-gate-review.ps1` and `.claude/hooks/hook-epic-fan-in.ps1` are absent from the diff.

## Physical line counts with net delta against the merge base

| File | Merge base | Final | Delta |
|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 | 500 | 496 | -4 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 | 500 | 496 | -4 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 462 | 468 | +6 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 462 | 468 | +6 |
