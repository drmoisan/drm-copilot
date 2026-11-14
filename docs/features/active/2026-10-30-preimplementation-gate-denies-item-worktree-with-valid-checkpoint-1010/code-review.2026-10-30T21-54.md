# Code Review: Preimplementation gate resolves the target worktree checkpoint (#1010)

---

**Review Date:** 2026-10-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010`
**Feature Folder Selection Rule:** the only active folder whose suffix matches issue 1010 in the branch name; it holds the material scoping-doc changes.
**Base Branch:** `main` (merge base `0c0027faefff4231a129579b2a850fe4c377f4e8`)
**Head Branch:** `bug/preimplementation-gate-item-worktree-1010` (`84a345c7dd8910b8c7a28ce2ffc5958aa3d73877`)
**Review Type:** Initial review

---

## Executive Summary

The branch fixes the preimplementation gate evaluating the coordinator session-root checkpoint instead of the checkpoint of the worktree a call targets. On the Claude surface, the path and command legs of `Resolve-OrchestrationGateTarget` now call `Resolve-HookTargetWorktree` (#1009) with the `file_path`, or with every `-C` selector and absolute operand of every `git add` / `git commit` invocation, and adapt the result to the existing `{ Status, WorktreeRoot, ReasonCode, Detail }` shape. On the Codex surface, the single-feature read, which was cwd-relative on every leg, now goes through new Codex `Resolve-OrchestrationGateTarget` / `Read-OrchestrationGateCheckpoint` functions, including `apply_patch` marker paths. Both gates treat `lifecycle_ready` as ready only when it is the JSON boolean `true`. The diff was reviewed against `main` using the refreshed PR context, direct inspection of the four production diffs, the coverage artifact, bundle comparisons, the feature evidence, and a 273-test re-run of the affected suites.

**What changed:**
A recording invoker (`Invoke-OrchestrationGateWorktreeList`) wraps the single listing seam (`Get-OrchestrationGateWorktreeList`) and sets `$script:OrchestrationGateWorktreeListFailed` when the listing throws or names no worktree, so the gate denies with `TARGET_WORKTREE_NOT_DERIVABLE` instead of accepting the resolver's session-root fallback (spec E1). Ambiguous results deny with `TARGET_WORKTREE_AMBIGUOUS`. The Claude `Get-OrchestrationEpicScopeSelector` is removed. The Codex `Get-CheckpointContent` moved into the Codex `-epic-scope` file with a mandatory, pattern-validated absolute `-Path`; the Codex gate shrank to 491 lines and stays under its 500-line pin.

**Top 3 risks:**
1. The three building-block functions and the adapter body are duplicated between the Claude and Codex `-epic-scope` files and described in the Codex header as byte-identical, but no test compares their text; behavior parity rests on the two suites running matching B-rows.
2. A gated call whose session root is outside any registered worktree listing (for example, a session root outside a repository) and whose target is absolute now denies as not derivable, where it previously read the session-root checkpoint. This is the spec's E1 intent, but it is a behavior change for consumers.
3. `git commit` pathspec operands that follow an option the shared invocation parser does not model (for example `git commit -m msg /abs/wt/file`) are not collected, so such a commit is still evaluated against the session root. This fails toward deny for a coordinator and is recorded as a deviation in the self-review.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all local gates pass, and the PR-head CI run is owned by the S9 gate.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `Get-OrchestrationGateWorktreeList`, `Invoke-OrchestrationGateWorktreeList`, `Get-OrchestrationGateCommandOperandPath`; adapter tail of `Resolve-OrchestrationGateTarget` | The functions are textually identical today (confirmed by this review from the diff), and the Codex header states they are byte-identical to the Claude sibling, but no test pins that identity. The Parity suite's function inventory (`Assert-GateFunctionSet`) covers only the two gate entry-point files, not the `-epic-scope` files. | Add a parity row that compares the `Extent.Text` of the three functions across the two `-epic-scope` files, in the style of the nine parity rows in `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1`. This can be done inside this item. | Two hand-maintained copies of enforcement logic can drift silently; the bundle-parity contracts compare each source to its bundle, not Claude to Codex. | `git diff 0c0027fae..HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`; `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` lines 151-189 |
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (and Codex twin) | `Get-OrchestrationGateCommandOperandPath` | Only `-C` global-option values and absolute entries in `$match.Operands` are collected. Pathspecs after an option the invocation parser does not model (for example `-m <msg>`) are not collected, so `git commit -m msg /abs/wt/file` resolves to the session root. | Document `git -C <wt> commit` and `git add <wt>/file` as the supported forms in the PR description alongside R4, or extend the parser in a later item if a consumer needs the pathspec form. | Behavior fails toward the pre-fix evaluation (session root), not toward a relaxation; the spec's acceptance rows (`-c k=v -C`, absolute `git add` operand, later-segment `-C`) are satisfied. | `evidence/qa-gates/self-review.2026-10-30T21-33.md` Deviations, third bullet |
| Nit | `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `Resolve-OrchestrationGateTarget`, `$markerPaths` assignment | Every non-path command, including Bash command text, is first scanned with `Get-OrchestrationPatchMarkerPath`; a Bash command whose text contains `*** Add File:`-style lines would be resolved by those marker paths rather than by git operands. | Optional: pass the tool kind (Bash versus `apply_patch`) into the resolver, or accept the current behavior and note it in a comment. | Matches the pre-existing epic-scope leg (same call at line 386), so behavior is consistent within the file; the input is unusual. | Codex `-epic-scope` lines 206 and 386 |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `Get-OrchestrationGateWorktreeList` body | The three body lines (the `git` call, non-zero-exit return, join) are uncovered in both files by design, because every suite mocks the wrapper. | None for this item. | Keeps unit tests free of `git` processes; the uncovered lines are visible in the coverage metric as the policy intends. Each file remains above 96%. | `evidence/qa-gates/coverage-delta.2026-10-30T21-09.md` |
| Info | Both gates | path and command legs | Each gated call that reaches the single-feature read with an absolute target starts one `git worktree list --porcelain` process (spec R5). | None for this item; monitor hook latency after merge. | Accepted design decision in `spec.md` Performance constraints. Relative paths do not invoke the listing. | `spec.md` R5 |

No Blocker or Major findings. No covered file is at or above 700 logical lines (largest: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at 506; largest production file the Codex gate at 491), so no file-size Warning applies. `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The adapter order (listing failure, then ambiguous, then null root, then session or other worktree) is identical on both surfaces and fails closed at each step.
- Reason codes come from `Get-WorktreeResolutionAmbiguityReasonCode` / `Get-WorktreeResolutionNoTargetReasonCode` on the Claude surface; the Codex restatement is pinned equal by row B9.
- The single-feature deny wording is unchanged; the existing EpicScope and EpicScopeTargets deny-text suites pass without edits.
- `Agent(...)` delegation branches and `Get-OrchestrationEpicScopeDecision` are untouched; `WorktreeResolution.Tests.ps1` (16) passes unchanged and is absent from the diff.
- Removing the cwd-relative `$script:CheckpointPath` read from the Codex gate removes the last single-feature read that bound to the process directory.

#### API and safety notes

- Every new function has `[CmdletBinding()]` and `[OutputType()]`; PSScriptAnalyzer reports 0 findings on all 14 changed PowerShell files.
- `Get-CheckpointContent` (Codex) validates its `-Path` as absolute (`ValidatePattern('^([A-Za-z]:[\\/]|/)')`), and row C15 asserts a relative path is rejected.
- The `git` invocation uses the call operator with an argument list (`& git -C $SessionRoot worktree list --porcelain`), not string-built command text.
- Path comparison with the session root uses `ConvertTo-HookTargetWorktreeNormalizedPath` and `OrdinalIgnoreCase`, consistent with the #1009 resolver.

#### Error handling and logging

- A failed import of `HookTargetWorktree.psm1` (Claude) or dot-source of `hook-target-worktree.ps1` (Codex) is reported through `Add-HookDependencyFailure`; T13 and C16 assert the deny names the file.
- Deny details name the resolver `Source` and `Detail` (`resolver source <Source>: <Detail>`), as `spec.md` requires.

---

## Test Quality Audit

Two new Pester suites were added and four test files were updated. Coverage, regression (fail-before and pass-after), isolation (three seeded shuffles and a single-process full run), and contract-test evidence are present.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` — 26 tests: B1-B8 building blocks, T1-T14 gate decisions, baseline interception probe.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` — 30 tests: B1-B9, C1-C17, including `apply_patch` single-worktree and two-worktree rows.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` — four new readiness rows (`"false"`, `"true"`, `1`, `null`), all `Expected = $false` on both surfaces.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — three rows moved from `Push-Location` to mocked seams with an absolute `-Path`.
- `evidence/regression-testing/fail-before-claude-target-worktree.2026-10-30T20-52.md`, `fail-before-codex-target-worktree.2026-10-30T20-54.md`, `fail-before-readiness-parity.2026-10-30T20-55.md`, and `pass-after-target-worktree.2026-10-30T21-02.md`.
- `evidence/qa-gates/coverage-delta.2026-10-30T21-09.md` — re-verified by this review from `artifacts/pester/powershell-coverage.xml`.

### Quality assessment prompts

- **Determinism:** in-memory listing and checkpoint text; synthetic forward-slash roots; no clock or randomness.
- **Isolation:** one behavior per `It`; the baseline helper registers the listing-wrapper mock for suites requesting the `Get-CheckpointContent` baseline.
- **Speed:** no process or disk I/O in the new rows; this review's 273-test re-run completed in under a minute.
- **Diagnostics:** assertions name the decision, the reason code, and the checkpoint path read.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | Argument-list call operator for `git`; no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Absolute-path validation on the Codex seam; relative operands are dropped by the parser and resolve to the session root. |
| Error handling remains explicit | ✅ PASS | Listing failure, ambiguity, and null root each deny with a named reason code. |
| Configuration / path handling is safe | ✅ PASS | The checkpoint path is composed beneath the resolved root as `<root>/artifacts/orchestration/orchestrator-state.json`. |
| Gate strictness preserved | ✅ PASS | No readiness requirement relaxed; `lifecycle_ready` is stricter; target-mixed rule V1 and the `-targets` files are untouched. |

---

## Research Log

No external research was required. The review relied on the repository's spec, research document, rule files, the branch diff, and the #1009 resolver.

---

## Verdict

The change is ready for normal PR flow. It implements the spec's adapter over the #1009 resolver on both surfaces, closes the Codex cwd-relative read, tightens `lifecycle_ready`, and is supported by per-file coverage of 88% to 97% with no changed-line regression other than the always-mocked wrapper body, plus clean isolation runs. The findings are Minor, Nit, and Info items. The first Minor finding (a text-equality parity row for the duplicated building blocks) is small and related to this item, and can be addressed in-item before merge at the orchestrator's discretion; it is not a blocking finding.
