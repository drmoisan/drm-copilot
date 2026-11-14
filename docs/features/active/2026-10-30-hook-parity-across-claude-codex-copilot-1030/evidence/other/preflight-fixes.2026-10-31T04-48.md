# Preflight Fixes (round two, confirming)

Timestamp: 2026-10-31T04-48
Plan: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md
Branch: issue-1030-prep-r2

Both fixes edit task text only. No task was added, removed or reordered.

## Fix 1: [P3-T3]

- Defect class: incomplete anchor; an existing test that is not named (validator-blind class).
- Finding: [P3-T1] records two guarded loads in `$script:FeatureFolderOrderResolutionImportFailure`: `feature-folder-resolution.ps1` and the child 2 resolver module. `Get-HookScopedImportFailureHandler` (`tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`) reports one handler per guarded leaf. `Get-HookExemptionFinding` reports `UNLISTED-HANDLER` for any leaf that no Handler row lists. `tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1` runs that check over `.codex/hooks` and the bundle mirror. The task text said only "an `H1` `codex` row", and the existing Claude H1 row lists only `feature-folder-resolution.ps1`, so a row copied from it would fail the Guard suite. The task did not name the Guard suite.
- Change: the task now states the row's variable, consumer and deny-path file, deny condition and deny code, and a leaf list of `feature-folder-resolution.ps1` and `DevelopmentDocsRoot.psm1`. It names `hook-import-failure-exemptions.Guard.Tests.ps1` as unchanged in code, notes that `hook-dependency-failure.Codex.Tests.ps1` excludes listed leaves from B1, and adds the Guard suite to the acceptance list. The file set and the design are unchanged. The Guard suite already ran in the [P6-T9] single-process run.

## Fix 2: [P2-T9]

- Defect class: ambiguous task literal whose clarification keeps the assertion.
- Finding: the Claude `validate-required-artifact-output.ps1` missing-argument path exits 0 with empty stdout when `StopHookActive` is set. The [P2-T12] row `uses one SubagentStop continuation per validator and stops repeated continuation loops` runs each validator without arguments and expects stdout `continue` false on the second run. The [P2-T4] contract ("every block") already covers this case, but the task text did not say so explicitly.
- Change: the task now states that the missing-argument block also goes through `Exit-CodexSubagentStopDecision`.
