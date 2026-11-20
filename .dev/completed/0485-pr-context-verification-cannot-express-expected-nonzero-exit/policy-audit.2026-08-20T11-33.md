# Policy Compliance Audit: PR-Context ExpectedExitCode Evidence Key (Issue #485)

**Audit Date:** 2026-08-20
**Code Under Test:**
- `scripts/dev_tools/pr_context/verification_evidence.py` (modified)
- `scripts/dev_tools/pr_context/collector.py` (modified)
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (modified)
- `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` (modified)
- `tests/scripts/dev_tools/pr_context/__init__.py` (new)
- `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` (new)
- `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` (new)
- `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` (modified, additions only)
- `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` (modified, additions only)
- Six copies of `evidence-and-timestamp-conventions/SKILL.md` (documentation, modified)
- 60 files under `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/` (scoping docs and evidence, markdown only)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 5 files | 3995 tests | PASS 3995 pass, 0 fail, 5 skipped | 92.43% lines, 84.90% branches | 92.45% lines, 84.93% branches | 100% |
| TypeScript | 4 files | 2580 tests | PASS 2580 pass, 0 fail | 96.61% lines, 89.96% branches | 96.62% lines, 89.98% branches | 100% |

Markdown documentation files (six SKILL.md copies and the feature-folder docs/evidence) carry no coverage requirement. PowerShell, C#, Bash, and JSON have zero changed files on this branch, so their rows are omitted per the template note.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/baseline/ts-test-coverage.2026-08-20T09-53.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (re-parsed by this audit) and `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/qa-gates/final-ts-test-coverage.2026-08-20T09-53.md`
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on this branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on this branch)
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/qa-gates/coverage-delta.2026-08-20T09-53.md`
- Python baseline coverage artifact: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/baseline/py-pytest-coverage.2026-08-20T09-53.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (re-parsed by this audit) and `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/qa-gates/final-py-pytest-coverage.2026-08-20T09-53.md`

---

## Executive Summary

This audit reviews the full branch diff of `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485` (head `a1a68417`) against the resolved base branch `main` (merge base `71aebdb9`). The branch adds one optional, integer-valued evidence key `ExpectedExitCode` to the PR-context verification-evidence schema in both parity runtimes (Python and TypeScript), changes normalization from "observed equals zero" to "observed equals declared expectation" via an extracted pure helper per runtime, adds one conditional rendered row line, documents the key in all six copies of `evidence-and-timestamp-conventions/SKILL.md`, and adds 57 Python tests plus 22 TypeScript tests without editing any pre-existing test.

**Policy documents evaluated:**
- PASS `general-code-change` policy (`.claude/rules/general-code-change.md`)
- PASS `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` and Python unit-test policy
- PASS `.claude/rules/typescript.md` and TypeScript unit-test policy
- N/A PowerShell policies (zero changed PowerShell files)
- N/A C# policies (zero changed C# files)
- N/A Bash and JSON policies (zero changed files of either kind)

Toolchain result: format, lint, type-check, and full test suites re-run by this audit for both languages; all clean in a single pass. Coverage verdicts: Python PASS, TypeScript PASS (both repo-wide and per changed file; changed-line coverage 100%). The `modified-workflow-needs-green-run` rule does not fire: the branch diff touches no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (verified by `git diff --name-only 71aebdb9..HEAD` filtered on those prefixes, zero matches).

**Template sourcing note:** the review artifacts were created from the bundled template assets at `extensions/drm-copilot/resources/templates/policy_audit/`, the same asset files served by the MCP resolver tool. The templates' canonical structure is preserved and their instruction blocks were removed.

**Temporary artifacts cleanup:**
- PASS All temporary/one-time scripts created during development were deleted. The Layer 2 corpus-comparison harness was throwaway by design; `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/qa-gates/throwaway-script-removed.2026-08-20T09-53.md` records its removal, and no throwaway script appears in the branch diff.
- PASS No ongoing tooling scripts were introduced by this change.

## Rejected Scope Narrowing

No scope narrowing was attempted. The caller prompt explicitly instructed a full feature-vs-base audit and disclaimed that its two collection-mechanism observations were not scope-narrowing instructions. This audit covers the full branch diff (75 files) against `main`.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited `0` (clean).
- The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero matches. All 60 evidence files added by this branch live under the canonical `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/<kind>/` tree.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred; no caller instruction supplied a non-canonical evidence path.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | New Python tests build parser input inline per test and seed collector inputs through the in-memory `mem_fs_path` fixture; no shared mutable state. New TypeScript tests construct markdown strings inline. Full suites pass under default parallel/ordered discovery (3995 Python, 2580 TypeScript). |
| **Isolation** - Each test targets single behavior | PASS | Each new test asserts one parser or renderer behavior (e.g., `test_duplicate_expectation_key_takes_first_occurrence`, `it("reports unparseable for a non-integer expectation")`). Parametrized cases isolate one input shape each. |
| **Fast Execution** - Tests complete quickly | PASS | Targeted new-module runs: 57 Python tests in 0.09-0.46s; 44 TypeScript tests in the two changed suites in 0.46s. Full suites: Python 6.97s, TypeScript 3.30s. |
| **Determinism** - Consistent results | PASS | No wall-clock reads, no randomness, no timers, no network. Grep of the four new/changed test files for `tmp_path`, `tempfile`, `setTimeout`, `Date.now`, `sleep` returns only a docstring stating `tmp_path` is never used. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive snake_case/pytest names and Jest `describe`/`it` sentences; module docstrings state scope and the in-memory-filesystem constraint. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development):** Python 92.43% lines, 84.90% branches; TypeScript 96.61% lines, 89.96% branches.<br>**Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`; `npm run test:coverage`.<br>**Timestamp:** 2026-08-20 09:53.<br>Recorded in `evidence/baseline/py-pytest-coverage.2026-08-20T09-53.md` and `evidence/baseline/ts-test-coverage.2026-08-20T09-53.md`. |
| **No Coverage Regression** | PASS | **Post-change coverage:** Python 92.45% lines (+0.02 pp), 84.93% branches (+0.03 pp); TypeScript 96.62% lines (+0.01 pp), 89.98% branches (+0.02 pp).<br>**Status:** No regression; all four metrics improved. Independently re-derived by this audit from `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info`. |
| **New Code Coverage >= 90%** | PASS | **New/modified production files:** the four production files listed above.<br>**New code coverage:** 100% (75 of 75 added lines with an LCOV record covered, 0 missed).<br>**Calculation method:** intersection of `git diff -U0` added-line numbers with `DA:` records; independently re-verified by this audit — every uncovered line/branch in all four files falls outside the changed hunks. |
| **Comprehensive Coverage** | PASS | `normalize_result` / `normalizeResult` (new helpers): exhaustively tested over -8..8 plus large-magnitude values. Parser expectation paths: absent, zero, non-zero equal, non-zero different, non-integer, empty, duplicated, wrong-cased. Renderer: non-zero renders line, zero/absent omits it. Untested lines in the two parser files are pre-existing (e.g., `verification_evidence.py:124`). |
| **Positive Flows** - Valid inputs | PASS | `test_observed_equal_to_nonzero_expectation_passes[1-1, 137-137, -3--3]`, `test_absent_expectation_records_match_pre_change_shapes`, TS equivalents. |
| **Negative Flows** - Invalid inputs | PASS | `test_non_integer_expectation_is_unparseable_and_clears_fields[banana, empty]`, `test_observed_differing_from_nonzero_expectation_fails[2-1, 0-1]`, TS equivalents. |
| **Edge Cases** - Boundary conditions | PASS | Large-magnitude exit codes (2147483647), negative expectations, duplicated key first-wins, values containing further colons, wrong-cased key discarded. |
| **Error Handling** - Error paths | PASS | `test_parse_verification_evidence_file_propagates_read_failure` verifies read failures propagate rather than being swallowed. `EXIT_CODE: SKIPPED` remains `unparseable` with and without an expectation. |
| **Concurrency** - If applicable | N/A | Pure parsing/rendering functions; no concurrency surface. |
| **State Transitions** - If applicable | N/A | Stateless record construction; no stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.43% lines (13527/14635), 84.90% branches. Post-change: 92.45% lines (13542/14648), 84.93% branches. Change: +0.02 pp lines, +0.03 pp branches. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/qa-gates/coverage-delta.2026-08-20T09-53.md`.
- TypeScript: Baseline: 96.61% lines (41750/43212), 89.96% branches. Post-change: 96.62% lines (41810/43272), 89.98% branches. Change: +0.01 pp lines, +0.02 pp branches. New/changed-code coverage: 100%. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/qa-gates/coverage-delta.2026-08-20T09-53.md`.
- PowerShell: zero changed files on this branch. Disposition: N/A - out of scope. Evidence: `git diff --name-only 71aebdb9..HEAD` contains no `.ps1`/`.psm1`/`.psd1` path.
- C#: zero changed files on this branch. Disposition: N/A - out of scope. Evidence: `git diff --name-only 71aebdb9..HEAD` contains no `.cs` path.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions compare whole records/rendered strings so a mismatch prints both sides; parametrized IDs (e.g., `[2-1]`, `[key-written-as-zero]`) identify the failing input shape directly. |
| **Arrange-Act-Assert Pattern** | PASS | Each test arranges markdown/fixture input, invokes the parser or renderer once, and asserts on the returned record or string. |
| **Document Intent** | PASS | Test names state the behavior under test; module docstrings explain the sibling-module placement and the eleven-shape parity table ordering contract. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No database, network, subprocess, or external API in any new test. |
| **Use Mocks/Stubs** | PASS | Collector-level Python tests use the repository's in-memory `mem_fs_path` fixture rather than the real filesystem; TypeScript tests pass in-memory `FileSystem` fakes per existing suite conventions. |
| **Environment Stability** | PASS | No temporary files (prohibited by policy) are created; grep for `tmp_path`/`tempfile` across the new tests confirms the prohibition is honored. No mutable global state. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy review for the branch, produced by the feature-review workflow before PR authoring. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #485; `issue.md`, `spec.md` (version 1.0, work mode `full-bug`), and research doc `research/2026-08-17T16-10-expected-nonzero-exit-research.md` define the defect and the fix contract. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.md` records the policy reading order; `plan.2026-08-17T15-00.md` is the executed atomic plan. |
| **Document the plan** | PASS | `plan.2026-08-17T15-00.md` with per-task acceptance gates; AC inventory mapped to tasks in `evidence/baseline/ac-inventory.2026-08-20T09-53.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One flat optional key, default 0, equality comparison. Rejected alternatives (list-valued, boolean, per-gate schema) are documented in spec.md with rationale. |
| **Reusability** | PASS | Normalization extracted into a pure two-argument helper per runtime (`normalize_result` / `normalizeResult`) instead of duplicating the comparison inline. |
| **Extensibility** | PASS | The single-integer key is a strictly additive base for a future list form (a bare integer is a valid one-element list); `REQUIRED_FIELDS` is untouched so the required-schema contract is unchanged. |
| **Separation of concerns** | PASS | Parsing (pure, no I/O) stays in the parser modules; the renderer change is one conditional row line in each collector-output layer. No import edge to the atomic-executor QC path (verified: `git grep -n -E "qc_runner_expectations|pytest_expectations" -- scripts/dev_tools/pr_context extensions/drm-copilot/src/lib/pr-context` exits 1). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Changes land in the existing parity-pair modules; the Python collector-level tests go in a new sibling module rather than growing the over-limit `test_collect_pr_context_part4.py`. |
| **Under 500 lines** | PARTIAL | `verification_evidence.py` 215, `verification-evidence.ts` 303, `collector-output.ts` 454, new test files 408/141, changed TS test files 456/445 — all within limit. `collector.py` is 623 lines: a pre-existing violation that grew by 4 lines (spec AC20 caps growth at 5; extraction is recorded as follow-up in spec.md "Post-fix monitoring or clean-up tasks"). See section 8. |
| **Public vs internal** | PASS | Python helper is module-level and documented; TypeScript exports `EXPECTED_EXIT_CODE_FIELD` and `normalizeResult` alongside the existing exported constants; the record type gains one documented member. |
| **No circular dependencies** | PASS | No new imports between modules; the parser remains dependency-free of the executor QC path. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `ExpectedExitCode`, `expected_exit_code`/`expectedExitCode`, `normalize_result`/`normalizeResult` follow language conventions (snake_case Python, camelCase TypeScript). |
| **Docs/docstrings** | PASS | Google-style docstring with Side Effects on the Python helper; TSDoc on the TypeScript helper and record member; the six SKILL.md copies document the key's exact casing, default, unparseable behavior, first-wins rule, and per-file scope. |
| **Comment why, not what** | PASS | Comments explain rationale (e.g., why the TypeScript addition is a separate `if` rather than `else if`: to keep the required-field block byte-identical). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `poetry run black --check` (changed Python scope); `npx prettier --check` (changed TypeScript scope).<br>**Result:** re-run by this audit 2026-08-20T11-33; no changes needed, exit 0 both. |
| **2. Linting** | PASS | **Command:** `poetry run ruff check` (changed scope); `npx eslint` (changed scope).<br>**Result:** re-run by this audit; zero findings, exit 0 both. |
| **3. Type checking** | PASS | **Command:** `poetry run pyright scripts/dev_tools/pr_context tests/scripts/dev_tools/pr_context tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`; `npm run typecheck` (`tsc -p ./ --noEmit`).<br>**Result:** re-run by this audit; 0 errors both. |
| **4. Testing** | PASS | **Command:** `poetry run pytest -q` (full suite); `npm run test:unit` (full suite).<br>**Result:** re-run by this audit; Python 3995 passed / 5 skipped in 6.97s; TypeScript 2580 passed across 185 suites in 3.30s. |
| **Full toolchain loop** | PASS | Executor's final single clean pass recorded in `evidence/qa-gates/final-qc-single-clean-pass.2026-08-20T09-53.md`; this audit's independent re-run also completed in one pass with no file modified. |
| **Explicit reporting** | PASS | Commands and results recorded per stage under `evidence/qa-gates/` and reproduced in this audit's Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | `spec.md` "Delivered outcome (recorded 2026-08-20)" and `issue.md` "Delivered Outcome" summarize the change set and verification results. |
| **Design choices explained** | PASS | Spec records the chosen design and the rejected alternatives with reasons (research sections cited inline). |
| **Update supporting documents** | PASS | Six copies of `evidence-and-timestamp-conventions/SKILL.md` updated byte-identically (push-down contract tests pass; `git grep -c "ExpectedExitCode"` reports 3 matches in each of the six files). |
| **Provide next steps** | PASS | `issue.md` "Next Step" and spec "Post-fix monitoring or clean-up tasks" record the pending promotion of the duplicate-required-key precedence defect. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check scripts/dev_tools/pr_context tests/scripts/dev_tools/pr_context tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`<br>**Result:** 14 files unchanged, exit 0 (audit re-run). |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check` (same scope)<br>**Result:** all checks passed, exit 0 (audit re-run). |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright` (same scope)<br>**Result:** 0 errors, 0 warnings (audit re-run); full-repo run recorded in `evidence/qa-gates/final-py-pyright.2026-08-20T09-53.md`. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest -q`<br>**Result:** 3995 passed, 5 skipped (audit re-run). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | `expected_exit_code: int = 0` on the frozen-style dataclass; helper fully annotated (`int, int -> NormalizedResult`); no `Any` introduced. |
| **Dataclasses for value objects** | PASS | The existing `VerificationEvidenceRecord` dataclass gains one defaulted field appended last, avoiding construction-site breakage (verified against `evidence/baseline/record-construction-sites.2026-08-20T09-53.md`). |
| **Protocols/ABCs for interfaces** | N/A | No new interface surface. |
| **Avoid utility classes** | PASS | New behavior is a module-level function, not a static-method class. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | The expectation parse catches exactly `ValueError` from `int()` and converts it to the documented `unparseable` record; no broad catch. |
| **Logging over print** | PASS | No logging or print added; `evidence/qa-gates/py-no-logging-gate.2026-08-20T09-53.md` records the gate. |
| **Invariants at construction** | PASS | Every `unparseable` record uniformly carries `exit_code=None` and `expected_exit_code=0` (Invariant E), enforced at each construction site and pinned by tests. |

### Section 3E: TypeScript Code Change Policy Compliance

#### 3E.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | **Command:** `npx prettier --check` on the four changed TypeScript files.<br>**Result:** all files use Prettier style, exit 0 (audit re-run). |
| **Linting with ESLint** | PASS | **Command:** `npx eslint` on the four changed TypeScript files.<br>**Result:** zero findings, exit 0 (audit re-run). |
| **Type checking with TSC** | PASS | **Command:** `npm run typecheck` from `extensions/drm-copilot/`.<br>**Result:** exit 0 (audit re-run). |
| **Testing with Jest** | PASS | **Command:** `npm run test:unit`.<br>**Result:** 2580 passed, 185 suites (audit re-run). |

#### 3E.2 TypeScript Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | `readonly expectedExitCode: number` on the exported record interface; `parseIntegerStrict` reused for the new value; no suppression comments added (grep of the diff for `eslint-disable`/`@ts-` returns zero additions). |
| **Parity with Python** | PASS | Helper signature and semantics mirror `normalize_result`; the eleven-shape fixture table is transcribed in both suites in the same order (AC8). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Both new modules are pytest-native with `pytest.mark.parametrize`; the collector-level module reuses the repository's `mem_fs_path` fixture. |
| **Coverage expectation** | PASS | New/changed-code coverage 100%; repo-wide 92.45% lines, 84.93% branches, above the 85%/75% uniform thresholds. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | 12 test functions expanding to 54 parser cases plus 3 collector-level cases, each pinning one behavior. |
| **Mocking sparingly** | PASS | Only the filesystem is faked (in-memory fixture); the parser is exercised directly on strings. |
| **Organization** | PASS | `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` mirrors `scripts/dev_tools/pr_context/verification_evidence.py`; the collector-level module is a documented sibling of the over-limit `test_collect_pr_context_part4.py`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | Behavior-stating names, e.g. `test_non_integer_expectation_is_unparseable_and_clears_fields`. |
| **Docstrings/comments** | PASS | Module docstrings state scope, constraints, and the private-renderer suppression rationale (single-line scope, precedent cited). |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest -q`<br>**Result:** 3995 passed, 5 skipped, 6.97s. |
| **No Alternative Test Runners** | PASS | Only pytest is used. |

### Section 4E: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | Additions extend the existing `describe` blocks with `it` and `it.each` cases; no new runner. |
| **Existing tests unmodified** | PASS | `git diff --numstat` shows additions only (237+0, 62+0) in the two changed suites; the nine pre-existing parser tests and four renderer tests pass without body edits (AC25). |
| **Determinism infrastructure** | PASS | No timers, no `Date.now`, no fake-timer need (pure functions). |

---

## 5. Test Coverage Detail

### `normalize_result` / `normalizeResult` (extracted pure helpers)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_normalize_result_with_default_expectation_matches_pre_change_expression` (21 parametrized cases: -8..8 plus 4 large-magnitude) | Positive/Edge Case | `verification_evidence.py:60-74` | PASS |
| `normalizeResult with a zero expectation matches the pre-change expression` | Positive/Edge Case | `verification-evidence.ts:56-67` | PASS |

**Coverage:** 100% of both helpers.

### `parse_verification_evidence_markdown` / `parseVerificationEvidenceMarkdown` (expectation paths)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_absent_expectation_records_match_pre_change_shapes` (8 shapes) | Positive | default-to-zero path | PASS |
| `test_observed_equal_to_nonzero_expectation_passes` (3 cases) | Positive | pass-on-equality path | PASS |
| `test_observed_differing_from_nonzero_expectation_fails` (2 cases) | Negative | fail-on-difference path | PASS |
| `test_non_integer_expectation_is_unparseable_and_clears_fields` (2 cases) | Negative/Error Handling | `verification_evidence.py:158-174` | PASS |
| `test_duplicate_expectation_key_takes_first_occurrence` | Edge Case | first-wins guard `verification_evidence.py:129-130` | PASS |
| `test_skipped_exit_code_remains_unparseable` (2 cases) | Error Handling | Invariant F | PASS |
| `test_unrecognized_rows_are_ignored` | Edge Case | accept-list confinement | PASS |
| `test_eleven_shape_fixture_table` and TS `it.each(shapeCases)` | Parity | full record agreement across runtimes | PASS |

**Not covered:** `verification_evidence.py:124` (pre-existing early-return line outside the changed hunks); pre-existing branches at lines 98 and 123. No changed line or branch is uncovered.

### Renderers (`_render_verification_evidence_section` / `renderVerificationEvidenceSection`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_renderer_emits_expectation_line_for_non_zero_expectation` | Positive | `collector.py:156-158,166` | PASS |
| `test_renderer_omits_expectation_line_for_zero_expectation` (key-omitted, key-written-as-zero) | Negative/Edge Case | omission branch | PASS |
| `renders the expectation line for a non-zero declared expectation` plus zero/absent cases (TS) | Positive/Negative | `collector-output.ts:116-119,126` | PASS |

**Not covered:** none of the changed renderer lines; remaining uncovered lines in `collector.py` and `collector-output.ts` are pre-existing and outside the changed hunks.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (Python full suite) | 3995 passed, 5 skipped | PASS |
| Total Tests (TypeScript full suite) | 2580 passed, 185 suites | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Python 6.97s; TypeScript 3.30s | PASS Fast |
| New tests added | 57 Python (54 parser + 3 collector-level), 22 TypeScript | PASS |
| Changed test suites (targeted) | 57 Python new-module tests; 44 tests in the two changed TS suites | PASS |
| Test File Size | 408 / 141 / 456 / 445 lines (all <= 500) | PASS Maintainable |
| Code Coverage | Python 92.45% lines / 84.93% branches; TypeScript 96.62% lines / 89.98% branches | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` (changed scope) | 14 files unchanged | PASS |
| Ruff Linting | `poetry run ruff check` (changed scope) | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright` (changed scope) | 0 errors, 0 warnings | PASS |
| Pytest Tests | `poetry run pytest -q` (full suite) | 3995 passed, 5 skipped | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check` (changed files) | All files formatted | PASS |
| ESLint | `npx eslint` (changed files) | Zero findings | PASS |
| TSC | `npm run typecheck` | Exit 0 | PASS |
| Jest | `npm run test:unit` | 2580 passed / 185 suites | PASS |

**Notes:**
All audit re-runs executed 2026-08-20T11-33 in this worktree at head `a1a68417` with a clean working tree. Executor-recorded full-scope runs are under `evidence/qa-gates/final-*.2026-08-20T09-53.md` and agree with the audit re-runs. Pre-existing failures: none observed.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **AC10 and AC17 (cross-runtime corpus parity) are PARTIAL, not PASS.** The corpus comparison over the 641 single-`EXIT_CODE` artifacts reported 5 content differences plus 1 presence difference, all attributable to a pre-existing duplicate-required-key precedence divergence (Python last-wins vs TypeScript first-wins) that this branch deliberately does not touch because converging it would change reported results for existing artifacts and violate the change's additive requirement. No difference touches an `EXIT_CODE` row, a `Normalized result` row, or the new `Expected EXIT_CODE` row. Both criteria remain unchecked in `spec.md`; remediation is routed through `remediation-inputs.2026-08-20T11-33.md` (promotion of the follow-up defect, not a code change on this branch). Evidence: `evidence/other/additive-corpus-parity.2026-08-20T09-53.md`.
- **`scripts/dev_tools/pr_context/collector.py` is 623 lines**, over the 500-line limit. Pre-existing violation; this branch added 4 lines (within spec AC20's 5-line cap). Extraction is recorded as follow-up in spec.md; not remediated here to keep the bugfix minimal.

### Approved Exceptions

- **Deferred duplicate-required-key precedence divergence.** Documented in spec.md "Out of scope" and "Post-fix monitoring or clean-up tasks", with the promotion path named (`potential-to-issue`) and the widened scope specified (duplicate REQUIRED key, not only `EXIT_CODE`). The spec's own risk R3 pre-recorded that the corpus comparison would be contaminated by this defect.
- **`collector.py` over-limit growth.** Pre-recorded in spec risk R4 with mitigation (5-line cap, sibling test module); satisfied as specified.

### Removed/Skipped Tests

**None.** No pre-existing test was edited, removed, or skipped (verified: `git diff --numstat` on the pre-existing test files shows zero deletions; `evidence/qa-gates/existing-tests-unmodified-final.2026-08-20T09-53.md`). The 5 skipped Python tests are pre-existing parametrized skips in `test_parallel_manifest_bash_parity.py`, unrelated to this branch.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **468dbe1e** - docs(485): prepare expected-nonzero-exit fix (research, spec, plan)
2. **a1a68417** - fix(485): add ExpectedExitCode to PR-context verification evidence

### Files Modified

1. **`scripts/dev_tools/pr_context/verification_evidence.py`** (MODIFIED, +45/-1)
   - Adds `EXPECTED_EXIT_CODE_FIELD`, the defaulted `expected_exit_code` record field, the pure `normalize_result` helper, first-wins acceptance of the optional key, and the non-integer-expectation `unparseable` path. `REQUIRED_FIELDS` unchanged.
2. **`extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`** (MODIFIED, +56/-1)
   - Mirror of the Python change: exported constant, record member, `normalizeResult`, separate-`if` parse acceptance, strict-integer expectation parsing.
3. **`scripts/dev_tools/pr_context/collector.py`** (MODIFIED, +4)
   - Conditional `  - Expected EXIT_CODE: <int>` row between `EXIT_CODE` and `Normalized result`, rendered only for a non-zero expectation.
4. **`extensions/drm-copilot/src/lib/pr-context/collector-output.ts`** (MODIFIED, +5)
   - Same conditional row in the TypeScript renderer.
5. **`tests/scripts/dev_tools/pr_context/__init__.py`, `tests/scripts/dev_tools/pr_context/test_verification_evidence.py`** (NEW)
   - 54 parser tests including the eleven-shape parity fixture table.
6. **`tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`** (NEW)
   - 3 collector-level renderer tests using the in-memory filesystem fixture.
7. **`extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts`, `collector-output.test.ts`** (MODIFIED, additions only)
   - 22 added TypeScript tests mirroring the Python coverage, including `it.each(shapeCases)`.
8. **Six copies of `evidence-and-timestamp-conventions/SKILL.md`** (MODIFIED, +13 each)
   - Documents the optional key, its exact casing, default, unparseable rule, first-wins rule, per-file scope, and rendering behavior.
9. **60 files under the feature folder** (NEW/MODIFIED, markdown)
   - issue/spec/plan/research updates and the canonical evidence tree (`baseline/`, `qa-gates/`, `regression-testing/`, `other/`, `issue-updates/`).

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

All toolchain gates, coverage thresholds, evidence-location rules, documentation push-down contracts, and test policies pass. Two spec acceptance criteria (AC10, AC17) are PARTIAL due to a pre-existing, explicitly deferred cross-runtime defect, and one pre-existing file-size violation (`collector.py`) grew by 4 lines within its spec-sanctioned cap. Neither gap is introduced by this branch; both have documented follow-up paths.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, plan, and baselines documented.
- PASS Design Principles: minimal additive design with documented alternatives.
- PARTIAL Module & File Structure: `collector.py` pre-existing over-limit (+4 lines, capped and documented).
- PASS Naming, Docs, Comments: conventions followed, rationale-focused comments.
- PASS Toolchain Execution: single clean pass, independently re-run by this audit.
- PASS Summarize & Document: spec/issue delivered-outcome sections complete.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline: black/ruff/pyright/pytest all clean.
- PASS Python Design & Typing: fully annotated, defaulted dataclass field appended last.
- PASS Error Handling: specific `ValueError` catch, uniform unparseable invariant.

**For TypeScript:**
- PASS Tooling & Baseline: prettier/eslint/tsc/jest all clean.
- PASS Design & Typing: readonly typed member, strict integer parsing, no suppressions.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: independent, isolated, fast, deterministic, readable.
- PASS Coverage & Scenarios: 100% changed-line coverage; thresholds cleared; no regression.
- PASS Test Structure: AAA with parametrized diagnostics.
- PASS External Dependencies: in-memory filesystem only; no temporary files.
- PASS Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope; PASS Test Style & Structure; PASS Naming & Readability; PASS Toolchain.

**For TypeScript:**
- PASS Framework & Scope; PASS existing-tests-unmodified constraint; PASS determinism.

### Metrics Summary

- PASS 3995/3995 Python tests passing; 2580/2580 TypeScript tests passing.
- PASS Python coverage 92.45% lines / 84.93% branches (thresholds 85% / 75%).
- PASS TypeScript coverage 96.62% lines / 89.98% branches (thresholds 85% / 75%).
- PASS New/changed-code coverage 100% across all four changed production files.
- PASS No coverage regression in any metric; all four repo-wide metrics improved.
- PASS All code quality checks passing in a single pass.

### Recommendation

**Ready for merge, conditional on the documented follow-up.** The branch is policy-clean for its own scope. Before or immediately after PR authoring: (1) push head `a1a68417` to `origin` (the branch is currently 1 commit ahead of its upstream); (2) promote the duplicate-required-key precedence divergence as its own bug via the potential-to-issue path (already queued as the unchecked "Next Step" item in `issue.md`), which is the remediation route for the PARTIAL AC10/AC17. No code change on this branch is required.

---

## Appendix A: Test Inventory

### Complete Test List

New Python parser tests (`tests/scripts/dev_tools/pr_context/test_verification_evidence.py`, 54 cases from 12 functions):

- test_verification_evidence.py::test_absent_expectation_records_match_pre_change_shapes (8 shape cases)
- test_verification_evidence.py::test_normalize_result_with_default_expectation_matches_pre_change_expression (21 cases: -8..8 and 4 large-magnitude values)
- test_verification_evidence.py::test_observed_equal_to_nonzero_expectation_passes (cases 1-1, 137-137, -3--3)
- test_verification_evidence.py::test_observed_differing_from_nonzero_expectation_fails (cases 2-1, 0-1)
- test_verification_evidence.py::test_non_integer_expectation_is_unparseable_and_clears_fields (banana, empty)
- test_verification_evidence.py::test_duplicate_expectation_key_takes_first_occurrence
- test_verification_evidence.py::test_skipped_exit_code_remains_unparseable (without-expectation, with-expectation)
- test_verification_evidence.py::test_unrecognized_rows_are_ignored
- test_verification_evidence.py::test_value_containing_further_colons_is_preserved_intact
- test_verification_evidence.py::test_parse_verification_evidence_file_propagates_read_failure
- test_verification_evidence.py::test_parse_verification_evidence_file_reads_declared_expectation
- test_verification_evidence.py::test_eleven_shape_fixture_table (eleven parity shapes)

New Python collector-level tests (`tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py`, 3 cases):

- test_collect_pr_context_expected_exit.py::test_renderer_emits_expectation_line_for_non_zero_expectation
- test_collect_pr_context_expected_exit.py::test_renderer_omits_expectation_line_for_zero_expectation (key-omitted, key-written-as-zero)

New TypeScript tests (22 added cases across the two changed suites), explicit titles:

- parseVerificationEvidenceMarkdown - defaults the expectation to zero and matches pre-change records
- normalizeResult with a zero expectation matches the pre-change expression
- parseVerificationEvidenceMarkdown - normalizes to pass when the observed code equals a non-zero expectation
- parseVerificationEvidenceMarkdown - normalizes to fail when the observed code differs from a non-zero expectation
- parseVerificationEvidenceMarkdown - reports unparseable for a non-integer expectation
- parseVerificationEvidenceMarkdown - takes the first occurrence of a duplicated expectation key
- parseVerificationEvidenceMarkdown - reports unparseable for EXIT_CODE SKIPPED
- parseVerificationEvidenceMarkdown - ignores rows outside the accept-list
- parseVerificationEvidenceMarkdown - it.each(shapeCases) eleven-shape parity table
- renderVerificationEvidenceSection - renders the expectation line for a non-zero declared expectation
- renderVerificationEvidenceSection - zero/absent expectation omission cases

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Formatting
poetry run black --check scripts/dev_tools/pr_context tests/scripts/dev_tools/pr_context tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py

# Linting
poetry run ruff check scripts/dev_tools/pr_context tests/scripts/dev_tools/pr_context tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py

# Type checking
poetry run pyright scripts/dev_tools/pr_context tests/scripts/dev_tools/pr_context tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py

# Testing (full suite)
poetry run pytest -q

# Coverage (executor artifact re-parsed by this audit)
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**For TypeScript (from `extensions/drm-copilot/`):**
```bash
# Formatting
npx prettier --check src/lib/pr-context/verification-evidence.ts src/lib/pr-context/collector-output.ts test/lib/pr-context/verification-evidence.test.ts test/lib/pr-context/collector-output.test.ts

# Linting
npx eslint src/lib/pr-context/verification-evidence.ts src/lib/pr-context/collector-output.ts test/lib/pr-context/verification-evidence.test.ts test/lib/pr-context/collector-output.test.ts

# Type checking
npm run typecheck

# Testing (full suite)
npm run test:unit
```

**Audit-specific verification commands:**
```bash
# Scope and invariants
git diff --name-status 71aebdb9..HEAD
git grep -n -E "qc_runner_expectations|pytest_expectations" -- scripts/dev_tools/pr_context extensions/drm-copilot/src/lib/pr-context   # exits 1 (AC18)
git grep -c "ExpectedExitCode" -- "*evidence-and-timestamp-conventions/SKILL.md"   # 3 matches in each of six files (AC23)
git diff --numstat 71aebdb9..HEAD -- extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts   # additions only (AC25)

# Evidence locations
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .   # exit 0
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-08-20
**Policy Version:** Current (as of audit date)
