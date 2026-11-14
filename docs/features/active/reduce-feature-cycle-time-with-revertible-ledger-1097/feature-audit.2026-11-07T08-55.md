# Feature Audit: Concurrent Review, Stage C Re-review (#1097)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main`
**Head Branch:** `feature/reduce-feature-cycle-time`
**Work Mode:** `full-feature`
**Audit Type:** Re-review of PR C after the remediation of F1 (stages A and B merged as PR #1100 and PR #1101)

---

## Scope and Baseline

- **Base branch:** `main` (commit `278bb7047db986bbb0a8652ca323656ce85f8a08`, equal to `origin/main` after a fetch)
- **Head branch/commit:** `feature/reduce-feature-cycle-time` (commit `197f3122a3352aa4ee57832f3f39f5746698d334`)
- **Merge base:** `278bb7047db986bbb0a8652ca323656ce85f8a08`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, generated 2026-11-07 08:40:25 UTC for this head
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, reviewer real-process probes, and CI run 42356449380 read through `gh`
- **Feature folder used:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** the audit covers the full branch diff, 93 files over 25 commits. `spec.md` `## Delivery Stages` states that a PR owes criteria tagged with its stage and earlier ones, so this PR owes the six `[A]`, two `[B]`, and seven `[C]` criteria. Criteria tagged `[D]` to `[I]` are delivered by later stages.

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
| 4 | Revert in memory | PASS | Delivered in stage A; the reviewer replayed 25 blocks at this head. |
| 5 | Review skill standing rule | PASS | Delivered in stage A; the skill text is present at head. |
| 6 | Gates pass at each stage | PASS | At this head `Invoke-PoshQCParallelTest` returned `ExitCode` 0 with 15392 tests and 0 failures, and the JUnit file agrees. `pytest -n auto` recorded 16138 passed and 0 failed at stage C; no Python file changed since then, so the Testing Rule called for no new run. CI run 42356449380 at this head concluded `success` on all 23 jobs, so the Python suites also passed on the final tree. |
| 7 | Stage timing report | PASS | Delivered in stage B. |
| 8 | `stage_timing` tolerated | PASS | Delivered in stage B. |
| 9 | Guard precedes relaxation | PASS | `git merge-base --is-ancestor 9d0af380e ee44aaa86` exits 0. |
| 10 | Merge denied on each guarded path | PASS | Real gate process, both runtimes: review passed with CI pending denied, on the standalone and the epic-child checkpoints; CI green with review pending denied with `REVIEW_GATE_NOT_PASSED`. The `RGP-` rows (21) cover paths 1, 2, 3, 3b, 4, and docs-only, 0 failing. The F1 wrapper and chain forms now deny. Forms that remain readable only at run time are inside the D10 limit; see the note below. |
| 11 | Stale, failure, bare, predecessor | PASS | Real gate process, both runtimes: a code predecessor denied with `REVIEW_GATE_HEAD_STALE`; an absent object denied with `REVIEW_GATE_HEAD_UNRESOLVED`; a bare command denied with `REVIEW_GATE_HEAD_UNRESOLVED`; a feature-folder-only predecessor passed the guard. Real `git`: a merge of `origin/main` Stale; a non-ancestor Stale; an invalid folder Unresolved. A failed head lookup is covered by the `gh-failure` and `gh-unparseable-output` rows. |
| 12 | Claude and Codex behave the same | PASS | The four guard copies are byte-identical, and the same rows run through both gates. All 74 reviewer forms gave the same guard result on both gates: `allow` on Claude paired with no decision on Codex. The two gates differ after the guard only in their existing branches; for example Codex has no green-CI branch. |
| 13 | No key: no `gh`, no denial, no relaxation | PASS | `RG-SHAPE-NOKEY-*`, `RGC-SHAPE-NOKEY-*`, and `nokey-` rows. Reviewer: 56 forms gave the same decision at this head and the merge base, with a keyless checkpoint and with none. `Resolve-EpicMergeGateItemTarget` starts no `gh`. Added latency is Minor R2 and does not affect this criterion. |
| 14 | Readiness and `require_complete` | PASS | Read in all three runtimes, with the corpus through each. F4 is closed: a `Review_Mode` key no longer relaxes PowerShell readiness, confirmed by a reviewer probe and two `OCR-` rows. |
| 15 | Skill default, join, parallel step, own commit | PASS | Section read in all copies; `CRS-` rows pin it. `CI full run` exists in `ci.yml` and passed in run 42356449380. Entry and relaxation land together in `ee44aaa86`. The subject token differs from the entry number, which the entry discloses (Minor F2). |

**Note on item 10 and owner condition 3.** Under the key, brace-expansion forms such as `gh {pr,merge} N --merge` and interpreter argv lists still reached `allow` (R1). The reviewer graded them as inside D10 because the phrase is assembled at run time and is not in the command text, which D10 states as "encoded or run-time composed text". They also have to be written deliberately. This is a reading of the D10 wording. If the owner reads D10 more narrowly, R1 becomes an `autonomous` finding, and the fix is one trigger change under the key.

---

## Summary

- **Owed criteria:** 15
- **PASS:** 15
- **PARTIAL:** 0
- **FAIL:** 0
- **UNVERIFIED:** 0
- **CI note:** CI run 42356449380 at head `197f3122a` concluded `success` on all 23 jobs, including `CI full run` and `CI Required Gate`.

Items 10 and 11 were PARTIAL at the prior review, both from F1. The shape rule resolves that cause: the guard no longer depends on the scope filter having matched.

Owner condition check:

1. Revertibility: met. The entry replays to `origin/main` at this head, and to the parent of `ee44aaa86`, with 0 differing paths.
2. Baselines: met. The branch removes no baseline task or evidence.
3. Merge control: met within the limit stated in D10, subject to the reading of that limit noted above.
4. Older checkpoints: met. Every rule is key-gated; 56 forms kept their decision without the key; no existing fixture changed; no Epic #1019 folder is in the diff.

---

## Acceptance Criteria Check-off

Newly checked in both `spec.md` and `user-story.md`, because each evaluated PASS:

- `[C] Under review_mode: "concurrent", merge is denied ...`
- `[C] The guard denies a stale head ...`

Only the checkbox changed. No criterion text changed. The other `[A]`, `[B]`, and `[C]` items were already checked and were evaluated PASS.

### AC Status Summary

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md`, `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 40 in each file
- Checked off (delivered): 15
- Remaining (unchecked): 25
- Items remaining: the 25 items tagged `[D]` to `[I]`, which later stages owe.

---

**Audit Completed By:** feature-review agent
