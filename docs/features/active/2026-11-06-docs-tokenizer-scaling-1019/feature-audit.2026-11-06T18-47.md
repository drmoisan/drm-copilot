# Feature Audit: Python Tokenizer Scaling (#1019)

---

**Audit Date:** 2026-11-06
**Feature Folder:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `bug/docs-tokenizer-scaling-1019`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `eca4fc203`)
- **Head branch/commit:** `bug/docs-tokenizer-scaling-1019` (commit `fe9a4023d`)
- **Merge base:** `c4a2398aa93c721e06f6878851526d4338ec98c7`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/evidence/**`
  - Additional evidence: `evidence/qa-gates/review-reverification.2026-11-06T18-47.md`
- **Feature folder used:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
- **Requirements source:** `issue.md`, section `## Acceptance Criteria`
- **Work mode resolution note:** Explicit marker `- Work Mode: minor-audit` in `issue.md`.
- **Scope note:** The audit covers the full branch diff against the resolved base. Scaling, differential, and guard evidence were recorded against commit `39a0bdbe1`; the only later commit changes the feature folder only, and the module SHA-256 at head equals the recorded value.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/issue.md` - only source

### Acceptance criteria

1. Root cause is verified by measurement before any production change, and the measurements (call cost against source length, tokenizer time against source size for the unfixed module and the candidate) are recorded under `evidence/baseline/`.
2. The production hunks of commit 1332ba34f are present byte for byte in `.claude/lib/docs/DocsPythonTokens.psm1`, and no loop in the module passes the whole source to a .NET method as an argument.
3. Tokenizer time is approximately linear in source length for a names-only source and a string-heavy source: doubling the source no more than about doubles the time, recorded under `evidence/qa-gates/`.
4. A structural regression guard in `DocsPythonTokens.Tests.ps1` uses no sleep, timing threshold, or temporary file, and is recorded failing on the unfixed module and on the candidate module and passing on the fixed module (`evidence/regression-testing/`).
5. Behavior is unchanged: the existing `DocsPythonTokens.Tests.ps1` cases pass, new window-boundary cases pass, and a differential run over the unfixed and fixed modules reports identical tokens and diagnostics (`evidence/regression-testing/`).
6. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPythonTokens.psm1` is byte-identical to the module, and the push-down resource contract and manifest tests pass.
7. The PowerShell toolchain (format, analyze, test) passes on the changed files, `DocsPythonTokens.psm1` line coverage is at least 85%, and the before and after suite durations are recorded under `evidence/qa-gates/`.
8. CI is green on the pull request head and the pull request is merged into `epic/documentation-estate-tooling-integration` (CI-dependent).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Root cause measured before the production change | PASS | `evidence/baseline/root-cause-profile.2026-11-06T17-25.md` holds both tables. The file was added in `99b26392e`, before the fix commit `39a0bdbe1`. | `git log --oneline c4a2398aa..HEAD` | The profile states that AMSI attribution is not established. |
| 2 | Candidate hunks present; no loop passes the whole source | PASS | `evidence/regression-testing/candidate-hunks.2026-11-06T18-09.md`: 12 added lines found, 3 removed lines absent. Reviewer read: the loop passes `$source`, the bounded window, to `Match`, and `$sourceText` only as invocant or bound parameter. | `git show 1332ba34f --stat`; `git diff c4a2398aa...HEAD -- .claude/lib/docs/DocsPythonTokens.psm1` | The coding-cookie `for` loop passes `$lines[n]` at most twice per run; on a one-line source that element is the whole source. This is bounded, and the plan records it. A source of at most 1,024 characters is its own window, also bounded. |
| 3 | Tokenizer time approximately linear | PASS | `evidence/qa-gates/scaling-after.2026-11-06T18-33.md`: ratios from 1.72 to 2.09 at 8,000 units and above for names, strings, and long string bodies. | `sh SCRATCH/issue-1019-p2-t7.sh` (recorded) | Host-specific absolute times. The reviewer did not re-time. |
| 4 | Structural guard recorded failing on unfixed and candidate, passing on fixed | PASS | `evidence/regression-testing/guard-fail-before.2026-11-06T18-28.md`: unfixed 2 failed, candidate 1 failed, fixed 2 passed. `SUITE` guard cases use no sleep, timing threshold, or temporary file. | `pwsh -NoProfile -File SCRATCH/issue-1019-guard-driver.ps1` (recorded) | The criterion as written is met. Code-review finding F1 records that the guard also passes on an unbounded-window mutant. That is a test-strength finding handled in remediation, and the re-audit re-evaluates this row after the guard changes. |
| 5 | Behavior unchanged | PASS | `evidence/regression-testing/differential.2026-11-06T18-33.md`: 1098 inputs, zero differing hashes, negative control 80 of 93 differ. Reviewer run of `SUITE`: 56 passed, 0 failed. | Pester 6 on `SUITE` (`review-reverification.2026-11-06T18-47.md`) | Token-limit and 1,048,576-byte inputs excluded from the unfixed run with a stated reason, and covered by `SUITE` on the fixed module. |
| 6 | Bundle byte-identical; contract tests pass | PASS | Reviewer `sha256sum`: both `6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf`. `evidence/regression-testing/mirror-parity.2026-11-06T18-09.md`: 16 passed. | `sha256sum` over both paths; `poetry run pytest` (recorded) | The contract tests were not re-run by the reviewer; the two files are unchanged since. |
| 7 | Toolchain passes; coverage at least 85%; durations recorded | PASS | Reviewer: formatter text equal, analyzer 0 findings, 56 passed. Module line coverage 100.00% (151 of 151). `evidence/qa-gates/suite-duration-before.2026-11-06T17-49.md` and `suite-duration-after.2026-11-06T18-28.md`. | `sh SCRATCH/issue-1019-review.sh` | Before: no finish within 600 s. After: 27.07 s. |
| 8 | CI green on the PR head and merged (CI-dependent) | UNVERIFIED | Pending-CI. No pull request exists for this branch, and the PR context reports CI status as not available. | Verified at S9 by the item's own orchestrator run | Listed pending-CI per `acceptance-criteria-tracking`, `### CI-Dependent Criteria`. Not a review blocker per `orchestrate`, `## PR Creation Gate`, condition 2. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 7 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-8, pending-CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Code-review finding F1: the structural guard does not pin the window length bound. It is a remediation input and not an acceptance-criterion failure.

**Recommended follow-up verification steps:**

1. After remediation, run the guard on the unfixed, candidate, fixed, and unbounded-window modules, and re-review.
2. At S9, confirm green CI on the final PR head and check off AC-8.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- AC-1 through AC-7 were already checked in `issue.md` by the executor, and each is evaluated as PASS here.
- AC-8 is UNVERIFIED and remains unchecked.
- This review made no change to `issue.md`.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/issue.md`
- Total AC items: 8
- Checked off (delivered): 7
- Remaining (unchecked): 1
- Items remaining: CI is green on the pull request head and the pull request is merged into `epic/documentation-estate-tooling-integration` (CI-dependent).

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/issue.md` | 8 | 7 | 1 | Checkbox-backed; AC-8 pending-CI |

The `## Evidence Checklist` section of `issue.md` is outside `## Acceptance Criteria` and is not an acceptance-criteria source for `minor-audit`.
