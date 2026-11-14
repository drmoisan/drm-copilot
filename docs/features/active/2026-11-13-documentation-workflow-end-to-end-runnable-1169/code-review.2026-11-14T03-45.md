# Code Review: Documentation Workflow End-to-End Runnable, Part A (Issue #1169), Re-audit After Remediation Cycle 1

**Review Date:** 2026-11-14
**Branch:** `feature/documentation-workflow-end-to-end-runnable-1169` @ `0580d77d765737653b3eda1a7cd4a1f53766ad4c` (PR #1175)
**Base:** `main`, merge base `f9e817b2ace9875b24f3df8ad27b97a4065a435e`
**Scope:** full branch diff `f9e817b2a..0580d77d7`, 173 files (PowerShell hooks, docs library, Pester suites, skill copies, engineering documentation, pack manifests, feature folder). The review re-reads the whole diff and gives particular attention to the cycle-1 commits `3629ae7df`, `b54dfb34e`, `4496e307c`, `2a587e635` and the head merge `0580d77d7`.
**Prior review:** `code-review.2026-11-14T00-21.md` (CR1 and CR2 blocking; CR3 and CR4 non-blocking, brought into cycle 1 by the orchestrator scope decision).

## Executive Summary

All five cycle-1 items are resolved, and the reviewer confirmed each one by direct inspection and by real-process probes of the shipped hooks.

- CR1 (F1): `Get-OrchestrationDocsEstateSegmentShape` now assigns `$rest = @(if (...) { ... })`, so a single remaining token stays a one-element array. A real-process probe of the Claude and Codex preimplementation gates, run from a scratch git repository that holds a valid profile, a docs-only staged index, and no checkpoint, admits `git commit --file=msg.txt` and `git commit --message=docs`. The same probe against the pre-remediation hooks (`32d8c602d`, extracted with `git archive`) denies both. Nine new rows failed before the fix (`evidence/regression-testing/fail-before.F1.2026-11-14T01-37.md`).
- CR2 (F2): the `RECEIPT_ABSENT` message now names `Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -WriteReceipt`, the snapshot-revision default, and `Refresh After Rebase or Source Change`. The reason code is unchanged, and `DocsCompleteGate.Tests.ps1` asserts each token and the absence of the old phrase.
- F3 (FA1): the docs leg reads the profile through `Get-WorktreeResolutionGitFileText`, which both cleanup suites already null-mock, and `Get-OrchestrationDocsEstateFileText` is deleted. `git diff f9e817b2a..HEAD` and `git diff eb73f1dff..HEAD` over both cleanup suites print nothing. The transparency check holds: the only path-agnostic non-null mock of the seam is in a Codex suite that never loads the docs leg.
- CR3: `Test-DocsEstatePath` returns `$false` for any path outside `docs/` other than the workflow constant. Real-process probe: with a profile whose roots are `docs` and `guide` and whose artifact path is `scripts/x.json`, `git add -- guide/start.md` and `git add -- docs/a.md scripts/evil.ps1` now deny with `DOCS_LEG_PATH_NOT_ALLOWED`, and a commit with `guide/start.md` staged denies with `DOCS_LEG_STAGED_PATH_NOT_ALLOWED`. The pre-remediation hooks allowed both add commands.
- CR4: a file-level `AfterAll` removes the dot-sourced functions in the four docs suites.

No blocking finding remains. Two low-severity notes and two file-size warnings are recorded below. None is blocking.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low | `.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1` (four byte-identical copies) | `Get-OrchestrationDocsEstateContextResult`, the `[string]::IsNullOrEmpty($profileText)` check | R1-N1 (non-blocking). A zero-byte `docs-profile.json` now reads as absent, so the A1 leg denies with the unchanged gate text and no `DOCS_LEG_PROFILE_INVALID` suffix. The A2 delegation leg (`enforce-model-routing-receipt-docs.ps1`) reads the same file through its own seam, which returns an empty string, so it reports `DOCS_DELEGATION_PROFILE_INVALID`. Both legs deny; only the diagnostic differs. A whitespace-only or malformed file still yields `DOCS_LEG_PROFILE_INVALID`. | No change required. If the diagnostics are aligned later, record in the spec whether a zero-byte file counts as an absent profile or as an invalid one. | The remediation plan records this as a deliberate decision (`## Premise Corrections and Decisions`, "F3 semantics"), because the reused seam returns `$null` for both an absent and a zero-byte file. The behavior stays fail-closed, and the no-profile deny text stays byte-identical. | Reviewer real-process probe: a zero-byte profile with `git commit -F msg.txt` returns the gate deny text with no docs suffix on both runtimes. Code reading of `Get-ModelRoutingDocsEstateFileText` and `ConvertFrom-DocsEstateProfileText`. |
| Low | Head commit `0580d77d7` | commit message | R1-N2 (non-blocking). The head commit is a merge of `origin/main` (`f9e817b2a`, PR #1176), with a resolved conflict in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Its subject reads "docs(features): revise remediation cycle 1 plan after preflight for issue 1169", which repeats the subject of `eb38b24da` and does not describe a merge. | No rewrite of published history is required. Use a merge subject for later main syncs. | The commit log is the record of the main sync and its conflict resolution. | `git log -1 --format=%P 0580d77d7` lists two parents. `git show --remerge-diff 0580d77d7` shows one conflict, resolved as the union of both `SharedModuleNames` lists. |
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` and its `claude-customizations` bundle copy | whole file | 707 logical lines (700-line advisory tier). Unchanged in cycle 1. | None required. | File-size advisory tier. | Reviewer logical-line count (split on line terminators, trailing terminator not counted). |
| Warning | `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | whole file | 757 logical lines (700-line advisory tier). Unchanged in cycle 1. | Consider splitting by decision step when the file is next extended. | File-size advisory tier. | Same count. |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1` (four copies) | `.NOTES` call-time dependency list | The docs leg now depends on `Get-WorktreeResolutionGitFileText`, which `WorktreeResolution.psm1` (Claude) and `enforce-orchestration-preimplementation-gate-epic-resolution.ps1` (Codex) describe as their own read seam. The dependency is documented in the `.NOTES` block, and both main gates load the defining file before they call the docs leg. | None required. | Recorded so that a later change to the seam contract (for example, throwing on a locked file) is checked against the docs leg as well. | `grep` of both main gates and their epic-scope siblings: `Import-Module ... WorktreeResolution.psm1` (Claude) and `. enforce-orchestration-preimplementation-gate-epic-resolution.ps1` (Codex) precede the call site. |

## Cycle-1 Verification Detail

| Item | Verification | Result |
|---|---|---|
| CR1 / F1 | Diff of `3629ae7df`; real-process probe of both gates at head and at `32d8c602d`; fail-before artifact lists the nine failing rows | Fixed; head admits, pre-remediation denies |
| CR2 / F2 | Diff of `3629ae7df`; `git grep "for the pull request head"` finds only the unchanged pass message (line 201), which is accurate | Fixed |
| F3 / FA1 | `git diff f9e817b2a..HEAD` and `git diff eb73f1dff..HEAD` over both cleanup suites are empty; `git grep Get-OrchestrationDocsEstateFileText` finds no match outside evidence and review documents; transparency check of every `Mock Get-WorktreeResolutionGitFileText` in `tests/` | Fixed |
| CR3 | Diff of `4496e307c`; real-process probe with a discriminating profile (roots `docs` and `guide`, artifact path `scripts/x.json`) at head and at `32d8c602d`; spec definition, A1 criterion 4, and the new A2 criterion revised; six skill copies carry the new sentence | Fixed |
| CR4 | `grep -c AfterAll` reports 1 in each of the four suites; the removal follows the parse-and-remove form of `hook-docs-estate-context.Tests.ps1` | Fixed |
| Mirror parity | SHA-256 of the four copies of `enforce-orchestration-preimplementation-gate-docs.ps1`, `hook-docs-estate-context.ps1`, and `hook-docs-only-diff.ps1` (one hash each); `cmp` of every Claude, `.agents`, and `.github` file with its bundle copy | Byte-identical |
| Head merge | `git diff --name-only 2a587e635 0580d77d7` intersected with the branch diff lists only the two `core.json` manifests (auto-merged union; the five docs entries are present) and `legacy-codex-hook-contracts.Tests.ps1` (conflict resolved as a union) | Neutral for branch content |

## Positive Observations

- F3 reuses a seam that the existing suites already isolate, so 36 suites return to their merge-base text and the discovery guard needs no new token. This removes the coupling that FA1 described instead of documenting it.
- Each CR3 deny row uses a profile under which the old rule admits the outside path, and it asserts that path in the deny reason, so every row fails against the old rule. The reviewer's base-versus-head probe confirms that the old rule admitted those exact commands.
- The fail-before record for F1 names each failing row and states the expected exit code of its runner.
- Evidence is append-only. The cycle added new files beside the superseded ones, and every stamp precedes the commit that carries it.

## Typed-Python Review

Not applicable: the branch changes no Python file.

## Verdict

PASS. No blocking finding. The notes R1-N1 and R1-N2 and the two file-size warnings are non-blocking.
