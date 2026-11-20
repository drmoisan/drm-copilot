# Code Review: Standalone orchestration merge on green (#997)

---

**Review Date:** 2026-10-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997`
**Feature Folder Selection Rule:** the only active feature folder added on the branch; its suffix matches issue #997 in the branch name.
**Base Branch:** `main` (merge base `fd4fe5b2985f3caaaffb60d9dc393584e7750c3a`, equal to `origin/main`)
**Head Branch:** `bug/standalone-orchestration-merge-on-green-997` (`98c851059de5aaa048b4a3578f678f1bc1ac05c5`)
**Review Type:** Initial review of the full branch diff

---

## Executive Summary

The branch loosens a merge authorization control. Before it, a standalone orchestration could merge its own pull request only through a session-bound #670 `standalone_merge_authorizations` record. After it, the merge gate also allows the merge when the per-feature checkpoint records a green S9 gate for that exact pull request and the live pull-request head still equals the head CI passed on. The new branch (3b) runs only after branches 1 to 3 decline and before branch 4, and every non-green case declines silently, so all existing deny strings except the final one are unchanged.

Because the change widens an allow path, this review examined each fail-closed case adversarially against the source, not only against the tests. Every case named by the caller declines, and the parallel-child exclusion is described as best-effort in all six places it is mentioned.

**What changed:**
- New sibling `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` (321 lines): two pure checks, one live-head seam, one head-agreement check, one parallel worktree seam, a stage-B helper, and the stage orchestrator.
- `.claude/hooks/enforce-epic-merge-gate.ps1`: one guarded dot-source line, one call and early allow, one suffix append on the branch-4 deny, and the updated final deny text and header.
- Three new Pester suites; three deny-text pins; row C9 in `hook-dependency-failure.SpecialCases.Tests.ps1`.
- Prose in `orchestrator-state.md`, `parallel-orchestration.md`, `orchestrate/SKILL.md` (S9 step 7, checkpoint schema, PR Creation Gate condition 7), and `parallel-orchestrate/SKILL.md`; byte-identical mirrors; `core.json`.

**Top 3 risks:**
1. A parallel child whose parent has recorded neither its PR number nor its worktree path, and which has not written `parallel_mode`/`parallel_slug`, is not excluded by the hook. This residual window is inherent (the `Parallel mode: true` marker is not in a Bash payload) and is disclosed in the hook header, the sibling header, both rules, and both skills.
2. The control trusts the checkpoint's recorded `ci_gate.conclusion`. A session that writes a false `success` can merge. This is the same trust model as branch 1 and the #670 record, and the rules call it a policy-level control, not a security control.
3. A push between the stage D lookup and the merge changes the head unless `--match-head-commit` is passed. The hook does not require the flag (decision D8); the skill prose instructs passing it, and when it is passed `gh` enforces the pin server-side.

**PR readiness recommendation:** **Go**. No Blocker, Major, or Minor finding. Two Low and three Info observations are recorded below; none requires a remediation cycle. Merge remains subject to the S9 CI green gate on the final PR head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low | `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` | `Get-EpicMergeGateGreenCiDecision`, stage C (reuses `Get-DocsOnlyMergeShapeViolation`) | Stage C rejects chains, wrappers, environment prefixes, `-R`, `--repo`, `/pull/` selectors, and `--auto`, but accepts `--admin`, `--squash`, and `--rebase`. A green standalone checkpoint therefore admits `gh pr merge <PR> --admin`, which bypasses branch protection rules. | Optional follow-up: decline `--admin` in the green-CI branch, or record the acceptance as a decision in the rule prose. | AC-14 enumerates exactly the rejected shapes, and the docs-only branch makes the same choice, so this is within the approved scope. The live-head and CI checks still apply, and the skill prose issues `--merge` with `--match-head-commit`. | Source read of `hook-docs-only-diff.ps1` lines 361-378; spec AC-14. |
| Low | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (consumed, not edited) | `Get-WorktreeRunCheckpoint` returns `$null` for an unparseable or non-`parallel` checkpoint; `Resolve-WorktreeRunTargetByRecord` skips it | Layers 1a and 1b treat a corrupt parallel-orchestrator checkpoint as "no record", so the green branch does not fail closed on it. The stage-B helper fails closed only on `$null`, a throw, or a non-`NoTarget` status. | No change required for this item. If the exclusion is hardened later, have the resolver report an unreadable run checkpoint as `Ambiguous` for the green-CI caller. | This falls inside the disclosed best-effort window: a parallel child is excluded mechanically only when some readable record names it. The pre-existing branch-4 and docs-only callers use the same resolver semantics. | Source read of `WorktreeRunResolution.psm1` lines 180-193 and 431-437. |
| Info | `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` | `--match-head-commit` rows | A flag with no value (`--match-head-commit` as the last token, or followed by another flag) makes `Get-CommandLineFlagValue` return `$null`; `[string]$null` is `''`, which is non-null and unequal to the live head, so the decision declines with `GREEN_CI_MATCH_HEAD_MISMATCH`. The behavior is fail-closed, but no decision row pins it. | Optional: add one row for the valueless flag. | The pure `Test-EpicMergeGateGreenCiHeadAgreement` documents the empty-string case, and the code path is covered (100% lines). | Source read of `hook-command-invocation-operands.ps1` lines 105-112 and sibling lines 309-320. |
| Info | `.claude/skills/parallel-orchestrate/SKILL.md` | Line 254 | "the merge gate's green-CI branch declines a checkpoint that carries either, so a parallel child cannot merge its own pull request through that branch." The sentence is conditional on the keys being written, but read alone it is more absolute than the best-effort disclosure later in the same file. | Optional wording: "so a parallel child that records them cannot merge its own pull request through that branch." | The same file states the residual window explicitly in the merge-gate paragraph, and no prose file states that the exclusion is mechanically closed (AC-22). | Reviewer `grep` of the six prose files and both hook headers. |
| Info | `artifacts/python/lcov.info` (gitignored) | Pre-existing artifact | The Python coverage artifact present at review start predated the branch work, so the reviewer regenerated it from a full-suite run at head (policy audit, Approved Exceptions). | None. | The only Python change is a test-support constant; repo-wide figures are 94.13% lines and 88.81% branches. | Regenerated `artifacts/python/coverage.json`. |

No Blocker, Major, or Minor findings. No covered file in the branch diff is at or above 700 lines (largest 476), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- One string appended to `MERGE_ON_GREEN_FRAGMENTS`, pinning the new #997 amendment sentence in `parallel-orchestrate/SKILL.md`, alongside the retained "not modified by this feature" fragment.

#### Typing and API notes

- Black, Ruff, and Pyright clean on the file (reviewer).

#### Error handling and logging

- Not applicable; a data constant only.

### TypeScript implementation audit

#### What changed well

- Not applicable; no TypeScript file changed.

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- Not applicable.

### PowerShell implementation audit

#### What changed well

- Placement: the call sits after the parallel allow-branch because `$epicTarget` and `$parallelTarget` are resolved only there. Branches 1 to 3 run first and are unchanged; branch 4 and the docs-only branch are unchanged except that `$greenCi.Suffix` (empty for every stage A to C decline) is appended to the branch-4 deny.
- Ordinal, type-strict comparisons throughout: `-ceq 'passed'`, `-ceq 'success'`, `-cmatch '^[0-9a-f]{40}([0-9a-f]{24})?$'`, `[string]::Equals(..., Ordinal)`. A string `"false"` for `epic_mode`, a number 1, a float or boolean `pr_number`, and an uppercase SHA all fail closed.
- The PR binding reads `pr_gate.pr_number` only. A matching `standalone_merge_authorizations` record does not satisfy it, so the green branch cannot be satisfied by an authorization record standing in for a CI result.
- Stage ordering keeps `gh` out of every non-green path: stages A to C are pure, and the decision tests assert `Get-EpicMergeGateLivePrHeadSha` is invoked zero times when any of them declines.
- The live-head seam returns `$null` on every failure path (`$null` result, non-zero exit including 124 and -1, unparseable JSON, non-object JSON, malformed oid), and the decision converts `$null` into a deny with `GREEN_CI_LIVE_HEAD_UNRESOLVED`.
- The sibling loads through the guarded dot-source pattern; row C9 proves a load failure yields the existing `EPIC_MERGE_GATE_BLOCKED` dependency-failure deny naming the file.
- `cmp` reports both hook files identical to their bundle copies; `core.json` lists the sibling.

#### API and safety notes

- `Get-EpicMergeGateGreenCiDecision` returns `[ordered]@{ Allowed; Suffix }`, matching the spec's contract.
- `Resolve-EpicMergeGateParallelItemByWorktree` passes `(Get-Location).Path` as the session root, consistent with the other resolution seams in `enforce-epic-merge-gate-resolution.ps1`.

#### Error handling and logging

- The stage-B helper wraps the worktree seam in `try`/`catch` and declines on a throw, with a comment stating why. No new logging channel; the deny suffix carries the stage D and E outcome.

### C# implementation audit

#### What changed well

- Not applicable; no C# file changed.

#### Type safety and API notes

- Not applicable.

#### Error handling and logging

- Not applicable.

---

## Test Quality Audit

The reviewer re-ran the eight merge-gate suites at head (229 passed, 0 failed), PSScriptAnalyzer over nine changed PowerShell files (0 findings), the full Python suite with branch coverage (7429 passed), and the Python static checks. Results are in the policy audit.

### Reviewed test and QA artifacts

- `enforce-epic-merge-gate.GreenCi.Tests.ps1`: pure-function matrix with one row per fail-closed input, plus the live-head wrapper through a mocked `Invoke-DocsOnlyGhExe` for six outcomes and the worktree-seam argument forwarding.
- `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`: decisions through `Invoke-EpicMergeGateDecision`, including three allow rows, the three suffix codes, item-target and checkpoint declines, the bare command (asserting the exact final deny text), five parallel-exclusion rows across layers 1a, 1b, and 2, eight command-shape rows, and three stage-ordering rows.
- `enforce-epic-merge-gate.GreenCiRegression.Tests.ps1`: branch 1, the parallel allow-branch, the #670 record, and the docs-only branch still allow; `Test-ChildCheckpointAllowsEpicMerge` still returns false for `epic_mode` false.
- `evidence/regression-testing/expect-fail.2026-10-29T16-27.md` and `pass-after.2026-10-29T16-33.md`: the new rows fail before the sibling exists and pass after.
- `evidence/regression-testing/isolation.2026-10-29T16-55.md`: three seeded shuffles pass.

### Quality assessment prompts

- **Determinism:** fixed synthetic SHAs and roots; no clock, no process, no temporary files.
- **Isolation:** the baseline mock family and interception probe in each new suite prevent a live checkpoint read; per-row mocks use closures.
- **Speed:** all seams mocked.
- **Diagnostics:** `-Because` carries the decision reason or the command text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | `gh` arguments are a fixed array with the integer PR number; stage C rejects chains, wrappers, and substitutions before stage D. |
| Stale head declines | PASS | Live head unequal to `ci_gate.head_sha` -> `GREEN_CI_HEAD_STALE` (decision row; sibling line 317). |
| Pending or failed CI declines | PASS | `ci_gate.conclusion` must be the exact string `success`; pending, failure, absent, case variant, and non-object `ci_gate` rows. |
| `step9_status` not passed declines | PASS | Exact `passed` only; absent, pending, `failed_remediation_required`, `blocked_ci_loop_limit`, case variant rows. |
| Unbound or different PR number declines | PASS | `pr_gate.pr_number` must be a JSON integer equal to the command number; absent, null, string, float, and different rows; authorization record not accepted. |
| Missing checkpoint declines | PASS | Absent and unparseable checkpoint rows; item NoTarget and Ambiguous rows. |
| Bare command declines | PASS | `$commandPrNumber` is `$null`, so `$itemTarget` is `$null` and stage A declines; the row asserts the exact final deny text. |
| `gh` failure or timeout declines | PASS | Wrapper rows for exit 1, 124, -1, unparseable JSON, malformed oid; decision row for `$null` -> `GREEN_CI_LIVE_HEAD_UNRESOLVED`. |
| Differing `--match-head-commit` declines | PASS | `GREEN_CI_MATCH_HEAD_MISMATCH` row; the stale check is evaluated first, so a stale head is never reported as a pin mismatch. |
| `epic_mode` true declines in 3b | PASS | Pure row; branch 1 still owns `epic_mode` true (regression row). |
| Parallel child declines when recorded | PASS | Layers 1a, 1b (including a throwing seam), and 2 each have a separate row paired with the NoTarget allow row. |
| Parallel exclusion described as best-effort | PASS | Hook header, sibling header, `orchestrator-state.md` ("Honest disclosure: the parallel exclusion is best-effort"), `parallel-orchestration.md`, `orchestrate/SKILL.md` step 7, and `parallel-orchestrate/SKILL.md` merge-gate paragraph. No file states that it is mechanically closed (see the Info row on line 254). |
| Branches 1 to 4, docs-only, and #670 unchanged | PASS | Diff shows no edit inside those branches; regression suite and the unchanged `enforce-epic-merge-gate.Tests.ps1` pass (reviewer run). |
| Hook dependency failure fails closed | PASS | Row C9. |
| No host paths in committed artifacts | PASS | Test fixtures use `/synthetic-worktrees/<name>`; test-hygiene evidence. |

---

## Research Log

No external research was required. The review relied on the branch diff, `research/research.2026-10-29T11-46.md`, the spec, the evidence folder, the consumed helpers (`hook-docs-only-diff.ps1`, `hook-command-invocation-operands.ps1`, `WorktreeRunResolution.psm1`, `enforce-epic-merge-gate-resolution.ps1`), and repository policy files.

---

## Verdict

The change is ready for the normal PR flow. The green-CI branch is narrowly gated, fails closed on every case the caller listed, and leaves the existing branches and deny strings unchanged apart from the intended final deny text. The residual parallel-exclusion window and the push-after-lookup race are inherent to a Bash-time hook, are disclosed consistently, and are mitigated by skill prose. The two Low observations (`--admin` acceptance and unreadable parallel checkpoints treated as no record) are candidates for a later hardening item and do not block this one. Merge remains subject to the S9 CI green gate on the final PR head.
