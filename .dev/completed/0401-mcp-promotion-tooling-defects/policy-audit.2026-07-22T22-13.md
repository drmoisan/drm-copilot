# Policy Compliance Audit: MCP Promotion Tooling Defects (Issue #401) — Remediation Cycle 1 Reaudit

---

**Audit Date:** 2026-07-22
**Code Under Test:**
- TypeScript (production): `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`, `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-poshqc.ts` (NEW, cycle 1), `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tool-inputs-potential-to-issue.ts` (NEW), `extensions/drm-copilot/src/workflow-command-arguments.ts`
- TypeScript (tests): 14 test files under `extensions/drm-copilot/test/` (4 new: `promotion.matrix.test.ts`, `mcp-tool-inputs.workspace-root.test.ts`, `mcp-tools.workspace-root.test.ts`; support additions in `promotion-test-support.ts`)
- Python (production): `scripts/dev_tools/potential_to_issue.py`
- Python (tests): `tests/scripts/dev_tools/test_potential_to_issue.py`, `tests/scripts/dev_tools/test_potential_to_issue_branches.py` (NEW, cycle 1)
- Documentation: `README.md`, `extensions/drm-copilot/README.md`, four `execute-hard-lock/SKILL.md` copies (repo + bundled mirrors)

**Baseline:** base branch `main`, merge-base `a0b251d330525b8307467f4cf529c5cc3e947445`. Head branch `bug/mcp-promotion-tooling-defects-401` @ `3ba0d3c4aab9a57d00a2a02591abcf0e0391c1e2` (original fix commit `9d2e7633` + remediation commit `3ba0d3c4`). Work mode: `full-bug`. Audit type: reaudit after remediation cycle 1 (`remediation-plan.2026-07-22T21-20.md`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 9 production, 14 test | 2031 tests (168 suites) | PASS 2031 pass, 0 fail (independently rerun this reaudit) | 96.30% lines, 89.22% branches | 96.34% lines (37643/39074), 89.21% branches (5201/5830) | `mcp-tool-inputs-potential-to-issue.ts`: 100% lines, 100% branches; `mcp-repo-automation-tool-definitions-poshqc.ts`: 100% lines (123/123), no branch constructs (BRF 0) |
| Python | 1 production, 2 test | 1992 tests (full `tests/scripts/dev_tools` scope, independently rerun) | PASS 1992 pass, 0 fail | `potential_to_issue.py` 91.00% lines, 68.18% branches; measured-set TOTAL 90.91% lines | `potential_to_issue.py` 95.00% lines (190/200), 81.82% branches (54/66); measured-set 90.98% lines (11147/12252), 81.83% branches (3638/4446) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/baseline/baseline-ts-test-coverage.2026-07-22T15-53.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (parsed this reaudit; LF counts match post-extraction file lengths 402/123, confirming freshness) + `evidence/qa-gates/final-ts-test-coverage.2026-07-22T21-30.md` + `evidence/qa-gates/coverage-delta-ts.2026-07-22T21-30.md`
- Python baseline coverage artifact: `evidence/baseline/baseline-py-test-coverage.2026-07-22T15-53.md` + `evidence/remediation-baseline/remediation-baseline-py-test-coverage.2026-07-22T21-30.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (parsed this reaudit) + `evidence/qa-gates/final-py-test-coverage.2026-07-22T21-30.md` + `evidence/qa-gates/coverage-delta-py.2026-07-22T21-30.md` (corrected per-module computation)
- PowerShell baseline coverage artifact: `N/A - out of scope` (zero PowerShell files in the branch diff)
- PowerShell post-change coverage artifact: `N/A - out of scope` (zero PowerShell files in the branch diff)
- C# baseline coverage artifact: `N/A - out of scope` (zero C# files in the branch diff)
- C# post-change coverage artifact: `N/A - out of scope` (zero C# files in the branch diff)
- Per-language comparison summary: Section 1.2.1 below

**Coverage verdicts (explicit, per language with changed files):**
- **TypeScript: PASS.** Repo-wide 96.34% lines / 89.21% branches (thresholds 85/75). Every changed production file >= 85% lines and >= 75% branches (lowest: `workflow-command-arguments.ts` 91.46%/88.24%). Both new files at 100% line coverage. No regression versus baseline (96.30%/89.22%); the line-denominator increase of 21 is attributable to the pure module split (docblock lines in the new fully-covered sibling).
- **Python: PASS.** The cycle-0 FAIL is resolved. Modified module `scripts/dev_tools/potential_to_issue.py`: 95.00% lines (190/200, up from 91.00%) and 81.82% branches (54/66, up from 68.18%), both above the uniform 85/75 floors, computed from per-module counts (not the TOTAL row) and independently verified from `artifacts/python/lcov.info` and a live pytest coverage rerun this reaudit. Measured-set totals 90.98% lines / 81.83% branches. Zero regression; the improvement came from the new tests-only file with no production change (verified: `git diff 9d2e7633..HEAD` contains no change to `scripts/dev_tools/potential_to_issue.py`).

## Rejected Scope Narrowing

None detected. The caller instructed a full branch-diff reaudit against merge-base `a0b251d3` including both commits, with both TypeScript and Python toolchains and coverage in scope, which matches the scope invariant. No narrowing attempt was present in the delegation prompt.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` → EXIT_CODE 0 (no violations), rerun this reaudit at head `3ba0d3c4`.
- The branch diff writes zero files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, or any other non-canonical evidence path (verified via `git diff --name-status a0b251d3..HEAD`, 102 files).
- All evidence in the diff resides under the canonical `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/<kind>/` tree (`baseline/`, `remediation-baseline/`, `qa-gates/`, `regression-testing/`, `other/`, `issue-updates/`). **PASS.**

---

## Executive Summary

This reaudit reviews remediation cycle 1 for issue #401 on branch `bug/mcp-promotion-tooling-defects-401` at head `3ba0d3c4`, covering the full branch diff against merge-base `a0b251d3` (both the original fix commit `9d2e7633` and the remediation commit `3ba0d3c4`).

All three remediation items are verified:

- **R1 (cycle-0 Blocking finding) — RESOLVED.** `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` is now 402 lines (was 504), with the five `run_poshqc_*` tool definitions extracted byte-identically to the new 123-line sibling `mcp-repo-automation-tool-definitions-poshqc.ts` and spliced back at the original array position via `...POSHQC_TOOL_DEFINITIONS` (type-only import in the sibling avoids a runtime cycle). This reaudit independently diffed `9d2e7633..HEAD` and confirmed a pure move: schemas, tool names, descriptions, and `required` arrays are unchanged; `REPO_AUTOMATION_TOOL_DEFINITIONS` still exposes all 21 repo-automation tools (16 + 5 split), 28 total with discovery, each requiring `workspace_root`. The full Jest suite passes at the identical 168-suite/2031-test count.
- **R2 — RESOLVED.** `scripts/dev_tools/potential_to_issue.py` per-module branch coverage rose from 68.18% (45/66) to 81.82% (54/66) and line coverage from 91.00% to 95.00% (190/200), via the new tests-only file `tests/scripts/dev_tools/test_potential_to_issue_branches.py` (10 cases, 408 lines, no production change). Verified from lcov and a live coverage rerun (1992 passed).
- **R3 — DEFERRED (accepted).** The two pre-existing over-500-line Python files (`potential_to_issue.py` 639, `test_potential_to_issue.py` 1076; 634/1017 at merge-base) are deferred to a follow-up issue with documented rationale (`evidence/other/r3-deferral.2026-07-22T21-30.md`), exercising the orchestrator discretion granted by the cycle-1 exit condition and consistent with the April 2026 precedent for these same files (`docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/policy-audit.2026-04-05T15-30.md`). This reaudit evaluates the deferral as acceptable: the overages predate the branch, the growth (+5/+59) came from required lockstep and regression work in the original cycle, and the decomposition is parity-sensitive work distinct from this bug fix. It remains a Major non-blocking follow-up, not a Blocking finding.

Both language toolchains were independently rerun green in a single pass at head `3ba0d3c4` during this reaudit. **Blocking-finding count: 0.** No remediation-inputs artifact is required.

**Policy documents evaluated:**
- [x] `general-code-change` policy (`.claude/rules/general-code-change.md`)
- [x] `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- [x] TypeScript: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- [x] Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`
- N/A PowerShell, C#, Bash (no changed files in the branch diff)

**Temporary artifacts cleanup:**
- [x] No temporary/one-time scripts remain in the branch diff (verified against `git diff --name-status`)
- [x] Working tree at review time is clean (`git status --porcelain` empty)

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | All fakes constructed per test on both sides (`FakePotentialFileSystem`, `FakeGhClient` in Jest; `FakeFileSystem`, `FakeGhClient` defined locally in the new `test_potential_to_issue_branches.py`). Full bulk runs green (2031 Jest, 1992 pytest, this reaudit). |
| **Isolation** - Each test targets single behavior | PASS | The 10 new branch-coverage cases each target one named branch/guard (docstrings cite the covered branch, e.g. "Cover branch 397->398"). Cycle-0 test isolation findings unchanged. |
| **Fast Execution** - Tests complete quickly | PASS | Jest full suite: 2031 tests in 2.70 s (this reaudit). pytest full dev_tools scope with coverage: 1992 tests in 9.88 s (this reaudit). |
| **Determinism** - Consistent results | PASS | New Python cases use in-memory fakes and `monkeypatch`; no wall-clock, RNG, network, subprocess, or temp-file usage (file docstring asserts this; full-file inspection this reaudit confirms). |
| **Readability & Maintainability** - Clear structure | PASS | New cases carry Google-style docstrings naming the covered branch and rationale, AAA comments, and grouped sections by concern. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | TS: 96.30%/89.22% (`baseline-ts-test-coverage.2026-07-22T15-53.md`); remediation baseline 96.33%/89.21% (`remediation-baseline-ts-test-coverage.2026-07-22T21-30.md`). Py: module 200/18/66/21 counts at baseline; remediation baseline re-pinned the same counts. |
| **No Coverage Regression** | PASS | TS: branch 89.21% unchanged; line 96.34% with the denominator shift fully attributable to the covered pure split. Py: module improved on both axes (91.00%→95.00% lines, 68.18%→81.82% branches); measured-set totals improved (Miss 1114→1105, BrPart 564→554). |
| **New Code Coverage** | PASS | `mcp-tool-inputs-potential-to-issue.ts` 100%/100%; `mcp-repo-automation-tool-definitions-poshqc.ts` 100% lines (123/123, BRF 0). Parsed from `coverage/lcov.info` this reaudit. |
| **Comprehensive Coverage** | PASS | The cycle-0 PARTIAL is resolved: `potential_to_issue.py` per-module branch coverage 81.82% >= 75%. Remaining uncovered: 10 statements / 12 partial branches in defensive CLI paths, above threshold. |
| **Positive Flows** | PASS | Carried from cycle 0 (bug/minor-audit rendering, fallback paths, absolute/relative `potential_path`); unchanged by the remediation diff. |
| **Negative Flows** | PASS | Cycle-0 cases plus new negative cases: invalid work mode, empty content, invalid mode/type combination re-raise, unresolved `gh` path guards. |
| **Edge Cases** | PASS | Cycle-0 cases plus new `os.path.relpath` ValueError fallback (cross-drive) case via `monkeypatch`. |
| **Error Handling** | PASS | `PromotionError` and `RuntimeError` guards asserted with match patterns in the new cases; failure envelope assertions unchanged. |
| **Concurrency** | N/A | No concurrent behavior in the changed scope. |
| **State Transitions** | N/A | No stateful components changed. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.30% lines / 89.22% branches -> Post-change: 96.34% lines / 89.21% branches. Change: +0.04% lines / -0.01% branches (flat; changed lines exercised; denominator +21 from the fully-covered pure module split). New/changed-code coverage: 100% lines and 100% branches for `mcp-tool-inputs-potential-to-issue.ts` (60/60, 1/1) and 100% lines for `mcp-repo-automation-tool-definitions-poshqc.ts` (123/123, no branch constructs). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` (parsed this reaudit); `evidence/qa-gates/coverage-delta-ts.2026-07-22T21-30.md`.
- Python: Baseline: 91.00% lines / 68.18% branches for the changed module `potential_to_issue.py` -> Post-change: 95.00% lines / 81.82% branches (190/200, 54/66), measured-set totals 90.98% lines / 81.83% branches. Change: +4.00% lines / +13.64% branches for the module (zero regression anywhere). New/changed-code coverage: 100% of changed lines exercised; no new Python production files (improvement delivered by the tests-only file `test_potential_to_issue_branches.py`). Disposition: PASS. Evidence: `artifacts/python/lcov.info` (parsed this reaudit); live rerun `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term` (1992 passed); `evidence/qa-gates/coverage-delta-py.2026-07-22T21-30.md`.
- PowerShell: no changed files in the branch diff; coverage comparison not applicable. Disposition: N/A. Evidence: `git diff --name-status a0b251d3..HEAD` (zero `.ps1`/`.psm1` entries).
- C#: no changed files in the branch diff; coverage comparison not applicable. Disposition: N/A. Evidence: `git diff --name-status a0b251d3..HEAD` (zero `.cs` entries).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | New pytest cases use `pytest.raises(..., match=...)` with exact message fragments (`"Invalid work mode"`, `"Potential file is empty"`, `"gh CLI path was not resolved"`). Cycle-0 exact-string assertions unchanged. |
| **Arrange-Act-Assert Pattern** | PASS | Explicit Arrange/Act/Assert comments in the new file (full-file inspection this reaudit). |
| **Document Intent** | PASS | Module docstring states purpose (branch-floor raise, no production change); each case docstring names the covered branch. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | New cases fake the filesystem and gh client entirely; `RealGhClient` guard cases avoid subprocess execution by construction (guards fire before any external call). |
| **Use Mocks/Stubs** | PASS | Local `FakeFileSystem`/`FakeGhClient` implementations of the module's seam interfaces; `monkeypatch` used at the import location for the relpath fallback. |
| **Environment Stability** | PASS | No temporary files (prohibited); literal fake paths only. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This reaudit is that review; zero Blocking findings remain (Section 8). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Remediation cycle driven by `remediation-inputs.2026-07-22T21-07.md` (R1/R2/R3) and `remediation-plan.2026-07-22T21-20.md`. |
| **Read existing change plans** | PASS | Remediation phase-0 evidence at `evidence/remediation-baseline/phase0-instructions-read.2026-07-22T21-30.md`. |
| **Document the plan** | PASS | Remediation plan with per-task evidence artifacts under `evidence/` (qa-gates, remediation-baseline, other). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | R1 is a pure module split (definitions moved verbatim, spliced back with a spread at the original position); R2 is tests-only. No new abstractions. |
| **Reusability** | PASS | Extraction follows the established `mcp-tool-inputs-push-down.ts` / `mcp-tool-inputs-potential-to-issue.ts` precedent; sibling reuses `workspaceRootProperty`. |
| **Extensibility** | PASS | Public import surface preserved: `POSHQC_TOOL_DEFINITIONS` re-exported from the base module; `REPO_AUTOMATION_TOOL_DEFINITIONS` shape unchanged. |
| **Separation of concerns** | PASS | The sibling holds exactly the five PoshQC definitions (single responsibility) with a docblock explaining the extraction rationale and the type-only import choice. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | PoshQC definitions form a cohesive extraction unit; branch-coverage tests grouped in a dedicated mirrored test file rather than growing the over-limit existing file. |
| **Under 500 lines** | PARTIAL | **Resolved (was Blocking):** `mcp-repo-automation-tool-definitions.ts` = **402** (was 504); new sibling = **123**. This reaudit independently measured every changed/new `.ts`/`.py` file in the branch diff via `wc -l`: all are <= 500 (largest: `mcp-tool-inputs.test.ts` 496, `mcp-server.test.ts` 487, `mcp-tool-inputs.ts` 477, `test_potential_to_issue_branches.py` 408) **except** the two pre-existing R3-deferred files: `scripts/dev_tools/potential_to_issue.py` 639 (634 at merge-base) and `tests/scripts/dev_tools/test_potential_to_issue.py` 1076 (1017 at merge-base). Disposition: Major, non-blocking, deferred to a follow-up issue per `evidence/other/r3-deferral.2026-07-22T21-30.md` under the cycle-1 exit-condition discretion and the April 2026 precedent for these same files. Not a Blocking finding: the overages predate the branch and the growth came from required lockstep/regression work. |
| **Public vs internal** | PASS | Base module remains the import point (`import` + re-`export` of the sibling constant); no consumer import-path changes were required (`evidence/other/r1-import-sweep.2026-07-22T21-30.md`; confirmed by the zero-test-change Jest run). |
| **No circular dependencies** | PASS | The sibling imports `ToolDefinition` type-only from the base (erased at compile time); the base imports the sibling constant at runtime — no runtime cycle. ESLint and tsc pass; Jest module graph loads cleanly (2031 tests). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `mcp-repo-automation-tool-definitions-poshqc.ts` (kebab-case, scoped suffix); `POSHQC_TOOL_DEFINITIONS` constant; `test_potential_to_issue_branches.py` mirrors production naming. |
| **Docs/docstrings** | PASS | Sibling docblock explains the extraction rationale, the splice-back invariant, and the type-only import decision. New Python test file/class/function docstrings comply with the commenting policy. |
| **Comment why, not what** | PASS | Docstrings cite the specific covered branch and why the guard exists; no line narration. |

### 2.5 After Making Changes - Toolchain Execution

All commands below were **independently rerun during this reaudit** at head `3ba0d3c4` (in addition to the executor's recorded qa-gates evidence at 2026-07-22T21-30):

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | TS: `npx prettier --check "src/**/*.ts" "test/**/*.ts"` → "All matched files use Prettier code style!", exit 0. Py: `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` → 324 files unchanged, exit 0. |
| **2. Linting** | PASS | TS: `npm run lint` (eslint src test) → exit 0. Py: `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` → "All checks passed!", exit 0. |
| **3. Type checking** | PASS | TS: `npm run typecheck` (`tsc -p ./ --noEmit`) → exit 0. Py: `poetry run pyright --outputjson scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue_content.py tests/scripts/dev_tools` → 184 files analyzed, 0 errors/0 warnings. |
| **4. Testing** | PASS | TS: `node run-jest.cjs --testMatch "<forward-slashed absolute glob>"` → 168 suites, 2031 tests passed, exit 0 (the default glob matches zero files under the worktree path; the explicit forward-slashed glob is the same workaround the executor recorded). Py: `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term -q` → 1992 passed, exit 0. |
| **Architecture / contract / integration stages** | N/A | No dependency-cruiser configuration exists for the extension package; no schema/contract surfaces or integration-test suites are affected by this diff. No stage was silently skipped — no repo-defined runner exists for these stages in the changed scope. |
| **Full toolchain loop** | PASS | Single-pass green on rerun (this reaudit) and recorded single-pass green in `evidence/qa-gates/final-*.2026-07-22T21-30.md` (executor). |
| **Explicit reporting** | PASS | Commands and exit codes recorded here and in the qa-gates evidence. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | `issue.md` "Fix Outcome" section; `spec.md` AC-11/AC-14 evidence lines updated with remediation-cycle citations. |
| **Design choices explained** | PASS | Extraction rationale in the sibling docblock; deferral rationale in `r3-deferral.2026-07-22T21-30.md`; corrected per-module coverage computation documented in `coverage-delta-py.2026-07-22T21-30.md`. |
| **Update supporting documents** | PASS | Doc sweep unchanged from cycle 0 (no new caller-facing contract changes in the remediation commit; the split is behavior-invariant). |
| **Provide next steps** | PASS | R3 follow-up decomposition flagged for a separate issue (Section 8). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` → 324 files unchanged, exit 0 (this reaudit). |
| **Linting with Ruff** | PASS | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` → exit 0 (this reaudit). Zero suppressions (`# noqa`, `# type: ignore`) in the new test file (grep, this reaudit). |
| **Type checking with Pyright** | PASS | 184 files analyzed, 0 errors (this reaudit). New test file fully annotated (`-> None` returns, typed fake attributes). |
| **Testing with Pytest** | PASS | 1992 passed full dev_tools scope with branch coverage (this reaudit). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | New fakes implement the module's seam interfaces with complete annotations; `TYPE_CHECKING`-gated `Iterable` import. |
| **Dataclasses for value objects** | N/A | No new value objects. |
| **Protocols/ABCs for interfaces** | N/A | Existing seam interfaces (`FileSystem`, `GhClient`) reused; no new interfaces. |
| **Avoid utility classes** | PASS | Test fakes are cohesive single-purpose classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | Production unchanged in cycle 1; new tests assert the existing specific exceptions (`PromotionError`, `RuntimeError`, `FileNotFoundError`). |
| **Logging over print** | N/A | No logging changes in the diff. |
| **Invariants at construction** | PASS | New test covers the `__post_init__` gh-path invariant branches. |

### Section 3B: TypeScript Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting — Prettier** | PASS | `npx prettier --check ...` → exit 0 (this reaudit). |
| **Linting — ESLint** | PASS | `npm run lint` → exit 0 (this reaudit). No new suppressions in the remediation diff (grep for `eslint-disable`/`@ts-expect-error`/`@ts-ignore` over `9d2e7633..HEAD` added lines: none). |
| **Type checking — TSC** | PASS | `npm run typecheck` → exit 0. No `any` introduced; the sibling uses `ReadonlyArray<ToolDefinition>` with a type-only import. |
| **Testing** | PASS | Jest 2031/2031 (this reaudit). Note: `.claude/rules/typescript.md` names Vitest; the extension's established framework is Jest — a pre-existing docs discrepancy recorded in spec Rollout & Follow-up, not a violation introduced here. |

#### 3B.2 Design & Standards

| Requirement | Status | Evidence |
|------------|--------|----------|
| **ES modules / kebab-case files** | PASS | New sibling uses ES imports/exports and a kebab-case name. |
| **Fail fast with clear errors** | PASS | Unchanged from cycle 0 (fail-closed `workspace_root` guard verified again via the passing AC-4/AC-8 suites). |
| **No new runtime dependencies** | PASS | `extensions/drm-copilot/package.json` unchanged in the remediation diff. |
| **Runtime determinism** | PASS | No `Date`, `Math.random`, or timer usage introduced. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | New file uses plain pytest functions with `monkeypatch` fixture; no alternative runner. |
| **Coverage expectation** | PASS | Per-module `potential_to_issue.py`: 95.00% lines / 81.82% branches (>= 85/75), computed from per-module counts. Measured-set 90.98%/81.83%. Cycle-0 PARTIAL resolved. |
| **Focused unit tests / mocking sparingly / organization** | PASS | One branch per test; only the seam interfaces are faked; test file lives in the mirrored `tests/scripts/dev_tools/` tree (no colocation). |
| **Naming and readability** | PASS | Descriptive `test_...` names; docstrings identify the target branch and scenario. |

### Section 4B: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | PASS | Jest (`@jest/globals`), `*.test.ts` under `test/` mirroring `src/`; no test changes were needed for the R1 split (zero-modification suite pass is itself the behavior-invariance evidence). |
| **Coverage expectation** | PASS | 96.34% lines / 89.21% branches repo-wide; all changed files above thresholds; both new files at 100% lines. |
| **AAA / one behavior per test / fakes** | PASS | Carried from cycle 0; unchanged by the remediation diff. |
| **No external dependencies** | PASS | No network/filesystem/temp files in the test suites. |

---

## 5. Test Coverage Detail

### R1 verification — `mcp-repo-automation-tool-definitions.ts` split (cycle 1)

| Check | Result | Status |
|-------|--------|--------|
| Base module line count | 402 (<= 500; was 504) | PASS |
| Sibling module line count | 123 (<= 500) | PASS |
| Pure move (no schema/behavior change) | `git diff 9d2e7633..HEAD` shows the five `run_poshqc_*` definitions removed from the base and added verbatim to the sibling, spliced via `...POSHQC_TOOL_DEFINITIONS` at the original position | PASS |
| Tool count and required contract | 16 + 5 + 7 = 28 `"workspace_root"` required entries across runtime definition modules (grep, this reaudit); base mirror `mcp-tool-definitions.ts` 18/18; AC-5 length-pinned Jest assertions pass | PASS |
| Behavior invariance | 168 suites / 2031 tests pass with zero test modifications (identical counts to the pre-split baseline) | PASS |
| Coverage of both R1 files | 402/402 and 123/123 lines = 100.00%; no branch constructs (BRF 0) | PASS |

### R2 verification — `potential_to_issue.py` branch coverage (cycle 1)

| Check | Result | Status |
|-------|--------|--------|
| Per-module branch coverage | 54/66 = 81.82% (>= 75%); baseline 45/66 = 68.18% | PASS |
| Per-module line coverage | 190/200 = 95.00% (>= 85%); baseline 182/200 = 91.00% | PASS |
| Tests-only change | `git diff 9d2e7633..HEAD` contains no change to `scripts/dev_tools/potential_to_issue.py`; only `test_potential_to_issue_branches.py` (408 lines, 10 cases) added | PASS |
| Independent measurement | Live rerun `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term` → `potential_to_issue.py  200  10  66  12  92%`, 1992 passed; lcov parse concurs (BRH 54 / BRF 66) | PASS |
| Evidence-accuracy correction | `coverage-delta-py.2026-07-22T21-30.md` computes the AC-11 verdict from per-module counts and explicitly supersedes the defective cycle-0 computation | PASS |

### Cycle-0 functional coverage (carried forward, re-verified by full-suite reruns at head)

- `normalizeWorkspaceRoot` fail-closed/fallback/validation cases: PASS (Jest full run).
- `resolvePotentialToIssueToolInput` relative/absolute `potential_path` + summary pinning: PASS.
- `buildIssueBody` routing matrix (TS + Python lockstep) including (bug, minor-audit) regression: PASS.
- MCP schema required contract + dispatch failure envelope: PASS.

**Not covered:** 12 partially-covered branches in `potential_to_issue.py` (defensive CLI paths; above the 75% floor).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (TS) | 2031 (168 suites) | PASS |
| Tests Passed (TS) | 2031 (100%) | PASS |
| Execution Time (TS) | 2.70 s total | PASS Fast |
| Total Tests (Py, full dev_tools scope) | 1992 | PASS |
| Tests Passed (Py) | 1992 (100%) | PASS |
| Execution Time (Py) | 9.88 s with branch coverage | PASS Fast |
| Code Coverage (TS) | 96.34% lines, 89.21% branches | PASS |
| Code Coverage (Py) | measured-set 90.98% lines / 81.83% branches; modified module 95.00% / 81.82% | PASS |

---

## 7. Code Quality Checks

**For TypeScript (from `extensions/drm-copilot/`):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` | All files formatted, exit 0 | PASS |
| ESLint | `npm run lint` | No findings, exit 0 | PASS |
| TSC | `npm run typecheck` | 0 errors, exit 0 | PASS |
| Jest | `node run-jest.cjs --testMatch "<absolute forward-slashed glob>"` | 2031/2031 pass, exit 0 | PASS |

**For Python (from repo root):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` | 324 files unchanged, exit 0 | PASS |
| Ruff | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` | All checks passed, exit 0 | PASS |
| Pyright | `poetry run pyright --outputjson scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue_content.py tests/scripts/dev_tools` | 184 files, 0 errors | PASS |
| Pytest | `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term -q` | 1992 passed, exit 0 | PASS |

**Notes:**
Pre-existing conditions unrelated to this fix and unchanged this cycle: `.claude/rules/typescript.md` names Vitest while the extension uses Jest (flagged in spec for separate docs correction); the two R3-deferred over-500-line Python files (Section 8).

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **[Major, non-blocking — DEFERRED] Pre-existing over-500-line Python files.** `scripts/dev_tools/potential_to_issue.py` 639 lines (634 at merge-base, +5 from the required lockstep reorder) and `tests/scripts/dev_tools/test_potential_to_issue.py` 1076 lines (1017 at merge-base, +59 from required regression cases). Both predate the branch. Deferred to a follow-up issue per `evidence/other/r3-deferral.2026-07-22T21-30.md`, exercising the orchestrator discretion granted by the cycle-1 exit condition in `remediation-inputs.2026-07-22T21-07.md` (R3 "optional/deferrable"). Reaudit evaluation: the deferral is acceptable — the decomposition is parity-sensitive (byte-parity contract with `promotion.ts`), a distinct larger work unit, and consistent with the April 2026 precedent for these same files. A follow-up issue for the decomposition should be filed post-merge.

### Resolved This Cycle

- **[was Blocking] R1 file-size violation** — resolved (504 → 402 + 123-line sibling; pure split verified; all changed files <= 500 except the deferred pair).
- **[was Major] R2 modified-file branch coverage** — resolved (68.18% → 81.82% per-module; tests-only).
- **[was Major] Coverage-delta evidence accuracy** — resolved (`coverage-delta-py.2026-07-22T21-30.md` computes per-module and supersedes the defective cycle-0 artifact).

### Approved Exceptions

**None.** No exceptions were requested or approved. The R3 deferral is a documented scope decision under the remediation exit condition, not a policy exception.

### Removed/Skipped Tests

**None.** Test counts increased (2031 TS unchanged; Python 1982 → 1992).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **9d2e7633** — `fix(mcp-tools): require workspace_root and fix bug promotion body` (original fix)
2. **3ba0d3c4** — `refactor(mcp-repo-automation): split poshqc tool defs to fix size limit` (remediation cycle 1: R1 split, R2 tests, R3 deferral evidence, corrected coverage delta, cycle-0 audit artifacts, spec AC re-check-offs)

### Files Modified

1. **`extensions/drm-copilot/src/workflow-command-arguments.ts`** (MODIFIED) — fail-closed `normalizeWorkspaceRoot`.
2. **`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`** (MODIFIED, 402 lines) + **`mcp-repo-automation-tool-definitions-poshqc.ts`** (NEW, 123 lines) — `workspace_root` required for all tools; five PoshQC definitions extracted and spliced back (cycle 1).
3. **`mcp-discovery-tool-definitions.ts`**, **`mcp-tool-definitions.ts`** (MODIFIED) — `workspace_root` required (7 discovery; 18-tool test-only base mirror).
4. **`mcp-push-down-schema-properties.ts`** (MODIFIED) — description rewritten (required; no `process.cwd()` default).
5. **`mcp-tool-inputs.ts`** (MODIFIED, 477 lines) + **`mcp-tool-inputs-potential-to-issue.ts`** (NEW, 60 lines) — resolver extraction; relative `potential_path` resolved against `workspace_root`.
6. **`extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`** (MODIFIED) — bug-first `buildIssueBody` reorder; docblock and parity header corrected.
7. **`scripts/dev_tools/potential_to_issue.py`** (MODIFIED) — identical lockstep branch reorder (no change in cycle 1).
8. **Tests** — 14 TS test files (4 new); `tests/scripts/dev_tools/test_potential_to_issue.py` updated; **`test_potential_to_issue_branches.py`** (NEW, cycle 1, 408 lines, 10 branch-coverage cases).
9. **Docs** — repo/extension READMEs, four `execute-hard-lock/SKILL.md` copies.
10. **Feature docs/evidence** — spec, issue, plan, research, remediation inputs/plan, cycle-0 audit artifacts, and the full canonical evidence tree (baseline, remediation-baseline, qa-gates, regression-testing, other, issue-updates).

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT (zero Blocking findings)

All cycle-0 findings are closed or dispositioned: the Blocking R1 file-size violation is resolved by a verified pure module split; the R2 branch-coverage shortfall is resolved tests-only above thresholds; the R3 pre-existing overages are deferred with documented rationale under the granted discretion and precedent. Both language toolchains pass in a single pass on independent rerun at head `3ba0d3c4`; coverage passes for both languages with explicit per-module verification.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation inputs/plan present
- ✅ Design Principles: minimal, precedent-following pure split; tests-only coverage fix
- ⚠️ Module & File Structure: all branch-attributable files <= 500; two pre-existing overages deferred (Major, non-blocking, follow-up issue required)
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: single-pass green, independently rerun
- ✅ Summarize & Document: spec/issue/evidence updated

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python Tooling & Baseline / Design & Typing / Error Handling (zero suppressions)
- ✅ TypeScript Tooling & Baseline / Design & Standards (no new suppressions, no `any`, no new dependencies)

#### General Unit Test Policy (Section 1)
- ✅ Core Principles
- ✅ Coverage & Scenarios: TS PASS; Py PASS (cycle-0 PARTIAL resolved)
- ✅ Test Structure
- ✅ External Dependencies

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python Framework/Style/Naming/Coverage
- ✅ TypeScript Framework/Style/Coverage

### Metrics Summary

- ✅ 2031/2031 TS tests passing; 1992/1992 Py tests passing (independent reruns at head)
- ✅ TS coverage 96.34% lines / 89.21% branches
- ✅ Py coverage: modified module 95.00% lines / 81.82% branches; measured-set 90.98% / 81.83%
- ✅ File-size gate: all changed files <= 500 except the two documented R3-deferred pre-existing files
- ✅ All format/lint/type checks passing on independent rerun
- ✅ Evidence locations canonical (validator exit 0)

### Recommendation

**Approved — GO for PR authoring.** Blocking-finding count: 0. No remediation-inputs artifact is required this cycle. Post-merge follow-up: file a separate issue for the R3 decomposition of `potential_to_issue.py` (639) and `test_potential_to_issue.py` (1076), coordinating the production split with the TS/Python byte-parity contract.

---

## Appendix A: Test Inventory

New tests attributable to remediation cycle 1 (`tests/scripts/dev_tools/test_potential_to_issue_branches.py`, 10 cases):

1. test_real_gh_client_post_init_accepts_explicit_gh_path
2. test_real_gh_client_is_authenticated_false_when_path_unresolved
3. test_real_gh_client_command_raises_when_path_unresolved
4. test_promote_potential_rejects_invalid_work_mode
5. test_promote_potential_rejects_empty_content
6. test_promote_potential_wraps_invalid_mode_type_combination
7. test_relative_path_falls_back_to_absolute_on_value_error
8. test_minor_audit_uses_existing_evidence_checklist
9. test_missing_label_failure_without_retry_when_ensure_label_fails
10. test_create_success_without_issue_number_skips_view_and_metadata

Cycle-0 test inventory (20 representative entries across `workflow-command-arguments.test.ts`, `mcp-tool-inputs.workspace-root.test.ts`, `mcp-tools.workspace-root.test.ts`, `mcp-repo-automation-tool-definitions.test.ts`, `promotion.test.ts`, `promotion.matrix.test.ts`, `potential-to-issue-service-call.test.ts`, `test_potential_to_issue.py`) is unchanged and recorded in `policy-audit.2026-07-22T21-07.md` Appendix A; all pass at head `3ba0d3c4`.

---

## Appendix B: Toolchain Commands Reference

**For TypeScript (from `extensions/drm-copilot/`):**
```bash
# Formatting (check-only used in this reaudit)
npx prettier --check "src/**/*.ts" "test/**/*.ts"

# Linting
npm run lint

# Type checking
npm run typecheck

# Testing (explicit forward-slashed glob required under the worktree path)
node run-jest.cjs --testMatch "<absolute-forward-slashed-worktree-path>/extensions/drm-copilot/test/**/*.test.ts"
npm run test:coverage   # coverage artifact: extensions/drm-copilot/coverage/lcov.info
```

**For Python (from repo root):**
```bash
# Formatting (check-only)
poetry run black --check scripts/dev_tools tests/scripts/dev_tools

# Linting
poetry run ruff check scripts/dev_tools tests/scripts/dev_tools

# Type checking
poetry run pyright --outputjson scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue_content.py tests/scripts/dev_tools

# Testing + coverage (per-module verdict computed from the module row, not TOTAL)
poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term
# coverage artifact: artifacts/python/lcov.info
```

**Line-count and evidence-location verification:**
```bash
git diff --name-only a0b251d330525b8307467f4cf529c5cc3e947445..HEAD -- '*.ts' '*.py' | xargs wc -l
python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-07-22
**Policy Version:** Current (as of audit date)
