# test-support-hygiene-793-skipif (Issue #938)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/ (Issue #938)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #938
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/938
- Last Updated: 2026-10-15
- Work Mode: minor-audit

## Summary

Two small Python test-hygiene items recorded as #903 Operator Follow-ups 9 and 12.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. #793 L22: `build_valid_epic_state` and `build_read_text_stub` live in a test module rather than a `*_test_support.py` module.
2. `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py:11-15` keeps a skipif reason ("gitignored and unavailable in CI") that .gitignore no longer supports.

## Expected Behavior

Shared builders live in a test-support module; skip reasons are accurate or the skip is removed.

## Acceptance Criteria

- [x] `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py` exists and defines `build_valid_epic_state` and `build_read_text_stub`, moved verbatim from their prior test modules.
- [x] No `test_*.py` file under `tests/` contains `def build_valid_epic_state` or `def build_read_text_stub`; the only definition of each is in the support module (verified by a single-line token search).
- [x] No `test_*.py` module imports `build_valid_epic_state` or `build_read_text_stub` from another `test_*.py` module, and the support module is not re-exported from any test module; `test_validate_epic_orchestrator_state_merge_status.py`, `test_validate_orchestration_artifacts_dispatch.py`, `test_validate_orchestration_artifacts_plan_gates.py`, and `test_validate_orchestration_artifacts_parallel_dispatch.py` import the builders from `tests.scripts.dev_tools.validate_orchestration_artifacts_test_support`.
- [x] The docstring in `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py` and the comment in `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` cite `validate_orchestration_artifacts_test_support` instead of the former test-module locations.
- [x] `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py` contains no `skipif` token and no `_requires_codex_runtime` token, and `import pytest` is removed if it is otherwise unused.
- [x] `poetry run pytest tests/scripts/dev_tools/test_codex_handoff_contract_parity.py -q -rs` reports all five tests passed with no skipped tests.
- [x] `poetry run pytest` over `test_validate_epic_orchestrator_state.py`, `test_validate_epic_orchestrator_state_merge_status.py`, `test_validate_orchestration_artifacts.py`, `test_validate_orchestration_artifacts_dispatch.py`, `test_validate_orchestration_artifacts_plan_gates.py`, `test_validate_orchestration_artifacts_parallel_dispatch.py`, and `test_validate_discovery_artifacts_dispatch.py` passes with zero failures and a collected-test count not lower than the pre-change baseline.
- [x] `poetry run black --check`, `poetry run ruff check`, and `poetry run pyright` report no errors on every touched Python file, including the new support module.
- [x] The TypeScript toolchain (Prettier, ESLint, tsc, and the jest run for `epic-orchestrator-state-core.test.ts`) passes in `extensions/drm-copilot` with the touched `.ts` file.
- [x] Every touched or created file stays at or under 500 lines.

## Actual Behavior

Both items remain.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 issue.md Operator Follow-ups 9 and 12.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The new #903 P7 mirror test already covers the atomic-plan-contract .agents pair unconditionally.

## Proposed Fix / Validation Ideas

- [ ] Move the two builders into a test-support module.
- [ ] Remove or correct the stale skipif.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch