# Policy Compliance Audit: native-bash-toolchain-no-poetry (Issue #393)

**Audit Date:** 2026-07-21
**Code Under Test:** Full branch diff `193864d87f3dfcc2e2a18987ec2ecc592dfea93b..145dae538d732a908d6e1e0e8eb3d5a053e8a7d5` (59 files, +2891/-564). Core production changes: `scripts/bash/shell-qc.sh` (new), `scripts/bash/shell_qc_lib.sh` (new), `scripts/dev_tools/shell_qc.py` (deleted), `scripts/dev_tools/fix_all_branches.py` (modified), `pyproject.toml` (modified), `.github/workflows/_shell-coverage.yml` (modified), `.github/workflows/_build-check.yml` (modified), `.claude/rules/shell.md` (new, mirrored to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`), `.vscode/tasks.json`, `README.md`, two policy-audit templates, bats tests `tests/shell/test_shell_qc_discovery.bats` and `tests/shell/test_shell_qc_commands.bats`, fixtures under `tests/fixtures/shell_qc/`.

Authoritative range: `193864d87f3dfcc2e2a18987ec2ecc592dfea93b..145dae538d732a908d6e1e0e8eb3d5a053e8a7d5` per `artifacts/pr_context.appendix.txt` (`Range:` line), verified against `git rev-parse HEAD`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 3 files (1 modified, 1 deleted, pyproject.toml) | 2069 tests | PASS 2069 pass, 0 fail | 89.3% lines, 87% combined (branch >= 75%) | 90.9% lines, 81.6% branches | 96.3% lines / 95.8% branches (`fix_all_branches.py`, changed file) |
| Bash | 4 production/test files (2 new lib/wrapper, 2 new bats suites) | 44 bats tests | PASS 44 pass, 0 fail (CI run 29877012724) | 0.0% lines (CI merged kcov report on main, run 29735688734) | 0.0% lines (CI merged kcov report, run 29877012724) | 0.0% (merged Cobertura records zero instrumented lines) |
| TypeScript | 0 files | N/A | N/A | N/A (zero changed files) | N/A (zero changed files) | N/A (zero changed files) |
| PowerShell | 0 files | N/A | N/A | N/A (zero changed files) | N/A (zero changed files) | N/A (zero changed files) |
| C# | 0 files | N/A | N/A | N/A (zero changed files) | N/A (zero changed files) | N/A (zero changed files) |
| GitHub Actions (YAML) | 2 workflows | green `workflow_dispatch` runs | PASS conclusion=success x2 | N/A (config) | N/A (config) | N/A (config) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero changed TypeScript files on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero changed TypeScript files on the branch)
- PowerShell baseline coverage artifact: N/A - out of scope (zero changed PowerShell files on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero changed PowerShell files on the branch)
- Python baseline coverage artifact: docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/baseline/python-test.2026-07-21T18-45.md
- Python post-change coverage artifact: artifacts/python/lcov.info (parsed this audit: 11138/12252 lines = 90.91%; 3628/4446 branches = 81.60%) and docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/final-python-test.2026-07-21T18-45.md
- Bash baseline coverage artifact: CI artifact `shell-coverage` of main run 29735688734 (kcov-merged/cov.xml, line-rate 0.000, lines-valid 0)
- Bash post-change coverage artifact: CI artifact `shell-coverage` of branch-head run 29877012724 (kcov-merged/cov.xml, line-rate 0.000, lines-valid 0)
- Per-language comparison summary: section 1.2.1 of this audit

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

---

## Executive Summary

This audit reviews the full feature-vs-base diff for Issue #393 (replace the Python/Poetry-driven shell quality-control toolchain with a native bash wrapper). Base branch: `main`; merge-base `193864d8`; branch head `145dae53` (single commit). Evidence sources: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, executor evidence under the feature `evidence/` tree, independent re-runs of check-only commands by this reviewer, and independent verification of the two CI `workflow_dispatch` runs via the GitHub CLI.

Overall result: the implementation is policy-compliant in design, structure, tests, tone, and Python coverage, and the `modified-workflow-needs-green-run` rule is satisfied with verified green runs against the branch head. One blocking finding remains: bash line coverage for the two new production bash files cannot pass the uniform >= 85% line-coverage gate because the CI kcov merged Cobertura report contains zero instrumented lines (0.0%), both on this branch and on the `main` baseline. The condition is a pre-existing measurement-pipeline defect faithfully preserved by the parity requirement, and the feature's own `coverage-delta` evidence explicitly deferred the bash numeric to CI with the rule "remediation-required, never PASS" when the numeric is unavailable. Fail-closed, the bash coverage verdict is FAIL and remediation is triggered.

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/tonality.md` (tone of all authored docs)
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/python.md` obligations (via toolchain evidence and re-runs)
- PASS `.claude/rules/shell.md` (new rule, itself audited for content and mirror parity)
- PASS `.claude/rules/ci-workflows.md`
- PASS `.claude/rules/quality-tiers.md` (uniform coverage thresholds applied; see Bash FAIL)

**Language-specific policies evaluated:**
- PASS Python: black, ruff, pyright, pytest evidence plus reviewer re-run of black/ruff
- FAIL (coverage only) Bash: shfmt + shellcheck + bats pass; kcov line-coverage measurement yields no data
- N/A TypeScript, PowerShell, C#: zero changed files on the branch
- PASS GitHub Actions: green `workflow_dispatch` runs verified against branch head

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts remain in the diff; all new files are production tooling, tests, checked-in fixtures, or evidence documents.

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller. The delegation prompt requested the full feature-review-workflow contract with scope determined by this agent per the scope invariant; the audited scope is the full branch diff against `main`. One caller statement is recorded for transparency (not a narrowing): the prompt named `issue.md` (AC1-AC9) as the acceptance-criteria source while declaring `full-feature` work mode. Per the work-mode contract, `full-feature` resolves AC sources to `spec.md` and `user-story.md`; this audit uses those files. The AC1-AC9 text is byte-equivalent across `issue.md`, `spec.md` (mapping table), and `user-story.md`, so the resolution changes nothing material.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exit code 0 (no violations).
- Reviewer diff scan: no branch-diff files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All feature evidence is under `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/<kind>/` (baseline, qa-gates, other). PASS.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: the caller supplied no non-canonical evidence paths.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each bats test creates its own invocation via `run`; state is confined to env vars per test. `teardown` removes the coverage output dir used by the coverage-path tests. Python suites unchanged and pass (2069). |
| **Isolation** - Each test targets single behavior | PASS | Discovery suite tests one function behavior per test (shebang parse, suffix, exclusion, ordering); command suite tests one subcommand contract per test (skip markers, exit codes, argv shapes). |
| **Fast Execution** - Tests complete quickly | PASS | CI `Run shell-qc test with coverage` step executed 44 bats tests in under a minute inside kcov (run 29877012724 log timestamps 23:26:46-23:26:47 for output flush). |
| **Determinism** - Consistent results | PASS | All external tools are replaced by checked-in recording stubs via the `SHELL_QC_<TOOL>_BIN` seam; no network, no wall-clock, no randomness. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive bats test names state scenario and expectation; header comments document suite purpose and the no-temporary-files approach. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS (Python) / FAIL (Bash) | **Python baseline:** 89.3% lines (11138/12474), combined 87%.<br>**Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`<br>**Timestamp:** 2026-07-21 18:45 (evidence/baseline/python-test.2026-07-21T18-45.md)<br>**Bash baseline:** deferred to CI by the executor; reviewer resolved it from the last green main run 29735688734: merged kcov Cobertura reports 0.0% (lines-valid 0). |
| **No Coverage Regression** | PASS (Python) / FAIL-CLOSED (Bash) | **Python post-change:** 90.9% lines (11138/12252), 81.6% branches. Change: +1.6 pts lines (deleting the fully-untested 222-statement `shell_qc.py` shrinks the denominator).<br>**Bash:** baseline 0.0% and post-change 0.0% are identical (no regression introduced), but 0.0% cannot satisfy the uniform threshold; see New Code Coverage row. |
| **New Code Coverage >= 85% lines / >= 75% branches** | PASS (Python) / FAIL (Bash) | **Python changed file** `scripts/dev_tools/fix_all_branches.py`: 79/82 lines = 96.3%, 23/24 branches = 95.8% (parsed from artifacts/python/lcov.info).<br>**Bash new files** `scripts/bash/shell-qc.sh` (103 lines), `scripts/bash/shell_qc_lib.sh` (354 lines): the CI merged Cobertura (`kcov-merged/cov.xml`, run 29877012724) records `lines-valid="0"` and an empty `<classes>` list, so measured new-code line coverage is 0.0%. Gate >= 85% not met. Blocking; routed to remediation. |
| **Comprehensive Coverage** | PASS (functional) | All 10 library functions and the wrapper dispatch are exercised by 29 new bats tests (16 command-path + 11 discovery-path across the two suites, plus help/usage cases): discovery, shebang forms, exclusions, ordering, check/format/test/coverage flows, missing-tool paths, exit-code maxima, usage errors. The gap is the kcov measurement, not test scenarios. |
| **Positive Flows** - Valid inputs | PASS | check/format/test happy paths with stub tools exit 0 and record expected argv (`shfmt -d` once, `shellcheck` per file, `shfmt -w`, kcov argv + merge). |
| **Negative Flows** - Invalid inputs | PASS | Unknown subcommand exits 2; unknown `test` flag exits 2; extra positionals on check/format exit 2 (wrapper `main`). |
| **Edge Cases** - Boundary conditions | PASS | Extensionless shebang, `env -S` form, uppercase `BASH` shebang, plain `sh` shebang, non-shell `.txt`/`.ps1` rejection, `node_modules` pruning, sorted/deduplicated output asserted exactly (5 lines). |
| **Error Handling** - Error paths | PASS | Missing shfmt/shellcheck exit 127 with the exact five-line block; missing bats in coverage mode exits 127; missing kcov exits 127 with message plus block; max-exit-code semantics asserted for both tools failing. |
| **Concurrency** - If applicable | N/A | The toolchain is sequential by design; no concurrent behavior introduced. |
| **State Transitions** - If applicable | N/A | No stateful component introduced. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 89.3% lines -> Post-change: 90.9% lines, 81.6% branches. Change: +1.6 pts lines. New/changed-code coverage: 96.3% lines on `scripts/dev_tools/fix_all_branches.py`. Disposition: PASS. Evidence: artifacts/python/lcov.info; docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/evidence/qa-gates/coverage-delta.2026-07-21T18-45.md.
- Bash: Baseline: 0.0% lines (main run 29735688734 merged kcov Cobertura) -> Post-change: 0.0% lines (branch-head run 29877012724 merged kcov Cobertura). Change: 0.0 pts (identical empty merge; parity preserved, no regression introduced). New/changed-code coverage: 0.0% recorded for the two new bash files because the merged report instruments zero lines. Disposition: FAIL. Evidence: CI artifact `shell-coverage` (kcov-merged/cov.xml and kcov-merged/coverage.json, `percent_covered: 0.00`) from https://github.com/drmoisan/drm-copilot/actions/runs/29877012724; baseline artifact from https://github.com/drmoisan/drm-copilot/actions/runs/29735688734.
- TypeScript: N/A - out of scope (zero changed files on the branch). Disposition: N/A.
- PowerShell: N/A - out of scope (zero changed files on the branch). Disposition: N/A.
- C#: N/A - out of scope (zero changed files on the branch). Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | bats reports the failing assertion line and file (observed in CI log format `in test file tests/shell/test_shell_qc_commands.bats, line 113`); assertions compare exact strings for byte-identical contracts. |
| **Arrange-Act-Assert Pattern** | PASS | `setup()` arranges seams and fixture roots; `run ...` acts; `[ "$status" ... ]` / `[[ "$output" ... ]]` assert. |
| **Document Intent** | PASS | Suite headers and test names describe scenario and expected outcome; fixture and stub files carry purpose comments. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Real shfmt/shellcheck/bats/kcov are never required by the unit suites; recording stubs under `tests/fixtures/shell_qc/stub-bin/` are injected through `SHELL_QC_<TOOL>_BIN`. |
| **Use Mocks/Stubs** | PASS | Four checked-in stubs (shfmt, shellcheck, bats, kcov) echo argv and honor `STUB_<TOOL>_EXIT`; rationale documented in each stub header. |
| **Environment Stability** | PASS with observation | Fixtures are checked in; no test creates fixture files at runtime. Observation: the coverage-path test directs production output to `artifacts/pester/kcov-bats` (gitignored artifacts tree) and `teardown` removes it; this is production-code output through the documented `SHELL_QC_KCOV_OUT_DIR` seam, not test-created temporary fixture files. Recorded as a Minor code-review observation, not a violation. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy review for the feature branch prior to PR authoring. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #393; `issue.md`, `spec.md` v0.2, `user-story.md` all present in the feature folder with AC1-AC9. |
| **Read existing change plans** | PASS | `plan.2026-07-21T19-00.md` and research doc `research/2026-07-21T18-45-native-bash-shell-qc-research.md` recorded; P0-T1 policy-read evidence at evidence/baseline/phase0-instructions-read.2026-07-21T18-45.md. |
| **Document the plan** | PASS | Atomic plan with phase/task IDs; completed tasks summarized in `artifacts/pr_context.summary.txt`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Direct translation of the removed module: small pure functions, single dispatch `case` in the wrapper, no indirection layers. |
| **Reusability** | PASS | Library/wrapper split (`shell_qc_lib.sh` sourceable by tests and the wrapper); `resolve_tool` and `print_missing_tool_block` shared by all subcommands. |
| **Extensibility** | PASS | `SHELL_QC_<TOOL>_BIN` per-tool seam and `SHELL_QC_KCOV_OUT_DIR` override; new subcommands slot into the `case` dispatch. |
| **Separation of concerns** | PASS | Argument parsing/dispatch (wrapper) separated from discovery/execution logic (library); coverage-report parsing isolated in `extract_cobertura_line_rate`/`print_coverage_summary`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One executable entry point plus one function library; bats suites split by concern (discovery vs commands) per the spec's file-size guidance. |
| **Under 500 lines** | PASS | shell-qc.sh 103, shell_qc_lib.sh 354, test_shell_qc_commands.bats 165, test_shell_qc_discovery.bats 84 (verified by `wc -l`). Deleted shell_qc.py was 495. |
| **Public vs internal** | PASS | Public surface is the CLI contract (check/format/test/--coverage/--help, exit codes 0/2/127, two byte-identical skip markers); library functions documented as the sourceable test surface. |
| **No circular dependencies** | PASS | Wrapper sources library; library sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `discover_shell_scripts`, `extract_shebang_command`, `resolve_tool`, `run_test_coverage`, `print_missing_tool_block` match the spec's named functions. |
| **Docs/docstrings** | PASS | Every library function carries a purpose/args/returns comment block; wrapper documents dispatch and source-guard rationale. |
| **Comment why, not what** | PASS | Comments explain rationale (for example why `|| rc=$?` is required under `set -e`, why NUL-delimited find output, why the SC1091 suppression is benign). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Python: `poetry run black --check .` re-run by reviewer, exit 0 (329 files unchanged). Bash: shfmt diff mode inside `bash scripts/bash/shell-qc.sh check`, exit 0 (reviewer re-run). |
| **2. Linting** | PASS | Python: `poetry run ruff check .` re-run by reviewer, exit 0. Bash: shellcheck per file inside `check`, exit 0 across 4 discovered scripts (reviewer re-run; also evidence/qa-gates/shell-qc-orchestrator-verification.2026-07-21T23-20.md). |
| **3. Type checking** | PASS | Python: `poetry run pyright` exit 0 (evidence/qa-gates/final-python-typecheck.2026-07-21T18-45.md). Bash: no type-check stage per `.claude/rules/shell.md`. |
| **4. Testing** | PASS | Python: 2069 passed (evidence/qa-gates/final-python-test.2026-07-21T18-45.md). Bash: 44/44 bats on CI ubuntu-latest (run 29877012724); local `test` prints the exact bats-absent skip marker and exits 0 (reviewer re-run). |
| **Full toolchain loop** | PASS | Executor restarted the Python loop after the extension-mirror contract-test failure and completed a single clean pass (documented in final-python-test evidence). |
| **Explicit reporting** | PASS | Commands and exit codes recorded per stage in evidence files; independent reviewer re-runs recorded in this audit and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Single conventional commit `145dae53 refactor(shell): replace Python shell-qc with native bash toolchain`. |
| **Design choices explained** | PASS | spec.md Implementation Strategy documents the library/wrapper split, the hidden `fix_all_branches.py` consumer, and the Non-Goals (pyright subcommand not ported). |
| **Update supporting documents** | PASS | README.md, .vscode/tasks.json, both policy-audit templates, and the new `.claude/rules/shell.md` (byte-identical extension mirror verified by `cmp`). |
| **Provide next steps** | PASS | Remediation inputs for the bash coverage finding accompany this audit; PR authoring is gated on the remediation decision. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check .`<br>**Result:** exit 0, 329 files unchanged (reviewer re-run 2026-07-21T19-39; executor evidence final-python-format). |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check .`<br>**Result:** exit 0, all checks passed (reviewer re-run; executor evidence final-python-lint). |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright`<br>**Result:** exit 0 (evidence/qa-gates/final-python-typecheck.2026-07-21T18-45.md). |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`<br>**Result:** 2069 passed, exit 0 (evidence/qa-gates/final-python-test.2026-07-21T18-45.md). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | The only Python production edit replaces three list literals in `fix_all_branches.py`; existing annotations unchanged; pyright clean. |
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
| **Formatting with shfmt** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check` (shfmt diff mode stage)<br>**Result:** exit 0, no diffs, 4 scripts discovered (reviewer re-run on host shfmt v3.12.0; CI pins 3.8.0 and is canonical per shell.md — CI run also green). |
| **Linting with shellcheck** | PASS | **Command:** `bash scripts/bash/shell-qc.sh check`<br>**Result:** exit 0. One justified suppression: SC1091 on the runtime `source` in shell-qc.sh with inline rationale and a `# shellcheck source=` directive, permitted by shell.md. |
| **Testing with bats** | PASS | **Command:** `bash scripts/bash/shell-qc.sh test --coverage` (CI)<br>**Result:** 44/44 pass on ubuntu-latest, run 29877012724; local host lacks bats and the wrapper printed the exact skip marker with exit 0. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | PASS | Both new files use `#!/usr/bin/env bash`. |
| **Error handling** | PASS | Wrapper sets `set -euo pipefail`; all legitimately-non-zero tool invocations captured with `|| rc=$?`; source-guard re-exits the captured code so failures are not masked. |
| **Under 500 lines** | PASS | 103 and 354 lines. |

### Section 3E: GitHub Actions Workflow Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **modified-workflow-needs-green-run** | PASS | Diff modifies `.github/workflows/_shell-coverage.yml` and `_build-check.yml`. Evidence artifact: evidence/qa-gates/workflow-dispatch-green-runs.2026-07-21T23-35.md. Independently verified by this reviewer via `gh run view`: run 29877012724 (Shell Coverage) and run 29877013754 (Build Check) both report `conclusion: success` and `headSha: 145dae538d732a908d6e1e0e8eb3d5a053e8a7d5` matching the branch head. A green `workflow_dispatch` run against the branch head satisfies the rule per the skill definition. Note: the supporting validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` named by the skill is not present in the repository; the rule was evaluated manually (recorded as an Info finding, pre-existing). |
| **ci-workflows.md pwsh exit-code rule** | N/A | The modified steps use bash `run:` blocks with no deliberately-failing nested commands. |
| **No Poetry on the shell path** | PASS | `_shell-coverage.yml` removes Set up Python / Install Poetry / venv cache / poetry install steps and runs `bash scripts/bash/shell-qc.sh test --coverage`; `_build-check.yml` replaces the console-script smoke with `bash scripts/bash/shell-qc.sh --help`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Existing suites only; `tests/scripts/dev_tools/test_fix_all_branches.py` and `test_fix_all.py` re-run green after the repointing (evidence/qa-gates/python-fixall-tests.2026-07-21T18-45.md, 37 tests). |
| **Coverage expectation** | PASS | Repo-wide 90.9% lines / 81.6% branches; changed file 96.3% lines. |

#### 4A.2-4A.4

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests / mocking / organization / naming / runner** | PASS | No Python test files changed; the pre-existing fix_all fakes key by step name, so the command-list repointing required no test edits, as the spec predicted. Only Pytest used. |

### Section 4C: Bash (bats) Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Test location mirrors production** | PASS | `tests/shell/test_shell_qc_*.bats` mirror `scripts/bash/`; policy requires tests under the `tests/` tree — satisfied; no colocation. |
| **No temporary files** | PASS with observation | Fixtures and stubs are checked in; see 1.4 observation regarding production coverage output under `artifacts/pester/kcov-bats`. |
| **Determinism** | PASS | Stub-driven; no wall-clock, sleep, or randomness in test code. |

---

## 5. Test Coverage Detail

### scripts/bash/shell_qc_lib.sh — discovery functions (11 tests, discovery suite)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| extract_shebang_command reads extensionless env bash shebang | Positive | extract_shebang_command | PASS |
| extract_shebang_command handles env -S flags form | Edge Case | env-flag skip loop | PASS |
| extract_shebang_command lowercases an uppercase shebang | Edge Case | lowercasing path | PASS |
| extract_shebang_command handles a plain sh shebang | Positive | non-env branch | PASS |
| is_shell_script accepts a .sh suffix | Positive | suffix branch | PASS |
| is_shell_script rejects a non-shell text file | Negative | shebang-fail branch | PASS |
| is_shell_script rejects a pwsh shebang | Negative | interpreter mismatch | PASS |
| discover_shell_scripts finds .sh suffix and every bash/sh shebang form | Positive | traversal + filter | PASS |
| discover_shell_scripts prunes the excluded node_modules directory | Edge Case | prune expression | PASS |
| discover_shell_scripts ignores non-shell files (txt and ps1) | Negative | filter rejection | PASS |
| discover_shell_scripts output is sorted and de-duplicated | Edge Case | LC_ALL=C sort -u | PASS |

### scripts/bash/shell-qc.sh + command paths (18 tests, command suite)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| check no-scripts skip / shfmt-missing 127 / shellcheck-missing 127 | Positive + Error | run_check preflight | PASS |
| check exit-code maxima (shfmt only, shellcheck only, both) | Error Handling | max-exit logic | PASS |
| check argv shape (shfmt once, shellcheck per file) | Positive | invocation contract | PASS |
| format -w argv | Positive | run_format | PASS |
| test skip markers (no dirs; bats absent) byte-identical | Edge Case | fix_all contract | PASS |
| test --coverage bats-missing 127 / kcov-missing 127 + block | Error Handling | run_test_coverage preflight | PASS |
| test --coverage kcov argv + merge | Positive | coverage pipeline | PASS |
| extract_cobertura_line_rate + print_coverage_summary fixture | Positive | parsing/formatting | PASS |
| --help / help exit 0; unknown subcommand exit 2; unknown test flag exit 2 | Negative | usage contract | PASS |

**Coverage:** Functional scenario coverage is complete for every public function. Measured kcov line coverage for these files is 0.0% because the merged CI Cobertura instruments zero lines (Blocking finding; see Section 8).

**Not covered:** The real-kcov success path is integration-covered by `_shell-coverage.yml` (run 29877012724) rather than unit-covered, by design (stubs replace kcov in the unit suite).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (bats, CI) | 44 | PASS |
| Tests Passed | 44 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Total Tests (pytest) | 2069 | PASS |
| Execution Time (bats under kcov, CI) | ~60s step | PASS Fast |
| Functions Tested (bash library) | 10/10 | PASS |
| Test File Sizes | 165 + 84 lines | PASS Maintainable |
| Code Coverage (Python) | 90.9% lines, 81.6% branches | PASS |
| Code Coverage (Bash, measured) | 0.0% lines (empty merged report) | FAIL |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | exit 0, 329 files unchanged (reviewer re-run) | PASS |
| Ruff Linting | `poetry run ruff check .` | exit 0 (reviewer re-run) | PASS |
| Pyright Type Checking | `poetry run pyright` | exit 0 (executor evidence) | PASS |
| Pytest Tests | `poetry run pytest --cov --cov-branch` | 2069 passed (executor evidence) | PASS |

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt + shellcheck | `bash scripts/bash/shell-qc.sh check` | exit 0 (reviewer re-run) | PASS |
| Help smoke | `bash scripts/bash/shell-qc.sh --help` | exit 0 (reviewer re-run) | PASS |
| bats + kcov | CI run 29877012724 | success, 44/44 | PASS |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:**
Pre-existing, unrelated to this branch: (1) the merged kcov Cobertura report was already empty on `main` (run 29735688734), so the bash coverage FAIL is inherited, not introduced; (2) `quality-tiers.yml` does not exist at the repository root on `main` or on this branch, although `.claude/rules/quality-tiers.md` names it as the tier source of truth; (3) the skill-named validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` is absent repo-wide.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Bash line-coverage measurement (Blocking, routed to remediation):** the uniform gate requires >= 85% line coverage for the new files `scripts/bash/shell-qc.sh` and `scripts/bash/shell_qc_lib.sh`. The authoritative CI artifact records zero instrumented lines (`kcov-merged/cov.xml`: `line-rate="0.000"`, `lines-valid="0"`; `coverage.json`: `percent_covered: 0.00`). Root cause is in the coverage pipeline, not the tests: `kcov --merge <out> ...` writes its merged report to `<out>/kcov-merged/cov.xml` while both the removed Python module and the parity-preserving bash port parse `<out>/cov.xml`, and the merged report itself aggregates no line data from the `--cobertura-only` per-run directories. Identical behavior exists on the `main` baseline, so the feature introduces no regression, and the feature's own coverage-delta evidence pre-declared this outcome remediation-required. See `remediation-inputs.2026-07-21T19-39.md`.
- **Coverage summary line never prints in real runs (Major, same root cause):** `print_coverage_summary "$out_dir/cov.xml"` is a silent no-op on CI because `cov.xml` lands at `$out_dir/kcov-merged/cov.xml`. Byte-parity with the removed module (which had the identical no-op), verified against the CI step log (no `Bash coverage (lines):` line after the 44-test TAP output).

### Approved Exceptions

- **shellcheck SC1091 suppression** in `scripts/bash/shell-qc.sh`: justified inline with rationale and a `# shellcheck source=` directive, explicitly permitted by `.claude/rules/shell.md`. Documented in evidence/qa-gates/shell-qc-orchestrator-verification.2026-07-21T23-20.md.

### Removed/Skipped Tests

**None.** All planned bats scenarios from the spec's Seeded Test Conditions are implemented; the pre-existing Python fix_all suites run unmodified.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **145dae53** - refactor(shell): replace Python shell-qc with native bash toolchain

### Files Modified

1. **scripts/bash/shell-qc.sh** (NEW) - native wrapper: dispatch, usage, source-guard, exit-code preservation.
2. **scripts/bash/shell_qc_lib.sh** (NEW) - discovery, shebang parsing, tool resolution seam, missing-tool block, check/format/test/coverage, Cobertura parsing.
3. **scripts/dev_tools/shell_qc.py** (DELETED) - 495-line Python module removed (0% covered at baseline).
4. **pyproject.toml** (MODIFIED) - all five console-script entries removed (`shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`, `dev.shell-qc`); verified by grep (no matches remain).
5. **scripts/dev_tools/fix_all_branches.py** (MODIFIED) - three command lists repointed to `bash scripts/bash/shell-qc.sh <cmd>`.
6. **.github/workflows/_shell-coverage.yml** (MODIFIED) - Python/Poetry setup steps removed; native invocation.
7. **.github/workflows/_build-check.yml** (MODIFIED) - native `--help` smoke step added; console-script smoke removed.
8. **.claude/rules/shell.md** (NEW) + byte-identical extension mirror (NEW) - path-scoped shell rule.
9. **.vscode/tasks.json, README.md, two policy-audit templates** (MODIFIED) - invocation references updated.
10. **tests/shell/*.bats, tests/fixtures/shell_qc/** (NEW) - two suites, four recording stubs, discovery fixtures, Cobertura fixture.
11. **docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/** (NEW) - scoping docs, plan, research, evidence tree.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT (one Blocking coverage finding; remediation triggered)

All design, structure, naming, tone, workflow, evidence-location, and Python-toolchain requirements pass, and the `modified-workflow-needs-green-run` rule is satisfied with independently verified green runs against the branch head. The audit cannot report full compliance because the mandatory bash line-coverage verification fails closed: the authoritative CI coverage artifact instruments zero lines for the new bash production files. Remediation inputs are provided.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: issue/spec/story/plan/research all present.
- PASS Design Principles: simple, seam-based, separated.
- PASS Module & File Structure: all files under 500 lines.
- PASS Naming, Docs, Comments: rationale-focused comments throughout.
- PASS Toolchain Execution: single clean pass after the documented mirror restart.
- PASS Summarize & Document: README, tasks, templates, rule doc updated.

#### Language-Specific Code Change Policy (Section 3)
- PASS Python Tooling & Baseline; N/A Design/Typing beyond the list-literal edit.
- PASS Bash tooling (shfmt/shellcheck/bats), design, error handling.
- PASS GitHub Actions: green-run rule satisfied and verified.

#### General Unit Test Policy (Section 1)
- PASS Core Principles.
- FAIL Coverage & Scenarios (bash measured coverage only; scenarios complete).
- PASS Test Structure.
- PASS External Dependencies.
- PASS Policy Audit.

#### Language-Specific Unit Test Policy (Section 4)
- PASS Python: unchanged suites green.
- PASS-with-FAIL-coverage Bash: suites complete and green; measured coverage 0.0% (Blocking).

---

### Metrics Summary

- 44/44 bats tests passing on CI (100%); 2069/2069 pytest passing.
- 10/10 bash library functions exercised by unit scenarios.
- Python 90.9% line / 81.6% branch coverage (thresholds 85/75 met).
- Bash measured line coverage 0.0% (empty merged kcov report) — Blocking.
- All check-only quality gates re-run by the reviewer pass (black, ruff, shell-qc check, evidence-locations validator).

---

### Recommendation

**Blocked** pending remediation of the bash coverage-measurement finding. Everything else is merge-ready: the workflow rule is satisfied with verified green runs, Python gates pass with margin, and the functional bats suites are complete. The remediation must produce a real numeric bash line-coverage measurement for `scripts/bash/shell-qc.sh` and `scripts/bash/shell_qc_lib.sh` that meets the >= 85% line gate (branch coverage is exempt for bash per `.claude/rules/shell.md`), and should fix the merged-report path so `Bash coverage (lines): NN.N%` prints on CI. See `remediation-inputs.2026-07-21T19-39.md`.

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
- test --coverage builds the kcov argv and merges the runs
- extract_cobertura_line_rate reads the fixture line-rate
- print_coverage_summary formats the fixture line-rate to one decimal percent
- --help prints usage and exits 0
- help subcommand prints usage and exits 0
- an unknown subcommand prints usage and exits 2
- an unknown test flag exits 2

(CI executes 44 total: these 29 plus the 15 pre-existing tests in tests/shell, including the coverage-demo suite.)

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

**Review-specific verification:**
```bash
python scripts/dev_tools/validate_evidence_locations.py --root .
gh run view 29877012724 --repo drmoisan/drm-copilot --json headSha,conclusion,status
gh run view 29877013754 --repo drmoisan/drm-copilot --json headSha,conclusion,status
gh run download 29877012724 --repo drmoisan/drm-copilot -n shell-coverage   # inspected kcov-merged/cov.xml
gh run download 29735688734 --repo drmoisan/drm-copilot -n shell-coverage   # baseline comparison
git diff 193864d8..145dae53 --name-status
```

Template source note: this artifact follows the canonical repository template `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (as updated by this branch); the MCP template-resolution tool was unavailable in this review session, and the repo template is the same content the resolver serves.

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-07-21
**Policy Version:** Current (as of audit date)
