# Feature Audit: npm-token-guard-gaps (#739)

**Audit Date:** 2026-10-01
**Feature Folder:** `docs/features/active/2026-09-27-npm-token-guard-gaps-739`
**Base Branch:** `main`
**Head Branch:** `bug/npm-token-guard-gaps-739`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `12fd3c2639f17aec3572f90e8d929205059be56d`, includes #723 / PR #813)
- **Head branch/commit:** `bug/npm-token-guard-gaps-739` (commit `9273246fd60550a51f5bc70ff4675773666d0a04`)
- **Merge base:** `12fd3c2639f17aec3572f90e8d929205059be56d`
- **Evidence sources:**
  - Primary: `git diff origin/main...HEAD` and `git log origin/main..HEAD`, read directly by the reviewer (`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are not present in this worktree)
  - Feature evidence: `docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/**`
  - Additional evidence: reviewer reruns of Black, Ruff, Pyright, and the guard module pytest; direct reads of the module, runbook, and #712 records
- **Feature folder used:** `docs/features/active/2026-09-27-npm-token-guard-gaps-739`
- **Requirements source:** `issue.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: minor-audit`; `spec.md` and `user-story.md` are not AC sources in this mode.
- **Scope note:** Full branch diff against `main` (41 files, 1418 insertions, 53 deletions).

### Baseline Comparison

| Aspect | Baseline (`origin/main` 12fd3c26) | Branch HEAD |
|---|---|---|
| Guard test nodes | 17 passed (`evidence/baseline/baseline-pytest-guard.2026-10-01T20-49.md`) | 52 passed (reviewer rerun) |
| Detected families | `secrets.NPM_TOKEN` references, `NODE_AUTH_TOKEN` mentions | adds `vars.NPM_TOKEN`, `_authToken` config keys, `NPM_TOKEN` assignments |
| Module docstring probe | `True False False False True False False` | `False True True True True True True` (`evidence/qa-gates/ac8-docstring-check.2026-10-01T20-59.md`) |
| Module line count | 263 | 492 (reviewer `grep -c ""`) |
| Runbook step 2 | points at `docs/features/active/unused-npm-token-secret-712/` and `issue.md` | points at the pending evidence record and cites D5 |
| Repo Python coverage | line 93.53%, branch 86.76% | line 93.53%, branch 86.76% (unchanged; test file omitted from coverage) |
| Full suite | 6296 passed, 6 skipped | 6331 passed, 6 skipped |

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-27-npm-token-guard-gaps-739/issue.md` - only source

### Acceptance criteria

1. AC1: A helper reports every line containing an `_authToken` configuration key in any casing (registry-scoped `.npmrc`, bare `_authToken=`, `NPM_CONFIG__AUTHTOKEN`, `npm_config__authToken`, `npm_config_//registry.npmjs.org/:_authToken`, `npm config set [//registry.npmjs.org/:]_authToken`), each with its own parametrized positive case.
2. AC2: The `_authToken` helper does not report `id-token: write`, `registry-url`, `always-auth: true`, `NODE_AUTH_TOKEN: x`, or `GH_AUTHTOKEN: x`; each has a parametrized negative case.
3. AC3: `find_npm_token_references` reports `vars.NPM_TOKEN` and `vars['NPM_TOKEN']` with positive cases; `vars.NPM_TOKEN_V2` is a negative case.
4. AC4: A helper reports `NPM_TOKEN` assignments (YAML block, flow, or quoted key; shell `NPM_TOKEN=` including a `$GITHUB_ENV` append; PowerShell `$env:NPM_TOKEN =`), each with a positive case, one fed from a differently named secret.
5. AC5: The assignment helper does not report `${{ secrets.NPM_TOKEN }}`, `${{ env.NPM_TOKEN }}`, `NPM_TOKEN_V2: x`, `MY_NPM_TOKEN: x`, or `# NPM_TOKEN is no longer used`; each has a negative case.
6. AC6: A tree-scan test asserts no `*.yml`/`*.yaml` file under `.github/` has a line reported by any of the four helpers, names offenders as `<relative-posix-path>:<line>`, and passes on the current tree.
7. AC7: Cases `spaced-bracket` and `lowercase-bracket` exist for `find_npm_token_references` and pass.
8. AC8: The module docstring no longer says "tracked files", states disk enumeration through `pathlib` regardless of version control, and names every detected family.
9. AC9: Runbook "Recording completion" step 2 names the pending evidence record, says not to change AC4 status (citing D5), and no longer references `docs/features/active/unused-npm-token-secret-712/` or `issue.md`.
10. AC10: `.github/workflows/publish-mcp-npm.yml` is not modified.
11. AC11: The test module is under 500 lines.
12. AC12: Black, Ruff, and Pyright on the module report no errors, the module pytest passes, and the full suite meets the 85% line and 75% branch thresholds.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 `_authToken` helper and seven positive cases | PASS | `find_npm_auth_token_config_references` (lines 106-119) delegates to `_NPM_AUTH_TOKEN_CONFIG_REFERENCE` with `re.IGNORECASE`. Positive cases (lines 288-317): `npmrc-echo-registry-scoped`, `npmrc-bare-key`, `npm-config-env-upper`, `npm-config-env-lower`, `npm-config-env-registry-scoped`, `npm-config-set-bare`, `npm-config-set-registry-scoped` | `poetry run pytest` on the module (52 passed) | One case per AC1 form |
| 2 | AC2 `_authToken` negative cases | PASS | Lines 331-343: `oidc-permission`, `setup-node-registry-url`, `always-auth`, `node-auth-token-is-separate-family`, `letter-prefixed-name`, plus `empty` | Same run | See code-review CR-3 for the double-underscore behavior |
| 3 | AC3 `vars` context references | PASS | `_NPM_TOKEN_CONTEXT_REFERENCE` (lines 39-42) accepts `secrets` or `vars`. Positive `vars-dot`, `vars-bracket` (lines 201-202); negative `vars-longer-name` (line 230) | Same run | None |
| 4 | AC4 `NPM_TOKEN` assignment helper | PASS | `find_npm_token_assignments` (lines 122-136). Positive cases (lines 357-374): `yaml-env-key-other-secret`, `yaml-flow-mapping`, `quoted-key`, `shell-export`, `github-env-append`, `powershell-env`, `lowercase-key` | Same run | `yaml-env-key-other-secret` feeds the key from `secrets.PUBLISH` |
| 5 | AC5 assignment negative cases | PASS | Lines 388-398: `secrets-dot-context`, `env-context-read`, `longer-name-key`, `prefixed-name-key`, `prose-comment`, plus `empty` | Same run | See code-review CR-2 for the comparison false positive |
| 6 | AC6 tree-scan test over four helpers | PASS | `test_github_yaml_files_contain_no_npm_token_route` (lines 449-492), parametrized over four finders; offender format verified by `test_collect_offenders_names_each_matching_line`; all four nodes pass after #723 merged | Same run; `evidence/qa-gates/ac-node-listing.2026-10-01T20-58.md` | None |
| 7 | AC7 `spaced-bracket` and `lowercase-bracket` | PASS | Lines 199-200 | Same run | None |
| 8 | AC8 module docstring | PASS | Lines 1-23 no longer contain "tracked files"; states files are "enumerated and read from disk through ``pathlib`` only, whether or not version control tracks them"; names all four families | Reviewer read; `evidence/qa-gates/ac8-docstring-check.2026-10-01T20-59.md` | None |
| 9 | AC9 runbook step 2 | PASS | Exactly one line replaced; names `docs/features/completed/unused-npm-token-secret-712/evidence/other/human-action-pending.2026-09-27T09-19.md` (exists, `Status: pending` at line 4); cites D5 (exists in #712 `spec.md`, line 95); no `features/active` or `issue.md` occurrence | `git diff origin/main...HEAD -- docs/features/completed/`; reviewer search of the runbook | None |
| 10 | AC10 `.github/` unmodified | PASS | No output | `git diff --name-only origin/main...HEAD -- .github` | Working tree clean |
| 11 | AC11 under 500 lines | PASS | `492` | `grep -c ""` on the module | None |
| 12 | AC12 toolchain and coverage thresholds | PASS | Black `1 file would be left unchanged.`; Ruff `All checks passed!`; Pyright `0 errors, 0 warnings, 0 informations`; module pytest 52 passed; full suite 6331 passed, 6 skipped (`evidence/qa-gates/final-pytest-coverage.2026-10-01T20-57.md`); 85/75 gate exit 0 (`evidence/qa-gates/final-coverage-thresholds.2026-10-01T20-57.md`); reviewer parse of `artifacts/python/lcov.info`: 93.53% lines, 86.76% branches | Reviewer reruns of Black, Ruff, Pyright, module pytest; full-suite coverage from existing artifacts per the no-rerun rule | None |

---

## Summary

**Overall Feature Readiness:** PASS - 12 of 12 acceptance criteria verified. 0 Blocking findings, 1 Non-blocking finding.

**Criteria summary:**
- **PASS:** 12 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Non-blocking finding:**

- **FA-1** (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, line 208): the positive-case test docstring for `find_npm_token_references` still says "secret reference" after AC3 added `vars` cases. This does not affect any AC verdict. See code-review CR-1.

**Items outside the AC set:**

- `issue.md` "Proposed Fix / Validation Ideas" lists an integration retest (next `mcp-server-v*` release publishes via OIDC) and the operator-owned `NPM_TOKEN` deletion and npm revocation from the #712 runbook. Neither is an acceptance criterion under minor-audit; both remain outside this branch and are noted for follow-up visibility only.
- Research scope exclusions recorded in `issue.md` (no `.npmrc` scan outside `.github/`, no `_auth`/`_password` keys, no `env.` context in `find_npm_token_references`, no edit to the #712 pending record) were respected; reviewer read of the module and the `docs/features/completed/` diff confirms none was added.

**Recommended follow-up verification steps:**

1. Confirm required CI jobs are green once the PR is opened.
2. Optionally address FA-1 / CR-1 and CR-2.

**Total Blocking Count:** 0

---

## Acceptance Criteria Check-off

- AC1 through AC12 are already `[x]` in `issue.md`; the evidence inspected supports each, so no change was needed.
- No AC verdict changed relative to the executor's check-offs, and no source-file edit was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-09-27-npm-token-guard-gaps-739/issue.md` (`## Acceptance Criteria`)
- Total AC items: 12
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 12 | 12 | 0 | Checkbox-backed |
