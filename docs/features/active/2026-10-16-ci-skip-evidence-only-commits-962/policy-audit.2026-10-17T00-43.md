# Policy Compliance Audit: CI change-scope skip for evidence-only commits (Issue #962)

---

**Audit Date:** 2026-10-17
**Branch:** `bug/ci-skip-evidence-only-commits-962` @ `0f98da84e5474e9c09892b33c2fb2995b763457c`
**Base:** `origin/main` @ `b8fcd77905a51284cfbca54226a2da2a7916a836` (merge base `b8fcd77905a51284cfbca54226a2da2a7916a836`; the branch contains `origin/main`, `git merge-base --is-ancestor origin/main HEAD` exit 0)
**Feature folder:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/`
**Template source:** bundled template `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`. The MCP template-resolver tool is not in this agent's toolset, so the bundled file was read directly; its structure is identical to the repository copy under `docs/features/templates/policy_audit/`.

**Code Under Test (full branch diff, 112 files; 104 are feature-folder documentation and evidence):**

- PowerShell (new): `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`
- PowerShell tests (new): `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
- PowerShell tests (modified): `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`
- Python test (modified): `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`
- Bash (modified): `scripts/bash/shell_qc_lib.sh`, `scripts/bash/shell-qc.sh`; bats (modified): `tests/shell/test_shell_qc_commands.bats`
- GitHub Actions YAML (modified): `.github/workflows/ci.yml`, `_quality-checks.yml`, `_security-scan.yml`, `_build-check.yml`, `_poshqc.yml`, `_shell-coverage.yml`, `_drm-copilot-extension-tests.yml`
- JSON (new): `config/ci-docs-only-paths.json`; YAML config (modified): `quality-tiers.yml`
- Markdown (modified): `.github/workflows/README.md`; feature-folder documents and evidence; `docs/features/potential/promoted/2026-10-16-ci-skip-evidence-only-commits.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 8 files (2 production, 6 test) | 236 tests in the coverage run (146 new) | PASS 236 pass, 0 fail; coverage verdict FAIL (repo-wide figure not established) | 0.25% lines (scoped-run population, 46 of 18607; target files absent at baseline) | 1.54% lines (scoped-run population, 293 of 18990) | 93.08% lines `CiChangeScope.psm1` (121/130); 88.64% lines `Invoke-CiChangeScope.ps1` (78/88) |
| Python | 1 file (test only) | 6 tests in the changed file (80 across three files) | PASS 80 pass, 0 fail; coverage verdict FAIL (artifact absent) | 0.0% recorded - no measurement, `artifacts/python/lcov.info` absent (FAIL) | 0.0% recorded - no measurement, `artifacts/python/lcov.info` absent (FAIL) | 0.0% recorded - no Python production file changed and no measurement exists (FAIL) |
| Bash | 3 files (2 production, 1 bats) | 8 new bats tests (CI-only) | Not run locally; coverage verdict FAIL (artifact absent) | N/A - no kcov `cov.xml` present | N/A - no kcov `cov.xml` present | N/A - no kcov `cov.xml` present |
| YAML (GitHub Actions) | 7 workflow files | 39 workflow-invariant tests (counted in the first row) | PASS actionlint 0 findings | N/A (not a coverage language) | N/A (not a coverage language) | N/A |
| JSON | 1 file | 23 config contract tests (counted in the first row) | PASS parse and contract suite | N/A (config file) | N/A (config file) | N/A |

TypeScript and C#: zero changed files on the branch; no row is required.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/baseline/baseline-coverage-files.2026-10-16T23-25.md` and `evidence/baseline/baseline-pester-coverage.2026-10-16T23-25.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-10-17 00:18 UTC; parsed by this review) and `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/final-coverage-files.2026-10-17T00-19.md`
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/coverage-delta.2026-10-17T00-19.md`

---

## Executive Summary

The branch adds a `Change scope` decision job and a `CI full run` marker job to `.github/workflows/ci.yml`, a `run-heavy` boolean input with step-level gating in six reusable workflows, a pure PowerShell decision module with a thin I/O entry script under `scripts/ci/`, an allowlist in `config/ci-docs-only-paths.json`, four new Pester suites, a `quality-tiers.yml` entry, a README section, and the D14 follow-ups (blocking security scan, recursive bats discovery, an 85% bash line-coverage gate).

Implementation quality is consistent with the spec. The production PowerShell is formatted, analyzer-clean, at most 345 lines per file, separates pure logic from I/O with injectable seams, and fails closed on every error path. The two new production files exceed the 85% line threshold (93.08% and 88.64%, independently re-parsed from `artifacts/pester/powershell-coverage.xml` by this review).

The audit is not PASS because four verification obligations depend on a CI run that has not occurred (no PR exists and `gh run list` returns no runs for the branch):

1. `modified-workflow-needs-green-run`: seven workflow files changed, and no green run against the branch head exists.
2. PowerShell repo-wide coverage: the local artifact is a scoped run (12 suites, 1.54% of the 214-file population) and does not measure repo-wide coverage.
3. Python coverage: `artifacts/python/lcov.info` is absent. Only a Python test file changed.
4. Bash coverage: no kcov `cov.xml` exists locally; bats and kcov run only in the Linux CI job.

All four are classified `awaiting_ci`. One `workflow_dispatch` run of `ci.yml` on the branch head (the change-scope decision returns `code=true` for `workflow_dispatch`, so every heavy job runs) resolves all four.

**Policy documents evaluated:**
- [✅] `CLAUDE.md` and `.claude/rules/general-code-change.md`
- [✅] `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`
- [✅] `.claude/rules/ci-workflows.md` (pwsh workflow steps)

**Language-specific policies evaluated:**
- [✅] Python: `.claude/rules/python.md` (test-only change)
- [✅] PowerShell: `.claude/rules/powershell.md`
- [✅] Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov)
- [✅] JSON: strict JSON, contract suite
- [N/A] TypeScript, C#: zero changed files

**Temporary artifacts cleanup:**
- [✅] No temporary or one-time scripts are committed. The executor's launcher and recipe files were written to the session scratchpad, outside the repository (plan P0-T3).
- [✅] The only new reusable scripts (`scripts/ci/*`) are tested and policy-compliant.

## Rejected Scope Narrowing

None detected. The caller prompt supplied the branch, base, merge-base SHA, feature folder, PR-context artifact paths, and AC source. It did not narrow scope to a plan, task, phase, or file subset, and it did not exempt any language from coverage. This audit covers the full branch diff `b8fcd77905a51284cfbca54226a2da2a7916a836..0f98da84e5474e9c09892b33c2fb2995b763457c`.

## Evidence Location Compliance

- `git diff --name-only b8fcd779..HEAD -- artifacts/` returns no paths, so no file in the branch diff lives under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported violations.
- All 75 evidence files of the branch are under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`).
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry was required.

## Policy Rule: modified-workflow-needs-green-run

- Trigger: the branch modifies seven paths under `.github/workflows/**`.
- Green-run evidence: none. `gh run list --repo drmoisan/drm-copilot --branch bug/ci-skip-evidence-only-commits-962` returned `[]`, and `gh pr list --head bug/ci-skip-evidence-only-commits-962` returned `[]`. The remote branch head equals the local head (`0f98da84`).
- Verdict: FAIL, classified `awaiting_ci` (finding B-1 in the remediation inputs).
- Satisfying evidence: a successful `CI` run whose head SHA equals the branch head, or a predecessor-head run that satisfies condition (b) of the rule. The latest commit that changes a path outside the feature folder is `db3372db1`; later commits (`3857d1064`, `0f98da84e`) change only feature-folder paths. A `workflow_dispatch` run is acceptable under the rule.
- The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.

## Tier Classification

`quality-tiers.yml` exists at the repository root on the base branch, so tiers are adopted. The branch adds `path: "scripts/ci"`, `tier: T4`, with a rationale. `evidence/qa-gates/final-quality-tiers.2026-10-17T00-19.md` records `check_quality_tiers` exit 0. Verdict: PASS. T4 has no tier-dependent property-test, mutation, or escape-hatch obligation; the uniform coverage thresholds still apply.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `Invoke-CiChangeScope.Tests.ps1` builds a fresh scenario per row with `Get-TestScenario`; fakes record calls in per-row lists. No shared mutable state across `It` blocks. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One reason code or one allowlist rule per `It`, named with the AC it verifies (for example `writes code=true BASE_NOT_ANCESTOR when merge-base exits 1 (AC-7)`). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 236 tests in 2.85 s (`evidence/qa-gates/final-pester-coverage.2026-10-17T00-19.md`); the four new suites take 0.11 to 0.79 s each. |
| **Determinism** - Consistent results | ✅ PASS | No clock, RNG, network, or process use. `gh` and `git` are replaced by in-memory scriptblock fakes through `-GhInvoker` and `-GitInvoker`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Describe/Context/It grouping by decision stage; helper functions documented with comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 0.25% lines of the scoped-run population; both `scripts/ci` targets absent. **Artifact:** `evidence/baseline/baseline-coverage-files.2026-10-16T23-25.md` (Timestamp 2026-10-16T23-25). |
| **No Coverage Regression** | ✅ PASS (changed files) / ❌ FAIL (repo-wide figure not established) | Both PowerShell production files are new, so no changed-line regression is possible for them. Repo-wide PowerShell, Python, and Bash figures are not established by local artifacts (findings B-2, B-3, B-4). |
| **New Code Coverage >= 85% (governing threshold)** | ✅ PASS | `CiChangeScope.psm1` 121/130 = 93.08%; `Invoke-CiChangeScope.ps1` 78/88 = 88.64%. Re-parsed by this review from the `LINE` counters of `artifacts/pester/powershell-coverage.xml`. The root `CLAUDE.md` states no threshold, so the 85% line default governs; PowerShell has no branch gate. |
| **Comprehensive Coverage** | ✅ PASS (with a non-blocking gap) | All eight exported pure functions and all entry-script functions except the process boundary `Invoke-CiChangeScopeNative` are exercised. Several fail-closed validation branches have no test (unparseable job-list JSON in the entry script; invalid `exclude_prefixes` and empty `extensions` in the config parser); each fails closed, and the gap is recorded as code-review finding CR-3 (Minor). |
| **Positive Flows** - Valid inputs | ✅ PASS | Docs-only decision (AC-11), allowlist positives for each prefix and extension (AC-12), committed-config read. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Allowlist negatives (AC-13), invalid config forms (AC-14), malformed run and job JSON (AC-3, AC-4). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty diff, non-NUL-terminated diff output, upper-case extension, dot files, current-run exclusion, unsorted run order, skipped marker. |
| **Error Handling** - Error paths | ✅ PASS | `UNEXPECTED_ERROR` envelope with a `::warning::` annotation when a seam throws or the config is invalid (AC-14, AC-16). |
| **Concurrency** - If applicable | N/A | Single-threaded decision script; no shared state. |
| **State Transitions** - If applicable | ✅ PASS | The ordered decision stages (event gate, fork gate, run list, marker, ancestry, diff, classification) each have a test for the stage's terminating outcome. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 0.25% lines (scoped-run population; target files absent) -> Post-change: 1.54% lines (scoped-run population). Change: +1.29 percentage points on the scoped population; both measurements cover only the scanned suites, not the repository. New/changed-code coverage: 93.08% lines for `scripts/ci/CiChangeScope.psm1` and 88.64% lines for `scripts/ci/Invoke-CiChangeScope.ps1`, both above 85%. Disposition: FAIL (new-file thresholds pass; the repo-wide figure is not established by the scoped artifact, finding B-2, awaiting the `poshqc / PowerShell QC` merged-coverage line). Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/final-coverage-files.2026-10-17T00-19.md`, `evidence/qa-gates/coverage-delta.2026-10-17T00-19.md`.
- Python: Baseline: 0.0% recorded (no measurement; artifact absent) -> Post-change: 0.0% recorded (no measurement; artifact absent). Change: none measurable; the 0.0% values denote an absent measurement, not measured zero coverage. New/changed-code coverage: 0.0% recorded; no Python production file changed. Disposition: FAIL (coverage artifact absent for Python, which has a changed file; finding B-3, awaiting the `Enforce Python coverage thresholds` step of `quality-checks7`). Evidence: `artifacts/python/` does not exist in the worktree; `evidence/qa-gates/final-python-tests.2026-10-17T00-21.md` records that no coverage argument was passed.
- Bash: Baseline: N/A (no kcov report) -> Post-change: N/A (no kcov report). Change: none measurable. New/changed-code coverage: N/A. Disposition: FAIL (coverage artifact absent for Bash, which has changed production files; finding B-4, awaiting the `shell-coverage / Shell Coverage (Bats + kcov)` job and its new 85% gate). Evidence: the kcov output directory does not exist in the worktree; `evidence/regression-testing/p5-shell-static.2026-10-17T00-00.md` states bats and kcov are CI evidence.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use `-Because` with the rule being checked (for example `the entry point must not run when the script is dot-sourced`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each row arranges a scenario, calls `Invoke-TestScenario` or the pure function, then asserts outputs and call counts. |
| **Document Intent** | ✅ PASS | File header comments state the seam strategy; `It` names carry the AC identifier. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No process, network, or API call in the PowerShell suites. A grep for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Start-Process`, `Set-Content`, `Out-File`, `New-Item`, `Start-Sleep`, `Get-Date`, and direct `git`/`gh` invocation in the four new suites returned no match. |
| **Use Mocks/Stubs** | ✅ PASS | `-GhInvoker`, `-GitInvoker`, `-OutputWriter`, `-ReadVariable` fakes; `Mock Add-Content` and `Mock Write-Information` for the default writer. Bats uses checked-in stubs under `tests/fixtures/shell_qc/stub-bin/`. |
| **Environment Stability** | ✅ PASS | PowerShell suites create no files. The workflow and config suites read committed repository files only. The bats suite writes kcov output under the gitignored `artifacts/pester/kcov-bats` and removes it in `teardown`; this pattern pre-dates the branch. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the pre-PR review. Outstanding items: findings B-1 to B-4 (all `awaiting_ci`). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (Issue #962) define the objective: remove the second full CI run caused by evidence-only commits. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-16T23-15.md` records the policy reads; `research/research.2026-10-16T14-39.md` records the design study. |
| **Document the plan** | ✅ PASS | `plan.2026-10-16T10-27.md` with phase commit evidence `evidence/other/commit-phase-0` to `commit-phase-6`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Step-level gating with a single boolean input; the decision returns one of two values with a reason string. |
| **Reusability** | ✅ PASS | One `run-heavy` input shape reused across six workflows; the allowlist rules are data-driven from JSON. |
| **Extensibility** | ✅ PASS | Allowlist prefixes and extensions are configuration; the marker job name is a parameter of `Test-CiFullRunMarker`. |
| **Separation of concerns** | ✅ PASS | `CiChangeScope.psm1` has no I/O; `Invoke-CiChangeScope.ps1` owns `gh`, `git`, environment, and file writes behind seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Pure module and entry script each have a single purpose. |
| **Under 500 lines** | ✅ PASS | `CiChangeScope.psm1` 345; `Invoke-CiChangeScope.ps1` 271; tests 323, 98, 411, 323; `shell_qc_lib.sh` 432; `shell-qc.sh` 106; bats 265; `CiWorkflow.Tests.ps1` 255; `PoshQcWorkflow.Tests.ps1` 217; Python test 163 (`wc -l`). |
| **Public vs internal** | ✅ PASS | `Export-ModuleMember` lists exactly the eight spec functions. |
| **No circular dependencies** | ✅ PASS | The entry script imports the module; the module imports nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs (`Test-`, `ConvertFrom-`, `Get-`, `Select-`, `New-`, `Find-`, `Resolve-`, `Invoke-`, `Read-`, `Write-`). |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function. |
| **Comment why, not what** | ✅ PASS | For example the comment that a NUL is compared as a char because culture-aware comparison ignores NUL. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** PoshQC format via `sh SCRATCH/tools/run-cr.sh cr-format` (MCP format). **Result:** FORMAT-DRIFT-COUNT 0 (`evidence/qa-gates/final-format.2026-10-17T00-15.md`). Black `--check` on the Python test: unchanged (re-run by this review). shfmt `-d` exit 0 (`p5-shell-static`). |
| **2. Linting** | ✅ PASS | **Command:** PoshQC analyze (`cr-pssa`). **Result:** PSSA-TOTAL 0 for eight files (`final-pssa.2026-10-17T00-15.md`). Ruff on the Python test: `All checks passed!` (re-run by this review). shellcheck exit 0. actionlint 0 findings for seven workflows. |
| **3. Type checking** | ✅ PASS | Pyright clean (`final-python-types.2026-10-17T00-21.md`); N/A for PowerShell and bash. |
| **4. Testing** | ✅ PASS (local) | Pester 255 passed, 0 failed in one invocation (`final-pester-list.2026-10-17T00-15.md`); `artifacts/pester/pester-junit.xml` shows 236 tests, 0 failures, 0 errors. Pytest: 6 passed in the changed file (re-run by this review), 80 passed across three files. Bats: not run locally (CI only). |
| **Full toolchain loop** | ✅ PASS | `evidence/qa-gates/qa-loop.2026-10-17T00-21.md`: pass 2 ran P6-T1 to P6-T17 with no file changed by any stage. |
| **Explicit reporting** | ✅ PASS | Every stage has an evidence file with `Timestamp`, `Command`, and `EXIT_CODE`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit subjects describe each phase; see section 9. |
| **Design choices explained** | ✅ PASS | `spec.md` decisions D1 to D9 and D14; research Candidate B selected over A and C with reasons. |
| **Update supporting documents** | ✅ PASS | `.github/workflows/README.md` gains the change-scope section and the D14-a corrections. |
| **Provide next steps** | ✅ PASS | Proof procedure P0 to P3 in `spec.md` for the CI-dependent criteria. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`<br>**Result:** 1 file would be left unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright` (executor)<br>**Result:** clean per `final-python-types.2026-10-17T00-21.md`. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py -q -p no:cacheprovider`<br>**Result:** 6 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | The changed test function keeps its `-> None` annotation; the new constant is a typed module-level `str`. |
| **Dataclasses for value objects** | N/A | No value object introduced. |
| **Protocols/ABCs for interfaces** | N/A | No interface introduced. |
| **Avoid utility classes** | ✅ PASS | No class added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | Test-only change. |
| **Logging over print** | N/A | Test-only change. |
| **Invariants at construction** | N/A | Test-only change. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | PoshQC format, FORMAT-DRIFT-COUNT 0. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | PSSA-TOTAL 0. Two suppressions carry justifications (`PSUseSingularNouns` on the spec-fixed name `Select-CiGreenBaseCandidates`; `PSUseShouldProcessForStateChangingFunctions` on the pure factory `New-CiChangeScopeDecision`). |
| **Fix all findings** | ✅ PASS | No open findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The workflow runs the script with `shell: pwsh` (PowerShell 7) on `ubuntu-latest`; no 7-only syntax such as ternary or `??` is used. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every function has `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`, and `ValidateSet` on `Write-CiChangeScopeTarget -Target`. |
| **Avoid global state** | ✅ PASS | `Set-StrictMode -Version Latest`; no global variables. |
| **Error handling** | ✅ PASS | Specific `CI_*_INVALID:` error prefixes; catches re-throw anything outside their own prefix; a single top-level fail-closed envelope. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 345 and 271 lines. |
| **Approved verbs** | ✅ PASS | All verbs are approved PowerShell verbs. |
| **Comment why** | ✅ PASS | Comments explain fail-closed ordering and comparison semantics. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `final-format.2026-10-17T00-15.md`. |
| **Step 2: Analyze** | ✅ PASS | `final-pssa.2026-10-17T00-15.md`. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `final-pester-list.2026-10-17T00-15.md` (255 passed, 0 failed). |
| **Rerun loop if needed** | ✅ PASS | Two QA passes; pass 2 followed the #952 re-integration (`evidence/other/reintegration.2026-10-17T00-09.md`). |

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | shfmt `-d` exit 0 (`evidence/regression-testing/p5-shell-static.2026-10-17T00-00.md`). |
| **Linting with shellcheck** | ✅ PASS | shellcheck exit 0 (same artifact). |
| **Testing with bats** | ❌ FAIL (not yet run) | Bats does not run in this Windows worktree; the eight new tests run only in `shell-coverage / Shell Coverage (Bats + kcov)`. Tracked as finding B-4 and AC-37/AC-38 (pending CI). |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | Unchanged pre-existing shebangs. |
| **Error handling** | ✅ PASS | Tool exits captured with `|| rc=$?` per `.claude/rules/shell.md`; `check_coverage_threshold` returns 0, 1, or 2 with a printed reason. |
| **Under 500 lines** | ✅ PASS | 432, 106, 265 lines. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | `config/` files are not in the governed JSON set; the file is two-space indented strict JSON. |
| **Schema validation** | ✅ PASS | `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` (23 tests) validates the committed file against the D3 contract through `ConvertFrom-CiDocsOnlyPathConfig`. |
| **Required $schema** | N/A | Not a governed schema-bearing file. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | No comments or trailing commas. |
| **Deterministic key order** | ✅ PASS | Fixed order `version`, `include_prefixes`, `exclude_prefixes`, `extensions`, matching the spec. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Pytest 9.0.2. |
| **Coverage expectation** | ❌ FAIL | Python coverage artifact absent (finding B-3). No Python production file changed, so the expected outcome is no change from the base branch. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | The changed test asserts one condition value. |
| **Mocking sparingly** | ✅ PASS | No mocks; reads the committed workflow file. |
| **Organization** | ✅ PASS | Existing location `tests/scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | Test name unchanged; docstring updated to the new expectation. |
| **Docstrings/comments** | ✅ PASS | Docstring states scenario and expected outcome. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`<br>**Result:** 6 passed. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `Describe`/`Context`/`It`, `-ForEach`, `Should -Invoke`. |
| **Use PoshQC Configuration** | ✅ PASS | Runs through the PoshQC MCP runner with `source=config` coverage population (`final-pester-coverage.2026-10-17T00-19.md`). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | No version-specific syntax in the suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 54 pure-module tests, 30 entry-script tests, 23 config tests, 39 workflow-invariant tests. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions are on published outputs (`code=`, reason, summary) and on invoker call counts that the spec requires. |
| **Mocking Used Sparingly** | ✅ PASS | Only `Add-Content` and `Write-Information` are mocked, for the default-writer rows. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`<br>**Code files:** `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`<br>The test tree mirrors the source tree. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All four new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | The entry suite has one Describe and five Contexts. |
| **Logical Grouping** | ✅ PASS | Grouped by decision stage. |
| **Docstrings/Comments** | ✅ PASS | File header and helper comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | PoshQC MCP test runner (`final-mcp-test.2026-10-17T00-15.md`) and the coverage run. |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### scripts/ci/CiChangeScope.psm1 (54 tests in CiChangeScope.Tests.ps1, 23 in CiDocsOnlyPathsConfig.Tests.ps1)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Event-eligibility rows for `merge_group`, `push`, `workflow_dispatch`, fork, same-repo (AC-1, AC-2) | Positive/Negative | 11-35 | ✅ |
| Config parse rows: malformed JSON, version, include_prefixes, extension dot (AC-14) | Negative/Error Handling | 37-101 | ✅ |
| Allowlist positive and negative rows (AC-12, AC-13) | Positive/Negative/Edge Case | 103-144 | ✅ |
| NUL path-list rows: empty text, unterminated text, terminated list | Edge Case | 146-172 (line 169 uncovered) | ✅ |
| Path decision rows: empty, mixed, docs-only (AC-9, AC-10) | Positive/Negative | 174-196 | ✅ |
| Candidate selection rows: current run, foreign repo, unsorted (AC-5) | Positive/Edge Case | 198-255 | ✅ |
| Marker rows: success, skipped, other, absent (AC-6) | Positive/Negative | 257-299 | ✅ |
| Decision factory rows | Positive/Error Handling | 301-334 | ✅ |

**Coverage:** 93.08% (121 of 130 lines). **Not covered (from the `ci="0"` line entries of the coverage XML):** lines 62 (config JSON that is not an object), 81 (invalid `exclude_prefixes`), 86 (empty or non-array `extensions`), 169 (NUL list with an empty entry), 217 and 226 (blank or non-object run-list JSON), 273, 282, and 286 (blank, non-object, or `jobs`-less job-list JSON). All nine are fail-closed validation throws or returns; see code-review finding CR-3.

### scripts/ci/Invoke-CiChangeScope.ps1 (30 tests in Invoke-CiChangeScope.Tests.ps1)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Event and fork gates (AC-1, AC-2) | Negative | 185-188 | ✅ |
| Run-list and job-list failures (AC-3, AC-4, AC-6) | Error Handling | 114-165 | ✅ |
| Ancestry and diff rows (AC-7 to AC-11) | Positive/Negative/Error Handling | 205-233 | ✅ |
| Fail-closed envelope (AC-14, AC-16) | Error Handling | 254-261 | ✅ |
| Seams, context, default writer (AC-11, AC-15, AC-17) | Positive | 43-112 | ✅ |

**Coverage:** 88.64% (78 of 88 lines). **Not covered (from the coverage XML):** the native process boundary `Invoke-CiChangeScopeNative` (lines 38-40), the default `-ReadVariable` reader of `Get-CiChangeScopeContext` (line 87), the default `gh` and `git` invokers (lines 249-250), the executed-script entry block (lines 269-270), and the `JOB_LIST_FAILED` mapping for an unparseable job list (lines 157-158). Seven of the ten lines are host-bound wiring that tests cannot reach without starting a process; they remain in the denominator as the Coverage Exclusion Policy requires. Lines 157-158 are testable; see code-review finding CR-3.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 236 (coverage run); 255 (list run incl. hook and PoshQC suites) | ✅ |
| Tests Passed | 236 (100%); 255 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 2.85 s (coverage run) | ✅ Fast |
| Average Time per Test | about 12 ms | ✅ Fast |
| Discovery Time | 360 ms | ✅ |
| Functions/Classes Tested | 8/8 exported module functions; 6/7 entry-script functions (native boundary excluded) | ✅ |
| Test File Size | 98 to 411 lines | ✅ Maintainable |
| Code Coverage (if applicable) | 93.08% and 88.64% lines (new files); PowerShell has no branch metric | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | unchanged | ✅ |
| Ruff Linting | `poetry run ruff check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | clean (executor evidence) | ✅ |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py -q` | 6 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | PoshQC format via `cr-format` | 0 drift | ✅ |
| PSScriptAnalyzer | PoshQC analyze via `cr-pssa` | 0 findings | ✅ |
| Pester Tests | PoshQC test via `cr-pester-list` and `cr-pester-cov` | 255 and 236 passed, 0 failed | ✅ |

**For Bash and workflows:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt | `shfmt -d` (executor, `cr-shell-static`) | exit 0 | ✅ |
| shellcheck | `shellcheck` (executor, `cr-shell-static`) | exit 0 | ✅ |
| actionlint | `scripts/dev-tools/run-actionlint.ps1` and actionlint 1.7.11 | 0 findings, seven files | ✅ |

**Notes:** This review could not run Pester, bats, or kcov directly because the worktree isolation guard refuses commands naming `pwsh`, `bash`, or `wsl`. PowerShell results are taken from the executor evidence and cross-checked against `artifacts/pester/pester-junit.xml` (236 tests, 0 failures) and `artifacts/pester/powershell-coverage.xml`. Python checks were re-run by this review.

---

## 8. Gaps and Exceptions

### Identified Gaps

- B-1 `modified-workflow-needs-green-run`: no green `CI` run against the branch head exists (`awaiting_ci`).
- B-2 PowerShell repo-wide line coverage is not established: the local artifact covers 12 suites and reports 1.54% of a 214-file population, which is a scoped figure, not a repo-wide measurement (`awaiting_ci`; the `poshqc / PowerShell QC` job prints `Merged PowerShell line coverage`).
- B-3 Python coverage artifact `artifacts/python/lcov.info` absent while a Python file changed (`awaiting_ci`; the `quality-checks7` job enforces 85/75 in `Enforce Python coverage thresholds`).
- B-4 Bash coverage artifact absent while bash production files changed (`awaiting_ci`; the `shell-coverage` job runs kcov and, with this branch, enforces 85%).
- Pending-CI acceptance criteria AC-32, AC-33, AC-34, AC-36, AC-37, AC-38 are owned by the orchestrator's S9 gate and are not review blockers (see the feature audit).

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented. Existing assertions adjusted under D6: `CiWorkflow.Tests.ps1` (event-field allowlist for the five `changes` job lines), `PoshQcWorkflow.Tests.ps1` (gate step may carry the run-heavy condition), and the Python contract test (threshold step carries exactly the run-heavy gate). Each adjustment is recorded in `evidence/other/workflow-suite-adjustment.2026-10-17T00-12.md`.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **4aeb1ecbd** - ci(962): gate heavy CI steps on the change-scope decision
2. **042d039dc** - feat(962): add the change-scope entry script
3. **97a1423de** - feat(962): add the docs-only allowlist, the pure change-scope module, and the scripts/ci tier entry
4. **5a86f411e** - test(962): add failing change-scope, workflow-gating, and shell QC regression tests
5. **9c25ceed8** - docs(962): correct and extend the workflows README, make shell QC discovery recursive, and enforce 85% coverage
6. **32350256b** - Merge remote-tracking branch 'origin/main' (re-integration after #952)
7. **db3372db1** - ci(962): re-integrate origin/main and re-apply the change-scope gating
8. **3857d1064**, **0f98da84e** - docs(962): final QA evidence and Phase 6 commit evidence
9. Earlier commits (`d7b975636` to `ca5e895d5`, plus merges `e07e235d5` and `4e82b3a3c`): spec, research, plan revisions, Phase 0 baselines.

### Files Modified

1. **scripts/ci/CiChangeScope.psm1** (NEW) - eight pure decision functions.
2. **scripts/ci/Invoke-CiChangeScope.ps1** (NEW) - I/O entry script with seams and a dot-source guard.
3. **config/ci-docs-only-paths.json** (NEW) - allowlist, version 1.
4. **.github/workflows/ci.yml** (MODIFIED) - `changes` and `full-run-marker` jobs; caller `needs`/`if`/`with`; `on:` block unchanged.
5. **Six reusable workflows** (MODIFIED) - `run-heavy` input and step gating; `_security-scan.yml` adds the Poetry export plugin step, `shell: bash`, and removes `continue-on-error`.
6. **scripts/bash/shell_qc_lib.sh**, **scripts/bash/shell-qc.sh** (MODIFIED) - `--recursive` bats discovery; `check_coverage_threshold` with `SHELL_QC_MIN_LINE_COVERAGE` (default 85).
7. **Tests** - four new Pester suites, two adjusted Pester suites, one adjusted Python test, eight new bats tests.
8. **quality-tiers.yml**, **.github/workflows/README.md** (MODIFIED).

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Code, tests, toolchain, structure, evidence location, and tier classification comply. Four verification obligations (B-1 to B-4) remain open and all wait on a CI run of the branch head; none requires a code change.

**Fail-closed reminder:** This audit does not report PASS, because the repo-wide PowerShell figure, the Python coverage artifact, the Bash coverage artifact, and the workflow green run are absent.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan, and policy reads recorded.
- ✅ Design Principles: pure/I-O split, data-driven allowlist, fail-closed.
- ✅ Module & File Structure: all files under 500 lines.
- ✅ Naming, Docs, Comments: approved verbs, comment-based help.
- ✅ Toolchain Execution: two clean QA passes.
- ✅ Summarize & Document: README section and proof procedure.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright, Pytest clean.
- ✅ Python Design & Typing: test-only change.
- ✅ Error Handling: N/A, test-only.

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean.
- ✅ PowerShell Design & Safety: advanced functions, strict mode, fail-closed envelope.
- ✅ Structure & Naming: approved verbs, under 500 lines.
- ✅ Toolchain: Pester 255/255.

**For Bash:**
- ✅ shfmt and shellcheck clean.
- ⚠️ bats and kcov pending CI (B-4).

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic, isolated, fast.
- ⚠️ Coverage & Scenarios: new-file coverage passes; repo-wide PowerShell, Python, and Bash coverage pending CI.
- ✅ Test Structure: AAA, named per AC.
- ✅ External Dependencies: no process, network, or temporary file in PowerShell suites.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest.
- ✅ Test Style & Structure: focused assertion.
- ✅ Naming & Readability: docstring updated.
- ❌ Coverage: artifact absent (B-3).

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC.
- ✅ Test Style & Structure: seams and fakes.
- ✅ Naming & Readability: AC-tagged names.
- ✅ Toolchain: clean.

---

### Metrics Summary

- ✅ 255/255 Pester tests passing (100%); 236/236 in the coverage run
- ✅ 6/6 Python tests in the changed file passing
- ✅ 93.08% and 88.64% line coverage on the two new PowerShell files
- ❌ Repo-wide PowerShell, Python, and Bash coverage not established locally
- ✅ Test files mirror the source tree under `tests/scripts/ci/`
- ✅ Format, lint, analyzer, and actionlint checks clean
- ✅ Test execution time: 2.85 seconds (fast)

---

### Recommendation

**Blocked (awaiting CI)**

Dispatch `ci.yml` against the branch head (`gh workflow run ci.yml --repo drmoisan/drm-copilot --ref bug/ci-skip-evidence-only-commits-962`) or open the PR, wait for the run to conclude `success`, and re-run this review with the run identifier. The run resolves B-1 (green run), B-2 (the `Merged PowerShell line coverage` line of `poshqc / PowerShell QC`), B-3 (the `Enforce Python coverage thresholds` step of every `quality-checks7` leg), and B-4 (the `Bash coverage NN.N% meets the minimum line coverage of 85%.` line of `shell-coverage`). No code change is required by this review.

---

## Appendix A: Test Inventory

### Complete Test List

1. `tests/scripts/ci/CiChangeScope.Tests.ps1` - 54 tests: event eligibility, config parsing, allowlist positives and negatives, NUL path list, path decision, candidate selection, full-run marker, decision factory.
2. `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` - 23 tests: committed config contract (AC-15).
3. `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` - 30 tests: event and fork gates; run and job list failures; ancestry and diff; fail-closed envelope; seams, context, default writer.
4. `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` - 39 tests: AC-18 to AC-21 and AC-36 workflow invariants.
5. `tests/scripts/workflows/CiWorkflow.Tests.ps1` - 4 tests (one assertion adjusted).
6. `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` - 15 tests (one assertion adjusted).
7. `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` - 35 tests, unchanged (AC-28).
8. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` - 6 tests (one assertion adjusted).
9. `tests/shell/test_shell_qc_commands.bats` - 30 tests, 8 new: two `--recursive` tests and six `check_coverage_threshold` tests.

---

## Appendix B: Toolchain Commands Reference

**Commands run by this review:**
```bash
git rev-parse HEAD
git merge-base HEAD origin/main
git diff --stat b8fcd77905a51284cfbca54226a2da2a7916a836..HEAD
git diff --name-status b8fcd77905a51284cfbca54226a2da2a7916a836..HEAD
git diff --name-only b8fcd77905a51284cfbca54226a2da2a7916a836..HEAD -- artifacts/
git log --oneline b8fcd77905a51284cfbca54226a2da2a7916a836..HEAD
git merge-base --is-ancestor origin/main HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py -q -p no:cacheprovider
poetry run ruff check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
poetry run black --check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
gh run list --repo drmoisan/drm-copilot --branch bug/ci-skip-evidence-only-commits-962 --limit 10 --json databaseId,workflowName,event,headSha,status,conclusion
gh pr list --repo drmoisan/drm-copilot --head bug/ci-skip-evidence-only-commits-962 --json number,state
git ls-remote origin refs/heads/bug/ci-skip-evidence-only-commits-962
awk (LINE counter extraction for the scripts/ci package of artifacts/pester/powershell-coverage.xml)
grep (test-hygiene scan of tests/scripts/ci/*.ps1 and CiChangeScopeWorkflow.Tests.ps1)
wc -l (file-size check)
```

**Executor commands relied on (from feature evidence):**
```powershell
# Formatting, analysis, tests, coverage (PoshQC through the MCP runner)
sh SCRATCH/tools/run-cr.sh cr-format -PathList "<eight PowerShell files>" -Write
sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "<eight PowerShell files>"
sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "<eleven suites>"
sh SCRATCH/tools/run-cr.sh cr-pester-cov -ScanFolderList "tests/scripts/ci,tests/scripts/workflows,tests/scripts/claude-lib/ci-gate"
sh SCRATCH/tools/run-cr.sh cr-cov-files -TargetList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1"
sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList "<seven workflow files>"
sh SCRATCH/tools/run-cr.sh cr-shell-static
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-17
**Policy Version:** Current (as of audit date)
