# extension-tests-fail-in-container (Issue #12)

- Date captured: 2026-02-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/extension-tests-fail-in-container/ (Issue #12)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #12
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/12
- Last Updated: 2026-02-04
## Summary

Extension integration tests cannot run inside the dev container, so the integration suite fails consistently.
This blocks running the full test workflow in container environments.

## Environment

- OS/version: Linux (dev container)
- Python version: Unknown (not provided)
- Command/flags used: Extension integration test suite executed in the container
- Data source or fixture: Extension test harness (no external data sources reported)

## Steps to Reproduce

1. Open the repo in the dev container.
2. Run the extension integration tests from the container.
3. Observe that the integration suite fails due to container limitations.

## Expected Behavior

Integration tests complete successfully when run in the container, or are implemented in a way that works in both container and host environments.

## Actual Behavior

Integration tests fail consistently in the dev container because the container cannot run the required integration test environment.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: Not provided.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The current integration test harness relies on a runtime that is not available in the dev container. The suite should be rewritten to use the Jest provider so it can run in container or on host.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: Ensure Jest-based tests cover the same integration behaviors currently covered by container-incompatible tests.
- [ ] Integration scenario to retest: Run the Jest-based integration suite in the dev container and on host to confirm parity.
- [ ] Manual verification notes: Validate that the extension still behaves correctly in a local VS Code instance after test rewrite.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch