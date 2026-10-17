# npm-token-guard-misses-append-assignment (Issue #933)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-token-guard-misses-append-assignment/ (Issue #933)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #933
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/933
- Last Updated: 2026-10-15
- Work Mode: minor-audit

## Summary

The workflow NPM token guard does not detect the append form NPM_TOKEN+=${{ secrets.X }}. Recorded as #903 Operator Follow-up 1 (from #845 research).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Add ``NPM_TOKEN+=${{ secrets.X }}`` to a workflow and run tests/scripts/dev_tools/test_workflow_npm_token_guard.py; none of the four finders reports it.

## Expected Behavior

The guard reports append assignments of NPM_TOKEN.

## Actual Behavior

The append form is not reported; #903 pinned this with the residual-bash-append-not-reported test row (AC-14).

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 issue.md Operator Follow-ups item 1; evidence/regression-testing/fail-before-exception.p8-845.*.md.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Proposed pattern from the research: \bNPM_TOKEN\s*\+?=(?!=). This reverses a #845 spec non-goal, so it needs an operator decision.

## Proposed Fix / Validation Ideas

- [ ] Decide whether the append form is in scope; if so, change the finders and flip the pinned row to expect a finding.

## Acceptance Criteria

Adopted approach (orchestrator decision D1, recorded 2026-10-15 under the autonomous operator policy): the append form is in scope. This reverses the #845 spec non-goal that classed bash `NPM_TOKEN+=x` as an accepted unreported residual. The guard lives in test code only. The fix changes alternative B of `_NPM_TOKEN_ASSIGNMENT` in `tests/scripts/dev_tools/npm_token_guard_test_support.py` from `\bNPM_TOKEN\s*=(?!=)` to `\bNPM_TOKEN\s*\+?=(?!=)`. Alternative A and finders 1-3 are unchanged. Research: `research/research.2026-10-15T17-50.md`.

- [x] AC-1: `find_npm_token_assignments` reports the append form, verified by new `test_find_npm_token_assignments_detects_assignment` rows in `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` that expect `[1]` for each of: `NPM_TOKEN+=${{ secrets.X }}` (the issue repro), `export NPM_TOKEN+=x`, and `$env:NPM_TOKEN += 'x'`.
- [x] AC-2: The pinned row `residual-bash-append-not-reported` in `test_find_npm_token_assignments_pins_documented_residuals` is flipped to expect `[1]` for `NPM_TOKEN+=x` and is renamed to the id `bash-append-reported`. The id `residual-bash-append-not-reported` no longer appears in the test module.
- [x] AC-3: No existing negative or residual outcome changes. Every pre-existing row in `test_workflow_npm_token_guard.py` other than the AC-2 row passes unchanged, including `equality-comparison`, `shell-equality-test`, `inequality-comparison`, `accepted-double-equals-narrowing-not-reported`, `residual-single-equals-shell-test-reported`, and `residual-bash-regex-match-reported`. New non-regression rows expect `[]` for `NPM_TOKEN+==x`, `NPM_TOKEN_V2+=x`, and `(( NPM_TOKEN++ ))`.
- [x] AC-4: The repository tree-scan tests in `test_workflow_npm_token_guard.py` still pass, so no workflow under `.github/` is newly reported.
- [x] AC-5: The stale statements are corrected. The `test_find_npm_token_assignments_pins_documented_residuals` docstring records that #933 reversed the #845 append non-goal and that the `=` shell test and `=~` residuals remain reported. The `find_npm_token_assignments` docstring in `npm_token_guard_test_support.py` states that `+=` appends are reported and that `==` and `+==` are not.
- [x] AC-6: Fail-before / pass-after evidence. The AC-1 and AC-2 rows fail against the unmodified pattern and pass after the change. Both pytest runs are recorded under `evidence/regression-testing/`.
- [x] AC-7: The Python toolchain (black, ruff, pyright, pytest) reports no formatting changes, no lint findings, no type errors, and no test failures on the two changed files and the full suite. Full-suite coverage after the change does not fall below baseline and meets the repository thresholds (line >= 85%, branch >= 75%). No production line changes, so new-code coverage is recorded as not applicable, supported by an empty `git diff --name-only origin/main...HEAD -- src scripts`.
- [x] AC-8: Both changed files stay at or under 500 lines, verified by a line count.
- [x] AC-9: The CI job `quality-checks7` (Code Quality & Tests) passes on the PR head (CI-dependent).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch