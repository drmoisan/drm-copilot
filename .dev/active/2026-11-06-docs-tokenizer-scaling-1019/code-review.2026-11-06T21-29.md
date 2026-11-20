# Code Review: Python Tokenizer Scaling (#1019), Re-Audit After Remediation Cycle 1

---

**Review Date:** 2026-11-06
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `6a4080ac96873cfaf0295d9b82b1d1d5d1cf3baf`)
**Head Branch:** `bug/docs-tokenizer-scaling-1019` at `40e598f9fbc18c1dd629447a43d1a76fea03299d`
**Review Type:** Re-audit after remediation cycle 1

---

## Executive Summary

The branch removes the quadratic cost of `Get-DocsPythonToken` by slicing in `Read-DocsPythonStringEnd`, reusing `NextMatch` in the loop, and lexing a bounded window of the source. Cycle 1 tightened the structural guard, added a third guard case, and added the related comment and help changes. Evidence reviewed: the PR context, the full production and test diff, the feature evidence, reviewer runs of format, analyzer, `SUITE`, and the docs folder at head, ten mutated module trees, an independent differential over 3470 seeded inputs, a scaling spot check, and two merged CI coverage artifacts. F1 is closed and no blocking finding remains.

**What changed:**
`.claude/lib/docs/DocsPythonTokens.psm1` (`MODULE`) gains two constants, a margin rebase, a string rebase, and help notes; its bundle copy is byte-identical. `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` (`SUITE`) gains the candidate tests, a three-case structural guard, and window-boundary cases. Scope is three non-document files plus the feature folder. Since the prior review, the production file changed in comments only.

**Top 3 risks:**
1. The guard pins the shape of the bound and not its value: raising the window size constant to 1073741824 passes all 57 tests. Read from the code, that value restores whole-remainder `Match` calls on a string-heavy source; its run time was not measured. The self-review records this limit.
2. The base tip advanced by 98 commits during this review, and four PowerShell files changed there. A merge check reports no conflict, but tests on the synced head have not run.
3. `DocsCSharpTokens.psm1` and other modules keep the same call pattern, and no open issue found by search tracks their scaling.

**PR readiness recommendation:** **Go**, after the sync with the base. AC-8 stays pending-CI until S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | `Describe 'Get-DocsPythonToken structural scaling guard'` | Nothing pins the value of `$script:DocsPythonTokenWindowSize`. With the constant at 1073741824 the window covers the rest of the source at every string rebase, and `SUITE` still passes 57 of 57. | Optional: add an AST assertion in the guard describe that the constant is an integer literal at or below a stated ceiling, such as 65536. Keep the line outside the candidate suite hunks. | Not blocking. The regression needs a deliberate edit of a named constant, visible in review, where F1 was an unguarded structural change. The prior inputs did not require the value, and the self-review records the limit. A ceiling well above 1,024 would leave ordinary tuning free. | Mutant `size-constant-huge` in the policy audit, `## Reviewer Re-Verification at Head`; `self-review.2026-11-06T21-14.md`, `## Window-Size Limit`. |
| Minor | `.claude/lib/docs/DocsCSharpTokens.psm1` | Whole-source `Match` in a loop | Carried from the prior review: the same call pattern exists outside this item and was not measured. An open-issue search still finds only #1033, the feature that added the module. | Orchestrator or owner decides: a separate epic child or a tracking issue. Do not widen this item, because `issue.md` places it outside. | The same defect class may slow other suites. | `issue.md`; `follow_ups` in the orchestrator checkpoint. |
| Info | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | `It 'assigns the lexing window only from a Substring of the source text'` | The predicate selects assignments whose left side is a plain variable. A typed left side, `[string] $source = $sourceText.Substring($windowStart)`, is not selected, and that mutant passes 57 of 57. | No action required. If the guard is touched for the Minor row above, also unwrap `ConvertExpressionAst` on the left side. | The form is unlikely in this code, and the first assignment would still be checked. | Mutant `typed-evasion`. |
| Info | `.claude/lib/docs/DocsPythonTokens.psm1` | `$windowSize` reset in the string rebase | Removing the reset passes 57 of 57. The result is a larger window after a long token, followed by strings. No correctness change, and the production code keeps the reset. | No action. | A timing-free test cannot observe this without a further structural pin. | Mutant `no-string-reset`. |
| Info | `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/remediation-plan.2026-11-06T18-47.md` | Header | `Status` still reads `Authored by atomic-planner; awaiting combined preflight and execution`, with every task checked. | Update with the next touch of the file. | Record accuracy. | Inspection. |
| Info | `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/evidence/qa-gates/self-review.2026-11-06T21-14.md` | Output Summary | The record names merge base `c4a2398aa`, which was correct when written. The sync moved it to `6a4080ac9`. `MODULE` and `SUITE` are identical at both, so the changed-line result is unchanged; this review recomputed 29 of 29. | No action. | Avoids misreading an older record. | `git diff --stat c4a2398aa 6a4080ac96` over both paths is empty. |
| Info | Pull request | Issue reference | #1019 is the epic issue, titled `Epic: documentation-estate-tooling`. | Do not use a closing keyword for it in the PR body. | A closing keyword could close the epic when the integration branch reaches the default branch. | `artifacts/pr_context.summary.txt`. |
| Info | Branch | Base | The base tip is now `8fa914935` (PR #1091), 98 commits ahead of the branch. `git merge-tree` reports no conflict, and no file in the item's non-document set changed there. | Sync before opening the PR, and refresh `merge-check-1034` after the sync. | Keeps the PR diff current. | `git merge-tree --write-tree HEAD 8fa914935`, exit 0. |
| Info | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | `margin-3` mutant | A margin of 3 passes 57 of 57, and a margin of 2 fails three exponent cases. The trace in the prior review gives a two-character backtrack, so this is likely an equivalent mutant and the value 8 carries slack. | No action. | Separates a real gap from an equivalent mutant. | Mutants `margin-2` and `margin-3`. |

No file-size Warning applies: `MODULE` 271, bundle 271, and `SUITE` 537 logical lines.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- F1 is closed by the guard's second case, which now requires exactly two `.Substring` arguments with `[math]::Min($windowSize, ...)` as the second. The new third case requires `$source` as the first `Match` argument inside the single token loop.
- The `Match` selection is case-sensitive, so `NextMatch` is not selected, and the coding-cookie `for` loop is outside it.
- The candidate hunks stay intact: a fresh patch from `1332ba34f` shows 12 added module lines and 41 added suite lines present in order, 3 removed lines absent, and hunk failures 0.
- The cycle's module change is comment-only per `comment-only-proof.2026-11-06T19-11.md`, and the reviewer differential ran on the final module rather than relying on that proof alone.
- The window logic was traced again against the token pattern. Small-window variants (16 and 24 characters, margin 8) force a rebase every few tokens and match the unfixed module on all 3470 inputs, which tests the logic well beyond the 1,024-character boundary.

#### API and safety notes

- The exported function, its parameters, and the token and diagnostic shapes are unchanged.
- `$text` and `$Text` are the same PowerShell variable. The assignment predates this branch and is not read as the source afterward, because the loop uses `$sourceText`.

#### Error handling and logging

- Each diagnostic path keeps its `return`. Past-window line numbers are asserted by `reports diagnostics with the right Line past the first window: <Case>`.

---

## Test Quality Audit

The tightened guard was checked by mutation rather than by its passing state. Of the ten trees, five fail as intended, the control passes, one is likely equivalent, and three pass and are recorded in the table above. `MODULE` line coverage is 100.00% (151 of 151). The reviewer ran the docs folder at head after the sync, so consumer suites are confirmed against the merged state: 2050 passed, 0 failed.

### Reviewed test and QA artifacts

- `evidence/regression-testing/guard-fail-before.2026-11-06T20-57.md` - four-tree guard matrix; the reviewer's independent mutants agree with it.
- `evidence/regression-testing/suite-on-fixed.2026-11-06T20-59.md` - suite counts; reproduced at head.
- `evidence/regression-testing/shuffle-isolation.2026-11-06T20-59.md` - three seeded orders, 164 passed each.
- `evidence/regression-testing/comment-only-proof.2026-11-06T19-11.md` - non-comment token identity with a negative control.
- `evidence/regression-testing/differential.2026-11-06T18-33.md` and `evidence/qa-gates/scaling-after.2026-11-06T18-33.md` - measured at the prior hash; the reviewer's differential and spot check at the final hash agree with them.
- `evidence/regression-testing/mirror-parity.2026-11-06T19-11.md` - byte identity and contract tests. The contract tests were not re-run in this review, because the session gate refused the direct command.
- `evidence/qa-gates/merge-check-1034.2026-11-06T21-18.md` - re-run at head against the same 1034 tip `fd6d78930`, exit 0.
- `evidence/qa-gates/suite-duration-after.2026-11-06T21-14.md` - coverage figures; re-parsed from the artifact.

### Quality assessment prompts

- **Determinism:** seeded generators, no clock, no sleep, no temporary file.
- **Isolation:** each case targets one behavior; the guard reads only the syntax tree.
- **Speed:** 23 to 30 s for the file; the token-limit test is the largest part.
- **Diagnostics:** `-Because` text names case, offset, and seed, and guard messages name the offending expression.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | N/A | No process call in the change. |
| Input validation at boundaries | PASS | Parameter attributes are unchanged. |
| Error handling remains explicit | PASS | Diagnostics unchanged; both differentials report no difference. |
| Configuration / path handling is safe | PASS | Tests resolve from `$PSScriptRoot`. |

---

## Research Log

No external research was required.

---

## Verdict

The production change is correct by trace and by two independent differentials, and its scaling meets the criterion. The structural guard now fails on the regression that F1 described. No blocking finding remains. The first Minor row is a small, optional addition; the owner may take it inside this item before the merge. The branch is ready for the pull request once it is synced with the base.
