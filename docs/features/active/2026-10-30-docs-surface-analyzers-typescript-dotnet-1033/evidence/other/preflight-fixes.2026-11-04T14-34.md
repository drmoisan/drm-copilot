# Preflight fixes - issue #1033 remediation cycle 1

Timestamp: 2026-11-04T14-34
Plan: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/remediation-plan.2026-11-04T14-15.md
Signal: PREFLIGHT: ALL CLEAR (single pass over every phase, task, and prose region)

## Fixes made in place (task text and preamble only; no task added, removed, or reordered)

1. `## Execution Context`, `HEAD` definition | stale state definition | The delegation commits and pushes at the end of every phase, so "`HEAD` means the branch head at the start of this cycle until [P5-T9] commits" no longer holds. Added `CYCLE_HEAD` (cycle-start head, recorded by [P0-T2]) and stated that `HEAD` in the comparison tasks [P1-T1], [P1-T2], [P2-T5], [P5-T8] means `CYCLE_HEAD`, and the current head in [P5-T6] and [P5-T9]. The asserted comparisons are unchanged.
2. [P0-T2] | stale state observation | `post-integration-merge.2026-11-04T14-05.md` was committed with the review artifacts before this cycle, so it cannot appear as untracked. The acceptance now records `CYCLE_HEAD` and asserts the file is tracked (present in the `MERGE_BASE` name listing, absent from porcelain). Intent (the post-merge evidence is committed on the branch) is unchanged.
3. [P2-T4] | stale heading anchor | `### DocsScannerCommon.psm1 (pure)` corrected to the spec heading spelling ``### `DocsScannerCommon.psm1` (pure)`` (backticks around the module name).
4. [P5-T9] | stale state observation | "Commit every change of this cycle, including the post-merge evidence file" and "shows the post-merge evidence file in the new commit" corrected to "commit every remaining change" (phase commits) and "shows the post-merge evidence file" in `MERGE_BASE..HEAD`, since the file is already committed. The clean-porcelain assertion is unchanged.

## Planner preflight notes checked

- [P2-T4] heading anchor: fixed (item 3).
- [P3-T2] analyzer claim: verified with a direct `Invoke-ScriptAnalyzer -ScriptDefinition` run (repository settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`) over a module-scope `[System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)` construction: 0 findings. No suppression is needed.
- [P3-T1] expect-fail claim: verified with a SCRATCH probe on the unmodified module. The fixture yields `GET /a | GET /c | GET /lower | GET /ok | POST /b | POST /upper` with 0 diagnostics, so the new test fails before [P3-T2] as the plan states.

## Validator

- `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>` (branch-current): plan validation passed, exit 0 before the fixes and exit 0 after the fixes.
