# Policy Compliance Audit: test launcher drops positional Jest path (Issue #1192)

---

**Audit Date:** 2026-11-15
**Code Under Test:** merge base `1df569f65ccdcca86cc9adeb5a1a33ef56f988cb` of `origin/main` and reviewed head `3c42b7be6803f2afbf69c210f352ebf8473e5d93` on `bug/test-launcher-jest-positional-path` (PR #1194); the diff between them lists the changed files.
- PowerShell production: `.claude/hooks/test-execution-policy.ps1` (447 logical lines) and three byte-identical copies in `.codex/hooks/` and the two `extensions/drm-copilot/resources` bundles
- PowerShell tests: `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` (419 logical lines), `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` (547 logical lines)
- JavaScript configuration: `extensions/drm-copilot/jest.config.cjs` (one comment line)
- Feature folder documents and evidence

Scope: full branch diff `1df569f65..3c42b7be6` against `origin/main`. Changed-file inventory taken from `git diff --name-only`; PR context at `artifacts/pr_context.summary.txt`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 identical hook copies, 2 test files | 26870 tests at the final gate (+18 new) | 0 failures, 0 errors | 96.01% lines repo-wide (44275 of 46114); hook 100% (170 of 170) | 96.01% lines (44281 of 46120); hook 100% (173 of 173) | 100% (the three added source lines are covered) |

Languages with zero changed files on the branch: Python, C#, Bash. The one changed `.cjs` line (`extensions/drm-copilot/jest.config.cjs`) is a comment in a configuration file that is not production runtime code and holds no executable change, so it carries no coverage row; the coverage verdict for it is PASS (vacuous), and the absence of `coverage/lcov.info` does not mask a changed executable line.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - the only changed JavaScript line is a comment; no executable line to cover`
- TypeScript post-change coverage artifact: `N/A - same reason`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192/evidence/baseline/pester-gate.2026-11-15T18-03.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (present), summarized in `evidence/qa-gates/final-pester-gate.2026-11-15T19-51.md`
- Python baseline coverage artifact: `N/A - zero changed Python files`
- Python post-change coverage artifact: `N/A - zero changed Python files`
- Per-language comparison summary: Section 1.2.1 below

Assumptions recorded: the review did not rerun any coverage generation (evidence model). The final gate ran at 19-51; the later commits change only feature-folder documents and merge `origin/main` (the four hook copies are byte-identical at the head).

---

## Executive Summary

The change reorders the command words built by `New-TestExecutionSuiteCommand` so that, for the jest and pester runners, the caller's extra arguments precede the lane-exclusion words. Jest parses `testPathIgnorePatterns` as an array option that would otherwise consume a later positional path. No other runner changes order, and with no extras the command is unchanged. The four copies of the hook are byte-identical at the head (blob hash `fb929f590c2c7ec1eae9d254fbc7a1d532c60041` for each). The Pester gate passes with 26870 tests, 0 failures, and hook coverage at 100%. The fail-before record shows the five new or updated ordering tests failing against the unmodified builder. No Python was added.

CI state at review time: the PR checks include completed passes (Change scope, CI full run, NPM audit, docs-validation, build-check, security-scan, Extension Tests on ubuntu) and pending jobs (PowerShell QC shards, hook suites on Linux, Python quality, Windows extension tests). The pending jobs are awaiting CI, which is not a failure and is not a blocking finding.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (no new project; the changed hook already sits in an existing classified path)

**Language-specific policies evaluated:**
- N/A Python: zero changed Python files
- PASS PowerShell
- PASS TypeScript/JavaScript (comment-only change)
- N/A Bash and C#: no shell or C# file changed
- N/A GitHub Actions: no workflow changed, so the modified-workflow green-run requirement does not apply

**Temporary artifacts cleanup:**
- PASS No scratch file is committed; the diff lists none outside the feature folder
- PASS No tooling script was added

---

## Rejected Scope Narrowing

The caller prompt directs the reviewer to read the final-QC static artifacts instead of re-running format, lint, and type checks. That is the evidence model of this review (artifacts are inspected, not regenerated), not a narrowing of scope to a plan, phase, file subset, or language, and no check for any language with changed files was skipped. No scope narrowing was detected.

---

## Evidence Location Compliance

`git diff --name-only 1df569f65..3c42b7be6` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence sits under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`. Result: PASS, no violations.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | New cases build a policy through `Get-TestPolicy -Text` and share no state. |
| Isolation | PASS | Each case targets one runner or one launcher path. |
| Fast execution | PASS | No process start or sleep; launcher cases use the injected state object. |
| Determinism | PASS | Pure word-list assertions; no clock, RNG, or environment write. |
| Readability | PASS | Arrange/Act/Assert comments and descriptive names; the updated case states why the order changed. |

### 1.2 Coverage and Scenarios

| Scenario | Status | Evidence |
|---|---|---|
| Positive flows | PASS | Single jest positional; positional plus flag; pester `-TestPath`. |
| Negative flows | PASS | Integration operand refused with exit 2 and no process started. |
| Edge cases | PASS | No extras leaves jest and pester commands unchanged. |
| Regression guard for other runners | PASS | pytest, dotnet-test, and bats keep suite words, exclusions, extras. |
| Concurrency and state | N/A | Pure builder. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.01% lines repo-wide (44275 of 46114) -> Post-change: 96.01% lines (44281 of 46120). Change: +0.00 percentage points; the hook file stays at 100% (170 of 170 to 173 of 173). New/changed-code coverage: 100% (the three added source lines are covered by the jest, pester, pytest, dotnet-test, and bats cases). Pester reports no branch counter, so the line threshold governs. Disposition: PASS. Evidence: `evidence/qa-gates/final-pester-gate.2026-11-15T19-51.md`, `artifacts/pester/powershell-coverage.xml`.
- TypeScript: Baseline: no executable change -> Post-change: no executable change. Change: not applicable (comment only). New/changed-code coverage: 100% (vacuous). Disposition: PASS. Evidence: `git diff` of `extensions/drm-copilot/jest.config.cjs` shows a single comment line.
- Python, C#, Bash: zero changed files on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

PASS. New cases use Arrange, Act, Assert sections and exact-string assertions that name the expected word order.

### 1.4 External Dependencies and Environment

PASS. No temp file, no network, no process start. The Linux hook-suite constraint (no drive letters, no Windows path literals) holds: the new cases use forward-slash relative paths. The regular-expression text in the Jest ignore words is pattern text from the policy, not a path, and the pre-existing case already carries it.

### 1.5 Policy Audit Requirement

PASS. This document is the audit.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. A research record and a spec with root-cause analysis precede the change.

### 2.2 Design Principles

PASS. The fix is the simplest order change in one function; no signature change; no `--` sentinel; the rejected alternatives are recorded in the spec.

### 2.3 Module and File Structure

PASS. The hook is 447 logical lines (below the 500 guidance tier); the two test files are 419 and 547 (below the 700 advisory tier). No file exceeds 800 lines and `config/file-size-baseline.json` is unchanged.

### 2.4 Naming, Docs, and Comments

PASS. The comment-based help of `New-TestExecutionSuiteCommand` states the reason for the order. The `jest.config.cjs` comment now says seven modules, matching the seven entries of `jest.docs-coverage.json`.

### 2.5 After Making Changes - Toolchain Execution

PASS. Static format and analyze records show EXIT_CODE 0 and zero findings over the six PowerShell files (`evidence/qa-gates/final-static-powershell.2026-11-15T19-29.md`). The full Pester gate and the contract checks passed in parallel runs only.

### 2.6 Summarize and Document

PASS. Task checks, phase gates, final gates, the fail-before record, the scope check, and a self-review are recorded under `evidence/`.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

PASS. The edited function keeps its `CmdletBinding`, `SuppressMessage` justification, and typed parameters. The runner comparison uses the case-sensitive `-ceq` operator. No new Python was added.

### Section 3C: Documentation Surface Check

N/A. `docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check produces no finding.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

PASS. Tests live under `tests/scripts/...` mirroring the production layout, run in both hook copies (`.claude/hooks` and `.codex/hooks`) through the existing `-ForEach` copy matrix, and use in-memory policy text.

---

## 5. Test Coverage Detail

### test-execution-policy.ps1

The builder is exercised by the jest cases (single positional, positional plus flag, no extras), the pester cases (`-TestPath` and no extras), and the pytest, dotnet-test, and bats ordering cases. The changed lines are 100% covered in both hook copies (173 of 173).

---

## 6. Test Execution Metrics

| Metric | Value |
|---|---|
| Pester tests, baseline | 26852 (0 failures) |
| Pester tests, final | 26870 (0 failures, 0 errors, 22 disabled as before) |
| Contract checks | 56 passed, 0 failed (push-down resource and pack-manifest contracts, execution-environment brief contract) |
| Fail-before proof | 9 failing cases (5 distinct names) against the unmodified builder |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | compare-only check over six files | 0 differences | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1` | 0 findings | PASS |
| Pester Tests | launcher pester suite, one parallel run | 26870 tests, 0 failures | PASS |
| Contract tests | one `pytest -n auto` run over five contract files | 56 passed | PASS |

**Notes:** Quality checks were read from the final-QC artifacts (the review did not rerun them). Review-time commands: `git diff` of the hook, the two test files, and `jest.config.cjs`; blob-hash comparison of the four hook copies (identical); logical line counts; scan of the diff for forbidden evidence paths.

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| CI full run, Change scope, build-check, docs-validation, security-scan, NPM audit, Extension Tests (ubuntu) | pass | completed green at review time | `3c42b7be6` | `gh pr checks 1194` |
| PowerShell QC shards and static, hook suites (Linux), Python quality, Windows extension tests | pending | not yet reported | `3c42b7be6` | `gh pr checks 1194`; workflow_dispatch run 43756451001 queued |

Local evidence (the final Pester gate with 0 failures) agrees with the expected outcome pass; the pending jobs are awaiting CI and are not a failure.

---

## 8. Gaps and Exceptions

### Identified Gaps

- The Jest array-option cause is inferred from the option definition and not reproduced with a live full Jest run; the spec states this and the unit tests pin the word order. Non-blocking.
- CI results for the PowerShell shards, the Linux hook suites, and Windows jobs are pending at review time (awaiting CI, non-blocking).

- Resolved in this review (F1): `artifacts/pester/powershell-coverage.xml` (written 2026-11-15T19:51:16Z) predated the merge commit `3c42b7be6` (2026-11-15T20:06:58Z) that brought PR #1193 PowerShell files into the branch. The reviewer reran the launcher Pester gate at the head (`evidence/qa-gates/review-pester-gate.2026-11-15T20-28.md`): 26903 tests, 0 failures, repo-wide 96.00% lines (44343 covered, 1846 missed; the difference from 96.01% is the merged shard helper), hook 173 of 173 lines, report written 2026-11-15T20:27:16Z.

### Approved Exceptions

None.

### Removed/Skipped Tests

None. The existing Jest case was updated, not removed or weakened.

---

## 9. Summary of Changes

### Commits in This PR/Branch

Fix commit `a5f4b7e00`, evidence commit `846184f85`, and the merge of `origin/main` at `3c42b7be6`.

### Files Modified

The four hook copies, two Pester test files, `jest.config.cjs` (comment), and the feature folder.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT (no blocking finding; F1 stale report closed by a review-time gate rerun; CI pending)

Toolchain, coverage, file size, evidence location, mirror parity, determinism, dependency, and scope requirements are met.

**Fail-closed reminder:** every required baseline artifact, QA artifact, coverage metric, and coverage-comparison artifact is present.

### Metrics Summary

- PASS 0 Pester failures; 56 contract tests passed
- PASS hook coverage 100% (173 of 173); repo-wide 96.01%
- PASS four hook copies byte-identical
- Awaiting CI: jobs listed in the CI Cross-check

### Recommendation

**Proceed to merge once the pending CI jobs report green.**

---

## Appendix A: Test Inventory

New or updated cases: updated jest positional case; single jest positional; positional plus flag; no extras for jest and pester; pester `-TestPath`; pytest, dotnet-test, bats ordering; launcher positional order; launcher integration-operand refusal.

## Appendix B: Toolchain Commands Reference

`sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (one parallel run); the contract-test pytest run recorded in `evidence/qa-gates/final-contracts.2026-11-15T20-05.md`.
