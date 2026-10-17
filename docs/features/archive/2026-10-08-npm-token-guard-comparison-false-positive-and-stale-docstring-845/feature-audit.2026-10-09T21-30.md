# Feature Audit: npm token guard comparison false positive and stale docstring (#845)

**Audit Date:** 2026-10-09
**Feature Folder:** `docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845`
**Base Branch:** `origin/main`
**Head Branch:** `bug/npm-token-guard-comparison-false-positive-and-stale-docstring-845`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review (structure rewrite of the 2026-10-09T21-30 pass)

- Blocking findings: 0
- Non-blocking findings: 1 (FA-1)
- Overall verdict: PASS (14 of 14 acceptance criteria PASS)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `73ddf6c6ad83d8f4034f642758f07f30a545294c` at review time)
- **Head branch/commit:** `bug/npm-token-guard-comparison-false-positive-and-stale-docstring-845` (commit `7c7546160409b0f3f58eecc8fa41dcdfdcd793de` at review time)
- **Diff form:** three-dot, `git diff origin/main...HEAD`
- **Evidence sources:**
  - PR context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in this worktree; scope was derived from `git diff origin/main...HEAD`.
  - Feature evidence: `docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/evidence/**`
  - Reviewer re-runs: `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` (56 passed), `poetry run ruff check --no-fix` on the test file (All checks passed!), `wc -l` on the test file (497), and `validate_evidence_locations.py --root .` (no violations).
- **Requirements source:** `spec.md` `## Acceptance Criteria`
- **Work mode resolution note:** full-bug uses `spec.md` only as the AC source.
- **Scope note:** Full branch diff against `origin/main`; the only changed code file is `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/spec.md` - only source

### Acceptance criteria

1. AC-1: Alternative B of `_NPM_TOKEN_ASSIGNMENT` is `\bNPM_TOKEN\s*=(?!=)`, alternative A is unchanged, and `re.IGNORECASE` is retained.
2. AC-2: Fail-first evidence recorded: with the new rows added and the pattern unchanged, `[equality-comparison]` and `[shell-equality-test]` fail.
3. AC-3: After the fix, `[equality-comparison]` (input `if: ${{ env.NPM_TOKEN == '' }}`) passes.
4. AC-4: After the fix, `[shell-equality-test]` (input `[[ $NPM_TOKEN == "" ]]`) passes.
5. AC-5: After the fix, `[inequality-comparison]` (input `if: ${{ env.NPM_TOKEN != '' }}`) passes.
6. AC-6: After the fix, `detects_assignment[empty-assignment-end-of-line]` (input `NPM_TOKEN=`, expected `[1]`) passes.
7. AC-7: Existing assignment rows are preserved and pass, with unchanged input text and expected value.
8. AC-8: Integration retest: `test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment]` and `test_collect_offenders_names_each_matching_line` pass against the current `.github/` tree.
9. AC-9: The `find_npm_token_assignments` docstring lists an `==` comparison among the inputs that are not reported.
10. AC-10: The first docstring line of `test_find_npm_token_references_detects_reintroduced_reference` equals "A reintroduced ``NPM_TOKEN`` secret or variable reference is reported."
11. AC-11: The targeted module run reports zero failed and zero errored nodes, with output under `evidence/qa-gates/`.
12. AC-12: Black check, Ruff check (including E501), and Pyright pass on the changed file in a single pass, with output under `evidence/qa-gates/`.
13. AC-13: The test file is at or under the 500-line policy limit.
14. AC-14: No changed path outside the test file, the feature folder, and the promoted lifecycle record.

---

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence and verification |
| --- | --- | --- |
| AC-1 | PASS | Diff line 48 shows alternative A unchanged and alternative B `\bNPM_TOKEN\s*=(?!=)` with `re.IGNORECASE`; `evidence/regression-testing/pattern-probe-after-fix.md` and `evidence/qa-gates/final-pattern-probe.md` record `True re.IGNORECASE`. |
| AC-2 | PASS | `evidence/regression-testing/fail-first-assignment-rows.md`: `[equality-comparison]` and `[shell-equality-test]` FAILED (exit 1, expected 1) with the pattern unchanged; commit order (`c2abd7331` test rows, then `7997f53fb` fix) confirms the fail-first state. |
| AC-3 | PASS | `[equality-comparison]` PASSED in `pass-after-assignment-rows.md` and `ac-node-listing.md`; reviewer run 56 passed. |
| AC-4 | PASS | `[shell-equality-test]` PASSED in the same artifacts. |
| AC-5 | PASS | `[inequality-comparison]` PASSED in the same artifacts. |
| AC-6 | PASS | `detects_assignment[empty-assignment-end-of-line]` PASSED; row input `NPM_TOKEN=` expects `[1]` per diff. |
| AC-7 | PASS | All 7 listed detect rows and 6 listed ignore rows PASSED in `ac-node-listing.md`; `diff-numstat.md` and the reviewer's diff show no existing `pytest.param(` line removed or altered. |
| AC-8 | PASS | `integration-retest.md`: `test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment]` and `test_collect_offenders_names_each_matching_line` PASSED; also PASSED in the full-module listing. |
| AC-9 | PASS | Diff shows the `find_npm_token_assignments` docstring includes "an ``==`` comparison" in the non-reported list, matching Proposed Fix item 3 verbatim; `final-docstring-probe.md` records `True True True`. |
| AC-10 | PASS | Diff shows the first docstring line equals "A reintroduced ``NPM_TOKEN`` secret or variable reference is reported."; same probe artifact. |
| AC-11 | PASS | `final-pytest-module.md`: 56 passed, exit 0, no failed or errored count; reviewer re-run confirms. |
| AC-12 | PASS | `final-black-check.md` (1 file would be left unchanged), `final-ruff.md` (All checks passed!), `final-pyright.md` (0 errors, 0 warnings, 0 informations), all LoopPass 1 per `final-loop-single-pass.md`. Reviewer re-ran Ruff. |
| AC-13 | PASS | `final-line-count.md` reports 497; reviewer `wc -l` also 497. |
| AC-14 | PASS | `git diff origin/main...HEAD --name-only` lists only the test file, paths under the feature folder, and the promoted record `docs/features/potential/promoted/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring.md`; reviewer filtered check for `artifacts`, `.github`, `src`, `scripts`, `extensions` returned empty. `scope-boundary.md` and `coverage-applicability.md` agree. Review artifacts written in this folder remain within the permitted feature-folder path. |

---

## Bug Fix Verification Against Spec

- Expected behavior 1 (comparison not reported): satisfied; `env.NPM_TOKEN == ''` returns `[]` after the fix, and the regression row documents it.
- Expected behavior 2 (docstring describes all parameterized cases): satisfied by the revised summary line.
- Non-goals respected: no `.github/` edit, no change to the other three finder patterns, no production change, historical fixture untouched.
- Decisions D1 through D4 were followed: lookahead approach, 77-character docstring wording, coverage-not-applicable statement, no total node-count criterion.

## Findings

- FA-1 (non-blocking): `spec.md` header still shows `Status: Draft` and `Version: 0.2`, and the seeded `## Test Strategy` checkboxes remain unchecked. These are not acceptance criteria and do not affect the verdict; the owner may update them at merge.

## Summary

**Overall Feature Readiness:** PASS.

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

Blocking findings: 0. Overall verdict: PASS. No remediation inputs are required, so `remediation-inputs` was not produced.

---

## Acceptance Criteria Check-off

- All 14 AC items were already `[x]` in `spec.md`; each was independently verified as PASS above, so no change was needed.
- No source-file edit was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/spec.md`
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: none
- Newly checked off by this review: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 14 | 14 | 0 | Checkbox-backed |
