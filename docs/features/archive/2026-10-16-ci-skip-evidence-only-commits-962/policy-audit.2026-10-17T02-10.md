# Policy Compliance Audit: CI change-scope skip for evidence-only commits (Issue #962)

---

**Audit Date:** 2026-10-17
**Audit Type:** Re-audit after remediation cycle 1 (supersedes `policy-audit.2026-10-17T00-43.md`)
**Branch:** `bug/ci-skip-evidence-only-commits-962` @ `8be7c95da5af05f6a9464a776469a380b400c0e2` (equal to the remote branch head, `git ls-remote`)
**Base:** `origin/main` @ `b8fcd77905a51284cfbca54226a2da2a7916a836` (merge base `b8fcd77905a51284cfbca54226a2da2a7916a836`; `git ls-remote origin refs/heads/main` returns the same SHA, so the branch is current with `main`)
**Feature folder:** `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/`
**CI run of record:** `CI` run 38992247041 (`workflow_dispatch`, `ci.yml`) on head `8be7c95da5af05f6a9464a776469a380b400c0e2`, conclusion `success`, 23 of 23 jobs `success` (`gh run view 38992247041 --json headSha,conclusion,event,jobs`).
**Template source:** the structure of the bundled template `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, as used by the prior audit.

**Code Under Test (full branch diff, 141 files; 108 are feature-folder evidence files and further files are feature-folder documents):**

- PowerShell (new): `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`
- PowerShell tests (new): `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
- PowerShell tests (modified): `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`
- Python test (modified): `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`
- Bash (modified): `scripts/bash/shell_qc_lib.sh`, `scripts/bash/shell-qc.sh`; bats (modified): `tests/shell/test_shell_qc_commands.bats`
- GitHub Actions YAML (modified): `.github/workflows/ci.yml`, `_quality-checks.yml`, `_security-scan.yml`, `_build-check.yml`, `_poshqc.yml`, `_shell-coverage.yml`, `_drm-copilot-extension-tests.yml`
- JSON (new): `config/ci-docs-only-paths.json`; YAML config (modified): `quality-tiers.yml`
- Markdown (modified): `.github/workflows/README.md`; feature-folder documents and evidence; `docs/features/potential/promoted/2026-10-16-ci-skip-evidence-only-commits.md`

**Delta since the prior audit (`0f98da84e..8be7c95da`, outside the feature folder):** `.github/workflows/_security-scan.yml` (one line, `continue-on-error: true` on the scan step), `.github/workflows/README.md` (one line, `### Security scan` body), `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` (row W18 replaced, 323 to 325 lines). Commit `d91d8e274`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 8 files (2 production, 6 test) | 11129 Pester tests in CI (three shards) | PASS 0 failures, 0 errors in each shard junit | 92.16% lines repo-wide (17300 of 18772, base-commit CI run 38982032960) | 92.15% lines repo-wide (17499 of 18990, CI merged coverage) | 93.08% lines `CiChangeScope.psm1` (121/130); 88.64% lines `Invoke-CiChangeScope.ps1` (78/88), both from the CI merged XML |
| Python | 1 file (test only) | 7278 passed, 6 skipped per leg (3.10 to 3.13) | PASS in all four `quality-checks7` legs | 93.97% lines repo-wide (17731 statements, 1070 missed, base-commit CI run 38982032960) | 93.97% lines repo-wide (17731 statements, 1070 missed); branch threshold 75% enforced and met by `Enforce Python coverage thresholds` | 93.97% lines (repo-wide figure; no Python production file changed, and the changed test file is excluded from measurement) |
| Bash | 3 files (2 production, 1 bats) | 733 bats tests in CI, 0 `not ok` | PASS | 95.2% lines repo-wide (base-commit CI run 38982032960, 725 bats tests) | 95.2% lines repo-wide (3272 of 3437, kcov `cov.xml`) | Modified files: `shell_qc_lib.sh` 91.3%, `shell-qc.sh` 88.6%; no uncovered line in any changed hunk |
| YAML (GitHub Actions) | 7 workflow files | 39 workflow-invariant tests (counted in the first row) | PASS actionlint 0 findings; CI run 38992247041 success | N/A (not a coverage language) | N/A (not a coverage language) | N/A |
| JSON | 1 file | 23 config contract tests (counted in the first row) | PASS parse and contract suite | N/A (config file) | N/A (config file) | N/A |

TypeScript and C#: zero changed files on the branch; no row is required.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/baseline/baseline-coverage-files.2026-10-16T23-25.md` and `evidence/baseline/baseline-pester-coverage.2026-10-16T23-25.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, which is the CI artifact `poshqc-test-results` of run 38992247041 (head `8be7c95da`), parsed by this review; log line of job 117279847607 `Merged PowerShell line coverage: 17499 of 18990 lines (92.15%), 1491 missed.`
- Local artifact provenance: at review time `artifacts/pester/powershell-coverage.xml` held the output of the remediation cycle's PoshQC MCP test run (P2-T5, scan folder `tests/scripts/workflows` only, written 2026-10-17 01:38 UTC). It reported `LINE missed="18990" covered="0"` because the workflow-invariant suites load no production code, so it measured a scoped run, not the whole repository. This review preserved that file in the session scratchpad and replaced the gitignored local file with the CI merged file for the same head (SHA-256 `fdf66288b40db7817fd6009ba2ca306b20a4074448528c085ae4b55bb88b32c5`, identical to the downloaded CI artifact). Coverage was not regenerated; the replacement file is the full-suite measurement that CI produced for head `8be7c95da`.
- Python post-change coverage: log of jobs 117277015585, 117277015538, 117277015587, 117277015551 (`TOTAL 17731 1070 6398 475 93%`; step `Enforce Python coverage thresholds` with `--min-line 85 --min-branch 75` succeeded)
- Bash post-change coverage artifact: CI artifact `shell-coverage` of run 38992247041 (`cov.xml`); log of job 117277015644 `Bash coverage (lines): 95.2%` and `Bash coverage 95.2% meets the minimum line coverage of 85%.`
- Per-language comparison summary: section 1.2.1 of this audit; previous-run headlines in `evidence/qa-gates/ci-coverage-headlines.2026-10-17T01-21.md`

---

## Executive Summary

The branch adds a `Change scope` decision job and a `CI full run` marker job to `.github/workflows/ci.yml`, a `run-heavy` boolean input with step-level gating in six reusable workflows, a pure PowerShell decision module with a thin I/O entry script under `scripts/ci/`, an allowlist in `config/ci-docs-only-paths.json`, four new Pester suites, a `quality-tiers.yml` entry, a README section, and the D14 follow-ups (security scan with a working export, recursive bats discovery, an 85% bash line-coverage gate).

The prior audit (`policy-audit.2026-10-17T00-43.md`) left four `awaiting_ci` findings (B-1 to B-4). The first CI run (38988542731) then failed `security-scan / Security Scanning` on 101 pre-existing `poetry.lock` advisories (remediation input RI-1). Remediation cycle 1 (commit `d91d8e274`) restored `continue-on-error: true` on the scan step only, replaced Pester row W18, and updated the README subsection.

CI run 38992247041 on the current head concluded `success` with 23 of 23 jobs `success`. It resolves all four carried findings:

1. B-1 `modified-workflow-needs-green-run`: a green `CI` run exists for the exact head SHA. Resolved.
2. B-2 PowerShell repo-wide coverage: 92.15% lines (17499 of 18990) from the merged coverage of the full suite. Resolved.
3. B-3 Python coverage: 93.97% lines repo-wide; the 85/75 threshold step passed on every leg. Resolved.
4. B-4 Bash coverage: 95.2% lines; the new 85% gate printed its pass line. Resolved.

RI-1 is resolved: the scan step ran a non-vacuous scan (78 packages scanned, 101 findings reported) and the job concluded `success`.

No blocking finding remains. Three Minor code-review findings (CR-1 to CR-3) remain as non-blocking recommendations.

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
- [✅] No temporary or one-time scripts are committed. The executor's launcher and recipe files were written to the session scratchpad, outside the repository.
- [✅] The only new reusable scripts (`scripts/ci/*`) are tested and policy-compliant.

## Rejected Scope Narrowing

None detected. The caller prompt supplied the branch, base, merge-base SHA, head SHA, feature folder, PR-context artifact paths, AC source, and CI facts, and it requested a full re-audit with no scope narrowing. It stated that AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38 are checked off by the orchestrator at S9; that is the ownership rule of `.claude/skills/acceptance-criteria-tracking/SKILL.md` (`### CI-Dependent Criteria`), not a narrowing of audit scope, and those criteria are still evaluated in the feature audit. No language was exempted from coverage. This audit covers the full branch diff `b8fcd77905a51284cfbca54226a2da2a7916a836..8be7c95da5af05f6a9464a776469a380b400c0e2`.

## Evidence Location Compliance

- `git diff --name-only b8fcd779..HEAD -- artifacts/` returns no paths, so no file in the branch diff lives under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported violations (re-run by this review on head `8be7c95da`).
- All 108 evidence files of the branch are under `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`, `remediation-baseline`).
- This review wrote no evidence files; CI artifacts it parsed were downloaded to the session scratchpad, outside the repository.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry was required.

## Policy Rule: modified-workflow-needs-green-run

- Trigger: the branch modifies seven paths under `.github/workflows/**`.
- Green-run evidence: `CI` run 38992247041, event `workflow_dispatch`, `headSha` `8be7c95da5af05f6a9464a776469a380b400c0e2` (equal to the branch head), conclusion `success`, 23 of 23 jobs `success`.
- The `Change scope` job logged `code=true reason=EVENT_NOT_PULL_REQUEST`, so every heavy step ran.
- Verdict: PASS. Prior finding B-1 is resolved.
- The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.

## Tier Classification

`quality-tiers.yml` exists at the repository root on the base branch, so tiers are adopted. The branch adds `path: "scripts/ci"`, `tier: T4`, with a rationale. `evidence/qa-gates/final-quality-tiers.2026-10-17T00-19.md` records `check_quality_tiers` exit 0, and the `quality-checks7` legs passed in CI. Verdict: PASS. T4 has no tier-dependent property-test, mutation, or escape-hatch obligation; the uniform coverage thresholds still apply.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `Invoke-CiChangeScope.Tests.ps1` builds a fresh scenario per row with `Get-TestScenario`; fakes record calls in per-row lists. No shared mutable state across `It` blocks. The suites also pass in the sharded CI layout. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One reason code or one allowlist rule per `It`, named with the AC it verifies. The new W18 row asserts one step's configuration. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 236 tests in 2.85 s locally (`evidence/qa-gates/final-pester-coverage.2026-10-17T00-19.md`); W18 took 0.007 s in CI. |
| **Determinism** - Consistent results | ✅ PASS | No clock, RNG, network, or process use. `gh` and `git` are replaced by in-memory scriptblock fakes. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Describe/Context/It grouping by decision stage; helper functions documented with comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 0.25% lines of the scoped local population; both `scripts/ci` targets absent. **Artifact:** `evidence/baseline/baseline-coverage-files.2026-10-16T23-25.md` (Timestamp 2026-10-16T23-25). |
| **No Coverage Regression** | ✅ PASS | PowerShell production files are new. In the two modified bash files, no line of any changed hunk is uncovered: the uncovered lines of `shell_qc_lib.sh` (98, 142-147, 213-219, 358-359, 377, 398, 403, 406, 414, 420) and `shell-qc.sh` (53, 54, 60, 61) are all outside the changed hunks (234-235, 264, 311-342, 353-354, 401, 425-426, 429; 37-39). No Python production file changed. |
| **New Code Coverage >= 85% (governing threshold)** | ✅ PASS | `CiChangeScope.psm1` 121/130 = 93.08%; `Invoke-CiChangeScope.ps1` 78/88 = 88.64% (CI merged XML, `LINE` counters). The root `CLAUDE.md` states no threshold, so the 85% line and 75% branch defaults govern; PowerShell has no branch gate. |
| **Comprehensive Coverage** | ✅ PASS (with a non-blocking gap) | All eight exported pure functions and all entry-script functions except the process boundary `Invoke-CiChangeScopeNative` are exercised. Several fail-closed validation branches have no test; recorded as code-review finding CR-3 (Minor). |
| **Positive Flows** - Valid inputs | ✅ PASS | Docs-only decision (AC-11), allowlist positives (AC-12), committed-config read. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Allowlist negatives (AC-13), invalid config forms (AC-14), malformed run and job JSON (AC-3, AC-4). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty diff, non-NUL-terminated diff output, upper-case extension, dot files, current-run exclusion, unsorted run order, skipped marker. |
| **Error Handling** - Error paths | ✅ PASS | `UNEXPECTED_ERROR` envelope with a `::warning::` annotation (AC-14, AC-16). |
| **Concurrency** - If applicable | N/A | Single-threaded decision script; no shared state. |
| **State Transitions** - If applicable | ✅ PASS | Each ordered decision stage has a test for its terminating outcome. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.16% lines repo-wide (17300 of 18772; `poshqc / PowerShell QC` of base-commit run 38982032960) -> Post-change: 92.15% lines repo-wide (17499 of 18990, CI merged coverage of the full suite, job 117279847607). Change: -0.01 percentage points, caused by 218 new production lines at 91.3% combined (199 covered) entering the denominator; the repo-wide figure stays above the 85% threshold, and no modified PowerShell production file exists, so no changed-line regression is possible. New/changed-code coverage: 93.08% (`scripts/ci/CiChangeScope.psm1`) and 88.64% (`scripts/ci/Invoke-CiChangeScope.ps1`), both above 85%, identical in the local and CI artifacts. Disposition: PASS. Evidence: CI artifact `poshqc-test-results` (`powershell-coverage.xml`), job log line `Merged PowerShell line coverage: 17499 of 18990 lines (92.15%), 1491 missed.`. Note: CI does not enforce a PowerShell threshold (`CoveragePercentTarget = 0`); this review read the printed value.
- Python: Baseline: 93.97% lines repo-wide (17731 statements, 1070 missed; base-commit run 38982032960, leg 3.10) -> Post-change: 93.97% lines repo-wide (17731 statements, 1070 missed; `TOTAL` row 93% combined). Change: 0.00 percentage points; the `TOTAL` rows are identical. New/changed-code coverage: 93.97% lines (repo-wide figure); no Python production file changed, and the changed test file is excluded from measurement. Branch coverage: the `Enforce Python coverage thresholds` step (`check_python_coverage_thresholds --min-line 85 --min-branch 75`) succeeded on all four legs, so branch coverage is at least 75%. Disposition: PASS. Evidence: logs of jobs 117277015585 (3.10), 117277015538 (3.11), 117277015587 (3.12), 117277015551 (3.13).
- Bash: Baseline: 95.2% lines repo-wide (base-commit run 38982032960, 725 bats tests) -> Post-change: 95.2% lines repo-wide (3272 of 3437, 733 bats tests). Change: 0.0 percentage points at the printed precision; no changed line is uncovered. New/changed-code coverage: `scripts/bash/shell_qc_lib.sh` 91.3%, `scripts/bash/shell-qc.sh` 88.6%, both above 85%. Disposition: PASS. Evidence: CI artifact `shell-coverage` (`cov.xml`), job 117277015644 log lines `Bash coverage (lines): 95.2%` and `Bash coverage 95.2% meets the minimum line coverage of 85%.`; kcov reports no branch data, and no branch gate applies to bash.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use `-Because`; the new W18 assertions state the PD-18 reason and the step-placement rule. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each row arranges a scenario, calls the unit, then asserts outputs and call counts. |
| **Document Intent** | ✅ PASS | File header comments state the seam strategy; `It` names carry the AC identifier. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No process, network, or API call in the PowerShell suites; the W18 replacement adds none (`evidence/qa-gates/rem1-hermetic.2026-10-17T01-39.md`, `HERMETIC-HITS: 0`). |
| **Use Mocks/Stubs** | ✅ PASS | `-GhInvoker`, `-GitInvoker`, `-OutputWriter`, `-ReadVariable` fakes; bats uses checked-in stubs under `tests/fixtures/shell_qc/stub-bin/`. |
| **Environment Stability** | ✅ PASS | PowerShell suites create no files. The bats suite writes kcov output under the gitignored `artifacts/pester/kcov-bats` and removes it in `teardown`; the pattern pre-dates the branch. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This re-audit is the pre-PR review. No blocking finding remains. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (Issue #962) define the objective. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-16T23-15.md` and `evidence/remediation-baseline/phase0-instructions-read.2026-10-17T01-29.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-16T10-27.md` and `remediation-plan.2026-10-17T01-20.md`, with commit evidence `evidence/other/commit-phase-0` to `commit-phase-6` and `commit-remediation-1.2026-10-17T01-40.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Step-level gating with a single boolean input; the remediation is a one-line workflow change. |
| **Reusability** | ✅ PASS | One `run-heavy` input shape reused across six workflows; allowlist rules are data-driven from JSON. |
| **Extensibility** | ✅ PASS | Allowlist prefixes and extensions are configuration. |
| **Separation of concerns** | ✅ PASS | `CiChangeScope.psm1` has no I/O; `Invoke-CiChangeScope.ps1` owns `gh`, `git`, environment, and file writes behind seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Pure module and entry script each have a single purpose. |
| **Under 500 lines** | ✅ PASS | `CiChangeScope.psm1` 345; `Invoke-CiChangeScope.ps1` 271; tests 323, 98, 411, 325; `shell_qc_lib.sh` 432; `shell-qc.sh` 106; bats 265; `_security-scan.yml` 51 (`wc -l`). |
| **Public vs internal** | ✅ PASS | `Export-ModuleMember` lists exactly the eight spec functions. |
| **No circular dependencies** | ✅ PASS | The entry script imports the module; the module imports nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs throughout. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function. |
| **Comment why, not what** | ✅ PASS | Comments explain fail-closed ordering and comparison semantics; the README states why the scan step is non-blocking. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** PoshQC format via `cr-format`. **Result:** FORMAT-DRIFT-COUNT 0 (`final-format.2026-10-17T00-15.md`; `rem1-format.2026-10-17T01-37.md` for the W18 file). shfmt `-d` exit 0 (`p5-shell-static`). Black clean in CI. |
| **2. Linting** | ✅ PASS | **Command:** PoshQC analyze (`cr-pssa`). **Result:** PSSA-TOTAL 0 (`final-pssa.2026-10-17T00-15.md`; `rem1-pssa.2026-10-17T01-37.md`). Ruff `All checks passed!` in every `quality-checks7` leg. shellcheck exit 0. actionlint 0 findings (`final-actionlint.2026-10-17T00-15.md`; `rem1-actionlint.2026-10-17T01-37.md`). `poshqc / PowerShell QC static` success in CI. |
| **3. Type checking** | ✅ PASS | Pyright clean in CI legs and `final-python-types.2026-10-17T00-21.md`; N/A for PowerShell and bash. |
| **4. Testing** | ✅ PASS | CI: Pester 11129 tests across three shards, 0 failures; pytest 7278 passed per leg; bats 733 tests, 0 `not ok`. Local: `rem1-pester-workflows.2026-10-17T01-37.md` (workflow suites, 39 rows of `CiChangeScopeWorkflow.Tests.ps1` passed). |
| **Full toolchain loop** | ✅ PASS | `evidence/qa-gates/qa-loop.2026-10-17T00-21.md` (pass 2 clean) and the cycle 1 Phase 2 stages P2-T1 to P2-T8, each recorded with no file rewritten. |
| **Explicit reporting** | ✅ PASS | Every stage has an evidence file with `Timestamp`, `Command`, and `EXIT_CODE`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit subjects describe each phase and the remediation; see section 9. |
| **Design choices explained** | ✅ PASS | `spec.md` decisions D1 to D9 and D14; remediation decisions RPD-1 to RPD-6. |
| **Update supporting documents** | ✅ PASS | `.github/workflows/README.md` change-scope section, D14-a corrections, and the revised `### Security scan` subsection. |
| **Provide next steps** | ✅ PASS | Proof procedure P0 to P3 in `spec.md` for the CI-dependent criteria; coordinator follow-up for the 14 affected packages in `remediation-plan.2026-10-17T01-20.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** Black check in `quality-checks7` and `poetry run black --check tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` (prior review)<br>**Result:** clean. |
| **Linting with Ruff** | ✅ PASS | **Command:** Ruff in `quality-checks7`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** clean in CI and `final-python-types.2026-10-17T00-21.md`. |
| **Testing with Pytest** | ✅ PASS | **Command:** pytest with coverage in `quality-checks7`<br>**Result:** 7278 passed, 6 skipped on each of four legs. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | The changed test keeps its `-> None` annotation; the new constant is a typed module-level `str`. |
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
| **Formatting with Invoke-Formatter** | ✅ PASS | PoshQC format, FORMAT-DRIFT-COUNT 0, including the replaced W18 row. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | PSSA-TOTAL 0; two suppressions carry justifications. `poshqc / PowerShell QC static` success in CI. |
| **Fix all findings** | ✅ PASS | No open findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | No 7-only syntax; the workflow runs the script with `shell: pwsh`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every function has `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`, and `ValidateSet`. |
| **Avoid global state** | ✅ PASS | `Set-StrictMode -Version Latest`; no global variables. |
| **Error handling** | ✅ PASS | Specific `CI_*_INVALID:` error prefixes; a single top-level fail-closed envelope. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 345 and 271 lines; largest test 411 lines. |
| **Approved verbs** | ✅ PASS | All verbs are approved PowerShell verbs. |
| **Comment why** | ✅ PASS | Comments explain fail-closed ordering and comparison semantics. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `final-format.2026-10-17T00-15.md`; `rem1-format.2026-10-17T01-37.md`. |
| **Step 2: Analyze** | ✅ PASS | `final-pssa.2026-10-17T00-15.md`; `rem1-pssa.2026-10-17T01-37.md`. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `rem1-pester-workflows.2026-10-17T01-37.md`; CI shards 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Cycle 1 Phase 2 completed without a restart. |

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | shfmt `-d` exit 0 (`evidence/regression-testing/p5-shell-static.2026-10-17T00-00.md`). |
| **Linting with shellcheck** | ✅ PASS | shellcheck exit 0 (same artifact). |
| **Testing with bats** | ✅ PASS | `shell-coverage / Shell Coverage (Bats + kcov)` job 117277015644: plan `1..733`, 0 `not ok`; the eight new tests (ok 712 to ok 719) pass. Prior finding B-4 is resolved. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | Unchanged pre-existing shebangs. |
| **Error handling** | ✅ PASS | Tool exits captured with `|| rc=$?`; `check_coverage_threshold` returns 0, 1, or 2 with a printed reason. |
| **Under 500 lines** | ✅ PASS | 432, 106, 265 lines. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | `config/` files are not in the governed JSON set; the file is two-space indented strict JSON. |
| **Schema validation** | ✅ PASS | `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` (23 tests) validates the committed file against the D3 contract. |
| **Required $schema** | N/A | Not a governed schema-bearing file. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | No comments or trailing commas. |
| **Deterministic key order** | ✅ PASS | Fixed order `version`, `include_prefixes`, `exclude_prefixes`, `extensions`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Pytest in all four legs. |
| **Coverage expectation** | ✅ PASS | 93.97% lines repo-wide; the 85/75 threshold step passed on every leg. Prior finding B-3 is resolved. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | The changed test asserts one condition value. |
| **Mocking sparingly** | ✅ PASS | No mocks; reads the committed workflow file. |
| **Organization** | ✅ PASS | Existing location `tests/scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | Test name unchanged; docstring updated. |
| **Docstrings/comments** | ✅ PASS | Docstring states scenario and expected outcome. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** pytest in `quality-checks7`<br>**Result:** 7278 passed, 6 skipped. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `Describe`/`Context`/`It`, `-ForEach`, `Should -Invoke`. |
| **Use PoshQC Configuration** | ✅ PASS | PoshQC runner locally and the `poshqc` shards in CI. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | No version-specific syntax in the suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 54 pure-module tests, 30 entry-script tests, 23 config tests, 39 workflow-invariant tests. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions are on published outputs and on invoker call counts the spec requires; W18 asserts the committed workflow configuration that AC-36 specifies. |
| **Mocking Used Sparingly** | ✅ PASS | Only `Add-Content` and `Write-Information` are mocked, for the default-writer rows. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/ci/CiChangeScope.Tests.ps1`, `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`<br>**Code files:** `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`<br>The test tree mirrors the source tree. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All four new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Grouped by decision stage and by workflow concern. |
| **Logical Grouping** | ✅ PASS | The W18 row stays in the `security scan` Context. |
| **Docstrings/Comments** | ✅ PASS | File header and helper comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | PoshQC MCP test runner (`rem1-mcp-poshqc-test.2026-10-17T01-38.md`) and the CI `poshqc` jobs. |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### scripts/ci/CiChangeScope.psm1 (54 tests in CiChangeScope.Tests.ps1, 23 in CiDocsOnlyPathsConfig.Tests.ps1)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Event-eligibility rows for `merge_group`, `push`, `workflow_dispatch`, fork, same-repo (AC-1, AC-2) | Positive/Negative | 11-35 | ✅ |
| Config parse rows: malformed JSON, version, include_prefixes, extension dot (AC-14) | Negative/Error Handling | 37-101 | ✅ |
| Allowlist positive and negative rows (AC-12, AC-13) | Positive/Negative/Edge Case | 103-144 | ✅ |
| NUL path-list rows | Edge Case | 146-172 (line 169 uncovered) | ✅ |
| Path decision rows (AC-9, AC-10) | Positive/Negative | 174-196 | ✅ |
| Candidate selection rows (AC-5) | Positive/Edge Case | 198-255 | ✅ |
| Marker rows (AC-6) | Positive/Negative | 257-299 | ✅ |
| Decision factory rows | Positive/Error Handling | 301-334 | ✅ |

**Coverage:** 93.08% (121 of 130 lines; identical in the CI merged XML). **Not covered:** lines 62, 81, 86, 169, 217, 226, 273, 282, 286. All nine are fail-closed validation throws or returns; see code-review finding CR-3.

### scripts/ci/Invoke-CiChangeScope.ps1 (30 tests in Invoke-CiChangeScope.Tests.ps1)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Event and fork gates (AC-1, AC-2) | Negative | 185-188 | ✅ |
| Run-list and job-list failures (AC-3, AC-4, AC-6) | Error Handling | 114-165 | ✅ |
| Ancestry and diff rows (AC-7 to AC-11) | Positive/Negative/Error Handling | 205-233 | ✅ |
| Fail-closed envelope (AC-14, AC-16) | Error Handling | 254-261 | ✅ |
| Seams, context, default writer (AC-11, AC-15, AC-17) | Positive | 43-112 | ✅ |

**Coverage:** 88.64% (78 of 88 lines; identical in the CI merged XML). **Not covered:** the native process boundary (38-40), the default `-ReadVariable` reader (87), the default invokers (249-250), the executed-script entry block (269-270), and the `JOB_LIST_FAILED` mapping for an unparseable job list (157-158). Lines 157-158 are testable; see CR-3.

### scripts/bash/shell_qc_lib.sh and scripts/bash/shell-qc.sh (bats, `tests/shell/test_shell_qc_commands.bats`)

**Coverage (kcov `cov.xml`, CI run 38992247041):** `shell_qc_lib.sh` 91.3%, `shell-qc.sh` 88.6%. No line of a changed hunk is uncovered (section 1.2).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 11129 (CI, three shards); pytest 7284 collected per leg (7278 passed, 6 skipped); bats 733 | ✅ |
| Tests Passed | Pester 0 failures, 0 errors; pytest 7278; bats 733 | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Pester shards 750.5 s, 153.0 s, 241.5 s; pytest 164.7 to 187.3 s per leg | ✅ |
| Average Time per Test | about 0.1 s Pester (CI); new suites about 12 ms per test locally | ✅ Fast |
| Discovery Time | 360 ms (local coverage run) | ✅ |
| Functions/Classes Tested | 8/8 exported module functions; 6/7 entry-script functions (native boundary excluded) | ✅ |
| Test File Size | 98 to 411 lines | ✅ Maintainable |
| Code Coverage (if applicable) | PowerShell 92.15% repo-wide; Python 93.97% lines; Bash 95.2% lines | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | Black check in `quality-checks7` | clean | ✅ |
| Ruff Linting | Ruff in `quality-checks7` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | clean | ✅ |
| Pytest Tests | pytest with coverage in `quality-checks7` | 7278 passed, 6 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | PoshQC format via `cr-format` | 0 drift | ✅ |
| PSScriptAnalyzer | PoshQC analyze via `cr-pssa`; `poshqc / PowerShell QC static` | 0 findings | ✅ |
| Pester Tests | `poshqc` shards 1 to 3 and the Linux hook suites | 0 failures | ✅ |

**For Bash and workflows:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt | `shfmt -d` (executor) | exit 0 | ✅ |
| shellcheck | `shellcheck` (executor) | exit 0 | ✅ |
| bats + kcov | `shell-coverage / Shell Coverage (Bats + kcov)` | 733 ok; 95.2% lines | ✅ |
| actionlint | `scripts/dev-tools/run-actionlint.ps1` | 0 findings | ✅ |

**Notes:** This review did not run Pester, bats, or kcov directly; the worktree isolation guard refuses commands naming `pwsh`, `bash`, or `wsl`. Results were taken from CI run 38992247041 (job logs and downloaded artifacts) and from the executor evidence.

---

## 8. Gaps and Exceptions

### Identified Gaps

- No blocking gap remains. B-1 to B-4 (prior audit) and RI-1 (remediation cycle 1) are resolved by CI run 38992247041.
- Pending-CI acceptance criteria AC-32, AC-33, AC-34, AC-36, AC-37, AC-38 are owned by the orchestrator's S9 gate (see the feature audit).
- Code-review findings CR-1 to CR-3 (Minor) remain open as recommendations.

### Approved Exceptions

**None.** The non-blocking `continue-on-error: true` on the safety scan step is a spec-recorded decision (AC-36 as amended, PD-18), not a policy exception: no policy file governs `continue-on-error`, and the base branch already carried `continue-on-error: true` on that step.

### Removed/Skipped Tests

**None.** Assertions adjusted under D6 are recorded in `evidence/other/workflow-suite-adjustment.2026-10-17T00-12.md`. Row W18 was replaced (not removed) by remediation cycle 1: the assertion that the job has no `continue-on-error` line became an assertion that the job has exactly one, `continue-on-error: true`, on the scan step. The fail-before and pass-after runs are `evidence/regression-testing/rem1-w18-expect-fail.2026-10-17T01-33.md` and `rem1-w18-pass.2026-10-17T01-34.md`.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **d91d8e274** - ci(962): keep the security scan non-blocking while pre-existing findings remain
2. **8be7c95da**, **f31be1979**, **0f0d95c2d** - docs(962): remediation evidence, CI security-scan findings, review round 1
3. **4aeb1ecbd** - ci(962): gate heavy CI steps on the change-scope decision
4. **042d039dc** - feat(962): add the change-scope entry script
5. **97a1423de** - feat(962): add the docs-only allowlist, the pure change-scope module, and the scripts/ci tier entry
6. **5a86f411e** - test(962): add failing change-scope, workflow-gating, and shell QC regression tests
7. **9c25ceed8** - docs(962): correct and extend the workflows README, make shell QC discovery recursive, and enforce 85% coverage
8. **32350256b**, **db3372db1** - re-integration of `origin/main` after #952 and re-applied gating
9. Earlier commits: spec, research, plan revisions, Phase 0 baselines, Phase 6 evidence.

### Files Modified

1. **scripts/ci/CiChangeScope.psm1** (NEW) - eight pure decision functions.
2. **scripts/ci/Invoke-CiChangeScope.ps1** (NEW) - I/O entry script with seams and a dot-source guard.
3. **config/ci-docs-only-paths.json** (NEW) - allowlist, version 1.
4. **.github/workflows/ci.yml** (MODIFIED) - `changes` and `full-run-marker` jobs; caller `needs`/`if`/`with`; `on:` block unchanged.
5. **Six reusable workflows** (MODIFIED) - `run-heavy` input and step gating; `_security-scan.yml` adds the Poetry export plugin step and `shell: bash`, and keeps `continue-on-error: true` on the scan step.
6. **scripts/bash/shell_qc_lib.sh**, **scripts/bash/shell-qc.sh** (MODIFIED) - `--recursive` bats discovery; `check_coverage_threshold`.
7. **Tests** - four new Pester suites, two adjusted Pester suites, one adjusted Python test, eight new bats tests.
8. **quality-tiers.yml**, **.github/workflows/README.md** (MODIFIED).

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Code, tests, toolchain, structure, evidence location, tier classification, coverage for every changed language, and the modified-workflow green-run rule comply. All findings of the prior audit and of remediation cycle 1 are resolved by CI run 38992247041 on the branch head.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan, remediation plan, and policy reads recorded.
- ✅ Design Principles: pure/I-O split, data-driven allowlist, fail-closed.
- ✅ Module & File Structure: all files under 500 lines.
- ✅ Naming, Docs, Comments: approved verbs, comment-based help.
- ✅ Toolchain Execution: clean local loops and a green CI run.
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
- ✅ Toolchain: Pester 0 failures locally and in CI.

**For Bash:**
- ✅ shfmt and shellcheck clean.
- ✅ bats 733 ok; kcov 95.2% lines with the 85% gate passing.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic, isolated, fast.
- ✅ Coverage & Scenarios: new-file, modified-file, and repo-wide thresholds met for PowerShell, Python, and Bash.
- ✅ Test Structure: AAA, named per AC.
- ✅ External Dependencies: no process, network, or temporary file in PowerShell suites.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest.
- ✅ Test Style & Structure: focused assertion.
- ✅ Naming & Readability: docstring updated.
- ✅ Coverage: 93.97% lines; threshold step passed.

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC.
- ✅ Test Style & Structure: seams and fakes.
- ✅ Naming & Readability: AC-tagged names.
- ✅ Toolchain: clean.

---

### Metrics Summary

- ✅ Pester 11129 tests in CI, 0 failures; workflow suites 39/39 locally after remediation
- ✅ pytest 7278 passed per leg on Python 3.10 to 3.13
- ✅ bats 733/733
- ✅ 93.08% and 88.64% line coverage on the two new PowerShell files
- ✅ Repo-wide coverage: PowerShell 92.15%, Python 93.97% lines (branch threshold met), Bash 95.2%
- ✅ Test files mirror the source tree under `tests/scripts/ci/`
- ✅ Format, lint, analyzer, and actionlint checks clean

---

### Recommendation

**Ready for PR**

Proceed to PR authoring. At S9, execute the `spec.md` Proof Procedure on the PR and check off the CI-dependent criteria AC-32 to AC-34 and AC-36 to AC-38 as each is verified on `pull_request` runs. The three Minor code-review findings may be addressed in a further remediation cycle at the orchestrator's discretion; they are not merge conditions.

---

## Appendix A: Test Inventory

### Complete Test List

1. `tests/scripts/ci/CiChangeScope.Tests.ps1` - 54 tests.
2. `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` - 23 tests (AC-15).
3. `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` - 30 tests.
4. `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` - 39 tests: AC-18 to AC-21 and AC-36 (row W18 replaced in cycle 1).
5. `tests/scripts/workflows/CiWorkflow.Tests.ps1` - 4 tests (one assertion adjusted).
6. `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` - 15 tests (one assertion adjusted).
7. `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` - 35 tests, unchanged (AC-28).
8. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` - 6 tests (one assertion adjusted).
9. `tests/shell/test_shell_qc_commands.bats` - 30 tests, 8 new.

---

## Appendix B: Toolchain Commands Reference

**Commands run by this review:**
```bash
git log --oneline -3
git diff --stat b8fcd77905a51284cfbca54226a2da2a7916a836..HEAD
git diff --name-only b8fcd77905a51284cfbca54226a2da2a7916a836..HEAD -- artifacts/
git diff --name-only 0f98da84e5474e9c09892b33c2fb2995b763457c..HEAD -- . ":(exclude)docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962"
git diff -U0 b8fcd77905a51284cfbca54226a2da2a7916a836..HEAD -- scripts/bash/shell_qc_lib.sh scripts/bash/shell-qc.sh
git show d91d8e274
git show b8fcd77905a51284cfbca54226a2da2a7916a836:.github/workflows/_security-scan.yml
git ls-remote origin refs/heads/main refs/heads/bug/ci-skip-evidence-only-commits-962
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
gh run view 38992247041 --repo drmoisan/drm-copilot --json headSha,conclusion,event,status,workflowName,jobs
gh run view --repo drmoisan/drm-copilot --job <id> --log   # jobs 117279847607, 117277015644, 117277015648, 117276956540, and the four quality-checks7 legs
gh run list --repo drmoisan/drm-copilot --workflow ci.yml --commit b8fcd77905a51284cfbca54226a2da2a7916a836   # base run 38982032960
gh run view --repo drmoisan/drm-copilot --job <id> --log   # base jobs 117273562025, 117273553437, 117274744135
gh api repos/drmoisan/drm-copilot/actions/runs/38992247041/artifacts
gh run download 38992247041 --repo drmoisan/drm-copilot -n shell-coverage
gh run download 38992247041 --repo drmoisan/drm-copilot -n poshqc-test-results
grep / awk over the downloaded cov.xml, powershell-coverage.xml, and pester-junit-shard-*.xml
wc -l (file-size check)
```

**Executor commands relied on (from feature evidence):**
```powershell
sh SCRATCH/tools/run-cr.sh cr-format -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1" -Write
sh SCRATCH/tools/run-cr.sh cr-pssa -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"
sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList ".github/workflows/_security-scan.yml"
sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows" -NamePatternList "*(AC-18)*,*(AC-19)*,*(AC-20)*,*(AC-21)*,*(AC-36)*"
sh SCRATCH/tools/run-cr.sh cr-readme
sh SCRATCH/tools/run-cr.sh cr-hermetic -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1"
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-17
**Policy Version:** Current (as of audit date)
