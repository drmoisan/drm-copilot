# testing-missing-mock-injections (Issue #42)

- Date captured: 2026-02-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/testing-missing-mock-injections/ (Issue #42)
- Issue: #42
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/42
- Last Updated: 2026-02-22
- Work Mode: full

## Summary

Unit tests in `tests/scripts/dev_tools/test_new_active_feature_folder.py` invoke `create_active_folder(...)` without injecting `code_launcher`, allowing the default launcher to execute real `code` subprocess calls. This causes external side effects (opening/creating files under `/workspace/...` mapped as `C:\workspace\...` on Windows), violating unit-test isolation.

## Environment

- OS/version: Windows host (paths observed under `C:\workspace\...`)
- Python version: project Poetry environment (exact interpreter version from local Poetry runtime)
- Command/flags used: `poetry run pytest tests/scripts/dev_tools -q`
- Data source or fixture:
	- `FakeFileSystem` in `test_new_active_feature_folder.py`
	- Runtime subprocess instrumentation via `artifacts/research/sitecustomize.py`
	- Subprocess evidence log: `artifacts/research/subprocess-invocations.log`

## Steps to Reproduce

1. Ensure tests run with default behavior where some `create_active_folder(...)` calls omit `code_launcher=...` in `tests/scripts/dev_tools/test_new_active_feature_folder.py`.
2. Run:
	- `poetry run pytest tests/scripts/dev_tools -q`
3. Inspect subprocess evidence (instrumented run):
	- `artifacts/research/subprocess-invocations.log`
4. Observe `code` invocations containing `/workspace/docs/features/active/...` paths (for example `single-marker-40`, `full-compatible`, `no-potential`).

## Expected Behavior

Unit tests should be hermetic: no real editor launcher process should execute, and no files should be opened/created outside test-controlled fake filesystem boundaries.

## Actual Behavior

`code` launcher subprocesses were invoked during unit tests with `/workspace/docs/features/active/...` file arguments, matching externally observed artifacts under `C:\workspace\docs\features\active\...`.

Confirmed examples from captured evidence include:
- `/workspace/docs/features/active/single-marker-40/issue.md`
- `/workspace/docs/features/active/full-compatible/user-story.md`
- `/workspace/docs/features/active/full-compatible/spec.md`
- `/workspace/docs/features/active/no-potential/user-story.md`

No explicit `git worktree` subprocess command was captured in the same instrumentation run (`GIT_WORKTREE_MATCHES=0`).

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:
	- `run|...\code.CMD /workspace/docs/features/active/full-compatible/user-story.md ...`
	- `run|...\code.CMD /workspace/docs/features/active/no-potential/user-story.md ...`
	- Source: `artifacts/research/subprocess-invocations.log`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Primary cause is missing launcher injection in 11 test callsites: `create_active_folder(...)` defaults to `default_code_launcher(...)` when `code_launcher` is not provided.

Relevant code path:
- `scripts/dev_tools/new_active_feature_folder_flow.py`
	- `opened = code_launcher(existing)`
- `scripts/dev_tools/new_active_feature_folder_io.py`
	- `default_code_launcher(...)` → `subprocess.run([code_cmd, ...], check=False)`

Known affected callsite functions include:
- `test_create_active_folder_raises_on_invalid_feature_type`
- `test_create_active_folder_raises_on_missing_template`
- `test_create_active_folder_raises_when_exists_without_force`
- `test_create_active_folder_minor_audit_materializes_issue_md_and_skips_full_docs`
- `test_work_mode_marker_minor_issue_md`
- `scenario_single_work_mode_marker_before_first_heading`
- `test_minor_audit_preserves_issue_frontmatter_and_spacing`
- `test_create_active_folder_minor_audit_falls_back_to_full_when_not_eligible`
- `test_work_mode_marker_fallback_issue_md_full`
- `test_create_active_folder_full_mode_remains_backward_compatible`
- `test_create_active_folder_fallback_reason_output`

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
	- Inject `code_launcher=FakeCodeLauncher()` in all missing `create_active_folder(...)` test callsites.
	- Add guard fixture in `tests/conftest.py` to fail on unmocked editor-launch subprocess attempts from isolated unit tests.
- [x] Integration scenario to retest
	- Re-run `poetry run pytest tests/scripts/dev_tools -q` and verify no real `code` subprocess invocations occur from `test_new_active_feature_folder.py`.
- [x] Manual verification notes
	- Confirm no new files appear under `C:\workspace\docs\features\active\*` after test execution.
	- Preserve/update `artifacts/research/subprocess-invocations.log` as verification evidence.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

## Resolution Summary

- Added deterministic regression test `test_guard_blocks_unmocked_code_launcher_invocation` and captured fail-before evidence.
- Injected `code_launcher=FakeCodeLauncher()` into the planned missing `create_active_folder(...)` callsites and aligned additional scoped callsites impacted by the new guard.
- Added scoped fixture `guard_unmocked_code_launcher_subprocess` in `tests/conftest.py` with explicit launcher-test allowlist containing `default_code_launcher`.
- Verified targeted module, guard/launcher subset, dev-tools folder tests, and full Python QA loop.

## Resolution Evidence

- `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/regression-testing/`
- `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/qa-gates/`