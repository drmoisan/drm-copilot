# Code Review: SubagentStop Hooks Resolve the Item Worktree (#1105)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
**Base Branch:** `main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, the merge base of `origin/main` and `HEAD` after a fetch)
**Head Branch:** `bug/hooks-read-main-checkout-1105` @ `5a866484f06e940196f7fe867dce98cc86e461de`
**Review Type:** Re-review after remediation cycle 1 (prior review `code-review.2026-11-07T15-37.md` at `98028900a`)

---

## Executive Summary

The branch makes six SubagentStop hooks resolve advertised artifact paths and coverage reports against the item worktree instead of the session root. Cycle 1 addressed the three prior findings, and the reviewer verified each by execution:

- **F1 resolved.** The helper reduces the delegation prompt to the first branch signal and the canonical issue lines, read by `Find-WorktreeResolutionBranchSignal` and `Find-WorktreeItemIssueSignal`. The model-routing gate's `Resolve-WorktreeItemTarget` calls the same two functions (`WorktreeItemResolution.psm1` lines 374 and 376). An identity with no branch label is placed through `Get-WorktreeItemCheckpointIssue`. Real-process probes: an issue-line-only prompt resolves to the item root, and so does `branch: <item>` followed by `base branch: main`. A reader that finds no worktree gives `TARGET_WORKTREE_NOT_DERIVABLE`. The coverage hook's unresolved-target message now names the first `branch:` label and the checkpoint issue line, and no longer advises absolute paths.
- **F2 resolved.** A counting transcript reader recorded one read for a relative `plan-path` in the executor hook.
- **F3 resolved.** Relative values with a `..` segment beneath an item root are rejected before any probe in all six hooks; `a..b` is accepted, and the session-root case is unchanged.

The two out-of-plan findings reported by the cycle 1 executor were evaluated:

1. The vacuous `-Times 0` assertion is confirmed by mutation and is the only instance of its class in the new and edited suites (F4, blocking, `autonomous`).
2. The `Register-EpicStateBaselineMock` duplicate-module failure is confirmed by reproduction. It is not blocking for this branch (F5, Nit).

**What changed well:**
The F1 fix reuses the gate's readers rather than adding a resolver, and keeps the checkpoint reader injectable, so no test reads a file. The F2 fix keeps both consumers unchanged by passing them a closure over the single read. The F3 rejection lives in one function, and each hook adds only a block message that names the token and the rejected segment.

**Top 3 risks:**
1. F4: the gate host cannot detect a regression that adds a session-root read of the PR context summary or `CLAUDE.md` alongside the item-root read.
2. F5: a future suite that loads a bundle hook copy in-process without cleanup would break every later suite in the same shard that registers a module-scoped baseline mock. The failure is loud and points at the duplicate module.
3. A prompt that names `base branch: main` before the item `branch:` label resolves to the session root. This matches the gate, which reads the same first signal, so the two stay consistent; the orchestrate skill places the item label first.

**PR readiness recommendation:** **Not ready.** Remediate F4 (one test file, three filter expressions).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1` | Case "reads the PR context summary, the root CLAUDE.md, and the coverage report only beneath the item root", line 218 (and the same name in lines 216-217) | F4. The `-Times 0` assertion's `ParameterFilter` reads `$Root`. A call without `-Root` leaves the name unbound in the filter scope, so PowerShell resolves it from an outer scope. `Invoke-PoshQCTest -Root <worktree>` puts a non-empty `$Root` there, so `[string]::IsNullOrEmpty($Root)` is false and the assertion passes for any hook behavior. Lines 216-217 read the same name; they assert `-Times 1` and still fail when the rooted read is missing, so they are not vacuous. | Replace `$Root` with `$PesterBoundParameters['Root']` in lines 216, 217, and 218. Keep the assertions otherwise unchanged. | `.claude/rules/powershell.md` requires identical results across hosts. The assertion is the suite's only pin on the "only beneath the item root" clause of spec criterion 8. Remediability class: `autonomous`. | Reviewer mutant (extra unrooted summary read) in a scratch copy: FAIL under plain `Invoke-Pester`, PASS when started from a function with a `$Root` parameter. With the recommended change: the original hook passes and the mutant fails in both hosts. |
| Nit | `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` (not in the branch diff) | `Register-EpicStateBaselineMock`, line 55 | F5. `Mock -ModuleName <name>` throws "Multiple script or manifest modules named 'WorktreeItemResolution' are currently loaded" when a bundle copy of the module is loaded beside the repository copy. The branch removed its own leak source with an `AfterAll` in the ThresholdsGuard suite, which is the only suite that loads a bundle hook copy in-process. | No change on this branch. If the helper is revisited, have it name the duplicate module paths in its error so the leaking suite is easy to find. Do not have it pick one copy silently, because the error is what detects a leak. | The helper pre-dates the branch. The failure is reported loudly, and no suite on this head triggers it. Remediability class if pursued: `autonomous`. | Reviewer reproduction in a scratch Pester file: importing the bundle `WorktreeItemResolution.psm1`, then calling the helper, fails with the error above. A search of `tests/` found no other in-process import of a bundle module. |

No covered file reaches the 700-line advisory tier (largest production file `validate-planner-output.ps1` at 473 logical lines; largest test file `validate-feature-review-coverage.Coverage.Tests.ps1` at 481), so no `Warning` row applies. `config/file-size-baseline.json` is not in the branch diff.

---

## Python

No Python file changed. The six contract modules that pin mirrors, the manifest, and the brief passed in the reviewer's run (126 tests).

## TypeScript

No TypeScript file changed.

## PowerShell

**What changed well:** `Get-SubagentStopIdentityPrompt` is pure and returns `$null` for a prompt with no identity, which keeps the session-root path unchanged. It assigns the issue signal before wrapping it, so the reader's single-object array is not double-wrapped. The checkpoint reader is attached only to a branch-free identity, so a branch-bearing prompt reads no checkpoint. `Resolve-SubagentStopArtifactLocation` now returns `Rejected` and `RejectionDetail` on every path, and each caller checks `Rejected` before using `ProbePath`.

**Safety:** an absolute value inside the item root that normalizes to a `..` path (for example `<item>/docs/../../../../etc/passwd`) is converted and then rejected. An absolute value outside every worktree is still left to the unchanged shape rules. The executor's closure returns the lines read once; a throwing read gives `$null`, the same as no transcript.

**Session-root invariant:** probes for no identity, `branch: main`, and an absolute path inside the session root returned the session root. `docs/../x.md` with the session root is not rejected and is probed unchanged, as before the branch.

PSScriptAnalyzer with the repository settings and `Invoke-Formatter` report 0 findings and 0 differences on the 42 changed non-bundle PowerShell files (reviewer run). Coverage: 100.00% on the helper (92 of 92), 97.96% on the freshness sibling (48 of 49), and 98.33% to 100.00% on the eight edited hooks.

## C#

No C# file changed.

---

## Test Quality

- **Discrimination.** The new cycle 1 cases assert the resolved root and the read location by path. The planner suite's case for the second-`branch:` shape (the one artifact-hook case the remediation plan required) asserts that the item copy is read and the relative path is not.
- **Host dependence (F4).** The search covered every `ParameterFilter` added on the branch (68 lines) for a filter that reads a parameter the hook may leave unbound. Only lines 216-218 of the coverage target suite read such a name (`$Root`). The other filters read `Path`, `LiteralPath`, `Lines`, `Content`, `SpecContent`, `ResearchFilePath`, `WorktreeRoot`, or `TotalCount`, and every production call site binds these by name. The `-Times 0` assertions without a filter in the executor, required-artifact, `prd-feature`, researcher, planner, coverage, and freshness suites count every call, so they can fail.
- **Seams.** The new default-reader case mocks `Get-WorktreeItemCheckpointIssue`; the hook suites register the item-resolution baseline mocks, so no checkpoint file is read.
- **Isolation (F5).** The ThresholdsGuard `AfterAll` removes modules loaded from the bundle path, and the reviewer's single-process run of 12 suites passed.

## Security and Correctness

No command text is evaluated, and cycle 1 adds no process call. The F3 rejection narrows the values the hooks probe. The F1 reduction emits only the branch name read by the gate's reader and numeric issue lines, so prompt text cannot add other content to the resolver input.

---

**Review completed by:** feature-review agent
