# Policy Compliance Audit: Standalone orchestration merge on green (Issue #997)

---

**Audit Date:** 2026-10-29
**Base Branch:** `main` (merge base `fd4fe5b2985f3caaaffb60d9dc393584e7750c3a`, equal to `origin/main`; the local `main` ref is stale and was not used)
**Head:** `bug/standalone-orchestration-merge-on-green-997` at `e8d649ac21f6cd2216613ddaccab9b49307568a8`
**Scope:** full branch diff `fd4fe5b2985f3caaaffb60d9dc393584e7750c3a..e8d649ac21f6cd2216613ddaccab9b49307568a8` (76 files, 3844 insertions, 42 deletions; two commits: `98c851059 feat(merge-gate): allow standalone merge after green CI` and `e8d649ac2 fix(merge-gate): decline --admin on the green-CI branch`).
**Review Type:** re-audit after a proportionate remediation cycle (prior review `2026-10-29T17-10`, verdict PASS).

**Code Under Test (non-documentation files):**

- PowerShell production (new): `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` (edited again by the remediation commit).
- PowerShell production (modified): `.claude/hooks/enforce-epic-merge-gate.ps1`; byte-identical bundle copies of both under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
- PowerShell tests (new): `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1`, `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` (edited again by the remediation commit), `enforce-epic-merge-gate.GreenCiRegression.Tests.ps1`.
- PowerShell tests (modified): `enforce-epic-merge-gate.Authorization.Tests.ps1`, `enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `enforce-epic-merge-gate.DocsOnly.Tests.ps1` (final deny-text pin only), `hook-dependency-failure.SpecialCases.Tests.ps1` (row C9).
- Python test support (modified): `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (one `MERGE_ON_GREEN_FRAGMENTS` entry; not touched by the remediation commit).
- JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one entry).
- Markdown runtime surfaces: `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, and their bundle copies.
- Documentation: the feature folder (issue, spec, plan, remediation plan, research, evidence, prior review artifacts).

**Remediation-cycle delta (`98c851059..e8d649ac2`):** stage C of `Get-EpicMergeGateGreenCiDecision` declines `--admin` silently; header and help text updated; four new decision rows (`--admin` in the command-shape table, `--admin` with a green checkpoint, `--squash`/`--rebase` still allow, valueless `--match-head-commit`); `orchestrator-state.md` item 1 lists `--admin`; one `parallel-orchestrate/SKILL.md` sentence aligned with the best-effort disclosure; spec AC-14 amended; three mirrors refreshed. No `.py` file changed in the cycle.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 production (+2 mirrors), 7 test | 12203 cases in the executor's full single-process `tests/scripts` run; 317 in the reviewer re-run of 13 repository suites | PASS 12193 passed, 0 failed, 10 skipped; reviewer 317 passed, 0 failed | repo-wide 92.93% lines (18349/19746) at the branch baseline; `enforce-epic-merge-gate.ps1` 100.00% (129/129) | repo-wide 92.95% lines (18410/19806); `enforce-epic-merge-gate.ps1` 100.00% (132/132) | `enforce-epic-merge-gate-green-ci.ps1` 100.00% (57/57) |
| Python | 0 production, 1 test-support | 7435 full suite (reviewer run at `98c851059`; no `.py` change since) plus 120 contract tests re-run at head | PASS 7429 passed, 6 skipped, 0 failed; contract re-run 120 passed | N/A for the test-support file (tests are excluded from measurement) | repo-wide 94.13% lines (16842/17893), 88.81% branches (5737/6460) | N/A (no production Python changed) |
| JSON | 1 manifest | push-down completeness and dependency-closure suites | PASS | N/A (config) | N/A | N/A |
| TypeScript | 0 | — | — | N/A (no changed files) | N/A | N/A |
| C# | 0 | — | — | N/A (no changed files) | N/A | N/A |
| Bash | 0 | — | — | N/A (no changed files) | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file in the branch diff).
- TypeScript post-change coverage artifact: N/A (no TypeScript file in the branch diff).
- PowerShell baseline coverage artifact: `FEATURE/evidence/baseline/pester-full-baseline.2026-10-29T16-24.md` (branch baseline) and `FEATURE/evidence/baseline/pester-full.2026-10-29T17-45.md` (remediation-cycle baseline, 92.95%).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (226 source files, LINE counter 18410 covered and 1396 not covered); its companion `artifacts/pester/pester-junit.xml` reports 12203 tests, 0 failures, 10 disabled, matching the executor's 12193-passed full single-process run in `FEATURE/evidence/qa-gates/pester-full.2026-10-29T19-10.md`. The artifact was written after the last edit to both hook files and the decision suite (file modification times checked).
- Python baseline coverage artifact: `FEATURE/evidence/baseline/python-dev-tools-baseline.2026-10-29T16-10.md` (test results; no production Python in scope).
- Python post-change coverage artifact: `artifacts/python/lcov.info` (217 `SF:` records) and `artifacts/python/coverage.json`, regenerated by the reviewer at `98c851059` in the prior review; reused because `git diff --name-only 98c851059 e8d649ac2 -- '*.py'` is empty.
- Per-language comparison summary: Section 1.2.1.

`FEATURE` denotes `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997`.

---

## Executive Summary

The branch implements issue #997: a standalone orchestration may merge its own pull request when its per-feature checkpoint records a green S9 gate for that exact pull request and the live head equals `ci_gate.head_sha`. The prior review passed with two Low and three Info observations. The remediation cycle closed three of them: the green-CI branch now declines `--admin`, a valueless `--match-head-commit` is pinned by a decision row, and the `parallel-orchestrate/SKILL.md` sentence matches the best-effort disclosure.

Reviewer verification at head `e8d649ac2`:

- Pester run of the 12 `enforce-epic-merge-gate*.Tests.ps1` suites plus `hook-dependency-failure.SpecialCases.Tests.ps1`: 317 passed, 0 failed.
- Reviewer adversarial probe (34 rows, scratchpad only, not committed): ten `--admin` spellings (trailing, leading, before the PR number, double- and single-quoted, `--admin=true`, `--ADMIN`, after `--`, newline-separated, combined with a matching `--match-head-commit`) all deny with zero live-head calls; twelve checkpoint fail-closed rows, eight command-shape rows, and the three suffix codes behave as specified. One row was denied by the green-CI branch but allowed by the pre-existing branch 1 (`epic_mode` as the string `"false"`); see Section 8 and the code review. It is not a regression from this branch.
- Parse of `artifacts/pester/powershell-coverage.xml`: repo-wide 92.95%; the sibling and the gate at 100.00%.
- PSScriptAnalyzer over the 11 changed PowerShell files (including mirrors): 0 findings. `Invoke-Formatter` would change none of them. Black, Ruff, Pyright on the changed Python file: clean.
- Python contract modules (seven, including `test_parallel_orchestrator_surface_contracts.py`): 120 passed.
- Codex generator `--check`: exit 0. `check_quality_tiers`: OK (26 entries).
- `cmp` mirror parity: 6 of 6 identical. Evidence-location validator: exit 0.
- Largest changed covered file: 476 logical lines.

No blocking finding was identified.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md` (prose matches the implementation, including the new `--admin` exclusion)

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md`
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` (no suppression added)
- PASS `.claude/rules/self-explanatory-code-commenting.md`
- N/A TypeScript, C#, Bash: no changed files

**Temporary artifacts cleanup:**
- PASS No temporary script is committed. Reviewer probe, launcher, and parsing scripts are in the session scratchpad.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope. The caller requested the "full feature-review-workflow skill contract end to end ... with no scope narrowing", and the full branch diff against the merge base was reviewed, not only the remediation commit.

Two caller instructions are method notes, not narrowing:

- "Use artifacts/pester/powershell-coverage.xml only if from a full single-process run (the executor reported 12193 tests)": the artifact's 226-file denominator and its companion JUnit total (12203 cases = 12193 passed + 10 disabled, 0 failures) confirm a full run, so it was used.
- "reuse the Python coverage from the earlier review only if no .py file changed since": no `.py` file changed between `98c851059` and `e8d649ac2`, so the prior reviewer-generated artifact was reused.

---

## Evidence Location Compliance

- `git diff --name-only origin/main...HEAD` filtered for `^artifacts/(baselines|qa|evidence|coverage)/`: no matches.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0.
- All committed evidence, including the remediation cycle's, is under `FEATURE/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`).

Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | `FEATURE/evidence/regression-testing/isolation.2026-10-29T19-20.md`: 11 merge-gate suites in one process with seeds 11, 23, 37 (245 passed each); `isolation-python.2026-10-29T18-35.md`: seven Python modules reversed (120 passed). |
| **Isolation** - Each test targets single behavior | PASS | The four new rows each assert one decision; `-ForEach` rows for the command-shape table and the `--squash`/`--rebase` pair. |
| **Fast Execution** - Tests complete quickly | PASS | All seams mocked; the decision suite runs in about 1.2 s (reviewer run). |
| **Determinism** - Consistent results | PASS | Fixed synthetic SHAs and `/synthetic-worktrees/<name>` roots; reviewer re-run 317 of 317 passed. |
| **Readability & Maintainability** - Clear structure | PASS | Arrange/Act/Assert comments in each new `It`; names state input and outcome. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `FEATURE/evidence/baseline/pester-full-baseline.2026-10-29T16-24.md`; remediation baseline `baseline/pester-full.2026-10-29T17-45.md`. |
| **No Coverage Regression** | PASS | Sibling 56/56 -> 57/57 (100.00%); gate 132/132 (100.00%); repo-wide 92.95% -> 92.95% (18409 -> 18410 covered). |
| **New Code Coverage >= 85% line, >= 75% branch** | PASS | New sibling 100.00% lines including the new `--admin` line; Pester measures no branch coverage, so no PowerShell branch gate applies. |
| **Comprehensive Coverage** | PASS | Every fail-closed row in AC-03 to AC-16 has a test, including the amended AC-14 `--admin` case. |
| **Positive Flows** - Valid inputs | PASS | Allow rows for plain merge, matching pin, matching `pr_gate.head_sha`; new `--squash` and `--rebase` allow rows. |
| **Negative Flows** - Invalid inputs | PASS | `--admin` rows; valueless `--match-head-commit` row; the existing checkpoint and command-shape rows. |
| **Edge Cases** - Boundary conditions | PASS | Valueless pin flag; `--admin` with an otherwise fully valid green checkpoint. Reviewer probe adds quoted, `=`-valued, upper-case, and after-`--` spellings. |
| **Error Handling** - Error paths | PASS | Unchanged live-head wrapper rows; C9 dependency-failure row. |
| **Concurrency** - If applicable | N/A | The push-after-lookup race is disclosed and mitigated by `--match-head-commit` in prose; not testable at unit level. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.93% lines repo-wide (18349/19746) at the branch baseline, 92.95% (18409/19805) at the remediation baseline -> Post-change: 92.95% lines repo-wide (18410/19806). Change: +0.02 points against the branch baseline, no change against the remediation baseline. New/changed-code coverage: 100% (new file `enforce-epic-merge-gate-green-ci.ps1` 57/57 lines; modified `enforce-epic-merge-gate.ps1` 132/132 lines, 100.00% at baseline and after). No branch gate applies (Pester). Thresholds: root `CLAUDE.md` states none, so the 85% line default governs and is met. Disposition: PASS. Evidence: reviewer parse of `artifacts/pester/powershell-coverage.xml`; `FEATURE/evidence/qa-gates/pester-full.2026-10-29T19-10.md`.
- Python: Baseline: no production Python in scope; the only changed file is test support under `tests/`, which is excluded from measurement -> Post-change: repo-wide 94.13% lines (16842/17893) and 88.81% branches (5737/6460). Change: no production line changed. New/changed-code coverage: 100% (zero production lines changed, so every changed production line is covered vacuously). Thresholds 85% line and 75% branch (defaults) met repo-wide. Disposition: PASS. Evidence: `artifacts/python/coverage.json` and `artifacts/python/lcov.info` (217 source files), reviewer-generated at `98c851059`; no `.py` change since.
- TypeScript: no changed files. Disposition: N/A. Evidence: the branch diff contains no `.ts` file.
- C#: no changed files. Disposition: N/A. Evidence: the branch diff contains no `.cs` file.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `-Because` carries the decision reason or the command text in the new rows. |
| **Arrange-Act-Assert Pattern** | PASS | Each new `It` has the three commented sections. |
| **Document Intent** | PASS | `It` names cite issue #997 and the expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | `Invoke-DocsOnlyGhExe` and `Get-EpicMergeGateLivePrHeadSha` are mocked; no network. |
| **Use Mocks/Stubs** | PASS | The new rows reuse `Set-GreenCiCheckpoint` and the suite-level mocks. |
| **Environment Stability** | PASS | No `New-TemporaryFile`, `TestDrive`, `Start-Process`, or file writes in the new rows (diff read). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy audit for head `e8d649ac2`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `remediation-plan.2026-10-29T18-00.md` items R1 to R3, derived from the prior review's observations. |
| **Read existing change plans** | PASS | `FEATURE/evidence/baseline/phase0-instructions-read.2026-10-29T17-13.md`. |
| **Document the plan** | PASS | `remediation-plan.2026-10-29T18-00.md`, all tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One line in stage C: a silent `return` when `Test-CommandLineFlag` reports `--admin`. |
| **Reusability** | PASS | Reuses the shared `Test-CommandLineFlag` parser already used for `--match-head-commit`. |
| **Extensibility** | PASS | Decision contract `[ordered]@{ Allowed; Suffix }` unchanged. |
| **Separation of concerns** | PASS | The decline is a pure stage before the single I/O stage. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | All green-CI logic remains in the sibling. |
| **File size (tiered policy)** | PASS | Reviewer logical line counts (`@(Get-Content).Count`): `enforce-epic-merge-gate.ps1` 476, `enforce-epic-merge-gate-green-ci.ps1` 325, `parallel_orchestrator_surface_expectations.py` 394, `GreenCiDecision.Tests.ps1` 329, `GreenCi.Tests.ps1` 267, `hook-dependency-failure.SpecialCases.Tests.ps1` 247, `DocsOnly.Tests.ps1` 216, `MergeQueue.Tests.ps1` 204, `Authorization.Tests.ps1` 183, `GreenCiRegression.Tests.ps1` 109; mirrors equal their sources. None at or above 500. `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | PASS | `.claude/settings.json` unchanged. |
| **No circular dependencies** | PASS | The sibling dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | New `It` names state the input and decision. |
| **Docs/docstrings** | PASS | Header stage C line and the function `.SYNOPSIS` mention the `--admin` decline. |
| **Comment why, not what** | PASS | "--admin bypasses branch protection, so a green checkpoint must not authorize it." |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Executor: `qa-gates/format.2026-10-29T18-30.md` (tree observation, no rewrite). Reviewer: `Invoke-Formatter` with repo settings would change 0 of 11 files; Black `--check` unchanged. |
| **2. Linting** | PASS | Reviewer: PSScriptAnalyzer 0 findings over 11 files; Ruff "All checks passed!". |
| **3. Type checking** | PASS | Reviewer: Pyright 0 errors on the changed Python file. PowerShell: N/A. |
| **4. Architecture-boundary tests** | PASS | `check_quality_tiers` OK (reviewer); `qa-gates/boundary-contract-stages.2026-10-29T16-39.md`. |
| **5. Unit tests** | PASS | Executor full Pester 12193 passed, 0 failed; reviewer 13 repository suites 317 passed. |
| **6. Contract / schema checks** | PASS | Reviewer: seven contract modules 120 passed; Codex generator `--check` exit 0. |
| **7. Integration tests** | PASS | Decisions driven through `Invoke-EpicMergeGateDecision`; C9 runs the hook as a process. The live post-merge check is deferred by design (AC-32). |
| **Full toolchain loop** | PASS | Remediation P5 evidence for each stage; reviewer re-runs clean. |
| **Explicit reporting** | PASS | Appendix B and the evidence folder. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `e8d649ac2` message lists the four changes. |
| **Design choices explained** | PASS | `remediation-plan.2026-10-29T18-00.md` design decisions; spec AC-14 amended. |
| **Update supporting documents** | PASS | `orchestrator-state.md` item 1 and the spec updated with mirrors. |
| **Provide next steps** | PASS | `spec.md` `## Rollout & Follow-up`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: PowerShell Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PowerShell 7+ compatibility** | PASS | PSScriptAnalyzer with repo settings: 0 findings (reviewer). |
| **Baseline captured** | PASS | `FEATURE/evidence/baseline/pester-full.2026-10-29T17-45.md`. |

#### 3A.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | No new function; the edited function keeps `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | PASS | Unchanged. |
| **Seams** | PASS | No new process call; the `--admin` decline precedes the stage D seam. |
| **Hook dependency guard** | PASS | Unchanged; row C9 passes in the reviewer run. |
| **No state-changing action without ShouldProcess** | N/A | The function reads and compares only. |

#### 3A.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Approved verbs** | PASS | No new function. |
| **Comment-based help** | PASS | `.SYNOPSIS` updated. |

#### 3A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format -> analyze -> test** | PASS | `qa-gates/format.2026-10-29T18-30.md` -> `analyze.2026-10-29T18-30.md` -> `pester-full.2026-10-29T19-10.md`; reviewer re-runs. |
| **Change budget** | PASS | One production PowerShell file edited in the cycle. |

### Section 3B: Python Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`<br>**Result:** 1 file would be left unchanged. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <same file>`<br>**Result:** All checks passed! |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <same file>`<br>**Result:** 0 errors, 0 warnings, 0 informations. |

#### 3B.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Type hints** | PASS | The changed line extends an annotated `tuple[str, ...]` constant. |

### Section 3C: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Valid JSON and entry placement** | PASS | `core.json` lists the new hook; completeness and dependency-closure tests pass in the reviewer contract run. |

### Section 3D: TypeScript, C#, Bash

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Applicable** | N/A | No `.ts`, `.cs`, `.sh`, or `.bats` file changed. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: PowerShell Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester 5** | PASS | `#Requires` Pester 5.0.0; run via `Invoke-PoshQCTest` (executor) and `Invoke-Pester` (reviewer). |
| **Location mirrors source** | PASS | `tests/scripts/claude-hooks/` mirrors `.claude/hooks/`. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **One behavior per `It`** | PASS | Each new row asserts one decision. |
| **Mocking rules** | PASS | `gh` never mocked directly; `Get-EpicMergeGateLivePrHeadSha` asserted with `Should -Invoke -Times 0 -Exactly`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive `It` names** | PASS | The full run includes `test-name-uniqueness.Tests.ps1` with 0 failures. |

### Section 4B: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | PASS | The fragment is consumed by `test_parallel_orchestrator_surface_contracts.py`; reviewer contract run 120 passed. |

---

## 5. Test Coverage Detail

### Remediation-cycle rows (`enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`)

| Test | Scenario | Status |
|------|----------|--------|
| command-shape row `--admin` | `gh pr merge 42 --merge --admin` denies; zero live-head calls | PASS |
| `--admin` with a valid green checkpoint | Falls through to the unchanged `STANDALONE_MERGE_AUTHORIZATION_ABSENT` deny; no `GREEN_CI` suffix; zero live-head calls | PASS |
| `--squash`, `--rebase` | Still allow with a green checkpoint | PASS |
| valueless `--match-head-commit` | Denies with `GREEN_CI_MATCH_HEAD_MISMATCH` | PASS |

### Pre-existing branch rows

| Test | Scenario | Status |
|------|----------|--------|
| Pure checks (`GreenCi.Tests.ps1`) | `ci_gate`, `step9_status`, `pr_gate.pr_number`, `epic_mode`, `head_sha`, live-head wrapper outcomes | PASS |
| Decision (`GreenCiDecision.Tests.ps1`) | Allow rows, suffix codes, target and checkpoint declines, parallel layers 1a/1b/2, command shape, stage ordering | PASS |
| Regression (`GreenCiRegression.Tests.ps1` and existing suites) | Branch 1, parallel, #670, docs-only, merge queue | PASS |

---

## 6. Test Execution Metrics

| Metric | Value |
|--------|-------|
| Pester full single-process run (executor) | 12203 cases: 12193 passed, 0 failed, 10 skipped |
| Pester merge-gate suites + C9 suite (reviewer) | 317 passed, 0 failed |
| Reviewer adversarial probe (not committed) | 34 rows: 33 matched expectation; 1 pre-existing branch-1 allow (Section 8) |
| Pester seeded shuffles (executor, seeds 11, 23, 37, 11 suites) | 245 passed each |
| Python contract modules (reviewer, at head) | 120 passed |
| Python full suite (reviewer, at `98c851059`) | 7429 passed, 6 skipped, 0 failed |
| PowerShell line coverage (repo-wide) | 92.95% (18410 of 19806) |
| Python line / branch coverage (repo-wide) | 94.13% / 88.81% |

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|-------|--------|----------|
| PSScriptAnalyzer | PASS | 0 findings, 11 files (reviewer direct run) |
| Formatter drift | PASS | `Invoke-Formatter` output equals source for 11 files (reviewer) |
| Black / Ruff / Pyright | PASS | Reviewer runs on the changed Python file |
| Mirror parity | PASS | `cmp`: 6 `.claude` files identical to their bundle copies |
| Codex generator `--check` | PASS | exit 0 (reviewer) |
| Quality tiers | PASS | `quality-tiers.yml` exists on the base; `check_quality_tiers`: OK (26 entries, 26 discovered projects). `.claude/hooks` is T3. |
| Coverage exclusions | PASS | No change to `config/poshqc-coverage.json` or `pyproject.toml`. |
| Forbidden-path scope | PASS | `git diff --name-only origin/main...HEAD` lists nothing under `config/`, `pyproject.toml`, `.claude/settings.json`, `.codex`, or `.claude/skills/epic-orchestrate`. |

---

## 8. Gaps and Exceptions

### Identified Gaps

- Low (code review, pre-existing, not introduced by this branch): `Test-ChildCheckpointAllowsEpicMerge` (branch 1) coerces `epic_mode` with `[bool]`, so the string `"false"` is truthy and a checkpoint with `epic_mode: "false"` and `step9_status: "passed"` is allowed by branch 1 before the green-CI branch runs. The green-CI branch itself declines this input (AC-11), and AC-17 requires branch 1 to stay unedited. The input gives no access beyond what `epic_mode: true` already gives branch 1.
- Low (code review, carried forward): an unparseable parallel-orchestrator checkpoint is skipped by the run resolver, so layers 1a and 1b treat it as no record. Within the disclosed best-effort exclusion.
- Low (code review): remediation-cycle evidence file names carry timestamps from `18-05` to `19-30`, later than the commit time (17:51 UTC) and the time of this review (17:56 UTC); the file-size artifact used `wc -l` rather than a logical line count. The reviewer reproduced the recorded results independently.
- AC-31 is pending CI by design; AC-32 is a deferred post-merge live check and is not claimed.

### Approved Exceptions

- Python coverage artifact reuse. `artifacts/python/lcov.info` and `coverage.json` were generated by the reviewer at `98c851059` (prior review); `git diff --name-only 98c851059 e8d649ac2 -- '*.py'` is empty, so the figures describe the head's Python tree. Contract modules were re-run at head (120 passed).
- PowerShell coverage artifact reuse. `artifacts/pester/powershell-coverage.xml` (written 13:47 local) postdates the last edits to both hook files (13:31) and the decision suite (13:33); its JUnit companion confirms a full single-process run (12203 cases, 0 failures). The reviewer's independent run of the merge-gate suites passed 317 of 317.

### Removed/Skipped Tests

- No test was removed. The 10 Pester and 6 Python skips are pre-existing and outside the branch's suites.

---

## 9. Summary of Changes

### Commits in This PR/Branch

- `98c851059` feat(merge-gate): allow standalone merge after green CI
- `e8d649ac2` fix(merge-gate): decline --admin on the green-CI branch

### Files Modified

- Production: 1 new hook sibling, 1 modified hook, 2 bundle copies.
- Tests: 3 new Pester suites, 4 modified Pester suites, 1 modified Python test-support module.
- Runtime Markdown: 2 rules and 2 skills, plus their bundle copies; `core.json`.
- Documentation: feature folder (issue, spec, plan, remediation plan, research, evidence, prior review artifacts).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policy checks pass. Observations are Low or Info only.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

- PASS: design, structure, naming, file size, and the seven-stage toolchain.

#### Language-Specific Code Change Policy (Section 3)

- PASS: PowerShell, Python, JSON; N/A: TypeScript, C#, Bash.

#### General Unit Test Policy (Section 1)

- PASS: principles, coverage (PowerShell PASS, Python PASS), scenarios, and environment.

#### Language-Specific Unit Test Policy (Section 4)

- PASS: Pester and Pytest.

### Metrics Summary

| Metric | Value |
|--------|-------|
| Blocking findings | 0 |
| Non-blocking findings | 3 Low, 1 Info (code review) |
| New-file coverage (lines) | PowerShell 100.00% |
| Largest changed covered file | 476 lines |

### Recommendation

Proceed to the PR creation gate. AC-31 remains pending CI and is checked off by the item's own orchestrator run at S9; AC-32 is a deferred post-merge verification.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1` (new)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` (new; four rows added by the remediation cycle)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` (new)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` (deny-text pin)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` (deny-text pin)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` (deny-text pin)
- `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` (row C9)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (one fragment)

---

## Appendix B: Toolchain Commands Reference

```powershell
# Linting and format drift (reviewer, 11 changed PowerShell files)
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information
Invoke-Formatter -ScriptDefinition <source> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Tests (reviewer: 12 enforce-epic-merge-gate*.Tests.ps1 suites, hook-dependency-failure.SpecialCases.Tests.ps1, scratchpad probe)
Invoke-Pester -Configuration <Run.Path = the suites>
```

```bash
# Python
poetry run black --check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run pyright tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
poetry run python -m pytest -q -p no:cacheprovider --no-cov <seven contract modules>

# Contracts and scope
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python -m scripts.dev_tools.check_quality_tiers
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```
