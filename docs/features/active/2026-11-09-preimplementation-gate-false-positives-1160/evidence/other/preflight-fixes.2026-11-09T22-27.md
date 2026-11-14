# Preflight Fixes (round 2)

Timestamp: 2026-11-09T22-27
Plan: docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/plan.2026-11-09T16-36.md

Each entry is a trivial defect fixed in task text or plan preamble. No task was added, removed, or reordered. The round-1 record `preflight-fixes.2026-11-09T22-14.md` is unchanged.

1. `[P3-T1]` | validator-blind changed-behavior class (an existing asserting test outside the file set) | `Get-EpicStateFileSeamCensus` in `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` counts a function as a read seam when its body reads a file and its defining file holds an `artifacts/` string literal. The bookkeeping sibling would hold such literals (the `artifacts/orchestration/` tree and the checkpoint suffix) next to the configuration reader, so every existing suite that loads either gate would fail AC-4 of `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (issue #737). The task now requires the sibling to take the five #539 trees from `$script:OrchestrationBookkeepingTrees` and the checkpoint suffix from `$script:CheckpointPaths` and to hold no `artifacts/` string literal, and adds that check to the acceptance. File set, design, and assertions are unchanged.
2. `## Existing Tests Asserting Changed Behavior` | missing changed-behavior disposition | The discovery-guard row now states why existing gate suites stay compliant. Added `enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1` (listed in research section 8) with disposition unchanged.
3. `[P5-T3]` | acceptance wording not aligned with its AC source | AC-22 asks for the changed lines of both gate files to stay at or above the Phase 0 baseline. The task recorded per-file figures only. It now also records changed-line coverage against the merge base of `origin/main` and `HEAD`, read from the per-line entries of `artifacts/pester/powershell-coverage.xml`.
4. `[P3-T3]` | test-isolation clarification | The leg-scope Write row now uses a repository-relative `file_path`, so the #1026 cleanup leg does not resolve an absolute path against a real worktree listing.

Validator after the fixes:

- Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/plan.2026-11-09T16-36.md
- EXIT_CODE: 0
- Output Summary: plan validation passed; 19 canonical tasks, 87 physical lines (within the 20-task and 250-line guideline).
