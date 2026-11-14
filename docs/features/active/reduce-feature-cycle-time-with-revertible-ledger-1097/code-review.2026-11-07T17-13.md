# Code Review: Stage E and Stage E2 Re-audit After the Merge-Conflict Cycle (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `5fe6b94e97360da8767ce167a4fd69b0bda4872e`, the merge commit of PR #1108; `origin/main` is at `a2e338950`, PR #1111, a release version bump)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `2f655129692b8d5836657bce5281b5f86f95c008` (PR #1110)
**Review Type:** Re-audit of PR E (stage E and stage E2) after the merge-conflict cycle of `remediation-inputs.2026-11-07T16-16.md` (313 files, 62 commits)

---

## Executive Summary

Since the prior review (`code-review.2026-11-07T16-07.md`, head `9676eed60`), the branch recorded that review and the PR number of entries `0004` to `0006` (`41caab5a1`), became conflicting after PR #1108 merged into `main`, and ran stage F1:

- `699e03563` merges `origin/main`. In all ten conflicted paths, PR #1108's side differs from the old merge base only by its token renames (`xUnit` to `MSTest`, `Pester v5` to `Pester v6`). The resolution keeps this branch's text and applies those renames. The reviewer confirmed this with word-level diffs of each source against the pre-merge head and of PR #1108's diff of the same files: both consist of the same renames only. Each bundle equals its source, and the conflict-marker path count is unchanged (23).
- `8d0ee095d` (`reduction: 0006`) regenerates the `0006` patch over its 217 paths; `git apply -R --check` exits 0.
- `ba6563e59` (`reduction: 0001`) regenerates the 16 sections of the `0001` patch that PR #1108 broke.
- `2f6551296` rewrites the acceptance of [P1-T3] after execution and checks it.

The merge finding is closed. No blocking finding remains.

The orchestrator asked this review to judge whether the PR worsens the known `0001` revertibility gap and to classify that gap. It is recorded as RF1, Major and non-blocking, owned by the planned stage R:

- **The F1 cycle did not worsen it.** The failing-path lists at the pre-merge head and at this head are identical (44 paths each).
- **The branch worsened it, but less than the live-tree count suggests.** On `main` the `0001` patch fails 18 paths. On this branch, with `0006` reversed first, it fails 44. A full newest-first revert in memory (`0006` patch, then the blocks of `0005` to `0002`, each entry read from the chain state) applies all 126 blocks. On that result, the 21 newly failing sources reduce to one real failure: the brief `.claude/skills/execution-environment/SKILL.md`. There, `6c64f0508`, a stage E commit that adds a rule and is not a reduction, put a line inside the context of a `0001` hunk. The other failures are derived files that revert steps 2 and 3 recreate.
- **The gap in kind predates this PR.** No ledger text states the revert order, and entry `0001` says its check "succeeds on the working tree", which is false here and on `main`.
- **Stage R covers it.** `plan.2026-11-07T12-03.md` appeared untracked during this review. It adds the order rule, the corrected sentences, a chain test, and [P1-T8], which closes every gap the chain reports.

**What changed well:**
The merge resolution follows a stated rule, and the rule was checked for every conflict hunk rather than assumed. Each patch was regenerated over its whole path set, not edited by hand, and the regenerated hunks differ from the old ones only by the renames. The executor recorded the pre-existing `0001` failure with `EXIT_CODE: 1` and an explicit escalation instead of hiding it.

**Top 3 risks:**
1. RF1: until stage R lands, a reader who follows `0001` as written checks its patch on the live tree, sees 44 failures, and must restore those paths by hand. The order rule that reduces this to one hunk exists only in an uncommitted draft plan.
2. The stage R plan states that the 44 paths fail "only because the check runs on the live tree". The brief hunk from `6c64f0508` is an exception; stage R's chain test and [P1-T8] would find it.
3. N1: the [P1-T3] evidence and plan disagree. The evidence says the task stays unchecked, and the plan checks it under rewritten acceptance text.

**PR readiness recommendation:** **Ready to merge once CI is green at the final head.** Before merge, commit the stage R plan (a feature-folder path, so the review stays current) and note the brief hunk in it.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`, `patches/0001-parallel-only-test-gates.patch`, `README.md`, `.claude/skills/execution-environment/SKILL.md` | `0001` `## Stored Patch` and `## Revert Steps` step 1; README format rules; the brief's contract-test list | RF1 (non-blocking, owned by stage R). Entry `0001` is not mechanically revertible. (a) Its check sentence says the patch "succeeds on the working tree". The patch fails 18 paths on `main`, 195 here, and 44 after the `0006` reversal that its step 1 requires. (b) No README or entry text states that entries are reverted newest-first. (c) After a full newest-first revert, where all 126 blocks of `0005` to `0002` apply in sequence, 14 of 22 failing sources pass. Seven of the other eight are derived (five Codex variants, two brief mirrors). One source, the brief, still fails, because `6c64f0508` added the `planning-contract-wording.Tests.ps1` line inside the context of the `0001` hunk on the test list. The core rule of `0001` is restorable through its four blocks, which apply after the `0006` reversal. | Carry RF1 in stage R as planned. Before PR #1110 merges, commit `plan.2026-11-07T12-03.md`, and add the brief hunk from `6c64f0508` to its known gaps; its R5 remedy (regenerate the hunk so it carries the edit in both images) applies. Correct the scope sentence that attributes all 44 failures to the live-tree check. | Classification: a pre-existing design gap. It is present on `main` from stages C and D, this PR does not create it, and a written plan sequenced next covers it. It is not blocking for PR E: the review skill's ledger rule (an entry in the same commit as each reduction) is met, the owed `[E]` criterion for entry `0001` holds, and the delivery stages place later work in later PRs. Had it been made blocking, its class would be `autonomous` with design scope. The narrowed [P1-T3] does not close it. | Scratch-index probes: `0001` check at `5fe6b94e9`, 18 failing; at `a64e59cde` and `HEAD` after the `0006` reversal, 44 each, lists equal; at `HEAD` without the reversal, 195. Chain probe: `0005` 44, `0004` 3, `0003` 49, `0002` 30 blocks applied; per-path `git apply -R --check --include` gives 14 passing and 8 failing. `git show 6c64f0508`. `git diff --stat 5fe6b94e9 a64e59cde` of the `0001` patch is empty. |
| Minor | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T16-16.md`, `evidence/other/stage-f1-patch-rebase-0001.2026-11-07T16-39.md`, `evidence/qa-gates/self-review.2026-11-07T16-58.md` | [P1-T3] acceptance; artifact `Output Summary` | N1. `2f6551296` rewrote the [P1-T3] acceptance after execution and checked the task. The evidence artifact still reads `EXIT_CODE: 1`, "[P1-T3] stays unchecked", and "escalated", and the self-review lists the same item as open. | Add a dated note to the plan stating that the acceptance was narrowed after execution and that stage R carries the gap. Do not edit the existing artifact. | The records disagree about whether the task passed. Record only. | `git show 2f6551296`; the two evidence files. |
| Minor | `.claude/skills/atomic-plan-contract/SKILL.md` (six copies), QA gates, executor profiles | Restored "no per-file or repo-wide coverage drop" wording | N2 (carried from prior N1). The comparison is stated over raw totals, and one branch arc of the unchanged `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` depends on thread timing. In this run that file reads 61 of 88 branches against 62 of 88 at the baseline. The repo-wide total rose because PR #1108 added tests. | For the owner: state the precision of the repo-wide comparison, or apply the no-drop rule to changed files only. Separately, make the arc deterministic in its tests. | The review skill judges repo-wide coverage by threshold. Remediability class if made blocking: `human_decision_required`. | `stage-f1-test-gates.2026-11-07T16-57.md`; `artifacts/python/lcov.info` BRF 12558, BRH 11825. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` | Header block | N3 (carried from prior N2). The header still reads `Last Updated: 2026-11-06T21-23` and `Version: 0.1`. | Update it when stage R [P1-T1] edits the spec. | Record only. | `spec.md` lines 6 and 8. |
| Nit | `.claude/agents/feature-review.md` and `.codex/agents/feature-review.toml` | Modified-file coverage rule | N4 (carried from prior N3). The Claude text names changed lines and the Codex text names the file's line figure. | None required. | The two profiles are not mirrors. Record only. | Prior review. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is 566 logical lines (`tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`). `config/file-size-baseline.json` is not in the branch diff.

### Prior findings

| Finding | Status | Evidence |
|---|---|---|
| F1 of `remediation-inputs.2026-11-07T16-16.md`: PR #1110 conflicts with `main` | Closed | Two-parent merge `699e03563`; both sides kept (word-diffs); bundles equal; generator `--check` exit 0; `0006` patch `git apply -R --check` exit 0; `gh pr view 1110` reports `MERGEABLE`. |
| N1 of `code-review.2026-11-07T16-07.md`: repo-wide comparison precision | Open, non-blocking | Carried as N2. |
| N2 and N3 of `code-review.2026-11-07T16-07.md` | Open, record only | Carried as N3 and N4. |

---

## Detailed Notes

### Merge resolution

- PR #1108's diff of the five conflicted sources, from `bad886e30` to `5fe6b94e9`, consists of renames only: 3, 2, 2, 1, and 2 `xUnit`/`MSTest` or `v5`/`v6` word pairs. The resolved sources differ from the pre-merge head by 3, 4, 4, 1, and 2 such pairs. The difference between those counts is the sweep of this branch's own added lines, which the merge artifact lists (11 sweep renames and 3 auto-merged).
- No `xUnit` or `Pester v5` remains in the five sources, so PR #1108's `policy-toolchain-naming.Tests.ps1` holds. Its 18 tests passed in the gate.

### Patch rebases

- `0006`: the 217-path set is unchanged, and `git apply -R --check` exits 0 (reviewer).
- `0001`: the 16 rebased sections are those PR #1108 broke. `git diff 5fe6b94e9 HEAD` of the patch shows 52 changed lines per side: 36 hunk lines and 16 `index` lines.

### Revert order (RF1)

- Revert routes were tested only per entry. `ProcessReductionLedger.Replay.Tests.ps1` replays one sample, and the F1 gate replays every block at head, where every entry is still applied. No test reverses one entry and then replays an earlier one.
- The chain must read each entry's text from the chain state, not from the live file, because the `0006` patch also edits entries `0001` and `0005`. The reviewer's first probe read `0005` from the live file and reported 16 missing fences. That was a probe error, and its result is withdrawn. Stage R's design already reads entries from the chain state.
- A non-reduction commit can break an earlier entry's patch context, as `6c64f0508` did, because the ledger rule covers only reductions. Stage R's R5 makes such an edit fail CI through the chain test, and its README remedy regenerates the hunk in the same commit.

### Security and correctness

No production code changed after stage E. The stage E production files are at 100% and 99.52% line coverage in the F1 gate.
