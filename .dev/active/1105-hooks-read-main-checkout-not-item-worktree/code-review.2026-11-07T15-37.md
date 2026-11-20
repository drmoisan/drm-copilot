# Code Review: SubagentStop Hooks Resolve the Item Worktree (#1105)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105`
**Base Branch:** `main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, equal to `origin/main` after a fetch)
**Head Branch:** `bug/hooks-read-main-checkout-1105` @ `98028900a19973e8467846b5962170488529c5b1`
**Review Type:** First review

---

## Executive Summary

The branch fixes four observed defects (#1031, #1034, #1096, #1097) in which SubagentStop hooks read an item's artifacts and coverage reports from the main checkout. A new helper, `.claude/hooks/subagentstop-target-worktree.ps1`, resolves the item worktree once per invocation through the existing `Resolve-HookTargetWorktree`. It uses an absolute advertised path when one is present, and otherwise the delegation prompt read from the subagent transcript. Each artifact hook converts an absolute value inside the item root to repository-relative form, runs its unchanged shape rules, and probes only the copy beneath the resolved root. The coverage hook reads the PR context summary, the root `CLAUDE.md`, and the coverage reports beneath the item root. A new sibling, `validate-feature-review-coverage-freshness.ps1`, blocks when a report is absent or older than the newest commit that touches its language.

The reviewer verified the main claims by execution:

- 1475 Pester tests over the 29 suites of the edited hooks and the three guard suites passed, and 126 contract pytest tests passed.
- The coverage figures were parsed from the item worktree's own report and match the gate evidence.
- The ten bundle copies and six brief copies are byte-identical.
- Eleven identity and path shapes were run through the real helper and the real coverage hook entry point. Nine behave as the spec states. Two prompt shapes that the model-routing gate admits do not resolve (F1).

One Major finding blocks the merge. One Minor finding and one Nit follow.

**What changed well:**
The helper adds no resolver; it adapts envelope and transcript input to `Resolve-HookTargetWorktree`. The session-root case returns the advertised value unchanged, so every pre-existing suite passes with its `ParameterFilter` values untouched. Block messages keep the advertised spelling and only append a probe note, so the message stems pinned by contract tests are unchanged. The coverage hook's unresolved-target block reads nothing from the session root. Its freshness rule uses the committer time of the newest language-touching commit, which is deterministic and needs one `git log` per language. The transcript readers moved without change.

**Top 3 risks:**
1. F1: a gate-admitted prompt with only the canonical issue line, or with a second `branch:` token after the item label, does not resolve. In a main-checkout session the coverage hook then blocks repairably on every stop, and neither form of advertised path clears it.
2. A review in an item worktree now blocks when no coverage report was produced there. The message names the expected path, as the spec intends, and in-flight runs see this only after merge.
3. The git-failure freshness block is non-repairable, so under `stop_hook_active` it passes on the second stop without the floor checks. This matches the hook's existing handling of an unreadable `CLAUDE.md`.

**PR readiness recommendation:** **Not ready.** Remediate F1 first.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/hooks/subagentstop-target-worktree.ps1` (and bundle copy); consumers `.claude/hooks/validate-feature-review-coverage.ps1` and the five artifact hooks | `Resolve-SubagentStopTargetWorktree`, lines 176-186; coverage hook unresolved-target block | F1. The helper passes the whole prompt to `Resolve-HookTargetWorktree` without a `CheckpointIssueReader`. That resolver collects every `branch:` token and cannot place an issue line without a reader. The model-routing gate (`Resolve-WorktreeItemTarget`) reads the first `branch:` occurrence and places an issue-only prompt through the checkpoints. Real-process probes: an issue-only prompt gives `TARGET_WORKTREE_NOT_DERIVABLE` ("issue 1 cannot be placed without a checkpoint issue reader"); `branch: feature/x-1` followed by `base branch: main` gives `TARGET_WORKTREE_AMBIGUOUS`. With `stop_hook_active` true in a main-checkout session, the coverage hook returned a repairable block for relative paths. For absolute paths inside the session root it returned the location-rule block, so the remedy the message names does not work there. Before this branch the same review read its artifacts from the session root and could pass. In an item-worktree session, the artifact hooks fall back to the session root for these shapes, which is the original defect. | In the helper, pass `Resolve-HookTargetWorktree` a prompt reduced to the first `branch:` label and the canonical issue line(s), matching the orchestrate contract ("written as the first `branch:` occurrence"). Resolve an issue-line-only prompt as the gate does: supply a `CheckpointIssueReader` that reuses the existing checkpoint issue reader, not a new resolver. Correct the coverage hook's remedy text so it does not advise absolute paths when the resolution would fall to the session root. Add tests for both prompt shapes in the helper suite and the coverage suite, plus one artifact-hook case. | `spec.md` assumes "every delegation that reaches SubagentStop ... passed the model-routing gate and therefore carries resolvable identity". The probes show that the gate admits shapes this helper cannot resolve. `Resolve-HookTargetWorktree` stays unchanged, as the spec requires. Remediability class: `autonomous`. | Reviewer probes in the session scratchpad: the helper over nine shapes with an injected worktree list and transcript; `Invoke-FeatureReviewCoverageValidation` with `stop_hook_active: true`, `SessionRoot '/repo/main'`, and four prompt and path combinations. `Find-WorktreeResolutionBranchSignal` (first match) in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`; `Resolve-WorktreeItemTargetByIssue` in `WorktreeItemResolution.psm1`. |
| Minor | `.claude/hooks/validate-executor-output.ps1` | `Get-ExecutorOutputBlockDecision`, resolution at about line 324 and `Test-IsPreflightRun` at line 334 | F2. For a relative `plan-path`, the transcript head is read twice per invocation: once by `Resolve-SubagentStopTargetWorktree` and once by `Test-IsPreflightRun`. | Read the head once and pass the lines to both, for example by giving the helper's caller the lines or a memoizing reader. | `spec.md` Performance constraints: "one 50-line transcript head read". The cost is small, so this is non-blocking. Remediability class if pursued: `autonomous`. | Code inspection of the two call sites. |
| Nit | `.claude/hooks/subagentstop-target-worktree.ps1` | `Resolve-SubagentStopArtifactPath`, line 227-228 | F3. A relative value with `..` segments is joined beneath the item root without normalization. The probe `../../../etc/passwd` gave `<item>/../../../etc/passwd`, and `docs/features/active/../../x/spec.md` matches the required-artifact pattern. | Optionally reject a value that contains a `..` segment before the shape rules run. | The class pre-dates the branch: the hooks probed the same value relative to the process directory before. The hooks only test for existence and read text, so no write is possible. Remediability class: none required. | Reviewer probe of `Resolve-SubagentStopArtifactLocation`. |

No covered file reaches the 700-line advisory tier (largest `validate-planner-output.ps1` at 469 logical lines), so no `Warning` row applies. `config/file-size-baseline.json` is not in the branch diff.

---

## Python

No Python file changed. The six contract modules that pin mirrors, the manifest, and the brief passed in the reviewer's run (126 tests).

## TypeScript

No TypeScript file changed.

## PowerShell

**What changed well:** every hook loads the helper with the guarded single-statement pattern, and the freshness sibling loads only in the coverage hook. The helper imports `HookTargetWorktree.psm1` with `-Force`, behind the same guard. New functions are advanced functions with `OutputType` and explicit `AllowNull` and `AllowEmptyString` parameters. Reader functions in the metrics sibling take an optional `Root` and keep the process-relative default, so `Test-LanguageCoverageRow` and `Get-CoverageNarrowingLine` (pinned by Codex parity tests) are not edited.

**Safety:** the artifact hooks never fall back to the main checkout once an item root resolves. The probe path is the item copy, and the main-only cases in every suite assert zero reads outside the item root. An absolute value outside every registered worktree reaches the unchanged shape rules and is rejected. The coverage hook's not-derivable and ambiguous cases read no artifact and no report, as `Should -Invoke ... -Times 0` asserts in the suite. The freshness decision passes the root and fixed pathspecs to `git` as separate arguments, and evaluates no string.

**Session-root invariant:** for a prompt with no identity, a branch label naming the session root's branch, and an absolute path inside the session root, the reviewer's probes returned the session root with the advertised value unchanged. All 21 pre-existing suites of the edited hook families pass with no edits. The freshness suite asserts that no probe runs for source `SessionRoot` or a root equal to the session root.

PSScriptAnalyzer with the repository settings and `Invoke-Formatter` report 0 findings and 0 differences on the 18 changed non-bundle PowerShell files (reviewer run). Coverage: 100.00% on the helper (73 of 73), 97.96% on the freshness sibling (48 of 49), and 98.31% to 100.00% on the eight edited hooks.

## C#

No C# file changed.

---

## Test Quality

- **Discrimination.** The main-only and both-checkouts cases assert the read location with `ParameterFilter`, so a fallback to the process-relative path fails them. The coverage suite's `reads ... only beneath the item root` case asserts zero calls with an empty `Root` for the summary and `CLAUDE.md`. The stale-report case asserts zero floor reads.
- **Seams.** Transcript, worktree list, git, report time, and file reads are injected or mocked. No new suite starts a process or touches the file system.
- **Linux safety.** Fixture roots are `/synthetic-worktrees/main` and `/synthetic-worktrees/main/.claude/worktrees/bug-1105`.
- **Fail-before.** Replaced by the exception dossier under `evidence/regression-testing/`, which cites the merge-base code for each suite under the owner's parallel-only test rule.
- **Gap.** No case covers an issue-line-only prompt or a second `branch:` token (F1).

## Security and Correctness

No command text is evaluated. The one new process call is the default `GitInvoker`, `git -C <root> log -1 --format=%ct HEAD -- <pathspecs>`, with arguments passed separately. File reads stay behind existing or new named seams. Correctness concerns are F1 (identity parsing) and F3 (path normalization, pre-existing).

---

**Review completed by:** feature-review agent
