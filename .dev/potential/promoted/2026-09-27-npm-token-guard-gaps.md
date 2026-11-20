# npm-token-guard-gaps (Issue #739)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-token-guard-gaps/ (Issue #739)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #739
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/739
- Last Updated: 2026-09-27
## Summary

The guard test added by #712 (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py`) catches `NPM_TOKEN`/`NODE_AUTH_TOKEN` references in workflows but misses other ways a long-lived npm token could be reintroduced. It also has small documentation defects.

## Environment

- OS/version: any
- Python version: repo default
- Command/flags used: pytest on the guard
- Data source or fixture: #712 final report

## Steps to Reproduce

The guard does not flag any of these:
1. `_authToken` written to an `.npmrc`
2. `NPM_CONFIG__AUTHTOKEN`
3. `npm config set ... _authToken`
4. `vars.NPM_TOKEN`
5. An env var named `NPM_TOKEN` that is fed from a differently named secret

## Expected Behavior

Any route that configures a long-lived npm auth token in a workflow fails the guard; publishing stays OIDC-only.

## Actual Behavior

Only the direct secret references are caught. Other defects:
- Runbook step 2 ("Recording completion") points at `issue.md` instead of `spec.md` or the pending evidence record.
- The docstring says "tracked files", but the guard scans files on disk.
- The spaced-bracket and lowercase-bracket forms have no tests, although the pattern handles them.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #712 final report, follow-ups 1-4.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The guard was scoped to the reference forms seen historically.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: extend the patterns and add a test per form; fix the docstring and runbook pointer; add the bracket-form tests.
- [ ] Integration scenario to retest: the next `mcp-server-v*` release still publishes via OIDC.
- [ ] Manual verification notes: the operator still owes the `NPM_TOKEN` secret deletion and npm revocation (#712 runbook).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
