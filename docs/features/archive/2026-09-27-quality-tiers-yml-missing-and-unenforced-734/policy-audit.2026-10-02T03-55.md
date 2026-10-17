# Policy Compliance Audit: quality-tiers.yml classification and tier-classification gate (#734)

---

**Audit Date:** 2026-10-02
**Code Under Test:** `scripts/dev_tools/quality_tiers_contract.py` (new, 391 lines), `scripts/dev_tools/check_quality_tiers.py` (new, 193 lines), `tests/scripts/dev_tools/test_quality_tiers_contract.py` (new, 495 lines), `tests/scripts/dev_tools/test_check_quality_tiers.py` (new, 388 lines), `quality-tiers.yml` (new, 75 lines), `.github/workflows/_quality-checks.yml` (one added step), and the citation correction in `.claude/rules/quality-tiers.md`, `.agents/skills/quality-tiers/SKILL.md`, and their two bundled copies under `extensions/drm-copilot/resources/`. Branch `bug/quality-tiers-yml-missing-and-unenforced-734`, head `bd731f4eb4d489fbfd25cae4111303dc7f41340c`, base `origin/main`, merge base `b080a69ecb60b65d016362b21fffed0a34be9144`. Full branch diff: 91 files, 3281 insertions, 4 deletions (82 of the files are feature-folder documentation and evidence).

**Template source:** the structure of the most recent committed policy audit in this repository (`docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/policy-audit.2026-10-02T00-54.md`).

**Review type:** Initial feature review.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 4 files (2 production, 2 test; all new) | 61 new test cases (42 functions); full suite 6393 passed, 6 skipped | ✅ PASS | 93.53% lines, 86.76% branches | 93.61% lines, 86.89% branches | `quality_tiers_contract.py` 98.43% lines / 96.15% branches; `check_quality_tiers.py` 100.00% lines / 91.67% branches |
| YAML (GitHub Actions workflow, `quality-tiers.yml`) | 2 files | N/A | ✅ actionlint exit 0; CI run 36980560291 green | N/A (not a coverage language) | N/A | N/A |
| Markdown (policy mirrors, feature docs) | 85 files | N/A | ✅ parity tests pass | N/A | N/A | N/A |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- Python baseline coverage artifact: `artifacts/python/coverage-baseline.json` (2026-10-02 03:21) and `evidence/baseline/coverage-totals.2026-10-02T03-18.md`
- Python post-change coverage artifact: `artifacts/python/coverage.json` and `artifacts/python/lcov.info` (both written 2026-10-02 03:43, after the last code commit e918d4da at 03:41), plus `evidence/qa-gates/final-coverage-totals.2026-10-02T03-41.md` and `evidence/qa-gates/coverage-delta.2026-10-02T03-41.md`
- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Per-language comparison summary: Section 1.2.1 of this audit

---

## Executive Summary

This audit evaluates the full branch diff against `origin/main` (merge base `b080a69e`). The change adds a root `quality-tiers.yml` (24 entries, T3/T4 only), a pure validation core and a CLI wrapper, 61 hermetic unit test cases, a `tier-classification` step in the `quality-checks7` job, and the operator-approved citation correction in four policy/skill files.

No blocking policy finding was identified. One non-blocking PARTIAL is recorded (PA-1: one test function without a `-> None` return annotation, plan deviation D3).

Independent reviewer re-runs at head `bd731f4e`:
- `poetry run black --check` on the four new Python files: exit 0.
- `poetry run ruff check` on the four new Python files: exit 0.
- `poetry run pyright` on the four new Python files: 0 errors.
- `poetry run pytest` on the two new test files plus `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_claude_rules_frontmatter.py`: 92 passed.
- `poetry run python -m scripts.dev_tools.check_quality_tiers`: exit 0, `quality-tiers: OK (24 entries, 24 discovered projects)`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0.
- CI run 36980560291 (`_quality-checks.yml`, `workflow_dispatch`, head `bd731f4e`): conclusion `success` on all four Python legs; step `tier-classification` `success` in each leg. Recorded in `evidence/qa-gates/ci-run-quality-checks.2026-10-02T03-55.md`.

The full Pytest suite with coverage was not re-run by the reviewer; coverage was verified from the existing artifacts listed above, and the full suite passed in the CI run on every leg.

**Policy documents evaluated:**
- ✅ `CLAUDE.md`
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- ⚠️ `.claude/rules/python.md` (PA-1, non-blocking) and ✅ `.claude/rules/python-suppressions.md`
- ✅ `.github/instructions/github-actions.instructions.md` and `.claude/rules/ci-workflows.md`
- N/A TypeScript, PowerShell, C#, Bash (zero changed files on the branch diff)

**Operator decisions applied (2026-09-30):** the citation edit to `.claude/rules/quality-tiers.md` and its three mirrors is approved as written in the spec, and the recorded T3/T4 classification is accepted. Neither is raised as a policy finding.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts were committed.
- ✅ The two new scripts are permanent tooling referenced by the workflow.
- Reviewer probe files (a Black formatting probe and a coverage parser) were written to the session scratchpad only.

---

## Rejected Scope Narrowing

None detected. The caller prompt directed a full review of the branch against `origin/main`. The caller instruction to evaluate AC-10 and the CI half of AC-16 as UNVERIFIED-awaiting-CI is not a scope narrowing; it became moot because CI run 36980560291 completed with `success` before this audit was written, and both criteria were evaluated on that evidence.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exit 0.
- Branch diff scan: `git diff --name-only origin/main...HEAD -- artifacts` returns no files. No file in the branch diff sits under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Reviewer evidence written to the canonical path: `evidence/qa-gates/ci-run-quality-checks.2026-10-02T03-55.md`.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Every test builds its inputs locally (in-memory YAML strings, `QualityTierManifest` values, tracked-path lists, injected fakes). No module-level mutable state is written. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One QT code or one discovery boundary per test; parametrized matrices for QT003 (10 cases), QT006 (6 cases), QT004 (2 cases), excluded roots (4 cases). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 92 tests (new plus parity/frontmatter) in 0.47 s in the reviewer run. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, network, process, or sleep. Discovery output is a `frozenset`; error lists are produced in sorted order where order is asserted. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange/Act/Assert comments, one-sentence docstrings stating scenario and outcome, assertion messages on most assertions. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 93.53% lines, 86.76% branches (`artifacts/python/coverage-baseline.json`; `evidence/baseline/coverage-totals.2026-10-02T03-18.md`). |
| **No Coverage Regression** | ✅ PASS | **Post-change:** 93.61% lines, 86.89% branches. **Change:** +0.08% lines, +0.13% branches. No existing production file was modified. |
| **New Code Coverage** | ✅ PASS | `quality_tiers_contract.py`: LF 191 / LH 188 (98.43%), BRF 78 / BRH 75 (96.15%). `check_quality_tiers.py`: LF 64 / LH 64 (100.00%), BRF 12 / BRH 11 (91.67%). Both exceed 85% line and 75% branch. |
| **Comprehensive Coverage** | ✅ PASS | Every QT code QT001-QT009 has at least one named test; every discovery boundary in spec "Test Strategy" has a named test. Uncovered lines 124, 155, 199 are noted as CR-2 (non-blocking). |
| **Positive Flows** | ✅ PASS | `test_parse_quality_tiers_accepts_valid_manifest`, `test_main_returns_zero_and_prints_summary_for_valid_manifest`, `test_find_classification_errors_valid_manifest_returns_no_errors`. |
| **Negative Flows** | ✅ PASS | QT001-QT009 tests, including three QT009 variants (lister `OSError`, git non-zero, git not found). |
| **Edge Cases** | ✅ PASS | Root path `.`, lowercase tier `t3`, `./` segment, empty tracked list, nested PoshQC inside `scripts/powershell`, settings `.psd1` without sibling. |
| **Error Handling** | ✅ PASS | Fail-closed QT009 verified; stderr `QTnnn:` prefix and empty stdout asserted by `_assert_failure_output`. |
| **Concurrency** | N/A | No concurrent behavior. |
| **State Transitions** | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.53% lines, 86.76% branches -> Post-change: 93.61% lines, 86.89% branches. Change: +0.08% lines, +0.13% branches. New/changed-code coverage: `scripts/dev_tools/quality_tiers_contract.py` 98.43% lines / 96.15% branches; `scripts/dev_tools/check_quality_tiers.py` 100.00% lines / 91.67% branches. Repo-wide gate `check_python_coverage_thresholds --min-line 85 --min-branch 75` passed (`evidence/qa-gates/final-coverage-gate.2026-10-02T03-41.md`) and passed again in CI run 36980560291 on all four legs. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `artifacts/python/coverage.json`, `evidence/qa-gates/coverage-delta.2026-10-02T03-41.md`.

TypeScript, PowerShell, and C# have zero changed files on the branch, so no coverage verdict is required for them.

### 1.2.2 Coverage Exclusion Policy

- `pyproject.toml` is not in the branch diff; `[tool.coverage.run] omit` and `[tool.coverage.report] exclude_lines` are unchanged. `scripts/dev_tools` is within `source`, so both new production modules are in the coverage denominator.
- No `# pragma: no cover` was added in the new modules (reviewer read of both files).
- Verdict: PASS.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | e.g. `f"stderr line lacks a QT prefix: {line!r}"`, `f"entries without a folder: {missing}"`, `f"{path}: expected {tier}"`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | All tests carry `# Arrange` (where applicable), `# Act`, `# Assert` sections. |
| **Document Intent** | ✅ PASS | Every test has a docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | `git grep -nE "tmp_path\|tmpdir\|tempfile\|subprocess\|NamedTemporary\|mkdtemp"` over both new test files: exit 1 (no match). The git runner and `which` resolver are injected fakes (`FakeRunResult`); `test_main_returns_one_with_qt009_when_git_not_found` fails the test if the runner is called. |
| **Use Mocks/Stubs** | ✅ PASS | Injected callables only; no `monkeypatch` of production modules. |
| **Environment Stability** | ✅ PASS | `test_default_manifest_reader_reads_file_text` uses the repository `mem_fs_path` fixture (`tests/conftest.py` line 146), which patches `pathlib.Path` methods onto an in-memory store; no disk write. The two committed-tree tests read `quality-tiers.yml` and call `is_dir()` read-only, as the spec explicitly authorizes. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (`- Work Mode: full-bug`), `spec.md` (17 acceptance criteria). |
| **Read existing change plans** | ✅ PASS | `plan.2026-09-29T21-45.md`; four preflight rounds recorded under `evidence/other/`. |
| **Document the plan** | ✅ PASS | Plan with Execution Deviations D1-D5. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One pure module, one CLI module; per-path discovery function with five rule clauses. |
| **Reusability** | ✅ PASS | `_path_form_problem` reused by QT006 and the QT007 malformed-path filter; `find_entry_errors` reused by the QT009 path in the CLI. |
| **Extensibility** | ✅ PASS | Discovery roots in one frozen `DISCOVERY_RULES` constant; CLI collaborators injected as keyword-only parameters with defaults. |
| **Separation of concerns** | ✅ PASS | Core has no I/O imports (`git grep` for `os`, `subprocess`, `shutil`, `pathlib`, `sys`, `open(`, `print(`, `read_text`, `write_text` in the core: exit 1). File and process I/O live only in the CLI. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Core = parse/discover/compare; CLI = read/list/report. |
| **Under 500 lines** | ✅ PASS | 391, 193, 495, 388 lines (`wc -l`). `test_quality_tiers_contract.py` has 5 lines of headroom (CR-3). |
| **Public vs internal** | ✅ PASS | Helpers are `_`-prefixed. |
| **No circular dependencies** | ✅ PASS | CLI imports core; core imports only `yaml` and the standard library. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Function and constant names follow spec-normative names. |
| **Docs/docstrings** | ✅ PASS | Module docstrings list failure codes and discovery rules; public functions document args, returns, and raises. |
| **Comment why, not what** | ✅ PASS | e.g. the `Any` justification on `construct_mapping` (matches PyYAML stub signature). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check <4 files>`<br>**Result:** exit 0, 4 files unchanged. Executor full-tree run: `evidence/qa-gates/final-black.2026-10-02T03-41.md`. CI Black step success on all legs. |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check <4 files>`<br>**Result:** exit 0. CI Ruff step success. |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <4 files>`<br>**Result:** 0 errors (strict mode). CI Pyright step success. |
| **4. Architecture boundaries** | N/A | No Python architecture-boundary tool is configured (`evidence/qa-gates/final-architecture-stage.2026-10-02T03-41.md`, expected exit 1 on search). |
| **5. Testing** | ✅ PASS | Reviewer targeted run 92 passed. Executor full suite 6393 passed, 6 skipped (`final-pytest-full.2026-10-02T03-41.md`). CI Pytest step success on all four legs. |
| **6. Contract / schema** | ✅ PASS | Two bundled-payload parity tests and `test_claude_rules_frontmatter.py` passed in the reviewer run. |
| **7. Integration** | ✅ PASS | `poetry run python -m scripts.dev_tools.check_quality_tiers` exit 0 (reviewer); `tier-classification` step success in CI. |
| **Full toolchain loop** | ✅ PASS | `evidence/qa-gates/final-qa-loop-summary.2026-10-02T03-41.md` (pass 2 after the D5 restart). |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded in `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Conventional commit messages per phase. |
| **Design choices explained** | ✅ PASS | Spec "Proposed Fix" and plan deviations D1-D5. |
| **Update supporting documents** | ✅ PASS | AC check-offs in `spec.md`; follow-ups in `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`. |
| **Provide next steps** | ✅ PASS | Follow-ups FU-734-1 through FU-734-4. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PEP 8 naming** | ✅ PASS | `snake_case` functions, `PascalCase` dataclasses, `CONSTANT_CASE` module constants. |
| **Strong typing (production)** | ✅ PASS | All public and private production functions are fully annotated. One `Any` in `_UniqueKeySafeLoader.construct_mapping` return type, commented as required by the PyYAML stub override. |
| **Strong typing (tests)** | ⚠️ PARTIAL (non-blocking, PA-1) | `tests/scripts/dev_tools/test_quality_tiers_contract.py` line 434: `def test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry():` has no `-> None`. See PA-1 below. |
| **Dataclasses** | ✅ PASS | `QualityTierEntry`, `QualityTierManifest`, `QualityTierError`, `DiscoveryRules` are `frozen=True`. |
| **Protocols** | ✅ PASS | `GitRunResult` Protocol types the injected runner result. |
| **Error handling** | ✅ PASS | Only `yaml.YAMLError` in the core and `OSError` at the CLI boundary are caught, as the spec prescribes. `FileNotFoundError` from a missing git is an `OSError` subclass and maps to QT009. |
| **Suppressions** | ✅ PASS | One suppression: `# noqa: S603 - static analysis can't verify runtime validation` at `check_quality_tiers.py` line 90, the exact pre-authorized form in `.claude/rules/python-suppressions.md` line 29. Git is resolved with `shutil.which`, so S607 is not triggered and not suppressed. |
| **Logging vs print** | ✅ PASS | `print` is used for the CLI output contract (stderr QT lines, stdout summary) that the spec mandates; this is the CLI boundary, consistent with other `scripts/dev_tools` CLIs. |
| **Python 3.10 compatibility** | ✅ PASS | Reviewer scan for `tomllib`, `typing.Self`, `ExceptionGroup`, `except*`, `StrEnum`, `datetime.UTC`, `TaskGroup`, `typing.Never`, `LiteralString`, `assert_never`, `NotRequired`: no match. CI 3.10 leg ran Black, Ruff, Pyright, `tier-classification`, Pytest, and the coverage gate with `success`. |
| **No new dependencies** | ✅ PASS | PyYAML already present; `pyproject.toml` and `poetry.lock` not in the diff. |

**PA-1 (non-blocking PARTIAL): missing return annotation on one test function (plan deviation D3).**
- File/location: `tests/scripts/dev_tools/test_quality_tiers_contract.py` line 434.
- Rule: `.claude/rules/python.md` Toolchain item 3 ("All Python code must be fully type-annotated") and Coding Standards ("All public functions and methods must have full type hints for parameters and return values").
- D3 states the plan-mandated name "cannot fit 88 columns with the annotation". The reviewer verified that Black 26.1.0 formats the annotated form as `def <name>() -> (\n    None\n):`, whose first line is 92 characters and would fail Ruff E501. However, a compliant alternative exists: the name is mandated only by the plan, not by `spec.md` (the spec names only `test_main_returns_one_with_qt008_when_entry_removed` and `test_committed_quality_tiers_yml_matches_live_tree`). A shorter name such as `test_find_classification_errors_empty_projects_yield_qt007_per_entry` fits with `-> None`.
- Why non-blocking: Pyright strict passes (the return type is inferred as `None`); the Ruff `ANN` rule family is not selected in `pyproject.toml`; and the repository has established precedent for unannotated test functions (for example `tests/scripts/dev_tools/test_collect_pr_context.py` lines 137-174 and `test_atomic_executor_cli.py` lines 191, 225, 265). The deviation is disclosed in the plan.
- Recommended action: rename the test and add `-> None` when the file is next edited (it would be combined naturally with CR-2/CR-3 in the code review).

### Section 3B: GitHub Actions Workflow Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **actionlint** | ✅ PASS | `evidence/qa-gates/final-actionlint.2026-10-02T03-41.md` exit 0 (actionlint 1.7.11). Not re-run by the reviewer (worktree guard denies the `pwsh` wrapper); the workflow parsed and ran in CI run 36980560291. |
| **Job structure / triggers unchanged** | ✅ PASS | Diff is one 5-line step insertion at lines 74-77 between "Verify Codex agent deployment profiles" and "Run tests with Pytest". No job, trigger, matrix, or permission change. |
| **Step contract** | ✅ PASS | `name: tier-classification`, `run: poetry run python -m scripts.dev_tools.check_quality_tiers`, `continue-on-error: false`. |
| **ci-workflows.md exit-code rule** | ✅ PASS | Single command whose expected exit is 0; no expected-nonzero handling needed. |
| **modified-workflow-needs-green-run** | ✅ PASS | Run 36980560291 (`workflow_dispatch`, head `bd731f4e`) concluded `success` on all four legs; `tier-classification` `success` in each. |
| **Shallow checkout** | ✅ PASS | `actions/checkout@v7` default depth; `git ls-files` succeeded in CI (step success with no QT009). |

### Section 3C: Policy-document edits

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Operator-approved scope** | ✅ PASS | Each of the four files changes exactly one line, replacing the old substring with the spec's exact new text (`git diff origin/main...HEAD` per file). Approved by the operator 2026-09-30. |
| **Byte identity of mirrors** | ✅ PASS | `.claude/rules/quality-tiers.md` and its bundled copy share blob `ab45b338` (from `28209fc8`); `.agents/skills/quality-tiers/SKILL.md` and its bundled copy share blob `f988f2f4` (from `f6fdc20b`). Parity tests pass. |
| **Frontmatter unchanged** | ✅ PASS | Edit is at line 9 / line 12, below frontmatter; `test_claude_rules_frontmatter.py` passes. |
| **No `.github/instructions/*` edit** | ✅ PASS | Only `.github/workflows/_quality-checks.yml` under `.github/` is in the diff. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | ✅ PASS | Plain pytest functions with `parametrize`. |
| **Test location mirrors source** | ✅ PASS | `scripts/dev_tools/<m>.py` -> `tests/scripts/dev_tools/test_<m>.py`. |
| **One behavior per test** | ✅ PASS | See 1.1. |
| **Patch at use site / mock sparingly** | ✅ PASS | Dependency injection instead of patching. |
| **No sleeps, temp files, processes, network** | ✅ PASS | See 1.4. |
| **Coverage thresholds** | ✅ PASS | See 1.2.1. |

---

## 5. Test Coverage Detail

### `quality_tiers_contract.py` (47 collected cases across 28 test functions)

| Area | Tests | Status |
|------|-------|--------|
| Parse positive | `accepts_valid_manifest`, `accepts_root_path_entry` | ✅ |
| QT002 | invalid YAML, duplicate top-level key, non-mapping root | ✅ |
| QT003 | 10-case matrix plus `keeps_valid_entries_alongside_qt003` | ✅ |
| QT004 | `T5`, `t3` | ✅ |
| QT005 | duplicate path | ✅ |
| QT006 | absolute, drive letter, backslash, trailing slash, `..`, `./` | ✅ |
| QT007 / QT008 / accumulation / empty set | four tests | ✅ |
| Discovery R1-R5 and exclusions | 10 test functions (14 cases) | ✅ |
| Committed tree | `matches_live_tree`, `assigns_spec_tiers` | ✅ |

**Coverage:** 98.43% lines, 96.15% branches. Uncovered: line 124 (non-scalar mapping key), line 155 (non-integer `version`), line 199 (missing `projects` key).

### `check_quality_tiers.py` (14 tests)

QT001, QT002 (lister not called), QT009 x3, entry errors with QT009, QT008 removed entry, QT004+QT008 accumulation, argparse exit 2, relative `--file` resolution, `git ls-files -z` argv/cwd, NUL splitting, default reader via `mem_fs_path`, and the success summary line. **Coverage:** 100% lines, 91.67% branches.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full suite, executor) | 6393 passed, 6 skipped | ✅ |
| Tests Failed | 0 | ✅ |
| New tests | 61 collected cases (47 core, 14 CLI; `final-test-inventory.2026-10-02T03-41.md` and reviewer `--collect-only`) | ✅ |
| Reviewer targeted run | 92 passed in 0.47 s | ✅ |
| Repo-wide coverage | 93.61% lines, 86.89% branches | ✅ |
| CI run 36980560291 | success, 4/4 legs | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check <4 files>` | exit 0 | ✅ |
| Ruff | `poetry run ruff check <4 files>` | exit 0 | ✅ |
| Pyright | `poetry run pyright <4 files>` | 0 errors | ✅ |
| Pytest | `poetry run pytest -q -p no:cacheprovider <5 files>` | 92 passed | ✅ |
| Integration | `poetry run python -m scripts.dev_tools.check_quality_tiers` | exit 0 | ✅ |
| CI | `gh run view 36980560291 --json jobs` | success | ✅ |
| Evidence locations | `validate_evidence_locations.py --root .` | exit 0 | ✅ |

---

## 8. Gaps and Exceptions

### Identified Gaps

- PA-1 (non-blocking): missing `-> None` on one test function; compliant rename available.
- Base drift (informational): `origin/main` has advanced to `71f8dcb4` (PR #817) since the merge base. `git merge-tree --write-tree origin/main HEAD` exits 0 (no conflict), and no file added on main since the merge base matches a discovery rule, so `tier-classification` is expected to remain green after the branch is updated. Update the branch from main before opening the PR.

### Approved Exceptions

- Citation edit in four policy/skill files: operator-approved 2026-09-30.
- T3/T4 tier classification: operator-accepted 2026-09-30.

### Removed/Skipped Tests

**None.**

---

## 9. Summary of Changes

1. `quality-tiers.yml` — 24 entries (T3 x 18, T4 x 6), `version: 1` list schema.
2. `scripts/dev_tools/quality_tiers_contract.py` — pure parse/discover/compare core (QT002-QT008).
3. `scripts/dev_tools/check_quality_tiers.py` — CLI (QT001, QT009, exit 0/1/2).
4. Two new test files (61 collected cases).
5. `.github/workflows/_quality-checks.yml` — `tier-classification` step.
6. Citation correction in four policy/skill files.
7. Follow-ups recorded in `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT (one non-blocking PARTIAL)

### Metrics Summary

- ✅ 6393/6393 non-skipped tests passing; 92/92 in the reviewer run
- ✅ 93.61% line coverage, 86.89% branch coverage (no regression)
- ✅ New modules at 98.43%/96.15% and 100.00%/91.67%
- ✅ CI run 36980560291 green at head on all four Python legs

### Blocking findings: 0

### Recommendation

**Ready for merge** after the branch is updated from `origin/main` and CI re-runs green on the updated head.

---

## Appendix A: Test Inventory

### New tests: `tests/scripts/dev_tools/test_quality_tiers_contract.py` (28 functions, 47 collected cases)

1. test_parse_quality_tiers_accepts_valid_manifest
2. test_parse_quality_tiers_accepts_root_path_entry
3. test_parse_quality_tiers_rejects_invalid_yaml_with_qt002
4. test_parse_quality_tiers_rejects_duplicate_top_level_key_with_qt002
5. test_parse_quality_tiers_rejects_non_mapping_root_with_qt002
6. test_parse_quality_tiers_rejects_schema_violation_with_qt003 (10 cases)
7. test_parse_quality_tiers_keeps_valid_entries_alongside_qt003
8. test_quality_tier_error_renders_code_prefix
9. test_discover_projects_root_package_json_yields_root
10. test_discover_projects_csproj_directory_is_project
11. test_discover_projects_psd1_with_sibling_psm1_is_project
12. test_discover_projects_ignores_settings_psd1_without_sibling_psm1
13. test_discover_projects_ignores_excluded_roots (4 cases)
14. test_discover_projects_ignores_scripts_child_without_direct_code_file
15. test_discover_projects_discovers_nested_poshqc_and_scripts_powershell
16. test_discover_projects_discovers_claude_lib_child
17. test_discover_projects_discovers_hook_roots_only_with_tracked_file (2 cases)
18. test_discover_projects_empty_list_yields_empty_set
19. test_find_classification_errors_valid_manifest_returns_no_errors
20. test_find_entry_errors_reports_qt004_for_invalid_tier (2 cases)
21. test_find_entry_errors_reports_qt005_for_duplicate_path
22. test_find_entry_errors_reports_qt006_for_malformed_path (6 cases)
23. test_find_classification_errors_reports_qt007_for_undiscovered_entry
24. test_find_classification_errors_reports_qt008_for_unclassified_project
25. test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry
26. test_find_classification_errors_accumulates_qt004_and_qt008
27. test_committed_quality_tiers_yml_matches_live_tree
28. test_committed_quality_tiers_yml_assigns_spec_tiers

### New tests: `tests/scripts/dev_tools/test_check_quality_tiers.py` (14 tests)

1. test_main_returns_zero_and_prints_summary_for_valid_manifest
2. test_main_returns_one_with_qt001_when_manifest_missing
3. test_main_returns_one_with_qt002_and_skips_git_for_invalid_yaml
4. test_main_returns_one_with_qt009_when_runner_raises_oserror
5. test_main_returns_one_with_qt009_when_git_exits_nonzero
6. test_main_returns_one_with_qt009_when_git_not_found
7. test_main_reports_entry_errors_alongside_qt009
8. test_main_returns_one_with_qt008_when_entry_removed
9. test_main_reports_qt004_and_qt008_in_one_run
10. test_main_raises_system_exit_two_for_unknown_argument
11. test_main_resolves_relative_file_against_repo_root
12. test_list_tracked_files_invokes_git_ls_files_z
13. test_list_tracked_files_splits_nul_separated_output
14. test_default_manifest_reader_reads_file_text

### Modified or removed tests

None. No pre-existing test file is in the branch diff.

---

## Appendix B: Toolchain Commands Reference

```bash
git -C <worktree> merge-base origin/main HEAD          # b080a69ecb60b65d016362b21fffed0a34be9144
git -C <worktree> diff --stat origin/main...HEAD
poetry run black --check scripts/dev_tools/quality_tiers_contract.py scripts/dev_tools/check_quality_tiers.py tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py
poetry run ruff check <same 4 files>
poetry run pyright <same 4 files>
poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py
poetry run python -m scripts.dev_tools.check_quality_tiers
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run black --diff --target-version py310 <scratchpad probe>   # D3 alternative check
gh api repos/drmoisan/drm-copilot/actions/runs/36980560291 --jq '{path,head_sha,conclusion,event}'
gh run view 36980560291 --repo drmoisan/drm-copilot --json jobs
git -C <worktree> merge-tree --write-tree origin/main HEAD
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-02
**Policy Version:** Current (as of audit date)
