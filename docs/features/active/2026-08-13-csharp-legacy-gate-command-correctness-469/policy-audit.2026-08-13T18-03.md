# Policy Compliance Audit: csharp-legacy-gate-command-correctness (Issue #469)

---

**Audit Date:** 2026-08-13
**Code Under Test:** Branch `bug/csharp-legacy-gate-command-correctness-469` at `d342c6c77e85b052a489bb7dbc881f6dca9dbe92` versus base `main` (merge base `fe0413d4aca1e76b2d02d05701fba79a887d5405`). 40 changed files: 4 canonical `csharp-legacy` Markdown variant sources, `README.md`, 4 Python test files, the feature folder (issue.md, spec.md, plan, research, 24 evidence artifacts), and 2 potential-feature documents.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 4 files (all under `tests/`) | 3781 tests | PASS 3781 pass, 0 fail, 5 pre-existing skips | 92.30% lines, 84.66% branches | 92.30% lines, 84.66% branches | N/A — only test files changed; `tests/**` is excluded from the coverage denominator by policy |
| TypeScript | 0 files | 2495 tests | PASS 2495 pass, 0 fail (executor evidence; verification-only run, no TypeScript change) | 96.57% lines, 89.90% branches | 96.57% lines, 89.90% branches | N/A — no TypeScript files in the branch diff |
| PowerShell | 0 files | N/A | N/A | N/A — no PowerShell files in the branch diff | N/A — no PowerShell files in the branch diff | N/A |
| C# | 0 files | N/A | N/A | N/A — no C# files in the branch diff | N/A — no C# files in the branch diff | N/A |
| Markdown | 32 files | N/A | N/A | N/A — outside every coverage denominator | N/A — outside every coverage denominator | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/baseline/typescript-tests-coverage.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-typescript-tests-coverage.2026-08-13T17-28.md`
- PowerShell baseline coverage artifact: N/A — no PowerShell files in the branch diff
- PowerShell post-change coverage artifact: N/A — no PowerShell files in the branch diff
- Per-language comparison summary: section 1.2.1 below and `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/coverage-comparison.2026-08-13T17-28.md`

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

---

## Executive Summary

This audit covers the full branch diff `fe0413d4..d342c6c7` (40 files) against `main`. The change corrects three defective C# quality-gate commands in the four canonical `csharp-legacy` variant sources on the Claude and Codex/Agents surfaces, updates the matching `README.md` section, and adds seven deterministic Python tests (five content-contract tests, two repeated-generation determinism tests). No Python, TypeScript, PowerShell, or C# production code changed; the production-side diff is Markdown resource payloads only.

The reviewer re-ran the full Python toolchain independently (Black check, Ruff, Pyright, Pytest with branch coverage): all four stages exit 0 in a single pass, 3781 passed / 5 pre-existing skips, line 92.30% (13288/14396) and branch 84.66% (4475/5286), numerically identical to both the executor's baseline and final evidence. The reviewer additionally verified the content contract independently (all seven required substrings present, all three file-scoped forbidden literals absent, span-scoped nullable predicate satisfied, zero fenced code blocks in all four variant files) and performed two adversarial mutant probes: reintroducing `sln /t:Build` into the Claude variant and injecting `/p:Nullable=enable` into a Codex msbuild command span each caused the corresponding new exclude test to fail; both files were restored with `git checkout --` and the four affected suites re-passed (32/32).

**Policy documents evaluated:**
- [x] `.claude/rules/general-code-change.md`
- [x] `.claude/rules/general-unit-test.md`
- [x] `.claude/rules/quality-tiers.md`
- [x] `.claude/rules/tonality.md`
- [x] `.claude/rules/self-explanatory-code-commenting.md`
- [x] `.claude/rules/ci-workflows.md` and `.claude/rules/benchmark-baselines.md` (not engaged; see policy-rule section)

**Language-specific policies evaluated:**
- [x] `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` (test files changed)
- N/A PowerShell — no PowerShell files in the branch diff
- N/A TypeScript rules for code change — no TypeScript files in the branch diff (verification-only toolchain runs recorded by the executor)
- N/A C# — no C# source files in the branch diff (the change edits Markdown documents that describe C# commands)

**Temporary artifacts cleanup:**
- [x] All temporary/one-time scripts created during development have been deleted (reviewer verification: `git status --porcelain` shows no untracked files; the executor's final-python-tests-coverage evidence records that its temporary JSON coverage export was deleted after reading)
- [x] No ongoing tooling scripts were created by this feature
- Reviewer mutant-probe mutations were applied to two variant files and fully reverted with `git checkout --`; post-restore `git status --porcelain` was clean for both files and all four affected test suites re-passed.

## Rejected Scope Narrowing

None detected. The caller prompt explicitly directed a full feature-vs-base audit with no narrowing. The two scope decisions recorded in `spec.md` and `issue.md` (the Codex default-slot defect deferred to `docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md`, and the MSBuild binlog / `CoreCompile`-count proof struck by owner decision on 2026-08-13) are owner-authored requirement-scope decisions inside the AC source, not caller attempts to narrow the audit scope; this audit still covered every changed file in the branch diff.

## Evidence Location Compliance

- Branch-diff scan: `git diff --name-only fe0413d4..HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` — zero matches. Every evidence artifact this feature produced lives under the canonical `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/{baseline,qa-gates,regression-testing,issue-updates,other}/` tree.
- Whole-tree validator: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 1 with two reported paths, both pre-existing, untracked by git, and absent from this branch's diff:

| Reported path | Canonical replacement | Disposition |
|---|---|---|
| `artifacts/research/2026-07-07T19-00-epic-folder-structure-research.md` | `docs/features/active/<feature>/research/` or `docs/research/` | FAIL per validator; not in the #469 branch diff and untracked by git — pre-existing local file already recorded in the #331 policy audit; housekeeping, not attributable to this branch |
| `artifacts/research/2026-08-04T09-53-crlf-atomic-plan-validator-434-research.md` | `docs/features/active/<feature>/research/` or `docs/research/` | FAIL per validator; not in the #469 branch diff and untracked by git — pre-existing local file; housekeeping, not attributable to this branch |

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred: no instruction supplied a non-canonical evidence path.

## Coverage Verification

- Python coverage artifact `artifacts/python/lcov.info` exists and was regenerated by the reviewer's own `poetry run pytest --cov --cov-branch --cov-report=term` run (exit 0). Repo-wide line coverage 92.30% (threshold >= 85%) and branch coverage 84.66% (threshold >= 75%): PASS.
- Changed Python files are exclusively under `tests/` (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_end_to_end.py`, `test_push_down_codex_and_agents_customizations.py`); `tests/**` is excluded from the coverage denominator by `.claude/rules/general-unit-test.md`, so there are no new or modified production files with per-file coverage obligations. No regression: baseline and post-change totals are identical.
- TypeScript, PowerShell, and C# have zero changed files on the branch, so per the review contract their coverage verdicts are N/A. TypeScript coverage evidence nonetheless exists from the executor's verification-only runs (`coverage/lcov.info`; 96.57% lines / 89.90% branches, identical baseline and post-change) and corroborates zero TypeScript impact.

## Policy Rule: modified-workflow-needs-green-run

Not triggered. The branch diff contains no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. The benchmark-baseline provenance rule (`.claude/rules/benchmark-baselines.md`) is likewise not engaged (no baseline files changed).

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | The five new contract tests read repository bytes with no shared mutable state; the two determinism tests each construct their own `RecordingFileSystem`. Reviewer ran the four files together (32 passed) and individually during mutant probes with identical results. |
| **Isolation** - Each test targets single behavior | PASS | One test per behavior: required-substring presence, forbidden-form absence, modern-profile pin, and repeated-generation determinism are separate functions per surface. |
| **Fast Execution** - Tests complete quickly | PASS | The four affected files complete in 0.26s (32 tests); the full suite of 3781 tests completes in under 18s. |
| **Determinism** - Consistent results | PASS | Contract tests read static repository bytes; determinism tests use in-memory `RecordingFileSystem` doubles with a fixed seeded tree. No time, randomness, network, or disk I/O in the new tests. |
| **Readability & Maintainability** - Clear structure | PASS | New tests follow the existing module conventions: module-level constants, Google-style docstrings, Arrange/Act/Assert comments, one f-string assertion message per (file, substring) pair. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development):** 92.30% lines, 84.66% branches (Python); 96.57% lines, 89.90% branches (TypeScript, verification-only)<br>**Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`<br>**Timestamp:** 2026-08-13 (evidence/baseline/python-tests-coverage.md) |
| **No Coverage Regression** | PASS | **Post-change coverage:** 92.30% lines, 84.66% branches (Python)<br>**Change:** +0.00% lines, +0.00% branches<br>**Status:** No regression — reviewer-run totals are numerically identical to baseline (13288/14396 statements, 4475/5286 branches). |
| **New Code Coverage ≥90%** | N/A | No new production files. All new code is in `tests/**`, which is excluded from the coverage denominator by policy; Markdown payloads are outside every coverage denominator. |
| **Comprehensive Coverage** | PASS | The new helper `_spans_with_both_literals` (both contract files) and `_destination_map` / `_seed_legacy_variant_tree` are exercised by every invocation of their host tests; reviewer mutant probes confirmed both the file-scoped scan and the span-scoped predicate paths execute and discriminate. |
| **Positive Flows** - Valid inputs | PASS | Required-substring tests assert the corrected commands are present in all four variant files (7 substrings x 4 files); modern-profile test asserts the SDK-style commands remain present in both root files. |
| **Negative Flows** - Invalid inputs | PASS | Forbidden-form tests assert the three file-scoped stale literals are absent and that no inline code span carries both `msbuild` and `/p:Nullable=enable`. Fail-before evidence (`evidence/regression-testing/fail-before-contract-tests.2026-08-13T17-28.md`) records 4 failed / 0 passed against the pre-fix content, and the reviewer's two mutant probes each produced a fresh failure. |
| **Edge Cases** - Boundary conditions | PASS | The chosen literals encode the collision boundaries: `csharpier .` does not match `csharpier check .` as a contiguous substring; `sln /t:Build` does not match the intentionally retained "CI may retain `/t:Build`" prose; the span-scoped predicate permits the standalone prohibition span while forbidding the property inside command spans. Reviewer independently re-verified all three boundaries against current file bytes. |
| **Error Handling** - Error paths | N/A | No production code paths changed; the tests assert static content, and the existing `ManifestError` reject path retains its pre-existing coverage (`test_invalid_csharp_variant_pack_combination_fails_before_writes`). |
| **Concurrency** - If applicable | N/A | No concurrency behavior in scope. |
| **State Transitions** - If applicable | N/A | No stateful component in scope. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.30% lines / 84.66% branches -> Post-change: 92.30% lines / 84.66% branches. Change: +0.00% lines / +0.00% branches. New/changed-code coverage: N/A — only `tests/**` files changed, excluded from the denominator by policy. Disposition: PASS. Evidence: `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/coverage-comparison.2026-08-13T17-28.md` plus the reviewer's independent pytest run (exit 0, identical totals).
- TypeScript: Baseline: 96.57% lines / 89.90% branches -> Post-change: 96.57% lines / 89.90% branches. Change: +0.00% lines / +0.00% branches. New/changed-code coverage: N/A — no TypeScript files in the branch diff. Disposition: N/A. Evidence: `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/qa-gates/final-typescript-tests-coverage.2026-08-13T17-28.md`.
- PowerShell: N/A — no PowerShell files in the branch diff. Disposition: N/A. Evidence: `git diff --name-only fe0413d4..HEAD` contains no `.ps1`/`.psm1`/`.psd1` path.
- C#: N/A — no C# files in the branch diff. Disposition: N/A. Evidence: `git diff --name-only fe0413d4..HEAD` contains no `.cs` path.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Every assertion carries an f-string message naming the file and the substring or span, e.g. `Stale legacy gate substring present in {relative_path}: {forbidden}`. Mutant-probe failures produced immediately actionable messages naming the offending file and literal. |
| **Arrange-Act-Assert Pattern** | PASS | All seven new tests carry explicit `# Arrange` / `# Act / Assert` section comments matching the host files' existing convention. |
| **Document Intent** | PASS | Each new test has a Google-style docstring stating the scenario, the scoping rationale (file-scoped vs span-scoped), and why the scan is limited to the four variant files. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, subprocess, or temp-file use. Contract tests read tracked repository files; determinism tests are fully in-memory. |
| **Use Mocks/Stubs** | PASS | `RecordingFileSystem` in-memory doubles are used for both determinism tests, matching the established pattern in the host files. |
| **Environment Stability** | PASS | No temporary files created by any new test (the prohibition in `.claude/rules/general-unit-test.md` is honored); no environment variables or global state read. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy review for branch `bug/csharp-legacy-gate-command-correctness-469` prior to PR authoring. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #469 and `spec.md` define the defect (three non-executing C# gates in the `csharp-legacy` pack) and the corrected gate contract. |
| **Read existing change plans** | PASS | `evidence/other/phase0-instructions-read.md` records the eight policy files read in order before implementation. |
| **Document the plan** | PASS | `plan.2026-08-13T16-26.md` (revision 2) is the plan of record; all tasks are checked off with per-task evidence artifacts. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The fix is byte-level Markdown content correction; no engine, manifest, or routing change. The test additions use plain substring and regex-span assertions. |
| **Reusability** | PASS | The verbose 60-line seeding dict in the Codex customization test was extracted into `_seed_legacy_variant_tree` and reused by two tests; path constants were hoisted to module level. |
| **Extensibility** | PASS | Required/forbidden substring sets are module-level tuples, so future gate-contract changes are one-line edits. |
| **Separation of concerns** | PASS | Content contracts live in the two resource-contract files (real bytes); routing/determinism live in the end-to-end files (in-memory doubles) — exactly the division the spec's verification contract mandates. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Each test file extends its existing single concern; no new files created. |
| **Under 500 lines** | PASS | Post-change counts: `test_push_down_claude_resource_contracts.py` 432, `test_push_down_codex_and_agents_resource_contracts.py` 347, `test_push_down_claude_pack_end_to_end.py` 390, `test_push_down_codex_and_agents_customizations.py` 495 (compacted from 497 before the new test was added). All within the 500-line limit. |
| **Public vs internal** | PASS | New helpers are `_`-prefixed module internals. |
| **No circular dependencies** | PASS | Test modules import only `re`, `pathlib`, and their existing loaders; no new imports across modules. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `test_claude_legacy_variant_files_exclude_stale_gate_commands`, `_spans_with_both_literals`, `CODEX_LEGACY_VARIANT_FILES` — names state behavior and scope. |
| **Docs/docstrings** | PASS | Every new function and helper carries a Google-style docstring with Purpose/Args/Returns/Raises/Side Effects per `.claude/rules/self-explanatory-code-commenting.md`. |
| **Comment why, not what** | PASS | Comments explain rationale, e.g. the case-sensitivity comment ("the lowercase `msbuild` token appears only in command spans, while prose names the product `MSBuild`") and the artifact-root exclusion rationale in the determinism tests. Loop comprehensions carry intent comments. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `poetry run black --check .` (reviewer re-run)<br>**Result:** exit 0, 415 files unchanged. Executor final pass: `poetry run black .` exit 0. |
| **2. Linting** | PASS | **Command:** `poetry run ruff check .` (reviewer re-run)<br>**Result:** exit 0, all checks passed, zero suppressions added by this change. |
| **3. Type checking** | PASS | **Command:** `poetry run pyright` (reviewer re-run)<br>**Result:** exit 0, 0 errors. |
| **4. Testing** | PASS | **Command:** `poetry run pytest --cov --cov-branch --cov-report=term` (reviewer re-run)<br>**Result:** exit 0, 3781 passed, 5 pre-existing skips, 0 failed. |
| **Full toolchain loop** | PASS | Reviewer executed format -> lint -> type-check -> test in one sequence with no failures and no file changes: a single clean pass. Executor evidence records the same for its final Phase 4 loop, including the TypeScript verification stages (format, lint, typecheck, test:coverage all exit 0). |
| **Explicit reporting** | PASS | Commands and exit codes are recorded in this audit and in the 24 evidence artifacts under the feature folder. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | `spec.md` Proposed Fix and the traceability record (`evidence/other/traceability.2026-08-13T17-28.md`) summarize every change site. |
| **Design choices explained** | PASS | The spec records the rejected alternatives (file-wide nullable ban, line-scoped predicate, bare `/t:Build` literal) with rationale; Plan Note 2 documents the Codex pack-spelling decision. |
| **Update supporting documents** | PASS | `README.md` "Legacy VSTO C# (.NET Framework)" section updated to the corrected commands (AC15). |
| **Provide next steps** | PASS | Spec Rollout section: standard PR to `main`; downstream consumers re-run the push-down; the Codex default-slot defect remains a recorded follow-up. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check .`<br>**Result:** exit 0, no reformatting needed (reviewer re-run). |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check .`<br>**Result:** exit 0, zero findings; no `# noqa` added anywhere in the diff. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright`<br>**Result:** exit 0, 0 errors; all new functions fully annotated (`tuple[Path, ...]`, `tuple[str, ...]`, `list[str]`, `dict[str, str]`). No `Any`, no `# type: ignore` in the diff. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest --cov --cov-branch --cov-report=term`<br>**Result:** exit 0, 3781 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Every new constant, helper, and test function carries complete annotations; zero `Any`. |
| **Dataclasses for value objects** | N/A | No value objects introduced; module-level tuples of literals suffice. |
| **Protocols/ABCs for interfaces** | N/A | No new interfaces; existing `RecordingFileSystem` doubles reused. |
| **Avoid utility classes** | PASS | New helpers are module-level functions, not static-method classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No production error paths changed; tests use plain assertions with descriptive messages. |
| **Logging over print** | PASS | No `print` statements added. |
| **Invariants at construction** | N/A | No constructors added. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | All seven new tests are plain Pytest functions in existing Pytest modules; no fixtures or plugins added. |
| **Coverage expectation** | PASS | Repo-wide 92.30% lines / 84.66% branches against the uniform >= 85% / >= 75% gates; no new production code, so no new-code obligation arises. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One behavior per test; required-presence and forbidden-absence are separate functions; determinism is a separate function per engine. |
| **Mocking sparingly** | PASS | Only the pre-existing `RecordingFileSystem` in-memory double is used, and only where real filesystem writes would otherwise be needed. |
| **Organization** | PASS | Tests live in `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/` production modules, per the universal layout rule. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_<surface>_legacy_variant_files_<contain|exclude>_...`, `test_push_down_<engine>_repeated_generation_is_deterministic` — descriptive and parallel across surfaces. |
| **Docstrings/comments** | PASS | Every test documents scenario, scoping unit, and rationale; helper docstrings carry full Google-style sections. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py -q`<br>**Result:** 32 passed in 0.26s (reviewer re-run, post mutant-probe restore). |
| **No Alternative Test Runners** | PASS | Only Pytest is used. |

---

## 5. Test Coverage Detail

### Content-contract tests — Claude surface (3 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_claude_legacy_variant_files_contain_corrected_gate_commands | Positive | 2 files x 7 required substrings | PASS |
| test_claude_legacy_variant_files_exclude_stale_gate_commands | Negative | 2 files x 3 forbidden literals + span predicate | PASS |
| test_claude_modern_csharp_profile_retains_modern_gate_commands | Regression pin | 2 root files x 4 assertions | PASS |

**Coverage:** Content assertions are file-byte checks; production Markdown is outside the coverage denominator. Discrimination proven by fail-before evidence (4 failed / 0 passed pre-fix) and by the reviewer's `sln /t:Build` mutant, which the exclude test caught.

**Not covered:** The `README.md` legacy section (AC15) has no test by design — the spec scopes automated absence scans to the four variant files. Reviewer verified the README section manually (see feature audit AC15).

### Content-contract tests — Codex surface (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_codex_legacy_variant_files_contain_corrected_gate_commands | Positive | 2 files x 7 required substrings | PASS |
| test_codex_legacy_variant_files_exclude_stale_gate_commands | Negative | 2 files x 3 forbidden literals + span predicate | PASS |

**Coverage:** Discrimination proven by the reviewer's `/p:Nullable=enable` span-injection mutant, which the exclude test caught with the offending span named in the failure message.

**Not covered:** The Codex default-slot files are deliberately outside the scan scope (pre-existing defect recorded at `docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md`).

### Determinism tests (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_push_down_claude_repeated_generation_is_deterministic | Positive / idempotence | Two full generations compared as path->content maps | PASS |
| test_push_down_codex_repeated_generation_is_deterministic | Positive / idempotence | Two full generations compared as path->content maps | PASS |

**Not covered:** None beyond the doubles' inherent limits (synthetic content; real emitted text is covered by the contract tests, which is the spec's verification-contract division).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full Python suite) | 3781 passed, 5 skipped | PASS |
| Tests Failed | 0 | PASS |
| Execution Time (full suite) | 14.94s (reviewer run) | Fast |
| Affected-file subset | 32 tests in 0.26s | Fast |
| New tests added by this feature | 7 (5 contract + 2 determinism) | PASS |
| Test File Sizes | 432 / 347 / 390 / 495 lines (all <= 500) | PASS |
| Code Coverage | 92.30% lines, 84.66% branches | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | exit 0, 415 files unchanged | PASS |
| Ruff Linting | `poetry run ruff check .` | exit 0, all checks passed | PASS |
| Pyright Type Checking | `poetry run pyright` | exit 0, 0 errors | PASS |
| Pytest Tests | `poetry run pytest --cov --cov-branch --cov-report=term` | exit 0, 3781 passed / 5 skipped | PASS |

**Notes:**
The 5 skips are pre-existing parameterized skips in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` (cases that declare no accessor expectation), unrelated to this change and present at baseline. TypeScript checks were verification-only (no TypeScript file changed); executor evidence records exit 0 for `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:coverage`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Uncommitted working-tree evidence update (Advisory, pre-PR housekeeping).** `git status --porcelain` shows one modified file not in HEAD `d342c6c7`: `docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/evidence/issue-updates/issue-469.2026-08-13T17-28.md`, in which the orchestrator replaced the executor's `PostedAs: unknown` / posting-deferred header with the posted GitHub comment URL (issue #469 comment 5286830741). The change is correct and desirable, but it must be committed before PR authoring so the branch's evidence trail matches the posted state. Not a policy FAIL; the reviewed diff itself is clean.
- **Pre-existing evidence-location validator failures (housekeeping, not attributable to this branch).** Two untracked local files under `artifacts/research/` fail `validate_evidence_locations.py` (see Evidence Location Compliance). Both predate this branch, are outside the diff, and are not tracked by git, so they cannot ship in the PR. Recommended disposition: relocate or delete locally.

### Approved Exceptions

- **Struck requirement (owner decision, 2026-08-13):** the MSBuild binary-log / `CoreCompile`-execution-count proof from the originating handoff is excluded by owner decision recorded in `issue.md` and `spec.md` (this repository has no classic-MSBuild solution or harness). Its absence is intended; the reviewer confirmed no binlog or `CoreCompile` assertion exists anywhere in the diff.
- **Codex default-slot defect deferred:** `.agents/skills/csharp/SKILL.md` and `.agents/skills/csharp-qa-gate/SKILL.md` carry pre-existing classic-MSBuild content; correcting them would violate AC13 (default profile unchanged). Recorded for follow-up at `docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md`, which is included in this branch.

### Removed/Skipped Tests

**None.** All planned tests implemented. No test was removed, weakened, or skipped; the 5 suite-level skips are pre-existing and unrelated.

---

## 9. Summary of Changes

### Commits in This PR/Branch

Branch range `fe0413d4..d342c6c7` on `bug/csharp-legacy-gate-command-correctness-469` (single-feature branch; commit granularity follows the plan phases, with HEAD at `d342c6c7`).

### Files Modified

1. **extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md** (MODIFIED) — Toolchain steps 1-3 corrected (CSharpier subcommands + restore, `/t:Rebuild /m`, whole-argument platform token, nullable prohibition prose); line-83 severity-invariant cited fragment drops `/p:Nullable=enable`.
2. **extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md** (MODIFIED) — four-step gate sequence corrected; one explanation paragraph inserted covering `/t:Rebuild /m` rationale, CI `/t:Build` allowance, and per-file `#nullable enable` opt-in.
3. **extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md** (MODIFIED) — same steps-1-3 correction with `TaskMaster.sln`.
4. **extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md** (MODIFIED) — same four-step correction plus explanation paragraph with `TaskMaster.sln`.
5. **README.md** (MODIFIED) — "Legacy VSTO C# (.NET Framework)" format/analyze/nullable command lines rewritten to the corrected contract (AC15).
6. **tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py** (MODIFIED, +146) — constants plus three new tests (contain / exclude / modern pin).
7. **tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py** (MODIFIED, +110) — constants plus two new tests (contain / exclude).
8. **tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py** (MODIFIED, +72) — `_destination_map` helper plus Claude determinism test.
9. **tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py** (MODIFIED, +104/-106) — behavior-preserving compaction (`_seed_legacy_variant_tree`, path constants) plus Codex determinism test.
10. **docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/** (NEW) — issue.md, spec.md, plan, research, 24 evidence artifacts.
11. **docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md** (NEW) — out-of-scope defect record.
12. **docs/features/potential/promoted/2026-08-13-csharp-legacy-gate-command-correctness.md** (NEW) — promoted potential entry, reconstructed with an appended Restoration Note documenting the mid-session disappearance anomaly.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All policy gates pass on reviewer-executed evidence: the Python toolchain completes in one clean pass, coverage holds the uniform gates with zero regression, the content contract is independently verified against real bytes, both adversarial mutant probes were caught by the new tests, the diff contains no out-of-scope path, and no evidence artifact in the branch diff violates the canonical location invariant. Two housekeeping items are recorded in Section 8 (one uncommitted evidence-file update to commit before PR authoring; two pre-existing untracked local files outside the diff).

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective, plan, and policy reads evidenced
- ✅ Design Principles: minimal byte-level fix; test scaffolding reused
- ✅ Module & File Structure: all four test files <= 500 lines (495 max)
- ✅ Naming, Docs, Comments: full docstring and intent-comment compliance
- ✅ Toolchain Execution: single clean pass, reviewer-verified
- ✅ Summarize & Document: spec, README, traceability all updated

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python Tooling & Baseline: Black/Ruff/Pyright/Pytest all exit 0
- ✅ Python Design & Typing: fully annotated, zero Any, zero suppressions
- ✅ Python Error Handling: no error-path changes; no print statements

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, fast, deterministic, readable
- ✅ Coverage & Scenarios: 92.30% / 84.66% with zero regression; positive, negative, and boundary scenarios covered
- ✅ Test Structure: AAA with actionable failure messages
- ✅ External Dependencies: none; no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python Framework & Scope: Pytest only, gates met
- ✅ Python Test Style & Structure: focused, minimal mocking, mirrored layout
- ✅ Python Naming & Readability: descriptive parallel names, full docstrings
- ✅ Python Toolchain: verified by reviewer re-run

---

### Metrics Summary

- ✅ 3781/3781 tests passing (100%; 5 pre-existing skips)
- ✅ 7 new tests, all discriminating (fail-before evidence + 2 reviewer mutant probes caught)
- ✅ 92.30% line coverage, 84.66% branch coverage (gates: >= 85% / >= 75%)
- ✅ Zero coverage regression versus baseline
- ✅ All code quality checks passing in one pass
- ✅ Full-suite execution time 14.94s

---

### Recommendation

**Ready for merge**, conditional on one pre-PR housekeeping action: commit the working-tree update to `evidence/issue-updates/issue-469.2026-08-13T17-28.md` so the branch records the posted issue-comment URL. No remediation plan is required; no Blocking findings exist.

---

## Appendix A: Test Inventory

New tests added by this feature:

- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_legacy_variant_files_contain_corrected_gate_commands
- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_legacy_variant_files_exclude_stale_gate_commands
- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_modern_csharp_profile_retains_modern_gate_commands
- tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_contain_corrected_gate_commands
- tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_exclude_stale_gate_commands
- tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py::test_push_down_claude_repeated_generation_is_deterministic
- tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_push_down_codex_repeated_generation_is_deterministic

Pre-existing tests exercised as regression guards: test_variant_subtree_is_bundle_only_and_non_colliding, test_selected_legacy_csharp_writes_variant_content_to_canonical_paths (compacted, behavior unchanged), test_invalid_csharp_variant_pack_combination_fails_before_writes, plus the full 3781-test suite.

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

# Testing with coverage
poetry run pytest --cov --cov-branch --cov-report=term-missing

# Affected-file subset
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py -q
```

**For TypeScript (verification-only; no TypeScript change):**
```bash
cd extensions/drm-copilot
npm run format
npm run lint
npm run typecheck
npm run test:coverage
```

**Evidence-location scan:**
```bash
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
git diff --name-only fe0413d4..HEAD
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-08-13
**Policy Version:** Current (as of audit date)
