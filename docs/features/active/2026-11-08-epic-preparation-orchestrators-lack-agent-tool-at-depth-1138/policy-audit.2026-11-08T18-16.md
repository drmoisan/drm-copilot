# Policy Compliance Audit: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Audit Date:** 2026-11-08
**Code Under Test:** merge base `a90d522c6ac239bca858d7bc800d52860e823219` of the base branch and reviewed head `08e400844373251892289ce0c7562b1daff6af0e`; the diff between them lists the changed files (57 paths, first review)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production (2 hooks plus 2 bundle copies), 3 test | 20119 | PASS 20109 pass, 0 fail, 10 skipped | 95.62% lines | 95.64% lines | 100% (new helper, 19/19), 90.79% (origin hook, 69/76) |
| Python | 0 production, 2 test | 16566 | PASS 16560 pass, 0 fail, 6 skipped | 97.11% lines | 97.11% lines | N/A (no production files changed) |
| JSON | 1 file | N/A | PASS pack manifest contract tests | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-08T17-38.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (parsed directly at the reviewed head)
- Python baseline coverage artifact: `evidence/baseline/pytest-baseline.2026-11-08T17-40.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (totals recomputed: 34296 of 35317 lines, 12649 of 13404 branches)
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are recorded for PowerShell and Python, the two languages with changed files.

---

## Executive Summary

The branch adds a nesting-depth preflight for the epic and parallel chains: a Pester-tested PowerShell helper (`.claude/hooks/epic-invocation-nesting-depth.ps1`) dot-sourced through the guarded pattern into `enforce-epic-invocation-origin.ps1`, an Agent-tool preflight paragraph in five agent files, `## Nesting Depth` sections in seven skills, one line in six execution-environment brief copies, bundle mirrors, a `core.json` entry, and a #1138 re-baseline of two pinned digests. All policy documents below were evaluated against the full branch diff from the merge base.

PowerShell coverage was read from `artifacts/pester/powershell-coverage.xml`: the new helper sourcefile counter reads `covered="19" missed="0"`, the origin hook `covered="69" missed="7"`, and the root LINE counter 36056 covered of 37701 (95.64%). Python changed only in two test files; `artifacts/python/lcov.info` totals equal the Phase 0 figures.

Policy compliance is met. The review's single blocking finding (code review F1: the coordinator agents give no instruction for a `NESTING_DEPTH_INSUFFICIENT:` hook deny) is a correctness and completeness finding recorded in `code-review.2026-11-08T18-16.md`; it does not arise from a policy violation.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`
- PASS `quality-tiers.md` (`.claude/hooks` is classified T3 in `quality-tiers.yml`)

**Language-specific policies evaluated:**
- PASS `powershell.md` (code and unit test)
- PASS `python.md` (test-only edits)
- N/A TypeScript, C#, Bash: zero changed files
- PASS JSON: one `core.json` entry, covered by the pack-manifest contract tests

**Temporary artifacts cleanup:**
- PASS Scratch launchers are outside the repository; `git status --porcelain` was empty at the reviewed head before this review wrote its artifacts.

---

## Rejected Scope Narrowing

None. The caller asked for the full branch diff against the merge base of `origin/main` and HEAD. The instruction to read the final-QC static evidence instead of re-running format, lint, and type checks follows the evidence model and does not narrow scope; every language with changed files has an explicit coverage verdict below.

## Evidence Location Compliance

No branch-diff file lies under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (`git diff --name-only` over the range lists no `artifacts/` path). `scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0. Evidence is under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`. No EVIDENCE_LOCATION_OVERRIDE_REJECTED event.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each `It` mocks `Get-SubagentSpawnDepthSetting` itself; the import-failure `It` resets the dependency-failure state in `finally` |
| **Isolation** - Each test targets single behavior | PASS | Helper `It` blocks target one decision; hook-integration blocks target `Invoke-EpicInvocationOriginDecision` |
| **Fast Execution** - Tests complete quickly | PASS | Pure in-memory decisions; contract suite reads files in place |
| **Determinism** - Consistent results | PASS | No clock, randomness, network, or environment mutation; the seam is mocked, and the existing origin suite pins the seam to unset |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `It` names, Arrange/Act/Assert comments, `-Because` messages naming the value, pair, or literal |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | 95.62% lines PowerShell, 97.11% lines and 94.37% branches Python (Phase 0 baseline artifacts) |
| **No Coverage Regression** | PASS | PowerShell 95.62% to 95.64%; origin hook 90.41% to 90.79%; Python unchanged |
| **Changed Files Meet Thresholds** | PASS | Line threshold 85%: helper 100%, origin hook 90.79%; branch threshold not applicable to PowerShell |
| **New Code Coverage >=90%** | PASS | Helper 19 of 19 lines (spec AC10 sets 90%) |
| **Comprehensive Coverage** | PASS | All three helper functions, including the unmocked seam read |
| **Positive Flows** | PASS | Unset, empty, whitespace, `3`, `4`, `10`, padded ` 4 ` allow |
| **Negative Flows** | PASS | `2`, `1`, `0`, `-1` deny with remedy text; `two`, `2.5` deny with the parse message |
| **Edge Cases** | PASS | Eight applying and four non-applying caller/target pairs; padded values |
| **Error Handling** | PASS | "guarded import failure denies" (and hook-dependency-failure B1 row) |
| **Concurrency** | N/A | Stateless read-only helper |
| **State Transitions** | N/A | No stateful component |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.62% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.64% lines. Change: +0.02% lines. New/changed-code coverage: 100% new helper (19 of 19), 90.79% origin hook (69 of 76, baseline 90.41%). Disposition: PASS. Evidence: `evidence/baseline/pester-baseline.2026-11-08T17-38.md`, `evidence/qa-gates/pester-final.2026-11-08T18-06.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 97.11% lines, 94.37% branches -> Post-change: 97.11% lines, 94.37% branches. Change: 0. New/changed-code coverage: no Python production file changed; the two edited files are tests. Disposition: PASS. Evidence: `evidence/baseline/pytest-baseline.2026-11-08T17-40.md`, `evidence/qa-gates/pytest-final.2026-11-08T18-06.md`, `artifacts/python/lcov.info`.

### 1.3 Test Structure and Diagnostics

PASS. Assertions use ordinal `StartsWith` and `Contains` with `-Because` text naming the input, the pair, or the file and literal.

### 1.4 External Dependencies and Environment

PASS. No test sets an environment variable or writes a file (local `Invoke-PoshQCLeakScan`: 0 failures). Tests mirror the source layout under `tests/scripts/claude-hooks/` and `tests/scripts/claude-runtime/`.

### 1.5 Policy Audit Requirement

PASS. This audit is the artifact.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes
PASS. Phase 0 baselines for PowerShell static, Python static, Pester, and pytest exist under `evidence/baseline/`; the fail-before exception dossier is under `evidence/regression-testing/`.

### 2.2 Design Principles
PASS. The depth decision lives in a separate helper with a single environment-reading seam; the origin hook adds one guarded dot-source and one call.

### 2.3 Module & File Structure
PASS. Helper 126 lines, origin hook 295 lines, largest changed covered file 499 lines (`test_parallel_orchestrator_surface_contracts.py`). No covered file reaches 700 lines; `config/file-size-baseline.json` is unchanged.

### 2.4 Naming, Docs, and Comments
PASS. Approved verbs (`Get`, `Test`), comment-based help on every function, a why-comment at the call site.

### 2.5 After Making Changes - Toolchain Execution
PASS. `poshqc-static-final.2026-11-08T17-53.md`: 0 of 7 files need formatting, 0 analyzer findings, leak scan 0 failures. `python-static-final.2026-11-08T17-54.md`: Black, Ruff, Pyright 0 findings.

### 2.6 Summarize and Document
PASS. Spec, plan, research, evidence, skills, brief, and agent text are present.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

PASS. Edits are a digest tuple update with a #1138 comment block and a heading-count assertion with an updated docstring, both in test code.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline
PASS. PSScriptAnalyzer and Invoke-Formatter clean per the static artifact. One `PSUseSingularNouns` suppression with a justification on `Test-EpicInvocationNestingDepthApplies`.

#### 3B.2 PowerShell Design & Safety
PASS. `CmdletBinding`, `OutputType`, `AllowNull`/`AllowEmptyString` parameters; no process start, no `Invoke-Expression`; invariant-culture parse; a set non-integer value fails closed.

#### 3B.3 Structure, Naming, and Comments
PASS.

#### 3B.4 Running the Toolchain
PASS. One parallel Pester gate: 20119 tests, 0 failed.

### Documentation Surface Check
N/A. `docs/documentation-estate/docs-profile.json` is absent at the head, so the check produces no finding.

### Tier classification
PASS. `quality-tiers.yml` exists; the changed production files are under `.claude/hooks`, classified T3. No new project root is introduced.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

PASS. Existing tests edited in place; the frozen-surface digest test and the heading-layout test pass in the final gate.

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope
PASS. Pester 6.x through `Invoke-PoshQCParallelTest`; `*.Tests.ps1` files mirror the source layout.

#### 4B.2 Test Style and Structure
PASS. `Describe`/`Context`/`It`; the only mocks are the environment seam and `Join-Path` in the import-failure case.

#### 4B.3 Naming and Readability
PASS.

#### 4B.4 Running the Toolchain
PASS. Final gate green.

---

## 5. Test Coverage Detail

### epic-invocation-nesting-depth.ps1 (helper)
Unset, empty, and whitespace values; integers at or above 3; integers below 3 including 0 and -1; non-integer values; the eight applying and four non-applying caller/target pairs; the AST rule that the seam is the only environment reader; an unmocked seam read.

### enforce-epic-invocation-origin.ps1 (wiring)
Main-thread `epic-planner` delegation denied at limit 2; `epic-planner` to `orchestrator` denied at limit 2; orchestrator-originated `epic-planner` still gets `EPIC_INVOCATION_ORIGIN_BLOCKED:`; failed helper import denies with the helper named. The existing origin suite passes with the seam pinned to unset.

### Reviewer real-process probe
Through `pwsh -NoProfile -File` with the variable set in the child environment and a JSON envelope on stdin, 16 cases matched the spec: chain pairs deny at `2`; `orchestrator` to `atomic-executor` and `task-researcher`, main thread to `orchestrator` (at `2` and `1`), and `epic-planner` to `atomic-planner` allow; unset and `3` allow; `abc` denies.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 20119 Pester, 16566 pytest | PASS |
| Tests Passed | 20109 Pester (10 skipped), 16560 pytest (6 skipped) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 625.36 s Pester (8 workers), 220.88 s pytest | PASS |
| Average Time per Test | N/A (parallel gate) | N/A |
| Discovery Time | N/A | N/A |
| Functions/Classes Tested | 3/3 helper functions plus the origin decision function | PASS |
| Test File Size | 499 logical lines largest | PASS |
| Code Coverage | 95.64% PowerShell lines; 97.11% Python lines, 94.37% Python branches | PASS |

---

## 7. Code Quality Checks

| Check | Result |
|-------|--------|
| PSScriptAnalyzer | PASS 0 findings |
| Invoke-Formatter check | PASS 0 drift |
| Leak scan | PASS 0 failures (local) |
| Black, Ruff, Pyright | PASS 0 findings |
| Codex generator `--check` | PASS exit 0 (re-run by the reviewer) |

## CI Cross-check

No pull request and no CI run exist for the branch yet (`gh pr list` and `gh run list` for the branch returned empty). The rows below record the local evidence the review relies on; CI confirmation on the PR head is pending-CI and owned by the orchestrator at S9.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| Pester suite | pass | 20119 tests, 0 failed | 08e400844373251892289ce0c7562b1daff6af0e | `evidence/qa-gates/pester-final.2026-11-08T18-06.md` |
| `poshqc / PowerShell QC static` (format, analyze, leak scan) | pass | 0 findings, 0 leak failures | 08e400844373251892289ce0c7562b1daff6af0e | `evidence/qa-gates/poshqc-static-final.2026-11-08T17-53.md` |
| `Enforce Python coverage thresholds` | pass | 97.11% lines, 94.37% branches | 08e400844373251892289ce0c7562b1daff6af0e | `evidence/qa-gates/pytest-final.2026-11-08T18-06.md`, `artifacts/python/lcov.info` |
| Python static | pass | 0 findings | 08e400844373251892289ce0c7562b1daff6af0e | `evidence/qa-gates/python-static-final.2026-11-08T17-54.md` |

---

## 8. Gaps and Exceptions

### Identified Gaps
- AC9 (leak scan in the CI static job) was verified locally with the same `Invoke-PoshQCLeakScan` function; CI confirmation is pending-CI and is not a blocking finding.
- The hook's view of a settings `env` block value is an unverified assumption stated in the spec; the instruction-level preflight is the primary control.

### Approved Exceptions
- Fail-before exception dossier `evidence/regression-testing/fail-before-exception.2026-11-08T17-25.md`: a live nested reproduction is not possible from an isolated subagent.

### Removed/Skipped Tests
None.

---

## 9. Summary of Changes

Adds a configured-limit nesting-depth deny to the epic invocation origin hook through a new helper, an Agent-tool preflight in the orchestrator and four coordinator agents, `## Nesting Depth` documentation with a main-session fallback in seven skills, a brief line in six copies, bundle mirrors, a pack-manifest entry, and a #1138 pin re-baseline.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

No policy violation was found. The review verdict is REMEDIATION_REQUIRED because of code-review finding F1 (correctness gap in coordinator handling of the new hook deny), recorded in `remediation-inputs.2026-11-08T18-16.md`.

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

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

**For Python:**
- PASS Test-only edits, static checks clean

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 20109/20119 Pester tests passing (10 skipped); 16560 pytest passing (6 skipped)
- PASS 95.64% PowerShell line coverage; 97.11% Python line coverage
- PASS Proper file organization
- PASS All code quality checks passing

---

### Recommendation

**Remediate code-review F1 (light path), then re-review.**

---

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1` (new)
- `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1` (new)
- `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` (setup-only seam mock)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (pin re-baseline)
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (heading count 16 to 17)

## Appendix B: Toolchain Commands Reference

PowerShell: PoshQC format and analyze with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `Invoke-PoshQCLeakScan`, and `Invoke-PoshQCParallelTest`. Python: Black `--check`, Ruff, Pyright, and `pytest -n auto --cov --cov-branch`. As recorded in the QA-gate evidence artifacts.
