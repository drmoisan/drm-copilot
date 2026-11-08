# Feature Audit: Python Tokenizer Scaling (#1019), Re-Audit After Remediation Cycle 1

---

**Audit Date:** 2026-11-06
**Feature Folder:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `bug/docs-tokenizer-scaling-1019`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `6a4080ac9` as supplied; the tip moved to `8fa914935` at 21:25 UTC during this review)
- **Head branch/commit:** `bug/docs-tokenizer-scaling-1019` (commit `40e598f9fbc18c1dd629447a43d1a76fea03299d`)
- **Merge base:** `6a4080ac96873cfaf0295d9b82b1d1d5d1cf3baf`, unchanged by the tip movement
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/evidence/**`
  - Prior review inputs: `remediation-inputs.2026-11-06T18-47.md`, `remediation-plan.2026-11-06T18-47.md`
  - Reviewer runs: `policy-audit.2026-11-06T21-29.md`, `## Reviewer Re-Verification at Head`
- **Feature folder used:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
- **Requirements source:** `issue.md`, section `## Acceptance Criteria`
- **Work mode resolution note:** Explicit marker `- Work Mode: minor-audit` in `issue.md`.
- **Scope note:** The audit covers the full branch diff against the resolved base. The `MODULE` hash at head is `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702`. The `## Acceptance Criteria` section of `issue.md` is byte-identical to the version at `14e88f70b`, the commit of the prior review (`cmp` exit 0).

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
| 1 | Root cause measured before the production change | PASS | `evidence/baseline/root-cause-profile.2026-11-06T17-25.md` holds both tables. The file was added in `99b26392e`, before the fix commit `39a0bdbe1`. | `git log --oneline 6a4080ac9..HEAD` | The profile states that AMSI attribution is not established; the module `.NOTES` now says so. |
| 2 | Candidate hunks present; no loop passes the whole source | PASS | Reviewer check with a fresh patch from `1332ba34f`: 12 added module lines present in order, 3 removed lines absent, hunk failures 0. `evidence/regression-testing/candidate-hunks.2026-11-06T19-10.md` agrees. The guard's first case passes at head. | `git show 1332ba34f -- MODULE SUITE`; `SCRATCH/issue-1019-hunkcheck.ps1` | The coding-cookie `for` loop passes `$lines[n]` at most twice per run; this is bounded, and the plan records it. |
| 3 | Tokenizer time approximately linear | PASS | `evidence/qa-gates/scaling-after.2026-11-06T18-33.md`: ratios from 1.72 to 2.09 at 8,000 units and above. Valid for the final hash through `evidence/regression-testing/comment-only-proof.2026-11-06T19-11.md`. Reviewer single-run spot check at head: 1.63 to 2.29 for names and strings, up to 64,000 units. | `SCRATCH/issue-1019-r2-scale.ps1` | Host-specific absolute times. Three reviewer ratios exceed 2, the highest 2.29, in a single run. Across the full eightfold size increase, time grew 7.9 times for names and 7.1 times for strings, so the spot check does not indicate superlinear growth. |
| 4 | Structural guard recorded failing on unfixed and candidate, passing on fixed | PASS | `evidence/regression-testing/guard-fail-before.2026-11-06T20-57.md`: unfixed 2 failed, candidate 1 failed, fixed 3 passed, mutant 2 failed. Reviewer mutants built independently: `unbounded-assign` and `match-inline` each fail the intended guard case. The guard cases use no sleep, timing threshold, or temporary file. | Pester 6.2.0 on each mutant tree | Closes prior finding F1. The guard pins the bound's shape, not the constant's value; a Minor row in the code review records this. |
| 5 | Behavior unchanged | PASS | `evidence/regression-testing/differential.2026-11-06T18-33.md`: 1098 inputs, zero differing hashes, with a negative control. Reviewer differential at the final hash: 3470 seeded inputs, 0 differences for `MODULE` and for two small-window variants. Reviewer runs: `SUITE` 57 passed, 0 failed; docs folder 2050 passed, 0 failed. | `SCRATCH/issue-1019-r2-fuzz.ps1`; Pester 6.2.0 | The token-limit and 1,048,576-byte inputs are covered by `SUITE` on the fixed module. |
| 6 | Bundle byte-identical; contract tests pass | PASS | Reviewer `sha256sum` and `cmp`: both `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702`. `evidence/regression-testing/mirror-parity.2026-11-06T19-11.md` records the contract tests at this hash. | `sha256sum`; `cmp` | The reviewer's direct `pytest` command was refused by the session gate, so the contract-test half rests on the recorded run. Both files are unchanged since that run, and CI re-runs these tests. |
| 7 | Toolchain passes; coverage at least 85%; durations recorded | PASS | Reviewer at head: formatter text equal, analyzer 0 findings, 57 passed. `MODULE` line coverage 100.00% (151 of 151), re-parsed from `artifacts/pester/powershell-coverage.xml`. `evidence/qa-gates/suite-duration-before.2026-11-06T17-49.md` and `suite-duration-after.2026-11-06T21-14.md`. | `SCRATCH/issue-1019-r2-static.ps1` | Before: no finish within 600 s. After: 23.32 s recorded. |
| 8 | CI green on the PR head and merged (CI-dependent) | UNVERIFIED | Pending-CI. No pull request or workflow run exists for this branch, and the PR context reports CI status as not available. | Verified at S9 by the item's own orchestrator run | Listed pending-CI per `acceptance-criteria-tracking`, `### CI-Dependent Criteria`. Not a review blocker. |

---

## Summary

**Overall Feature Readiness:** READY FOR PR, after a sync with the base

**Criteria summary:**
- **PASS:** 7 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-8, pending-CI)
- **FAIL:** 0 criteria

**Prior finding:** F1 is closed. Each related non-blocking item is delivered.

**Top gaps preventing PASS:**

1. None among the seven criteria that can be evaluated before the pull request exists. AC-8 waits on CI and the merge.

**Recommended follow-up verification steps:**

1. Sync the branch with `8fa914935` and refresh `merge-check-1034`.
2. At S9, confirm green CI on the final PR head, including the two push-down contract test files, and check off AC-8.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- AC-1 through AC-7 were already checked in `issue.md`, and each is evaluated as PASS here.
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
