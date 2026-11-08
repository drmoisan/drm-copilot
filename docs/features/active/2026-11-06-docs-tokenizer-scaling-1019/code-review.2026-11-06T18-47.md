# Code Review: Python Tokenizer Scaling (#1019)

---

**Review Date:** 2026-11-06
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `c4a2398aa`)
**Head Branch:** `bug/docs-tokenizer-scaling-1019` at `fe9a4023d`
**Review Type:** Initial review

---

## Executive Summary

The branch removes the quadratic cost of `Get-DocsPythonToken` by slicing in `Read-DocsPythonStringEnd`, reusing `NextMatch` in the loop, and lexing a bounded window of the source. Evidence reviewed: the PR context, the production and test diff, all feature evidence, a reviewer re-run of format, analyzer, and `SUITE`, the merged CI coverage artifact of the branch merged at the merge base, and a mutation of the window bound. The window logic was traced by hand against the token pattern and no behavior defect was found. One test gap requires remediation.

**What changed:**
`.claude/lib/docs/DocsPythonTokens.psm1` gains two constants, a margin rebase, and a string rebase; its bundle copy is byte-identical. `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` (`SUITE`) gains the candidate tests, a structural guard, and window-boundary cases. Scope is three non-document files plus the feature folder.

**Top 3 risks:**
1. The structural guard does not detect removal of the window length bound (F1).
2. Retained candidate comments state an AMSI cause that the root-cause profile records as not established.
3. `DocsCSharpTokens.psm1` and other modules keep the same call pattern, and no open issue found by search tracks their scaling.

**PR readiness recommendation:** **Needs Revision** - one proportionate remediation cycle for F1, with the related Minor and Nit rows, then re-review.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | `It 'assigns the lexing window only from a Substring of the source text'` | F1. The case checks only that each `$source` assignment is a `.Substring` call on `$sourceText`; it does not inspect the arguments. A mutant using `$sourceText.Substring($windowStart)` and `$sourceText.Substring(0)` passes both guard cases. | Assert that each `$source` assignment passes exactly two arguments, and that the second is a `[math]::Min` call whose first argument is `$windowSize`. Assert that the first argument of each `.Match` call inside the token loop is the variable `$source`. Record the mutant failing in `guard-fail-before` evidence. | The guard exists to stop this regression without timing. The behavior cases and the names-only token-limit test keep passing on the mutant, so nothing else in `SUITE` reports a string-heavy return to quadratic cost. | `evidence/qa-gates/review-reverification.2026-11-06T18-47.md`, passed 2, failed 0 on the mutant. |
| Minor | `.claude/lib/docs/DocsPythonTokens.psm1` | Loop-head comment in `Get-DocsPythonToken` | The retained comment says `Match` runs only for the first token and after a string token. It now also runs after a margin rebase. The declaration comment reconciles "whole source" only. | Extend the declaration comment above `$source` to state the margin rebase. Keep the candidate lines byte-identical for AC-2. Re-copy the bundle. | A reader can take the stale sentence as a complete list of restart points. | Diff of `MODULE`; `self-review` wording decision. |
| Minor | `.claude/lib/docs/DocsPythonTokens.psm1`; `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | Candidate comments in `Read-DocsPythonStringEnd`, the loop head, and the candidate test | Three retained comments attribute the cost to an AMSI-enabled host. `root-cause-profile` states that AMSI attribution is not established. | Add a note in the module `.NOTES` that the measured cost is in the PowerShell method-invocation layer and the AMSI attribution is unverified. Keep the candidate lines byte-identical. | `.claude/rules/tonality.md` requires wording to match the evidence. | `evidence/baseline/root-cause-profile.2026-11-06T17-25.md`. |
| Minor | `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/issue.md` | `## Dependencies / Risks` | States that 1034 already carries the candidate hunks. The 1034 tip has reverted them. | Update that sentence outside `## Acceptance Criteria`, and leave AC-2 unchanged. | The merge rationale reads differently once the tip no longer holds the candidate. | `evidence/qa-gates/merge-check-1034.2026-11-06T18-18.md`. |
| Minor | `.claude/lib/docs/DocsCSharpTokens.psm1` | Whole-source `Match` in a loop | The same call pattern exists outside this item and was not measured. Issue text scopes it out. A search for `DocsCSharpTokens` in open issues found only #1033, the feature that added the module. | Orchestrator decides: measure and fix in a separate epic child, or file a tracking issue. Do not widen this cycle, because `issue.md` places it outside the item. | The same defect class may slow other suites. | `issue.md`; `root-cause-profile` `## Other Length-Proportional Calls Checked in the Module`. |
| Nit | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1`; `.claude/lib/docs/DocsPythonTokens.psm1` | File and module `.DESCRIPTION` | Neither mentions the guard, the window cases, or the window. | Add one sentence each. | Help text describes the module for maintainers. | Inspection. |
| Info | `.claude/lib/docs/DocsPythonTokens.psm1` | Margin and string rebase blocks | The rebase statements appear twice. The plan specifies both. | No action. A helper would add a call per rebase in the hot loop. | Recorded in the self-review. | `self-review`. |
| Info | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | `It 'property: long inputs reconstruct their spans and lines'` | Passes with margin 0, as the self-review recorded. The padded-offset cases catch that mutation. | No action required. | Margin is guarded by other cases. | `self-review`. |
| Info | `evidence/qa-gates/suite-duration-after.2026-11-06T18-28.md` | `## Run Conditions` | Its 31.61% whole-population figure is the instruction counter of a one-folder run. Line is 26.89%. Neither is a repo-wide figure. | No action; the artifact states the figure is not a measure of the module. | Avoids misreading. | `review-reverification`. |
| Info | `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/plan.2026-11-06T12-15.md` | Header | Status remains `Draft` with all tasks checked. | Update with the next plan touch. | Record accuracy. | Inspection. |
| Info | Pull request | Issue reference | #1019 is the epic issue, titled `Epic: documentation-estate-tooling`. | Do not use a closing keyword for it in the PR body. | A closing keyword could close the epic when the integration branch reaches the default branch. | `artifacts/pr_context.summary.txt`. |
| Info | Branch | Base | The branch is one docs-only commit behind `origin/epic/documentation-estate-tooling-integration` (`eca4fc203`). `git merge-tree` reports no conflict. | Sync before opening the PR per the orchestrator's normal step. | Keeps the PR diff current. | `git merge-tree --write-tree HEAD origin/epic/documentation-estate-tooling-integration`. |

No file-size Warning applies: `MODULE` 265, bundle 265, and `SUITE` 492 logical lines.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The pattern has no lookbehind and anchors only with `\G` and `\z`, so re-slicing cannot change what precedes a match.
- A truncated token can differ from its full form only through a backtrack of at most two characters (an exponent `e-` with no digit) or a match reaching the window end, and the margin of 8 covers both. A match within the margin rebases before any state is updated.
- A match never fails because of the window: a position after an unrebased match is at least 8 characters before the window end, so a backslash continuation has its newline in view.
- `$lineStart` is rebased with `$position`, including negative values, so columns remain correct. A string ending at the end of the source yields an empty window and ends the loop.
- Doubling occurs only at position zero with a match reaching the margin, and any later rebase resets the size, so window cost stays proportional to token length.

#### API and safety notes

- The exported function, its parameters, and the token and diagnostic shapes are unchanged. The differential covers 1098 inputs with zero differing hashes and a negative control.
- `$text` and `$Text` are the same PowerShell variable. The assignment predates this branch and is not read as the source afterward, because the loop uses `$sourceText`.

#### Error handling and logging

- Each diagnostic path keeps its `return`. Past-window line numbers are asserted by `reports diagnostics with the right Line past the first window: <Case>`.

---

## Test Quality Audit

The added cases drive every window branch, and `MODULE` line coverage is 100.00% (151 of 151). Guard evidence shows the expected matrix on the unfixed, candidate, and fixed modules, but the reviewer's mutant shows that the matrix does not cover removal of the bound (F1).

### Reviewed test and QA artifacts

- `evidence/regression-testing/suite-on-fixed.2026-11-06T18-09.md` - suite counts on the fixed module; reproduced by the reviewer at head.
- `evidence/regression-testing/guard-fail-before.2026-11-06T18-28.md` - guard matrix with failure messages.
- `evidence/regression-testing/differential.2026-11-06T18-33.md` - identical tokens and diagnostics with a negative control.
- `evidence/qa-gates/scaling-after.2026-11-06T18-33.md` - ratios from 1.72 to 2.09 at 8,000 units and above.
- `evidence/regression-testing/shuffle-isolation.2026-11-06T18-28.md` - three seeded orders.
- `evidence/regression-testing/candidate-hunks.2026-11-06T18-09.md` - hunk identity.
- `evidence/qa-gates/review-reverification.2026-11-06T18-47.md` - reviewer run, coverage parse, and mutant.

### Quality assessment prompts

- **Determinism:** seeded generators, no clock, no sleep, no temporary file.
- **Isolation:** each case targets one behavior; the guard reads only the syntax tree.
- **Speed:** 27 to 33 s for the file; the token-limit test is the largest part.
- **Diagnostics:** `-Because` text names case, offset, and seed.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | N/A | No process call in the change. |
| Input validation at boundaries | PASS | Parameter attributes are unchanged. |
| Error handling remains explicit | PASS | Diagnostics unchanged; differential identical. |
| Configuration / path handling is safe | PASS | Tests resolve from `$PSScriptRoot`. |

---

## Research Log

No external research was required.

---

## Verdict

The production change is correct by trace and by the recorded differential, and its scaling evidence meets the criterion. The change is not ready for the PR until the structural guard pins the window bound, because that guard is the only automated check for the string-heavy regression. A proportionate remediation cycle is sufficient; the Minor and Nit rows that relate to this item can be taken in the same cycle.
