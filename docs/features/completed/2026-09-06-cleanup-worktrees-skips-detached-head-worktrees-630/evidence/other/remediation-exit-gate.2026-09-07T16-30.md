# Remediation Exit-Gate Summary

Timestamp: 2026-09-07T16-30
Task: [P6-T16]
Issue: #630
Branch: `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
Cycle entry commit: `65a56cb94352c2a19c381acf4008837fa84aee69`
Cycle commit: `12cc5766775c4faf172023132b97a199415e9709`
Merge base: `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`

## R1 through R6 — implementation tasks and verifying evidence

Paths below are relative to
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/`.

### R1 — cover the untested delete-eligible verdicts (Major)

- Implementation tasks: [P1-T1], [P1-T2], [P1-T3], [P1-T4] (fixture scenarios); [P2-T1], [P2-T2],
  [P2-T3], [P2-T4], [P2-T5], [P2-T6] (bats cases).
- Evidence:
  - `evidence/regression-testing/r1-fixtures-only-suite.2026-09-07T15-00.md`
  - `evidence/regression-testing/r1-detached-suite.2026-09-07T15-00.md`
  - `evidence/qa-gates/final-bats-suite.2026-09-07T16-30.md`
  - `evidence/qa-gates/final-bash-test-coverage.2026-09-07T16-30.md`
  - `evidence/qa-gates/coverage-delta.2026-09-07T16-30.md`
  - `evidence/qa-gates/new-paths-tracked.2026-09-07T16-30.md`

### R2 — cover the unexercised fail-closed guards on the destructive path (Major)

- Implementation tasks: [P3-T1], [P3-T2], [P3-T3], [P3-T4] (fixture scenarios); [P4-T1], [P4-T2],
  [P4-T3], [P4-T4], [P4-T5], [P4-T6] (bats cases).
- Evidence:
  - `evidence/regression-testing/r2-fixtures-only-suite.2026-09-07T15-00.md`
  - `evidence/regression-testing/r2-detached-suite.2026-09-07T15-00.md`
  - `evidence/qa-gates/final-bats-suite.2026-09-07T16-30.md`
  - `evidence/qa-gates/final-bash-test-coverage.2026-09-07T16-30.md`
  - `evidence/qa-gates/coverage-delta.2026-09-07T16-30.md`
  - `evidence/qa-gates/new-paths-tracked.2026-09-07T16-30.md`

### R3 — strengthen two existing assertions (Minor)

- Implementation tasks: [P5-T1] (locked-case exit-code assertion), [P5-T2] (CLI record-literal
  assertion).
- Evidence:
  - `evidence/qa-gates/final-bats-suite.2026-09-07T16-30.md`
  - `evidence/qa-gates/pinned-assertions-unmodified.2026-09-07T16-30.md`
  - `evidence/qa-gates/no-temp-files.2026-09-07T16-30.md`

### R4 — document the apply-mode exit-code change (Minor)

- Implementation tasks: [P5-T3] (`SKILL.md` sentence), [P5-T4] (push-down mirror refresh), [P5-T5]
  (`usage()` heredoc paragraph), [P5-T6] (CLI bats case).
- Evidence:
  - `evidence/qa-gates/push-down-mirror.2026-09-07T16-30.md`
  - `evidence/qa-gates/final-bats-suite.2026-09-07T16-30.md`
  - `evidence/qa-gates/file-line-counts.2026-09-07T16-30.md`

### R5 — record the `COMMIT|` blind spot as a limitation (Minor)

- Implementation task: [P5-T7] (L5 entry in `spec.md`).
- Tests: none. `spec.md` carries no executable behavior; the condition is verified by the `git grep`
  counts in [P5-T7] and by [P6-T15].
- Evidence:
  - `evidence/other/ac-status.2026-09-07T16-30.md`
  - `evidence/other/remediation-exit-gate.2026-09-07T16-30.md` (this file)

### R6 — pre-PR integration check against the epic base (Minor)

- Implementation task: [P6-T14].
- Tests: none. This is a pre-PR integration check rather than a behavior.
- Evidence:
  - `evidence/qa-gates/integration-precheck.2026-09-07T16-30.md`

## Detached state tokens — producing bats case for each of the seven

Every case below lives in `tests/shell/test_cleanup_worktrees_detached.bats`. The mapping was
derived by reading that file rather than from the plan text.

| Token | Producing case (at least one) | Line |
|---|---|---|
| `MERGED_CLEAN` | `report emits one detached record with MERGED_CLEAN` | :40 |
| `MERGED_CONTENT_NEUTRAL` | `report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD` | :171 |
| `MERGED_EQUIVALENT` | `report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD` | :191 |
| `NOT_MERGED` | `report emits NOT_MERGED for an unmerged detached HEAD` | :51 |
| `HAS_UNIQUE_RESIDUALS` | `report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD` | :209 |
| `PROTECTED_CURRENT` | `the caller's own detached worktree is PROTECTED_CURRENT` | :129 |
| `ANCESTRY_ERROR` | `a hard git failure maps to ANCESTRY_ERROR with no removal` | :139 |

All seven tokens are produced by at least one named case. Four of the seven — `MERGED_CLEAN`,
`NOT_MERGED`, `PROTECTED_CURRENT`, and `ANCESTRY_ERROR` — were already produced by cases from the
original plan. The three this remediation cycle adds are `MERGED_CONTENT_NEUTRAL`,
`MERGED_EQUIVALENT`, and `HAS_UNIQUE_RESIDUALS`.

Additional cases producing the same tokens, recorded for completeness:

- `MERGED_CLEAN`: `apply removes a merged detached worktree without force` (:85),
  `classify_detached_head returns MERGED_CLEAN for an ancestor HEAD` (:146).
- `MERGED_CONTENT_NEUTRAL`: `apply removes a content-neutral detached worktree without force`
  (:180), which drives the destructive path from that verdict.
- `MERGED_EQUIVALENT`: `apply removes a cherry-equivalent detached worktree without force` (:199);
  `classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main` (:223),
  which covers the second producing statement of that token, on the all-residuals-content-on-main
  rung.
- `NOT_MERGED`: `apply never touches an unmerged detached worktree` (:93).
- `ANCESTRY_ERROR`: `classify_detached_head returns 2 on a hard failure` (:156) and the five
  fail-closed cases listed in the next section.

## R2 fail-closed guards — asserting bats case for each of the five

The five guards are those named in the R2 table of
`remediation-inputs.2026-09-07T12-45.md:123-129`. Every case below lives in
`tests/shell/test_cleanup_worktrees_detached.bats`.

| Guard | Function | Asserting case | Line |
|---|---|---|---|
| `compute_protected` non-zero | `classify_detached_head` | `a protection-set hard failure fails closed as ANCESTRY_ERROR` | :235 |
| `CONTENT_NEUTRAL_ERROR` | `classify_detached_head` | `a content-neutral probe hard failure fails closed as ANCESTRY_ERROR` | :251 |
| `CHERRY_ERROR` / `DIFF_TREE_ERROR` | `classify_detached_head` | `a cherry hard failure fails closed as ANCESTRY_ERROR` (:266) and `a diff-tree hard failure fails closed as ANCESTRY_ERROR` (:282) | :266, :282 |
| `RESIDUAL_ERROR` | `classify_detached_head` | `a residual ls-tree hard failure fails closed as ANCESTRY_ERROR` | :295 |
| `((crc != 0))` | `reverify_detached_delete_eligible` | `reverify_detached_delete_eligible blocks on a classification hard failure` | :310 |

All five guards are asserted by at least one named case. The third row carries two cases because
that guard covers two distinct tokens, `CHERRY_ERROR` and `DIFF_TREE_ERROR`, which the fixture stub
cannot fail for the same sha in one scenario: the stub answers `cherry` from one key per sha, so
`det00015` is a second key set hosted inside the same scenario directory and driven by direct
invocation.

The four `classify_detached_head` guards each assert the same three-part fail-closed contract: the
classification returns 2, echoes `ANCESTRY_ERROR`, and echoes no `MERGED_` token; report mode
carries the error state into the `WORKTREE|/repo-wt/det|DETACHED|ANCESTRY_ERROR|detached` record;
and apply mode invokes no `worktree remove` and returns non-zero. The exception is the diff-tree
case, which is direct-invocation only for the stub-keying reason above and therefore asserts the
classification part alone. The `reverify` guard asserts `$status` equal to 1, output containing
`BLOCKED-REVERIFY`, and no `worktree remove`.

## Coverage against the gate

- Per-file line rate for `scripts/bash/cleanup_worktrees_detached_lib.sh`, post-change: **1.000**
- Gate for this cycle: **0.85**
- Result: **at or above the gate**. The measured rate is also at or above the plan's stated target of
  0.95.
- Baseline for comparison: 0.806 ([P0-T7]); signed delta **+0.194**.
- Aggregate bash line coverage: 92.9 baseline to 94.2 post-change, signed delta **+1.3**, against the
  85.0 uniform floor in `.claude/rules/quality-tiers.md`.

Both figures were measured by `.github/workflows/_shell-coverage.yml` run `34142466852` against head
sha `12cc5766775c4faf172023132b97a199415e9709`. No branch-coverage figure is reported, because kcov
does not measure branch coverage for bash.

## Toolchain state

| Stage | Command | Result |
|---|---|---|
| 1 — format | `sh scripts/bash/shell-qc.sh format` | exit 0; `Before:`/`After:` porcelain listings byte-identical |
| 2 — lint | `sh scripts/bash/shell-qc.sh check` | exit 0; stdout and stderr empty |
| 3 — test | `npx --yes bats --tap tests/shell` | exit 0; TAP plan 321; 0 lines beginning `not ok` |

The loop completed in a single iteration. There is no type-check stage for bash.

## Acceptance-criteria state

`spec.md` carries 24 acceptance criteria, all 24 checked, 0 remaining. This cycle added none,
reworded none, removed none, and re-marked none; see
`evidence/other/ac-status.2026-09-07T16-30.md`.

Output Summary: R1 through R6 each map to at least one implementation task and at least one evidence
artifact, all named above. All seven detached state tokens are produced by at least one named bats
case, and all five R2 fail-closed guards are asserted by at least one named bats case; both mappings
were derived by reading `tests/shell/test_cleanup_worktrees_detached.bats`. The post-change per-file
line rate for `scripts/bash/cleanup_worktrees_detached_lib.sh` is 1.000 against the 0.85 gate. The
bash toolchain loop passed in a single iteration.
