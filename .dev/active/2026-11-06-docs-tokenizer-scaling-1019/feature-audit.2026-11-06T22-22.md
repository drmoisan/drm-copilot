# Feature Audit: Python Tokenizer Scaling (#1019), Re-Audit After Remediation Cycle 2

---

**Audit Date:** 2026-11-06
**Feature Folder:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `bug/docs-tokenizer-scaling-1019`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit after remediation cycle 2

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (tip `8fa914935`, re-fetched in this review)
- **Head branch/commit:** `bug/docs-tokenizer-scaling-1019` (commit `3649bc628c972c82869ea5ff6c1d23309037e4f9`)
- **Merge base:** `8fa914935e3efec81d1e970bc525d907a9458203`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/evidence/**`
  - Prior review inputs: `remediation-inputs.2026-11-06T21-37.md`, `remediation-plan.2026-11-06T21-37.md`
  - Reviewer runs: `policy-audit.2026-11-06T22-22.md`, `## Reviewer Re-Verification at Head`
- **Feature folder used:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
- **Requirements source:** `issue.md`, section `## Acceptance Criteria`
- **Work mode resolution note:** Explicit marker `- Work Mode: minor-audit` in `issue.md`.
- **Scope note:** The audit covers the full branch diff against the resolved base. The `MODULE` hash at head is `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702`, the value at the prior review. The `## Acceptance Criteria` section of `issue.md` is byte-identical to the version at `c533c313a`, the start of cycle 2 (`cmp` exit 0).

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
| 1 | Root cause measured before the production change | PASS | `evidence/baseline/root-cause-profile.2026-11-06T17-25.md` holds both tables. The file was added in `99b26392e`, before the fix commit `39a0bdbe1`. | `git log --oneline 8fa914935..HEAD` | The profile states that AMSI attribution is not established; the module `.NOTES` says so. |
| 2 | Candidate hunks present; no loop passes the whole source | PASS | Reviewer check with a fresh patch from `1332ba34f`: 12 added module lines present in order, 3 removed lines absent, hunk failures 0. `evidence/regression-testing/candidate-hunks.2026-11-06T21-53.md` agrees. The guard's first case passes at head, and the loop was read in full. | `git show 1332ba34f -- MODULE SUITE`; `SCRATCH/issue-1019-hunkcheck.ps1` | The coding-cookie `for` loop passes `$lines[n]` at most twice per run; this is bounded, and the plan records it. |
| 3 | Tokenizer time approximately linear | PASS | `evidence/qa-gates/scaling-after.2026-11-06T18-33.md`: ratios from 1.72 to 2.09 at 8,000 units and above. Valid for the final hash through `evidence/regression-testing/comment-only-proof.2026-11-06T19-11.md`. | `sha256sum` of `MODULE` | Not re-measured in this review, because `MODULE` is byte-identical to the module the prior reviewer's spot check measured. |
| 4 | Structural guard recorded failing on unfixed and candidate, passing on fixed | PASS | `evidence/regression-testing/guard-fail-before.2026-11-06T21-55.md`: unfixed 3 failed, candidate 2 failed, fixed 4 passed. Reviewer mutants and thirteen boundary and evasion probes agree, and the two mutants that passed in the prior review now fail. The guard cases use no sleep, timing threshold, or temporary file. | Pester 6.2.0 on each mutant tree | One probe that bypasses the constant passes the guard; a code-review Info row records it. The criterion does not require that form to fail. |
| 5 | Behavior unchanged | PASS | `evidence/regression-testing/differential.2026-11-06T18-33.md`: 1098 inputs, zero differing hashes, with a negative control. Prior reviewer differential at the same module hash: 3470 seeded inputs, 0 differences. Reviewer runs at head: `SUITE` 58 passed, 0 failed; docs folder 2051 passed, 0 failed, 0 skipped, 0 not run in 302.69 s. | Pester 6.2.0 | The token-limit and 1,048,576-byte inputs are covered by `SUITE` on the fixed module. |
| 6 | Bundle byte-identical; contract tests pass | PASS | Reviewer `sha256sum` and `cmp`: both `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702`. `evidence/regression-testing/mirror-parity.2026-11-06T19-11.md` records 16 contract tests passed at this hash. | `sha256sum`; `cmp` | The reviewer's direct `pytest` command was refused by the session gate, so the contract-test half rests on the recorded run. Both files are unchanged since that run, and CI re-runs these tests. |
| 7 | Toolchain passes; coverage at least 85%; durations recorded | PASS | Reviewer at head: formatter text equal, analyzer 0 findings, 58 passed. `MODULE` line coverage 100.00% (151 of 151), re-parsed from `artifacts/pester/powershell-coverage.xml`. `evidence/qa-gates/suite-duration-before.2026-11-06T17-49.md`, `suite-duration-after.2026-11-06T18-28.md`, and `suite-duration-after.2026-11-06T22-09.md`. | `SCRATCH/issue-1019-r2-static.ps1` | Before: no finish within 600 s. After: 22.46 s recorded. |
| 8 | CI green on the PR head and merged (CI-dependent) | UNVERIFIED | Pending-CI. No pull request or workflow run exists for this branch (`gh pr list` and `gh run list` on the branch return nothing). | Verified at S9 by the item's own orchestrator run | Listed pending-CI per `acceptance-criteria-tracking`, `### CI-Dependent Criteria`. Not a review blocker. |

---

## Summary

**Overall Feature Readiness:** READY FOR PR

**Criteria summary:**
- **PASS:** 7 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-8, pending-CI)
- **FAIL:** 0 criteria

**Prior rows:** R1, R2, and R3 are closed.

**Top gaps preventing PASS:**

1. None among the seven criteria that can be evaluated before the pull request exists. AC-8 waits on CI and the merge.

**Recommended follow-up verification steps:**

1. At S9, confirm green CI on the final PR head, including the two push-down contract test files, and check off AC-8.
2. Re-run `merge-check-1034` if the 1034 tip moves past `fd6d78930` before this branch merges.

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
