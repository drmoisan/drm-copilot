# Policy Compliance Audit: native-bash-toolchain-no-poetry (Issue #393) — Remediation Re-Audit (R4)

**Audit Date:** 2026-07-21
**Code Under Test:** Full branch diff `193864d87f3dfcc2e2a18987ec2ecc592dfea93b..5a5d08ff49b914faed1790dbdca0e403d1552253` (66 files, +3697/-564; 3 commits). Core production changes: `scripts/bash/shell-qc.sh` (new), `scripts/bash/shell_qc_lib.sh` (new), `scripts/dev_tools/shell_qc.py` (deleted), `scripts/dev_tools/fix_all_branches.py` (modified), `pyproject.toml` (modified), `.github/workflows/_shell-coverage.yml` (modified), `.github/workflows/_build-check.yml` (modified), `.claude/rules/shell.md` (new, mirrored to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`), `.vscode/tasks.json`, `README.md`, two policy-audit templates, bats tests `tests/shell/test_shell_qc_discovery.bats` and `tests/shell/test_shell_qc_commands.bats`, fixtures under `tests/fixtures/shell_qc/`. Remediation delta since the prior audit (commit `a87ff2e1`): `scripts/bash/shell_qc_lib.sh` `run_test_coverage` kcov invocation and merged-report copy; `tests/shell/test_shell_qc_commands.bats` argv assertion.

Authoritative range: `193864d87f3dfcc2e2a18987ec2ecc592dfea93b..5a5d08ff49b914faed1790dbdca0e403d1552253` per `artifacts/pr_context.appendix.txt` (`Range:` line; artifacts refreshed this session against the current head), verified against `git rev-parse HEAD`.

**Re-audit context:** This is the cycle-1 remediation re-audit. The prior audit (`policy-audit.2026-07-21T19-39.md`) recorded one Blocking finding (REM-1: bash line coverage unmeasured, 0.0%) and one Major finding (REM-2: coverage summary line never printed on CI). Both were remediated in commit `a87ff2e1` per `remediation-plan.2026-07-21T19-39.md`. This audit independently verifies the remediation. **Both findings are resolved; zero Blocking findings remain.**

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 3 files (1 modified, 1 deleted, pyproject.toml) | 2069 tests | PASS 2069 pass, 0 fail | 89.3% lines, 87% combined (branch >= 75%) | 90.9% lines, 81.6% branches | 96.3% lines / 95.8% branches (`fix_all_branches.py`, changed file) |
| Bash | 4 production/test files (2 new lib/wrapper, 2 new bats suites) | 44 bats tests | PASS 44 pass, 0 fail (CI run 29878850555 at head 5a5d08ff) | 0.0% lines (CI merged kcov report on main, run 29735688734 — pre-existing measurement defect, now fixed) | 88.2% lines (194/220, merged kcov Cobertura, run 29878850555) | 88.6% lines `shell-qc.sh`, 87.6% lines `shell_qc_lib.sh` (per-file line-rate from merged cov.xml) |
| TypeScript | 0 files | N/A | N/A | N/A (zero changed files) | N/A (zero changed files) | N/A (zero changed files) |
| PowerShell | 0 files | N/A | N/A | N/A (zero changed files) | N/A (zero changed files) | N/A (zero changed files) |
| C# | 0 files | N/A | N/A | N/A (zero changed files) | N/A (zero changed files) | N/A (zero changed files) |
| GitHub Actions (YAML) | 2 workflows | green `workflow_dispatch` runs | PASS conclusion=success x2 at head 5a5d08ff | N/A (config) | N/A (config) | N/A (config) |

Bash branch coverage: kcov reports line coverage only for bash; per `.claude/rules/shell.md` there is no bash branch-coverage gate. The uniform line threshold (>= 85%) applies and is met repo-wide (88.2%) and per new file (88.6%, 87.6%).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero changed TypeScript files on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero changed TypeScript files on the branch)
- PowerShell baseline coverage artifact: N/A - out of scope (zero changed PowerShell files on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero changed PowerShell files on the branch)
- Python baseline coverage artifact: docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/baseline/python-test.2026-07-21T18-45.md
- Python post-change coverage artifact: artifacts/python/lcov.info (parsed in the prior cycle: 11138/12252 lines = 90.91%; 3628/4446 branches = 81.60%; no Python file changed since, verified by `git diff --name-status a87ff2e1..5a5d08ff`) and docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/final-python-test.2026-07-21T18-45.md
- Bash baseline coverage artifact: CI artifact `shell-coverage` of main run 29735688734 (kcov-merged/cov.xml, line-rate 0.000, lines-valid 0 — the pre-existing measurement defect this remediation fixed)
- Bash post-change coverage artifact: CI artifact `shell-coverage` of branch-head run 29878850555 (cov.xml and kcov-merged/cov.xml byte-identical: line-rate 0.882, lines-covered 194, lines-valid 220; downloaded and parsed by this reviewer) and docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/bash-coverage-fixed.2026-07-21T23-56.md
- Per-language comparison summary: section 1.2.1 of this audit

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

---

## Executive Summary

This re-audit reviews the full feature-vs-base diff for Issue #393 after the cycle-1 remediation. Base branch: `main`; merge-base `193864d8`; branch head `5a5d08ff` (3 commits: `145dae53` feature, `a87ff2e1` remediation fix, `5a5d08ff` remediation-plan/evidence docs). Evidence sources: refreshed `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt`, the feature `evidence/` tree, independent reviewer re-runs of check-only commands, and independent verification of CI runs and coverage artifacts via the GitHub CLI.

**Remediation verification (REM-1 Blocking, REM-2 Major — both RESOLVED):**

- REM-1 (bash coverage unmeasured): commit `a87ff2e1` removed `--cobertura-only` from the per-run kcov invocation in `scripts/bash/shell_qc_lib.sh::run_test_coverage` (lines 332-338), so per-run coverage databases now feed `kcov --merge`. Independently verified: this reviewer downloaded CI artifact `shell-coverage` from run 29878850555 (headSha `5a5d08ff` = current branch head, conclusion success) and parsed the merged Cobertura: repo-wide bash `line-rate="0.882"` (194/220 = 88.2%), per-file `shell-qc.sh` 88.6%, `shell_qc_lib.sh` 87.6%, `coverage_demo.sh` 100.0%, `coverage_lib.sh` 100.0%. Both new production files exceed the uniform >= 85% line gate.
- REM-2 (summary line never printed): the same commit copies `<out>/kcov-merged/cov.xml` to the canonical `<out>/cov.xml` (lines 349-354) before `print_coverage_summary "$out_dir/cov.xml"`. Independently verified: the run 29878850555 step log prints `Bash coverage (lines): 88.2%`, and the downloaded artifact contains `cov.xml` at the canonical root, byte-identical to `kcov-merged/cov.xml` (verified with `diff`).
- The bats regression guard was updated accordingly: `tests/shell/test_shell_qc_commands.bats` now asserts `--cobertura-only` is absent from the kcov argv and `kcov --include-pattern=` is present. All 44 bats tests pass on CI at the current head (run log `ok 1`..`ok 44`, zero `not ok`).

Overall result: the implementation is policy-compliant. All uniform coverage gates now pass for every language with changed files (Python 90.9%/81.6%; bash 88.2% lines with both new files >= 85%), the `modified-workflow-needs-green-run` rule is satisfied with fresh green `workflow_dispatch` runs verified against the current head `5a5d08ff`, and all reviewer check-only re-runs pass. Zero Blocking findings remain; remediation is not triggered.

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/tonality.md` (tone of all authored docs, including the new remediation-plan and evidence docs)
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/python.md` obligations (toolchain evidence and reviewer re-runs)
- PASS `.claude/rules/shell.md` (rule content, mirror parity, and now the coverage expectation it documents is observable on CI)
- PASS `.claude/rules/ci-workflows.md`
- PASS `.claude/rules/quality-tiers.md` (uniform coverage thresholds applied and met)

**Language-specific policies evaluated:**
- PASS Python: black, ruff, pyright, pytest evidence plus reviewer re-run of black/ruff this session
- PASS Bash: shfmt + shellcheck + bats pass; kcov line coverage now measured at 88.2% (was the prior cycle's Blocking finding)
- N/A TypeScript, PowerShell, C#: zero changed files on the branch
- PASS GitHub Actions: green `workflow_dispatch` runs verified against the current branch head

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts remain in the diff; all new files are production tooling, tests, checked-in fixtures, or evidence documents.

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller. The delegation prompt requested the full feature-review-workflow contract with scope determined by this agent per the scope invariant; the audited scope is the full branch diff against `main`. One caller statement is recorded for transparency (not a narrowing): the prompt named `issue.md` (AC1-AC9) as the acceptance-criteria source while the persisted work mode is `full-feature`. Per the work-mode contract, `full-feature` resolves AC sources to `spec.md` and `user-story.md`; this audit uses those files. The AC1-AC9 text is byte-equivalent across `issue.md`, `spec.md` (mapping table), and `user-story.md`, so the resolution changes nothing material.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exit code 0 (no violations; reviewer re-run this session).
- Reviewer diff scan (`git diff --name-status 193864d8..5a5d08ff`): no branch-diff files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All feature evidence is under `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/<kind>/` (baseline, qa-gates, other), including the two new remediation evidence files. PASS.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: the caller supplied no non-canonical evidence paths.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each bats test creates its own invocation via `run`; state is confined to env vars per test; `teardown` removes the coverage output dir used by the coverage-path tests. Python suites unchanged and pass (2069). |
| **Isolation** - Each test targets single behavior | PASS | Discovery suite tests one function behavior per test; command suite tests one subcommand contract per test. The remediation edit changed only one assertion block in one test. |
| **Fast Execution** - Tests complete quickly | PASS | CI `Run shell-qc test with coverage` step executed 44 bats tests under kcov in under a minute (run 29878850555 log timestamps 00:01:18-00:01:19). |
| **Determinism** - Consistent results | PASS | All external tools replaced by checked-in recording stubs via the `SHELL_QC_<TOOL>_BIN` seam; no network, no wall-clock, no randomness. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive bats test names; the updated coverage-argv assertion carries an inline comment explaining why `--cobertura-only` must be absent (issue #393 reference). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Python baseline:** 89.3% lines (11138/12474), combined 87% (evidence/baseline/python-test.2026-07-21T18-45.md). **Bash baseline:** 0.0% lines on the `main` run 29735688734 merged kcov report (the pre-existing measurement defect this cycle fixed). |
| **No Coverage Regression** | PASS | **Python post-change:** 90.9% lines, 81.6% branches (+1.6 pts lines vs baseline; no Python change since the prior cycle). **Bash post-change:** 88.2% lines vs a 0.0% baseline (+88.2 pts; the remediation made previously-unmeasurable coverage measurable). |
| **New Code Coverage >= 85% lines / >= 75% branches** | PASS | **Python changed file** `scripts/dev_tools/fix_all_branches.py`: 96.3% lines / 95.8% branches. **Bash new files:** `shell-qc.sh` 88.6% lines, `shell_qc_lib.sh` 87.6% lines (per-file line-rate parsed from run 29878850555 merged cov.xml). Bash branch coverage is not measurable by kcov; no bash branch gate per `.claude/rules/shell.md`. |
| **Comprehensive Coverage** | PASS | All 10 library functions and the wrapper dispatch exercised by 29 new bats tests plus 15 pre-existing shell tests (44 total, all green on CI at head). |
| **Positive Flows** - Valid inputs | PASS | check/format/test happy paths with stub tools exit 0 and record expected argv (per-run kcov without `--cobertura-only`, then `kcov --merge`). |
| **Negative Flows** - Invalid inputs | PASS | Unknown subcommand exits 2; unknown `test` flag exits 2; extra positionals exit 2. |
| **Edge Cases** - Boundary conditions | PASS | Extensionless shebang, `env -S` form, uppercase shebang, plain `sh` shebang, non-shell rejection, `node_modules` pruning, sorted/deduplicated output asserted exactly. |
| **Error Handling** - Error paths | PASS | Missing shfmt/shellcheck/bats/kcov paths exit 127 with exact message blocks; max-exit-code semantics asserted. |
| **Concurrency** - If applicable | N/A | Sequential toolchain; no concurrent behavior introduced. |
| **State Transitions** - If applicable | N/A | No stateful component introduced. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 89.3% lines -> Post-change: 90.9% lines, 81.6% branches. Change: +1.6 pts lines. New/changed-code coverage: 96.3% lines on `scripts/dev_tools/fix_all_branches.py`. Disposition: PASS. Evidence: artifacts/python/lcov.info; docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/coverage-delta.2026-07-21T18-45.md (no Python file changed since the prior cycle, verified by `git diff --name-status a87ff2e1..5a5d08ff`).
- Bash: Baseline: 0.0% lines (main run 29735688734 merged kcov Cobertura, pre-existing measurement defect) -> Post-change: 88.2% lines (194/220, branch-head run 29878850555 merged kcov Cobertura). Change: +88.2 pts (remediation `a87ff2e1` made coverage measurable). New/changed-code coverage: 88.6% lines `shell-qc.sh` and 87.6% lines `shell_qc_lib.sh` (per-file line-rate). Disposition: PASS. Evidence: CI artifact `shell-coverage` of https://github.com/drmoisan/drm-copilot/actions/runs/29878850555 (downloaded and parsed by this reviewer); docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/bash-coverage-fixed.2026-07-21T23-56.md.
- TypeScript: N/A - out of scope (zero changed files on the branch). Disposition: N/A.
- PowerShell: N/A - out of scope (zero changed files on the branch). Disposition: N/A.
- C#: N/A - out of scope (zero changed files on the branch). Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | bats reports the failing assertion line and file; assertions compare exact strings for byte-identical contracts. |
| **Arrange-Act-Assert Pattern** | PASS | `setup()` arranges seams and fixture roots; `run ...` acts; `[ "$status" ... ]` / `[[ "$output" ... ]]` assert. |
| **Document Intent** | PASS | Suite headers and test names describe scenario and expected outcome; the remediation added a rationale comment to the changed assertion. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Real shfmt/shellcheck/bats/kcov never required by the unit suites; recording stubs injected through `SHELL_QC_<TOOL>_BIN`. |
| **Use Mocks/Stubs** | PASS | Four checked-in stubs (shfmt, shellcheck, bats, kcov) echo argv and honor `STUB_<TOOL>_EXIT`. |
| **Environment Stability** | PASS with observation | Fixtures are checked in; no test creates fixture files at runtime. Carried observation (Minor, prior cycle): the coverage-path test directs production output to the gitignored `artifacts/pester/kcov-bats` through the documented `SHELL_QC_KCOV_OUT_DIR` seam and cleans it in `teardown`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required re-audit for the feature branch prior to PR authoring. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #393; `issue.md`, `spec.md` v0.2, `user-story.md` present with AC1-AC9; remediation cycle driven by `remediation-inputs.2026-07-21T19-39.md`. |
| **Read existing change plans** | PASS | `plan.2026-07-21T19-00.md`, research doc, and `remediation-plan.2026-07-21T19-39.md` all recorded in the feature folder. |
| **Document the plan** | PASS | The remediation plan documents rationale, findings addressed, changes, and verification; committed at `5a5d08ff`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The remediation is minimal: one flag removal, one guarded copy, one assertion update. No new indirection. |
| **Reusability** | PASS | Library/wrapper split unchanged; `resolve_tool` and `print_missing_tool_block` shared by all subcommands. |
| **Extensibility** | PASS | `SHELL_QC_<TOOL>_BIN` and `SHELL_QC_KCOV_OUT_DIR` seams unchanged. |
| **Separation of concerns** | PASS | Coverage-report parsing remains isolated in `extract_cobertura_line_rate`/`print_coverage_summary`; the canonical-path copy is confined to `run_test_coverage`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One executable entry point plus one function library; bats suites split by concern. |
| **Under 500 lines** | PASS | shell-qc.sh 103, shell_qc_lib.sh 363, test_shell_qc_commands.bats 168, test_shell_qc_discovery.bats 84 (verified by `wc -l` this session). |
| **Public vs internal** | PASS | CLI contract unchanged by the remediation (check/format/test/--coverage/--help, exit codes 0/2/127, byte-identical skip markers). |
| **No circular dependencies** | PASS | Wrapper sources library; library sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Function names match the spec's named functions; no renames in the remediation. |
| **Docs/docstrings** | PASS | Every library function carries a purpose/args/returns comment block. |
| **Comment why, not what** | PASS | The remediation added two rationale comments: why `--cobertura-only` must not be passed, and why the merged report is copied to the canonical path. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Python: `poetry run black --check .` re-run by reviewer this session, exit 0 (329 files unchanged). Bash: shfmt diff mode inside `bash scripts/bash/shell-qc.sh check`, exit 0 (reviewer re-run this session). |
| **2. Linting** | PASS | Python: `poetry run ruff check .` re-run by reviewer this session, exit 0. Bash: shellcheck per file inside `check`, exit 0 across 4 discovered scripts (reviewer re-run). |
| **3. Type checking** | PASS | Python: `poetry run pyright` exit 0 (evidence/qa-gates/final-python-typecheck.2026-07-21T18-45.md; no Python change since). Bash: no type-check stage per `.claude/rules/shell.md`. |
| **4. Testing** | PASS | Python: 2069 passed (evidence/qa-gates/final-python-test.2026-07-21T18-45.md). Bash: 44/44 bats on CI ubuntu-latest at head 5a5d08ff (run 29878850555); local `test` prints the exact bats-absent skip marker and exits 0 (reviewer re-run). |
| **Full toolchain loop** | PASS | Remediation verified via the CI dispatch loop documented in the remediation plan; reviewer re-ran the local check-only stages in a single clean pass this session. |
| **Explicit reporting** | PASS | Commands and exit codes recorded per stage in evidence files and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Three conventional commits: `145dae53` (feature), `a87ff2e1` (remediation fix, references REM-1/REM-2), `5a5d08ff` (remediation plan + evidence docs). |
| **Design choices explained** | PASS | The remediation plan documents why the orchestrator applied the fix directly (no delegate can execute bats/kcov) and the root cause of both findings. |
| **Update supporting documents** | PASS | README.md, .vscode/tasks.json, both policy-audit templates, `.claude/rules/shell.md` (mirror byte-identical); remediation evidence recorded under evidence/qa-gates/. |
| **Provide next steps** | PASS | This re-audit closes the remediation loop; go/no-go recommendation in Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check .`<br>**Result:** exit 0, 329 files unchanged (reviewer re-run 2026-07-21T20-09). |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check .`<br>**Result:** exit 0, all checks passed (reviewer re-run 2026-07-21T20-09). |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright`<br>**Result:** exit 0 (executor evidence; no Python file changed since). |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`<br>**Result:** 2069 passed, exit 0 (executor evidence; no Python file changed since). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | The only Python production edit replaces three list literals in `fix_all_branches.py`; annotations unchanged; pyright clean. |
| **Dataclasses for value objects** | N/A | No new Python value objects. |
| **Protocols/ABCs for interfaces** | N/A | No new Python interfaces. |
| **Avoid utility classes** | PASS | No classes added; `shell_qc.py` module removed entirely. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No exception-handling code changed. |
| **Logging over print** | N/A | No logging code changed. |
| **Invariants at construction** | N/A | No constructors changed. |

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check` (shfmt diff stage)<br>**Result:** exit 0, no diffs, 4 scripts discovered (reviewer re-run this session; CI pins 3.8.0 and is canonical — CI run 29878850555 also green). |
| **Linting with shellcheck** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check`<br>**Result:** exit 0. One justified suppression: SC1091 on the runtime `source` in shell-qc.sh with inline rationale and a `# shellcheck source=` directive, permitted by shell.md. |
| **Testing with bats** | PASS | **Command:** `bash scripts/bash/shell-qc.sh test --coverage` (CI)<br>**Result:** 44/44 pass on ubuntu-latest at head 5a5d08ff, run 29878850555; local host lacks bats and the wrapper printed the exact skip marker with exit 0. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | PASS | Both files use `#!/usr/bin/env bash`. |
| **Error handling** | PASS with observation | Wrapper sets `set -euo pipefail`; legitimately-non-zero tool invocations are captured into `rc` with the or-capture pattern. Observation (Minor, new): the canonical-path copy suppresses a copy failure with an or-true suffix; see code-review finding CR-1. |
| **Under 500 lines** | PASS | 103 and 363 lines. |

### Section 3E: GitHub Actions Workflow Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **modified-workflow-needs-green-run** | PASS | Diff modifies `.github/workflows/_shell-coverage.yml` and `_build-check.yml`. Independently verified by this reviewer via `gh run view`: run 29878850555 (Shell Coverage (reusable)) and run 29878851590 (Build Check (reusable)) both report `conclusion: success` and `headSha: 5a5d08ff49b914faed1790dbdca0e403d1552253` exactly matching the current branch head. A green `workflow_dispatch` run against the branch head satisfies the rule per the skill definition. Note (Info, pre-existing): the supporting validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` named by the skill is not present in the repository; the rule was evaluated manually. |
| **ci-workflows.md pwsh exit-code rule** | N/A | The modified steps use bash `run:` blocks with no deliberately-failing nested commands. |
| **No Poetry on the shell path** | PASS | `_shell-coverage.yml` runs `bash scripts/bash/shell-qc.sh test --coverage` with no Poetry steps; `_build-check.yml` uses the native `--help` smoke. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest / coverage expectation** | PASS | No Python test files changed this cycle; repo-wide 90.9% lines / 81.6% branches; changed file 96.3% lines. |
| **Focused unit tests / mocking / organization / naming / runner** | PASS | Pre-existing fix_all fakes key by step name, so the command-list repointing required no test edits. |

### Section 4C: Bash (bats) Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Test location mirrors production** | PASS | `tests/shell/test_shell_qc_*.bats` mirror `scripts/bash/`; no colocation. |
| **No temporary files** | PASS with observation | Fixtures and stubs checked in; carried 1.4 observation regarding production coverage output under the gitignored artifacts tree. |
| **Determinism** | PASS | Stub-driven; no wall-clock, sleep, or randomness in test code. |
| **Regression guard for the remediation** | PASS | The coverage-argv test now asserts `--cobertura-only` is absent and `kcov --include-pattern=` is present, preventing reintroduction of the REM-1 defect. |

---

## 5. Test Coverage Detail

### scripts/bash/shell_qc_lib.sh — discovery functions (11 tests, discovery suite)

Unchanged from the prior audit (see `policy-audit.2026-07-21T19-39.md` Section 5 for the per-test table); all 11 discovery tests green on CI at head 5a5d08ff (run log `ok 34`-`ok 44`).

### scripts/bash/shell-qc.sh + command paths (18 tests, command suite)

Unchanged except the coverage-argv test, which now asserts the post-remediation kcov invocation shape (no `--cobertura-only`; `--include-pattern=` present; merge invoked). All 18 command-suite tests green on CI at head 5a5d08ff.

**Coverage:** Measured kcov line coverage at head 5a5d08ff: repo-wide bash 88.2% (194/220); `shell-qc.sh` 88.6%; `shell_qc_lib.sh` 87.6%. The prior cycle's measurement gap is closed.

**Not covered:** The real-kcov success path is integration-covered by `_shell-coverage.yml` (run 29878850555) rather than unit-covered, by design (stubs replace kcov in the unit suite). Uncovered lines in the two production files (26 of 220 total across the four measured files) are predominantly missing-tool fallback branches and the real-kcov copy path exercised only on CI.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (bats, CI, head 5a5d08ff) | 44 | PASS |
| Tests Passed | 44 (100%) | PASS |
| Tests Failed | 0 (zero `not ok` in run log) | PASS |
| Total Tests (pytest) | 2069 | PASS |
| Execution Time (bats under kcov, CI) | ~60s step | PASS Fast |
| Functions Tested (bash library) | 10/10 | PASS |
| Test File Sizes | 168 + 84 lines | PASS Maintainable |
| Code Coverage (Python) | 90.9% lines, 81.6% branches | PASS |
| Code Coverage (Bash, measured) | 88.2% lines repo-wide; 88.6% / 87.6% per new file | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | exit 0, 329 files unchanged (reviewer re-run) | PASS |
| Ruff Linting | `poetry run ruff check .` | exit 0 (reviewer re-run) | PASS |
| Pyright Type Checking | `poetry run pyright` | exit 0 (executor evidence; no Python change since) | PASS |
| Pytest Tests | `poetry run pytest --cov --cov-branch` | 2069 passed (executor evidence) | PASS |

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt + shellcheck | `bash scripts/bash/shell-qc.sh check` | exit 0 (reviewer re-run this session) | PASS |
| Help smoke | `bash scripts/bash/shell-qc.sh --help` | exit 0 (reviewer re-run) | PASS |
| Local test skip path | `bash scripts/bash/shell-qc.sh test` | exit 0, exact skip marker (reviewer re-run) | PASS |
| bats + kcov | CI run 29878850555 (head 5a5d08ff) | success, 44/44, coverage 88.2% | PASS |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:**
Pre-existing, unrelated to this branch (carried Info items): (1) `quality-tiers.yml` does not exist at the repository root on `main` or this branch although `.claude/rules/quality-tiers.md` names it as the tier source of truth; (2) the skill-named validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` is absent repo-wide (rule evaluated manually this cycle, as in the prior cycle). Resolved since the prior cycle: the spurious `#ISO-8601` autoclose candidate no longer appears in the refreshed `artifacts/pr_context.summary.txt` (author-asserted list is now `#393` only).

---

## 8. Gaps and Exceptions

### Identified Gaps

- **None Blocking.** The prior cycle's Blocking finding (REM-1, bash coverage unmeasured) and Major finding (REM-2, summary line never printed) are both resolved by commit `a87ff2e1` and independently verified against CI run 29878850555 at the current head: repo-wide bash line coverage 88.2%, per-file 88.6% / 87.6% (both >= 85%), canonical `cov.xml` present and byte-identical to `kcov-merged/cov.xml`, and the run log prints `Bash coverage (lines): 88.2%`.
- Minor (new, non-blocking): the canonical-path copy `cp -f ... || true` in `run_test_coverage` suppresses a copy failure; see code-review finding CR-1 for the recommendation.

### Approved Exceptions

- **shellcheck SC1091 suppression** in `scripts/bash/shell-qc.sh`: justified inline with rationale and a `# shellcheck source=` directive, explicitly permitted by `.claude/rules/shell.md`.

### Removed/Skipped Tests

**None.** All planned bats scenarios remain implemented; the coverage-argv assertion was updated (not removed) to guard the remediation; total CI test count unchanged at 44.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **145dae53** - refactor(shell): replace Python shell-qc with native bash toolchain
2. **a87ff2e1** - fix(shell): make kcov coverage measurable and land cov.xml at canonical path (remediation for REM-1/REM-2)
3. **5a5d08ff** - docs(shell): record cycle-1 remediation plan and bash-coverage evidence (#393)

### Files Modified

1. **scripts/bash/shell-qc.sh** (NEW) - native wrapper: dispatch, usage, source-guard, exit-code preservation.
2. **scripts/bash/shell_qc_lib.sh** (NEW; remediated in a87ff2e1) - discovery, tool resolution, missing-tool block, check/format/test/coverage, Cobertura parsing; per-run kcov now runs without `--cobertura-only` and the merged report is copied to the canonical `cov.xml`.
3. **scripts/dev_tools/shell_qc.py** (DELETED) - 495-line Python module removed.
4. **pyproject.toml** (MODIFIED) - all five console-script entries removed.
5. **scripts/dev_tools/fix_all_branches.py** (MODIFIED) - three command lists repointed to `bash scripts/bash/shell-qc.sh <cmd>`.
6. **.github/workflows/_shell-coverage.yml** (MODIFIED) - Python/Poetry setup steps removed; native invocation.
7. **.github/workflows/_build-check.yml** (MODIFIED) - native `--help` smoke step added; console-script smoke removed.
8. **.claude/rules/shell.md** (NEW) + byte-identical extension mirror (NEW) - path-scoped shell rule.
9. **.vscode/tasks.json, README.md, two policy-audit templates** (MODIFIED) - invocation references updated.
10. **tests/shell/*.bats, tests/fixtures/shell_qc/** (NEW; commands suite remediated in a87ff2e1) - two suites, four recording stubs, discovery fixtures, Cobertura fixture.
11. **docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/** (NEW) - scoping docs, plan, research, evidence tree, prior-cycle review artifacts, remediation plan and evidence.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT (zero Blocking findings; remediation cycle 1 verified resolved)

All design, structure, naming, tone, workflow, evidence-location, Python-toolchain, and bash-toolchain requirements pass. The mandatory coverage verification now passes for every language with changed files: Python 90.9% lines / 81.6% branches (changed file 96.3%/95.8%); bash 88.2% lines repo-wide with both new production files at 88.6% and 87.6% (uniform >= 85% line gate met; no bash branch gate per `.claude/rules/shell.md`). The `modified-workflow-needs-green-run` rule is satisfied with green `workflow_dispatch` runs independently verified against the current branch head `5a5d08ff`.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is absent. All required artifacts for this audit are present and were independently parsed.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes; PASS Design Principles; PASS Module & File Structure; PASS Naming, Docs, Comments; PASS Toolchain Execution; PASS Summarize & Document.

#### Language-Specific Code Change Policy (Section 3)
- PASS Python Tooling & Baseline; N/A Design/Typing beyond the list-literal edit.
- PASS Bash tooling (shfmt/shellcheck/bats/kcov), design, error handling (one Minor observation, CR-1).
- PASS GitHub Actions: green-run rule satisfied and verified at the current head.

#### General Unit Test Policy (Section 1)
- PASS Core Principles; PASS Coverage & Scenarios (bash measured coverage now passes); PASS Test Structure; PASS External Dependencies; PASS Policy Audit.

#### Language-Specific Unit Test Policy (Section 4)
- PASS Python: unchanged suites green.
- PASS Bash: suites complete and green; measured line coverage 88.2% with both new files >= 85%.

---

### Metrics Summary

- 44/44 bats tests passing on CI at head 5a5d08ff (100%); 2069/2069 pytest passing.
- 10/10 bash library functions exercised by unit scenarios.
- Python 90.9% line / 81.6% branch coverage (thresholds 85/75 met).
- Bash 88.2% line coverage repo-wide; new files 88.6% and 87.6% (>= 85% gate met).
- All check-only quality gates re-run by the reviewer pass (black, ruff, shell-qc check/help/test, evidence-locations validator).
- Blocking findings: 0. Remediation: not triggered.

---

### Recommendation

**Go for PR authoring.** The cycle-1 remediation resolved both findings with independently verified numeric evidence at the current branch head, all uniform coverage gates pass, the workflow green-run rule is satisfied against head `5a5d08ff`, and no Blocking or Major findings remain. The single new Minor observation (CR-1, `cp -f ... || true`) and the carried Info items are tracked in the code review and do not gate the PR.

---

## Appendix A: Test Inventory

### tests/shell/test_shell_qc_discovery.bats (11 tests)

- extract_shebang_command reads extensionless env bash shebang
- extract_shebang_command handles env -S flags form
- extract_shebang_command lowercases an uppercase shebang
- extract_shebang_command handles a plain sh shebang
- is_shell_script accepts a .sh suffix
- is_shell_script rejects a non-shell text file
- is_shell_script rejects a pwsh shebang
- discover_shell_scripts finds .sh suffix and every bash/sh shebang form
- discover_shell_scripts prunes the excluded node_modules directory
- discover_shell_scripts ignores non-shell files (txt and ps1)
- discover_shell_scripts output is sorted and de-duplicated

### tests/shell/test_shell_qc_commands.bats (18 tests)

- check prints the no-scripts skip message and exits 0
- check exits 127 with the five-line block when shfmt is missing
- check exits 127 with the block when shellcheck is missing
- check returns the shfmt exit code when only shfmt fails
- check returns the shellcheck exit code when only shellcheck fails
- check returns the maximum exit code when both tools fail
- check invokes shfmt once over the full list and shellcheck once per file
- format passes -w to shfmt
- test prints the exact no-test-directory skip marker and exits 0
- test prints the exact bats-missing skip marker and exits 0
- test --coverage exits 127 with the coverage message when bats is missing
- test --coverage exits 127 with message and block when kcov is missing
- test --coverage builds the kcov argv and merges the runs (post-remediation shape: no `--cobertura-only`)
- extract_cobertura_line_rate reads the fixture line-rate
- print_coverage_summary formats the fixture line-rate to one decimal percent
- --help prints usage and exits 0
- help subcommand prints usage and exits 0
- an unknown subcommand prints usage and exits 2
- an unknown test flag exits 2

(CI executes 44 total: these 29 plus the 15 pre-existing tests in tests/shell, including the coverage-demo suite. Verified in the run 29878850555 log: `ok 1`..`ok 44`, zero failures.)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**For Bash:**
```bash
bash scripts/bash/shell-qc.sh format
bash scripts/bash/shell-qc.sh check
bash scripts/bash/shell-qc.sh test
bash scripts/bash/shell-qc.sh test --coverage
```

**Review-specific verification (this session):**
```bash
poetry run dev.pr-context --base main --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt
python scripts/dev_tools/validate_evidence_locations.py --root .
gh run view 29878850555 --json headSha,conclusion,status,workflowName   # Shell Coverage: success @ 5a5d08ff
gh run view 29878851590 --json headSha,conclusion,status,workflowName   # Build Check: success @ 5a5d08ff
gh run view 29878850555 --log | grep "Bash coverage"                    # prints: Bash coverage (lines): 88.2%
gh api repos/drmoisan/drm-copilot/actions/artifacts/8514019872/zip      # downloaded shell-coverage artifact; parsed cov.xml
git diff 193864d8..5a5d08ff --name-status
git show a87ff2e1 -- scripts/bash/shell_qc_lib.sh tests/shell/test_shell_qc_commands.bats
wc -l scripts/bash/shell-qc.sh scripts/bash/shell_qc_lib.sh tests/shell/*.bats
```

Template source note: this artifact follows the canonical repository template `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (as updated by this branch); the MCP template-resolution tool was unavailable in this review session, and the repo template is the same content the resolver serves.

---

**Audit Completed By:** feature-review agent (Claude Code), remediation re-audit R4
**Audit Date:** 2026-07-21
**Policy Version:** Current (as of audit date)
