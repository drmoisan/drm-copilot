# Policy Compliance Audit: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

---

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after remediation cycle 2
**Code Under Test:** Full branch diff of `bug/codex-coverage-hook-freshness` (head `eb20091a7891728d6455578f4376801a04bde37f`) against `main` (merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e`, equal to `origin/main` after `git fetch origin`). 66 paths. Outside the feature folder the diff holds 2 added and 1 modified Codex hook file (`.codex/hooks/feature-review-coverage-target.ps1`, `.codex/hooks/validate-feature-review-coverage-freshness.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`) with their byte-identical bundle copies, the Codex `core.json` pack manifest, six copies of the execution-environment brief, 2 added and 2 modified Pester suites under `tests/scripts/codex-hooks/`, and the promoted record. No Python, TypeScript, C#, or bash file is in the diff. Cycle 2 changed one condition in one production function (`Get-CodexReviewPolicyAuditPath`) and its help text, its bundle copy, and added one test row.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production files (+3 bundle copies), 4 test files | 16067 tests | ✅ 16057 pass, 0 fail, 10 skipped | 94.06% lines | 94.13% lines | 99.34% lines |
| TypeScript | 0 files | not run | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

Rows for Python, C#, and bash are omitted because the branch diff holds zero files of those languages. Pytest ran only as a gate for the bundle, manifest, dependency-closure, and brief contract tests (this review: 50 passed, 0 failed).

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/evidence/baseline/pester-parallel.2026-11-07T19-23.md
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows the policy-audit template headings defined in `scripts/dev_tools/validate_policy_audit_artifact.py` and the validated structure of the prior audit.

---

## Executive Summary

Remediation cycle 2 resolved CR-3, the one Low finding of the cycle 1 re-audit. In `Get-CodexReviewPolicyAuditPath`, the `..` segment check now runs only when the final segment of the examined candidate matches `^policy-audit\.(?:[^/]+\.)?md$`. A valid audit cited beside a non-audit path that contains `..` is selected again, and a policy-audit path that contains `..` still yields `AUDIT_PATH_TRAVERSAL`.

This review verified the fix independently:

- Direct calls of the head extractor on nine message shapes. A valid audit with a forward-slash or backslash code-review `..` path is selected. Policy-audit `..` paths are blocked in the versioned, `audit/` folder, upper-case, trailing-punctuation, and root-level forms. Non-audit `..` paths alone are skipped.
- The pre-cycle extractor (from `37e2f147a`), run on the new row's message, returns `AUDIT_PATH_TRAVERSAL` with no paths, so the new row discriminates.
- Both the shape test and the new name test use case-insensitive `-match`. Every final segment that the shape pattern accepts also matches the name pattern. So the narrowing cannot let a policy-audit candidate with `..` reach selection.

No blocking finding remains. No new finding is introduced by cycle 2.

- Coverage: PowerShell PASS (repo-wide 94.13%, changed production files 99.34%).
- Static checks: PSScriptAnalyzer 0 findings over 201 files; formatter 0 changes; leak scan 0 failures (evidence `qa-gates/poshqc-analyze.2026-11-07T21-11.md`, `qa-gates/poshqc-format.2026-11-07T21-11.md`, `qa-gates/poshqc-leakscan.2026-11-07T21-11.md`).
- Base: the merge base equals `origin/main` (`12825cb00`), so no base drift exists at this head.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [N/A] Python: no Python file in the branch diff
- [N/A] TypeScript: no TypeScript file in the branch diff
- [N/A] C#: no C# file in the branch diff
- [N/A] GitHub Actions: no workflow file in the branch diff

Toolchain state: the last production commit is `18b41b198` (21:10 UTC). The cycle 2 format, analyze, and leak scan gates (21:11 UTC), the Pester parallel gate (21:21 UTC), and the pytest gate (21:22 UTC) ran after it. The merged coverage and JUnit files were written at 21:21 UTC and describe that tree. This review parsed those files, re-ran the pytest contract set and the Codex generator check at head, and ran its own probes against the head and pre-cycle extractors. It did not re-run Pester.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --porcelain` was empty before this review wrote its artifacts.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: the two new hook files are covered at 97.96% and 98.73% of lines.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller supplied the branch, worktree, merge base, head, feature folder, PR context paths, AC source, and prior inputs. None of these limits the files audited or waives a language. The audit scope is the full diff against the merge base, not only the cycle 2 change.

---

## Evidence Location Compliance

`scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0 with no output. `git diff --name-only` of the merge base against head lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/regression-testing/`, and `<FEATURE>/evidence/other/`. No violations were found.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The new row calls the pure extractor and sets no state; leak scan 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per `It`, tagged `1114:`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 8 shards, full suite green in the cycle 2 final gate. |
| **Determinism** - Consistent results | ✅ PASS | No clock read, randomness, network, real git, or temporary file in the new row. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Outcome assertions on the exact path list and an empty reason code. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | ✅ PASS | `.codex/hooks/validate-feature-review-coverage.ps1` 175 of 175 lines (100.00%; Phase 0 baseline 100.00%). |
| **New Code Threshold** | ✅ PASS | `validate-feature-review-coverage-freshness.ps1` 48 of 49 (97.96%); `feature-review-coverage-target.ps1` 78 of 79 (98.73%; cycle 1 98.70%). |
| **Comprehensive Tests** | ✅ PASS | Cycle 2 added the row `1114: ignores a non-audit path with a .. segment cited beside a valid policy audit`; the three existing `AUDIT_PATH_TRAVERSAL` rows still pass, so both outcomes of the narrowed condition are exercised. |
| **Positive Flows** - Valid inputs | ✅ PASS | Single audit, versioned and audit-folder shapes, space roots, trailing punctuation, greatest-timestamp selection, valid audit beside a non-audit `..` path. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Null and non-string messages, policy-audit `..` segments, cross-folder audits, absent audit beneath the item root. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Report written at the reference commit time passes; whitespace roots and trailing punctuation are handled. |
| **Error Handling** - Error paths | ✅ PASS | Git non-zero, empty, non-integer, and throwing invokers fail closed; four `B1` dependency rows pass. |
| **Concurrency** - If applicable | N/A | The hook is a single short-lived process. |
| **State Transitions** - If applicable | ✅ PASS | `stop_hook_active` true yields `continue = false` for the D2 block and the freshness block. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.06% lines -> Post-change: 94.13% lines. Change: +0.07 pp. New/changed-code coverage: 99.34% lines. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/evidence/qa-gates/pester-parallel.2026-11-07T21-21.md.

Thresholds: the root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern. Pester reports no branch figure, and no branch threshold applies to PowerShell.

PowerShell detail. This review parsed the root LINE counter of `artifacts/pester/powershell-coverage.xml` (written 21:21 UTC, after the last production commit at 21:10 UTC): 24716 covered, 1542 missed (94.13%). `artifacts/pester/pester-junit.xml` reads 16067 tests, 0 failures, 0 errors, 10 skipped, which identifies the full merged run of the cycle 2 final gate. The changed-code figure sums the three measured production files: 301 of 303 lines. The two uncovered lines are line 99 of the twin (the default `GitInvoker`) and line 40 of the target file (the body of `Invoke-CodexReviewCoverageGitExe`). Both are real-git seams that tests mock by design. The bundle copies are byte-identical to their sources (SHA-256 compared by this review) and are not measured separately. Changed lines of the modified hook show no regression against the Phase 0 baseline (100.00% before and after).

---

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Arrange-Act-Assert** | ✅ PASS | The new row builds the message, calls the extractor, then asserts. |
| **Actionable failure messages** | ✅ PASS | Exact path lists and reason codes asserted; the fail-before message names the expected path and the `$null` result. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No external services** | ✅ PASS | Git is reached only through `Invoke-CodexReviewCoverageGitExe`, mocked in every row. |
| **No temporary files** | ✅ PASS | The new row creates no file. |
| **Linux-safe fixtures** | ✅ PASS | Forward-slash, exact-case literals with no drive letter; Linux CI is a pending CI-dependent criterion. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policy audit produced** | ✅ PASS | This file. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policies read and baseline captured** | ✅ PASS | `evidence/baseline/` holds the Phase 0 baselines and the cycle 2 reference `scope-check.2026-11-07T20-55.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity** | ✅ PASS | The fix adds one pattern variable and one conjunct to an existing condition. |
| **Reusability** | ✅ PASS | Reuses `Resolve-HookTargetWorktree` and `Get-HookTargetWorktreeRelativePath`; no second resolver. |
| **Separation of concerns** | ✅ PASS | Parsing and selection are pure; git calls sit behind one wrapper seam. |
| **Correctness of extraction rules** | ✅ PASS | CR-3 resolved; the set of final segments that the shape test accepts is a subset of those that the name test matches, both case-insensitive, verified by probes. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File size** | ✅ PASS | Production files 387, 249, and 145 logical lines (Codex 500-line cap held). Test files 363, 267, 423, and 506 lines. No file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Functions-only helpers** | ✅ PASS | Both new files hold no statement outside function definitions. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names and help** | ✅ PASS | The help of `Get-CodexReviewPolicyAuditPath` states that the `..` check applies to policy-audit candidates and that other candidates with `..` fail the shape test. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Format** | ✅ PASS | 201 files, 0 would change. |
| **Lint** | ✅ PASS | 0 findings. |
| **Type check** | N/A | PowerShell. |
| **Tests** | ✅ PASS | Pester 0 failures; pytest contract set 0 failures. |
| **Contract checks** | ✅ PASS | This review: bundle, manifest, dependency-closure, and brief contract tests 50 passed; `generate_codex_agent_variants.py --check` exit 0. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Brief updated** | ✅ PASS | Six brief copies unchanged by cycle 2; brief contract tests pass. |

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
| **Fail closed** | ✅ PASS | Every unresolvable target blocks; policy-audit `..` paths still block. |
| **No Python in hooks** | ✅ PASS | No `.py` file under `.codex/hooks`; no Python invocation. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **CmdletBinding and typed parameters** | ✅ PASS | Unchanged signature of the cycle 2 function. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **format, analyze, test in order** | ✅ PASS | `qa-gates/` artifacts at 21-11 (format, analyze, leak scan) and 21-21 (Pester). |

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
| **Mock the wrapper, not git** | ✅ PASS | The new row needs no mock; existing rows mock the wrapper seams. |
| **Mock signature parity** | ✅ PASS | Existing mocks unchanged. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive row names** | ✅ PASS | The new `1114:` row is named as in the remediation plan. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Parallel gate** | ✅ PASS | One `Invoke-PoshQCParallelTest` run for fail-before and one for the final gate. |

---

## 5. Test Coverage Detail

### feature-review-coverage-target.Tests.ps1 (42 tests)

**Coverage:** `feature-review-coverage-target.ps1` 98.73% of lines.

**Not covered:** 1 line, the body of the real-git seam (line 40).

### validate-feature-review-coverage-freshness.Tests.ps1 (21 tests)

**Coverage:** `validate-feature-review-coverage-freshness.ps1` 97.96% of lines; unchanged by cycle 2.

**Not covered:** 1 line, the default `GitInvoker` parameter value (line 99).

### validate-feature-review-coverage.Coverage.Tests.ps1 (40 tests)

**Coverage:** `validate-feature-review-coverage.ps1` 100.00% of lines.

**Not covered:** nothing.

---

## 6. Test Execution Metrics

| Gate | Tests | Failed | Skipped | Duration |
|------|-------|--------|---------|----------|
| Pester parallel (cycle 2 final) | 16067 | 0 | 10 | not recorded |
| Pester parallel (cycle 2 fail-before) | 16067 | 1 | 10 | not recorded |
| Pester parallel (cycle 1 final) | 16066 | 0 | 10 | 251.30 s |
| Pester parallel (Phase 0) | 15881 | 0 | 10 | 1374.61 s |
| pytest contract set (this review) | 50 | 0 | 0 | 27.54 s |

Fail-before: the new row failed on its `Paths` outcome assertion against the unfixed extractor, and the three existing `AUDIT_PATH_TRAVERSAL` rows passed (`evidence/regression-testing/fail-before.2026-11-07T21-08.md`). This review confirmed the discrimination independently by running the pre-cycle extractor on the row's message.

---

## 7. Code Quality Checks

**For PowerShell:**
- PSScriptAnalyzer: 0 findings over 201 files.
- Formatter: 0 differences.
- Leak scan: 570 files, 0 failures.

**Notes:**
- Direct-call probes by this review are recorded in the code review.

---

## 8. Gaps and Exceptions

### Identified Gaps

- Info (carried): an absolute path under a root that contains a space is not extracted when the label is wrapped in Markdown emphasis or when text follows the path on the label line. The pre-cycle extractors also failed these shapes; the result is a fail-closed `AUDIT_NOT_NAMED`.
- Info (carried): 8.3 short-name absolute paths do not match a long-name session root (shared resolver, out of scope).

### Approved Exceptions

None.

### Removed/Skipped Tests

None in cycle 2. The rows `returns no audit when the active folder is absent` and `returns the most recently written audit` were replaced earlier by target-selection rows, as the spec requires.

---

## 9. Summary of Changes

### Commits in This PR/Branch

47 commits from `4224ca1ad` to `eb20091a7`, including the merge of `origin/main` (`d5a211dd0`). Production commits: `5a5765d56` (freshness twin), `40bb0343f` (target functions), `5a37633e6` (hook fix), `7fe54399b` (brief), `137b9a727` (cycle 1 extraction fix), `18b41b198` (cycle 2 traversal scope fix).

### Files Modified

See the Code Under Test line above.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

No blocking finding remains. CR-3 is resolved and verified by the parallel gate, the fail-before evidence, and this review's probes of the head and pre-cycle extractors.

**Fail-closed reminder:** numeric post-change coverage is recorded for the one changed coverage language, and changed-code coverage is recorded for the changed production files.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

✅ PASS.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:** ✅ PASS.

#### Unit Test Policy (Sections 1 and 4)

✅ PASS: coverage PASS; scenario completeness PASS.

---

## Appendix A: Test Inventory

- `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1` (new, 42 tests)
- `tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1` (new, 21 tests)
- `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` (modified, 40 tests)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (modified, 43 tests)
- `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` (unchanged, 93 tests including 4 `B1` rows for the hook)

## Appendix B: Toolchain Commands Reference

- Check-only `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`
- `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`
- `Invoke-PoshQCLeakScan -Root <worktree>`
- `Invoke-PoshQCParallelTest -Root <worktree>`
- `poetry run python -m pytest -n auto --no-cov` over the four contract test files
- `poetry run python scripts/dev_tools/generate_codex_agent_variants.py --check`
- Review: `validate_evidence_locations.py --root <worktree>`; coverage XML and JUnit parse; extractor probes against the head and pre-cycle files
