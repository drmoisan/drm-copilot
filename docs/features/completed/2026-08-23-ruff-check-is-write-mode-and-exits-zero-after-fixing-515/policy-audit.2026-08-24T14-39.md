# Policy Compliance Audit: Ruff check write-mode removal (Issue #515)

---

**Audit Date:** 2026-08-24
**Code Under Test:** `pyproject.toml` (modified, 1 line deleted), `tests/scripts/dev_tools/test_ruff_config_alignment.py` (new, 117 lines), plus feature documentation and evidence under `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/`

**Review scope:** Full branch diff `80b65d2ed843d2dd72d722f3b6d88b8b84634227..4a926a0383e3c18aea475de1edad461d0f95998b` (`bug/ruff-check-is-write-mode-and-exits-zero-after-fixing-515-r2` vs `main`). No caller-supplied scope narrowing was attempted; no `## Rejected Scope Narrowing` section is required.

**Template source note:** The MCP tool `resolve_policy_audit_template_asset` was unavailable in this review session (no MCP tool surface). This artifact was created from the bundled asset file `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the identical file that tool resolves (see `extensions/drm-copilot/src/policy-audit-template-assets.ts`, asset id `policy_audit.template`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (1 config, 1 test module) | 4 new tests; 4116 total | Pass: 4116 pass, 0 fail, 5 pre-existing skips | 92.6067% lines, 85.1913% branches | 92.6067% lines, 85.2095% branches | N/A - no measured production Python source changed |

Languages with zero changed files on this branch: TypeScript, PowerShell, C#, Bash, JSON. Their coverage verdicts are N/A because they have no changed files in the branch diff; every language with changed files (Python only) carries an explicit PASS verdict below.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on this branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on this branch)
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on this branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on this branch)
- Per-language comparison summary: Section 1.2.1 of this document
- Python baseline coverage artifact: `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-test-coverage.2026-08-24T13-52.md`
- Python post-change coverage artifact: `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-test-coverage.2026-08-24T14-16.md` plus `artifacts/python/coverage.json` and `artifacts/python/lcov.info` (present on disk, re-parsed by this reviewer)

---

## Executive Summary

The branch fixes issue #515 by deleting a single line — `fix = true` — from the `[tool.ruff]` table in `pyproject.toml`, making the bare `poetry run ruff check` invocation read-only for every agent-facing call site and for CI simultaneously, and adds a four-test configuration-alignment regression module at `tests/scripts/dev_tools/test_ruff_config_alignment.py`. All remaining diff content is feature documentation and evidence under the active feature folder.

The change is fully compliant with the general code-change policy, the general unit-test policy, and the Python-specific policies. The seven-stage toolchain completed in a single clean pass (executor evidence, corroborated by this reviewer's independent check-only runs). Repo-wide Python coverage is above both thresholds with zero regression. No policy document under `.claude/rules/` or `.github/instructions/` is touched. The diff modifies no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`, so the `modified-workflow-needs-green-run` rule does not fire.

**Policy documents evaluated:**
- Pass: `general-code-change` policy (`.claude/rules/general-code-change.md`)
- Pass: `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- Pass: Python (`.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/quality-tiers.md`)
- N/A: PowerShell — zero changed files
- N/A: TypeScript — zero changed files
- N/A: C# — zero changed files
- N/A: Bash — zero changed files
- N/A: JSON — zero changed files

The new test module is deterministic, subprocess-free, and reads only committed text. Repo-wide Python: 4116 passed, 0 failed, 5 pre-existing declared skips; line coverage 92.6067% (>= 85%), branch coverage 85.2095% (>= 75%), no regression versus baseline.

**Temporary artifacts cleanup:**
- Pass: The manual differential used scratch files outside the repository working tree (session scratchpad); working-tree status snapshots before and after confirm no repository file was added or altered.
- Pass: No temporary or one-time scripts remain in the diff. The only committed script content is the regression test module, which is fully tested by executing it and is policy-compliant.

## Evidence Location Compliance

All 20 evidence artifacts in the branch diff live under the canonical `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/<kind>/` scheme (`baseline/`, `regression-testing/`, `qa-gates/`, `other/`). The diff contains zero files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (verified against `git diff --name-only 80b65d2e..HEAD`). `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred; no caller supplied a non-canonical evidence path. Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | The four tests share no mutable state; each reads committed files independently via module-level pure helpers. Reviewer ran the module standalone (4 passed, 0.06s) and the executor ran it inside the full 4116-test suite with identical results. |
| **Isolation** - Each test targets single behavior | PASS | One assertion target per test: fix-mode absence, show-fixes presence, standalone-config absence, workflow lint-step presence. Failure of any one identifies its exact guarded invariant. |
| **Fast Execution** - Tests complete quickly | PASS | 4 tests in 0.06s standalone (reviewer run); full suite 21.15s for 4116 tests (executor evidence `final-python-test-coverage.2026-08-24T14-16.md`). |
| **Determinism** - Consistent results | PASS | No randomness, no time reads, no network, no subprocess. Inputs are the committed `pyproject.toml` and `.github/workflows/_quality-checks.yml` plus two filesystem existence checks at repo root. |
| **Readability & Maintainability** - Clear structure | PASS | Module docstring explains intent and constraints; each test has a one-line docstring; assertion messages explain the defect class and cite issue #515 with the offending content interpolated. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-change):** 92.6067% lines (13841/14946), 85.1913% branches (4677/5490)<br>**Command:** `poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`<br>**Timestamp:** 2026-08-24T13-52<br>Artifact: `evidence/baseline/phase0-python-test-coverage.2026-08-24T13-52.md`. |
| **No Coverage Regression** | PASS | **Post-change coverage:** 92.6067% lines, 85.2095% branches. **Change:** +0.0000% lines (bit-for-bit identical operands 13841/14946), +0.0182% branches (4678 vs 4677 covered, unchanged denominator 5490). **Status:** No regression. Evidence: `evidence/qa-gates/coverage-delta-verification.2026-08-24T14-17.md`. |
| **New Code Coverage** | N/A | The diff adds no line to the measured source set (`source = ["src", "scripts/dev_tools"]`, `pyproject.toml:120`). `pyproject.toml` is configuration; the new module is test code, omitted from measurement by design and confirmed by the unchanged statement denominator (14946 in both runs). |
| **Comprehensive Coverage** | PASS | All four helper functions in the new module (`_read_repository_text`, `_strip_comment`, `_tool_ruff_table_lines`, plus the four test functions) are executed by the tests themselves; nothing in the module is unreached. No production Python function changed. |
| **Positive Flows** - Valid inputs | PASS | `test_ruff_config_retains_show_fixes` and `test_quality_checks_workflow_still_runs_a_ruff_lint_step` assert the expected present-state of the committed configuration and workflow. |
| **Negative Flows** - Invalid inputs | PASS | `test_ruff_config_does_not_enable_fix_mode` and `test_no_standalone_ruff_config_at_repository_root` assert the absence of the two defect-reintroduction routes. Fail-before evidence proves the first test rejects the defective configuration (`evidence/regression-testing/fail-before-pass-after-ruff-config-alignment.2026-08-24T13-57.md`: 1 failed, 3 passed against the pre-change tree, EXIT_CODE 1 = ExpectedExitCode 1). |
| **Edge Cases** - Boundary conditions | PASS | The fix-mode matcher tolerates whitespace and trailing-comment variation and rejects commented-out lines (`_strip_comment` before match); the standalone-config test checks both `ruff.toml` and `.ruff.toml`; the workflow test matches the `ruff check` invocation while excluding YAML `name:` lines so a step rename cannot false-pass and a command deletion cannot false-fail. Matches the spec's edge-case requirements (spec.md, Test Strategy). |
| **Error Handling** - Error paths | PASS | Assertion messages interpolate the offending lines/paths so a failure names its cause. No production error path is added by the change. |
| **Concurrency** - If applicable | N/A | No concurrent behavior in scope. |
| **State Transitions** - If applicable | N/A | No stateful component in scope. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.6067% lines, 85.1913% branches -> Post-change: 92.6067% lines, 85.2095% branches. Change: +0.0000% lines, +0.0182% branches. New/changed-code coverage: N/A - the diff adds no line to the measured source set. Disposition: PASS. Evidence: docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/coverage-delta-verification.2026-08-24T14-17.md and evidence/baseline/phase0-python-test-coverage.2026-08-24T13-52.md; reviewer re-parse of artifacts/python/coverage.json totals confirmed line 92.6067% and branch 85.19% at review time.

Languages with zero changed files (TypeScript, PowerShell, C#, Bash, JSON): no comparison required; no coverage obligation attaches to a language with no changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Fail-before evidence shows the real failure output: the assertion message names the file, the mechanism of the defect, the issue number, and the offending line (`Offending: ['fix = true']`). |
| **Arrange-Act-Assert Pattern** | PASS | Each test arranges by reading committed text via helpers, acts by filtering/matching, asserts with a diagnostic message. Compact single-behavior AAA. |
| **Document Intent** | PASS | Module and per-test docstrings; comments explain why the table-body scan and comment-stripping exist (tolerance to formatting variation rather than byte-pinning). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No database, network, API, or subprocess. Reads two committed files and two root-path existence checks only. The rejected stdin differential (spec non-goal 4) was deliberately kept out of the committed suite for exactly this rule. |
| **Use Mocks/Stubs** | N/A | Nothing to mock; the unit under test is committed configuration text. |
| **Environment Stability** | PASS | No temporary file is created by any committed test. The manual differential's scratch files live outside the repository (session scratchpad) and are QA-gate evidence, not tests. No mutable global state. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy review for the branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #515, promoted with `- Work Mode: full-bug` in `issue.md`; spec.md status "Ready for Planning" with authorized two-file diff. |
| **Read existing change plans** | PASS | Research artifact `research/2026-08-23T21-05-ruff-write-mode-research.md` (31-call-site inventory, CI exposure, four directions evaluated); policy reading order recorded in `evidence/baseline/phase0-instructions-read.2026-08-24T13-45.md`. |
| **Document the plan** | PASS | Atomic plan `plan.2026-08-23T23-21.md` with per-task acceptance conditions and evidence paths. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The production change is a one-line configuration deletion; the guard is a 117-line text-assertion module. The simplest design that closes the defect and its reintroduction routes. |
| **Reusability** | PASS | Module structure follows the existing precedent `tests/scripts/dev_tools/test_pyright_config_alignment.py` (repo-root resolution, UTF-8 text read, content assertions). |
| **Extensibility** | PASS | Helpers (`_tool_ruff_table_lines`, `_strip_comment`) are reusable for future `[tool.ruff]` assertions without restructuring. |
| **Separation of concerns** | PASS | Pure text parsing separated into helpers; each test asserts one invariant. No I/O beyond reading committed files. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One module, one concern: Ruff configuration alignment. |
| **Under 500 lines** | PASS | `test_ruff_config_alignment.py` = 117 lines; `pyproject.toml` change is a deletion. |
| **Public vs internal** | PASS | Helpers are underscore-prefixed module internals; only pytest-discovered test functions are public. |
| **No circular dependencies** | PASS | The module imports only `re` and `pathlib`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Test names state the guarded invariant (`test_ruff_config_does_not_enable_fix_mode`, etc.); constants use `_UPPER_SNAKE` module-internal convention. |
| **Docs/docstrings** | PASS | Module docstring explains the defect, the fix, and the no-subprocess/no-temp-file constraints with the rule citation. |
| **Comment why, not what** | PASS | Comments explain rationale (why comment-stripping precedes matching, why the table-body scope). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `poetry run black --check .`<br>**Result:** exit 0, zero files would be reformatted, 443 files unchanged (`evidence/qa-gates/final-python-format.2026-08-24T14-12.md`). Reviewer re-ran scoped to the new module: exit 0. |
| **2. Linting** | PASS | **Command:** `poetry run ruff check` bracketed by `git status --porcelain` snapshots<br>**Result:** exit 0, "All checks passed!", snapshot pair byte-identical (`evidence/qa-gates/final-python-lint.2026-08-24T14-13.md`). Reviewer independently re-ran `poetry run ruff check .` bracketed by status snapshots at review time: exit 0, working tree unchanged. |
| **3. Type checking** | PASS | **Command:** `poetry run pyright`<br>**Result:** exit 0, 0 errors (`evidence/qa-gates/final-python-typecheck.2026-08-24T14-14.md`). Reviewer re-ran scoped to the new module: exit 0. |
| **4. Architecture-boundary tests** | N/A | No TypeScript or C# change; no Python architecture-boundary gate applies to this diff. |
| **5. Unit tests** | PASS | **Command:** `poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`<br>**Result:** 4116 passed, 0 failed, 5 pre-existing declared skips, exit 0 (`evidence/qa-gates/final-python-test-coverage.2026-08-24T14-16.md`). |
| **6. Contract / schema checks** | N/A | No API contract or schema in scope; `pyproject.toml` loses one key and no schema governs it. |
| **7. Integration tests** | N/A | No adapter or external-system change. The manual differential (QA-gate evidence) covers the intended integration behavior of the lint stage. |
| **Full toolchain loop** | PASS | Pass 1 of the final loop hit one pre-existing, unrelated failure (filed issue #510: a gitignored `.claude/state/` file enumerated by the push-down parity test). The trigger file was removed and the loop restarted from stage 1 per the restart rule; pass 2 completed all applicable stages clean in a single pass with a byte-identical entry/exit status snapshot (`evidence/qa-gates/final-qa-loop-single-pass.2026-08-24T14-18.md`). |
| **Explicit reporting** | PASS | Every stage recorded with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` in `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `4a926a03` "fix(ruff): stop lint stage from silently rewriting files (#515)"; spec.md Proposed Fix section. |
| **Design choices explained** | PASS | Spec documents four directions (a)-(d) with the decisive policy-prohibition rationale for rejecting (b) and (c), and deferral rationale for (d). |
| **Update supporting documents** | PASS | Feature folder carries issue.md, spec.md, plan, research, and 20 evidence artifacts. No policy document was touched (verified in diff). |
| **Provide next steps** | PASS | Spec Rollout & Follow-up records the post-merge CI confirmation step and two follow-up recommendations. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check .`<br>**Result:** exit 0, no reformat needed (executor evidence; reviewer scoped re-run exit 0). |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check`<br>**Result:** exit 0, "All checks passed!", no working-tree write (executor evidence and reviewer independent re-run). |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright`<br>**Result:** exit 0, 0 errors, 0 warnings reported as gate failures (executor evidence; reviewer scoped re-run exit 0). |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest ...`<br>**Result:** 4116 passed, 0 failed, exit 0. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All functions annotated (`-> None`, `-> str`, `-> list[str]`); `from __future__ import annotations`; no `Any`, no suppressions. |
| **Dataclasses for value objects** | N/A | No value object introduced. |
| **Protocols/ABCs for interfaces** | N/A | No interface introduced. |
| **Avoid utility classes** | PASS | Module-level functions; no class introduced. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | No exception handling added; a missing target file raises the natural `FileNotFoundError` from `Path.read_text`, which fails the test loudly — correct fail-fast behavior for a guard test. |
| **Logging over print** | PASS | No `print` and no logging in the module; assertion messages carry the diagnostics. |
| **Invariants at construction** | N/A | No constructed object. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Plain pytest functions, no fixtures needed; collected and run under the repo `pyproject.toml` config. |
| **Coverage expectation** | PASS | Repo-wide Python 92.6067% lines / 85.2095% branches, both above the uniform thresholds (>= 85% / >= 75%); no changed-line regression possible (no measured line changed). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One invariant per test; four tests total. |
| **Mocking sparingly** | PASS | Zero mocks. |
| **Organization** | PASS | `tests/scripts/dev_tools/test_ruff_config_alignment.py` mirrors the established location of the sibling config-alignment guard `test_pyright_config_alignment.py`. No colocation in the production tree. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `snake_case` test names describing behavior under guard. |
| **Docstrings/comments** | PASS | Every test carries a one-line docstring stating the invariant. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py -v`<br>**Result:** 4 passed (reviewer run at review time and executor evidence `evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T14-03.md`). |
| **No Alternative Test Runners** | PASS | Only pytest is used. |

---

## 5. Test Coverage Detail

### test_ruff_config_alignment.py (4 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_ruff_config_does_not_enable_fix_mode` | Negative (defect reintroduction) | helpers + lines 66-74 | Pass |
| `test_ruff_config_retains_show_fixes` | Positive (diagnostic preserved) | helpers + lines 77-85 | Pass |
| `test_no_standalone_ruff_config_at_repository_root` | Negative (precedence bypass) | lines 88-100 | Pass |
| `test_quality_checks_workflow_still_runs_a_ruff_lint_step` | Positive (gate presence) | lines 103-117 | Pass |

**Coverage:** The module is test code and is deliberately outside the measured source set (`tests/*` omitted per `pyproject.toml:122-127`); every statement in it executes when the suite runs, and the fail-before artifact demonstrates its discriminating power against the pre-change tree.

**Not covered:** None. No production Python source changed, so no production coverage detail applies.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 4121 collected (4116 passed + 5 skipped) | Pass |
| Tests Passed | 4116 (100% of non-skipped) | Pass |
| Tests Failed | 0 | Pass |
| Execution Time | 21.15s total (full suite, pass 2) | Pass (fast) |
| Average Time per Test | ~5ms | Pass (fast) |
| New Module Standalone | 4 tests in 0.06s | Pass (fast) |
| Functions/Classes Tested | 4/4 new tests executing all module helpers | Pass |
| Test File Size | 117 lines | Pass (maintainable) |
| Code Coverage | 92.6067% lines, 85.2095% branches (repo-wide Python) | Pass |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | exit 0, 0 reformats needed | Pass |
| Ruff Linting | `poetry run ruff check` (bracketed by status snapshots) | exit 0, All checks passed!, no tree write | Pass |
| Pyright Type Checking | `poetry run pyright` | exit 0, 0 errors | Pass |
| Pytest Tests | `poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch ...` | 4116 passed, 0 failed, exit 0 | Pass |
| Evidence Locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | Pass |

**Notes:**
Pass 1 of the executor's final QA loop failed one pre-existing, unrelated test (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) because a gitignored session state file under `.claude/state/` was enumerated by the parity walk — the already-filed issue #510. The trigger file was removed (no working-tree change; the file is gitignored) and the loop was restarted from stage 1, completing clean in pass 2. This is documented with reproduction and non-attribution reasoning in `evidence/qa-gates/final-python-test-coverage.2026-08-24T14-16.md` and does not indicate a defect in this branch.

Minor observation, not a gate: the `artifacts/python/coverage.json` on disk at review time reports 4677 covered branches (85.1913%), one branch below the 4678 (85.2095%) quoted in the P4-T4 artifact — consistent with a subsequent local re-run and with the run-to-run variation the executor's own delta artifact anticipates. Both readings are above the 75% threshold and both show zero line-coverage movement.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None.** All policy requirements are met.

### Approved Exceptions

**None.** No exceptions needed. The spec explicitly declined to request a policy exception (research directions (b) and (c) were rejected precisely because they would require editing prohibited policy documents).

### Removed/Skipped Tests

**None removed.** The 5 skips in the full suite are pre-existing, module-declared parametrized cases in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py`, present identically at baseline and unrelated to this branch. The stdin differential test was consciously scoped out at spec time (non-goal 4) and delivered as manual QA-gate evidence instead; that is a documented scope decision, not a skipped implementation.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **62674373** - (docs): prepare issue 515 lint write-mode bug fix (feature docs: issue.md, spec.md, research, plan)
2. **4a926a03** - fix(ruff): stop lint stage from silently rewriting files (#515) (production change + tests + evidence)

### Files Modified

1. **pyproject.toml** (MODIFIED)
   - Deleted `fix = true` from the `[tool.ruff]` table (one line). `show-fixes = true` retained. No other line changed.

2. **tests/scripts/dev_tools/test_ruff_config_alignment.py** (NEW)
   - Four-test configuration-alignment regression module guarding fix-mode absence, show-fixes presence, standalone-config absence, and CI lint-step presence.

3. **docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/** (NEW, 24 files)
   - issue.md, spec.md, plan.2026-08-23T23-21.md, research artifact, and 20 evidence artifacts under `evidence/{baseline,regression-testing,qa-gates,other}/`.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable stages of the seven-stage toolchain pass in a single recorded pass; repo-wide Python coverage is 92.6067% lines / 85.2095% branches with zero regression; the diff matches the spec's authorized write set exactly; no policy document is modified; evidence locations are canonical; and the `modified-workflow-needs-green-run` rule does not trigger (no workflow, benchmark, or action path in the diff).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- Pass — Before Making Changes: objective, research, and plan documented
- Pass — Design Principles: minimal one-line fix plus precedent-following guard
- Pass — Module & File Structure: 117-line module, well under limits
- Pass — Naming, Docs, Comments: complete docstrings and rationale comments
- Pass — Toolchain Execution: single clean pass with restart rule honored
- Pass — Summarize & Document: spec, plan, and evidence complete

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- Pass — Tooling & Baseline: all four tools exit 0
- Pass — Python Design & Typing: fully annotated, no suppressions
- Pass — Error Handling: fail-fast semantics preserved

#### General Unit Test Policy (Section 1)
- Pass — Core Principles: independent, isolated, fast, deterministic, readable
- Pass — Coverage & Scenarios: thresholds met, no regression, fail-before recorded
- Pass — Test Structure: AAA with diagnostic messages
- Pass — External Dependencies: zero external dependencies, zero temp files in tests
- Pass — Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- Pass — Framework & Scope: pytest only, coverage above thresholds
- Pass — Test Style & Structure: focused, mock-free, correctly located
- Pass — Naming & Readability: descriptive names and docstrings
- Pass — Toolchain: verified by executor evidence and reviewer re-runs

---

### Metrics Summary

- Pass — 4116/4116 non-skipped tests passing (100%)
- Pass — 4 new tests, all discriminating (fail-before proven for the primary guard)
- Pass — 92.6067% line coverage, 85.2095% branch coverage (repo-wide Python)
- Pass — Proper file organization: test module mirrors production layout precedent
- Pass — All code quality checks passing (Black, Ruff, Pyright, Pytest, evidence-location validator)
- Pass — Test execution time: 21.15s full suite (fast)

---

### Recommendation

**Ready for merge.** No remediation required. Post-merge, confirm the first `Lint with Ruff` CI run on `main` passes, per the spec's rollout note — a failure there would indicate a pre-existing fixable violation previously hidden by the write-mode step.

---

## Appendix A: Test Inventory

### Complete Test List

- tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode
- tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_retains_show_fixes
- tests/scripts/dev_tools/test_ruff_config_alignment.py::test_no_standalone_ruff_config_at_repository_root
- tests/scripts/dev_tools/test_ruff_config_alignment.py::test_quality_checks_workflow_still_runs_a_ruff_lint_step

(4 new tests; the remaining 4112 passing tests are the pre-existing suite, unchanged by this branch.)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Formatting (check-only)
poetry run black --check .

# Linting (now read-only by default after this change)
poetry run ruff check
poetry run ruff check --fix  # explicit auto-fix, unchanged behavior

# Type checking
poetry run pyright

# Testing with coverage
poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json

# New regression module standalone
poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py -v
```

**Review-side verification commands run by this audit:**
```bash
git diff --name-only 80b65d2e..HEAD
poetry run python -m scripts.dev_tools.pr_context.collector --base main --head HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py -v
poetry run black --check tests/scripts/dev_tools/test_ruff_config_alignment.py
poetry run pyright tests/scripts/dev_tools/test_ruff_config_alignment.py
git status --porcelain   # before and after poetry run ruff check .
poetry run ruff check .
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-08-24
**Policy Version:** Current (as of audit date)
