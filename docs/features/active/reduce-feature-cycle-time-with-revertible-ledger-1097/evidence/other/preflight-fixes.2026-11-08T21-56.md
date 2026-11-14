Timestamp: 2026-11-08T21-56
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-08T09-47.md
Scope: single-pass preflight of the stage J plan (issue 1097) after the branch was fast-forwarded to main with stage I merged (PR #1144).

## Fixes

1. P2-T3 | literal-formatting defect (wording contradicted the Design Summary) | The task said the Codex section uses "the same entry-point path and absent-file rule as `Invoke-CiGateParser.ps1` uses there". The Codex `## CI Green Gate` parser-absent rule is a stop rule (persist blocked state), while the Design Summary's absent-file rule for this entry point is no post with the merge unchanged. The task now names the same `.claude/lib/` path form as the parser and the absent-file rule of the Design Summary, and states that it is not the parser-absent stop rule. The asserted behavior (the Design Summary rule, pinned by the P2-T4 rows) is unchanged.
2. P3-T4 | validator-blind derivation defect, assertion kept | The ledger row derived one non-merge commit per entry that carries the entry's `reduction: NNNN` token and adds the entry file. Entry `0002` was added by its reduction commit as `0001-concurrent-review.md` with the token `reduction: 0001` and was renumbered to `0002` in a merge of `origin/main`, so the derivation as written finds no commit for `0002` and the row could not read PASS. The derivation now runs `git log --no-merges --no-renames --diff-filter=A --format=%s` over the entry file and, for `0002`, over its earlier file name, citing the renumbering merge by its subject. The asserted property (each reduction is its own commit that adds its entry) is unchanged.

## Checks Without a Fix

- Insertion points: `## PR Creation Gate` is still followed by `## Step 6 Delegation — Prohibited Prompt Language` in all four orchestrate copies; the two bundle copies are byte-identical to their sources.
- Ledger regions: the `0009` hunks on the orchestrate copies end at the `## PR Creation Gate` heading and the blank line after it, so the new section after the gate's last paragraph is outside them; the `0002` and `0003` revert blocks hold no text of the gate section. The `0010` hunk on the Claude `core.json` covers the `epic-wave-barrier-early-start.ps1` hook entry near the top of the paths array, far from the `ci-gate` entries where P1-T4 inserts; no other stored patch touches `core.json`; no stored patch touches `tests/scripts/claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1`. No entry needs regeneration; P0-T4 records this at execution.
- Back-fill: only `0010` reads `Merge commit: pending (PR #1144)`; P2-T5 back-fills it.
- Hooks: the statuses POST and the entry-point text hold no `pr merge`, `pr` before a dynamic word, `pulls/<n>/merge` path, `gh api graphql`, or merge mutation name, so the review guard trigger (`Test-EpicMergeGateReviewMergeText`) and the #1130 child-CI branch, which act only on merges, are not reached.
- Validators: the branch-current Python CLI `plan` subcommand and the installed MCP validator pass the plan; the CLI also passes `plan.2026-11-06T21-23.md` and `plan.2026-11-07T22-28.md`.
