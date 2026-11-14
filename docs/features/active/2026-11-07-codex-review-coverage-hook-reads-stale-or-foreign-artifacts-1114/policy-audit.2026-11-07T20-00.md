# Policy Compliance Audit: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

---

**Audit Date:** 2026-11-07
**Audit Type:** Initial feature review
**Code Under Test:** Full branch diff of `bug/codex-coverage-hook-freshness` (head `ee3bffcf773e6b3238c02878a8fb97eebbdb3b50`) against `main` (merge base `c24cbd295ecec1fc759f52a42806ad991aa49478`; `origin/main` is at `12825cb0018a001a058aade4f65cc022f0a9ca6e` after `git fetch origin`). 38 paths. Outside the feature folder the diff holds 2 added and 1 modified Codex hook file (`.codex/hooks/feature-review-coverage-target.ps1`, `.codex/hooks/validate-feature-review-coverage-freshness.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`) with their byte-identical bundle copies, the Codex `core.json` pack manifest, six copies of the execution-environment brief, 2 added and 2 modified Pester suites under `tests/scripts/codex-hooks/`, and the promoted record. No Python, TypeScript, C#, or bash file is in the diff.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production files (+3 bundle copies), 4 test files | 15946 tests | ✅ 15936 pass, 0 fail, 10 skipped | 94.06% lines | 94.08% lines | 99.31% lines |
| TypeScript | 0 files | not run | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

Rows for Python, C#, and bash are omitted because the branch diff holds zero files of those languages. Pytest ran as a gate only for the bundle and brief contract tests (16204 passed, 0 failed).

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/evidence/baseline/pester-parallel.2026-11-07T19-23.md
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows the policy-audit template headings defined in `scripts/dev_tools/validate_policy_audit_artifact.py`.

---

## Executive Summary

The branch fixes the three defects of the Codex review coverage hook named in the spec (identity, location, freshness). It removes `Get-LatestPolicyAudit`, selects the audit named in `last_assistant_message`, resolves the item root through the existing Codex resolver twin, and adds a function-text twin of the Claude freshness decision. Policy compliance is high: static tools report 0 findings, every Pester row passes, coverage of the three production files is 97.96% to 100%, mirrors and manifests are in parity, and no Claude production file changed.

One blocking finding is recorded (CR-1 in the code review): the audit-path extractor drops valid audit paths in two message shapes, which this review reproduced with real hook processes. An absolute path whose root contains a space is never extracted, so a reviewer in such a worktree cannot satisfy the hook in any message form; a path followed by sentence punctuation (`.` or `:`) is also dropped. Both cases block with `AUDIT_NOT_NAMED`. The defect fails closed (no wrong audit is accepted), but it blocks compliant reviews on hosts whose worktree paths contain whitespace, which the Codex consumer bundle reaches.

- Coverage: PowerShell PASS (repo-wide 94.08%, changed production files 99.31%).
- Static checks: PSScriptAnalyzer 0 findings over 201 files; formatter 0 changes (evidence `qa-gates/poshqc-analyze.2026-11-07T19-40.md`, `qa-gates/poshqc-format.2026-11-07T19-40.md`).
- Base drift: `origin/main` moved by PR #1112 (issue #1096). `git merge-tree --write-tree origin/main HEAD` reports no conflict; the six merged brief copies share blob `7d6520f96`; `Invoke-PoshQCLeakScan` over the merged tree reports 570 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [N/A] Python: no Python file in the branch diff
- [N/A] TypeScript: no TypeScript file in the branch diff
- [N/A] C#: no C# file in the branch diff
- [N/A] GitHub Actions: no workflow file in the branch diff

Toolchain state: the executor's final gates (format, analyze, Pester parallel, pytest parallel, Codex generator check) all exited 0 after the last production commit `7fe54399b` (14:39 local, 19:39 UTC). The coverage and JUnit artifacts were written at 19:47 UTC and describe that tree. This review re-read the JUnit and coverage artifacts and ran its own probes; it did not re-run a test suite.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --porcelain` was empty before this review wrote its artifacts.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: the two new hook files are covered at 97.96% and 98.51% of lines.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller supplied the branch, worktree, merge base, feature folder, PR context paths, and the AC source; none of these limits the files audited or waives a language. The audit scope is the full diff against the merge base.

---

## Evidence Location Compliance

`python -I scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0 with no output. `git diff --name-only c24cbd295...HEAD` lists no path under `artifacts/`. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/regression-testing/`, and `<FEATURE>/evidence/other/`. No violations were found.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New suites use in-memory seams; the merged-tree leak scan reports 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per `It`, tagged `1114:`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 8 shards in 363.83 s over 15946 tests. |
| **Determinism** - Consistent results | ✅ PASS | No clock read, randomness, network, real git, or temporary file; git seams throw on unexpected calls (`BeforeEach` in the entry context). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange-Act-Assert comments; `-Because` messages on outcome assertions. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | ✅ PASS | `.codex/hooks/validate-feature-review-coverage.ps1` 175 of 175 lines (100.00%; Phase 0 baseline 100.00%). |
| **New Code Threshold** | ✅ PASS | `validate-feature-review-coverage-freshness.ps1` 48 of 49 (97.96%); `feature-review-coverage-target.ps1` 66 of 67 (98.51%). |
| **Comprehensive Tests** | ⚠️ PARTIAL | Extraction shapes, separators, labels, traversal, ambiguity, resolver, and wrappers are covered. No row covers a path with whitespace or a path followed by sentence punctuation; both shapes fail in a real-process probe (CR-1). |
| **Positive Flows** - Valid inputs | ✅ PASS | Single audit, versioned and audit-folder shapes, greatest-timestamp selection, fresh reports. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Null and non-string messages, `..` segments, cross-folder audits, absent audit beneath the item root. |
| **Edge Cases** - Boundary conditions | ⚠️ PARTIAL | Report written at the reference commit time passes; whitespace in absolute roots is not handled (CR-1). |
| **Error Handling** - Error paths | ✅ PASS | Git non-zero, empty, non-integer, and throwing invokers fail closed; four `B1` dependency rows pass. |
| **Concurrency** - If applicable | N/A | The hook is a single short-lived process. |
| **State Transitions** - If applicable | ✅ PASS | `stop_hook_active` true yields `continue = false` for the D2 block and the freshness block. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.06% lines -> Post-change: 94.08% lines. Change: +0.02 pp. New/changed-code coverage: 99.31% lines. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/evidence/qa-gates/pester-parallel.2026-11-07T19-47.md.

Thresholds: the root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern. Pester reports no branch figure, and no branch threshold applies to PowerShell.

PowerShell detail. This review parsed the root LINE counter of `artifacts/pester/powershell-coverage.xml` (written 19:47 UTC, after the last production commit at 19:39 UTC): 24395 covered, 1534 missed (94.08%). `artifacts/pester/pester-junit.xml` reads 15946 testcases, 0 failed, 10 skipped, which identifies the full merged run of the final gate. The changed-code figure sums the three measured production files: 289 of 291 lines. The two uncovered lines are the default `GitInvoker` line of the twin and the body line of `Invoke-CodexReviewCoverageGitExe`, both real-git seams that tests mock by design. The bundle copies are byte-identical to their sources (`cmp`) and are not measured separately.

---

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Arrange-Act-Assert** | ✅ PASS | Comment-marked sections in the entry rows. |
| **Actionable failure messages** | ✅ PASS | `-Because` on stdout outcome assertions; reason substrings asserted. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No external services** | ✅ PASS | Git is reached only through `Invoke-CodexReviewCoverageGitExe`, mocked in every row. |
| **No temporary files** | ✅ PASS | No `TestDrive`, `New-Item`, `Set-Content`, or temp-path call in the three new or changed suites. |
| **Linux-safe fixtures** | ✅ PASS | `/`-rooted forward-slash fixture roots; Linux CI is a pending CI-dependent criterion. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policy audit produced** | ✅ PASS | This file. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policies read and baseline captured** | ✅ PASS | `evidence/baseline/` holds scope, format, analyze, Pester, and pytest baselines. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity** | ✅ PASS | Five small functions in the target file; the hook gains a linear sequence of reads. |
| **Reusability** | ✅ PASS | Reuses `Resolve-HookTargetWorktree` and `Get-HookTargetWorktreeRelativePath`; no second resolver. |
| **Separation of concerns** | ✅ PASS | Parsing and selection are pure; git calls sit behind one wrapper seam. |
| **Correctness of extraction rules** | ❌ FAIL | CR-1: valid audit paths with whitespace in the root or trailing sentence punctuation are not extracted. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File size** | ✅ PASS | Production files 387, 226, and 145 logical lines (Codex 500-line cap held). `legacy-codex-hook-contracts.Tests.ps1` is 506 lines (500-line guidance tier only; no finding). No file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Functions-only helpers** | ✅ PASS | Both new files hold no statement outside function definitions. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names and help** | ✅ PASS | Approved verbs; comment-based help on every function; hook help keeps both `CLAUDE.md` sentences (E4-ST3 passes). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format** | ✅ PASS | 201 files, 0 changes. |
| **Lint** | ✅ PASS | 0 findings. |
| **Type check** | N/A | PowerShell. |
| **Tests** | ✅ PASS | Pester 0 failures; pytest 0 failures. |
| **Contract checks** | ✅ PASS | Bundle, manifest, dependency-closure, and brief contract tests pass; `generate_codex_agent_variants --check` exit 0. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Brief updated** | ✅ PASS | Six brief copies share one blob id at head and on the merged tree. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PowerShell 7 compatible** | ✅ PASS | PSSA with repo settings, 0 findings. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Wrapper seam for executables** | ✅ PASS | `Invoke-CodexReviewCoverageGitExe -GitArgs`. |
| **No script-scope mutable state** | ✅ PASS | New files hold none. |
| **Fail closed** | ✅ PASS | Every unresolvable target blocks; dependency loads use the guarded dot-source pattern. |
| **No Python in hooks** | ✅ PASS | No `.py` file under `.codex/hooks`; no Python invocation. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **CmdletBinding and typed parameters** | ✅ PASS | All new functions. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **format, analyze, test in order** | ✅ PASS | `qa-gates/` artifacts at 19-40, 19-40, 19-47. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pester, mirrored location** | ✅ PASS | `tests/scripts/codex-hooks/<name>.Tests.ps1`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Mock the wrapper, not git** | ✅ PASS | Mocks target `Invoke-CodexReviewCoverageGitExe`, `Invoke-CodexReviewCoverageGitLog`, `Get-CodexReviewCoverageWorktreeList`. |
| **Mock signature parity** | ✅ PASS | `param([string[]] $GitArgs)` matches production. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive row names** | ✅ PASS | Row names quoted verbatim by the spec ACs. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Parallel gate** | ✅ PASS | One `Invoke-PoshQCParallelTest` run per gate. |

---

## 5. Test Coverage Detail

### feature-review-coverage-target.Tests.ps1 (34 tests)

**Coverage:** `feature-review-coverage-target.ps1` 98.51% of lines.

**Not covered:** 1 line, the body of the real-git seam.

### validate-feature-review-coverage-freshness.Tests.ps1 (21 tests)

**Coverage:** `validate-feature-review-coverage-freshness.ps1` 97.96% of lines; function-name set and extent text equal to the Claude file (this review also compared the function region with `diff`: identical).

**Not covered:** 1 line, the default `GitInvoker` parameter value.

### validate-feature-review-coverage.Coverage.Tests.ps1 (40 tests)

**Coverage:** `validate-feature-review-coverage.ps1` 100.00% of lines.

**Not covered:** nothing.

---

## 6. Test Execution Metrics

| Gate | Tests | Failed | Skipped | Duration |
|------|-------|--------|---------|----------|
| Pester parallel (final) | 15946 | 0 | 10 | 363.83 s |
| Pester parallel (Phase 0) | 15881 | 0 | 10 | 1374.61 s |
| pytest parallel (final) | 16210 | 0 | 6 | 146.89 s |

Fail-before: the four `1114:` entry rows failed against the unfixed hook (`evidence/regression-testing/fail-before.2026-11-07T19-37.md`).

---

## 7. Code Quality Checks

**For PowerShell:**
- PSScriptAnalyzer: 0 findings over 201 files.
- Formatter: 0 differences.

**Notes:**
- Real-process probes by this review: the hook copied into scratch roots with and without a space; results recorded in the code review (CR-1).

---

## 8. Gaps and Exceptions

### Identified Gaps

- CR-1 (blocking): audit-path extraction drops absolute paths whose root contains whitespace and paths followed by sentence punctuation.
- CR-2 (non-blocking): a `..` path with two segments below the feature folder is skipped by the shape filter and reported as `AUDIT_NOT_NAMED` instead of `AUDIT_PATH_TRAVERSAL`; no `..` path can be selected.

### Approved Exceptions

None.

### Removed/Skipped Tests

The rows `returns no audit when the active folder is absent` and `returns the most recently written audit` were replaced by target-selection rows, as the spec requires.

---

## 9. Summary of Changes

### Commits in This PR/Branch

27 commits from `4224ca1ad` to `ee3bffcf7`; production commits `5a5765d56` (freshness twin), `40bb0343f` (target functions), `5a37633e6` (hook fix), `7fe54399b` (brief).

### Files Modified

See the Code Under Test line above.

---

## 10. Compliance Verdict

### Overall Status: ❌ REMEDIATION REQUIRED

One blocking finding (CR-1) requires a code change in `Get-CodexReviewPolicyAuditPath` and new test rows.

**Fail-closed reminder:** numeric post-change coverage is recorded for the one changed coverage language, and changed-code coverage is recorded for the changed production files.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

❌ FAIL on extraction correctness (CR-1); all other rows PASS.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:** ✅ PASS.

#### Unit Test Policy (Sections 1 and 4)

⚠️ PARTIAL: coverage PASS; scenario completeness lacks the CR-1 shapes.

---

## Appendix A: Test Inventory

- `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1` (new, 34 tests)
- `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1` (new, 21 tests)
- `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` (modified, 40 tests)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (modified, 43 tests)
- `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` (unchanged, 93 tests including 4 `B1` rows for the hook)

## Appendix B: Toolchain Commands Reference

- `Invoke-PoshQCFormat -Root <worktree> -ScanFolders ...` and a check-only `Invoke-Formatter` pass
- `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`
- `Invoke-PoshQCParallelTest -Root <worktree>`
- `poetry run pytest -n auto --cov --cov-branch`
- `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
- Review: `git merge-tree --write-tree origin/main HEAD`; `Invoke-PoshQCLeakScan -Root <merged tree>`; `validate_evidence_locations.py --root <worktree>`
