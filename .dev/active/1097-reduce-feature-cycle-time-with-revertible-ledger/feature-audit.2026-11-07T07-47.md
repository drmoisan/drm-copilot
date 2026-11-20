# Feature Audit: Concurrent Review, Stage C (#1097)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main`
**Head Branch:** `feature/reduce-feature-cycle-time`
**Work Mode:** `full-feature`
**Audit Type:** First review of PR C (stages A and B merged as PR #1100 and PR #1101)

---

## Scope and Baseline

- **Base branch:** `main` (commit `278bb7047db986bbb0a8652ca323656ce85f8a08`, equal to `origin/main` after a fetch)
- **Head branch/commit:** `feature/reduce-feature-cycle-time` (commit `0a09dacd33e01be591869a949ff373b5f83fbb88`)
- **Merge base:** `278bb7047db986bbb0a8652ca323656ce85f8a08`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, generated 2026-11-07 07:35:05 UTC for this head
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, and reviewer real-process probes
- **Feature folder used:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** the audit covers the full branch diff. `spec.md` `## Delivery Stages` states that a PR owes criteria tagged with its stage and earlier ones, so this PR owes the six `[A]`, two `[B]`, and seven `[C]` criteria. Criteria tagged `[D]` to `[I]` are delivered by later stages.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` — primary
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md` — secondary; its 40 criteria are identical to `spec.md`, including checkbox state

### Acceptance criteria

1. [A] `docs/engineering/process-reductions/` exists with a `README.md` index, and a test fails when the index and the entries disagree.
2. [A] A test fails if a ledger entry lacks a required section, covering a complete entry, a missing section, an empty section, and missing prior text, and it also iterates the real entries read-only.
3. [A] The structure test accepts a pending merge commit only in the exact form `Merge commit: pending (PR #N)`.
4. [A] `Invoke-ProcessReductionRevert` restores `Prior` text in memory, normalizes line endings before comparing, and throws when `Current` is absent.
5. [A] The review skill and all its mirrored copies state the standing rule, conditional on the ledger folder existing, and state that one-off waivers are not entries.
6. [A] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures, under the Testing Rule, at each stage.
7. [B] Stage timing is recorded in the checkpoint and in committed evidence, and is reported per stage by `Get-StageTimingReport.ps1`, which labels figures as wall-clock and states that the merge stage is not captured.
8. [B] A test proves that `stage_timing` passes each validator and survives portable handoff.
9. [C] The merge guard commit precedes the readiness relaxation commit on the branch.
10. [C] Under `review_mode: "concurrent"`, merge is denied with review passed and CI pending, and with CI green and review pending, on each guarded path. On the authorization path, which reads no CI result, the required `CI Required Gate` context is the control, and the spec limit in D10 applies.
11. [C] The guard denies a stale head after a code change, including a merge of `origin/main`; a git failure; an unresolved head; and a bare command under the key. It allows a predecessor head whose later changes are only feature-folder paths.
12. [C] The Claude guard and its Codex twin behave the same on these cases.
13. [C] A test proves that a checkpoint without the key makes no `gh` call, receives no new denial, and receives no readiness relaxation.
14. [C] `step7_status: pending` stops blocking PR readiness only under the key, and `require_complete` under the key requires the same `PASS` record in the Python, TypeScript, and PowerShell validators.
15. [C] The orchestrate skill defaults new runs to concurrent and requires a `CI full run` at the join, the parallel merge-on-green step does not record `ci_green` while the child's review is unresolved, and the concurrent reduction lands as its own commit with its entry.

The remaining 25 criteria are tagged `[D]` (4), `[E]` (6), `[F]` (3), `[G]` (3), `[H]` (2), and `[I]` (7). They are not owed by this PR.

---

## Acceptance Criteria Evaluation

| # | Criterion (short) | Status | Evidence |
|---|---|---|---|
| 1 | Ledger index and index test | PASS | Delivered in stage A. `Test-ProcessReductionLedger` is valid at this head with 2 rows. |
| 2 | Entry structure test | PASS | Delivered in stage A; the real entries, now two, are valid. |
| 3 | Pending merge commit form | PASS | Delivered in stage A. Entry `0002` uses the exact form. |
| 4 | Revert in memory | PASS | Delivered in stage A; the reviewer replayed 24 blocks at this head. |
| 5 | Review skill standing rule | PASS | Delivered in stage A; the skill text is present at head. |
| 6 | Gates pass at each stage | PASS | Stage C gates recorded `ExitCode` 0 with 14801 tests and 16138 passed, 0 failed. The JUnit file agrees. The gates ran on the commit before the merge of `origin/main`, and no production file of this branch changed in that merge. CI run 42351876419 at this head concluded `success` on all 23 jobs, including `CI full run`, so the merged tree is covered. |
| 7 | Stage timing report | PASS | Delivered in stage B. |
| 8 | `stage_timing` tolerated | PASS | Delivered in stage B. |
| 9 | Guard precedes relaxation | PASS | `git merge-base --is-ancestor 9d0af380e ee44aaa86` exits 0. |
| 10 | Merge denied on each guarded path | PARTIAL | The `RGP-` rows pass, and the real gate process denied a pending review for a number, a URL, `gh api`, `sh -c`, a leading `git status &&`, and `gh -R`. However, `if ...; then gh pr merge 1101 --merge; fi`, `exec gh pr merge 1101 --merge`, and `! gh pr merge 1101 --merge` returned `allow` with a pending review. D10 does not list this limit. See F1. |
| 11 | Stale, failure, bare, predecessor | PARTIAL | Real `git`: equal head Current; a feature-folder-only predecessor Current; a code predecessor Stale; a merge of `origin/main` Stale; a non-ancestor Stale; an absent object Unresolved; an invalid folder Unresolved. A bare command alone is denied, but `gh pr merge 1101 --merge; gh pr merge --merge` returned `allow` on the epic-child path, because only the first selector is read. See F1. |
| 12 | Claude and Codex behave the same | PASS | The guard files are byte-identical and the shared rows run through both gates (`RG-TWIN-IS-BYTE-IDENTICAL`). F1 applies to both gates equally, because `enforce-epic-merge-gate-command.ps1` is also byte-identical. |
| 13 | No key: no `gh`, no denial, no relaxation | PASS | `RGP-NOKEY-` rows with `-Times 0 -Exactly` seam assertions, `RGC-NOKEY-` rows, `test_readiness_blocks_pending_step7_without_key`, `OCR-READINESS-BLOCKS-WITHOUT-KEY`. Real gate process with no key: allowed by the green-CI branch as before. |
| 14 | Readiness and `require_complete` | PASS | Read in all three runtimes, with the corpus through each. The reviewer ran the Python CLI on simulated checkpoints: pending step 7 passes readiness under the key. The key-case gap in PowerShell is Minor F4 and does not affect the value `concurrent` under the exact key. |
| 15 | Skill default, join, parallel step, own commit | PASS | Section read in all copies; `CRS-` rows pin it. `CI full run` exists in `ci.yml`. Entry and relaxation land together in `ee44aaa86`. The subject token differs from the entry number, which the entry discloses (Minor F2). |

---

## Summary

- **Owed criteria:** 15
- **PASS:** 13
- **PARTIAL:** 2 (items 10 and 11)
- **FAIL:** 0
- **UNVERIFIED:** 0
- **CI note:** CI run 42351876419 at this head concluded `success` on all 23 jobs, which covers the merged tree for item 6.

The partial results share one cause, F1. The guard's logic is correct for every command the gate reads. The gap is in which commands reach it.

Owner condition check:

1. Revertibility: met. The entry replays to `origin/main` at this head.
2. Baselines: met. The branch removes no baseline task or evidence, and it adds stage C baselines.
3. Merge control: not met until F1 is resolved, because the limit is not stated in D10.
4. Older checkpoints: met. Every rule is key-gated; no existing fixture changed; no Epic #1019 folder is in the diff.

---

## Acceptance Criteria Check-off

Newly checked: none. The `[A]`, `[B]`, and five `[C]` items were already checked and were evaluated PASS.

Moved back to unchecked in both `spec.md` and `user-story.md`, because each evaluated PARTIAL and the executor had checked it:

- `[C] Under review_mode: "concurrent", merge is denied ...`
- `[C] The guard denies a stale head ...`

Only the checkbox changed. No criterion text changed.

### AC Status Summary

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md`, `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 40 in each file
- Checked off (delivered): 13
- Remaining (unchecked): 27
- Items remaining: the two `[C]` items above, and the 25 items tagged `[D]` to `[I]`, which later stages owe.

---

**Audit Completed By:** feature-review agent
