# Preflight Fixes (Issue #984)

Timestamp: 2026-10-20T12-48
Plan: docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984/plan.2026-10-20T07-56.md

Single-pass preflight under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`. Only task text and plan preamble were edited; no task was added, removed, reordered, or checked.

## Fixes

1. `## Files Written` (Feature folder line) | incomplete path citation | Named the promotion lifecycle record `docs/features/potential/promoted/2026-10-20-completion-helpers-missing-from-core-pack-manifest.md` as a file created by promotion and not edited by the plan. Reason: the worktree carries this file as untracked at preflight, so the [P7-T1] scope condition ("every changed path outside `FEATURE/` is in `## Files Written`") could not hold while the file was unlisted.
2. `[P0-T2]` | unsatisfiable condition from lifecycle state (meaning kept) | The porcelain stop condition now excludes the promoted lifecycle record named in `## Files Written`. Reason: `git status --porcelain` at preflight lists that record outside `FEATURE/`, which would have stopped execution at [P0-T2] for a file the plan does not touch. The condition still stops on any other entry outside `FEATURE/`.
3. `[P0-T9]` | command over a file the plan creates later | The baseline Pytest set is the [P6-T17] contract tests that exist at baseline, excluding `test_push_down_pack_manifest_dependency_closure.py`, which [P1-T3] creates. Reason: naming a missing file makes Pytest exit with a collection error for the whole run.
4. `[P2-T1]` | ambiguous row scope (meaning kept) | Stated that the in-process helper-failure rows CH1, CH2, and CH6 re-dot-source the hook and carry the `E-CONSTRUCTION` handler-variable assertion, and that CH4 and CH5 apply the same mocks through the `&` route without re-dot-sourcing. Reason: a `$script:` variable set inside a script invoked through `&` is not visible to the test, so the assertion cannot pass on CH4 or CH5; the [P2-T5] expected fail-before set (CH5 passes before the fix) already implies this scope.
5. `[P2-T5]` | validator-blind exit-code class from the brief | Stated that the launcher exits 1 when the JUnit failed count is non-zero. Reason: `Invoke-Pester` without `-EnableExit` exits 0 when tests fail, so the recorded `EXIT_CODE` would not match the task's `ExpectedExitCode: 1`.

## Verification after fixes

- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`): re-run after the edits; result `ok: true`.
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`: re-run after the edits; `plan validation passed`, EXIT_CODE 0.
