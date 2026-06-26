# Policy Compliance Audit: F8 ts-new-active-feature-folder (Issue #240)

**Audit Date:** 2026-06-26
**Code Under Test:** TypeScript only. New: `extensions/drm-copilot/src/lib/new-active-feature-folder/{models,markdown,io,docs,flow,index,new-active-feature-folder-service-call}.ts`. Modified: `extensions/drm-copilot/src/repo-automation-service.ts`. New/updated tests under `extensions/drm-copilot/test/**`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 8 production (.ts) + 11 test (.ts) | 999 tests / 85 suites | ✅ 999 pass, 0 fail | 97.36% lines, 87.55% branch (`src/lib/**`, executor `f8-ts-test-baseline.md`) | 97.73% lines, 88.29% branch (`src/lib/**`) | 97.36%–100% lines, 83.33%–100% branch |

**Note:** Python, PowerShell, and C# have zero changed files in the branch diff; coverage verdict for those languages is `N/A — zero changed files` (an acceptable verdict only because they have no changed files on the branch). TypeScript is the only language with changed files; its coverage verdict is explicit `PASS` (see Section 1.2).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/f8-ts-test-baseline.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/f8-final-test-coverage.md` (independently re-verified by reviewer via `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`)
- PowerShell baseline coverage artifact: `N/A — zero changed files`
- PowerShell post-change coverage artifact: `N/A — zero changed files`
- Per-language comparison summary: Section 1.2.1 and `evidence/qa-gates/f8-coverage-delta.md`

**Non-negotiable verdict rule:** Numeric baseline and post-change coverage are present for the only in-scope language (TypeScript).

**Fail-closed rule:** This audit's overall verdict is NON-COMPLIANT due to a file-size policy violation (`io.ts` = 542 lines), not a missing-evidence condition. See Section 8 and the Compliance Verdict.

---

## Executive Summary

F8 ports the Python `new_active_feature_folder` cluster to in-process TypeScript under `extensions/drm-copilot/src/lib/new-active-feature-folder/**` and rewires `RepoAutomationService.newActiveFeatureFolder()` to call the in-process helper instead of spawning Python. The reviewer independently ran the TypeScript toolchain (format, lint, typecheck, full test suite with coverage) and verified file sizes by `wc -l`.

Toolchain result: format clean, lint 0 errors, typecheck 0 errors, 999/999 tests pass across 85 suites, coverage well above policy thresholds for all new files.

One **Blocking** policy violation was found by direct line count: `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` is **542 lines**, exceeding the repository hard limit of 500 lines (`.claude/rules/general-code-change.md`, "File Size Limit"). The F8 plan itself (Split Strategy, line 55; task P2-T1 acceptance) mandated a contingent split of the VS Code launcher seam into `io-launcher.ts` if `io.ts` exceeded 500 lines. The split was not performed. AC-F8-10 ("No file exceeds 500 lines") and AC-F8-3/P2-T1 acceptance ("file < 500 lines") are therefore not satisfied. This is a code-defect-level violation, not a policy-reconciliation item.

The Jest-vs-Vitest divergence is recorded as accepted decision D1 in `spec.md` and is a Major policy-reconciliation item (policy text vs package toolchain), not a per-feature blocker.

**Policy documents evaluated:**
- ✅ `general-code-change.md`
- ✅ `general-unit-test.md`
- ✅ `quality-tiers.md`
- ✅ `typescript.md` + `typescript-suppressions.md`
- ✅ `architecture-boundaries.md`
- ✅ `tonality.md`

**Language-specific policies evaluated:**
- N/A `python-*` — zero changed Python files
- N/A `powershell-*` — zero changed PowerShell files
- ✅ TypeScript `typescript.md` + `typescript-suppressions.md`
- N/A C# — zero changed C# files

**Temporary artifacts cleanup:**
- ✅ No temporary/throwaway scripts were introduced by this feature.
- ✅ No ongoing tooling scripts added.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow scope to a plan, task, phase, or file subset, and no instruction attempted to mark any language's coverage as out of scope or informational only. The caller correctly instructed the reviewer to determine scope per the SKILL invariant and to treat the appendix git name-status / direct `git diff` as authoritative over the misclassifying summary. The reviewer used `git diff --name-status c432b69...HEAD` as the authoritative scope source. No rejection required.

---

## Evidence Location Compliance

The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, or `artifacts/regression-testing/`.

- `git diff --name-only c432b69...HEAD | grep -E '...non-canonical evidence paths...'` → no matches.
- `python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0 (no violations).

All F8 evidence artifacts are written under the canonical `<FEATURE>/evidence/<kind>/` scheme (`evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`). **PASS — no evidence-location violations.** No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred.

---

## modified-workflow-needs-green-run

The branch diff modifies no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (verified by `git diff --name-only` filter — no matches). The rule does not fire. No green-run evidence is required.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Tests use per-test `Map`-backed `FolderFileSystem` fakes and fresh fakes (`test/lib/new-active-feature-folder/fakes.ts`); no shared mutable state. 999/999 pass in a single run. |
| **Isolation** | ✅ PASS | One behavior per `it(...)`; modules tested in dedicated files mirroring source (`models.test.ts`, `markdown.test.ts`, `io.test.ts`, `docs.test.ts`, `flow.test.ts`, `new-active-feature-folder-service-call.test.ts`). |
| **Fast Execution** | ✅ PASS | Full suite runtime 2.507s for 999 tests (reviewer `node run-jest.cjs --coverage`). |
| **Determinism** | ✅ PASS | Injected `nowProvider` clock seam, injected `gh`/env/which lookups, injected `CommandRunner`, no real subprocess/PATH/env/temp files. |
| **Readability & Maintainability** | ✅ PASS | AAA structure; descriptive `it(...)` titles mapping to parity scenarios. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/f8-ts-test-baseline.md` (executor, pre-change). |
| **No Coverage Regression** | ✅ PASS | Post-change `src/lib/**`: 97.73% lines / 88.29% branch (reviewer re-run). `evidence/qa-gates/f8-coverage-delta.md` records no regression on overall `src/lib/**`. |
| **New Code Coverage** | ✅ PASS | New cluster files: `models.ts` 97.36% line / 83.33% branch; `markdown.ts` 100% / 93.1%; `io.ts` 98.89% / 88.88%; `docs.ts` 100% / 100%; `flow.ts` 99.54% / 92.1%; `new-active-feature-folder-service-call.ts` 100% / 100%. All exceed line >= 85% and branch >= 75%. `index.ts` is a re-export-only facade (100% line; 10.34% function is the re-export case documented per `.claude/rules/general-unit-test.md`). |
| **Comprehensive Coverage** | ✅ PASS | Positive, negative, edge, and error scenarios covered per the cluster module test files. |
| **Positive / Negative / Edge / Error Flows** | ✅ PASS | e.g. `validateFeatureName` accepts kebab/underscore and throws byte-identical message; `defaultIssueFetcher` returns null on missing gh/non-zero/blank/parse-fail; `setSection`/`updateSectionBody` backslash-preservation regressions covered. |
| **Concurrency / State Transitions** | N/A | Not applicable to pure transform + filesystem-seam logic. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.36% lines / 87.55% branch (`src/lib/**`). Post-change: 97.73% lines / 88.29% branch (`src/lib/**`). Change: +0.37% lines / +0.74% branch (no regression). New/changed-code coverage: 97.36% to 100% lines / 83.33% to 100% branch across the cluster. Disposition: PASS. Evidence: `evidence/qa-gates/f8-final-test-coverage.md`, `evidence/qa-gates/f8-coverage-delta.md`, and reviewer re-run of `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`.
- Python: `N/A — zero changed files`.
- PowerShell: `N/A — zero changed files`.
- C#: `N/A — zero changed files`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `@jest/globals` `expect` assertions with specific expected values (byte-identical strings, ordered call sequences). |
| **Arrange-Act-Assert** | ✅ PASS | Tests follow AAA per plan tasks P1-T2…P4-T2. |
| **Document Intent** | ✅ PASS | Descriptive test names mirror Python parity scenarios. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No real `gh`, `git`, `code`, network, or temp files; all seams injected. |
| **Use Mocks/Stubs** | ✅ PASS | `Map`-backed `FolderFileSystem` fake, fake `CommandRunner`, fake `gh`/env/which lookups, fixed `nowProvider`. |
| **Environment Stability** | ✅ PASS | Deterministic `America/New_York` formatting via `Intl.DateTimeFormat`; no host-timezone dependence; no temp files (general-unit-test policy). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit plus `code-review.2026-06-26T05-25.md` and `feature-audit.2026-06-26T05-25.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Plan `F8-new-active-feature-folder.plan.md` references issue #240, inventory, and spec.md epic AC. |
| **Read existing change plans** | ✅ PASS | Phase 0 P0-T1/P0-T2 evidence in `evidence/baseline/f8-phase0-instructions-read.md`. |
| **Document the plan** | ✅ PASS | Detailed atomic plan with phase tasks and AC checklist. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Direct port preserving Python control flow; pure helpers separated from I/O. |
| **Reusability** | ✅ PASS | Reuses F1 `CommandRunner`/`SubprocessRunner`, `toPosixPath`, `normalizeRequestedWorkMode`; mirrors F2/F5/F6/F7 service-call precedents. |
| **Extensibility** | ✅ PASS | Options-object `createActiveFolder` with injectable seams (fs, fetcher, launcher, clock, env/which). |
| **Separation of concerns** | ✅ PASS | Pure logic (`models`, `markdown`) separated from I/O (`io`, `RealFolderFileSystem`) and service wiring (`new-active-feature-folder-service-call`). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Seven cluster files split by responsibility per the plan Split Strategy. |
| **Under 500 lines** | ❌ FAIL | `io.ts` = **542 lines** (`wc -l`), exceeding the 500-line hard limit. All other files within limit: `docs.ts` 350, `flow.ts` 438, `index.ts` 50, `markdown.ts` 437, `models.ts` 379, `new-active-feature-folder-service-call.ts` 134, `repo-automation-service.ts` 499. The plan-mandated `io-launcher.ts` split was not performed. **Blocking finding.** |
| **Public vs internal** | ✅ PASS | `index.ts` facade re-exports the public surface; private helpers kept module-local. |
| **No circular dependencies** | ✅ PASS | Lint (includes import plugin) passed with 0 errors; facade is leaf re-export. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | camelCase functions, PascalCase types, kebab-case filenames. |
| **Docs/docstrings** | ✅ PASS | Module and function docstrings present (e.g. `getEstTimestamp` documents the clock seam and the naive-datetime divergence; `index.ts` documents the facade). |
| **Comment why, not what** | ✅ PASS | Branch/decision comments and parity notes present. |

### 2.5 After Making Changes — Toolchain Execution (reviewer-independent)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `npx prettier --check` on all changed src/test files → "All matched files use Prettier code style!" |
| **2. Linting** | ✅ PASS | `npm run lint` (`eslint src test`) → 0 errors, 0 warnings. |
| **3. Type checking** | ✅ PASS | `npm run typecheck` (`tsc -p ./ --noEmit`) → 0 errors. |
| **4. Testing** | ✅ PASS | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` → 999 pass / 0 fail / 85 suites. |
| **Full toolchain loop** | ✅ PASS | All stages green in a single reviewer pass. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded here and in `evidence/qa-gates/**`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Plan and evidence artifacts summarize the port. |
| **Design choices explained** | ✅ PASS | Parity notes, D1 divergence, naive-datetime divergence documented. |
| **Update supporting documents** | ✅ PASS | spec.md records D1; plan AC checklist maintained. |
| **Provide next steps** | ⚠️ PARTIAL | Remediation required for the `io.ts` size violation (see Section 8 and remediation-inputs). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3 (TypeScript)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting (Prettier)** | ✅ PASS | `npx prettier --check` clean on changed files. |
| **Linting (ESLint)** | ✅ PASS | `npm run lint` 0 errors. |
| **Type checking (TSC)** | ✅ PASS | `npm run typecheck` 0 errors. |
| **Strong typing / no `any`** | ✅ PASS | `grep` for `: any` / `as any` / `<any>` in the cluster found only documentation-comment hits (the literal text `Date.now()` and a Python-mirror comment), no actual `any` types. |
| **No banned `Date.now()` outside clock seam** | ✅ PASS | `grep "Date.now()"` in the cluster returns only a docstring in `models.ts` explaining the clock-seam rule; no executable `Date.now()` call. The injected `nowProvider` is the single allowed wall-clock seam. |
| **ES modules** | ✅ PASS | `import`/`export` only; no `require`/`module.exports`. |
| **Suppressions** | ✅ PASS | No new `eslint-disable` / `@ts-expect-error` / `@ts-ignore` introduced (lint clean; no suppression directives needed). |
| **File size <= 500 lines** | ❌ FAIL | `io.ts` = 542 lines. See Section 2.3. |

**Jest vs Vitest (D1):** `.claude/rules/typescript.md` step 4 mandates Vitest, but `extensions/drm-copilot/` uses Jest package-wide. Recorded as accepted decision D1 in `spec.md` and as a Major policy-reconciliation item (policy text vs package toolchain), not a per-feature blocker, consistent with prior F1–F7 reviews.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4 (TypeScript / Jest)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Test framework** | ✅ PASS (with D1) | Jest via `node run-jest.cjs`; `@jest/globals`. D1 reconciliation noted. |
| **Test file location mirrors source** | ✅ PASS | Tests live under `extensions/drm-copilot/test/lib/new-active-feature-folder/` mirroring `src/lib/new-active-feature-folder/`; no colocation in `src/`. |
| **Coverage thresholds** | ✅ PASS | All new executable files line >= 85%, branch >= 75%. |
| **Hermetic** | ✅ PASS | No real subprocess/PATH/env/temp files. |
| **AAA / one behavior per test** | ✅ PASS | Per plan tasks. |

---

## 5. Test Coverage Detail

### new-active-feature-folder cluster (per-file, reviewer re-run)

| Module | Line % | Branch % | Status |
|--------|--------|----------|--------|
| `models.ts` | 97.36% | 83.33% | ✅ |
| `markdown.ts` | 100% | 93.1% | ✅ |
| `io.ts` | 98.89% | 88.88% | ✅ |
| `docs.ts` | 100% | 100% | ✅ |
| `flow.ts` | 99.54% | 92.1% | ✅ |
| `new-active-feature-folder-service-call.ts` | 100% | 100% | ✅ |
| `index.ts` | 100% line (10.34% funcs; re-export-only facade per general-unit-test policy) | n/a | ✅ |

All executable cluster files exceed the uniform thresholds (line >= 85%, branch >= 75%). Untested residual lines are minor (e.g. `flow.ts:358-359`, `io.ts:66-67,435-438`, `models.ts` Real* adapter edge lines) and do not represent untested critical behavior.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 999 | ✅ |
| Tests Passed | 999 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 2.507s total | ✅ Fast |
| Test Suites | 85 passed / 85 | ✅ |
| Code Coverage (`src/lib/**`) | 97.73% lines, 88.29% branch | ✅ |

---

## 7. Code Quality Checks (TypeScript)

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check <changed files>` | All matched files formatted | ✅ |
| ESLint | `npm run lint` | 0 errors | ✅ |
| TSC | `npm run typecheck` | 0 errors | ✅ |
| Jest (coverage) | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` | 999 pass / 0 fail | ✅ |
| File size | `wc -l src/lib/new-active-feature-folder/*.ts src/repo-automation-service.ts` | `io.ts` 542 > 500 | ❌ |

---

## 8. Gaps and Exceptions

### Identified Gaps

- **File Size Limit (`io.ts` = 542 lines)** — Blocking. `.claude/rules/general-code-change.md` sets a hard 500-line limit for production code with no applicable exception (the exceptions are throwaway scripts, raw text fixtures, and Markdown). The F8 plan Split Strategy (line 55) and P2-T1 acceptance ("file < 500 lines") explicitly required extracting the VS Code launcher seam into `io-launcher.ts` and re-exporting if `io.ts` exceeded 500 lines; that contingent split was not performed. Remediation: extract the launcher seam (`INSIDERS_SIGNAL_NAMES`/`isInsidersSession`/`resolveCodeCli`/`defaultCodeLauncher` and supporting helpers) into `extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts`, re-export from `io.ts`, and re-run the toolchain so both files are < 500 lines.

### Approved Exceptions

- **D1 (Jest vs Vitest):** Accepted divergence recorded in `spec.md`. Major policy-reconciliation item, not a per-feature defect.
- **Naive-datetime divergence in `getEstTimestamp`:** Documented intentional divergence (a TS `Date` carries no naive form; the Python `ValueError` path has no TS analogue). Acceptable; documented in `models.ts` and `evidence/regression-testing/f8-port-parity.md`.

### Removed/Skipped Tests

- The Python-runtime-required extension case was intentionally inverted (per P4-T4) to assert success without Python; this is a deliberate behavior change, not a coverage loss.

---

## 9. Summary of Changes

### Files in this branch (vs merge-base `c432b69`)

Production TypeScript (new): `src/lib/new-active-feature-folder/{models,markdown,io,docs,flow,index,new-active-feature-folder-service-call}.ts`.
Production TypeScript (modified): `src/repo-automation-service.ts` (`newActiveFeatureFolder` delegation + import swap; 499 lines).
Tests (new): `test/extension.new-active-feature-folder-inprocess.test.ts`, `test/lib/new-active-feature-folder/{docs,flow,io,markdown,models,new-active-feature-folder-service-call}.test.ts`, `test/lib/new-active-feature-folder/fakes.ts`, `test/new-active-feature-folder-fs-harness.ts`.
Tests (modified): `test/extension.new-active-feature-folder.test.ts`, `test/extension.workflow-commands.test.ts`.
Docs/evidence (new): the F8 plan and `evidence/{baseline,qa-gates,regression-testing}/**` artifacts.

No Python, PowerShell, or C# source changed. `command-runtime.ts`, `executeScript`, the `"python"` branch, `repo-automation-args.ts`, and the F1 shared interfaces are untouched.

---

## 10. Compliance Verdict

### Overall Status: ❌ NON-COMPLIANT

The implementation quality is high and the toolchain is fully green, but a hard file-size policy limit is violated: `io.ts` is 542 lines against a 500-line maximum. This is a Blocking, code-defect-level finding that the plan itself anticipated and required to be avoided via a contingent split. It must be remediated before merge.

**Fail-closed reminder:** Verdict is not PASS while a Blocking policy violation remains open.

### Policy-by-Policy Summary

- ⚠️ General Code Change — Module & File Structure: FAIL (`io.ts` 542 lines); all other subsections PASS.
- ✅ General Unit Test Policy: PASS.
- ✅ Language-Specific Code Change (TypeScript): PASS except file-size FAIL; D1 reconciliation noted.
- ✅ Language-Specific Unit Test (TypeScript/Jest): PASS (with D1).
- ✅ Evidence Location Compliance: PASS.
- N/A Python / PowerShell / C#: zero changed files.

### Metrics Summary

- ✅ 999/999 tests passing (100%)
- ✅ 97.73% line / 88.29% branch coverage on `src/lib/**`
- ✅ Format, lint, typecheck all clean
- ❌ One file exceeds the 500-line limit (`io.ts` = 542)

### Recommendation

**Needs revision (Blocked for merge).** Address the single Blocking file-size finding by performing the plan-mandated `io-launcher.ts` split. After the split, re-run format → lint → typecheck → test and re-verify all cluster files are < 500 lines. No other corrective action is required.

---

## Appendix A: Test Inventory

The new/updated suites for this feature (85 suites, 999 tests total; reviewer-verified passing):

- `test/lib/new-active-feature-folder/models.test.ts` — `RealFolderFileSystem` copyTree/listFiles/move ordering; `getEstTimestamp`; `extractDateFromTimestamp`; `validateFeatureName`.
- `test/lib/new-active-feature-folder/markdown.test.ts` — `setSection`/`updateSectionBody` backslash preservation; `getSection`; `upsertWorkModeMarker`; `formatChecklist`; `prependToSectionBody`; `setHeaderPlaceholder`.
- `test/lib/new-active-feature-folder/io.test.ts` — `findPotentialFile`; `parseIssueNumber`; `buildFolderSlug`; `copyTemplate` bug-break; `copyFeatureTemplateForMinorAudit`; `materializePlanFile`; `defaultIssueFetcher`; launcher seam.
- `test/lib/new-active-feature-folder/docs.test.ts` — `updateFeatureDocs` per type; bug concatenation; `Test Strategy` seeding; `shouldUseMinorAuditMode`.
- `test/lib/new-active-feature-folder/flow.test.ts` — `createActiveFolder` control flow, error messages, emits, minor-audit vs full routing.
- `test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` — return contract, log forwarding, failure surface, input pass-through, no-op launcher.
- `test/extension.new-active-feature-folder-inprocess.test.ts` and updated `test/extension.new-active-feature-folder.test.ts` — in-process expectation; inverted missing-python case.

---

## Appendix B: Toolchain Commands Reference

```bash
# Scope (authoritative — summary misclassifies TS per agent memory)
git diff --name-status c432b69a294ef17ace8b64964b6b0cafb22bd450...HEAD

# TypeScript toolchain (run from extensions/drm-copilot/)
npx prettier --check "src/lib/new-active-feature-folder/**/*.ts" "src/repo-automation-service.ts" "test/lib/new-active-feature-folder/**/*.ts"
npm run lint
npm run typecheck
node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"

# File sizes
wc -l extensions/drm-copilot/src/lib/new-active-feature-folder/*.ts extensions/drm-copilot/src/repo-automation-service.ts

# Evidence-location compliance
python scripts/dev_tools/validate_evidence_locations.py --root .

# Workflow / non-canonical evidence path scan
git diff --name-only c432b69...HEAD | grep -E '\.github/workflows/|scripts/benchmarks/|\.github/actions/|artifacts/(baselines|baseline|qa|qa-gates|coverage|evidence|regression-testing)/'
```

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-06-26
**Policy Version:** Current (as of audit date)
