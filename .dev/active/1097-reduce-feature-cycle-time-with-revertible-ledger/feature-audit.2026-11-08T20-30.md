# Feature Audit: Stage I, Early Dependent Starts, Re-audit after Remediation Cycles 2 and 3 (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `ecdbcab193c02a2682f6c20eee2a9abc0a9de6af`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`. `artifacts/pr_context.summary.txt` resolves `origin/main` @ `5c81af727d0c4c85b893d6542356c47123454117` for head `ecdbcab19`.
- Merge base: `5c81af727d0c4c85b893d6542356c47123454117`, equal to `origin/main` after fetch; `main` includes stages A to H and PRs #1134, #1135, #1137, #1140, and #1142.
- Range audited: `5c81af727..ecdbcab19`, 120 files, 59 commits, two merge commits (`76eee9f10`, `4dae0e385`).
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: stage I owes the two `[I]` criteria on the barrier layers and on the frozen hashes. The other five `[I]` criteria are whole-item closing checks verified at stage J; this audit checks that stage I does not break them. `[A]` to `[H]` were delivered by earlier PRs; `[J]` is owed later.
- Remediation re-audit: cycle 2 findings F1 and F2 (`remediation-inputs.2026-11-08T19-22.md`) and cycle 3 finding F1 (`remediation-inputs.2026-11-08T19-48.md`, merge with `main` after PR #1142).

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
| RC2-F1 | Cycle 2 F1: absent-CLI fallback in the Claude early-start step 2, allowlist reason, `ESS` pin, re-pin, patch regeneration. | Yes |
| RC2-F2 | Cycle 2 F2: Layer 1 deny rows for an empty and a non-string `interface_settled_at`; both siblings at 100% lines. | Yes |
| RC3-F1 | Cycle 3 F1: merge `origin/main` after #1142 keeping both sides, mirrors, re-pin, 0010 regenerated against the merged base, #1142 consistent with the early-start rule. | Yes |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| I1 | PASS | Unchanged in production code since the prior review. Layer 1: `Test-EpicWaveEarlyStartEdge` skips only the edge whose `feature_folder` equals the record's resolved dependency; `other-dependency-unmerged` and `key-names-non-dependency` deny; `no-key-*` rows keep prior decisions; the new settled-time rows deny. Layer 2: the three ports exempt only the resolved folder and report the unmerged and unsynced messages at `pr_open` or later. Pester 0 failed (EarlyStart suites 59 tests), pytest 0 failed (`test_epic_wave_barrier_early_start.py` 30), Jest 0 failed on an identical TypeScript tree. |
| I2 | PASS | `5988fc822` (`reduction: 0010`) carries the rule, both re-baselined `PINNED_FROZEN_SURFACE_HASHES` digests, the entry, index row, and patch, and no other reduction. Cycle 2 `448d9918c` re-pinned in the same commit as its skill edit. At head the pins equal the merged surfaces' SHA-256. History note (CR6, non-blocking): in cycle 3, `8abf90f98` moved the skill digest and the re-pin followed in `5c50de7d8`, and the merge `4dae0e385` left `main`'s pins in place; the pinned digests were stale at five intermediate commits. The criterion is graded on the reduction's landing commit, as the prior review graded the identical cycle 1 pattern; the per-commit gap is recorded for owner ratification. |
| I3 | PASS (not broken) | Entry 0010 carries a stored patch, six revert steps, and four revert signals; `Test-ProcessReductionLedger` valid with 10 rows; chain valid. Every `reduction: 0010` commit (seven) touches only 0010 paths and feature-folder records and carries no other reduction. |
| I4 | PASS (not broken) | Stage I does not touch the planning, execution, or review skills. Its epic skill text is pinned by `early-start-skill-contract.Tests.ps1` (56 testcases). |
| I5 | PASS (not broken) | Deletions relative to `origin/main` lie only in the TS move, the Python helper, pin lines, the citation-test set, the chain module, and plan check-offs and revisions; no baseline task, artifact, or comparison is removed. Cycle 3 read the stage I Phase 0 baselines without re-capturing or reducing them. |
| I6 | PASS (not broken) | `layer2-parity-edge-cases.json` and `start-guard-matrix.json` unchanged; all existing wave-barrier suites pass; no Epic #1019 or other item's folder in the diff; every new rule is key-gated, and the fallback sentence keeps the barrier. |
| I7 | PASS (not broken) | No merge-gate, review-gate, or child-CI file in the diff; the early-start procedure permits no merge and completes the sync before S7 and S8. |
| RC2-F1 | PASS | Clause present in both copies (byte-identical); `ESS-CLAUDE-NAMES-PYTHON-CLI-ROUTE` pins it; allowlist reason names the absent case; Codex skill unchanged. |
| RC2-F2 | PASS | Rows at helper lines 124 and 125; siblings 30 of 30 lines in the coverage XML; production unchanged. |
| RC3-F1 | PASS | Two-parent merge; 0 deleted `main` lines in shared files; no conflict marker; 14 mirror pairs and twins identical; pins equal merged digests; 0010 reversal equals `origin/main` on 38 of 38 paths; entries 0001 to 0009 unchanged; chain and sub-chains valid; Codex generator `--check` exit 0; nesting-depth deny reason reads no prompt text; fallback sentence correct and D7 unchanged. |

## Summary

- Stage I delivers I1 and I2 at this head. The five closing criteria are not broken. Cycle 2 F1 and F2 and cycle 3 F1 are resolved.
- No blocking finding. CR6 (new) and CR3, CR4, CR5 (carried) are non-blocking.

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 46 per file
- Remaining (unchecked): 11 per file
- Items remaining: the five `[I]` closing criteria (I3 to I7), verified at stage J, and the six `[J]` criteria (review/verdict status posting, new-push behavior, records-only rule, narrow posting rules, skill limit text, no CI or ruleset addition).

## Acceptance Criteria Check-off

- I1 and I2 were checked off by the executor in commit `536ac1b4e`. This review evaluates each as PASS at this head, so they stay checked in both `spec.md` and `user-story.md`.
- I3 to I7 are closing checks owed at stage J and stay unchecked; the `[J]` criteria stay unchecked.
- No criterion was newly checked or unchecked by this review, no criterion was added, and no criterion text was changed.
