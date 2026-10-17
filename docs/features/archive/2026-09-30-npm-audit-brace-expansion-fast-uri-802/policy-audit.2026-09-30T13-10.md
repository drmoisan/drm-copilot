# Policy Compliance Audit: npm audit override remediation (#802)

**Audit Date:** 2026-09-30
**Code Under Test:** `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json`, `packages/mcp-server/package.json`, `packages/mcp-server/package-lock.json` (6 JSON files; 52 total changed files including feature-folder documentation and evidence)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 0 files | 3332 root, 3315 extension | PASS, 0 fail | root 97.64% lines, 90.96% branches; extension 97.02% lines, 91.17% branches | root 97.64% lines, 90.96% branches; extension 97.02% lines, 91.17% branches | N/A (0 executable lines changed) |
| Python | 0 files | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |
| JSON | 6 files | N/A | validated by `npm ci` and `npm audit` | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/baseline/root-test-coverage.2026-09-30T09-15.md`, `evidence/baseline/extension-test-coverage.2026-09-30T09-20.md`
- TypeScript post-change coverage artifact: `evidence/qa-gates/root-test-coverage.2026-09-30T09-45.md`, `evidence/qa-gates/extension-test-coverage.2026-09-30T09-45.md`
- PowerShell baseline coverage artifact: N/A - out of scope (0 changed PowerShell files)
- PowerShell post-change coverage artifact: N/A - out of scope (0 changed PowerShell files)
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-09-30T09-55.md` and section 1.2.1 below

Templates were read directly from the repository copies under `extensions/drm-copilot/resources/templates/policy_audit/`.

---

## Executive Summary

The branch changes six npm manifest and lockfile JSON files (2 commits over merge-base `6e6ccd62`). It raises the `fast-uri` override to `^3.1.8` in all three packages and raises or adds the `brace-expansion` override at `^5.0.12`. No TypeScript, Python, PowerShell, or C# source file changed, so no language has changed source files and the per-language coverage gate does not apply; repo-wide coverage is reported for context and shows zero delta. The lockfiles resolve `brace-expansion` 5.0.12 (root, extension), `fast-uri` 3.1.8 (all three), and `minimatch` 10.2.5 (root, extension), verified by direct lockfile inspection. Audit evidence shows exit 0 in all three packages. One toolchain gate, the root `format:check`, exits 2 both at baseline and post-change with byte-identical output; the cause is pre-existing fixture JSON and is unrelated to the change set. PR CI status is not available because no PR exists yet.

**Policy documents evaluated:**
- Reviewed: `general-code-change.md` (no source code changed; design, size, and I/O rules not triggered)
- Reviewed: `general-unit-test.md` (no tests added or changed; coverage non-regression verified)
- Reviewed: `quality-tiers.md` (uniform gate matrix)

**Language-specific policies evaluated:**
- TypeScript: toolchain evidence reviewed, no source change
- Python, PowerShell, C#, Bash: N/A, 0 changed files
- JSON: manifests and lockfiles validated by `npm ci` and lockfile inspection

**Temporary artifacts cleanup:**
- No temporary scripts were committed. `git status` shows only the untracked promoted lifecycle record `docs/features/potential/promoted/2026-09-30-npm-audit-brace-expansion-fast-uri.md`, which is not part of the branch diff.

## Rejected Scope Narrowing

None. The caller prompt did not narrow scope.

## Evidence Location Compliance

- Scan: `git diff --name-only 6e6ccd62 HEAD` filtered for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/` returned no paths.
- `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` exited 0.
- All evidence lives under `docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/evidence/{baseline,qa-gates}/`. Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

No test file changed. Independence, isolation, determinism, and readability are N/A for this diff; the existing suites were executed unchanged (root 239 suites / 3332 tests, extension 236 suites / 3315 tests, all passing).

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | Root 97.64% lines / 90.96% branches; extension 97.02% lines / 91.17% branches (`evidence/baseline/*-test-coverage.*.md`) |
| No Coverage Regression | PASS | Post-change equals baseline in both packages, delta 0 (`coverage-delta.2026-09-30T09-55.md`) |
| New/Modified File Coverage | N/A | 0 changed source files; manifests and lockfiles have no executable lines |
| Scenario completeness | N/A | No behavior added |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: root 97.64% lines / 90.96% branches, extension 97.02% lines / 91.17% branches -> Post-change: identical. Change: 0. New/changed-code coverage: N/A, 0 executable lines changed. Disposition: PASS (repo-wide at or above 85% lines and 75% branches). Evidence: `evidence/qa-gates/coverage-delta.2026-09-30T09-55.md`.
- Coverage artifact note: `coverage/lcov.info` is absent from the worktree (only `coverage/clover.xml` exists), and `artifacts/python/lcov.info` and the Pester artifacts exist from other runs. Because no TypeScript, Python, or PowerShell source file is in the branch diff, artifact absence does not trigger the mandatory-coverage FAIL. Repo-wide TypeScript figures were taken from executor QA records; the figures were not independently reproduced by this review.
- Threshold note: the agent contract Verification Procedure cites 90% new-file and 80% repo-wide, while its threshold section and `.claude/rules/quality-tiers.md` state 85% line / 75% branch. The 85/75 rule was applied. The result is the same under either.

### 1.3-1.5 Diagnostics, Dependencies, Audit Requirement

N/A for test structure (no tests changed). No external service dependency or temporary file was introduced. This audit serves as the pre-submission review.

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify objective | PASS | `issue.md` states the objective and three acceptance criteria |
| Document the plan | PASS | `plan.2026-09-30T13-00.md` and earlier `plan.2026-09-30T08-50.md` |
| Simplicity first | PASS | Six-file change limited to override values; `git diff` shows 22 insertions and 21 deletions |
| Scope containment | PASS | `scope-check.2026-09-30T09-40.md`; `git diff --name-status` outside `docs/features` lists exactly six JSON files |
| Dependencies | PASS | No dependency added; override ranges only. `brace-expansion` override added to `packages/mcp-server/package.json`, where the lockfile has no `brace-expansion` entry, so the override is precautionary and inert |
| Under 500 lines | N/A | No production, test, or script file added; Markdown and JSON exempt |
| Naming, docs | N/A | No code |

### 2.5 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting (extension) | PASS | `extension-format-check` exit 0 |
| Formatting (root) | PARTIAL | `npm run format:check` exits 2 at baseline (`evidence/baseline/root-format-check.2026-09-30T09-10.md`) and post-change (`evidence/qa-gates/root-format-check.2026-09-30T09-45.md`) with byte-identical output. Cause: `tests/fixtures/**` JSON, including a deliberately invalid JSON fixture. No file in this change set is reported. Pre-existing, not a regression |
| Linting | PASS | `root-lint` and `extension-lint` exit 0 |
| Type checking | PASS | `root-typecheck` and `extension-typecheck` exit 0 |
| Architecture-boundary / contract / integration | N/A | No source or contract change |
| Unit tests | PASS | Root 3332 and extension 3315 tests pass |
| mcp-server build | PASS | `mcp-server-build.2026-09-30T09-45.md` exit 0 |
| Security audit | PASS | `audit-*.2026-09-30T09-35.md` and `final-audit-*.2026-09-30T09-50.md`, all exit 0 |

The plan task P2-T1 is correctly left unchecked by the executor because of the root format-check exit code.

---

## 3. Language-Specific Code Change Policy Compliance

- TypeScript (`.claude/rules/typescript.md`): no `.ts` file changed; no suppressions introduced. N/A for design and typing rules.
- JSON: four-space or repository-standard formatting preserved; manifests parse and `npm ci` succeeded (`lock-*.2026-09-30T09-30.md`). Key order in `overrides` was not reordered beyond the value edits. PASS.
- Python, PowerShell, C#, Bash: 0 changed files. N/A.

## 4. Language-Specific Unit Test Policy Compliance

No test file changed in any language. TypeScript unit-test policy: existing Jest suites executed unchanged and passing (root 3332, extension 3315). Python, PowerShell, C#: N/A, 0 changed files.

## 5. Test Coverage Detail

No function, class, or module under test was added or changed. Post-change TypeScript coverage: root 97.64% lines, 90.96% branches; extension 97.02% lines, 91.17% branches; delta 0 against baseline.

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Root tests passed | 3332 of 3332 | PASS |
| Extension tests passed | 3315 of 3315 | PASS |
| Execution time | about 7.7s root, 7.5s extension | Fast |
| Code coverage | root 97.64% lines, 90.96% branches | PASS |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Extension format | `npx prettier --check` | exit 0 | PASS |
| Root format | `npm run format:check` | exit 2, identical to baseline (pre-existing fixtures) | PARTIAL |
| Lint (root, extension) | `npm run lint` | exit 0 | PASS |
| Typecheck (root, extension) | `npm run typecheck` | exit 0 | PASS |

**Notes:** The root format failure is pre-existing and unrelated to this work.

---

## 8. Gaps and Exceptions

### Identified Gaps
- Root `format:check` exits 2 on pre-existing fixture JSON (uniform gate "Format check: 100% pass" is not met at the repository level). Pre-existing on `main`, unchanged by this branch; recommend a separate issue. Not attributed to this change.
- PR CI for the head commit is not available (no PR). The NPM Audit Gate result in CI is therefore unverified; local `npm audit` evidence exits 0.

### Approved Exceptions
**None.**

### Removed/Skipped Tests
**None.**

## 9. Summary of Changes

### Commits in This PR/Branch
1. **013b6917** - fix(deps): raise fast-uri and brace-expansion overrides to patched versions (#802)
2. **c22849de** - docs(802): record commit and push evidence and plan progress

### Files Modified
1. `package.json`, `package-lock.json` (MODIFIED): `fast-uri` ^3.1.4 to ^3.1.8; `brace-expansion` ^5.0.8 to ^5.0.12; lockfile resolves 3.1.8 and 5.0.12.
2. `extensions/drm-copilot/package.json`, `package-lock.json` (MODIFIED): same override changes.
3. `packages/mcp-server/package.json`, `package-lock.json` (MODIFIED): `fast-uri` raised; `brace-expansion` override added.
4. Feature folder documentation and evidence (NEW, 46 files).

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

All applicable policy checks for the six-file change are met. The overall verdict is partial rather than full because the root format gate exits non-zero (pre-existing) and PR CI cannot be verified before a PR exists. No blocking finding is attributable to this branch.

### Metrics Summary

- 3332/3332 root tests and 3315/3315 extension tests passing
- Line coverage 97.64% (root) and 97.02% (extension); branch coverage 90.96% and 91.17%; delta 0
- Audit exit 0 in all three packages
- Evidence location scan clean

### Recommendation

**Ready for PR creation.** Open a PR and confirm the NPM Audit Gate and required CI jobs are green. File a separate issue for the pre-existing root `format:check` fixture failure.

## Appendix A: Test Inventory

No tests were added or changed. The existing Jest suites (root 239 suites, extension 236 suites) were executed unchanged.

## Appendix B: Toolchain Commands Reference

```bash
npx --yes npm@11 ci
npx --yes npm@11 audit --audit-level=moderate
npx --yes npm@11 run format:check
npx --yes npm@11 run lint
npx --yes npm@11 run typecheck
npx --yes npm@11 run test:unit:coverage
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-30
**Policy Version:** Current (as of audit date)
