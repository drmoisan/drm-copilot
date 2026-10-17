# Policy Compliance Audit: npm audit SDK and proxy-addr remediation (#830)

**Audit Date:** 2026-10-07
**Code Under Test:** `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json`, `packages/mcp-server/package.json`, `packages/mcp-server/package-lock.json` (6 JSON files; 69 files changed in total, including feature-folder documentation, evidence, and the promoted lifecycle record)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 0 files | 3825 root, 3808 extension | PASS, 0 fail | root 97.68% statements/lines, 91.15% branches; extension 97.09% lines, 91.37% branches | root 97.68% statements/lines, 91.15% branches; extension 97.09% lines, 91.37% branches | N/A (0 executable lines changed) |
| Python | 0 files | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |
| JSON | 6 files | N/A | validated by `npm audit`, `npm ls`, lockfile diff | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/baseline/root-test-coverage.2026-10-07T15-00.md`, `evidence/baseline/extension-test-coverage.2026-10-07T15-00.md`
- TypeScript post-change coverage artifact: `evidence/qa-gates/root-test-coverage.2026-10-07T16-00.md`, `evidence/qa-gates/extension-test-coverage.2026-10-07T16-00.md`
- PowerShell baseline coverage artifact: N/A - out of scope (0 changed PowerShell files)
- PowerShell post-change coverage artifact: N/A - out of scope (0 changed PowerShell files)
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-10-07T16-15.md` and section 1.2.1 below
- Python, C#: no changed files; no coverage artifact required.

---

## Executive Summary

The branch (base `origin/main` f6ef5b2f, head f744baf0) changes six npm manifest and lockfile files. In all three packages `@modelcontextprotocol/sdk` is raised to `^1.31.0` (root and extension from `^1.30.1`, mcp-server from `^1.29.0`) and the override `"proxy-addr": "^2.0.8"` is added next to the existing `fast-uri` override. Each lockfile now resolves `@modelcontextprotocol/sdk` 1.32.1 and `proxy-addr` 2.0.8; the lockfile diffs contain only those two package entries, the new `funding` block on `proxy-addr`, and the root dependency range line. No `@types/vscode`, `@types/node`, or `typescript-eslint` line appears in the manifest diff, and the lockfile diffs contain no change to those packages. No TypeScript, Python, PowerShell, or C# source file changed, so the per-language coverage gate has no changed file to evaluate; repo-wide TypeScript coverage is unchanged from baseline. Recorded audit evidence shows exit 0 ("found 0 vulnerabilities") in all three packages. The root `format:check` exits 2 at baseline and post-change with identical bodies (pre-existing `tests/fixtures/**` JSON); it is excluded from AC-3 by the issue text, as in #802. PR CI has not run because no PR exists yet.

**Policy documents evaluated:**
- Reviewed: `general-code-change.md` (no source code changed; design, size, and I/O rules not triggered)
- Reviewed: `general-unit-test.md` (no tests added or changed; coverage non-regression verified)
- Reviewed: `quality-tiers.md` (uniform gate matrix)

**Language-specific policies evaluated:**
- TypeScript: toolchain evidence reviewed, no source change
- Python, PowerShell, C#, Bash: 0 changed files
- JSON: manifests and lockfiles validated by lockfile diff inspection and recorded `npm audit` / `npm ls` output

**Temporary artifacts cleanup:**
- No temporary scripts are in the branch diff. `git status --short` shows one untracked file, `evidence/qa-gates/final-push.2026-10-07T16-30.md`, a push-record evidence file created after the final commit; it is not in the branch diff (see Gaps).

## Rejected Scope Narrowing

None. The caller prompt asked for a reduced minor-audit review of the full branch diff and did not narrow scope.

## Evidence Location Compliance

- Scan: `git diff --name-only origin/main...HEAD` filtered for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/` returned no paths.
- `python -m scripts.dev_tools.validate_evidence_locations --root <worktree>` exited 0.
- All evidence lives under `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/evidence/{baseline,qa-gates}/`. Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

No test file changed. The existing suites were executed unchanged (root 254 suites / 3825 tests, extension 251 suites / 3808 tests, all passing at baseline and post-change).

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | Root 97.68% lines / 91.15% branches; extension 97.09% lines / 91.37% branches (`evidence/baseline/*-test-coverage.2026-10-07T15-00.md`) |
| No Coverage Regression | PASS | Post-change equals baseline in both packages, delta 0 (`coverage-delta.2026-10-07T16-15.md`) |
| Repo-wide thresholds (85% lines, 75% branches) | PASS | 97.68 / 91.15 root; 97.09 / 91.37 extension |
| New/Modified File Coverage | N/A | 0 changed source files; manifests and lockfiles have no executable lines |
| Scenario completeness | N/A | No behavior added |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: root 97.68% lines / 91.15% branches, extension 97.09% lines / 91.37% branches -> Post-change: root 97.68% lines / 91.15% branches, extension 97.09% lines / 91.37% branches (identical). Change: 0. Changed-code coverage: N/A, 0 executable lines changed. Disposition: PASS (no regression; repo-wide at or above 85% lines and 75% branches). Evidence: `evidence/qa-gates/coverage-delta.2026-10-07T16-15.md`. Figures come from executor QA records and were not reproduced by this review. A `coverage/lcov.info` artifact was not required because no TypeScript source file is in the branch diff.
- Python, PowerShell, C#: zero changed files on the branch; no verdict required.
- Threshold note: the agent contract Verification Procedure cites 90% new-file and 80% repo-wide, while its threshold section and `.claude/rules/quality-tiers.md` state 85% line / 75% branch. The 85/75 rule was applied; the result is the same under either.

### 1.3-1.5 Diagnostics, Dependencies, Audit Requirement

No tests changed. No external service dependency or temporary file was introduced.

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify objective | PASS | `issue.md` states the objective and AC-1 to AC-3 |
| Document the plan | PASS | `plan.2026-10-07T14-30.md` (all tasks checked) and earlier `plan.2026-10-07T09-57.md` |
| Simplicity first | PASS | Production diff is 6 files, 39 insertions and 24 deletions (`git diff --stat origin/main...HEAD` excluding docs) |
| Scope containment | PASS | `scope-check.2026-10-07T15-30.md`; non-docs diff lists exactly the six JSON files |
| Dependencies | PASS | No dependency added. SDK range raised to the patched release; one override entry added per manifest. No change to `@types/vscode`, `@types/node`, `typescript-eslint` (`protected-deps-manifest-diff.2026-10-07T15-30.md`; lockfile diffs checked directly) |
| Under 500 lines | N/A | No production, test, or script file added; Markdown and JSON exempt |
| Naming, docs | N/A | No code |

### 2.5 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting (extension) | PASS | `extension-format-check.2026-10-07T16-00.md` exit 0 |
| Formatting (root) | PARTIAL | `npm run format:check` exits 2 at baseline (`evidence/baseline/root-format-check.2026-10-07T15-00.md`) and post-change (`evidence/qa-gates/root-format-check.2026-10-07T16-00.md`); `root-format-check-diff.2026-10-07T16-00.md` shows only the Timestamp line differs. Cause: `tests/fixtures/**` JSON. Pre-existing, excluded from AC-3 as in #802, not a regression |
| Linting | PASS | `root-lint` and `extension-lint` exit 0 |
| Type checking | PASS | `root-typecheck` and `extension-typecheck` exit 0 |
| Architecture-boundary / contract / integration | N/A | No source or contract change |
| Unit tests | PASS | Root 3825 and extension 3808 tests pass |
| mcp-server build | PASS | `mcp-server-build.2026-10-07T16-00.md` exit 0 |
| Security audit | PASS | `audit-*.2026-10-07T15-30.md` and `final-audit-*.2026-10-07T16-10.md`, all exit 0 |

---

## 3. Language-Specific Code Change Policy Compliance

- TypeScript (`.claude/rules/typescript.md`): no `.ts` file changed; no suppressions introduced.
- JSON: manifests parse; override placement is consistent with neighbouring entries. PASS.
- Python, PowerShell, C#, Bash: 0 changed files.

## 4. Language-Specific Unit Test Policy Compliance

No test file changed in any language. Existing Jest suites executed unchanged and passing.

## 5. Test Coverage Detail

No function, class, or module under test was added or changed. Post-change TypeScript coverage equals baseline (delta 0).

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Root tests passed | 3825 of 3825 | PASS |
| Extension tests passed | 3808 of 3808 | PASS |
| Code coverage | root 97.68% lines, 91.15% branches; extension 97.09% lines, 91.37% branches | PASS |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Extension format | `npx prettier --check` | exit 0 | PASS |
| Root format | `npm run format:check` | exit 2, identical to baseline (pre-existing fixtures) | PARTIAL (excluded from AC-3) |
| Lint (root, extension) | `npm run lint` | exit 0 | PASS |
| Typecheck (root, extension) | `npm run typecheck` | exit 0 | PASS |
| Audit (3 packages) | `npm audit --audit-level=moderate` | exit 0, 0 vulnerabilities | PASS |

---

## 8. Gaps and Exceptions

### Identified Gaps
- PR CI for head f744baf0 is not available (no PR). The NPM Audit Gate and Publish to Marketplace results are pending CI. Local evidence is recorded; CI is the authority for AC-3.
- Root `format:check` exits 2 on pre-existing fixture JSON. Pre-existing on `main`, unchanged by this branch, excluded from AC-3 by the issue wording.
- `evidence/qa-gates/final-push.2026-10-07T16-30.md` is untracked; it records the push of f744baf0 and should be committed with the review artifacts.
- Stale text in `issue.md`: the Status line names `docs/features/active/npm-audit-mcp-sdk-proxy-addr/`, and the Proposed Fix and Next Step checkboxes are unchecked. These are not acceptance criteria and have no policy consequence.

### Approved Exceptions
None.

### Removed/Skipped Tests
None.

## 9. Summary of Changes

### Files Modified
1. `package.json`, `package-lock.json`: SDK `^1.30.1` to `^1.31.0`; override `proxy-addr` `^2.0.8` added; lockfile resolves SDK 1.32.1 and proxy-addr 2.0.8.
2. `extensions/drm-copilot/package.json`, `package-lock.json`: same changes.
3. `packages/mcp-server/package.json`, `package-lock.json`: SDK `^1.29.0` to `^1.31.0`; override added; same resolved versions.
4. Feature folder plans, issue, and evidence, plus `docs/features/potential/promoted/2026-10-07-npm-audit-mcp-sdk-proxy-addr.md` (NEW).

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

All applicable policy checks for the six-file change are met. The verdict is partial because the root format gate exits non-zero (pre-existing, excluded) and PR CI cannot be verified before a PR exists. Blocking findings attributable to this branch: 0.

### Recommendation

Ready for PR creation. After the PR opens, confirm the three NPM Audit Gate jobs and Publish to Marketplace are green before checking off AC-3.

## Appendix A: Test Inventory

No tests were added or modified (manifest and lockfile-only change). The existing Jest suites were executed unchanged: root 254 suites / 3825 tests passed, extension 251 suites / 3808 tests passed.

## Appendix B: Toolchain Commands Reference

```bash
npx --yes npm@11 audit --audit-level=moderate
npx --yes npm@11 ls @modelcontextprotocol/sdk proxy-addr --all
npx --yes npm@11 run format:check
npx --yes npm@11 run lint
npx --yes npm@11 run typecheck
npx --yes npm@11 run test:unit:coverage
npx --yes npm@11 run build
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-07
