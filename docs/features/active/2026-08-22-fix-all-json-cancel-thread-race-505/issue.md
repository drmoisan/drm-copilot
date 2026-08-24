# fix-all-json-cancel-thread-race (Issue #505)

- Date captured: 2026-08-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/fix-all-json-cancel-thread-race/ (Issue #505)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.


- Issue: #505
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/505
- Last Updated: 2026-08-23
- Work Mode: full-bug

## Summary

`tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result` fails intermittently. It asserts that the JSON lane cancels before its validate step when a sibling lane fails, which depends on a cancel signal propagating across threads before that step is reached. Under machine load the race resolves the other way and the lane runs validate, failing the assertion.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `poetry run pytest tests/scripts/dev_tools/test_fix_all_failure_paths.py`
- Data source or fixture: `FakeRunnerFactory` responses built by `base_success_responses()` in the same test module

## Steps to Reproduce

1. Run the whole Python suite, or the single node id, repeatedly on a loaded workstation.
2. Observe that the result alternates between pass and fail with no source change.
3. Measured during issue #500 orchestration: 13 failures in the first 19 iterations of an isolated loop, and 3 of 3 failures when run alone during a period of contention.
4. Immediately afterwards, a full-suite run on a quiet machine returned `4078 passed, 5 skipped, 0 failed`.

## Expected Behavior

The test is deterministic. Given the same inputs it produces the same result on every run, regardless of machine load, as `.claude/rules/general-unit-test.md` requires under its determinism rules.

## Actual Behavior

The assertion fails with:

```text
AssertionError: assert 'JSON: validate' not in ['JSON: format', 'JSON: validate']
```

The run also emits `PytestUnhandledThreadExceptionWarning`, indicating an exception raised inside a worker thread.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

  ```text
  tests\scripts\dev_tools\test_fix_all_failure_paths.py:170: AssertionError
  E       AssertionError: assert 'JSON: validate' not in ['JSON: format', 'JSON: validate']
  PytestUnhandledThreadExceptionWarning: Exception in thread Thread-1 (_runner)
  ```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. The full Python suite runs unrestricted in CI (`.github/workflows/_quality-checks.yml`), so this test executes on every pull request. A CI runner under load can turn a required check red for a reason unrelated to the change under review, which stalls any orchestration whose completion gate depends on observing CI green, and invites remediation cycles against a defect that is not the author's.

## Suspected Cause / Notes

The race is in `scripts/dev_tools/fix_all_runtime.py`: one `threading.Thread` per branch is started around line 148, and `cancel_event.set()` is called around line 145. Nothing forces the cancel signal to be observed by a sibling lane before that lane advances to its next step, so the outcome depends on scheduling.

Confirmed not to be caused by the issue #500 branch: that branch touches nothing under `scripts/`, and the same test fails identically at the merge base in a detached worktree with the loaded module verified through `__file__`.

## Proposed Fix / Validation Ideas

- [ ] Make the cancel observation deterministic rather than timing dependent, for example by having each lane check the cancel event at a defined barrier the test can drive, instead of relying on the signal winning a race against thread start-up.
- [ ] Unit coverage areas: `fix_all_runtime` lane sequencing and cancel propagation.
- [ ] Integration scenario to retest: a sibling failure with `complete_all` off must skip the dependent step on every run.
- [ ] Manual verification notes: run the node id in a loop of at least 50 iterations under artificial load and require zero failures.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
