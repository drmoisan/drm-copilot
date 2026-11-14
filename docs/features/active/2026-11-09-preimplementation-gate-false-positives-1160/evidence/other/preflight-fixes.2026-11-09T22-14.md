# Preflight Fixes

Timestamp: 2026-11-09T22-14
Plan: docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/plan.2026-11-09T16-36.md

Each entry is a trivial defect fixed in task text or plan preamble. No task was added, removed, or reordered.

1. `## Execution Constraints (owner brief, binding)` | validator-blind test-isolation class | Added a bullet stating that `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (issue #737) discovers every new suite under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, so each new suite that loads a gate or hook file uses `Register-EpicStateBaselineMock` in its outermost `BeforeAll` and calls `Invoke-EpicStateInterceptionProbe` inside an `It`. Without it the final Pester gate fails on the guard's AC-4 and AC-6 rows.
2. `## Pre-Mortem` File size bullet | incorrect fact | Replaced "may cross it (no gate fails below 801)" with the fact that `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` pins the Codex gate and its bundle copy at or below 500 lines, and that the Codex gate is within ten lines of that bound before this item.
3. `## Existing Tests Asserting Changed Behavior` | missing changed-behavior disposition | Added `legacy-codex-hook-contracts.Tests.ps1` (500-line bound and bundle byte identity of the Codex gate), `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (research section 8; cleanup-leg allows return before the new leg), and `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (discovers the new suites), each with disposition unchanged.
4. `[P1-T3]` | ambiguous assertion and isolation | Stated the deny-text comparison as byte-equal to the generic final deny text quoted in the spec, with no suffix (the AC-2 wording), and required guarded mocks of `Get-OrchestrationGateBookkeepingConfigText` and `Get-OrchestrationGateStagedIndex` that bind once P3-T1 lands without breaking the P1-T4 run, plus the issue #737 isolation form.
5. `[P3-T1]` | omitted spec rule in task text | Added the spec `#### Data flow and validation changes` rule that a pathless commit with a `$null` root is denied without calling the staged-index reader, so existing suites that inject `-CheckpointRaw` do not reach a real index read.
6. `[P3-T2]` | missing constraint from an existing asserting test | Added the acceptance condition that the Codex gate stays at or below 500 lines after the P2-T2 and P3-T2 edits, as `legacy-codex-hook-contracts.Tests.ps1` requires.
7. `[P3-T3]` | validator-blind test-isolation class | Required the issue #737 isolation form and a mocked `Read-OrchestrationGateCheckpoint` returning a `/synthetic-worktrees/` path for rows that need a root, so no row reads a real worktree listing or checkpoint.
8. `[P5-T2]` | count literal | Replaced "the nine new test files" with "the eight new suites (the corpus file is data only)"; the spec lists nine new test-tree files, one of which is the data-only corpus.

Validators after the fixes:

- Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/plan.2026-11-09T16-36.md
- EXIT_CODE: 0
- Output Summary: plan validation passed; 19 canonical tasks, 87 physical lines (within the 20-task and 250-line guideline).
- MCP `validate_orchestration_artifacts` (artifact_type plan): ok true.
