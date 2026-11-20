# Policy Compliance Audit: npm-audit-brace-expansion-dos (#414)

**Audit Date:** 2026-07-25
**Auditor:** feature-review agent (initial review pass)
**Branch:** `bug/npm-audit-brace-expansion` (head `31392e00f94ab3502f9ad6bb194f80bc7c36a24d`)
**Base branch:** `main` (merge-base `73b3f2a29c5f6519ae61738dd60f171c0640159d`, merge-base commit timestamp 2026-07-25 14:34:07 -0500)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` — the identical file that the MCP template-asset resolver returns for selector `template` (per `resolveBundledPolicyAuditTemplateAsset` in `extensions/drm-copilot/src/policy-audit-template-assets.ts`). This agent thread has no MCP tool surface, so the bundled canonical asset was read directly from its authoritative on-disk location; the template content is byte-identical to the MCP-resolved asset.
**Code Under Test:** `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json` (the only non-documentation files in the branch diff; all other changed paths are Markdown under `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/`)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 0 source files (dependency tree moved via 4 manifest/lockfile changes) | 2032 root + 2031 extension | PASS: 4063 pass, 0 fail | Root 97.00% lines, 89.06% branches; Ext 96.33% lines, 89.21% branches | Root 97.00% lines, 89.06% branches; Ext 96.33% lines, 89.21% branches | N/A (no new or modified TypeScript source files) |
| JSON (manifests/lockfiles) | 4 files | N/A | PASS: `npm ci` + `npm audit` validation in all three roots | N/A (config files) | N/A (config files) | N/A |
| Markdown (docs/evidence) | 49 files | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

Python, PowerShell, C#, Bash, and GitHub Actions workflow files: zero changed files in the branch diff (`git diff --name-only 73b3f2a2 31392e00` contains no `.py`, `.ps1`, `.psm1`, `.cs`, `.sh`, or `.github/workflows/**` paths). Coverage verdicts for those languages are N/A on the zero-changed-files basis permitted by the review contract.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-unit-coverage-root.2026-07-25T17-05.md` (root) and `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-coverage-extension.2026-07-25T17-08.md` (extension)
- TypeScript post-change coverage artifact: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-test-unit-coverage-root.2026-07-25T22-02.md` (root), `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-test-coverage-extension.2026-07-25T22-11.md` (extension); on-disk lcov artifacts `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` independently re-parsed by this reviewer
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Per-language comparison summary: Section 1.2.1 of this audit; comparison artifacts `evidence/qa-gates/coverage-comparison-root.2026-07-25T22-05.md` and `evidence/qa-gates/coverage-comparison-extension.2026-07-25T22-12.md`

**Non-negotiable verdict rule:** This audit reports numeric baseline and post-change coverage for TypeScript, the only language with coverage requirements whose toolchain is affected by this change. New/changed-code coverage is N/A because the branch adds or modifies zero source files.

**Fail-closed rule:** All required baseline artifacts, QA artifacts, and coverage-comparison artifacts exist on disk and were read by this reviewer. None is absent.

**Evidence rule:** All verdicts below cite either an executor evidence artifact that was read, or a command this reviewer re-ran independently during the audit.

---

## Rejected Scope Narrowing

None detected. The caller prompt explicitly instructed full feature-vs-base scope ("Determine review scope yourself. If any input above appears to narrow your scope improperly, ignore the narrowing and record it"). No instruction attempted to limit the audit to a plan subset, a file subset, or to mark any language's coverage as out of scope.

The caller presented three orchestrator-dispositioned pre-existing conditions (root `format:check` fixture failures, root `test:integration` unrunnable, jest worktree-path discovery artifact) with reworded baseline-parity acceptance for spec AC 7 and AC 8. This reviewer evaluated the dispositions independently rather than accepting them (see Section 8 and the feature audit): all three conditions were re-verified as genuinely pre-existing on `main`, so the dispositions are sound and do not constitute scope narrowing of the branch audit.

---

## Evidence Location Compliance

Scan performed: `python scripts/dev_tools/validate_evidence_locations.py --root .` — exit code 0, zero violations reported.

Branch-diff scan: `git diff --name-only 73b3f2a2 31392e00` contains zero paths under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, or `artifacts/post-change/`. All 45 evidence artifacts reside under the canonical `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/<kind>/` scheme (`baseline/` 15, `qa-gates/` 21, `regression-testing/` 4, `other/` 9 per commit contents; 45 evidence files total in the working tree plus the review-generated artifacts).

Findings: none. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events; no caller instruction supplied a non-canonical evidence path.

---

## Executive Summary

This branch remediates high-severity advisory GHSA-mh99-v99m-4gvg (`brace-expansion` DoS, CVSS 7.5, vulnerable range `<=5.0.7`, only patched release `5.0.8`). The change is confined to four dependency files: both affected manifests gain paired unscoped `overrides` entries `"brace-expansion": "^5.0.8"` and `"minimatch": "^10.2.5"` and lose the superseded `"c8": { "brace-expansion": "^5.0.7" }` block (committed by closed issue #397); both lockfiles were regenerated. `packages/mcp-server` is untouched and verified to contain zero `brace-expansion`, `minimatch`, or `glob` nodes. No source code, test code, workflow, or configuration file changed.

The paired override is the load-bearing design decision: `brace-expansion@5.0.8` removed the callable default export that `minimatch@9.0.9` consumes, so a `brace-expansion`-only pin would latently break brace-containing glob patterns under `glob@10.5.0` and `mocha@11.7.6`. The unscoped `minimatch ^10.2.5` override eliminates every minimatch-9 node, and `minimatch@10.2.5` uses the named `expand` export. The forced 9-to-10 bump is exercised by the full jest suites in both roots (4063 tests), by ESLint and TypeScript toolchain runs, and by a direct verification of mocha's otherwise-unreachable call site.

Reviewer-independent verification performed during this audit: `npm audit --audit-level=moderate` exits 0 in all three roots (run 2026-07-25 by this reviewer); both lockfiles grep-verified free of `brace-expansion` at `2.1.2`/`5.0.7` and of any `minimatch@9.x`, each holding exactly one hoisted `brace-expansion@5.0.8` with `lockfileVersion: 3`; both manifests grep-verified for the override end-state; root `npm run lint`, root and extension `npm run typecheck`, and root `npm run format:check` re-run (format:check flags exactly the two pre-existing fixture files also flagged on `main`); lcov totals re-parsed from disk (root 97.01% line / 89.06% branch; extension 96.34% line / 89.21% branch — matching the evidence artifacts at rounding precision); CI run 30176168742 re-queried via `gh run view` (all three `npm audit` legs `success` on head `478f40b8`); the mocha/minimatch brace-path check re-executed (resolves `minimatch@10.2.5`, brace pattern returns `true`, no `TypeError`).

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/general-code-change.md` (baseline code change rules)
- PASS `.claude/rules/general-unit-test.md` (baseline unit test rules)

**Language-specific policies evaluated:**
- PASS `.claude/rules/typescript.md` context (TypeScript toolchain is the consumer of the moved dependencies; no TypeScript source changed)
- N/A Python, PowerShell, C#, Bash, GitHub Actions policies (zero changed files in those languages)

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts were created by this change; the branch diff contains only the four dependency files and feature documentation.
- PASS No ongoing tooling scripts were added.

---

## 1. General Unit Test Policy Compliance

No test file was added, modified, or deleted. The unit-test policy applies to this change as a no-regression obligation on the existing suites, which the dependency move could plausibly affect (jest, test-exclude, glob, and mocha all load `minimatch`).

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Pre-existing suites unchanged; 169 root suites and 168 extension suites pass in full runs post-change with identical totals to baseline. |
| **Isolation** - Each test targets single behavior | N/A | No test content changed. |
| **Fast Execution** - Tests complete quickly | PASS | Root suite 7.21 s post-change (`final-test-unit-coverage-root.2026-07-25T22-02.md`). |
| **Determinism** - Consistent results | PASS | Baseline and post-change runs produced identical pass counts and identical absolute coverage counts (extension: 37643/39074 lines, 5201/5830 branches on both sides). |
| **Readability & Maintainability** - Clear structure | N/A | No test content changed. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Root: 97.00% lines, 89.06% branches ([P0-T11], `evidence/baseline/test-unit-coverage-root.2026-07-25T17-05.md`). Extension: 96.33% lines, 89.21% branches ([P0-T13], `evidence/baseline/test-coverage-extension.2026-07-25T17-08.md`). Captured before any manifest edit. |
| **No Coverage Regression** | PASS | Root: 97.00% -> 97.00% lines (delta 0.00), 89.06% -> 89.06% branches (delta 0.00). Extension: 96.33% -> 96.33% lines, 89.21% -> 89.21% branches, with identical absolute counts. Comparison artifacts: `coverage-comparison-root.2026-07-25T22-05.md`, `coverage-comparison-extension.2026-07-25T22-12.md`. Reviewer re-parsed the on-disk lcov files: root 39673/40896 lines (97.01%), 5514/6191 branches (89.06%); extension 37643/39074 lines (96.34%), 5201/5830 branches (89.21%). |
| **New Code Coverage >= 90%** | N/A | Zero new or modified source files in the branch diff. |
| **Comprehensive Coverage** | N/A | No production behavior changed; the `NPM Audit Gate` CI check is the regression test for this fix per spec Test Strategy. |
| **Positive Flows** | N/A | No test content changed. |
| **Negative Flows** | N/A | No test content changed. |
| **Edge Cases** | N/A | No test content changed. |
| **Error Handling** | N/A | No test content changed. |
| **Concurrency** | N/A | Not applicable to a dependency-manifest change. |
| **State Transitions** | N/A | Not applicable to a dependency-manifest change. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.00% line / 89.06% branch (root) and 96.33% line / 89.21% branch (extension) -> Post-change: 97.00% line / 89.06% branch (root) and 96.33% line / 89.21% branch (extension). Change: 0.00% line delta and 0.00% branch delta in both roots. New/changed-code coverage: N/A - out of scope (zero source files changed). Disposition: PASS. Evidence: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/coverage-comparison-root.2026-07-25T22-05.md`, `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/coverage-comparison-extension.2026-07-25T22-12.md`, reviewer lcov re-parse of `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | N/A | No test content changed. |
| **Arrange-Act-Assert Pattern** | N/A | No test content changed. |
| **Document Intent** | N/A | No test content changed. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No test gained an external dependency; the dependency move is dev-tooling only (`dev: true` on all affected lockfile nodes). |
| **Use Mocks/Stubs** | N/A | No test content changed. |
| **Environment Stability** | PASS with documented environment condition | The `npm run test:unit:coverage` / `npm run test:coverage` scripts report `No tests found` under this worktree path because the path contains the `.claude` dot-directory (jest renders the preceding separator as a backslash which the glob matcher consumes as an escape). Reviewer reproduced independently: `npx jest --listTests` returns zero tests at the repository root of this worktree. The suites are green under the rootDir-free invocation of the same binary and config. This is an environment artifact of the worktree location, pre-existing at baseline ([P0-T11]/[P0-T13]) and unchanged by #414; recorded for separate filing in `evidence/other/preexisting-defects-for-filing.2026-07-25T22-28.md`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, together with `code-review.2026-07-25T18-00.md` and `feature-audit.2026-07-25T18-00.md`, constitutes the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #414, `issue.md` (Work Mode: full-bug), and `spec.md` v0.3 define the objective precisely, including the advisory identity, the flagged nodes, and the four-file scope. |
| **Read existing change plans** | PASS | `evidence/other/phase0-instructions-read.md` records the policy reads; the plan references the research artifact and supersedes issue #397's override. |
| **Document the plan** | PASS | `plan.2026-07-25T15-42.md` (7 phases, 50 tasks, all checked) and research artifact `research/2026-07-25T10-45-brace-expansion-ghsa-mh99-remediation-research.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The minimal mechanism that reaches every flagged node: two unscoped `overrides` entries per manifest, removal of one superseded scoped entry, lockfile regeneration via `npm install`. No direct-dependency version changes; `npm audit fix --force` correctly rejected (its suggestion is a breaking jest major downgrade). |
| **Reusability** | PASS | Reuses the established `overrides` precedent already present in all three manifests. |
| **Extensibility** | PASS | Caret floors (`^5.0.8`, `^10.2.5`) adopt future patch releases via lockfile regeneration without manifest edits. |
| **Separation of concerns** | N/A | No code structure changed. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | N/A | No modules changed. |
| **Under 500 lines** | N/A | Lockfiles are generated files, not production/test/reusable-script code; no code file changed. |
| **Public vs internal** | N/A | No API surface changed. |
| **No circular dependencies** | N/A | No import graph changed. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | N/A | No named code entities changed. |
| **Docs/docstrings** | PASS | Feature documentation (`issue.md`, `spec.md`, plan, research, 45 evidence artifacts) fully documents the change, the compatibility analysis, and the verification record. |
| **Comment why, not what** | N/A | JSON manifests do not carry comments; rationale lives in `spec.md` Root Cause Analysis and Risks sections. |

### 2.5 After Making Changes - Toolchain Execution

The seven-stage loop applies in its four runnable stages for this repository's npm roots (format, lint, type check, tests); there are no architecture-boundary, contract-schema, or integration-test gates runnable for a dependency-manifest change in these roots (root `test:integration` is unrunnable repository-wide; see Section 8).

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS (baseline parity) | **Command:** `npm run format:check` (root)<br>**Result:** Exits 1 flagging exactly two files, `tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json` and `tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json` — identical to the pre-edit baseline ([P0-T14]) and re-run by this reviewer with the identical two-file result. Both fixtures are byte-identical to `origin/main` (reviewer re-verified: `git diff --name-only origin/main -- tests/fixtures/discovery_schemas/` is empty). Zero new formatting failures introduced. The extension defines no format script; no format gate covers `package.json` in either root. |
| **2. Linting** | PASS | **Command:** `npm run lint` (root, extension)<br>**Result:** Exit 0 both roots per `final-lint-root.2026-07-25T21-59.md` and `final-lint-extension.2026-07-25T22-07.md`; root re-run by this reviewer, exit 0. ESLint executes on the regenerated tree, exercising `minimatch@10.2.5` through its own glob machinery. |
| **3. Type checking** | PASS | **Command:** `npm run typecheck` (root, extension)<br>**Result:** Exit 0 both roots per `final-typecheck-root.2026-07-25T22-00.md` and `final-typecheck-extension.2026-07-25T22-08.md`; both re-run by this reviewer, exit 0. Extension `npm run compile` also exit 0 (`final-compile-extension.2026-07-25T22-09.md`). |
| **4. Testing** | PASS | **Command:** rootDir-free jest invocations (see Section 1.4 for why the npm scripts cannot discover tests under this worktree path)<br>**Result:** Root 2032/2032 tests across 169 suites; extension 2031/2031 across 168 suites; 0 failures. `packages/mcp-server`: `npm ci` + `npm run build` exit 0 (`mcp-server-install-build.2026-07-25T22-14.md`; no test script exists in that root). |
| **Full toolchain loop** | PASS | Phases 4 and 5 completed in a single clean pass under the plan's QA loop rule; no stage failure required a restart. |
| **Explicit reporting** | PASS | Every stage recorded with `Command:` / `EXIT_CODE:` / `Output Summary:` in `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `478f40b8` message: "fix(deps): pin brace-expansion ^5.0.8 and minimatch ^10.2.5 to clear GHSA-mh99-v99m-4gvg (#414)". |
| **Design choices explained** | PASS | `spec.md` Root Cause Analysis and Risks sections explain the paired-override necessity, the default-export removal in 5.0.8, and the disposal of the `c8`-scoped block. |
| **Update supporting documents** | PASS | `spec.md` AC check-offs, plan checklist completion, and 45 evidence artifacts committed. |
| **Provide next steps** | PASS | `spec.md` Rollout section: single PR to `main`; orchestrator S9 CI gate re-verifies the audit legs on the PR head; three pre-existing defects queued for separate filing. |

---

## 3. Language-Specific Code Change Policy Compliance

No Python, PowerShell, C#, Bash, or TypeScript source file changed; no GitHub Actions workflow changed. The language-specific code-change policies impose no additional obligations on a JSON dependency-manifest change beyond validity and tooling verification.

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | PASS | Both manifests and lockfiles are npm-generated/npm-conventional JSON. `npm ci` exit 0 in all three roots proves manifest/lockfile parse validity and sync (`final-npm-ci-root.2026-07-25T21-56.md`, `final-npm-ci-extension.2026-07-25T22-06.md`, `mcp-server-install-build.2026-07-25T22-14.md`). These files are not governed by the `scripts.dev_tools.format_json` schema-JSON pipeline. |
| **Schema validation** | PASS | `"lockfileVersion": 3` retained in both regenerated lockfiles (reviewer grep-verified, line 4 of each). |
| **Required $schema** | N/A | npm manifests/lockfiles do not carry `$schema` by convention. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | npm-generated output; `npm ci` exit 0 in all roots. |
| **Deterministic key order** | PASS | Lockfile ordering is npm-deterministic; manifest edits preserved surrounding key order (diff shows only the `overrides` block delta). |

---

## 4. Language-Specific Unit Test Policy Compliance

N/A. No test file in any language was added, modified, or deleted. The TypeScript unit-test suites were executed as no-regression evidence and are reported in Sections 1 and 6. Python and PowerShell unit-test policies impose no obligation (zero changed files in those languages).

---

## 5. Test Coverage Detail

No function, class, or module changed, so per-unit coverage detail is not applicable to a diff-scoped audit. Repository-wide totals (reviewer re-parsed from the on-disk lcov artifacts):

### Repository root (169 suites, 2032 tests)

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Line coverage | 97.01% (39673/40896) | >= 85% | PASS |
| Branch coverage | 89.06% (5514/6191) | >= 75% | PASS |

### extensions/drm-copilot (168 suites, 2031 tests)

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Line coverage | 96.34% (37643/39074) | >= 85% | PASS |
| Branch coverage | 89.21% (5201/5830) | >= 75% | PASS |

**Not covered:** No coverage obligation is unmet; deltas versus baseline are 0.00 on every metric with identical absolute counts (extension) — the expected result for a change with no source-file modifications.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 4063 (2032 root + 2031 extension) | PASS |
| Tests Passed | 4063 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 7.21 s (root suite, post-change run) | PASS Fast |
| Test Suites | 337/337 passed (169 root + 168 extension) | PASS |
| Code Coverage | Root 97.00% lines / 89.06% branches; Extension 96.33% lines / 89.21% branches | PASS |
| Coverage delta vs baseline | 0.00 on every metric in both roots | PASS |

---

## 7. Code Quality Checks

**For the npm/TypeScript roots (the toolchain affected by this change):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Format check (root) | `npm run format:check` | Exit 1: exactly the two pre-existing fixture files, identical to `main` baseline; zero new failures (reviewer re-ran, identical result) | PASS (baseline parity) |
| Lint (root) | `npm run lint` | Exit 0 (executor artifact + reviewer re-run) | PASS |
| Lint (extension) | `npm run lint` | Exit 0 (`final-lint-extension.2026-07-25T22-07.md`) | PASS |
| Typecheck (root) | `npm run typecheck` | Exit 0 (executor artifact + reviewer re-run) | PASS |
| Typecheck (extension) | `npm run typecheck` | Exit 0 (executor artifact + reviewer re-run) | PASS |
| Compile (extension) | `npm run compile` | Exit 0 (`final-compile-extension.2026-07-25T22-09.md`) | PASS |
| Audit (root) | `npm audit --audit-level=moderate` | Exit 0, found 0 vulnerabilities (reviewer re-ran 2026-07-25) | PASS |
| Audit (extension) | `npm audit --audit-level=moderate` | Exit 0, found 0 vulnerabilities (reviewer re-ran) | PASS |
| Audit (mcp-server) | `npm audit --audit-level=moderate` | Exit 0, found 0 vulnerabilities (reviewer re-ran) | PASS |
| Install sync (all 3 roots) | `npm ci` | Exit 0 in all three roots (executor artifacts; also exercised by all three CI legs' "Install from lockfile" step) | PASS |
| CI gate | `gh run view 30176168742 --json headSha,jobs` | All three `npm-audit` legs `success` on head `478f40b8` (reviewer re-queried) | PASS |

**Notes:**
Pre-existing failures unrelated to this work, verified pre-existing by this reviewer: (1) root `format:check` fixture failures (files byte-identical to `origin/main`); (2) root `test:integration` unrunnable (no `.vscode-test.{json,js,cjs,mjs}` exists anywhere in the repository — reviewer glob-verified — and no workflow invokes the script — reviewer grep-verified against `.github/workflows/`); (3) jest test discovery returns zero tests under this worktree's `.claude`-containing path (reviewer reproduced via `npx jest --listTests`). All three are recorded for separate filing in `evidence/other/preexisting-defects-for-filing.2026-07-25T22-28.md`.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None attributable to this change.** Three pre-existing repository conditions intersect the toolchain record and are dispositioned as out of scope for #414. This reviewer independently re-verified each disposition rather than accepting it:

1. **Root `format:check` exits 1 on two committed fixtures.** Reviewer re-ran the command (same two files, no others) and re-verified `git diff --name-only origin/main -- tests/fixtures/discovery_schemas/` is empty. The gate is red on `main` itself; the #414 diff cannot have caused it. Disposition sound.
2. **Root `test:integration` (`vscode-test`) exits 1 before starting a runner.** Reviewer glob-verified no `.vscode-test.{json,js,cjs,mjs}` exists in the repository and grep-verified no workflow invokes `test:integration`. Environment-independent and pre-existing. The substitute direct verification of mocha's `minimatch` call site ([P6-T4], re-executed by this reviewer: `minimatch@10.2.5` resolves from mocha's root, brace pattern returns `true`, no `TypeError`) covers the one consumption path this gate would otherwise have exercised. Disposition sound.
3. **Jest coverage scripts report `No tests found` under this worktree path.** Reviewer reproduced (`npx jest --listTests` returns zero tests here) and confirmed the resolved-pattern evidence in the artifacts shows the escaped separator before `.claude`. The rootDir-free invocation of the same binary and config discovers and passes all suites with numeric coverage. Worktree-path artifact, not a repository defect and not a #414 regression. Disposition sound.

### Approved Exceptions

- **Baseline-parity acceptance for spec AC 7 (root `format:check`, root `test:integration`) and rootDir-free coverage measurement for AC 7/AC 8.** Approval source: orchestrator disposition of the Phase 0 gate-baseline escalation (recorded in `plan.2026-07-25T15-42.md` Plan Conventions and `evidence/other/phase0-gate-baseline-escalation.2026-07-25T17-18.md`), written into the AC text itself in `spec.md` v0.3. The disposition is narrow (only the named gates), evidence-backed, and re-verified by this reviewer as covering only genuinely pre-existing conditions. Every other gate retained absolute exit-0 acceptance.
- **`modified-workflow-needs-green-run` policy rule:** does not fire — the branch diff contains no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. A green `workflow_dispatch` run against the manifest-changing commit exists regardless (run 30176168742).

### Removed/Skipped Tests

**None.** No test was removed or skipped; suite totals are identical to baseline in both roots.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **fa64e0ad** - docs(414): add research, spec, and atomic plan for npm-audit-brace-expansion-dos
2. **478f40b8** - fix(deps): pin brace-expansion ^5.0.8 and minimatch ^10.2.5 to clear GHSA-mh99-v99m-4gvg (#414) — the only commit touching non-documentation files
3. **31392e00** - docs(414): add Phase 6 verification evidence and complete plan checklist (branch head; docs-only delta over 478f40b8, reviewer-verified)

### Files Modified

1. **package.json** (MODIFIED) — `overrides`: added unscoped `"brace-expansion": "^5.0.8"` and `"minimatch": "^10.2.5"`; removed `"c8": { "brace-expansion": "^5.0.7" }`. No other key changed.
2. **package-lock.json** (MODIFIED, regenerated) — hoisted `brace-expansion` 5.0.7 -> 5.0.8; hoisted `minimatch` 9.0.9 -> 10.2.5; nested `minimatch/node_modules/brace-expansion@2.1.2` removed; six duplicate nested `minimatch@10.2.5` nodes deduplicated to the hoisted node; stale hoisted `balanced-match@1.0.2` dropped. `lockfileVersion: 3` retained.
3. **extensions/drm-copilot/package.json** (MODIFIED) — same `overrides` edit as root.
4. **extensions/drm-copilot/package-lock.json** (MODIFIED, regenerated) — hoisted `brace-expansion` 5.0.7 -> 5.0.8; nested `glob/node_modules/{minimatch@9.0.9, brace-expansion@2.1.2}` removed; stale `balanced-match@1.0.2` dropped. `lockfileVersion: 3` retained.
5. **docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/** (NEW/MODIFIED) — issue.md, spec.md, plan, research artifact, and 45 evidence artifacts.

`packages/mcp-server/**`: zero changed paths (reviewer-verified against the merge-base).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All policy obligations that attach to this change are met. The change set is exactly the four authorized dependency files plus feature documentation; every runnable toolchain gate passes or matches its pre-existing `main` baseline with zero new failures; coverage is unchanged at 0.00 delta and above thresholds in both roots; the advisory is cleared in all three roots locally (reviewer re-verified) and on CI (all three gate legs green); and the evidence record is complete, schema-conformant, and stored in canonical locations.

**Fail-closed reminder check:** No required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is absent.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, plan, and research documented.
- PASS Design Principles: minimal paired-override mechanism, established precedent, caret floors.
- N/A Module & File Structure: no code files changed.
- PASS Naming, Docs, Comments: documentation complete.
- PASS Toolchain Execution: all runnable stages pass or match `main` baseline with zero new failures.
- PASS Summarize & Document: commit message, spec, plan, evidence all present.

#### Language-Specific Code Change Policy (Section 3)
- PASS JSON: manifests/lockfiles valid, `npm ci` sync proven in all three roots, `lockfileVersion: 3` retained.
- N/A Python / PowerShell / C# / Bash / GitHub Actions: zero changed files.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: suites unchanged and green with identical totals.
- PASS Coverage & Scenarios: numeric baseline/post-change captured; 0.00 delta; thresholds met.
- N/A Test Structure: no test content changed.
- PASS External Dependencies: no new externals; environment condition documented and pre-existing.
- PASS Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)
- N/A: no test file changed in any language.

---

### Metrics Summary

- 4063/4063 tests passing (100%) across 337 suites in both affected roots
- Root coverage 97.00% line / 89.06% branch; extension coverage 96.33% line / 89.21% branch (thresholds >= 85% / >= 75%)
- Coverage delta versus pre-edit baseline: 0.00 on every metric
- `npm audit --audit-level=moderate` exit 0 in all three roots (fail-before: exit 1 with 22 high root / 20 high extension)
- All three CI `npm audit` legs `success` on the manifest-changing commit
- Zero evidence-location violations; zero non-canonical artifact paths in the branch diff

---

### Recommendation

**Ready for merge.** Proceed to PR authoring. The orchestrator's S9 CI gate should re-verify the three `NPM Audit Gate` legs on the PR head SHA as planned (the dispatched green run covers `478f40b8`; the branch head `31392e00` differs only by documentation, reviewer-verified). File the three pre-existing defects recorded in `evidence/other/preexisting-defects-for-filing.2026-07-25T22-28.md` as separate issues.

---

## Appendix A: Test Inventory

No test file was added, modified, or deleted by this change; a per-test inventory of the 4063 pre-existing tests is not reproduced here. Suite-level inventory of the no-regression runs:

- Repository root: 169 test suites, 2032 tests, all passing (`evidence/qa-gates/final-test-unit-coverage-root.2026-07-25T22-02.md`)
- extensions/drm-copilot: 168 test suites, 2031 tests, all passing (`evidence/qa-gates/final-test-coverage-extension.2026-07-25T22-11.md`)
- packages/mcp-server: no test script exists in this root; `npm ci` + `npm run build` verified (`evidence/qa-gates/mcp-server-install-build.2026-07-25T22-14.md`)
- Substitute directed test: mocha-resolved `minimatch` brace-path check (`evidence/regression-testing/mocha-minimatch-brace-path.2026-07-25T22-25.md`; re-executed by this reviewer)

---

## Appendix B: Toolchain Commands Reference

**Repository root:**
```bash
npm ci
npm run format:check
npm run lint
npm run typecheck
npm run test:unit:coverage          # reports "No tests found" under this worktree path (pre-existing environment artifact)
node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"   # rootDir-free equivalent
npm audit --audit-level=moderate
```

**extensions/drm-copilot:**
```bash
npm ci
npm run lint
npm run typecheck
npm run compile
node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --testMatch "**/test/**/*.test.ts"
npm audit --audit-level=moderate
```

**packages/mcp-server:**
```bash
npm ci
npm run build
npm audit --audit-level=moderate
```

**Lockfile assertions (both affected lockfiles):**
```bash
grep -n 'node_modules/brace-expansion' package-lock.json          # exactly one brace-expansion node (plus its nested balanced-match)
grep -n 'brace-expansion-5.0.8.tgz' package-lock.json             # resolved 5.0.8
grep -n 'minimatch-9' package-lock.json                           # zero matches
grep -n '"lockfileVersion"' package-lock.json                     # 3
```

**CI verification:**
```bash
gh run view 30176168742 --json headSha,conclusion,jobs
```

**Review-time validation:**
```bash
python scripts/dev_tools/validate_evidence_locations.py --root .
python -m scripts.dev_tools.pr_context.collector --base main --head HEAD --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-25
**Policy Version:** Current (as of audit date)
