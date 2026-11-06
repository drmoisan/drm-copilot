# Preflight fixes (issue 1067)

Timestamp: 2026-11-04T03-38
Plan: docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067/plan.2026-11-03T17-43.md

Single-pass preflight under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`. Every fix edits task text or preamble only; no task was added, removed, or reordered.

## Fixes

1. `## Existing Tests That Assert Changed Behavior` (preamble) | stale statement | `tests/powershell/` does not exist in the tree; "holds no files" changed to "does not exist".
2. `## Existing Tests That Assert Changed Behavior`, D4 bullet | incomplete citation | The `Invoke-PoshQCTest` suite list omitted `PoshQC.TestingCommands.Tests.ps1`, `PoshQC.RunSettings.Tests.ps1`, `PoshQC.TestingSeamDefaults.Tests.ps1`, `PoshQC.EntryPoints.Tests.ps1`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, and `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1`, and several of them do not stub `-ResolveScanConfig`. The list was completed and the rationale corrected (stub, explicit `-ScanFolders`, or an absent or workspace-relative configuration; no suite supplies a rooted entry). The disposition (unaffected) is unchanged.
3. [P0-T1] | citation correction | Added `.github/copilot-instructions.md`, item 1 of the `CLAUDE.md` policy reading order, to the read list; the count changes from eight to nine files.
4. [P0-T2] | unsatisfiable literal, meaning kept | The P0-T1 artifact is written before P0-T2 and committed only in P0-T9, so `git status --porcelain` cannot be empty at P0-T2. The condition now requires that porcelain lists only paths under `<FEATURE>/evidence/baseline/`, which keeps the asserted property (no code change before the baseline).
5. [P0-T3] | missing mechanical step in task text | No task wrote `SCRATCH/issue-1067-run-pester.ps1`, which P0-T3 and later tasks run. P0-T3 now writes it to the run-script contract in `## Inputs and Conventions` before running it.
6. [P4-T1] | literal formatting | A raw `\absolute\path` in the JSON fixture text does not parse (probe on PowerShell 7.6.9: `Bad JSON escape sequence: \a`), so the test would hit the malformed-JSON branch. The task now states that the fixture text uses JSON-escaped backslashes; the asserted entry value and expectation are unchanged.
7. [P0-T7] | success-case output | pytest prints no failed count on a clean run. The artifact now records the pytest summary line (passed count, and failed or error count when printed).
8. [P6-T10] | success-case output | "records 0 failed" changed to "records a pytest summary line that carries a passed count and no failed or error count"; the asserted outcome is unchanged.
9. [P6-T14] | unsatisfiable literal, meaning kept | Phase 6 commits nothing before P6-T19, so porcelain cannot be empty at P6-T14 (the three isolation-fix test files and Phase 6 evidence are uncommitted). The condition now requires that porcelain lists only those three test files and paths under `<FEATURE>/evidence/`, which keeps the asserted property (no test run wrote a file into the tree). The ordering phrase "after P6-T7" was removed because P6-T14 already runs after P6-T13.
10. [P6-T18] | policy alignment and scope of count | `acceptance-criteria-tracking` requires check-off when the verifying task passes, as the preamble already states; P6-T18 now confirms the check-offs and checks off only those not yet checked, and the count is scoped to `spec.md` `## Acceptance Criteria` (the spec has other checked boxes under Impact, Logs, and Test Strategy).

## Validation after fixes

- `mcp__drm-copilot__validate_orchestration_artifacts` (artifact_type plan): re-run after the fixes; result `ok: true`.
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`: re-run after the fixes; EXIT_CODE 0, `plan validation passed`.
