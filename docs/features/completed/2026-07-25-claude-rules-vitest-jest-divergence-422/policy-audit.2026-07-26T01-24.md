# Policy Compliance Audit: Claude/Codex Rule Mirror Vitest→Jest Correction (Issue #422)

**Audit Date:** 2026-07-26
**Code Under Test:**
- `.claude/rules/typescript.md` (Markdown, modified)
- `.claude/rules/general-unit-test.md` (Markdown, modified)
- `.claude/rules/general-code-change.md` (Markdown, modified)
- `.claude/agents/atomic-executor.md` (Markdown, modified)
- `.agents/skills/general-unit-test/SKILL.md` (Markdown, modified)
- `.agents/skills/general-code-change/SKILL.md` (Markdown, modified)
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md` (Markdown, modified)
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md` (Markdown, modified)
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md` (Markdown, modified)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` (Markdown, modified)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md` (Markdown, modified)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md` (Markdown, modified)
- `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` (Python, new test module, 184 lines)
- Feature-folder documentation and evidence under `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/` (Markdown, new)

**Baseline:** `origin/main` @ `fb483b8468204e4385b5583c3b3ec4c0a987eede` (merge base). Head: `bug/claude-rules-typescript-vitest-jest-divergence` @ `042ed066b1350100513bc0a7e09c141b2f3ead12`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 file (new test module) | 2138 tests | ✅ 2138 pass, 0 fail (reviewer re-run 2026-07-26) | 91.00% lines, 81.84% branches | 91.00% lines, 81.84% branches | N/A — no production code added; the only new Python file is test code, excluded from the coverage denominator per `.claude/rules/general-unit-test.md` |
| Markdown | 36 files | N/A (locked by new pytest module + parity tests) | ✅ 28 targeted contract/parity tests pass | N/A (no coverage) | N/A (no coverage) | N/A |

TypeScript, PowerShell, and C# have zero changed files in the branch diff (`git diff --name-only fb483b84..HEAD` contains no `.ts`, `.ps1`, or `.cs` file). `N/A` is therefore an acceptable coverage verdict for those languages per the feature-review-workflow contract. Python coverage verdict: **PASS**.

### Coverage Evidence Checklist

- Python baseline coverage artifact: `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-python-pytest-coverage.2026-07-26T00-50.md`
- Python post-change coverage artifact: `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/final-python-pytest-coverage.2026-07-26T01-08.md` plus the LCOV artifact `artifacts/python/lcov.info` (independently parsed by the reviewer: 11175/12280 lines = 91.00%, 3642/4450 branches = 81.84%, 143 source files)
- Per-language comparison summary: `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/coverage-delta.2026-07-26T01-08.md` (zero delta; denominators byte-identical)
- TypeScript baseline coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `N/A - out of scope` (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: `N/A - out of scope` (zero PowerShell files changed on the branch)
- C# baseline coverage artifact: `N/A - out of scope` (zero C# files changed on the branch)
- C# post-change coverage artifact: `N/A - out of scope` (zero C# files changed on the branch)

**Non-negotiable verdict rule:** satisfied — numeric baseline and post-change coverage are recorded for the only language with changed executable files (Python), and the new-code population is empty with a recorded rationale.

---

## Rejected Scope Narrowing

None detected. The orchestrator prompt explicitly stated "The orchestrator supplies no scope narrowing" and enumerated verification points as "areas to verify, not a scope limit." The audit scope used is the full branch diff `fb483b84..042ed066` against `origin/main`.

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT_CODE 0, no violations reported.
- Branch-diff scan: no changed file lives under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 26 evidence artifacts live under the canonical `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/<kind>/` tree (`baseline/`, `regression-testing/`, `qa-gates/`, `other/`).
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no caller instruction supplied a non-canonical evidence path.

**Verdict: PASS.**

---

## Executive Summary

This branch corrects a Vitest/Jest divergence between the canonical `.github/instructions/` policy source (which mandates Jest) and twelve mirror files (six repo-root instruction mirrors plus their six bundled extension copies), and adds one pytest regression module that locks the corrected state. No production code changed. The Python toolchain (Black, Ruff, Pyright, Pytest) passes cleanly on the reviewer's independent re-run. All six mirror pairs are byte-identical by SHA-256. The fix direction is canon-to-mirror, as `CLAUDE.md` requires; no canonical policy file was modified.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (cross-language code change policy)
- ✅ `.claude/rules/general-unit-test.md` (cross-language unit test policy)
- ✅ `.claude/rules/python.md` semantics via toolchain execution (Python file changed)
- ✅ `.claude/rules/typescript.md` (content under review; the corrected text was checked against root `package.json` and `.github/instructions/typescript-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md` (uniform coverage thresholds applied)
- ✅ `.claude/rules/tonality.md` (artifact tone)

**Language-specific policies evaluated:**
- ✅ Python: `python-code-change` / `python-unit-test` policy semantics — the new test module was audited and the toolchain executed
- N/A PowerShell, C#, Bash, JSON — no files of these types changed
- N/A GitHub Actions — no workflow files changed (`modified-workflow-needs-green-run` does not fire: no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` is in the diff)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts appear in the branch diff. Working tree is clean at HEAD.

---

## 1. General Unit Test Policy Compliance

Scope: the single new test module `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` (15 test cases).

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each test performs its own file read via `read_repo_text()`; no shared mutable state, no module-level caches, no fixtures with state. Parametrized cases are independent per file. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Five distinct test functions: framework-name absence, `vi.*` API absence, `npm run` command resolution, Testing-line semantic anchor, coverage-line semantic anchor. One property per function. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | `15 passed in 0.05s` (pass-after evidence); reviewer run of the 28-test contract/parity selection completed in 0.19s. |
| **Determinism** - Consistent results | ✅ PASS | Pure text reads of checked-in files plus `json.loads` of checked-in `package.json`. No time, randomness, network, or environment dependence. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names (`test_mirror_does_not_name_the_vitest_framework`), module docstring citing issue #422, explicit Arrange/Act/Assert comments, helper functions with docstrings. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Baseline: 91.00% lines, 81.84% branches. Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Artifact: `evidence/baseline/baseline-python-pytest-coverage.2026-07-26T00-50.md` (timestamp 2026-07-26T00-50, pre-change). |
| **No Coverage Regression** | ✅ PASS | Post-change: 91.00% lines, 81.84% branches. Delta: 0.00 pp on identical numerators/denominators (11175/12280 lines, 3642/4450 branches). Reviewer independently parsed `artifacts/python/lcov.info` and reproduced both figures exactly. |
| **New Code Coverage** | N/A | Zero new or changed production lines. The only new Python file is test code, outside the coverage denominator per `pyproject.toml` (`source = ["src", "scripts/dev_tools"]`, `omit` of `tests/*`) and per the policy sentence permitting test-file exclusion. Recorded rationale, not a placeholder. |
| **Comprehensive Coverage** | ✅ PASS | The regression module covers all three spec-mandated properties (token absence, command resolution, semantic anchors) across all six mirrors; bundled copies are covered transitively by the two parity tests, as the spec design states. |
| **Positive Flows** | ✅ PASS | Pass-after run: all 15 cases pass against the corrected tree (`evidence/regression-testing/pass-after.2026-07-26T00-58.md`; reviewer re-run confirms). |
| **Negative Flows** | ✅ PASS | Fail-before run against the pre-fix tree: `12 failed, 3 passed`, EXIT_CODE 1, with failures at exactly the lines named in `spec.md` (`evidence/regression-testing/fail-before.2026-07-26T00-58.md`). Reviewer corroborated the pre-fix defect content at the merge base via `git show fb483b84:.claude/rules/typescript.md` (Vitest at lines 16, 42, 51, 73; `npm run test` and `npm run test:coverage` present). |
| **Edge Cases** | ✅ PASS | The `\bvi\.[a-zA-Z]` regex avoids false positives on legitimate text; `find_unique_line` asserts exactly one marker line, failing loudly on structural drift; `NPM_RUN_PATTERN` tolerates any backtick-wrapped `npm run <name>` token position. |
| **Error Handling** | ✅ PASS | `read_root_package_script_names` asserts JSON object shape and `scripts` presence with actionable messages; assertion messages name the offending file, lines, and unresolved script names. |
| **Concurrency** | N/A | Pure read-only file assertions; no concurrent behavior exists to test. |
| **State Transitions** | N/A | No stateful component under test. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 91.00% lines / 81.84% branches -> Post-change: 91.00% lines / 81.84% branches. Change: 0.00 pp. New/changed-code coverage: N/A (no production code changed; rationale recorded). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta.2026-07-26T01-08.md`, `artifacts/python/lcov.info` (reviewer-parsed).
- TypeScript: `N/A - zero changed files on the branch`.
- PowerShell: `N/A - zero changed files on the branch`.
- C#: `N/A - zero changed files on the branch`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Every assertion carries a message naming the file, the policy rationale, and the offending content (e.g., "names npm scripts that do not exist in root package.json: {unresolved}"). The fail-before artifact demonstrates the diagnostics in practice. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | All five test functions carry explicit `# Arrange` / `# Act` / `# Assert` section comments. |
| **Document Intent** | ✅ PASS | Module docstring explains the defect history and the transitive-parity design decision; each test has a one-line docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, database, subprocess, or external service. Reads only checked-in repository files, following the structural precedent `tests/scripts/dev_tools/test_codex_orchestration_contracts.py`. |
| **Use Mocks/Stubs** | N/A | Nothing to mock; the subject under test is checked-in file content. |
| **Environment Stability** | ✅ PASS | No temporary files created (grep of the module: no `tempfile`, no writes; the module docstring and spec state "It writes nothing"). `REPO_ROOT` is derived from `__file__`, not from CWD or environment variables. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit document is the required policy review for the branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #422; `issue.md` (Work Mode: full-bug) and `spec.md` define the objective and the adjudicated scope. |
| **Read existing change plans** | ✅ PASS | Research artifact `research/2026-07-25T22-15-claude-rules-vitest-jest-divergence-research.md` adjudicated every occurrence; plan `plan.2026-07-25T21-44.md` sequenced the work. |
| **Document the plan** | ✅ PASS | `plan.2026-07-25T21-44.md` — all 6 phases and every task checked off; Phase 0 policy reads recorded in `evidence/baseline/phase0-instructions-read.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Minimal textual corrections; no indirection or tooling added beyond one flat pytest module. |
| **Reusability** | ✅ PASS | The test module reuses the established live-tree contract-test pattern; parity coverage of bundles is delegated to the two existing parity tests instead of duplicating assertions. |
| **Extensibility** | ✅ PASS | `MIRROR_RELATIVE_PATHS` tuple and parametrization allow new mirrors to be added with one line. |
| **Separation of concerns** | ✅ PASS | Pure text assertions; no I/O beyond reads; no mixing of concerns. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One module, one concern: TypeScript toolchain instruction contracts. |
| **Under 500 lines** | ✅ PASS | `wc -l` = 184 lines. All modified Markdown files are also under limit or are documentation files (exempt). |
| **Public vs internal** | ✅ PASS | Test module exposes no public API. |
| **No circular dependencies** | ✅ PASS | Imports stdlib + pytest only. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `test_typescript_rule_testing_line_names_the_unit_test_command`, `read_root_package_script_names`, `VITEST_API_PATTERN` — all self-describing, snake_case/UPPER_CASE per Python convention. |
| **Docs/docstrings** | ✅ PASS | Module and function docstrings present throughout. |
| **Comment why, not what** | ✅ PASS | Comments explain rationale (e.g., why `npm run test` needs a semantic anchor despite resolving). |

### 2.5 After Making Changes - Toolchain Execution

Reviewer-executed check-only commands (independent of executor evidence):

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check .` — "All done!", 333 files unchanged, EXIT_CODE 0. |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check .` — "All checks passed!", EXIT_CODE 0. |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` — 0 errors, 0 warnings, 0 informations. |
| **4. Testing** | ✅ PASS | **Command:** `poetry run pytest -q` — `2138 passed in 3.52s` (matches executor-reported count exactly). Targeted selection (new module + both parity modules): 28 passed. |
| **Full toolchain loop** | ✅ PASS | Executor Phase 5 loop completed in a single clean pass (`evidence/qa-gates/final-*` artifacts); reviewer re-run reproduced all results with no file changes. |
| **Explicit reporting** | ✅ PASS | Commands recorded here and in the executor's `evidence/qa-gates/` artifacts. |

Stages 4 (architecture-boundary), 6 (contract/schema), 7 (integration) of the seven-stage loop: no production code or schema changed; the push-down resource contract tests (the integration surface named in the spec's Test Strategy) pass. No architecture-boundary tooling exists for Markdown; the noted absence of `.dependency-cruiser.cjs` is a pre-existing, recorded adjacent finding outside this feature's scope.

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `042ed066` "fix(422): align Claude and Codex rule mirrors with the Jest runner"; spec Design summary table. |
| **Design choices explained** | ✅ PASS | Transitive-parity decision, semantic-anchor rationale, and `npx jest` flag-name caveat all documented in spec and test docstrings. |
| **Update supporting documents** | ✅ PASS | Feature folder complete (issue, spec, plan, research, 26 evidence artifacts). Note: `README.md` retains Vitest wording at lines 303/318 — recorded by the spec as an out-of-owned-set follow-up, not a defect of this change. |
| **Provide next steps** | ✅ PASS | Spec `## Rollout & Follow-up` lists the separate `.dependency-cruiser.cjs` filing and the README follow-up. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | `poetry run black --check .` — clean (reviewer run) and `evidence/qa-gates/final-python-black.2026-07-26T01-08.md`. |
| **Linting with Ruff** | ✅ PASS | `poetry run ruff check .` — clean (reviewer run) and `evidence/qa-gates/final-python-ruff.2026-07-26T01-08.md`. |
| **Type checking with Pyright** | ✅ PASS | `poetry run pyright` — 0/0/0 (reviewer run) and `evidence/qa-gates/final-python-pyright.2026-07-26T01-08.md`. |
| **Testing with Pytest** | ✅ PASS | `poetry run pytest -q` — 2138 passed (reviewer run) and `evidence/qa-gates/final-python-pytest-coverage.2026-07-26T01-08.md`. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations including `re.Pattern[str]`, `frozenset[str]`; JSON narrowed via `isinstance` assertions plus explicit `cast` with an explanatory comment; no `Any`. |
| **Dataclasses for value objects** | N/A | No value objects introduced. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces introduced. |
| **Avoid utility classes** | ✅ PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | Shape violations fail via assertions with specific messages (appropriate in test code); no broad catches. |
| **Logging over print** | ✅ PASS | No `print` statements. |
| **Invariants at construction** | N/A | No classes constructed. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain pytest with `@pytest.mark.parametrize`; no plugins beyond repo defaults. |
| **Coverage expectation** | ✅ PASS | Repo-wide 91.00% lines / 81.84% branches against uniform floors 85% / 75%. New-code population empty (test-only addition). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One property per test function; parametrization isolates per-file failures. |
| **Mocking sparingly** | ✅ PASS | No mocks; direct assertions over checked-in content. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` placement matches the structural precedent `test_codex_orchestration_contracts.py` for repo-contract tests and the `tests/` tree-location rule; not colocated with production source. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | Behavior-describing snake_case names throughout. |
| **Docstrings/comments** | ✅ PASS | Docstrings on module, helpers, and every test. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `poetry run pytest` — see Section 2.5. |
| **No Alternative Test Runners** | ✅ PASS | Only pytest used for Python. |

---

## 5. Test Coverage Detail

### test_typescript_toolchain_instruction_contracts.py (15 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_mirror_does_not_name_the_vitest_framework[6 params]` | Negative (forbidden token) | Six mirror files, full text | ✅ |
| `test_mirror_does_not_reference_the_vitest_api[6 params]` | Negative (forbidden API token) | Six mirror files, full text | ✅ |
| `test_typescript_rule_npm_commands_resolve_to_root_package_scripts` | Positive + Negative (resolution) | `.claude/rules/typescript.md` all `npm run` tokens vs `package.json` scripts | ✅ |
| `test_typescript_rule_testing_line_names_the_unit_test_command` | Semantic anchor (positive + negative) | Testing toolchain line | ✅ |
| `test_typescript_rule_coverage_line_names_the_coverage_command` | Semantic anchor (positive) | Coverage command line | ✅ |

**Coverage:** The module is test code (excluded from coverage denominators). Fail-before/pass-after evidence demonstrates all assertions are live: 12 of 15 failed pre-fix, 15 of 15 pass post-fix.

**Not covered:** Bundled copies are intentionally not asserted directly; the two push-down parity tests extend the guarantee transitively (design decision recorded in the module docstring and spec).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full suite) | 2138 | ✅ |
| Tests Passed | 2138 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time (full suite, reviewer run) | 3.52s | ✅ Fast |
| Targeted contract/parity selection | 28 passed in 0.19s | ✅ Fast |
| New module test count | 15 (12 failing pre-fix → 15 passing post-fix) | ✅ |
| Test File Size | 184 lines | ✅ Maintainable |
| Code Coverage (Python repo-wide) | 91.00% lines, 81.84% branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 333 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors, 0 warnings | ✅ |
| Pytest Tests | `poetry run pytest -q` | 2138 passed in 3.52s | ✅ |

**Mirror parity (SHA-256, reviewer-executed):**

| Pair | Repo-root vs bundled hash | Status |
|------|---------------------------|--------|
| `.claude/rules/typescript.md` | `44574b98…` = `44574b98…` | ✅ IDENTICAL |
| `.claude/rules/general-unit-test.md` | `c2d5f069…` = `c2d5f069…` | ✅ IDENTICAL |
| `.claude/rules/general-code-change.md` | `02eefec6…` = `02eefec6…` | ✅ IDENTICAL |
| `.claude/agents/atomic-executor.md` | `55a5b37e…` = `55a5b37e…` | ✅ IDENTICAL |
| `.agents/skills/general-unit-test/SKILL.md` | `92889171…` = `92889171…` | ✅ IDENTICAL |
| `.agents/skills/general-code-change/SKILL.md` | `635dcdb6…` = `635dcdb6…` | ✅ IDENTICAL |

**Notes:**
Pyright emitted a benign environment warning ("venv .venv subdirectory not found in venv path") in the reviewer worktree; error count remained zero. No pre-existing failures were observed.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Evidence wording inaccuracy (Minor, non-blocking):** `evidence/other/npx-jest-resolution.2026-07-26T00-58.md` records `npx jest --version` output `30.4.1` and asserts it "satisfies the declared `^30.4.2` range constraint family." Semver `^30.4.2` requires >= 30.4.2, so 30.4.1 does not satisfy the declared range; the resolved binary came from a parent-checkout `node_modules` installation that predates the manifest bump. The substantive conclusion of the artifact — that the `Bash(npx jest *)` command form resolves and executes in this repository while `npx vitest` had no resolvable binary — remains verified and correct. No remediation of this branch is required; the installed-version drift belongs to the sibling orchestration that owns `package.json`.
- **MCP template/validator tools unavailable to the reviewer:** review artifacts were created from the bundled template assets at `extensions/drm-copilot/resources/templates/policy_audit/` (the same assets the MCP tool `resolve_policy_audit_template_asset` serves) and required-heading conformance was verified manually. Documented assumption per the no-questions constraint.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented; the `[P3-T2]` authorized skip branch for `npx jest` was not needed (the invocation executed).

### Known Unfixed Findings (deliberate, assessed)

1. **`.dependency-cruiser.cjs` does not exist** yet is named at `.claude/rules/typescript.md:57`, `.claude/rules/general-unit-test.md:40`, and `.agents/skills/general-unit-test/SKILL.md:45`. Assessment: **defensible to leave unfixed.** It is a distinct accuracy defect (architecture-boundary tooling, not the Vitest/Jest divergence), the plan's hard constraint 5 forbids folding it in, and it is recorded for separate filing in `evidence/other/adjacent-finding-dependency-cruiser.2026-07-26T00-58.md`. Reviewer verified the file is absent repository-wide (glob `**/.dependency-cruiser.cjs`: no matches). Not blocking; the separate issue must actually be filed post-merge (spec Rollout & Follow-up).
2. **`README.md:303` and `README.md:318` describe the TypeScript toolchain as Vitest.** Assessment: **defensible to leave unfixed.** `README.md` is outside the research-adjudicated owned file set; the spec records it as a planner-optional follow-up. Reviewer confirmed both lines still read Vitest. Not blocking for this instruction-mirror fix, though it perpetuates the same class of reader-facing inaccuracy and should be picked up promptly.
3. **`jest-haste-map` naming collision** between root `package.json` and `extensions/drm-copilot/package.json` (both named `drm-copilot`). Assessment: **defensible to leave unfixed.** Pre-existing baseline behavior, warning-only, and both manifests are owned by the sibling orchestration per the spec's hard constraints. Not blocking.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **6fe7e745** - docs(422): add feature folder, research, and spec for Vitest/Jest mirror divergence
2. **564987e6** - docs(422): apply preflight deltas to atomic plan
3. **042ed066** - fix(422): align Claude and Codex rule mirrors with the Jest runner

### Files Modified

1. **Six repo-root instruction mirrors** (MODIFIED) — Vitest→Jest framework references, `npm run test`→`npm run test:unit`, `npm run test:coverage`→`npm run test:unit:coverage`, `vi.*`→`jest.*`, `vitest.config.ts`→`jest.config.cjs`, `Bash(npx vitest *)`→`Bash(npx jest *)`.
2. **Six bundled counterparts** under `extensions/drm-copilot/resources/` (MODIFIED) — byte-identical to their repo-root files (SHA-256 verified).
3. **`tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`** (NEW) — 15-case regression module locking the corrected state.
4. **Feature folder** `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/` (NEW) — issue, spec, plan, research, 26 evidence artifacts.

Prohibited-path verification (reviewer-executed against the full branch diff): no path under `.github/instructions/**`; root `package.json`, `jest.config.cjs`, `run-jest.cjs`, `tsconfig*.json`, `.vscode-test.*` unmodified; `expert-react-frontend-engineer.agent.md` and `github-actions-ci-cd-best-practices.instructions.md` unmodified; no `docs/features/completed/**` edits; no Vitest migration.

Canon-consistency verification: `.github/instructions/typescript-unit-test.instructions.md` mandates Jest (`jest.spyOn`, `jest.mock`, `jest.resetAllMocks`, `jest.useFakeTimers`) and approves `npm run test:unit` (lines 24, 82-94, 110); the corrected mirrors now agree. Hook consistency: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:67` recognizes the family `npx (prettier|eslint|tsc|jest)`, so the new `Bash(npx jest *)` allowlist entry is hook-consistent; Jest `^30.4.2` is the declared root devDependency and `jest.config.cjs` exists at the repo root.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All policy gates pass. The change is documentation-plus-test-only, mirrors the canonical Jest policy exactly, preserves byte-parity across all six bundled pairs, and holds coverage exactly at baseline (91.00% / 81.84%) with zero regression. No blocking findings. The single Minor finding (semver wording in one evidence artifact) does not affect the delivered fix.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective, research, and plan documented
- ✅ Design Principles: minimal, reusable, extensible test design
- ✅ Module & File Structure: 184-line single-purpose module
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: clean single pass, reviewer-reproduced
- ✅ Summarize & Document: complete feature folder

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python Tooling & Baseline: Black/Ruff/Pyright/Pytest all clean
- ✅ Python Design & Typing: fully typed, no `Any`
- ✅ Python Error Handling: compliant for test code

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, fast, deterministic, readable
- ✅ Coverage & Scenarios: 91.00% / 81.84%, zero delta, fail-before evidence
- ✅ Test Structure: AAA with diagnostics
- ✅ External Dependencies: none; no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python Framework & Scope, Style & Structure, Naming, Toolchain: all compliant

### Metrics Summary

- ✅ 2138/2138 tests passing (100%)
- ✅ 91.00% line coverage / 81.84% branch coverage (floors 85% / 75%)
- ✅ 6/6 mirror pairs byte-identical (SHA-256)
- ✅ 15/15 regression cases passing; 12 demonstrably failing pre-fix
- ✅ All code quality checks passing
- ✅ Full-suite execution 3.52s

### Recommendation

**Ready for merge.** No remediation required. Post-merge follow-ups (outside this branch): file the separate `.dependency-cruiser.cjs` issue and the README Vitest-wording correction.

---

## Appendix A: Test Inventory

New module `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`:

- test_mirror_does_not_name_the_vitest_framework[.claude/rules/typescript.md]
- test_mirror_does_not_name_the_vitest_framework[.claude/rules/general-unit-test.md]
- test_mirror_does_not_name_the_vitest_framework[.claude/rules/general-code-change.md]
- test_mirror_does_not_name_the_vitest_framework[.claude/agents/atomic-executor.md]
- test_mirror_does_not_name_the_vitest_framework[.agents/skills/general-unit-test/SKILL.md]
- test_mirror_does_not_name_the_vitest_framework[.agents/skills/general-code-change/SKILL.md]
- test_mirror_does_not_reference_the_vitest_api[.claude/rules/typescript.md]
- test_mirror_does_not_reference_the_vitest_api[.claude/rules/general-unit-test.md]
- test_mirror_does_not_reference_the_vitest_api[.claude/rules/general-code-change.md]
- test_mirror_does_not_reference_the_vitest_api[.claude/agents/atomic-executor.md]
- test_mirror_does_not_reference_the_vitest_api[.agents/skills/general-unit-test/SKILL.md]
- test_mirror_does_not_reference_the_vitest_api[.agents/skills/general-code-change/SKILL.md]
- test_typescript_rule_npm_commands_resolve_to_root_package_scripts
- test_typescript_rule_testing_line_names_the_unit_test_command
- test_typescript_rule_coverage_line_names_the_coverage_command

Related pre-existing modules exercised: `test_push_down_claude_resource_contracts.py` (11 tests), `test_push_down_codex_and_agents_resource_contracts.py` (2 tests) — all passing.

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Formatting
poetry run black --check .

# Linting
poetry run ruff check .

# Type checking
poetry run pyright

# Testing
poetry run pytest -q
poetry run pytest tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q
```

**Review-specific verification:**
```bash
# PR context refresh
python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt

# Mirror parity
sha256sum <six repo-root files> <six bundled counterparts>

# Prohibited-path scan
git diff --name-only fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD

# Pre-fix defect corroboration
git show fb483b8468204e4385b5583c3b3ec4c0a987eede:.claude/rules/typescript.md

# Coverage artifact parse (artifacts/python/lcov.info)
python -c "<sum LF/LH/BRF/BRH records>"

# Evidence location compliance
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-07-26
**Policy Version:** Current (as of audit date)
