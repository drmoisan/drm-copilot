# Preflight Fixes - Issue 1019

Timestamp: 2026-11-06T17-46
Plan: docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/plan.2026-11-06T12-15.md

All fixes edit task text or plan preamble only. No task was added, removed, or reordered, and no asserted behavior changed. After the fixes, the branch-current Python validator and the installed MCP validator both pass the plan.

## Fixes

1. `## Conventions` (`CANDIDATE`), stale fact. The tip of `origin/feature/docs-enforcement-and-ci-1034-r2` has reverted the fix: `git diff` of `MODULE` and `SUITE` between `HEAD` and that tip is empty. The text now states this and that hunks come from the `CANDIDATE` commit.
2. `## Pre-Mortem`, `Review checklists`, unrecorded interpretation. Added the coding-cookie `for` loop to the wording decision that [P2-T9] records, because AC-2 says "no loop" and a one-line source passes its whole text once through `$lines[$cookieLine]`.
3. [P0-T2], ordering of a live input. `SCRATCH/unfixed` already exists and the bounded before-fix run reads it. The task now reuses it when hashes match instead of creating it.
4. [P0-T3], evidence accuracy. `SCRATCH/before.txt` reports `passed=16` and `notrun=13` under the label `suite without the token-limit test`. `SUITE` has 29 tests, and the run's filter also skipped the 12 data-driven `reports <Code>` cases. The artifact must state this.
5. [P0-T4], literal scope. `git status --porcelain` is now scoped to `MODULE` and `SUITE`, because evidence files written by the same task change the unscoped output.
6. [P0-T5], validator-blind command shape. `Filter.FullName` matches the unexpanded test path. A discovery-only probe of the template-spelled list selected 28 of 29 tests and excluded only the token-limit test. The acceptance now records not-run exactly 1.
7. [P0-T6], stale reference. The `execution-environment` skill names no alternative runner. The text now states the observed environment and the `poetry run` and `poetry install` rule.
8. [P1-T1], literal comparison form. The candidate keeps the removed `Match` text at a deeper indent, so the absence check is stated as a whole-line comparison.
9. [P1-T4], helper invocation and unprinted value. Added the helper's mandatory `-Root`. The helper prints counts and failed names only, so the passed-set statement is now derived from the counts and the titles, with skipped 0 added.
10. [P2-T7], stale shape name and helper parameters. `one-long-string` is now the helper's `long-string-body`, and the mandatory `-ModulePath` and `-Label` are named. A clause states that the 3.0 bound allows for host noise and that reviewers read the recorded ratios against the AC-3 wording. The bound itself is unchanged.

## Observations (no plan change)

- AC-3 reads "no more than about doubles", and [P2-T7] gates at a ratio of 3.0. The gate is more permissive than the criterion's wording. The planner's bound is retained because it is an assertion; a recorded ratio materially above 2 needs a reviewer decision at AC-3 check-off.
- The root-cause profile says a one-line source costs two whole-source cookie calls. `[math]::Min(2, $lines.Count)` gives one call for one line. The evidence file was not edited.
- `issue.md` `## Dependencies / Risks` says 1034 already carries the candidate hunks. That is no longer true at the branch tip. A trial `git merge-tree --write-tree` of `HEAD` and that tip reported no conflict. `issue.md` was not edited.
- [P2-T6] volume: 993 tracked `.py` files, all at most 26,368 characters, so none is excluded by the 64,000 bound. Scaling the measured unfixed names-shape cost by squared length gives an estimate of about 1.7 hours for one serial process on the unfixed module. This is an estimate, not a run. The task's resume and partition design applies.
- Direct observations at preflight: `SCRATCH/before-full.txt` was absent and `SCRATCH/before-full.tmp` was present, so the measurement had not finished, and [P0-T3] carries the stop rule for absence. Candidate and base `MODULE` and `SUITE` blobs are formatter-stable with zero analyzer findings. The two contract tests pass (16 passed). Pester 6.2.0 is installed.
