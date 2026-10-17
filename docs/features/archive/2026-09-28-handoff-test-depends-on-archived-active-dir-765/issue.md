# handoff-test-depends-on-archived-active-dir (Issue #765)

- Date captured: 2026-09-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/handoff-test-depends-on-archived-active-dir/ (Issue #765)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #765
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/765
- Last Updated: 2026-09-28
- Work Mode: minor-audit

## Summary

`test_plan_directory_rediscovery_blocks_before_write` in `tests/scripts/dev_tools/test_orchestration_handoff_paths.py` fails on `main` and on every PR because it passes the literal directory `docs/features/active` to `resolve_pinned_plan_path`, and that directory no longer exists after PR #759 archived every active feature folder.

## Environment

- OS/version: ubuntu-latest (GitHub Actions), `quality-checks7 / Code Quality & Tests (3.11)`
- Python version: 3.11.16
- Command/flags used: `poetry run pytest` (CI quality-checks job)
- Data source or fixture: repository tree at `main` 5d0b93a0

## Steps to Reproduce

1. Check out `main` at or after the merge of PR #759 (no tracked files under `docs/features/active/`).
2. Run `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py`.
3. Observe the failure in `test_plan_directory_rediscovery_blocks_before_write`.

## Expected Behavior

The test passes: a directory supplied as a plan path is rejected with `HandoffContractError`, independent of whether any particular feature folder exists in the checkout.

## Actual Behavior

`Path.resolve(strict=True)` raises `FileNotFoundError: [Errno 2] No such file or directory: '.../docs/features/active'` before the resolver reaches its `is_file()` check, so `pytest.raises(HandoffContractError)` fails. Observed on PR #761, run 36494745343, job 109171564777.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `FAILED tests/scripts/dev_tools/test_orchestration_handoff_paths.py::test_plan_directory_rediscovery_blocks_before_write - FileNotFoundError: [Errno 2] No such file or directory: '/home/runner/work/drm-copilot/drm-copilot/docs/features/active'`

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The Python quality-checks job fails for every PR into `main`, including release PR #761.

## Suspected Cause / Notes

The test depends on a mutable content directory. `docs/features/active/` exists only while at least one active feature folder is tracked; git does not track empty directories.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: point the test at a stable tracked directory that the same test module already depends on (`tests/fixtures/orchestration-handoff/contract`).
- [ ] Integration scenario to retest: CI `quality-checks7` job on the fix PR and on PR #761 after it is updated from `main`.
- [ ] Manual verification notes: none.

## Acceptance Criteria

- [x] `test_plan_directory_rediscovery_blocks_before_write` no longer references `docs/features/active` and passes when no `docs/features/active/` directory exists.
- [x] The test still asserts that a directory plan path is rejected with `HandoffContractError`.
- [x] No production file changes.
- [x] The Python toolchain (Black, Ruff, Pyright, Pytest) passes locally for the changed test module.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
