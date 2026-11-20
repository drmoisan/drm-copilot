# Policy Compliance Audit: Issue 1016 — migrate_development_docs tool and the .dev move (epic 1018 child 7)

**Audit Date:** 2026-11-20  
**Code Under Test:** merge base `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3` of the base branch `origin/epic/shared-agent-harness-layer-integration` and reviewed head `f744ce9e060a98dec1be9d393bba5c644e81ed61`; the diff between them lists the changed files (35872 paths: 35183 renames, 514 modifications, 174 additions, 1 deletion)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 23 production files (13 added, 10 modified) plus 75 test files | 6717 tests (root run) | ✅ 6717 pass, 0 fail | 97.59% lines, 94.95% branches (extension gate, Phase 0) | 97.59% lines, 94.95% branches (extension gate); root run 98.52% lines, 94.61% branches | 100% lines on 12 of 13 new files; CLI 96.5% lines, 95.12% branches; lowest new-file branch figure 85.71% |
| Python | 7 production files (2 hand-edited) plus 74 test files | 17104 tests | ✅ 17104 pass, 0 fail | 96.65% lines, 92.52% branches | 96.66% lines, 92.53% branches | 100% (11 new statements, 8 new branches in build_discovery_runtime.py) |
| PowerShell | 16 production files plus 13 bundle copies (1 hand-edited) plus 150 test files | 29157 tests | ✅ 29157 pass, 0 fail | 96.84% lines (47273/48814) | 96.84% lines (47286/48827) | 100% (13 new lines in ProcessReductionChain.psm1) |
| Bash | 1 production file plus 1 bundle copy plus 1 bats file | 14 tests | ✅ 14 pass, 0 fail | 89.8% lines (derived: no instrumented line differs from base) | 89.8% lines (kcov, report-lane-assertion.sh) | 100% (the changed line is heredoc text inside the executed usage block) |
| JSON | 8 files (routing copies, blast-radius, jest coverage map, tasks, fixture) | N/A | ✅ parse and parity tests pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/baseline/ts-test-coverage.2026-11-20T10-44.md` (stage B Phase 0) and `evidence/baseline/ts-test-coverage.2026-11-20T06-54.md` (stage A Phase 0)
- TypeScript post-change coverage artifact: `coverage/lcov.info` (root run by the reviewer, recorded in `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md`) and `evidence/qa-gates/ts-test-coverage.2026-11-20T18-10.md`
- Python baseline coverage artifact: `evidence/baseline/py-test-coverage.2026-11-20T10-49.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` and `evidence/qa-gates/py-test-coverage.2026-11-20T18-10.md`
- PowerShell baseline coverage artifact: `evidence/baseline/ps-test-coverage.2026-11-20T11-03.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` and `evidence/qa-gates/ps-test-coverage.2026-11-20T18-10.md`
- Per-language comparison summary: section 1.2.1 below and `evidence/qa-gates/coverage-delta.2026-11-20T18-10.md`

Baseline coverage is read from the plan's `Phase 0 baseline` artifacts. The Python and Pester artifacts were written at 17:54 to 18:09 UTC, after the last code commit `ed9f5e43d` (17:48 UTC); the head commit `f744ce9e0` changes only evidence and requirement documents. The canonical root `coverage/lcov.info` was absent at the start of the review; the reviewer ran one root Jest coverage run (19 s) to produce it. Its per-file figures for every changed TypeScript production file equal the executor's extension-gate figures.

---

## Executive Summary

The branch delivers stage A (the TypeScript migration tool `migrate_development_docs`, its MCP registration, CLI subcommand and tests) and stage B (the move of the development records from `docs/` to `.dev/`, the feature-folder rename, the flip of `development_docs_root` to `.dev`, and the dependent test, prose, template and ledger updates). Static stages and unit test stages pass for TypeScript, Python and PowerShell in one clean local pass; the changed bats suite passes; coverage meets every threshold with no regression. Two blocking findings remain: the tool's idempotence defect under `links-only` (F1) and the unmet user-story owner-presentation criterion that decision A14 replaced without a recorded supersession (F2). Four toolchain criteria are pending CI and are not findings.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (tier classification not applicable: no `quality-tiers.yml` at the base)
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md` + `.claude/rules/architecture-boundaries.md`
- ✅ `.claude/rules/python.md` + `.claude/rules/python-suppressions.md`
- ✅ `.claude/rules/powershell.md`
- ✅ Bash: bats run and kcov measurement by the reviewer; shellcheck and shfmt not rerun (one heredoc text line changed)
- ✅ JSON: routing parity and blast-radius tests

**Temporary artifacts cleanup:**
- ✅ All executor launchers and comparison scripts live under the issue scratch directory and are not committed
- ✅ No new tooling script is committed; the reviewer's launchers are in the session scratchpad

---

## Rejected Scope Narrowing

No narrowing was detected. The caller asked that the four toolchain criteria be classified `awaiting_ci`. That is a classification instruction, not a narrowing; the review reclassifies them as pending-CI criteria with no finding block (see section 8), because a purely CI-dependent criterion cannot be resolved before a pull request exists and a blocking entry for it would hold the PR gate.

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. All evidence is under `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/<kind>/` (before the self-move, under the old feature path, moved with the folder). Result: PASS.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head (`git ls-files docs` lists only `docs/README.md`). The check is not applicable and produces no finding.

## Vendored Coverage Exemptions

No `vendored-coverage-exemptions.json` exists beside a coverage output, no `.push-down-manifest.json` changed, and the only coverage configuration change is `extensions/drm-copilot/jest.config.cjs`, which adds a `coverageThreshold` map (`jest.development-docs-migration-coverage.json`) and no exclusion. Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New Jest suites build fakes per test (`migration-test-fakes.ts`: `InMemoryFileSystem`, `FakeMigrationGit`); full suites pass in parallel runs (Jest workers, pytest `-n auto`, Pester 8 workers). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One suite per new module; each `it` asserts one rule (for example one refusal rule per case in `migration-plan.test.ts`). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Root Jest 19 s for 6717 tests; pytest 139 s; Pester 711 s for 29157 tests. |
| **Determinism** - Consistent results | ✅ PASS | No clock or random use in the new tests; the executor removed two run-to-run coverage variances by adding deterministic tests (`final-qa-loop.2026-11-20T18-10.md`). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange-Act-Assert comments, descriptive `it` names. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** TypeScript 97.59% lines, 94.95% branches; Python 96.65% lines, 92.52% branches; PowerShell 96.84% lines<br>**Command:** one run of each gate in [P0-T5] to [P0-T7]<br>**Artifact:** `evidence/baseline/ts-test-coverage.2026-11-20T10-44.md`, `py-test-coverage.2026-11-20T10-49.md`, `ps-test-coverage.2026-11-20T11-03.md`<br>**Timestamp:** 2026-11-20 10:44 to 11:03 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** TypeScript 97.59%/94.95%; Python 96.66%/92.53%; PowerShell 96.84%<br>**Change:** +0.00 TypeScript, +0.01 Python lines and branches, +0.003 PowerShell lines<br>**Status:** No regression; no per-file drop on 46 changed production files (`coverage-delta.2026-11-20T18-10.md`, reproduced by the reviewer from the standing artifacts) |
| **Changed Files Meet Thresholds** | ✅ PASS | **Thresholds:** 85% lines, 75% branches (defaults; the root `CLAUDE.md` states none)<br>**Status:** Every changed production file meets the thresholds. Lowest: `mcp-server.ts` 88.37% lines, 82.35% branches; `enforce-evidence-locations.ps1` 89.13% lines; `report-lane-assertion.sh` 89.8% lines. `repo-automation-service-contract.ts` reports 0/346 at base and head; it holds only type and interface declarations (one added optional method signature) and is a type-only module under the coverage policy. |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** 13 new TypeScript production files; hand-edited `build_discovery_runtime.py`, `ProcessReductionChain.psm1`<br>**New code coverage:** 12 new TypeScript files at 100% lines, CLI 96.5% lines; Python new code 100% lines and branches; PowerShell new lines 13/13<br>**Calculation method:** per-file lcov and JaCoCo records of the final gate run |
| **Comprehensive Coverage** | ✅ PASS | One suite per new module (layout map, rename plan, reference rewrite, git seam, decisions, plan, apply, report, service call, inputs, handler, CLI, `main()` dispatch). |
| **Positive Flows** - Valid inputs | ✅ PASS | Mapping rows, mechanical renames, link recomputation at depths 3 to 5, apply of moves, renames, rewrites and README. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Every refusal rule in `migration-plan.test.ts` and `migration-decisions.test.ts`; CLI usage errors (exit 2). |
| **Edge Cases** - Boundary conditions | ⚠️ PARTIAL | Token boundaries, case-insensitive collisions, NUL-split paths with spaces are tested. Gap: no case applies a second run with `links-only` to a migrated tree whose moved records still hold an old prefix (F1). |
| **Error Handling** - Error paths | ✅ PASS | Handler error when `migrateDevelopmentDocs` is absent; `toFailureToolResult` path; CLI exit 1. |
| **Concurrency** - If applicable | N/A | The tool is synchronous; no concurrent behavior changed. |
| **State Transitions** - If applicable | ⚠️ PARTIAL | Moves-then-rewrites two-call transition is tested; the migrated-tree state under `links-only` is not (F1). |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.59% lines (94.95% branches) -> Post-change: 97.59% lines (94.95% branches). Change: +0.00% lines, +0.00% branches. New/changed-code coverage: 100% lines on 12 of 13 new files, 96.5% on the CLI. Disposition: PASS. Evidence: `coverage/lcov.info`, `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md`, `evidence/qa-gates/coverage-delta.2026-11-20T18-10.md`.
- Python: Baseline: 96.65% lines (92.52% branches) -> Post-change: 96.66% lines (92.53% branches). Change: +0.01% lines, +0.01% branches. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/py-test-coverage.2026-11-20T18-10.md`.
- PowerShell: Baseline: 96.84% lines -> Post-change: 96.84% lines. Change: +0.003% lines. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/ps-test-coverage.2026-11-20T18-10.md`.
- Bash: Baseline: 89.8% lines -> Post-change: 89.8% lines. Change: +0.0% lines. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md` (kcov of `report-lane-assertion.sh`).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact-value `toEqual` assertions on plans and file maps; Pester `-Because` reasons. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit AAA comments in the new suites. |
| **Document Intent** | ✅ PASS | Module headers cite the spec section each suite pins. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The new suites use in-memory fakes; no real git and no temporary file (spec criterion verified by reading `migration-test-fakes.ts`). |
| **Use Mocks/Stubs** | ✅ PASS | Fake `CommandRunner`, `FileSystem` and `MigrationGit`; the real planner and rewrite logic run. |
| **Environment Stability** | ✅ PASS | Forward-slash, case-explicit fixtures; repository-relative paths. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with the code review and feature audit of the same timestamp. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue 1016; `spec.md`, `user-story.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-10-30T18-59.md` (stage A) and `plan.2026-10-30T23-35.md` (stage B), all tasks checked. |
| **Document the plan** | ✅ PASS | Task-check evidence per task under `evidence/other/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Pure planner plus a thin applier; one dispatch case and one optional service method. |
| **Reusability** | ✅ PASS | Reuses child 2's parser, formatter and area map; reuses `CommandRunner` and `FileSystem`. |
| **Extensibility** | ✅ PASS | Owner-question inputs are decision-file values, not code. |
| **Separation of concerns** | ✅ PASS | Planning is pure; I/O is behind `MigrationGit` and `FileSystem`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One module per concern under `src/lib/development-docs-migration/`. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts of 361 changed covered files measured by the reviewer: largest `Get-EpicProgressReport.Tests.ps1` 699, `test_cli_part3.py` 689, `jest.config.cjs` 684. No file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | Exports limited to the planner, applier, report and seam factory. |
| **No circular dependencies** | ✅ PASS | The migration modules import downward only (layout map, rename plan, rewrite, decisions into plan; plan into apply and report). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `buildMigrationPlan`, `applyMigrationPlan`, `computeSourceDigest`. |
| **Docs/docstrings** | ✅ PASS | TSDoc on exported functions; README sections for the tool. |
| **Comment why, not what** | ✅ PASS | Decision references (A1, R4) in comments. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** Prettier check, Black check, PoshQC formatter<br>**Result:** 0 files flagged in each (`ts-static`, `py-static`, `ps-static` 2026-11-20T18-10) |
| **2. Linting** | ✅ PASS | **Command:** ESLint, Ruff, PSScriptAnalyzer<br>**Result:** 0 findings each |
| **3. Type checking** | ✅ PASS | **Command:** `npm run typecheck`, Pyright<br>**Result:** 0 errors; N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** Jest, pytest `-n auto`, `Invoke-PoshQCParallelTest`, bats<br>**Result:** all passing |
| **Full toolchain loop** | ✅ PASS | Stages 1 to 6 clean in pass 5 of 5; stage 7 (integration) runs in CI and is pending. dependency-cruiser is not configured in the repository; the no-`vscode` assertion is a Jest test. |
| **Explicit reporting** | ✅ PASS | `final-qa-loop.2026-11-20T18-10.md` records each pass and restart cause. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit subjects per task and phase. |
| **Design choices explained** | ⚠️ PARTIAL | Decisions A1 to A30, D-P4T3-1, D-P5-1 are recorded. D-P4T3-1 states that the 4570 listed records are not rewrite candidates under `links-only`; the code classifies them as outside moved trees, where apply mode rewrites them (F1). |
| **Update supporting documents** | ✅ PASS | `packages/mcp-server/README.md`, `extensions/drm-copilot/README.md`, `docs/README.md`. |
| **Provide next steps** | ✅ PASS | Remediation inputs of this review. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** 1071 files unchanged |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check .`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov=scripts --cov-branch`<br>**Result:** 17104 passed, 6 skipped |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | New helpers in `build_discovery_runtime.py` fully annotated. |
| **Dataclasses for value objects** | N/A | No new value object. |
| **Protocols/ABCs for interfaces** | N/A | No new interface. |
| **Avoid utility classes** | ✅ PASS | Module-level functions. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | No new exception path. |
| **Logging over print** | ✅ PASS | No print added. |
| **Invariants at construction** | N/A | No new class. |

No new Python file is added (name-status diff against the merge base, `scope-size-decisions.2026-11-20T18-12.md`, confirmed by the reviewer: no `A` entry with a `.py` extension).

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** PoshQC formatter over 1866 files<br>**Result:** 0 drift |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** per-file `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | None open. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Changes are string literals and one read-only fallback function; new suites `#Requires -Version 7.0` as siblings. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `Resolve-ProcessReductionLivePath` uses `CmdletBinding`. |
| **Parameter validation** | ✅ PASS | Mandatory parameters. |
| **Avoid global state** | ✅ PASS | No global variable. |
| **Error handling** | ✅ PASS | No swallowed error added. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | `ProcessReductionChain.psm1` 638 lines. |
| **Approved verbs** | ✅ PASS | `Resolve-` is approved. |
| **Comment why** | ✅ PASS | Fallback comment cites the moved-tree reason. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 drift. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 29157 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Five passes; restarts recorded. |

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** not rerun<br>**Result:** the change replaces text inside a heredoc body; no shell token changed |
| **Linting with shellcheck** | ✅ PASS | **Command:** not rerun<br>**Result:** same reason |
| **Testing with bats** | ✅ PASS | **Command:** `bats --jobs 4 tests/shell/report_lane_assertion_dispatch.bats` (WSL Ubuntu, reviewer run)<br>**Result:** 14 of 14 passed |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | Unchanged. |
| **Error handling** | ✅ PASS | Unchanged. |
| **At or below the 800-line hard limit** | ✅ PASS | Well below 700 lines. |

The executor's self-review states that no `.sh` or `.bats` file changed; that statement is inaccurate (`report-lane-assertion.sh`, its bundle copy and `report_lane_assertion_dispatch.bats` changed). The reviewer closed the gap by running bats and kcov. Non-blocking.

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** Prettier check covers `*.json` in the extension; other files keep existing key order<br>**Result:** unchanged formatting |
| **Schema validation** | ✅ PASS | **Command:** routing parity and blast-radius tests<br>**Result:** pass |
| **Required $schema** | ✅ PASS | Routing copies keep `$schema`. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | One-value and one-entry edits. |
| **Deterministic key order** | ✅ PASS | Existing order kept; `.dev` inserted in sorted position of `path_roots`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | pytest with xdist. |
| **Coverage expectation** | ✅ PASS | New code 100%; local repo-wide 96.66% lines, 92.53% branches; CI result recorded as pending in `## CI Cross-check`. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | `test_stream_keeps_polling_without_idle_timeout_until_exit` pins one edge. |
| **Mocking sparingly** | ✅ PASS | In-memory file system fakes. |
| **Organization** | ✅ PASS | Mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | Behavior-named tests. |
| **Docstrings/comments** | ✅ PASS | Docstrings present. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `pytest -n auto`<br>**Result:** 17104 passed |
| **No Alternative Test Runners** | ✅ PASS | pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester 6 through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`<br>**Config:** unchanged. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | As sibling suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | The two unresolved-target suites drive one return each. |
| **Test Behavior Over Implementation** | ✅ PASS | Assert hook decisions. |
| **Mocking Used Sparingly** | ✅ PASS | Isolation-guard closure-seam mocks only. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CleanupTargetUnresolved.Tests.ps1`<br>**Code file:** `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Correct suffix. |
| **Describe/Context/It Structure** | ✅ PASS | Standard structure. |
| **Logical Grouping** | ✅ PASS | One `Describe` per hook leg. |
| **Docstrings/Comments** | ✅ PASS | AAA comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`<br>**Result:** 29157 tests, 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### development-docs-migration modules (9 production files, 10 suites)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `migration-plan.test.ts` refusal cases | Negative | refusal block of `buildMigrationPlan` | ✅ |
| `migration-apply.test.ts` second apply | Edge Case | `applyMigrationPlan` | ✅ (fixture uses `references-and-links` only) |
| `reference-rewrite.test.ts` idempotence | Edge Case | `rewritePrefixes`, `recomputeRelativeLinks` | ✅ |
| `migration-decisions.test.ts` digest mismatch | Error Handling | `validateMigrationDecisions` | ✅ |

**Coverage:** 100% lines on every module; branches 85.71% to 100%.

**Not covered:** five branches in `folder-rename-plan.ts`, three in `migration-plan.ts`, one each in `migration-decisions.ts` and the service call.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 6717 Jest (root), 17104 pytest, 29157 Pester, 14 bats | ✅ |
| Tests Passed | all | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 19 s Jest, 139 s pytest, 711 s Pester | ✅ Fast |
| Average Time per Test | under 30 ms | ✅ Fast |
| Discovery Time | included above | ✅ |
| Functions/Classes Tested | all new exported functions | ✅ |
| Test File Size | largest changed test file 699 logical lines | ✅ PASS |
| Code Coverage (if applicable) | TypeScript 98.52% lines, 94.61% branches (root) | ✅ |

---

## 7. Code Quality Checks

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check` | 0 files flagged | ✅ |
| ESLint | `npm run lint` | 0 findings | ✅ |
| TSC | `npm run typecheck` | 0 errors | ✅ |
| Jest | `node run-jest.cjs --coverage` | 6717 passed | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 17104 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | PoshQC formatter | 0 drift | ✅ |
| PSScriptAnalyzer | per-file analyzer | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 29157 passed | ✅ |

**Notes:** the PSScriptAnalyzer step threw a NullReferenceException in passes 1 and 3 with no source change; the executor's launcher retries a file once on an analyzer exception and pass 5 recorded 0 retries. The tracked `testResults.xml` at the repository root was rewritten by the migration (one test-name string); harmless, noted in the code review.

---

## CI Cross-check

No pull request exists for the branch, so no CI run exists at the reviewed head; the outcomes below are claimed from local evidence for the orchestrator to compare at S9.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| TypeScript format, lint, typecheck | pass | 0 findings, 0 errors | f744ce9e0 | `evidence/qa-gates/ts-static.2026-11-20T18-10.md` |
| TypeScript Jest with coverage | pass | 6717 tests; 98.52% lines, 94.61% branches | f744ce9e0 | `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md` |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 17104 tests; 96.66% lines, 92.53% branches | f744ce9e0 | `evidence/qa-gates/py-test-coverage.2026-11-20T18-10.md` |
| Enforce Python coverage thresholds | pass | 96.66% lines, 92.53% branches | f744ce9e0 | `artifacts/python/lcov.info` |
| PoshQC analyze and format | pass | 0 findings, 0 drift | f744ce9e0 | `evidence/qa-gates/ps-static.2026-11-20T18-10.md` |
| PoshQC Pester tests | pass | 29157 tests; 96.84% lines | f744ce9e0 | `evidence/qa-gates/ps-test-coverage.2026-11-20T18-10.md` |
| shell-coverage / Shell Coverage (Bats + kcov) | pass | 14 tests; 89.8% lines for the changed file | f744ce9e0 | `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md` |
| Integration tests (stage 7) | pass | pending CI | f744ce9e0 | CI at S9 |

---

## 8. Gaps and Exceptions

### Identified Gaps

- F1 (blocking, autonomous): after the migration, `scanRewrites` in `extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts` (line 571) classifies every record under `.dev/` as outside the moved trees because `mapPath(path) === path`, so the in-tree scope `links-only` no longer protects it; in apply mode those 4570 records (37610 reference occurrences) are pushed to `plan.rewrites` with the prefix rule applied. A second apply on the migrated tree therefore does not produce an empty plan, which contradicts the spec `### Idempotence` rule and decision A3. The post-apply dry run lists the same files under `rewrites_outside_moved_trees`, and decision D-P4T3-1 records them as non-candidates, which does not match the code. The two discovery test files that keep the A5 resource key are also candidates and are not in the derived exclusions.
- F2 (blocking, autonomous): `user-story.md` scenario (c) still requires that the orchestrator present OQ-1 to OQ-13 to the owner. Decision A14 in `spec.md` replaced the owner stop with an orchestrator decision step under OD-1, but the user-story criterion carries no recorded supersession, so it is unmet as written.
- Pending CI (not findings): spec stage A toolchain criterion, spec stage B toolchain criterion, spec epic criterion "With `development_docs_root` set to `.dev`, the full toolchain passes", and user-story (d) toolchain criterion. Stages 1 to 6 pass locally; stage 7 runs in CI. These are checked off at S9 by the item's orchestrator under `### CI-Dependent Criteria`. The caller's requested `awaiting_ci` classification was not applied, for the reason given under `## Rejected Scope Narrowing`.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

The branch adds the TypeScript `migrate_development_docs` MCP tool and CLI subcommand, then uses it to move this repository's development records from `docs/` to `.dev/`, rename feature folders to `<NNNN>-<feature>`, and flip `development_docs_root` to `.dev` with the dependent test, prose, template and ledger updates.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, coverage, file size, evidence location and language rules are met. Two blocking findings (F1 tool idempotence under `links-only`, F2 unsuperseded user-story owner-presentation criterion) require remediation.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plans and spec read
- ✅ Design Principles: pure planner and seams
- ✅ Module & File Structure: no file at or above 700 lines
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: stages 1 to 6 clean; stage 7 pending CI
- ⚠️ Summarize & Document: D-P4T3-1 rationale does not match the code (F1)

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean
- ✅ Python Design & Typing: compliant
- ✅ Error Handling: compliant

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: compliant
- ✅ Structure & Naming: compliant
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ⚠️ Coverage & Scenarios: thresholds met; migrated-tree `links-only` scenario absent (F1)
- ✅ Test Structure: compliant
- ✅ External Dependencies: in-memory fakes
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: pytest
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: clean

**For PowerShell:**
- ✅ Framework & Scope: Pester 6
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: clean

### Metrics Summary

- ✅ 6717 Jest, 17104 pytest, 29157 Pester and 14 bats tests passing
- ✅ TypeScript 98.52% lines (root), Python 96.66%, PowerShell 96.84%
- ✅ No changed covered file at or above 700 lines
- ✅ Static stages clean in each language

### Recommendation

**Needs revision**

Fix F1 in `migration-plan.ts` with a test, re-run the post-apply dry run, and record a supersession for the user-story (c) criterion under A14 (F2). See `remediation-inputs.2026-11-20T18-20.md`.

---

## Appendix A: Test Inventory

### Complete Test List

- `extensions/drm-copilot/test/lib/development-docs-migration/layout-map.test.ts`
- `extensions/drm-copilot/test/lib/development-docs-migration/folder-rename-plan.test.ts`
- `extensions/drm-copilot/test/lib/development-docs-migration/reference-rewrite.test.ts`
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-git.test.ts`
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-decisions.test.ts`
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-plan.test.ts`
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-apply.test.ts`
- `extensions/drm-copilot/test/lib/development-docs-migration/migration-report.test.ts`
- `extensions/drm-copilot/test/lib/development-docs-migration/migrate-development-docs-service-call.test.ts`
- `extensions/drm-copilot/test/mcp-tool-inputs-development-docs.test.ts`
- `extensions/drm-copilot/test/mcp-handlers/development-docs-migration-handler.test.ts`
- `extensions/drm-copilot/test/migrate-development-docs-cli.test.ts`
- `extensions/drm-copilot/test/mcp-server.main.test.ts`
- `extensions/drm-copilot/test/mcp-tools.development-docs.test.ts`
- `extensions/drm-copilot/test/development-docs-migration-coverage-contracts.test.ts`
- `extensions/drm-copilot/test/lib/subprocess-runner.test.ts` (maxBuffer cases)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CleanupTargetUnresolved.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup-target-unresolved.Tests.ps1`
- `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` (live-path fallback cases)
- `tests/scripts/dev_tools/atomic_executor/test_cli_part4_part2.py::TestStreamCopilotOutput::test_stream_keeps_polling_without_idle_timeout_until_exit`
- `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` (moved-template key mapping)
- `tests/shell/report_lane_assertion_dispatch.bats`
- several hundred existing suites with path-literal updates (see the branch diff)

---

## Appendix B: Toolchain Commands Reference

**For TypeScript:**
```bash
node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=json-summary
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
```

**For Python:**
```bash
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest -n auto --cov=scripts --cov-branch
```

**For PowerShell:**
```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-20  
**Policy Version:** Current (as of audit date)
