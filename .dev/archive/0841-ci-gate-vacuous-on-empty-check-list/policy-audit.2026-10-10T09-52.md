# Policy Compliance Audit: CI gate vacuous on empty check list (#841, also closes #795)

---

**Audit Date:** 2026-10-10  
**Code Under Test:** `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (+ Claude bundle mirror), `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`, `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (new), `.claude/skills/orchestrate/SKILL.md` (+ Claude bundle mirror), `.claude/skills/feature-review-workflow/SKILL.md` (+ Claude bundle mirror), `.agents/skills/feature-review-workflow/SKILL.md` (+ Codex bundle mirror)

**Base branch:** `main` (`origin/main` @ `793731a12e0aafb5f6eb645fffa072d941797de1`). **Head:** `bug/ci-gate-vacuous-on-empty-check-list-841` @ `87f57d4f554172020dbf0f50d7e797a32298a647`. **Merge base:** `793731a12e0aafb5f6eb645fffa072d941797de1` (equal to `origin/main`; the branch is current with main). **Pre-change implementation base (executor baseline):** `5431ccdd471c184917493c4211afcd715bb4b95c`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 production (parser + byte-identical bundle mirror), 1 test | 35 tests (ci-gate folder) | ✅ 35 pass, 0 fail | parser 94.12% lines (32/34); repo 87.31% cmds | parser 97.83% lines (45/46); repo >= 87.31% cmds (no added misses) | 100% (13/13 executable changed lines) |
| Python | 1 test file (new); 0 production | 26 tests (new file); 1299 incl. related suites | ✅ 26 pass, 0 fail | 96% lines `skill_bundle_contract.py`; repo 93.61% lines | 96% lines `skill_bundle_contract.py`; repo 93.61% lines (no production change) | N/A - test code only, excluded from coverage measurement |
| Markdown (skills) | 6 files (3 sources + 3 mirrors) | text contracts in the Python file | ✅ pass | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/baseline/pester-ci-gate-coverage.2026-10-08T22-17.md` (parser 94.12%); repo-wide 87.31% from CI run 38054308295, PowerShell QC job 114219517675, at pre-change base 5431ccdd
- PowerShell post-change coverage artifact: `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md` (parser 97.83%, written from `artifacts/pester/powershell-coverage.xml` at 09:37); `artifacts/pester/powershell-coverage.xml` (current file, cross-checked by the reviewer)
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/coverage-comparison.2026-10-08T22-17.md`

---

## Executive Summary

The branch adds an opt-in `-RequireWorkflow <name>` guard to `Invoke-CiGateParser.ps1` so that S9 on an epic child can no longer conclude `success` on an empty or non-`CI`-only check set (CR-1); rewrites S9 step 2/3 and the `ci_gate.head_sha` schema bullet in the orchestrate skill (CR-4); replaces the SHA-exact qualifying-run definition in the `modified-workflow-needs-green-run` rule with a satisfiable predecessor-head alternative (PA-N9); and adds the rule to the `.agents` feature-review-workflow skill so its `.agents`-side citers resolve (#795). The default parser path is unchanged.

All policy categories evaluated as PASS. Coverage verdicts: PowerShell PASS, Python PASS. TypeScript, C#, and Bash have zero changed files. No blocking finding exists. The `modified-workflow-needs-green-run` rule does not fire: the branch diff contains no path under `.github/workflows/**`, `.github/actions/**`, or `scripts/benchmarks/**` (reviewer scan of `git diff --name-only origin/main...HEAD`, 61 paths, zero matches).

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (repository classified T4 in `quality-tiers.yml`; uniform coverage thresholds apply)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (test file only)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no shell files changed
- N/A JSON: no JSON files changed

Reviewer-run checks (check-only): `poetry run black --check`, `poetry run ruff check`, `poetry run pyright` on the new test file (all clean); `poetry run pytest` on the new file plus every suite named by spec AC-12, AC-13, AC-17, and AC-18 (1299 passed, 5 skipped, 0 failed); byte comparison (`cmp`) of all four source/mirror pairs (identical); line counts (`wc -l`); `validate_evidence_locations.py --root .` (exit 0). PowerShell format, analyze, and Pester results are taken from the executor's PoshQC MCP evidence (see Route note below) and cross-checked against CI logs and the coverage XML on disk.

**Route note (operator-mandated):** PowerShell verification used the PoshQC MCP tools plus the JUnit/JaCoCo XML they write; the evidence files record `ROUTE_SUBSTITUTION:` lines. This is an operator-mandated route, not a plan deviation, and is not treated as a finding.

**Template source note:** the MCP template-resolver tool is not available in this reviewer's tool list. The template was read from the repository bundle asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the file the resolver serves. The installed extension copy differs from it only in the three Bash-section command lines (section 3C), which are deleted here because no shell file changed.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts are present in the branch diff (the operator constraint prohibited scratch scripts; `evidence/other/scratch-smoke.2026-10-08T22-17.md` records the route check only).
- ✅ No new tooling scripts were added.
- Reviewer helper script for XML parsing was written to the session scratchpad only, outside the repository.

---

## Rejected Scope Narrowing

None. The caller prompt specified the full branch diff against `main`. Three caller statements were evaluated and are not scope narrowing: (1) the "Scope written" file list is informational and matches the full code diff; (2) the operator constraint that PowerShell verification used the PoshQC MCP tools is a statement about evidence source, and PowerShell coverage is evaluated here with an explicit verdict; (3) the instruction that CI-dependent findings use `Remediability: awaiting_ci` is a remediability classification rule, not an exclusion.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exit 0, no paths reported.
- Branch diff scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: zero matches.
- All 39 evidence files live under `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Result: PASS.

## Policy Rule: modified-workflow-needs-green-run

- Trigger scan: `git diff --name-only origin/main...HEAD` filtered for `^(\.github/|scripts/benchmarks/)` returned no paths (grep exit 1).
- Result: rule not triggered; no Blocking or `awaiting_ci` finding. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE; CI has not run because no PR exists yet.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Pester tests share only immutable `BeforeAll` state (script path, fixed clock, AST). Each `It` builds its own check set. Pytest tests are parametrized pure reads with no shared mutable state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `It` per behavior-matrix row in `Context "-RequireWorkflow (epic-child guard)"`; one pytest function per contract (S9 fragments, schema bullet, superseded wording, one-line command, qualifying run, SHA-exact absence, heading order, Codex bullets, citation resolution). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester ci-gate folder 0.834 s for 35 tests (JUnit `time`); new pytest file 26 tests in 0.10 s (reviewer run). |
| **Determinism** - Consistent results | ✅ PASS | Injected `$script:fixedClock`; no `gh`, network, wall clock, or randomness. Pytest reads committed files only. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names, Arrange/Act/Assert comments, pytest docstrings, named constants for fragments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Parser 94.12% lines (32/34), `evidence/baseline/pester-ci-gate-coverage.2026-10-08T22-17.md`, 2026-10-10 09:14. Python 96% (`evidence/baseline/python-coverage.2026-10-08T22-17.md`). Repo PowerShell 87.31% (CI run 38054308295 at 5431ccdd). |
| **No Coverage Regression** | ✅ PASS | Parser 94.12% -> 97.83% (+3.71). Instruction counter missed 3 -> 2, covered 40 -> 53, so the repo-wide command ratio cannot fall. Python unchanged at 96%. |
| **New Code Coverage >= 85%** | ✅ PASS | 13 of 13 executable added lines in the parser hit (`evidence/qa-gates/coverage-comparison.2026-10-08T22-17.md`). The new Python file is test code and is excluded from measurement by policy. |
| **Comprehensive Coverage** | ✅ PASS | `Get-CiGateConclusion` (guard validation, empty-set branch, pass tracking, presence rule) and `Invoke-CiGateParser`/script `process` forwarding all exercised. Only uncovered line: 338, the pre-existing default `$NowProvider` delegate (uncovered at baseline as line 270). |
| **Positive Flows** - Valid inputs | ✅ PASS | `returns success when a CI check passes`; `returns success when a CI check and a non-CI check both pass`; element without `workflow` beside a CI pass returns `success`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `throws an error naming -RequireWorkflow for a whitespace-only value`; pre-existing missing-bucket and unknown-bucket throw tests retained. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty array and `$null` set with the guard -> `pending`; only `skipping` CI checks -> `pending`; lowercase `ci` -> `pending` (case-sensitive); element lacking `workflow` -> non-matching, no throw. |
| **Error Handling** - Error paths | ✅ PASS | Whitespace-only guard value throws with a message naming the parameter; precedence failure > pending > presence verified by `returns failure when a CI check is pending and another check failed`. |
| **Concurrency** - If applicable | N/A | The parser is a pure, single-threaded derivation. |
| **State Transitions** - If applicable | N/A | No stateful component; the conclusion is a pure function of the check set. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.12% lines on `Invoke-CiGateParser.ps1` (32/34), repo-wide 87.31% commands (CI run 38054308295, 5431ccdd). Post-change: 97.83% lines on `Invoke-CiGateParser.ps1` (45/46); repo-wide not re-measured, bounded at >= 87.31% because the file's missed-command count fell from 3 to 2 while covered commands rose from 40 to 53. Change: +3.71 points on the parser. New/changed-code coverage: 100% (13/13 executable changed lines). Disposition: PASS. Evidence: `evidence/baseline/pester-ci-gate-coverage.2026-10-08T22-17.md`, `evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md`, `evidence/qa-gates/coverage-comparison.2026-10-08T22-17.md`, CI job 114219517675 log line `Covered 87.31% / 0%. 22,010 analyzed Commands in 178 Files.`
- Python: Baseline: 96% lines on `scripts/dev_tools/skill_bundle_contract.py` (module-scoped guard); repo-wide 93.61% lines (17572 statements, 1122 missed) and 92% combined line+branch (6344 branches, 511 partial) from CI run 38054308295 job 114219517535 at 5431ccdd. Post-change: 96% lines on the same module; repo-wide 93.61% lines unchanged because no Python production file changed. Change: 0.00 points. New/changed-code coverage: N/A - the only changed Python file is test code, excluded from coverage measurement. Disposition: PASS. Evidence: `evidence/baseline/python-coverage.2026-10-08T22-17.md`, `evidence/qa-gates/final-python-coverage.2026-10-08T22-17.md`, `artifacts/python/lcov.info` (LF 141, LH 136).

Branch coverage: PowerShell has no branch threshold (Pester measures commands and lines only). Python repo-wide branch coverage, derived from the 92% combined figure (16450 covered statements of 23916 statements+branches), lies between 85.6% and 89.4%, above the 75% threshold; it is unchanged by this branch.

Reviewer cross-check of the PowerShell artifact: the current `artifacts/pester/powershell-coverage.xml` (written 09:40:14 by the later `tests/scripts/claude-runtime` run recorded in `evidence/qa-gates/final-claude-runtime-pester.2026-10-08T22-17.md`) reports the parser at 0/46 because that run did not exercise it. Its 46 executable line numbers are identical to the 45 HIT lines plus line 338 recorded in the 09:37 post-change evidence, which confirms the instrumented line set. The 97.83% figure is therefore taken from the 09:37 evidence; the gitignored XML was overwritten by design. The reviewer did not regenerate coverage.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Pester `-Because` on the parameter-count assertion; pytest assertions print the copy path and the list of missing fragments or heading positions. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Every new `It` and pytest function carries Arrange/Act/Assert comments. |
| **Document Intent** | ✅ PASS | `It` names state the expected conclusion; module docstring of the pytest file states the #841/#795 contract. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No `gh`, network, or external process. Script-level forwarding test invokes the script file in-process with `&`. |
| **Use Mocks/Stubs** | ✅ PASS | No mocks needed: check sets are in-memory hashtables serialized to JSON; the clock is an injected scriptblock. |
| **Environment Stability** | ✅ PASS | No temporary files (pytest synthetic negative case uses an in-memory dict). Reads only committed repository files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the policy review for the branch; no open review items. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` state CR-1, CR-4, PA-N9, and #795 with reproduction steps. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-10-09T02-25.md` is the design basis; `evidence/baseline/phase0-instructions-read.2026-10-08T22-17.md` records policy reading. |
| **Document the plan** | ✅ PASS | `plan.2026-10-08T22-17.md`, 97/97 tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One boolean flag (`$requiredWorkflowPassed`) and one post-loop rule; no new functions. |
| **Reusability** | ✅ PASS | Guard lives in the existing pure `Get-CiGateConclusion`; callers forward a single parameter. |
| **Extensibility** | ✅ PASS | Parameter takes any workflow name; the parser holds no epic or branch concept. |
| **Separation of concerns** | ✅ PASS | Epic detection remains in the S9 skill text; the parser checks a workflow name only. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Changes confined to the existing parser and its test file; one new focused contract test module. |
| **Under 500 lines** | ✅ PASS | `wc -l`: parser 402, Pester file 410, new pytest file 312. Skill files are Markdown (exempt). |
| **Public vs internal** | ✅ PASS | Public surface change is one optional parameter with default `''`; output object shape unchanged. |
| **No circular dependencies** | ✅ PASS | No new imports or module references. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `RequireWorkflow`, `$requireWorkflowGuard`, `$requiredWorkflowPassed`, `unresolved_citations`, `missing_fragments`. |
| **Docs/docstrings** | ✅ PASS | `.PARAMETER RequireWorkflow` added to script, `Invoke-CiGateParser`, and `Get-CiGateConclusion` help; new `.EXAMPLE`; pytest helper docstrings. |
| **Comment why, not what** | ✅ PASS | Comments explain the StrictMode-safe property test and why whitespace is rejected rather than ignored. Minor residual "required check" wording in parser help/comments is noted as a Nit in the code review. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` (ci-gate folders); `poetry run black --check <new file>`<br>**Result:** ChangedCount=0; Black "1 file would be left unchanged" (reviewer run). |
| **2. Linting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`; `poetry run ruff check <new file>`<br>**Result:** DiagnosticCount=0; Ruff "All checks passed!" (reviewer run). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <new file>`<br>**Result:** 0 errors, 0 warnings (reviewer run). N/A for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` (ci-gate folder); `poetry run pytest` (new file + related suites)<br>**Result:** Pester 35/35; pytest 1299 passed, 5 skipped (reviewer run). |
| **Full toolchain loop** | ✅ PASS | Final QA evidence files record loop iteration 1 with no auto-fixes. Architecture-boundary, contract, and integration stages: no architecture tooling applies to these files; the contract stage is covered by the bundle-parity and pinned-fragment suites (pass). |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/qa-gates/` and in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 and commit subjects (`fix(841)`, `docs(841)`, `docs(795)`, `test(841)`). |
| **Design choices explained** | ✅ PASS | `spec.md` Assumptions A-2 (`pending` not `failure`), A-3 (non-CI checks must pass), A-4 (whitespace throws). |
| **Update supporting documents** | ✅ PASS | Orchestrate and feature-review skills plus mirrors updated together. |
| **Provide next steps** | ✅ PASS | Spec Rollout & Follow-up lists Codex S9 parity and a general citation scanner as follow-up candidates. |

---

## 3. Language-Specific Code Change Policy Compliance

---

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`<br>**Result:** unchanged (exit 0) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`<br>**Result:** All checks passed (exit 0) |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`<br>**Result:** 0 errors (exit 0) |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`<br>**Result:** 26 passed |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | All helpers and tests fully annotated (`tuple[str, ...]`, `dict[str, str]`, `list[str]`); no `Any`. |
| **Dataclasses for value objects** | N/A | No value objects; module-level constant tuples. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces. |
| **Avoid utility classes** | ✅ PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | No exception handling; `section()` lets `ValueError` propagate if a heading is absent (fails the test). |
| **Logging over print** | ✅ PASS | No print statements. |
| **Invariants at construction** | N/A | No classes. |

---

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` scan_folders `.claude/lib/ci-gate`, `tests/scripts/claude-lib/ci-gate`<br>**Result:** ChangedCount=0, object hashes identical before/after (`evidence/qa-gates/final-powershell-format.2026-10-08T22-17.md`) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze` same folders<br>**Result:** DiagnosticCount=0 (`evidence/qa-gates/final-powershell-analyze.2026-10-08T22-17.md`) |
| **Fix all findings** | ✅ PASS | No findings at baseline or post-change. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Added constructs (`[string]::IsNullOrWhiteSpace`, `-ceq`, `PSObject.Properties.Name -contains`) are available in 5.1 and 7.x. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Existing `[CmdletBinding()]` functions extended; parameter declared with `[Parameter(Mandatory = $false)]`. |
| **Parameter validation** | ✅ PASS | Whitespace-only value rejected with an explicit throw inside `Get-CiGateConclusion` (empty string is the documented off value, so `ValidateNotNullOrEmpty` is not applicable). |
| **Avoid global state** | ✅ PASS | Function-local variables only. |
| **Error handling** | ✅ PASS | Fail-fast throw naming the parameter; existing throws unchanged. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | Parser 402 lines; test file 410 lines. |
| **Approved verbs** | ✅ PASS | No new functions; `Get-CiGateConclusion` and `Invoke-CiGateParser` use approved verbs. |
| **Comment why** | ✅ PASS | Comments explain the StrictMode-safe property check and precedence. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | ChangedCount=0 (P6-T1). |
| **Step 2: Analyze** | ✅ PASS | DiagnosticCount=0 (P6-T2). |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 35/35 in ci-gate folder (P6-T3); 83/83 in `tests/scripts/claude-runtime` (P6-T10). |
| **Rerun loop if needed** | ✅ PASS | Loop iteration 1 for every final gate. |

---

## 4. Language-Specific Unit Test Policy Compliance

---

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `pytest.mark.parametrize` over the copy tuples; no fixtures needed. |
| **Coverage expectation** | ✅ PASS | Test-only Python change; repo-wide Python 93.61% lines (>= 85%), unchanged. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Each test asserts one contract over one copy. |
| **Mocking sparingly** | ✅ PASS | No mocking. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/`, alongside the other skill-text contract suites. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | e.g. `test_orchestrate_s9_states_epic_child_guard`, `test_rule_resolution_reports_missing_heading`. |
| **Docstrings/comments** | ✅ PASS | One-line docstring per test plus module docstring. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -q -p no:cacheprovider <new file + related suites>`<br>**Result:** 1299 passed, 5 skipped |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

---

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`Context`/`It`, `BeforeAll`, `Should -Be`/`-Throw`/`-Contain`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` (bundled PoshQC runner)<br>Settings unchanged. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | AST APIs (`Parser.ParseFile`, `GetHelpContent`) exist in both. CI PowerShell QC runs on the PR will confirm. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 18 new `It` blocks: 2 surface, 16 behavior. |
| **Test Behavior Over Implementation** | ✅ PASS | Behavior tests assert only `conclusion`; surface tests assert the declared contract required by AC-1. |
| **Mocking Used Sparingly** | ✅ PASS | No mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`<br>**Code file:** `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`<br>Pre-existing mirrored location. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `Invoke-CiGateParser.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe, 7 Contexts (2 new), 33 Its (18 new). |
| **Logical Grouping** | ✅ PASS | New `Context "-RequireWorkflow parameter surface"` and `Context "-RequireWorkflow (epic-child guard)"`. |
| **Docstrings/Comments** | ✅ PASS | Arrange/Act/Assert comments and scenario comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` scan_folders `tests/scripts/claude-lib/ci-gate`<br>**Result:** 35 passed, 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### Get-CiGateConclusion with -RequireWorkflow (16 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| returns pending for an empty check array with -RequireWorkflow CI | Edge Case | 168-181 | ✅ |
| returns pending for a null check set with -RequireWorkflow CI | Edge Case | 168-181 | ✅ |
| returns pending when only non-CI checks pass | Positive (guard holds) | 209-216, 236-237 | ✅ |
| returns success when a CI check passes | Positive | 209-216, 240 | ✅ |
| returns success when a CI check and a non-CI check both pass | Positive | 209-216, 240 | ✅ |
| returns failure when a CI check failed | Negative | 206 | ✅ |
| returns failure when a CI check was cancelled | Negative | 207 | ✅ |
| returns failure when a CI check passes and a non-CI check failed | Negative | 206 | ✅ |
| returns pending when a CI check is pending | Edge Case | 208, 230-231 | ✅ |
| returns pending when a CI check passes and a non-CI check is pending | Edge Case | 208, 230-231 | ✅ |
| returns failure when a CI check is pending and another check failed | Error precedence | 206, 208 | ✅ |
| returns pending when the only CI checks are skipping | Edge Case | 223, 236-237 | ✅ |
| does not match a lowercase ci workflow name (case-sensitive) | Edge Case | 213-215 | ✅ |
| treats an element without a workflow property as non-matching without throwing | Edge Case | 213-216 | ✅ |
| throws an error naming -RequireWorkflow for a whitespace-only value | Error Handling | 168-169 | ✅ |
| forwards -RequireWorkflow from the script entry point | Positive (wiring) | 362, 391-392 | ✅ |

**Coverage:** 97.83% of `Invoke-CiGateParser.ps1` (45/46 executable lines).

**Not covered:** line 338, the default `$NowProvider` delegate in the `Invoke-CiGateParser` param block; pre-existing and uncovered at baseline (line 270). Every test injects a fixed clock by design.

### -RequireWorkflow parameter surface (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| declares -RequireWorkflow as a string defaulting to '' on the script, Invoke-CiGateParser, and Get-CiGateConclusion | Contract (AST) | n/a (static) | ✅ |
| documents .PARAMETER RequireWorkflow in the help of the script, Invoke-CiGateParser, and Get-CiGateConclusion | Contract (AST) | n/a (static) | ✅ |

### test_ci_gate_epic_child_contracts.py (26 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_orchestrate_s9_states_epic_child_guard (x2 copies) | Positive | text contract | ✅ |
| test_orchestrate_schema_head_sha_names_queried_checks (x2) | Positive | text contract | ✅ |
| test_orchestrate_drops_required_check_wording (x2) | Negative | text contract | ✅ |
| test_orchestrate_parser_command_stays_on_one_line (x2) | Edge Case | text contract | ✅ |
| test_review_rule_defines_satisfiable_qualifying_run (x4) | Positive | text contract | ✅ |
| test_review_rule_drops_sha_exact_definition (x4) | Negative | text contract | ✅ |
| test_agents_review_rule_sits_before_ordered_procedure (x2) | Positive | text contract | ✅ |
| test_agents_review_rule_carries_codex_bullets (x2) | Positive | text contract | ✅ |
| test_agents_citing_copy_resolves_rule (x4) | Positive | text contract | ✅ |
| test_rule_resolution_reports_missing_heading | Negative (synthetic) | in-memory | ✅ |
| test_rule_resolution_accepts_defined_heading | Positive (synthetic) | in-memory | ✅ |

**Coverage:** test code; excluded from coverage measurement per policy.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 35 (ci-gate folder); pytest 26 (new file) | ✅ |
| Tests Passed | 35 (100%); 26 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Pester 0.834 s; pytest 0.10 s | ✅ Fast |
| Average Time per Test | Pester about 24 ms; pytest about 4 ms | ✅ Fast |
| Discovery Time | not separately reported by the MCP runner; included in totals | ✅ |
| Functions/Classes Tested | 2/2 parser functions plus script entry point | ✅ |
| Test File Size | 410 lines (Pester); 312 lines (pytest) | ✅ Maintainable |
| Code Coverage (if applicable) | 97.83% lines (parser); PowerShell has no branch metric | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` | unchanged | ✅ |
| Ruff Linting | `poetry run ruff check tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -q -p no:cacheprovider <new file + 7 related suites + test_parallel_*.py>` | 1299 passed, 5 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` (ci-gate folders) | ChangedCount=0 | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` (ci-gate folders) | DiagnosticCount=0 | ✅ |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` (`tests/scripts/claude-lib/ci-gate`) | 35 passed, 0 failed | ✅ |

**Notes:**
- PowerShell gates were not re-run by the reviewer (no PoshQC MCP tool in this agent's tool list; the operator constraint excludes shell/pwsh scratch scripts). Results are from executor evidence written 2026-10-10 09:36-09:40 with freshness timestamps recorded. The pre-change CI run 38054308295 shows the PowerShell QC job formatting the same three files as "Already formatted" and passing 6743 tests.
- The 5 pytest skips are pre-existing fixture skips in `test_parallel_manifest_bash_parity.py` unrelated to this branch.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None.** All policy requirements are met. Non-blocking observations (residual "required check" wording in parser help, Codex S9 parity) are recorded in the code review.

### Approved Exceptions

- PowerShell verification route: operator-mandated substitution of PoshQC MCP tools plus XML reads for scratch scripts (`ROUTE_SUBSTITUTION:` lines in the evidence). Recorded, not a finding.
- Repo-wide PowerShell post-change figure is bounded (>= 87.31%) rather than re-measured; CI PowerShell QC on the PR will report the measured value, and the orchestrator S9 gate requires that run to succeed.

### Removed/Skipped Tests

**None.** No test was removed. The pre-existing empty-array test was renamed only (adds "without -RequireWorkflow"); its expectation is unchanged.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **5c6c285d5** - docs(841): prepare feature folder, research, spec, and approved plan for #841 and #795
2. **c51f2f2bb** - Merge remote-tracking branch 'origin/main'
3. **5dd92fa57** - docs(841): record phase 0 baselines
4. **b94163c00** - test(841): add epic-child CI gate regression tests
5. **0a8e95af1** - docs(841): check off P1-T6
6. **7b162606a** - fix(841): add opt-in -RequireWorkflow guard to the CI gate parser
7. **0af738acc** - docs(841): require a passing CI check for epic-child S9 and describe queried checks
8. **955b7a68e** - docs(841): define a satisfiable qualifying run for modified-workflow-needs-green-run
9. **aafa069bd** - docs(795): define modified-workflow-needs-green-run in the Codex feature-review skill
10. **a46aa7e4b** - docs(841): check off P5-T8
11. **c675a8b65** - docs(841): record final QA evidence
12. **d68ccbb94** - docs(841): check off acceptance criteria and record verification
13. **a6f6da426** - docs(841): check off P6-T25
14. **87f57d4f5** - Merge remote-tracking branch 'origin/main'

### Files Modified

1. **`.claude/lib/ci-gate/Invoke-CiGateParser.ps1`** (MODIFIED) and its Claude bundle mirror (MODIFIED, byte-identical)
   - Adds `-RequireWorkflow` at script level, on `Invoke-CiGateParser`, and on `Get-CiGateConclusion`; whitespace-only rejection; presence rule after failure/pending precedence.
2. **`tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`** (MODIFIED)
   - Renames the empty-array default test; adds 18 tests in two contexts.
3. **`tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`** (NEW)
   - 26 text-contract tests for CR-4, PA-N9, and #795 citation resolution.
4. **`.claude/skills/orchestrate/SKILL.md`** (MODIFIED) and Claude bundle mirror
   - S9 epic-child paragraph, step 3 conclusion over queried checks, `head_sha` bullet.
5. **`.claude/skills/feature-review-workflow/SKILL.md`** (MODIFIED) and Claude bundle mirror
   - Satisfiable qualifying-run definition (alternatives (a) and (b)).
6. **`.agents/skills/feature-review-workflow/SKILL.md`** (MODIFIED) and Codex bundle mirror
   - New `## Policy Rules` / `### modified-workflow-needs-green-run` section.
7. **Feature folder and promoted lifecycle record** (NEW) - `issue.md`, `spec.md`, `plan`, `research`, 39 evidence files, `docs/features/potential/promoted/2026-10-08-ci-gate-vacuous-on-empty-check-list.md`.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All evaluated policies pass. Coverage: PowerShell PASS (parser 97.83%, changed lines 100%, no regression); Python PASS (test-only change, repo-wide 93.61% lines, unchanged). No blocking finding; the workflow green-run rule is not triggered.

**Fail-closed reminder:** Baseline, post-change, and comparison artifacts are present for both changed languages.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present
- ✅ Design Principles: opt-in guard, default unchanged
- ✅ Module & File Structure: all code files under 500 lines
- ✅ Naming, Docs, Comments: help text updated on all three surfaces
- ✅ Toolchain Execution: format, lint, type, test clean
- ✅ Summarize & Document: commits and spec record design decisions

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright, Pytest clean
- ✅ Python Design & Typing: fully annotated
- ✅ Error Handling: no broad handlers

**For PowerShell:**
- ✅ Tooling & Baseline: format 0 changes, PSSA 0 findings
- ✅ PowerShell Design & Safety: fail-fast validation
- ✅ Structure & Naming: approved verbs, under limit
- ✅ Toolchain: single-pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic, isolated
- ✅ Coverage & Scenarios: behavior matrix fully covered
- ✅ Test Structure: AAA
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest
- ✅ Test Style & Structure: focused, no mocks
- ✅ Naming & Readability: descriptive
- ✅ Toolchain: 26/26

**For PowerShell:**
- ✅ Framework & Scope: Pester v5 via PoshQC
- ✅ Test Style & Structure: one It per matrix row
- ✅ Naming & Readability: descriptive
- ✅ Toolchain: 35/35

---

### Metrics Summary

- ✅ 35/35 Pester tests passing (100%) in the ci-gate folder
- ✅ 26/26 new pytest tests passing; 1299 passed across related suites
- ✅ 97.83% line coverage on the parser; 100% of changed executable lines
- ✅ Test files mirror production locations
- ✅ All code quality checks passing
- ✅ Test execution time under 1 second per suite

---

### Recommendation

**Ready for merge** subject to the orchestrator S9 CI green gate on the PR head (CI has not run because no PR exists yet). No remediation is required.

---

## Appendix A: Test Inventory

### Complete Test List

1. Invoke-CiGateParser.ps1 › conclusion derivation across bucket combinations › 7 pre-existing tests (one renamed: "returns success for an empty required-check array without -RequireWorkflow (vacuous satisfaction)")
2. Invoke-CiGateParser.ps1 › fail-fast error handling › 3 pre-existing tests
3. Invoke-CiGateParser.ps1 › deterministic verified_at › 1 pre-existing test
4. Invoke-CiGateParser.ps1 › field passthrough › 2 pre-existing tests
5. Invoke-CiGateParser.ps1 › JSON emission › 1 pre-existing test
6. Invoke-CiGateParser.ps1 › Get-CiGateConclusion pure helper › 1 pre-existing test (null set returns success)
7. Invoke-CiGateParser.ps1 › -RequireWorkflow parameter surface › 2 new tests (section 5)
8. Invoke-CiGateParser.ps1 › -RequireWorkflow (epic-child guard) › 16 new tests (section 5)
9. CiGate.Manifest.Tests.ps1 › 2 pre-existing tests
10. test_ci_gate_epic_child_contracts.py › 26 nodes (section 5)

---

## Appendix B: Toolchain Commands Reference

**For Python (reviewer-run, check-only):**
```bash
poetry run black --check tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
poetry run ruff check tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
poetry run pyright tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_parallel_*.py
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**For PowerShell (executor-run through the PoshQC MCP tools; operator-mandated route):**
```powershell
# Formatting
mcp__drm-copilot__run_poshqc_format scan_folders=[".claude/lib/ci-gate","tests/scripts/claude-lib/ci-gate"]
# Linting
mcp__drm-copilot__run_poshqc_analyze scan_folders=[".claude/lib/ci-gate","tests/scripts/claude-lib/ci-gate"]
# Testing and coverage (reads artifacts/pester/pester-junit.xml and powershell-coverage.xml)
mcp__drm-copilot__run_poshqc_test scan_folders=["tests/scripts/claude-lib/ci-gate"]
```

**Reviewer verification commands:**
```bash
git diff --name-only origin/main...HEAD
git merge-base origin/main HEAD
cmp <source> <bundle mirror>   # four pairs, all identical
wc -l .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
gh run list --branch main --workflow CI --limit 5
gh run view 38054308295 --job 114219517675 --log   # PowerShell QC: Covered 87.31%
gh run view 38054308295 --job 114219517535 --log   # Python 3.13: TOTAL 17572 1122 6344 511 92%
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-10-10  
**Policy Version:** Current (as of audit date)
