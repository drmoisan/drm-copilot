# Feature Audit: Stage I, Early Dependent Starts, with the Remediation Cycle 1 Re-audit (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `8ed1c611d1f54e65a4fe0c6f4e06938f2cebc9fb`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`. `artifacts/pr_context.summary.txt` resolves `origin/main` @ `72e8b299c8ce99adce7db335e936974e8119493b` for head `8ed1c611d`.
- Merge base: `72e8b299c8ce99adce7db335e936974e8119493b`, equal to `origin/main` after fetch; `main` includes stages A to H and PRs #1134, #1135, #1137, #1140.
- Range audited: `72e8b299c..8ed1c611d`, 93 files, 41 commits, one merge commit (`76eee9f10`).
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: stage I owes the two `[I]` criteria on the barrier layers and on the frozen hashes. The other five `[I]` criteria are whole-item closing checks verified at stage J; this audit checks that stage I does not break them. `[A]` to `[H]` were delivered by earlier PRs; `[J]` is owed later.
- Remediation cycle 1 re-audit: F1 of `remediation-inputs.2026-11-08T18-06.md` (merge with `main`).

## Acceptance Criteria Inventory

Identical item for item in `spec.md` and `user-story.md`:

| ID | Criterion | Owed here |
|---|---|---|
| I1 | Layer 1 and layer 2 honor `early_start` only for the named dependency; a dependent at `pr_open` or later requires the dependency merged and a string `synced_at`; and without the key both layers are unchanged. | Yes |
| I2 | Frozen hashes are re-baselined in the same commit, and the reduction lands as its own commit with its entry. | Yes |
| I3 | The ledger holds an entry for every reduction made, including #1094; every entry carries the prior text or a patch, revert steps, and revert signals; and the reviewer confirms from the branch log that each reduction is a separate commit. | Not broken (stage J) |
| I4 | The planning, execution, and review skills, and all mirrored copies, describe the new rules, and contract tests pin them. | Not broken (stage J) |
| I5 | No baseline task, evidence, or comparison requirement is removed. | Not broken (stage J) |
| I6 | Older checkpoints and plans still validate: existing fixtures pass unchanged, and no Epic #1019 feature folder or admitted plan is edited. | Not broken (stage J) |
| I7 | Merge is still impossible without a passing review and green CI, within the limit stated in D10. | Not broken (stage J) |
| RC1-F1 | Cycle 1 F1: merge `origin/main` keeping both sides, re-pin, record 0010 against the merged base, entries 0001 to 0009 unchanged. | Yes |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| I1 | PASS | Layer 1: `Test-EpicWaveEarlyStartEdge` skips only the edge whose `feature_folder` equals the record's resolved dependency; rows `other-dependency-unmerged` and `key-names-non-dependency` deny; `no-key-*` rows keep prior decisions. Layer 2: the three ports exempt only the resolved folder and report the unmerged and unsynced messages at `pr_open` or later (corpus cases `pr-open-upstream-unmerged`, `pr-open-null-sync`, `pr-open-empty-sync`, `pr-open-numeric-sync`, `absent-status-fails-closed`); without a valid record no exempt folder exists; existing fixtures unchanged and `test_existing_corpus_holds_no_early_start_key` passes. Behavior verified; the missing Layer 1 test row for an empty `interface_settled_at` is a test gap (F2), not a behavior defect: the reviewer's real-process probe returns null for that record. |
| I2 | PASS | `5988fc822` (`reduction: 0010`) changes both `PINNED_FROZEN_SURFACE_HASHES` digests with the `RE-BASELINED by issue #1097` paragraph, and carries the entry, index row, and patch; it contains no other reduction. After the merge, the pins equal the merged surface digests (reviewer SHA-256), and the 0010 record names them. |
| I3 | PASS (not broken) | Entry 0010 carries a stored patch, six revert steps, and four revert signals; `Test-ProcessReductionLedger` valid with 10 rows; chain valid. The 0010 code landed in commit `5988fc822` separate from every other reduction; `80b87df59` and `149b09a02` are 0010-only record updates. |
| I4 | PASS (not broken) | Stage I does not touch the planning, execution, or review skills. Its epic skill text is pinned on 12 surfaces by `early-start-skill-contract.Tests.ps1`. |
| I5 | PASS (not broken) | Deletions outside the TS move, Python docstring, pin lines, and plan check-offs: none. No baseline task, artifact, or comparison is removed; stage I captured and compared its own Phase 0 baselines. |
| I6 | PASS (not broken) | `layer2-parity-edge-cases.json` and `start-guard-matrix.json` unchanged; all existing wave-barrier suites pass; no path under any Epic #1019 or other item's folder in the diff; every new rule is key-gated. |
| I7 | PASS (not broken) | No merge-gate, review-gate, or child-CI file is in the diff; the early-start procedure permits no merge and completes the sync before S7 and S8, so the #1130 child-CI gate reads post-sync heads. |
| RC1-F1 | PASS | `76eee9f10` has parents (branch head, `origin/main`); no conflict marker outside intentional fixtures; mirrors byte-identical; pins re-pinned; the 0010 reversal equals `origin/main` on all 38 paths, so main's text survives a revert; entries 0001 to 0009 unchanged; ledger and chain valid; gates green. |

## Summary

- Stage I delivers I1 and I2. The five closing criteria are not broken. Cycle 1 F1 is resolved.
- Two blocking findings remain: F1 (Claude early-start step 2 names no fallback when the validator CLI is absent in a destination repository) and F2 (no Layer 1 test row for an empty or non-string `interface_settled_at`). Both are autonomous and contained, and neither changes a criterion's text.

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 46 per file
- Remaining (unchecked): 11 per file
- Items remaining: the five `[I]` closing criteria (I3 to I7), verified at stage J, and the six `[J]` criteria.

## Acceptance Criteria Check-off

- I1 and I2 were checked off by the executor in commit `536ac1b4e`. This review evaluates each as PASS, so they stay checked in both `spec.md` and `user-story.md`.
- I3 to I7 are closing checks owed at stage J and stay unchecked.
- No criterion was newly checked or unchecked by this review, no criterion was added, and no criterion text was changed.
