# prettier-format-check-fails-on-docs-fixtures (Issue #1179)

- Date captured: 2026-11-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/prettier-format-check-fails-on-docs-fixtures/ (Issue #1179)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1179
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1179
- Last Updated: 2026-11-14
## Summary

The repository-root Prettier format check (`format:check`) fails on three JSON fixtures under `tests/scripts/claude-lib/docs/fixtures/`. CI does not run the root check, so the failure is visible only locally, where it makes the format stage of the mandatory toolchain loop fail for every orchestration that runs it.

## Environment

- OS/version: Windows 11 (local); reported by two independent orchestration runs (#1163, #1157) on 2026-11-13
- Python version: not applicable
- Command/flags used: root `npm run format:check` (Prettier `--check`)
- Data source or fixture: `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`, `python-native-corpus.json`, `python-surface-corpus.json`

## Steps to Reproduce

1. Check out `main`.
2. Run the root Prettier check over the repository (`npm run format:check`).
3. Observe the three fixture files reported as not formatted.

## Expected Behavior

The root format check passes on `main`, and CI enforces the same check so that a regression fails a PR.

## Actual Behavior

Prettier reports formatting differences in the three fixtures. CI stays green because no CI job runs the root check over these paths.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: Prettier `[warn]` lines naming the three fixture files, as reported by the #1163 and #1157 runs.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The fixtures are consumed by Pester suites under `tests/scripts/claude-lib/docs/` (snapshot, parity and analyzer tests) and one pytest suite. Some consumers may compare bytes or hashes, so reformatting may require regenerating pinned values, or the fixtures may instead need a `.prettierignore` entry if their exact layout is part of the contract. Decide which by reading the consumers.

## Proposed Fix / Validation Ideas

- [ ] Either format the fixtures and update any byte/hash pins, or add them to `.prettierignore` with a stated reason, whichever keeps the consumer contracts intact
- [ ] Make CI run the root format check (or extend an existing format job) so the class cannot recur
- [ ] Re-run the consuming Pester and pytest suites in parallel and confirm no regression

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
