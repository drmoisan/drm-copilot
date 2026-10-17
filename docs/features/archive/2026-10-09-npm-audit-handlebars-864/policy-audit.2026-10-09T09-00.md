# Policy Compliance Audit: npm audit handlebars remediation (#864)

**Audit Date:** 2026-10-09
**Code Under Test:** `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json` (4 JSON files; all other changes are feature-folder documentation and evidence)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 0 files | 3923 root, 3906 extension | PASS, 0 fail | root 97.76% statements/lines, 91.42% branches; extension 97.16% lines, 91.66% branches | root 97.76% statements/lines, 91.42% branches; extension 97.16% lines, 91.66% branches | N/A (0 executable lines changed) |
| Python | 0 files | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |
| JSON | 4 files | N/A | validated by `npm audit`, `npm ls`, lockfile diff | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/baseline/root-test-coverage.2026-10-09T08-24.md`, `evidence/baseline/extension-test-coverage.2026-10-09T08-26.md`
- TypeScript post-change coverage artifact: `evidence/qa-gates/root-test-coverage.2026-10-09T08-44.md`, `evidence/qa-gates/extension-test-coverage.2026-10-09T08-44.md`
- PowerShell baseline coverage artifact: N/A - out of scope (0 changed PowerShell files)
- PowerShell post-change coverage artifact: N/A - out of scope (0 changed PowerShell files)
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-10-09T08-48.md` and section 1.2.1 below
- Python, C#: no changed files; no coverage artifact required.

---

## Executive Summary

The branch (base `origin/main` e7d3779b, head 86829312) changes four npm manifest and lockfile files. The override `"handlebars": "^4.7.10"` is added to `overrides` in the root and extension manifests. Both lockfiles resolve `handlebars` 4.7.10 (previously 4.7.9) and update handlebars' own declared `minimist` range (^1.2.5 to ^1.2.8); no other package version changes. `packages/mcp-server` is untouched. No TypeScript, Python, PowerShell, or C# source file changed, so the per-language coverage gate has no changed file to evaluate; repo-wide TypeScript coverage is unchanged from baseline. Recorded evidence shows exit 0 with 0 vulnerabilities in root, extension, and packages/mcp-server. The root `format:check` fails at baseline and post-change on pre-existing `tests/fixtures` JSON; it is excluded from AC-3 by the issue text (#802, #848). PR CI has not run because no PR exists yet.

**Policy documents evaluated:**
- Reviewed: `general-code-change.md` (no source code changed; design, size, and I/O rules not triggered)
- Reviewed: `general-unit-test.md` (no tests added or changed; coverage non-regression verified)
- Reviewed: `quality-tiers.md` (uniform gate matrix)

**Language-specific policies evaluated:**
- TypeScript: toolchain evidence reviewed, no source change
- Python, PowerShell, C#, Bash: 0 changed files
- JSON: manifests and lockfiles validated by lockfile diff inspection and recorded `npm audit` / `npm ls` output

**Temporary artifacts cleanup:**
- No temporary scripts are in the branch diff.

## Rejected Scope Narrowing

None detected. The caller's exclusion of the pre-existing root `format:check` failure (tests/fixtures JSON, #802/#848) and of PR-CI status is an AC-3 definition carried in `issue.md`, not a narrowing of audit scope; it is evaluated as written.

## Evidence Location Compliance

- Scan: `git diff --name-only origin/main...HEAD` filtered for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/` returned no paths.
- `validate_evidence_locations.py` was not run (check-only review; the diff path scan above was performed instead, zero matches).
- All evidence lives under `docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/{baseline,qa-gates}/`. Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

No test file changed. The existing suites were executed unchanged (root 3923 tests, extension 3906 tests, all passing at baseline and post-change).

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | Root 97.76% lines / 91.42% branches; extension 97.16% lines / 91.66% branches (`evidence/baseline/root-test-coverage.2026-10-09T08-24.md`, `evidence/baseline/extension-test-coverage.2026-10-09T08-26.md`) |
| No Coverage Regression | PASS | Post-change equals baseline in both packages, delta 0 (`coverage-delta.2026-10-09T08-48.md`) |
| Repo-wide thresholds (85% lines, 75% branches) | PASS | 97.76 / 91.42 root; 97.16 / 91.66 extension |
| New/Modified File Coverage | N/A | 0 changed source files; manifests and lockfiles have no executable lines |
| Scenario completeness | N/A | No behavior added |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: root 97.76% lines / 91.42% branches, extension 97.16% lines / 91.66% branches -> Post-change: root 97.76% lines / 91.42% branches, extension 97.16% lines / 91.66% branches (identical). Change: 0. Changed-code coverage: N/A, 0 executable lines changed. Disposition: PASS (no regression; repo-wide at or above 85% lines and 75% branches). Evidence: `evidence/qa-gates/coverage-delta.2026-10-09T08-48.md`. The coverage artifact is the captured evidence log; `coverage/lcov.info` is not committed and was not required because no TypeScript source file is in the branch diff. Figures were read from the logs and not reproduced by this review.
- Python, PowerShell, C#: zero changed files on the branch; no verdict required.

### 1.3-1.5 Diagnostics, Dependencies, Audit Requirement

No tests changed. No external service dependency or temporary file was introduced.

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify objective | PASS | `issue.md` states the objective and AC-1 to AC-3 |
| Document the plan | PASS | `plan.2026-10-09T08-05.md` |
| Simplicity first | PASS | Production diff is 4 JSON files (+10/-8 lines) |
| Scope containment | PASS | `evidence/qa-gates/scope-check.2026-10-09T08-34.md`; non-docs diff lists exactly the four package files; `packages/mcp-server` untouched |
| Dependencies | PASS | Only an `overrides` entry is added. Lockfile diff changes handlebars 4.7.9 -> 4.7.10 plus handlebars' own `minimist` range; no other package version changes (`manifest-diff.2026-10-09T08-32.md`) |
| Under 500 lines | PASS | No production, test, or script file added; Markdown and JSON exempt |
| Naming, docs | N/A | No code |
| Coverage exclusion policy | PASS | No jest config or exclude entry changed |

### 2.5 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting (extension) | PASS | `extension-format-check.2026-10-09T08-44.md` exit 0 |
| Formatting (root) | PARTIAL | `root-format-check.2026-10-09T08-44.md` fails only on pre-existing `tests/fixtures` JSON (baseline: `evidence/baseline/root-format-check.2026-10-09T08-20.md`). Excluded from AC-3 per #802 / #848, not a regression |
| Linting | PASS | `root-lint` and `extension-lint` exit 0 |
| Type checking | PASS | `root-typecheck` and `extension-typecheck` exit 0 |
| Architecture-boundary / contract / integration | N/A | No source, API, or schema file changed |
| Unit tests | PASS | Root 3923 and extension 3906 tests pass |
| Security audit | PASS | `final-audit-root`, `final-audit-extension`, `final-audit-mcp-server` (2026-10-09T08-46): exit 0, 0 vulnerabilities |

---

## 3. Language-Specific Code Change Policy Compliance

- TypeScript (`.claude/rules/typescript.md`): no `.ts` file changed; no suppressions introduced.
- JSON: manifests parse; override placement is consistent with neighbouring entries and precedents #802/#831. PASS.
- Python, PowerShell, C#, Bash: 0 changed files.

## 4. Language-Specific Unit Test Policy Compliance

No test file changed in any language. Existing Jest suites executed unchanged and passing.

## 5. Test Coverage Detail

No function, class, or module under test was added or changed. Post-change TypeScript coverage equals baseline (delta 0).

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Root tests passed | 3923 of 3923 | PASS |
| Extension tests passed | 3906 of 3906 | PASS |
| Code coverage | root 97.76% lines, 91.42% branches; extension 97.16% lines, 91.66% branches | PASS |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Extension format | `npm run format:check` | exit 0 | PASS |
| Root format | `npm run format:check` | fails on pre-existing fixtures, same as baseline | PARTIAL (excluded from AC-3) |
| Lint (root, extension) | `npm run lint` | exit 0 | PASS |
| Typecheck (root, extension) | `npm run typecheck` | exit 0 | PASS |
| Audit (3 packages) | `npm audit --audit-level=moderate` | exit 0, 0 vulnerabilities | PASS |

---

## 8. Gaps and Exceptions

### Identified Gaps
- PR CI is not available (no PR exists yet). The NPM Audit Gate and Publish to Marketplace results are pending CI. Local evidence is recorded; CI is the authority for AC-3.
- Root `format:check` fails on pre-existing fixture JSON. Pre-existing on `main`, unchanged by this branch, excluded from AC-3 by the issue wording.

### Approved Exceptions
None.

### Removed/Skipped Tests
None.

## 9. Summary of Changes

### Files Modified
1. `package.json`, `package-lock.json`: override `"handlebars": "^4.7.10"` added; lockfile resolves handlebars 4.7.10.
2. `extensions/drm-copilot/package.json`, `package-lock.json`: same changes.
3. Feature folder plan, issue, and evidence.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

All applicable policy checks for the four-file change are met. The verdict is partial because the root format gate fails on pre-existing fixture JSON (excluded) and PR CI cannot be verified before a PR exists. blocking_count: 0 (FAIL: 0; blocking PARTIAL: 0).

### Recommendation

Ready for PR creation. After the PR opens, confirm the three NPM Audit Gate jobs and Publish to Marketplace are green before checking off AC-3.

## Appendix A: Test Inventory

No tests were added or modified (manifest and lockfile-only change). The existing Jest suites were executed unchanged: root 3923 tests passed, extension 3906 tests passed.

## Appendix B: Toolchain Commands Reference

```bash
npm audit --audit-level=moderate
npm ls handlebars --all
npm run format:check
npm run lint
npm run typecheck
npm run test:unit:coverage
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-09
