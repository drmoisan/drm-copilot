# Preflight Fixes — regenerate-after-integration-merge (Issue #1156), round 3 (confirming preflight)

Timestamp: 2026-11-09T23-08
Plan: docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned separately; the fixes below are task-text edits only, with no task added, removed, or reordered, and no assertion changed)
Prior records: docs/features/active/regenerate-after-integration-merge-1156/evidence/other/preflight-fixes.2026-11-09T22-22.md and docs/features/active/regenerate-after-integration-merge-1156/evidence/other/preflight-fixes.2026-11-09T22-41.md (not edited)

## Fixes

1. `[P3-T2]` | incomplete existing-test dispositions (validator-blind class) | Added `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1`, disposition unchanged. The suite scans every dot-sourced helper in the closure of each registered hook on the repository and mirror roots for success- or warning-stream writes, so the new dot-sourced `enforce-epic-merge-gate-regeneration.ps1` falls inside its scan. The task text now states the existing constraint (functions only, decision object returned, no stdout or warning-stream write; mirror findings equal repository findings after [P5-T1]). No assertion changes.
2. `[P3-T4]` | incomplete existing-test dispositions (validator-blind class) | Added the same suite for the new dot-sourced `hook-epic-regeneration.ps1`, disposition unchanged, with the same existing constraint stated. No assertion changes.

## Verified without change

- `[P3-T2]` line budget: `.claude/hooks/enforce-epic-merge-gate.ps1` and its bundle copy are 500 physical lines. The three named blocks (`ToolInputRaw` acquisition `if` in `Invoke-EpicMergeGateEntryPoint`, the dot-source early return, the `$entryPointResult.Count -gt 1` tail `if`) are three lines each, so the collapse removes 6 lines and the edit adds 2: net minus 4, 496 lines.
- `scripts/powershell/PoshQC/settings/pssa.settings.psd1` enables no brace-placement rule (`PSPlaceOpenBrace`, `PSPlaceCloseBrace`), and the same file already carries one-line `if` blocks, so Invoke-Formatter does not re-expand the collapsed blocks.
- `tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1` reads the dot-source early return and the tail through the AST (`Clauses[0].Item1.Extent.Text` and statement order), which the collapse does not change. No test pins the multi-line text of the three blocks.
- `session-root-reads-850.Constraints.Tests.ps1` bounds the `.claude` entry file and a fixed suite list; no suite this plan edits is on that list. The Codex entry file (436 to 438) is bounded only by the 800-line hard limit in `codex-epic-runtime-contracts.Tests.ps1`.
- `[P1-T3]`, `[P4-T1]`, `[P4-T6]`: the `fell_back` event, the `config_invalid` errors under `artifact_errors`, and the evidence file name each have an implementing sentence and a pinning assertion (`Get-RegenerationEvidencePath` exact-path and throw cases; section-scoped tokens `fell_back`, `artifact_errors`, `evidence/qa-gates/regeneration-delta.`).
