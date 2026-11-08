# Policy Compliance Audit: Preimplementation gate demands a checkpoint for a merged-feature follow-up (#1141)

**Audit Date:** 2026-11-08
**Code Under Test:** merge base `5c81af727d0c4c85b893d6542356c47123454117` of `origin/main` and reviewed head `d5961781e56f83046f76b7ab4d131ef8cb498d44`; the diff between them lists the changed files (43 paths, 2155 insertions, 103 deletions). The head includes merge commit `d5961781e` of `origin/main` (#1138); the merge base equals the `origin/main` tip after `git fetch origin main`, so #1138 content is outside the reviewed range.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 8 production (2 hooks x 4 copies, of which 4 are measured live copies), 3 test | 20484 | PASS 20474 pass, 0 fail, 10 disabled | 95.66% lines | 95.67% lines | 100% (54/54 changed lines per fan-in copy, 3/3 per epic-scope file) |
| Python | 1 test-support file | 16566 | PASS 16560 pass, 0 fail, 6 skipped | 97.11% lines, 94.36% branches | 97.11% lines, 94.37% branches | N/A - no Python production file changed |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-08T19-20.md` (Phase 0 baseline, 95.66%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (rewritten by the reviewer's full `Invoke-PoshQCParallelTest` run at head `d5961781e`; root LINE 36347 covered, 1644 missed); executor final gate `evidence/qa-gates/pester-final.2026-11-08T20-03.md`
- Python baseline coverage artifact: `evidence/baseline/pytest-baseline.2026-11-08T19-24.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (totals recomputed by the reviewer: 34296 of 35317 lines, 12649 of 13404 branches); executor final gate `evidence/qa-gates/pytest-final.2026-11-08T20-06.md`
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are recorded for PowerShell and Python, the two languages with changed files.

---

## Executive Summary

The branch adds an allow-only merged-feature follow-up disjunct to the epic-scope decision of the preimplementation gate on the Claude and Codex surfaces, implemented in `hook-epic-fan-in.ps1` by generalizing the #1136 shape and staged-index predicates. The review verified the four focus properties directly: (1) the allowance is bounded to `features[]` entries of the epic checkpoint with a terminal status, a plain slug, a well-formed `merge_commit_sha`, and an integer `pr_number`, and it reads no per-item checkpoint; (2) the disjunct can only return `''`, no existing test file was modified, and the full Pester suite passes at head; (3) the allowance calls `Get-EpicFanInAllowance` rather than duplicating it, and the Claude and Codex disjuncts are textually equivalent; (4) all hook, skill, brief, and bundle copies are byte-identical where required and the pin equals the head blob digest. No blocking finding.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`
- PASS `quality-tiers.md` (`quality-tiers.yml` exists; `.claude/hooks` and `.codex/hooks` are classified T3)
- PASS `tonality.md` (added skill and brief text)

**Language-specific policies evaluated:**
- PASS `powershell.md` (code and unit test)
- PASS `python.md` (one test-support constant)
- N/A TypeScript, C#, Bash, JSON: zero changed files

The reviewer re-ran the PowerShell gate at the merged head (20484 tests, 0 failures, 95.67% repo-wide lines), seven Python contract modules with `pytest -n auto` (105 passed), the Codex generator `--check` (exit 0), and the evidence-location validator (exit 0), and probed the allowance in process with 24 adversarial inputs.

**Temporary artifacts cleanup:**
- PASS `git status --porcelain` was empty at the reviewed head before this review wrote its artifacts.
- PASS Reviewer scripts (`pester-full.sh`, `pytest-contracts.sh`, `evid.sh`, `probe.ps1`, `cov.py`) live in the session scratchpad outside the repository.

---

## Rejected Scope Narrowing

None detected. The caller's instruction to anchor the diff on the merge base of `origin/main` and HEAD matches the legitimate scope source (`pr-base-branch-merge-base`, `artifacts/pr_context.summary.txt` Range `5c81af727..d5961781e`). Every language with changed files carries an explicit verdict below.

## Evidence Location Compliance

No branch-diff file lies under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` run from the worktree root exited 0. Feature evidence is under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`. No EVIDENCE_LOCATION_OVERRIDE_REJECTED event.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Mocks registered per `Context` `BeforeEach`; no shared mutable state; full suite green across 8 parallel shards |
| **Isolation** - Each test targets single behavior | PASS | One decision per `It`; `-ForEach` tables name each case |
| **Fast Execution** - Tests complete quickly | PASS | Pure-function rows and mocked gate rows; no sleeps or waits |
| **Determinism** - Consistent results | PASS | Synthetic `/synthetic-worktrees/` roots, mocked resolver and staged-index seams, SHA values built by string repetition |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive names; Arrange/Act/Assert comments in the gate suites; `-Because` carries the decision reason |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | PowerShell 95.66% lines; fan-in 100% (91/91) per copy; epic-scope 97.60% Claude, 97.92% Codex (Phase 0 baseline) |
| **No Coverage Regression** | PASS | PowerShell 95.67% at head; fan-in 100% (136/136); epic-scope 97.66% and 97.96%; Python lines equal, branches +0.01 |
| **Changed Files Meet Thresholds** | PASS | All four measured PowerShell files at or above 97.66% against the 85% line threshold; the branch threshold does not apply to PowerShell |
| **New Code Coverage >=90%** | PASS | 54 of 54 changed lines in each `hook-epic-fan-in.ps1` copy and 3 of 3 in each epic-scope file; the missed lines (131-133 Claude, 119-121 Codex) are outside the diff |
| **Comprehensive Coverage** | PASS | Unit rows for `Get-EpicMergedFeatureRoots`, `Test-EpicMergedFeaturePath`, `Get-EpicMergedFeatureFollowUpAllowance`, and the generalized shape, staged-index, and allowance functions |
| **Positive Flows** | PASS | Bare and prefixed folders, JSON-parsed 64-char SHA, `[long]` PR number, path, add, commit, and pathless allows on both surfaces |
| **Negative Flows** | PASS | Each qualification conjunct refused; non-qualifying features, code paths, flags, and mixed or empty indexes denied |
| **Edge Cases** | PASS | Bare root, root without slash, sibling prefix, status doc plus remainder, empty and blank root lists, `--` without operand, blank staged name |
| **Error Handling** | PASS | Throwing reader and unreadable `route_id` answer not allowed with `allowance error:` detail |
| **Concurrency** | N/A | Pure functions with no concurrent behavior |
| **State Transitions** | N/A | No stateful component |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.66% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.67% lines. Change: +0.01% lines. New/changed-code coverage: 100% (54 of 54 changed lines per fan-in copy, 3 of 3 per epic-scope file). Disposition: PASS. Evidence: `evidence/baseline/pester-baseline.2026-11-08T19-20.md`, `evidence/qa-gates/pester-final.2026-11-08T20-03.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 97.11% lines, 94.36% branches (from the `Phase 0 baseline` artifact) -> Post-change: 97.11% lines, 94.37% branches. Change: +0.00% lines, +0.01% branches. New/changed-code coverage: No Python production file changed; the one edited file is a test-support constant. Disposition: PASS. Evidence: `evidence/baseline/pytest-baseline.2026-11-08T19-24.md`, `evidence/qa-gates/pytest-final.2026-11-08T20-06.md`, `artifacts/python/lcov.info`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Allow rows put the decision reason in `-Because`; deny rows name the case |
| **Arrange-Act-Assert Pattern** | PASS | Explicit section comments in both gate suites |
| **Document Intent** | PASS | File-level `.SYNOPSIS` and `.DESCRIPTION` in both new test files |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No git, gh, network, or process calls in tests; the AST row reads the hook file only |
| **Use Mocks/Stubs** | PASS | Resolver seams inside `EpicScopeResolution`, `Get-OrchestrationGateStagedIndex`, and injected reader script blocks |
| **Environment Stability** | PASS | No temporary files; leak scan 0 failures with no allowlist change (`evidence/qa-gates/powershell-static.2026-11-08T19-53.md`) |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit is the required review artifact |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md` (Approved) and `research/research.2026-11-08T19-00.md` |
| **Read existing change plans** | PASS | `plan.2026-11-08T13-26.md`; preflight fixes recorded |
| **Document the plan** | PASS | Per-task commits tagged `[Pn-Tm]` |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One allow-only `if` per surface; two small pure functions plus a composing function |
| **Reusability** | PASS | `Get-EpicFanInAllowance` reused through optional predicates; no parser duplicated |
| **Extensibility** | PASS | Predicate parameters are a general seam; defaults keep #1136 behavior |
| **Separation of concerns** | PASS | Pure decision logic; the staged-index read stays behind the injected reader |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Both epic-scope allowances share one pure file |
| **At or below the 800-line hard limit** | PASS | Logical lines: `hook-epic-fan-in.ps1` 488 (four copies), epic-scope 402 Claude and 462 Codex (with bundles), unit tests 473, new gate tests 296 and 186, pin module 466. None at or above 700; `config/file-size-baseline.json` unchanged |
| **Public vs internal** | PASS | New functions are consumed by the epic-scope decision and tests only |
| **No circular dependencies** | PASS | No new dot-source or import |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Get-EpicMergedFeatureRoots`, `Test-EpicMergedFeaturePath`, `Get-EpicMergedFeatureFollowUpAllowance` |
| **Docs/docstrings** | PASS | Comment-based help on each new function; file header updated |
| **Comment why, not what** | PASS | The scope-chain comment explains why the predicate can see the roots |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Invoke-Formatter check: 0 drift in 11 files; Black check clean (final static artifacts) |
| **2. Linting** | PASS | PSScriptAnalyzer 0 findings; Ruff clean; one justified `PSUseSingularNouns` suppression |
| **3. Type checking** | PASS | Pyright 0 errors on the changed Python file; not applicable to PowerShell |
| **4. Testing** | PASS | Reviewer Pester at head 20484 tests, 0 failures; executor pytest 16560 passed, 0 failed |
| **Full toolchain loop** | PASS | Final static loop completed without restart |
| **Explicit reporting** | PASS | Commands and results in `evidence/qa-gates/` |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Section 9; commit messages |
| **Design choices explained** | PASS | `spec.md` Design summary; research design (A) |
| **Update supporting documents** | PASS | epic-orchestrate and orchestrate skills (four copies each) and the six brief copies |
| **Provide next steps** | PASS | PR authoring and CI at S9 |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

PASS. The only Python change is the `PINNED_FROZEN_SURFACE_HASHES` digest and a comment block in a test-support module; Black, Ruff, and Pyright are clean (`evidence/qa-gates/python-static.2026-11-08T19-53.md`). No Python file was added.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | 0 drift in 11 changed files |
| **Linting with PSScriptAnalyzer** | PASS | 0 findings with the repository settings |
| **Fix all findings** | PASS | The one finding was resolved with a justified suppression before the final loop |
| **PowerShell 5.1 & 7.6+ compatible** | N/A | Hook files are PowerShell 7 only by repository policy |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]` and `[OutputType()]` on each new function |
| **Parameter validation** | PASS | `AllowNull`, `AllowEmptyString`, `AllowEmptyCollection` attributes; inputs type-checked in the body |
| **Avoid global state** | PASS | No new script-scope variable |
| **Error handling** | PASS | `try`/`catch` answers not allowed with detail |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | PASS | Largest changed PowerShell file 488 logical lines |
| **Approved verbs** | PASS | `Get-` and `Test-` only |
| **Comment why** | PASS | Rationale comments only |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Final static artifact |
| **Step 2: Analyze** | PASS | Final static artifact |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | Reviewer `Invoke-PoshQCParallelTest` at head: ExitCode 0 |
| **Rerun loop if needed** | PASS | No restart needed |

### Documentation Surface Check

N/A. `docs/documentation-estate/docs-profile.json` is absent at the head, so the check produces no finding.

### Tier classification

PASS. `quality-tiers.yml` exists at the root on the base branch; the changed production files are under `.claude/hooks` and `.codex/hooks`, both classified T3.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

PASS. Executor `pytest -n auto` 16560 passed, 0 failed; reviewer `pytest -n auto` over the seven contract modules named in AC19 passed 105 of 105 at the merged head.

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | PASS | `BeforeAll`, `BeforeEach`, `Describe`/`Context`/`It`, `-ForEach` |
| **Use PoshQC Configuration** | PASS | `Invoke-PoshQCParallelTest` only |
| **PowerShell 5.1 & 7.6+ Compatible** | N/A | PowerShell 7 only |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | Function-level contexts in the unit file; decision-level rows in the gate files |
| **Test Behavior Over Implementation** | PASS | Gate rows assert decisions and deny text |
| **Mocking Used Sparingly** | PASS | Only resolver and staged-index seams |
| **Organization** | PASS | Hook tests in `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, the established locations for these hooks |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | Both new files end in `.Tests.ps1` |
| **Describe/Context/It Structure** | PASS | Grouped by function and outcome |
| **Logical Grouping** | PASS | `fail-before`, `allows`, `already admitted`, `denies` contexts |
| **Docstrings/Comments** | PASS | Header help and per-helper comments |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Reviewer run: 20484 tests, 0 failures |
| **No Alternative Test Runners** | PASS | No other runner used for evidence |

---

## 5. Test Coverage Detail

### hook-epic-fan-in.ps1 (both surface copies)

Coverage at head: 136 of 136 lines in each of the `.claude` and `.codex` copies; changed lines 54 of 54. Rows: `Get-EpicMergedFeatureRoots` (3 positive folder forms, JSON and `[long]` rows, 18 refusals, null and absent inputs, non-plain epic slug), `Test-EpicMergedFeaturePath` (3 admits, 14 refusals, empty and blank roots), generalized predicates (2 shape admits, 6 shape refusals, 5 staged-index rows), `Get-EpicMergedFeatureFollowUpAllowance` (4 allows, index-not-read row, 5 refusals, reader error, null scope and unreadable route, AST scan).

**Not covered:** None.

### enforce-orchestration-preimplementation-gate-epic-scope.ps1 (Claude and Codex)

The new disjunct (3 lines per surface) is covered. Pre-existing uncovered lines 131-133 (Claude) and 119-121 (Codex) are outside the diff and unchanged from baseline.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 20484 Pester, 16566 pytest | PASS |
| Tests Passed | 20474 Pester (10 disabled), 16560 pytest (6 skipped) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 609.83 s Pester (8 workers); 165.24 s pytest | PASS |
| Average Time per Test | N/A (parallel gate) | N/A |
| Discovery Time | N/A (parallel gate) | N/A |
| Functions/Classes Tested | 3 of 3 new functions and 4 of 4 generalized functions | PASS |
| Test File Size | 473 logical lines largest | PASS |
| Code Coverage (if applicable) | 95.67% PowerShell lines; 97.11% Python lines, 94.37% Python branches | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | Invoke-Formatter check over 11 files | 0 drift | PASS |
| PSScriptAnalyzer | Invoke-ScriptAnalyzer with repository settings | 0 findings | PASS |
| Pester Tests | `Invoke-PoshQCParallelTest -Root .` | 20484 tests, 0 failures | PASS |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` on the changed file | unchanged | PASS |
| Ruff Linting | `poetry run ruff check` on the changed file | clean | PASS |
| Pyright Type Checking | `poetry run pyright` on the changed file | 0 errors | PASS |
| Pytest Tests | `poetry run pytest -n auto` | 16560 passed | PASS |

**Notes:**
Format, lint, and type results are read from the final static artifacts and were not re-run by the reviewer. The merge of `origin/main` changed no PowerShell file of this branch's diff.

## CI Cross-check

No pull request exists for the branch yet; the rows record the local evidence the review relies on, and CI confirmation is pending-CI at S9.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| `poshqc / PowerShell QC` tests | pass | 20484 tests, 0 failed, 95.67% lines | d5961781e56f83046f76b7ab4d131ef8cb498d44 | reviewer `Invoke-PoshQCParallelTest`; `artifacts/pester/powershell-coverage.xml` |
| `poshqc / PowerShell QC` static | pass | 0 drift, 0 findings, 0 leak failures | fb777b19ef5c093689eab2e791e3e66f1f70b739 | `evidence/qa-gates/powershell-static.2026-11-08T19-53.md` |
| `Enforce Python coverage thresholds` | pass | 97.11% lines, 94.37% branches | fb777b19ef5c093689eab2e791e3e66f1f70b739 | `evidence/qa-gates/pytest-final.2026-11-08T20-06.md`; `artifacts/python/lcov.info` |
| `quality-checks7 / Code Quality & Tests (3.13)` | pass | 16560 passed, 0 failed | fb777b19ef5c093689eab2e791e3e66f1f70b739 | `evidence/qa-gates/pytest-final.2026-11-08T20-06.md` |
| Contract modules and Codex generator (reviewer) | pass | 105 passed; generator exit 0 | d5961781e56f83046f76b7ab4d131ef8cb498d44 | reviewer `pytest -n auto`; `generate_codex_agent_variants --check` |

Head `fb777b19e` differs from `d5961781e` only by the merge of `origin/main` (#1138 files and the combined pin digest).

---

## 8. Gaps and Exceptions

### Identified Gaps
**None.** All policy requirements are met. CI confirmation on the PR head is pending-CI and is not a finding.

### Approved Exceptions
**None.** No exceptions needed. The `PSUseSingularNouns` suppression on `Get-EpicMergedFeatureRoots` is justified inline (name fixed by the spec).

### Removed/Skipped Tests
**None.** All planned tests implemented.

---

## 9. Summary of Changes

The epic scope of the preimplementation gate now admits documentation and evidence follow-ups on an epic child that has already merged, before fan-in, when the epic checkpoint entry carries a terminal status and provenance, with every other call keeping its unchanged deny.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

No policy violation and no blocking finding. Review verdict PASS.

**Fail-closed reminder:** All required baseline, QA, and coverage artifacts were present.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline
- N/A Python Design & Typing (constant only)
- N/A Error Handling (constant only)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 20474 of 20484 Pester tests passing (10 disabled, 0 failed); 16560 pytest passing (6 skipped)
- PASS 7 of 7 new or generalized functions tested
- PASS 95.67% PowerShell line coverage; 100% of changed PowerShell lines
- PASS Proper file organization
- PASS All code quality checks passing
- PASS Pester 609.83 s on 8 workers

---

### Recommendation

**Ready for merge** after PR authoring and the CI green gate at S9.

---

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1` › contexts `Get-EpicMergedFeatureRoots`, `Test-EpicMergedFeaturePath`, `generalized predicates (issue #1141)`, `Get-EpicMergedFeatureFollowUpAllowance` (both surface copies)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1` › `fail-before`, `allows`, `already admitted`, `denies with unchanged text`, `denies`, `outside epic scope`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-merged-follow-up.Tests.ps1` › `fail-before`, `allows`, `denies`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` › `PINNED_FROZEN_SURFACE_HASHES` (consumed by `test_frozen_epic_surface_matches_pinned_baseline_digest`)

## Appendix B: Toolchain Commands Reference

Reviewer commands: `git fetch origin main`; `git diff 5c81af727...HEAD`; `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <worktree>`; `poetry run pytest -n auto` over seven contract modules; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`; `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`; `sha256sum` of every mirror copy and of `git show HEAD:<path>`; direct parsing of `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info`; in-process probe of `Get-EpicMergedFeatureFollowUpAllowance`.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-08
**Policy Version:** Current (as of audit date)
