# npm-token-guard-gaps (Issue #739)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-token-guard-gaps/ (Issue #739)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #739
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/739
- Last Updated: 2026-09-27
- Work Mode: minor-audit

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

## Acceptance Criteria

Source: research `research/research.2026-09-29T22-05.md` (Proposed Acceptance Criteria). Scope decisions for the research open questions: no `.npmrc` scan outside `.github/`, no `_auth`/`_password` keys, no `env.` context for `find_npm_token_references`, and no edit to the #712 pending evidence record; each is outside the issue's stated scope.

- [x] AC1: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` defines a helper that reports every line containing an `_authToken` configuration key in any casing: a registry-scoped `.npmrc` line, a bare `_authToken=` line, `NPM_CONFIG__AUTHTOKEN`, `npm_config__authToken`, `npm_config_//registry.npmjs.org/:_authToken`, and `npm config set [//registry.npmjs.org/:]_authToken`. Each form has its own parametrized positive case.
- [x] AC2: The `_authToken` helper does not report `id-token: write`, `registry-url: "https://registry.npmjs.org"`, `always-auth: true`, `NODE_AUTH_TOKEN: x`, or a letter-prefixed name such as `GH_AUTHTOKEN: x`. Each has a parametrized negative case.
- [x] AC3: `find_npm_token_references` reports `vars.NPM_TOKEN` and `vars['NPM_TOKEN']` in addition to the existing `secrets` forms, with a parametrized positive case for each; `vars.NPM_TOKEN_V2` is a parametrized negative case.
- [x] AC4: The module defines a helper that reports an `NPM_TOKEN` assignment: a YAML mapping key (block, flow, or quoted), a shell `NPM_TOKEN=` assignment including a `$GITHUB_ENV` append, and a PowerShell `$env:NPM_TOKEN =` assignment. Each has a parametrized positive case, and one case feeds the key from a differently named secret.
- [x] AC5: The `NPM_TOKEN` assignment helper does not report `${{ secrets.NPM_TOKEN }}`, `${{ env.NPM_TOKEN }}`, `NPM_TOKEN_V2: x`, `MY_NPM_TOKEN: x`, or `# NPM_TOKEN is no longer used`. Each has a parametrized negative case.
- [x] AC6: A tree-scan test asserts that no `*.yml`/`*.yaml` file under `.github/` has a line reported by any of the four helpers, and names each offender as `<relative-posix-path>:<line>`. The test passes on the current tree.
- [x] AC7: Parametrized cases `spaced-bracket` (`${{ secrets[ 'NPM_TOKEN' ] }}`) and `lowercase-bracket` (`${{ secrets['npm_token'] }}`) exist for `find_npm_token_references` and pass.
- [x] AC8: The module docstring no longer says "tracked files"; it states that files are enumerated and read from disk through `pathlib` whether or not version control tracks them, and it names every detected family.
- [x] AC9: Runbook `docs/features/completed/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md` "Recording completion" step 2 names `docs/features/completed/unused-npm-token-secret-712/evidence/other/human-action-pending.2026-09-27T09-19.md` as the record to update, says not to change AC4 status (citing D5), and no longer references `docs/features/active/unused-npm-token-secret-712/` or `issue.md`.
- [x] AC10: `.github/workflows/publish-mcp-npm.yml` is not modified by this change (`git diff --name-only origin/main...HEAD -- .github` produces no output).
- [x] AC11: The test module is under 500 lines.
- [x] AC12: `poetry run black`, `poetry run ruff check`, and `poetry run pyright` on the test module report no errors, `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` passes, and the full suite `poetry run pytest --cov --cov-branch --cov-report=term-missing` meets the 85% line and 75% branch thresholds.
