# Coverage and Size Comparison — [P6-T7]

Timestamp: 2026-11-14T03-45
Command: figures read from the Phase 0 baselines (evidence/baseline/pester-parallel.2026-11-10T04-00.md, pytest-parallel.2026-11-10T03-53.md, jest.2026-11-10T03-53.md) and the final gates (evidence/qa-gates/pester-final.2026-11-14T03-37.md, pytest-final.2026-11-14T03-42.md, jest-final.2026-11-14T03-44.md); sizes from pwsh SCRATCH/issue-1156-sizes.ps1 (Get-FileSizeLogicalLineCount and Test-FileSizeCoveredPath from .claude/lib/file-size-policy/FileSizePolicy.psm1 over the A/M files of git diff --name-status --no-renames between the merge base of origin/main and HEAD; physical lines by @(Get-Content -LiteralPath <file>).Count and by the same count of git show <merge base>:<file>)
EXIT_CODE: 0
Output Summary: outcome PASS. No new failing test in any gate (Pester 0 failures, pytest 0 failures, Jest 0 failures; the Phase 0 baselines had 0 failures). Every new PowerShell file at or above 85% line coverage; no edited entry file below its baseline; repo-wide coverage not lower in any gate. No covered file above 800 logical lines; the four physical-line files at or below 500. Advisory: .claude/lib/regeneration/Invoke-RegenerationPath.ps1 and its bundle copy are 711 logical lines, at the 700-line advisory tier (non-blocking Warning; no gate fails).

## Gate totals

| Gate | Phase 0 baseline | Final | Result |
|---|---|---|---|
| Pester (Invoke-PoshQCParallelTest) | 21311 tests, 0 failed; line 95.80% | 23310 tests, 0 failed, 10 skipped; line 95.83% | no new failure, no drop |
| pytest -n auto | 16598 passed, 0 failed; line 97.11%, branch 94.37% | 16729 passed, 0 failed; line 97.13%, branch 94.42% | no new failure, no drop |
| Jest | 5476 passed, 0 failed; Statements 97.15%, Branches 93.87%, Functions 92.11%, Lines 97.15% | 5559 passed, 0 failed; 97.17%, 93.94%, 92.17%, 97.17% | no new failure, no drop |

## PowerShell per-file line coverage

New files (no pre-change run; judged against the 85% threshold):

| File | Final line % | Threshold |
|---|---|---|
| .claude/lib/regeneration/Invoke-RegenerationPath.ps1 | 89.37 | met |
| .claude/lib/regeneration/RegenerationConfig.psm1 | 98.00 | met |
| .claude/lib/regeneration/RegenerationClassifier.psm1 | 100.00 | met |
| .claude/lib/regeneration/RegenerationDelta.psm1 | 100.00 | met |
| .claude/hooks/enforce-epic-merge-gate-regeneration.ps1 | 88.64 | met |
| .claude/hooks/hook-epic-regeneration.ps1 | 97.80 | met |
| .codex/hooks/enforce-epic-merge-gate-regeneration.ps1 | 97.73 | met |
| .codex/hooks/hook-epic-regeneration.ps1 | 97.80 | met |

Edited entry files (compared with the Phase 0 baseline):

| File | Baseline % | Final % | Result |
|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 | 98.63 | 98.63 | not below |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 99.43 | 99.44 | not below |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 97.66 | 97.73 | not below |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 97.96 | 98.01 | not below |

No production Python or TypeScript file changed, so no per-file Python or TypeScript production figure applies.

## Logical line counts (Test-FileSizeCoveredPath allowlist; A = added, M = modified)

| Status | Lines | File |
|---|---|---|
| A | 711 | .claude/lib/regeneration/Invoke-RegenerationPath.ps1 (and bundle copy) |
| A | 422 | .claude/lib/regeneration/RegenerationDelta.psm1 (and bundle copy) |
| A | 296 | .claude/lib/regeneration/RegenerationConfig.psm1 (and bundle copy) |
| A | 161 | .claude/lib/regeneration/RegenerationClassifier.psm1 (and bundle copy) |
| A | 161 | .claude/hooks/enforce-epic-merge-gate-regeneration.ps1 (and bundle copy) |
| A | 272 | .claude/hooks/hook-epic-regeneration.ps1 (and bundle copy) |
| A | 161 | .codex/hooks/enforce-epic-merge-gate-regeneration.ps1 (and bundle copy) |
| A | 272 | .codex/hooks/hook-epic-regeneration.ps1 (and bundle copy) |
| M | 496 | .claude/hooks/enforce-epic-merge-gate.ps1 (and bundle copy) |
| M | 408 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 (and bundle copy) |
| M | 438 | .codex/hooks/enforce-epic-merge-gate.ps1 (and bundle copy) |
| M | 468 | .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 (and bundle copy) |
| M | 502 | extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts |
| A | 300 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1 |
| M | 433 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1 |
| M | 374 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1 |
| A | 470 | tests/scripts/claude-hooks/hook-epic-regeneration.Tests.ps1 |
| A | 134 | tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Merge.Tests.ps1 |
| A | 531 | tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1 |
| A | 103 | tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tip.Tests.ps1 |
| A | 133 | tests/scripts/claude-lib/regeneration/RegenerationClassifier.Tests.ps1 |
| A | 216 | tests/scripts/claude-lib/regeneration/RegenerationConfig.Tests.ps1 |
| A | 270 | tests/scripts/claude-lib/regeneration/RegenerationDelta.Tests.ps1 |
| A | 625 | tests/scripts/claude-lib/regeneration/RegenerationResultScenario.ps1 |
| A | 319 | tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1 |
| A | 527 | tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1 |
| M | 251 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-fan-in.Tests.ps1 |
| M | 495 | tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py |
| M | 465 | tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py |
| M | 482 | tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py |

Files above 800: 0. `tests/scripts/claude-lib/regeneration/RegenerationResultTable.psd1` is outside the allowlist and not counted. `.claude/hooks/enforce-epic-merge-gate-review.ps1` and `.claude/hooks/hook-epic-fan-in.ps1` are absent from the diff (0 matching entries each).

## Physical line counts with net delta against the merge base

| File | Merge base | Final | Delta |
|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 | 500 | 496 | -4 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 | 500 | 496 | -4 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 462 | 468 | +6 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 462 | 468 | +6 |

All four are at or below 500.
