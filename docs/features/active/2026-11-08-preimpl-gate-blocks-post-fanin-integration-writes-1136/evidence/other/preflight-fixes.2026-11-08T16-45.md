# Preflight Fixes (issue #1136, round 2)

Timestamp: 2026-11-08T16-45
Plan: docs/features/active/2026-11-08-preimpl-gate-blocks-post-fanin-integration-writes-1136/plan.2026-11-08T11-00.md

## Round 1 defects re-checked

- [P3-T1] / Design Summary: fixed. The Codex scriptblock now passes `$legPaths` and `$legCommand`, matching `Get-OrchestrationEpicScopeDecision` in `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`; `-FilePath` is `[string[]]` with blank entries ignored.
- [P3-T3]: fixed. Nine Codex allow rows cover every AC-4 case.
- [P2-T2]: fixed. Unit rows cover unresolvable text, unbalanced quotes, the mixed chain, `--message`/`--file`/`--trailer`, an absolute path outside the worktree, and the two-entry path legs.

## Fixes

1. [P2-T1] | validator-blind constraint from an existing test (assertion meaning unchanged) | Added that each copy is at most 500 lines. [P3-T3] adds the file to `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, whose `It 'parse-checks each root and bundled hook and keeps every file within 500 lines'` then applies to the new file. The final Pester gate already enforces this; the task now states it.

## Substantive defects returned (not fixed here)

- [P3-T2] / [P3-T3]: no test fails if the allowance ignores the "readiness failure is exactly `merge-in-progress`" condition (AC-3). `Resolve-EpicScopeCheckpoint` requires `route_id` and `integration_branch` but not `epic_manifest_path`, so a fan-in-complete checkpoint with a blank or out-of-tree `epic_manifest_path` is in epic scope and fails readiness on `epic_manifest_path`. Every planned deny row also fails a fan-in or allowlist conjunct, so it does not discriminate.
