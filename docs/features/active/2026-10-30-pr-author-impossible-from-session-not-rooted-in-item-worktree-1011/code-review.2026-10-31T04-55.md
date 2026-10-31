# Code Review: pr-author coordinator-session topology (#1011), remediation cycle 1 re-review

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011`
**Feature Folder Selection Rule:** Supplied by the caller; it is the only active folder changed on the branch and its suffix matches issue 1011 in the branch name.
**Base Branch:** `main` (merge base `1a342cc8c974593fd0c733894a7b140527dbca82`, equal to the local `origin/main`)
**Head Branch:** `bug/pr-author-session-not-rooted-1011` at `97a0bbf1b271fb4128acb0a093ef13b2f8ba06a1`
**Review Type:** Re-review after remediation cycle 1 (prior review `code-review.2026-10-31T02-17.md` at `106f1cf4d`)

---

## Executive Summary

The branch makes PR authoring possible from a coordinator session that is not rooted in the item worktree. It adds two exact allowlist forms for the pr-author subagent, routes the PR gate's branch-signal resolution through the shared resolver from #1009, documents the coordinator-session procedure in the pr-author agent, the pr-author skill, and the orchestrate handoff section, and updates the execution-environment brief. This re-review covers the whole branch diff (79 files) and gives particular attention to the eight commits since `106f1cf4d`, which changed only the helpers file and its bundled copy, the TargetResolution suite, the six brief copies, and feature-folder documents and evidence.

**What changed in remediation cycle 1:**
`ConvertFrom-PrAuthorHookTargetResult` now ends in `return (ConvertTo-WorktreeItemResolvedResult -WorktreeRoot $Result.WorktreeRoot -SessionRoot $SessionRoot -Branch $branch -Detail $detail)` (helpers line 141) and returns `$null` when `Test-WorktreeResolutionRootMarker` rejects the root (line 140). `Resolve-PrAuthorWorktreeTarget` enters the shared-resolver block only when a branch signal is present and `Find-WorktreeItemIssueSignal` finds no canonical issue line (lines 93-94). TR-10, TR-11, and TR-12 pin the three changes; each failed against the unmodified helpers (`evidence/regression-testing/fail-before-r1.2026-10-31T02-42.md`) and passes after.

**Prior findings:**

| ID | Prior severity | Status | Closure evidence |
|---|---|---|---|
| CR-1 | Major (blocking) | Closed | Labelling delegated to the exported `ConvertTo-WorktreeItemResolvedResult` (ascent via `Find-WorktreeResolutionRoot`, `WorktreeItemResolution.psm1` lines 245-253); TR-10 passes; no inline comparison remains. |
| CR-2 | Minor | Closed | Issue-line bypass at helpers lines 93-94; TR-11 asserts zero shared-resolver calls and one identity-resolver call; brief sentence updated in six copies. |
| CR-3 | Minor | Closed | Marker check at helpers line 140; TR-12 asserts no selection and a NoTarget outcome with the no-target code. |
| CR-4 | Info | Open, accepted | Out of scope per `remediation-plan.2026-10-31T02-17.md`; no action was required. Unchanged. |
| CR-5 | Info | Open, accepted | Out of scope per the remediation plan; denial is fail-safe. Unchanged. |

**Top 3 risks:**
1. The live coordinator-session path is proven only by Pester until merge, because isolated subagents run `main`'s hooks (spec R3); the post-merge live check is deferred, not performed.
2. CI has not run on the head (no PR exists yet). The TR suite also runs in the Linux hook-suite job; new rows use `$script:ItemRoot` composed from `$PSScriptRoot` with forward slashes and mock both filesystem checks, which lowers but does not remove the CI-only risk.
3. CR-6 (Info, new): the branch signal is parsed twice per gate call, once in each of the two functions. The cost is one regex scan; no behavior difference.

**PR readiness recommendation:** **Ready** — no Blocker or Major finding; all prior blocking and Minor findings are closed with regression rows and fail-before evidence.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `Resolve-PrAuthorWorktreeTarget` and `ConvertFrom-PrAuthorHookTargetResult` | CR-4 (carried forward). For a branch checked out in no worktree, the shared resolver lists worktrees once and the identity fallback lists them again. | No action for this item. | The spec performance constraint allows the resolver's invocation in place of the replaced resolution; removing the second listing would require editing `.claude/lib/worktree-resolution/`, which AC-18 forbids. | `remediation-plan.2026-10-31T02-17.md` Findings Out of Scope. |
| Info | `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | `Test-PrAuthorAbsoluteBodyPathToken` | CR-5 (carried forward). A worktree root containing a space is split into two tokens and denied. | No action for this item. | Fail-safe denial; repository worktree roots in use contain no spaces. | Remediation plan Findings Out of Scope; AL-60. |
| Info | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | lines 92 and 133 | CR-6 (new). `Find-WorktreeResolutionBranchSignal` runs in `Resolve-PrAuthorWorktreeTarget` and again in `ConvertFrom-PrAuthorHookTargetResult`. | No action required. If the function is next edited, consider passing the branch as a parameter. | Pure string scan; the second call keeps `ConvertFrom-PrAuthorHookTargetResult` self-contained for direct testing (TR-02, TR-10). | Helpers lines 92, 133. |

No Blocker, Major, or Minor findings. No covered file is at or above 700 logical lines (largest: helpers at 499), so no file-size Warning applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- CR-1 fix removes the second labelling definition instead of patching it, so the gate now shares the identity resolver's exact SessionRoot semantics (equality, then ascent only on mismatch).
- CR-3 fix reuses the exported `Test-WorktreeResolutionRootMarker`, the same predicate `Get-WorktreeItemLiveRoot` uses, so a deleted registration is treated the same on both paths and reaches `TARGET_WORKTREE_NOT_DERIVABLE`.
- CR-2 fix uses the assign-then-wrap form for `Find-WorktreeItemIssueSignal` (which returns its array as one object), so `@($issueSignal).Count` counts issue numbers, not wrappers.
- The absolute body path grammar remains a pure, anchored, case-sensitive check with a segment loop; the `git worktree list --porcelain` form is matched by exact token count.
- Only a `CommandOperand` result selects a worktree (TR-06, TR-07), preserving the issue #673 rule.
- All six edited `.claude/` files are byte-identical to their bundled copies, and all six brief copies share one SHA-256 (both re-verified in this review).

#### API and safety notes

- `Resolve-PrAuthorWorktreeTarget` keeps its signature and result shape; `ConvertTo-WorktreeItemResolvedResult` returns the same six-property target object built by `New-WorktreeResolutionTargetResult`, with `Signal = 'Branch'` when a branch is supplied (TR-02, TR-03, TR-10 assert it).
- The protected functions named in AC-09 are unchanged: their files are absent from the diff, and the AST comparison in `evidence/qa-gates/scope-check-r1.2026-10-31T04-48.md` reports `FUNCTIONS_UNCHANGED: 3/3` for the helpers-file functions.
- The allowlist hook remains a pure string decision (no process start, file read, or import).

#### Error handling and logging

- No catch-all handler added. Every no-selection path falls through to the unchanged identity resolver and the #989 current-branch fallback, so deny codes and guidance text are unchanged.

---

## Test Quality Audit

The new and updated rows prove the allowlist forms, the resolver invocation contract, the four mapping outcomes, the issue #673 rule, the three remediation behaviors, and the documentation contract. Fail-before evidence exists for both the main plan (24 expected failures) and the remediation cycle (TR-10 to TR-12, with the other 16 rows passing against the unmodified helpers). Every changed line is executed.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` — the context `BeforeEach` now mocks `Test-WorktreeResolutionRootMarker` (true) and `Find-WorktreeResolutionRoot` in module `WorktreeItemResolution` (null), so no row reads the disk; TR-10 to TR-12 capture row-local values with `.GetNewClosure()`; no existing `It` block changed.
- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` — AL-50 to AL-67; unchanged since the initial review.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1`, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` — file-level shared-resolver mock to a null root, which returns before the new marker check; expectations unchanged; unchanged since `REMEDIATION_BASE` (`scope-check-r1`).
- `tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1` — CT-01 to CT-07; unchanged since the initial review.
- `evidence/regression-testing/fail-before-r1.2026-10-31T02-42.md` — 19 tests, 3 expected failures (TR-10, TR-11, TR-12).
- `evidence/qa-gates/gate-suites-r1.2026-10-31T02-44.md` — 21 suites, 534 tests, 0 failures, including the three AC-08 ItemArtifactRoot rows.
- `evidence/regression-testing/isolation-r1.2026-10-31T04-48.md` — seeds 13, 31, 59; 135 passed each.
- `evidence/regression-testing/pester-full-r1.2026-10-31T04-46.md` and `artifacts/pester/pester-junit.xml` — 13481 tests, 0 failures, 0 errors (header verified in this review).
- `evidence/qa-gates/coverage-comparison-r1.2026-10-31T04-46.md` and `artifacts/pester/powershell-coverage.xml` — 87/87 and 129/132 lines; missed lines 310, 326, 349 in the unchanged `Test-PrAuthorReceiptVerification` (counters and missed lines re-read in this review).

### Quality assessment prompts

- **Determinism:** No new row reads the clock, RNG, network, disk, or live worktrees; synthetic roots are composed from `$PSScriptRoot` with forward slashes.
- **Isolation:** Each row asserts one mapping or invocation property; mocks are per row or per context `BeforeEach`.
- **Speed:** The touched suites run in seconds in one process.
- **Diagnostics:** TR-10 to TR-12 carry `-Because` clauses naming the expected rule.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected; no credentials or tokens. No host path appears in committed feature-folder files (searched in this review). |
| No unsafe subprocess or command construction | ✅ PASS | The only process remains the shared resolver's existing `git worktree list --porcelain` invoker; the remediation adds no process. |
| Input validation at boundaries | ✅ PASS | The absolute path grammar rejects `..`, `.`, empty segments, backslashes, unrooted paths, wrong case, extra arguments, flags, and chains. |
| Error handling remains explicit | ✅ PASS | Unresolved results reach the existing deny codes. |
| Configuration / path handling is safe | ✅ PASS | Receipt `pr_body_path` and `context_summary_path` stay repo-relative; SessionRoot labelling now matches the shared definition (CR-1 closed). |

---

## Research Log

No external research was required. Behavior was established from repository sources: `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (`ConvertTo-WorktreeItemResolvedResult` lines 217-257, `Get-WorktreeItemLiveRoot` lines 180-215, `Find-WorktreeItemIssueSignal` lines 106-130, `Resolve-WorktreeItemTargetByBranch` lines 261-318), `.claude/lib/worktree-resolution/WorktreeResolution.psm1` (`Test-WorktreeResolutionRootMarker` lines 228-256, `Find-WorktreeResolutionRoot` from line 258), and `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (lines 272-274, confirming the #1010 statement added to the brief).

---

## Verdict

The remediation closes CR-1, CR-2, and CR-3 with the fixes the initial review recommended, each pinned by a regression row with recorded fail-before output. Coverage, analyzer, formatter, isolation, mirror parity, brief parity, scope, and evidence-location checks are complete and passing. The remaining items (CR-4, CR-5, CR-6) are informational and need no action for this item.

The change is ready for PR creation. The post-merge live coordinator-session `gh pr create` check remains a deferred follow-up, and the CI green gate applies at the PR head.
