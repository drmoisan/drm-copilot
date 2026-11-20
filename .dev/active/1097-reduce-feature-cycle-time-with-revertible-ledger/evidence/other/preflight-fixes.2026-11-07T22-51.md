# Preflight Fixes (Stage F, confirming pass)

Timestamp: 2026-11-07T22-51
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T06-17.md

## Fixes

1. `## Design` `**Result check.**` | scope derivation that missed the stated intent | The child-folder clause covered only folders holding a kickoff-listed plan path. Two in-flight #1019 folders, `2026-11-06-docs-tokenizer-scaling-1019` and `2026-11-06-execution-env-test-worktree-filter-1019`, carry `- Issue: #1019` in `issue.md` and are absent from the kickoff. They are held by 8 and 10 remote refs respectively, including `refs/remotes/origin/epic/documentation-estate-tooling-integration`, and hold three plan files each. The clause now defines a #1019 folder as one that holds a kickoff-listed plan path or whose `issue.md` on any `refs/remotes/origin/*` ref carries a line beginning `- Issue: #1019` or `- Parent epic: #1019`. Enumerated across all remote refs, that predicate selects the 11 kickoff folders and the two adopted folders, and no other folder. The assertion (every in-scope file keeps its result) is unchanged.
2. [P0-T5] | wording aligned with fix 1 | "each kickoff-listed child folder" became "each #1019 folder of `**Result check.**` with the clause that selected it", and the acceptance "every child folder was enumerated" became "every #1019 folder was enumerated".
3. [P2-T5] | precision of a recorded value | The replay artifact records "the UTC reading to the second", so the [P2-T6] equality between the commit dates and the recorded reading can be evaluated at the precision of the reading.

## Confirmed without change

- Zones: `plan.<stamp>.md` stamps are written in America/New_York by `scripts/dev_tools/new_active_feature_folder_models.py` and `extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts`, and every plan file in this folder was added within the New York hour of its stamp. `remediation-plan.<stamp>.md` stamps in this folder and the folder form in the #984 folder match UTC add times. The #1048 cycle plan stamp lies between its cycle's UTC review stamps.
- Parity: `test_utc_stamp_is_not_read_against_new_york_cutoff` is required in both validators; its `2026-11-07T14-30` UTC stamps are earlier in real time than the `2026-11-07T10-00` New York entry (`2026-11-07T15-00` UTC) and sort after it as strings.
- Commit dates: [P2-T5] sets the author and committer dates to the single reading and [P2-T6] checks both.
