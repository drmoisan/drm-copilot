# Code Review: pr-author coordinator-session topology (#1011)

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011`
**Feature Folder Selection Rule:** Supplied by the caller; it is the only active folder changed on the branch and its suffix matches issue 1011 in the branch name.
**Base Branch:** `main` (merge base `1a342cc8c974593fd0c733894a7b140527dbca82`, equal to the local `origin/main`)
**Head Branch:** `bug/pr-author-session-not-rooted-1011` at `106f1cf4d0f5f5874ea18d90da9a4a8094cfde39`
**Review Type:** Initial review

---

## Executive Summary

The branch makes PR authoring possible from a coordinator session that is not rooted in the item worktree. It adds two exact allowlist forms for the pr-author subagent, routes the PR gate's branch-signal resolution through the shared resolver delivered by #1009, documents the coordinator-session procedure in the pr-author agent, the pr-author skill, and the orchestrate handoff section, and updates the execution-environment brief. Scope is 4 production PowerShell files (2 plus 2 byte-identical bundled copies), 5 Pester suites (1 new), 16 customization Markdown files, and the feature folder. Evidence reviewed: the PR context summary and appendix, the full diff against the merge base, the shared resolver source, the replaced identity resolver source, the JaCoCo and JUnit artifacts, and the 30 evidence files under the feature folder.

**What changed:**
`enforce-pr-author-command-allowlist.ps1` gains `Test-PrAuthorAbsoluteBodyPathToken` (pure grammar check for `/`- or `X:/`-rooted forward-slash paths ending in `/artifacts/pr_body_<digits>.md`, with no empty, `.`, or `..` segment) and an exact four-token `git worktree list --porcelain` form. `enforce-pr-author-skill-helpers.ps1` imports `HookTargetWorktree.psm1`; `Resolve-PrAuthorWorktreeTarget` now calls `Resolve-HookTargetWorktree -CommandBranch` when the command carries a branch signal and maps the result through the new `ConvertFrom-PrAuthorHookTargetResult`, falling back to the unchanged identity resolver and the #989 current-branch fallback when the mapping yields no selection. The allowlist implementation is precise and fully tested. The resolver mapping is correct for the coordinator topology it targets, but its SessionRoot labelling differs from the definition it replaces (CR-1).

**Top 3 risks:**
1. CR-1: a session whose process directory is a subdirectory of the item worktree is labelled `OtherWorktree` for a `--head` command, so a relative `--body-file` that was allowed is now denied; the spec requires item-rooted gate decisions to stay unchanged.
2. The live coordinator-session path is proven only by Pester until merge, because isolated subagents run `main`'s hooks (spec R3); the post-merge live check is deferred, not performed.
3. CR-2 and CR-3: two smaller semantic differences between the shared resolver and the replaced identity path (no canonical-issue cross-check after a branch match; no filter for registrations whose directory is gone). Both still deny or select the same worktree in the cases the spec targets.

**PR readiness recommendation:** **Needs Revision** — one Major finding (CR-1) changes an item-rooted gate decision contrary to the spec's backward-compatibility expectation; the fix is small and local to one function.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (and bundled copy) | `ConvertFrom-PrAuthorHookTargetResult`, line 137 | CR-1. SessionRoot is decided by comparing the resolved root with the raw session path only. The replaced path labelled through the exported `ConvertTo-WorktreeItemResolvedResult`, which also ascends from the session path to its enclosing worktree (`Find-WorktreeResolutionRoot`). When the hook's process directory is a subdirectory of the item worktree, a `--head` command now yields `OtherWorktree` (previously `SessionRoot`), `RelativeBodyAllowed` becomes false, and a relative `--body-file` is denied with `PR_BODY_PATH_NONCANONICAL`. | Build the non-ambiguous result with `ConvertTo-WorktreeItemResolvedResult -WorktreeRoot $Result.WorktreeRoot -SessionRoot $SessionRoot -Branch $branch -Detail $detail` instead of the inline comparison, keeping the Ambiguous branch as is. Add a TargetResolution row with a session path below the resolved root (mock `Find-WorktreeResolutionRoot` in `WorktreeItemResolution` to return the root) asserting `SessionRoot`. Mirror the helpers file to the bundled copy. | Spec "Backward-compatibility expectations": every gate decision for an item-rooted session is unchanged; design mapping names "the session worktree", not the session path. `general-code-change.md` Reusability: the module documents the function as exported so the labelling is defined once; a second definition with different semantics is the defect this rule prevents. | `WorktreeItemResolution.psm1` lines 245-253 (ascent on mismatch); helpers line 137 (no ascent); `ConvertTo-HookTargetWorktreeNormalizedPath` (HookTargetWorktree.psm1 lines 37-61) only normalizes separators. No TR row covers a subdirectory session path. |
| Minor | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `Resolve-PrAuthorWorktreeTarget`, lines 90-98 | CR-2. When the shared resolver selects a worktree from the branch, the identity resolver is skipped, so a command carrying both a branch signal and a `Canonical issue number for this feature is #N` line no longer gets the branch/issue disagreement check (`Resolve-WorktreeItemTargetByBranch` returns Ambiguous on disagreement). | When `Find-WorktreeItemIssueSignal` finds an issue number in the command text, either skip the shared-resolver shortcut or pass a `CheckpointIssueReader` so the shared resolver performs the same agreement check. Can be handled in the CR-1 remediation. | The spec states resolution by canonical issue line is unchanged. A gh command text rarely carries that line, so the practical exposure is low. | `WorktreeItemResolution.psm1` lines 287-317; helpers lines 91-96. |
| Minor | `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` (consumed, not changed) | `Resolve-HookTargetBranchSource`, line 295 | CR-3. The shared resolver matches branch records without filtering prunable or directory-missing registrations, while the replaced `Get-WorktreeItemLiveRoot` dropped registrations whose directory is gone. A branch checked out in a deleted worktree now yields `OtherWorktree` with a missing root and a later `PR_CONTEXT_MISSING` deny instead of `TARGET_WORKTREE_NOT_DERIVABLE`. The branch match is also case-insensitive. | Treat a result whose root is not a live worktree as no selection in `ConvertFrom-PrAuthorHookTargetResult` (for example via `Test-WorktreeResolutionRootMarker`), or record the accepted difference in the spec. The resolver module is owned by #1009 and is out of this item's scope. | The call is still denied; only the reason code differs. | `HookTargetWorktree.psm1` lines 171, 187-188, 295; `WorktreeItemResolution.psm1` lines 209-213. |
| Info | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `Resolve-PrAuthorWorktreeTarget` | CR-4. For a branch checked out in no worktree, the shared resolver lists worktrees once and the identity fallback lists them again (two `git worktree list` processes per gate call). The executor recorded this in the self-review. | No action required; consider reusing the result if CR-1 remediation touches this function. | Spec performance constraint allows the resolver's invocation "in place of the replaced resolution"; the fallback path adds one. | `evidence/qa-gates/self-review.2026-10-31T02-08.md` code-review row "Info: performance note". |
| Info | `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | `Test-PrAuthorAbsoluteBodyPathToken`, line 70 | CR-5. A worktree root containing a space is split into two tokens and denied; the documented procedure has no quoting form. | No action for this item; note in the skill text if such roots are expected. | Repository worktree roots in use contain no spaces; the denial is fail-safe. | Allowlist tokenization; AL-60 (two-argument denial). |

No Blocker findings. One Major finding (CR-1). No covered file is at or above 700 logical lines (largest: helpers at 497), so no file-size Warning applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The absolute body path grammar is enforced in one pure function with an anchored, case-sensitive regex plus a segment loop; backslashes are rejected before matching. Fourteen deny rows pin each rejection class.
- The `git worktree list --porcelain` form is matched by exact token count and case-sensitive comparison, so `git worktree add/remove` and extra flags stay denied.
- Only a `CommandOperand` result selects a worktree, and the shared resolver receives only `-SessionRoot` and `-CommandBranch` (TR-09), so a feature-folder or other path argument can never decide the target (issue #673 preserved; TR-06, TR-07).
- A shared-resolver result that selects nothing falls through to the unchanged identity resolver and #989 fallback, so existing no-target and ambiguity denials are preserved.
- Bundled copies are byte-identical (verified with `cmp` in this review).

#### API and safety notes

- Both new functions use `[CmdletBinding()]`, `[OutputType()]`, and explicit `Mandatory`/`AllowNull`/`AllowEmptyString` attributes. Approved verbs. PSScriptAnalyzer clean.
- `Resolve-PrAuthorWorktreeTarget` keeps its signature and result shape, so `Get-PrAuthorTargetCheckpointResolution` and the ItemArtifactRoot consumers are unaffected.
- The allowlist hook remains a pure string decision (no process start, file read, or import), as the spec requires.

#### Error handling and logging

- No catch-all handler is added. A resolver invoker failure produces an empty record set inside the shared resolver, which maps to no selection and then to the existing deny path.
- Deny prefixes and reason codes are unchanged; the allowlist guidance text names both new forms (AL-67).

---

## Test Quality Audit

The new and updated rows prove the allowlist forms (allow and deny), the resolver invocation contract, the four mapping outcomes, the issue #673 rule, and the documentation contract. Fail-before evidence shows the new allow, TR, and CT rows failing against the unmodified hooks and documents, and the pinning deny rows passing before and after. Coverage of every changed line is 100%. The one scenario gap is the subdirectory session path tied to CR-1.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` — AL-50 to AL-67 added; AL-34 substitution extended for `<item worktree>`; all pre-existing rows unchanged in expectation.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` — TR-01 to TR-09 run the real `Resolve-PrAuthorWorktreeTarget` body with the three git-reaching seams mocked; results are six-property objects matching the resolver contract.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1`, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` — file-level mock of `Resolve-HookTargetWorktree` to the not-derivable result so `--head` identity rows start no git process; expectations unchanged. These suites therefore exercise the identity fallback rather than the shared-resolver path for `--head` rows, which is intended and documented in their descriptions.
- `tests/scripts/claude-runtime/pr-author-coordinator-topology-contract.Tests.ps1` — CT-01 to CT-07 static reads with whitespace collapsing and section scoping; CT-06 confirms the relative procedure remains outside the new section.
- `evidence/regression-testing/fail-before.2026-10-31T01-38.md` — 24 expected failures before the change.
- `evidence/regression-testing/isolation.2026-10-31T01-50.md` — three seeded shuffles, 132 passed each.
- `evidence/regression-testing/pester-full.2026-10-31T02-06.md` and `artifacts/pester/pester-junit.xml` — 13478 tests, 0 failures, 0 errors (header verified in this review).
- `evidence/qa-gates/coverage-comparison.2026-10-31T02-06.md` and `artifacts/pester/powershell-coverage.xml` — 87/87 and 129/132 lines (counters re-read in this review).

### Quality assessment prompts

- **Determinism:** No new row reads the clock, RNG, network, or live worktrees; synthetic roots use forward slashes or `$PSScriptRoot` composition.
- **Isolation:** Each row asserts one decision or mapping; mocks are set per row or per context.
- **Speed:** New allowlist rows run in 4 to 13 ms each; the touched suites run in seconds.
- **Diagnostics:** `-Because` clauses name the expected token or form; deny rows assert reason prefixes.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | The only process is the shared resolver's existing `git -C <session> worktree list --porcelain` invoker; the allowlist starts none. The new allow forms are read-only (`git worktree list`, `sha256sum` of one file). |
| Input validation at boundaries | ✅ PASS | The absolute path grammar rejects `..`, `.`, empty segments, backslashes, unrooted paths, wrong case, extra arguments, flags, and chains. |
| Error handling remains explicit | ✅ PASS | No swallowed errors added; unresolved results reach the existing deny codes. |
| Configuration / path handling is safe | ⚠️ See CR-1 | Receipt `pr_body_path` and `context_summary_path` stay repo-relative; no absolute path is written to a committed artifact. Session-root labelling differs from the shared definition (CR-1). |

---

## Research Log

No external research was required. Behavior was established from repository sources: `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` (`Resolve-HookTargetWorktree`, porcelain parser, path normalizer) and `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (`Get-WorktreeItemLiveRoot`, `ConvertTo-WorktreeItemResolvedResult`, `Resolve-WorktreeItemTargetByBranch`).

---

## Verdict

The allowlist change and the documentation changes are ready. The resolver consumption is correct for the coordinator-session topology the issue targets, and coverage, analyzer, formatter, isolation, and parity evidence are complete. One Major finding (CR-1) remains: the new SessionRoot labelling omits the enclosing-worktree ascent of the shared `ConvertTo-WorktreeItemResolvedResult`, which changes the decision for an item-rooted session whose process directory is below the worktree root. The recommended fix replaces the inline comparison with the existing exported function and adds one TargetResolution row.

The change needs one proportionate remediation cycle for CR-1 before PR creation. CR-2 and CR-3 are Minor and may be addressed in the same cycle at the planner's discretion; CR-4 and CR-5 are informational.
