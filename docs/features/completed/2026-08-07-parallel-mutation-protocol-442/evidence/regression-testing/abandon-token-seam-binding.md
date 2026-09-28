# Regression Evidence — Abandon Token Seam Binding Demonstration (P5-T4)

Timestamp: 2026-08-08T23-05

Task: [P5-T4] Producer/consumer seam test binding the abandon token pair across the language and
docs boundary.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
Reconciliation base: `c939b5b8`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -q --no-cov`

EXIT_CODE: 0 (final clean run; see the per-run table below for every recorded exit code)

## Why This Demonstration Is Required

The abandon token pair is produced in two artifacts and consumed in a third:

| Role | Artifact |
| --- | --- |
| Producer (authoritative) | `scripts/dev_tools/parallel_mutation_abandon_cli.py` — module constants `ABANDON_DISPOSITION_TOKEN` and `CONFIRM_ABANDON_TOKEN`, wired into the `build_parser()` surface |
| Producer (documentation) | `.claude/skills/parallel-remove/SKILL.md` — the single documented invocation line |
| Consumer | `.claude/hooks/enforce-parallel-abandon-gate.ps1` — the named assignments `$script:AbandonDispositionToken` and `$script:AbandonConfirmToken` |

Per-side coverage cannot detect divergence between them. Each side can reach 100% coverage while
tested against its own copy of the token, so a rename applied to one artifact alone would ship a
gate that never matches the command it is meant to guard. The seam test therefore PARSES each
counterpart artifact at run time — the CLI's constants plus its live argparse actions, the hook's two
named assignments, and the SKILL's one documented invocation line — and hardcodes no token value as
an expected value. Each of the three extractions is asserted non-empty before comparison, so a parse
that matched nothing fails loudly rather than trivially satisfying a subset assertion.

## Demonstration Method

A single-sided rename was applied in the WORKING TREE ONLY, once per artifact, and reverted
immediately after each run by the same script that applied it (the revert runs in a `finally` block
and re-reads the file to confirm byte equality with the original). The rename was never committed and
never staged. Renamed value in each case: the confirmation token gained the suffix `-renamed` on one
side only.

## Recorded Runs (numeric, no placeholders)

| Run | Working-tree state | EXIT_CODE | Pytest summary |
| --- | --- | --- | --- |
| 1 | clean (all three artifacts agree) | 0 | `10 passed in 0.04s` |
| 2 | rename in `.claude/hooks/enforce-parallel-abandon-gate.ps1` ONLY | 1 | `2 failed, 8 passed in 0.07s` |
| 3 | rename in `scripts/dev_tools/parallel_mutation_abandon_cli.py` ONLY | 1 | `3 failed, 7 passed in 0.08s` |
| 4 | rename in `.claude/skills/parallel-remove/SKILL.md` ONLY | 1 | `2 failed, 8 passed in 0.08s` |
| 5 | clean again (all renames reverted) | 0 | `10 passed in 0.04s` |

Each of runs 2, 3, and 4 exercised exactly one artifact's rename with the other two untouched, so the
failure in each case is attributable to divergence and to nothing else.

## Reverted-Clean State

After run 5:

- `git status --porcelain` reports the three artifacts only as untracked (`??`) new files of this
  feature, with no rename content in them.
- A `grep` for `renamed` across all three artifacts returns no match (`NO RESIDUAL RENAME`).
- The final clean run exits 0 with all 10 tests passing.

P7-T10 must therefore show no residual rename anywhere in the branch diff.

Output Summary: The binding property is demonstrated. On the clean tree the seam suite passes
(**EXIT_CODE 0, 10 passed**). A single-sided rename of the confirmation token fails the suite in every
one of the three artifacts independently — hook only (**EXIT_CODE 1, 2 failed / 8 passed**), CLI only
(**EXIT_CODE 1, 3 failed / 7 passed**), SKILL only (**EXIT_CODE 1, 2 failed / 8 passed**) — proving
that renaming a token in one artifact without the identical rename in the other two is caught rather
than shipped. All three renames were reverted in the working tree, never committed; the post-revert
run exits 0 with 10 passed and no residual `renamed` string remains in any artifact.
