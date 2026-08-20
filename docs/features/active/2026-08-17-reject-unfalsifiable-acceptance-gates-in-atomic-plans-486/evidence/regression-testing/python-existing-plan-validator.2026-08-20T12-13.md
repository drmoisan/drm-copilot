# Pre-Existing Plan-Validator Regression Suite

Timestamp: 2026-08-20T12-13
Task: [P6-T13]
Issue: #486
Working directory: worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a61259d5432e08b89`

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py -q`

EXIT_CODE: 0

Output Summary: 17 passed, 0 failed, 0 skipped in 0.13s. No pre-existing assertion in either file was modified by this change. The two files were run with `--no-cov` appended so the run measures only the regression outcome; the coverage-bearing run is the Phase 12 final-QC command.

Confirmation of the specific contracts the suite protects:

- `validate_plan_text(text)` keeps its `(text: str) -> list[str]` signature and its existing structural error strings and order; `test_validate_plan_text_rejects_noncanonical_phase_heading` and `test_validate_plan_text_rejects_nonsequential_task_numbers` pass unchanged.
- `_validate_from_args` still returns a `list[str]`; `test_validate_from_args_returns_unsupported_artifact_type` and `test_validate_from_args_dispatches_epic_orchestrator_state` pass unchanged. The new two-channel dispatcher `_validate_from_args_with_warnings` delegates to it for every non-plan artifact type, so the single-channel dispatch path is unmodified.
- `main(["plan", ...])` still returns 1 for a structurally invalid plan; `test_main_returns_exit_code_1_for_an_invalid_plan_artifact` passes unchanged.
