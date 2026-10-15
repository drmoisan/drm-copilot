# npm-token-guard-comparison-false-positive-and-stale-docstring (Issue #845)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-token-guard-comparison-false-positive-and-stale-docstring/ (Issue #845)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #845
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/845
- Last Updated: 2026-10-08
- Work Mode: full-bug

## Summary

The `NPM_TOKEN` assignment pattern added by #739 also matches an equality comparison such as `env.NPM_TOKEN == ''`, and one positive-case test docstring still describes only `secrets` references after `vars` cases were added. Both were recorded as non-blocking in the #739 review.

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
- Data source or fixture: origin/main at fb413fce; `docs/features/active/2026-09-27-npm-token-guard-gaps-739/code-review.2026-10-01T21-03.md` lines 39-40

## Steps to Reproduce

1. Read `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:47-49`: `_NPM_TOKEN_ASSIGNMENT = re.compile(r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=", re.IGNORECASE)`.
2. Evaluate the pattern against `if: ${{ env.NPM_TOKEN == '' }}`, `if: ${{ env.NPM_TOKEN != '' }}`, and `NPM_TOKEN=abc`.
3. Read the docstring of `test_find_npm_token_references_detects_reintroduced_reference` (line 208) and its parameter list (lines 201-202).

## Expected Behavior

- A comparison (`==`) is not reported as an assignment, or a test case documents that it is reported intentionally.
- The docstring describes all parameterized cases, for example "A reintroduced ``NPM_TOKEN`` secret or variable reference is reported at its line."

## Actual Behavior

- Step 2 printed `True` for `env.NPM_TOKEN == ''`, `False` for `env.NPM_TOKEN != ''`, and `True` for `NPM_TOKEN=abc` (in-memory `re` probe run on 2026-10-08 against the pattern copied from main). The `\bNPM_TOKEN\s*=` alternative matches the first `=` of `==`. The result is fail-closed: the guard would fail on a harmless comparison rather than miss a route. `git grep -n -i NPM_TOKEN -- .github` returns no match on main, so there is no current impact. No test case documents the behavior.
- Line 208 reads "A reintroduced ``NPM_TOKEN`` secret reference is reported at its line." while lines 201-202 add `vars-dot` and `vars-bracket` cases. Deviation D5 in the #739 plan updated the sibling negative test docstring to "secret or variable" but not this one.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:
  ```
  "if: ${{ env.NPM_TOKEN == '' }}" True
  "if: ${{ env.NPM_TOKEN != '' }}" False
  'NPM_TOKEN=abc' True
  ```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

A future workflow that tests whether `NPM_TOKEN` is empty would fail the guard test without introducing a token route. The docstring issue affects accuracy only.

## Suspected Cause / Notes

- Originating item: #739 (bug-burndown-2026-09-29 parallel run). Source: code review CR-1 and CR-2 (`code-review.2026-10-01T21-03.md:39-40`), policy audit NB-1 and NB-2 (`policy-audit.2026-10-01T21-03.md:186-187`), feature audit FA-1 (`feature-audit.2026-10-01T21-03.md:93`).
- CR-3 (`GH__AUTHTOKEN` matched by the `_authToken` lookbehind) and CR-4 (tree scan reads the repository from disk) were recorded as Info with no action and are not included.
- The test module is 492 lines; a fix must stay under the 500-line limit.
- No open issue covers these gaps (checked `gh issue list --state open` on 2026-10-08).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add a `(?!=)` lookahead after `=` in the second alternative, plus negative rows for `==` comparisons; or add a positive row documenting the comparison match if it is intended.
- [ ] Integration scenario to retest: rerun `test_github_yaml_files_contain_no_npm_token_route` against the current `.github/` tree.
- [ ] Manual verification notes: reword the line-208 docstring to "secret or variable reference".

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
