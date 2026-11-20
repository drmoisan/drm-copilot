# Policy Compliance Audit: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

---

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after remediation cycle 1
**Code Under Test:** Full branch diff of `bug/codex-coverage-hook-freshness` (head `378c0035a0e423bb4d230e162a6c896c6a567e2f`) against `main` (merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e`, equal to `origin/main` after `git fetch origin`). 52 paths. Outside the feature folder the diff holds 2 added and 1 modified Codex hook file (`.codex/hooks/feature-review-coverage-target.ps1`, `.codex/hooks/validate-feature-review-coverage-freshness.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`) with their byte-identical bundle copies, the Codex `core.json` pack manifest, six copies of the execution-environment brief, 2 added and 2 modified Pester suites under `tests/scripts/codex-hooks/`, and the promoted record. No Python, TypeScript, C#, or bash file is in the diff. Cycle 1 changed one production function (`Get-CodexReviewPolicyAuditPath`), its bundle copy, and added seven test rows.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 production files (+3 bundle copies), 4 test files | 16066 tests | ✅ 16056 pass, 0 fail, 10 skipped | 94.06% lines | 94.13% lines | 99.34% lines |
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

Remediation cycle 1 resolved the one blocking finding of the initial review (CR-1) and the non-blocking CR-2. `Get-CodexReviewPolicyAuditPath` now takes candidates from the label remainder, from quote and backtick spans, and from the token scan, and strips trailing `.`, `,`, `:`, and `;` after `.md`. This review confirmed the fix with real hook processes: under a root containing a space, a labelled absolute path and a sentence-final relative path now pass (exit 0, no output); the pre-cycle extractor, run in the same harness, blocks both with `AUDIT_NOT_NAMED`.

No blocking finding remains. One new non-blocking finding is recorded (CR-3, Low, in the code review). The CR-2 change applies the `..` check to every candidate that contains `docs/features/active/`, not only to policy-audit candidates. A message that names a valid audit and also cites a non-audit path containing `..` (for example a code-review path) now blocks with `AUDIT_PATH_TRAVERSAL`, and the reason calls that path "the policy-audit path". The block fails closed and can be repaired in one message. The initial review's own resolution item 4 recommended this scope.

- Coverage: PowerShell PASS (repo-wide 94.13%, changed production files 99.34%).
- Static checks: PSScriptAnalyzer 0 findings over 201 files; formatter 0 changes; leak scan 0 failures (evidence `qa-gates/poshqc-analyze.2026-11-07T20-25.md`, `qa-gates/poshqc-format.2026-11-07T20-25.md`, `qa-gates/poshqc-leakscan.2026-11-07T20-27.md`).
- Base: the branch merged `origin/main` at `12825cb00`; the merge base equals `origin/main`, so no base drift exists at this head.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [N/A] Python: no Python file in the branch diff
- [N/A] TypeScript: no TypeScript file in the branch diff
- [N/A] C#: no C# file in the branch diff
- [N/A] GitHub Actions: no workflow file in the branch diff

Toolchain state: the last production commit is `137b9a727` (20:25 UTC). The cycle's format and analyze gates (20:25 UTC), leak scan (20:27 UTC), Pester parallel gate, and pytest gate (both 20:33 UTC) ran after it. The merged coverage and JUnit files were written at 20:32 UTC and describe that tree. This review parsed those files, re-ran the pytest contract set and the Codex generator check at head, and ran its own extractor and real-process probes. It did not re-run Pester.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --porcelain` was empty before this review wrote its artifacts.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: the two new hook files are covered at 97.96% and 98.70% of lines.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller supplied the branch, worktree, merge base, head, feature folder, PR context paths, AC source, and prior inputs; none of these limits the files audited or waives a language. The audit scope is the full diff against the merge base, not only the cycle 1 change.

---

## Evidence Location Compliance

`scripts/dev_tools/validate_evidence_locations.py --root <item worktree>` exited 0 with no output. `git diff --name-only` of the merge base against head lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/regression-testing/`, and `<FEATURE>/evidence/other/`. No violations were found.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New rows call pure functions or mock `Test-Path` and `Get-CodexReviewCoverageWorktreeList`; leak scan 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per `It`, tagged `1114:`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 8 shards, 16066 tests in 251.30 s (merged JUnit `time`). |
| **Determinism** - Consistent results | ✅ PASS | No clock read, randomness, network, real git, or temporary file in the new rows. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange-Act-Assert comments in the resolver row; outcome assertions on exact paths and reason codes. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | ✅ PASS | `.codex/hooks/validate-feature-review-coverage.ps1` 175 of 175 lines (100.00%; Phase 0 baseline 100.00%). |
| **New Code Threshold** | ✅ PASS | `validate-feature-review-coverage-freshness.ps1` 48 of 49 (97.96%); `feature-review-coverage-target.ps1` 76 of 77 (98.70%; pre-cycle 98.51%). |
| **Comprehensive Tests** | ✅ PASS | Cycle 1 added rows for a labelled and a backticked absolute path under a root with a space, sentence-final `.` and `:`, a deeper `..` path, a two-audit labelled line, and resolver resolution under a space root. No row covers a valid audit cited beside a non-audit `..` path (CR-3, non-blocking). |
| **Positive Flows** - Valid inputs | ✅ PASS | Single audit, versioned and audit-folder shapes, space roots, trailing punctuation, greatest-timestamp selection, fresh reports. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Null and non-string messages, `..` segments, cross-folder audits, absent audit beneath the item root. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Report written at the reference commit time passes; whitespace roots and trailing punctuation are handled. |
| **Error Handling** - Error paths | ✅ PASS | Git non-zero, empty, non-integer, and throwing invokers fail closed; four `B1` dependency rows pass. |
| **Concurrency** - If applicable | N/A | The hook is a single short-lived process. |
| **State Transitions** - If applicable | ✅ PASS | `stop_hook_active` true yields `continue = false` for the D2 block and the freshness block. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.06% lines -> Post-change: 94.13% lines. Change: +0.07 pp. New/changed-code coverage: 99.34% lines. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/evidence/qa-gates/pester-parallel.2026-11-07T20-33.md.

Thresholds: the root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern. Pester reports no branch figure, and no branch threshold applies to PowerShell.

PowerShell detail. This review parsed the root LINE counter of `artifacts/pester/powershell-coverage.xml` (written 20:32 UTC, after the last production commit at 20:25 UTC): 24714 covered, 1542 missed (94.13%). `artifacts/pester/pester-junit.xml` reads 16066 tests, 0 failures, 0 errors, 10 disabled, which identifies the full merged run of the cycle 1 final gate. The changed-code figure sums the three measured production files: 299 of 301 lines. The two uncovered lines are the default `GitInvoker` line of the twin and the body line of `Invoke-CodexReviewCoverageGitExe`, both real-git seams that tests mock by design. The bundle copies are byte-identical to their sources (SHA-256 compared by this review) and are not measured separately. Changed lines of the modified hook show no regression against the Phase 0 baseline (100.00% before and after).

---

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Arrange-Act-Assert** | ✅ PASS | Comment-marked sections in the entry rows and the new resolver row. |
| **Actionable failure messages** | ✅ PASS | Exact path lists and reason codes asserted; reason substrings asserted. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No external services** | ✅ PASS | Git is reached only through `Invoke-CodexReviewCoverageGitExe`, mocked in every row. |
| **No temporary files** | ✅ PASS | The new rows create no file. |
| **Linux-safe fixtures** | ✅ PASS | `/synthetic root/repo` and other `/`-rooted forward-slash literals; Linux CI is a pending CI-dependent criterion. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policy audit produced** | ✅ PASS | This file. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Policies read and baseline captured** | ✅ PASS | `evidence/baseline/` holds the Phase 0 baselines and the cycle 1 reference `scope-check.2026-11-07T20-14.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity** | ✅ PASS | Three candidate sources feed one examination loop in one function. |
| **Reusability** | ✅ PASS | Reuses `Resolve-HookTargetWorktree` and `Get-HookTargetWorktreeRelativePath`; no second resolver. |
| **Separation of concerns** | ✅ PASS | Parsing and selection are pure; git calls sit behind one wrapper seam. |
| **Correctness of extraction rules** | ✅ PASS | CR-1 shapes are extracted (verified by direct calls and real-process runs). CR-3 (Low): the `..` check also applies to non-audit candidates; fail-closed and non-blocking. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File size** | ✅ PASS | Production files 387, 245, and 145 logical lines (Codex 500-line cap held). Test files 356, 267, 423, and 506 lines. No file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Functions-only helpers** | ✅ PASS | Both new files hold no statement outside function definitions. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names and help** | ✅ PASS | Help of `Get-CodexReviewPolicyAuditPath` states the three sources, the punctuation rule, eligibility, and the traversal order. |

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
| **Brief updated** | ✅ PASS | Six brief copies unchanged by cycle 1; brief contract tests pass. |

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
| **Fail closed** | ✅ PASS | Every unresolvable target blocks; CR-3 is a fail-closed false block, not a false pass. |
| **No Python in hooks** | ✅ PASS | No `.py` file under `.codex/hooks`; no Python invocation. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **CmdletBinding and typed parameters** | ✅ PASS | Unchanged signature of the cycle 1 function. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **format, analyze, test in order** | ✅ PASS | `qa-gates/` artifacts at 20-25, 20-25, 20-27 (leak scan), 20-33. |

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
| **Mock the wrapper, not git** | ✅ PASS | The new resolver row mocks `Get-CodexReviewCoverageWorktreeList`. |
| **Mock signature parity** | ✅ PASS | Existing mocks unchanged. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive row names** | ✅ PASS | Seven `1114:` rows named as in the remediation plan. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Parallel gate** | ✅ PASS | One `Invoke-PoshQCParallelTest` run for fail-before and one for the final gate. |

---

## 5. Test Coverage Detail

### feature-review-coverage-target.Tests.ps1 (41 tests)

**Coverage:** `feature-review-coverage-target.ps1` 98.70% of lines.

**Not covered:** 1 line, the body of the real-git seam.

### validate-feature-review-coverage-freshness.Tests.ps1 (21 tests)

**Coverage:** `validate-feature-review-coverage-freshness.ps1` 97.96% of lines; unchanged by cycle 1.

**Not covered:** 1 line, the default `GitInvoker` parameter value.

### validate-feature-review-coverage.Coverage.Tests.ps1 (40 tests)

**Coverage:** `validate-feature-review-coverage.ps1` 100.00% of lines.

**Not covered:** nothing.

---

## 6. Test Execution Metrics

| Gate | Tests | Failed | Skipped | Duration |
|------|-------|--------|---------|----------|
| Pester parallel (cycle 1 final) | 16066 | 0 | 10 | 251.30 s |
| Pester parallel (cycle 1 fail-before) | 16066 | 6 | 10 | not recorded |
| Pester parallel (Phase 0) | 15881 | 0 | 10 | 1374.61 s |
| pytest contract set (this review) | 50 | 0 | 0 | 5.98 s |

Fail-before: the six CR-1 and CR-2 rows failed on outcome assertions against the unfixed extractor, and the two-audit guard row passed (`evidence/regression-testing/fail-before.2026-11-07T20-23.md`). This review confirmed the discrimination independently by running the pre-cycle extractor in the same probe harness.

---

## 7. Code Quality Checks

**For PowerShell:**
- PSScriptAnalyzer: 0 findings over 201 files.
- Formatter: 0 differences.
- Leak scan: 570 files, 0 failures.

**Notes:**
- Real-process probes by this review: the head hook files copied under a root containing a space, with a policy audit and an empty PR summary, run through `pwsh -File` with SubagentStop payloads; results recorded in the code review.

---

## 8. Gaps and Exceptions

### Identified Gaps

- CR-3 (non-blocking, Low): the `..` check applies to every candidate containing `docs/features/active/`, so a valid audit cited beside a non-audit `..` path blocks with `AUDIT_PATH_TRAVERSAL`, and the reason calls the non-audit path "the policy-audit path".
- Info: an absolute path under a root that contains a space is not extracted when the label is wrapped in Markdown emphasis (`**policy-audit-path:**`) or when text follows the path on the label line. The pre-cycle extractor also failed these shapes.
- Info (carried): 8.3 short-name absolute paths do not match a long-name session root (shared resolver, out of scope).

### Approved Exceptions

None.

### Removed/Skipped Tests

None in cycle 1. The rows `returns no audit when the active folder is absent` and `returns the most recently written audit` were replaced earlier by target-selection rows, as the spec requires.

---

## 9. Summary of Changes

### Commits in This PR/Branch

36 commits from `4224ca1ad` to `378c0035a`, including the merge of `origin/main` (`d5a211dd0`). Production commits: `5a5765d56` (freshness twin), `40bb0343f` (target functions), `5a37633e6` (hook fix), `7fe54399b` (brief), `137b9a727` (cycle 1 extraction fix).

### Files Modified

See the Code Under Test line above.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

No blocking finding remains. CR-1 is resolved and verified by direct calls, the parallel gate, and real-process runs. CR-3 is non-blocking.

**Fail-closed reminder:** numeric post-change coverage is recorded for the one changed coverage language, and changed-code coverage is recorded for the changed production files.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

✅ PASS.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:** ✅ PASS.

#### Unit Test Policy (Sections 1 and 4)

✅ PASS: coverage PASS; scenario completeness PASS with the CR-3 row noted as optional.

---

## Appendix A: Test Inventory

- `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1` (new, 41 tests)
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
- Review: `validate_evidence_locations.py --root <worktree>`; coverage XML parse; extractor probes against head and pre-cycle files; real-process hook runs under a root containing a space
