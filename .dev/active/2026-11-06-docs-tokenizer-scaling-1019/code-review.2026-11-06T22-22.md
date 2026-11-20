# Code Review: Python Tokenizer Scaling (#1019), Re-Audit After Remediation Cycle 2

---

**Review Date:** 2026-11-06
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `8fa914935e3efec81d1e970bc525d907a9458203`)
**Head Branch:** `bug/docs-tokenizer-scaling-1019` at `3649bc628c972c82869ea5ff6c1d23309037e4f9`
**Review Type:** Re-audit after remediation cycle 2

---

## Executive Summary

The branch removes the quadratic cost of `Get-DocsPythonToken` by slicing in `Read-DocsPythonStringEnd`, reusing `NextMatch` in the loop, and lexing a bounded window of the source. Cycle 2 changed only the structural guard in `SUITE`, its help sentence, and one plan header. Evidence reviewed: the PR context, the full production and test diff, the cycle 2 evidence, reviewer runs of format, analyzer, and the docs folder at head, ten mutated module trees with the head `SUITE`, thirteen new guard boundary and evasion probes plus a control, and the merged CI coverage artifact for a tree equal to the merge base. Rows R1, R2, and R3 are closed and no blocking finding exists.

**What changed:**
`.claude/lib/docs/DocsPythonTokens.psm1` (`MODULE`) gains two constants, a margin rebase, a string rebase, and help notes; its bundle copy is byte-identical. Neither changed in cycle 2. `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` (`SUITE`) gains the candidate tests, a four-case structural guard, and window-boundary cases. Scope is three non-document files plus the feature folder.

**Top 3 risks:**
1. The guard pins the constant, not the value the function uses. Replacing the three reads of the constant in `Get-DocsPythonToken` with a large literal passes all 58 tests. This needs three deliberate edits and is visible in review.
2. CI on the pull request head has not run. A `main` push run on `a936a1d93` failed in `poshqc / PowerShell QC shard 1` for a cause not determined here, although a later run on the merge-base tree succeeded.
3. `DocsCSharpTokens.psm1` and other modules keep the same call pattern, and no open issue found by search tracks their scaling.

**PR readiness recommendation:** **Go.** AC-8 stays pending-CI until S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/docs/DocsCSharpTokens.psm1` | Whole-source `Match` in a loop | Carried from the prior reviews: the same call pattern exists outside this item and was not measured. An open-issue search still finds only #1033, the feature that added the module. | Orchestrator or owner decides: a separate epic child or a tracking issue. Do not widen this item, because `issue.md` places it outside. | The same defect class may slow other suites. | `issue.md`; `follow_ups` in the orchestrator checkpoint. |
| Info | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | `It 'assigns the window size once at module scope from an integer literal no greater than 65536'` | The case pins the constant, while the `[math]::Min` bound reads the local `$windowSize`. With all three reads of the constant in `Get-DocsPythonToken` replaced by 1073741824, the constant stays at 1024, the guard passes 4 of 4, and `SUITE` passes 58 of 58. | No action required for this item. If the guard is touched again, assert that `$windowSize` is assigned only from the constant or from a doubling of itself. | R1 asked for a pin on the constant, and that is delivered. The remaining form needs three deliberate edits. The self-review limits its claim to assignment statements of the constant. | Probe `size-local-literal` in the policy audit, `## Reviewer Re-Verification at Head`. |
| Info | `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/remediation-plan.2026-11-06T21-37.md` | Header | `Status` still reads `Authored by atomic-planner; awaiting combined preflight and execution`, with every task checked. This is the class of record R3 corrected for the cycle 1 plan. The executor left it because the plan's conventions limit its edits to checkboxes, and the self-review assigns the update to the orchestrator. | Orchestrator: set `Executed; AC-8 pending CI` with the next touch of the file. | Record accuracy. | Inspection; `self-review.2026-11-06T22-12.md`. |
| Info | `.claude/lib/docs/DocsPythonTokens.psm1` | `$windowSize` reset in the string rebase | Carried: removing the reset passes 58 of 58. The result is a larger window after a long token, followed by strings. No correctness change, and the production code keeps the reset. | No action. | A timing-free test cannot observe this without a further structural pin. | Mutant `no-string-reset`. |
| Info | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` | `margin-3` mutant | Carried: a margin of 3 passes 58 of 58, and a margin of 2 fails three exponent cases, so this is likely an equivalent mutant and the value 8 carries slack. | No action. | Separates a real gap from an equivalent mutant. | Mutants `margin-2` and `margin-3`. |
| Info | Pull request | Issue reference | Carried: #1019 is the epic issue, titled `Epic: documentation-estate-tooling`, and it is open. | Do not use a closing keyword for it in the PR body. | A closing keyword could close the epic when the integration branch reaches the default branch. | `gh issue view 1019`. |

No file-size Warning applies: `MODULE` 271, bundle 271, and `SUITE` 568 logical lines. `SUITE` is above the 500-line guidance tier, which produces no finding.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- R1 is closed by a new case that selects every assignment to the constant, including nested script blocks and cast left sides, and then requires one assignment at module scope from an integer literal at or below 65536. The reviewer's probes show that this holds against a cast, a capitalized name, hexadecimal and suffix literals, an expression, a floating-point literal, a string literal, and a second assignment. The ceiling is exact: 65536 passes and 65537 fails.
- R2 is closed by unwrapping `AttributedExpressionAst` on the left side, which also handles stacked casts. A typed assignment that keeps the bound still passes, so the rule judges the right side and does not reject a harmless cast.
- The candidate hunks stay intact: a fresh patch from `1332ba34f` shows 12 added module lines and 41 added suite lines present in order, 3 removed lines absent, and hunk failures 0.
- The window logic was read again in full against the token loop, including the order of the failed-match return and the rebase. A token that starts within the margin cannot be cut off, because the preceding token triggers a rebase, and at exactly the margin the 8 remaining characters hold any token's opening. This agrees with the prior differential at the same module hash.

#### API and safety notes

- The exported function, its parameters, and the token and diagnostic shapes are unchanged.
- `$text` and `$Text` are the same PowerShell variable. The assignment predates this branch and is not read as the source afterward, because the loop uses `$sourceText`.

#### Error handling and logging

- Each diagnostic path keeps its `return`. Past-window line numbers are asserted by `reports diagnostics with the right Line past the first window: <Case>`.

---

## Test Quality Audit

The guard was checked by mutation rather than by its passing state. Of the ten trees, the control passes, seven fail as intended, one is likely equivalent, and one passes and is recorded in the table above. The two mutants that passed in the prior review, `size-constant-huge` and `typed-evasion`, now fail. `MODULE` line coverage is 100.00% (151 of 151). The reviewer ran the docs folder at head: 2051 passed, 0 failed, 0 skipped, 0 not run in 302.69 s.

### Reviewed test and QA artifacts

- `evidence/regression-testing/guard-fail-before.2026-11-06T21-55.md` - six-tree guard matrix; the reviewer's independently built mutants and probes reproduce its failing cases and messages.
- `evidence/regression-testing/suite-on-fixed.2026-11-06T21-57.md` - 58 passed; reproduced on the reviewer's control tree.
- `evidence/regression-testing/shuffle-isolation.2026-11-06T21-57.md` - three seeded orders, 165 passed each.
- `evidence/regression-testing/candidate-hunks.2026-11-06T21-53.md` - reproduced with a fresh patch.
- `evidence/regression-testing/module-hash-reconfirm.2026-11-06T22-10.md` - reproduced: `MODULE` and `BUNDLE` both hash to `015c3836...`, and `cmp` exits 0.
- `evidence/regression-testing/differential.2026-11-06T18-33.md`, `evidence/qa-gates/scaling-after.2026-11-06T18-33.md`, and `evidence/regression-testing/comment-only-proof.2026-11-06T19-11.md` - carried at the same module hash, with the prior reviewer differential and spot check.
- `evidence/regression-testing/mirror-parity.2026-11-06T19-11.md` - byte identity and contract tests. The contract tests were not re-run, because the session gate refused the direct command.
- `evidence/qa-gates/merge-check-1034.2026-11-06T22-14.md` - re-run at head against the same 1034 tip `fd6d78930`, exit 0, with no conflict. The merged tree identifier differs from the record because the record used the preceding head, and the head commit adds that record.
- `evidence/qa-gates/suite-duration-after.2026-11-06T22-09.md` - coverage figures; re-parsed from the artifact.
- `evidence/qa-gates/self-review.2026-11-06T22-12.md` - read in full for its stated limits.

### Quality assessment prompts

- **Determinism:** seeded generators, no clock, no sleep, no temporary file.
- **Isolation:** each case targets one behavior; the guard reads only the syntax tree.
- **Speed:** 22 to 33 s for the file; the token-limit test is the largest part.
- **Diagnostics:** `-Because` text names case, offset, and seed, and guard messages name the offending expression or value.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | N/A | No process call in the change. |
| Input validation at boundaries | PASS | Parameter attributes are unchanged. |
| Error handling remains explicit | PASS | Diagnostics unchanged; both differentials report no difference at or before the head hash. |
| Configuration / path handling is safe | PASS | Tests resolve from `$PSScriptRoot`. |

---

## Research Log

No external research was required.

---

## Verdict

The production change is unchanged since the prior review and remains correct by trace and by two differentials. Cycle 2 delivered the three rows it took on, and the guard now fails on both mutants that passed before. No blocking finding exists. The remaining rows are one carried Minor row outside this item and Info rows that need no code change for this item. The branch is level with its base and ready for the pull request.
