# Phase 1 — Fail-Before Evidence (Divergence 1, Python)

Timestamp: 2026-07-25T17-45

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_step_status_extras.py tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py --no-cov -q`

EXIT_CODE: 1

Output Summary:

`10 failed, 29 passed in 0.14s`. Executed from the repo root before any Phase 1
production change. Every failure is a new case added by [P1-T1] / [P1-T2]; all
29 passing cases are either pre-existing PR-creation-readiness tests (9) or the
new non-owning-key rejection matrix (20), which already holds pre-fix.

Failing new tests (all 10):

- `test_validate_orchestrator_state_step_status_extras.py::test_plain_validation_accepts_step9_extra_status[passed]`
- `test_validate_orchestrator_state_step_status_extras.py::test_plain_validation_accepts_step9_extra_status[failed_remediation_required]`
- `test_validate_orchestrator_state_step_status_extras.py::test_plain_validation_accepts_step9_extra_status[blocked_ci_loop_limit]`
- `test_validate_orchestrator_state_step_status_extras.py::test_plain_validation_accepts_step6_blocked_remediation_loop_limit`
- `test_validate_orchestrator_state_step_status_extras.py::test_require_complete_rejects_failure_step_status[step9_status-failed_remediation_required]`
- `test_validate_orchestrator_state_step_status_extras.py::test_require_complete_rejects_failure_step_status[step9_status-blocked_ci_loop_limit]`
- `test_validate_orchestrator_state_step_status_extras.py::test_require_complete_rejects_failure_step_status[step6_status-blocked_remediation_loop_limit]`
- `test_validate_orchestrator_state_step_status_extras.py::test_require_complete_accepts_step9_passed`
- `test_validate_orchestrator_state_step_status_extras.py::test_epic_mode_checkpoint_with_step9_passed_validates`
- `test_validate_orchestrator_state_pr_creation_readiness.py::test_pr_creation_readiness_rejects_step6_blocked_remediation_loop_limit`

Representative pre-fix diagnostics:

- `AssertionError: assert ['Checkpoint has invalid step9_status: passed'] == []`
- `AssertionError: assert ['Checkpoint has invalid step6_status: blocked_remediation_loop_limit'] == []`
- `AssertionError: assert 'Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.' in ['Checkpoint has invalid step6_status: blocked_remediation_loop_limit']`

No pre-existing test failed.
