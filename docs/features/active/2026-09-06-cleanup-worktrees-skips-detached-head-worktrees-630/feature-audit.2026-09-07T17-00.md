# Feature Audit: detached-worktree classification and consolidation-branch ordering (Issue #630)

**Audit Date:** 2026-09-07
**Auditor:** feature-review agent
**Review Type:** Re-audit (R4) of remediation cycle 1; full feature-vs-base scope

---

## Scope and Baseline

**Base branch:** `epic/cleanup-merged-worktrees-hardening-integration`
This is an epic child feature. The base is the epic integration branch, not `main`.

**Merge base:** `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`
**Head:** `2742c417dcd686e76310d9f15420390d421868db`
**Feature branch:** `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
**Feature folder:** `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/`

**Work mode:** `full-bug`, read from the persisted marker `- Work Mode: full-bug` at `issue.md:12`.
Under `full-bug`, `spec.md` is the sole acceptance-criteria source per
`.claude/skills/acceptance-criteria-tracking/SKILL.md`. `user-story.md` in this folder carries no
acceptance criteria, and the `## Acceptance Criteria` section in `issue.md` is not an AC source in
this mode.

**Scope statement.** The audit covers the full branch diff `a36b6dca..2742c417` — 191 files changed,
6977 insertions, 106 deletions — not the remediation delta alone. The caller explicitly directed a
full re-audit with no narrowing, and no narrowing was applied.

**Baseline evidence.** PR-context artifacts at `artifacts/pr_context.summary.txt` and
`artifacts/pr_context.appendix.txt` were stale (generated at `65a56cb9`) and were regenerated at
head `2742c417` against the supplied base before the audit proceeded.

---

## Acceptance Criteria Inventory

**Source file:** `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`, section `## Acceptance Criteria`.

**Total AC items: 24** (AC1 through AC24). All 24 were already marked `[x]` at cycle entry; the
remediation cycle asserts it re-marked none, and `git diff 65a56cb9..HEAD -- spec.md` confirms the
only change to that file is the addition of limitation L5, with no edit inside the
`## Acceptance Criteria` section.

| ID | Summary |
|---|---|
| AC1 | Report mode emits exactly one five-field `WORKTREE` record per detached registration |
| AC2 | The detached state comes from the existing ladder applied to the HEAD SHA; unmerged yields `NOT_MERGED` |
| AC3 | The detached-candidate predicate is the porcelain `detached` flag, not the branch field |
| AC4 | Branch-backed records keep the four-field shape |
| AC5 | `parse_worktree_list` emits the same records as before |
| AC6 | Each pre-existing `WORKTREE` assertion in research 4.4 still passes, unmodified |
| AC7 | Apply mode removes a delete-eligible detached worktree with a non-forced `git worktree remove` |
| AC8 | Apply mode attempts no removal outside the three-token allowlist |
| AC9 | The caller's own detached worktree is protected by normalized path and short-circuits before classification |
| AC10 | The main worktree is never a detached candidate |
| AC11 | A dirty delete-eligible detached worktree is blocked without force and reports git status content |
| AC12 | A locked detached worktree yields `BLOCKED-LOCKED` and invokes no git removal |
| AC13 | A prunable detached worktree is report-only |
| AC14 | A hard git failure maps to `ANCESTRY_ERROR`, performs no removal, non-zero apply return |
| AC15 | Same-process re-verification blocks a removal on a flipped verdict |
| AC16 | `verify_consolidation_merged` refuses a zero-commit consolidation branch by tip equality |
| AC17 | The rejected `rev-list --count` guard form does not ship; post-merge cleanup is not blocked |
| AC18 | An empty or unresolvable `rev-parse` on either side is a hard failure, not an equality match |
| AC19 | All new coverage runs through the stub seams against checked-in fixtures; no temp files |
| AC20 | `SKILL.md` documents the record, the new token, the apply behavior, and the consolidation guard |
| AC21 | The push-down mirror is content-identical |
| AC22 | `--help` describes the detached record |
| AC23 | No file in `scripts/bash/` exceeds 500 lines; the detached group ships in a new file |
| AC24 | The bash toolchain loop completes in a single pass with line coverage at or above 85% |

---

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC1 | PASS | `report emits one detached record with MERGED_CLEAN` passes; it asserts the literal `WORKTREE\|/repo-wt/det\|DETACHED\|MERGED_CLEAN\|detached`, that exactly one output line begins `WORKTREE\|/repo-wt/det`, and that no `WORKTREE\|/repo/main\|DETACHED\|` line appears. Re-run by this reviewer at head. Independently confirmed by driving `run_report` against `detached_merged` outside bats. |
| AC2 | PASS | `report emits NOT_MERGED for an unmerged detached HEAD` passes. `classify_detached_head` calls only the four existing ladder rungs against the bare SHA (`scripts/bash/cleanup_worktrees_detached_lib.sh:102-149`); `classify_branch` is never called. |
| AC3 | PASS | `is_detached_candidate flag matrix` passes all eight rows: return 0 for `detached`, `detached,locked`, `detached,prunable`; non-zero for `main`, `main,bare`, `main,detached`, `prunable`, and the empty string. The function makes no git call. |
| AC4 | PASS | `branch-backed worktree records keep the four-field shape` passes, asserting `WORKTREE\|/repo-wt/feat\|feature-wt\|` against `merged_with_worktree`. |
| AC5 | PASS | `tests/shell/test_cleanup_worktrees_enumeration.bats` is absent from the branch diff entirely. Its four pinned literals at lines 33, 34, 41, 48 are byte-unmodified and all 12 cases pass at head. |
| AC6 | PASS | `git diff a36b6dca..HEAD` on `classification.bats`, `cli.bats`, and `hard_failures.bats` shows only an added `DLIB` variable, an added `source '${DLIB}'` in each helper chain, and appended cases. No assertion line is changed. All the named assertions were read at head and are textually intact; all 36 cases across those three suites pass. |
| AC7 | PASS | `apply removes a merged detached worktree without force` passes. Independently re-derived: this reviewer drove `run_apply` against `detached_merged` and `detached_content_neutral` outside bats and observed `stub-git: worktree remove /repo-wt/det` with no force flag, followed by `ACTION\|worktree-remove\|/repo-wt/det\|OK` and exit 0. |
| AC8 | PASS | `apply never touches an unmerged detached worktree` passes with the positive record assertion that makes it non-vacuous. Strengthened this cycle by `report emits HAS_UNIQUE_RESIDUALS ...`, whose apply half proves a second non-eligible terminal blocks the destructive path. |
| AC9 | PASS | `the caller's own detached worktree is PROTECTED_CURRENT` passes, asserting the `PROTECTED_CURRENT` record and that apply mode emits no `ACTION\|worktree-remove`. The AC's stated verification is satisfied as written. Caveat recorded: the third assertion, on the absence of a `merge-base` argv line, is not falsifiable because `classify_ancestry` routes that command's stderr to `/dev/null`. The short-circuit behavior itself is correct — `classify_detached_head` returns at lines 97-98 before the rung-1 call at line 102 — and is verified here by code inspection. See the Minor finding in `code-review.2026-09-07T17-00.md`. |
| AC10 | PASS | The `main`, `main,bare`, and `main,detached` rows of the flag matrix all return non-zero, and no scenario in the suite produces a `WORKTREE\|/repo/main\|DETACHED\|` line in either mode. Confirmed for the eight new scenarios by reading each `worktree-list.out`: every one tags `/repo/main` with `branch refs/heads/main`, which `parse_worktree_list` marks with the `main` flag. |
| AC11 | PASS | `dirty detached worktree blocks with DIRTY lines` passes, asserting `DIRTY\|/repo-wt/det\|?? untracked-artifact.txt`, `ACTION\|worktree-remove\|/repo-wt/det\|BLOCKED-DIRTY`, absence of `--force`, and non-zero status. `git diff` on `scripts/bash/cleanup_worktrees_actions_lib.sh` shows the `remove_worktree_safe` region is byte-unmodified by this feature. |
| AC12 | PASS | `locked detached worktree yields BLOCKED-LOCKED and invokes no removal` passes, asserting the token, absence of `worktree remove` and `worktree prune`, and — added by this cycle — `[ "$status" -ne 0 ]`. `remove_detached_worktree` places the locked test before every git invocation. |
| AC13 | PASS | `prunable detached worktree is report-only` passes: report mode emits a `WORKTREE\|/repo-wt/det\|DETACHED\|` line and apply mode produces no `ACTION\|worktree-remove`, no `worktree remove`, and no `worktree prune`. |
| AC14 | PASS | `a hard git failure maps to ANCESTRY_ERROR with no removal` and `classify_detached_head returns 2 on a hard failure` both pass. Extended this cycle by four more hard-failure cases (protection set, content-neutral probe, cherry, diff-tree, residual ls-tree), each asserting return 2, `ANCESTRY_ERROR`, absence of any `MERGED_` token, and — for four of them — the report record plus a non-zero apply status with no `worktree remove`. |
| AC15 | PASS | `reverify_detached_delete_eligible blocks on a flipped verdict` passes with `$status` 1 and `BLOCKED-REVERIFY`. Extended this cycle by `reverify_detached_delete_eligible blocks on a classification hard failure`, which covers the `((crc != 0))` branch that the allowlist-miss case does not reach. |
| AC16 | PASS | Both required cases pass: the unit case returns status 1 with `NOT_ANCESTOR` and no `MERGED_CLEAN`, and the apply case emits `ACTION\|delete\|documentationandmemories\|BLOCKED-CONSOLIDATION-UNMERGED` with no `branch -D` and no `worktree remove /repo-wt/dm`. The fixture sets `merge-base.documentationandmemories.rc` to 0, so the pre-existing ancestry check would report merged; the tip-equality pre-check has to win for the case to pass. |
| AC17 | PASS | `grep -rn "rev-list --count" scripts/bash/` returns no match, re-run by this reviewer. The `consolidated_merged` assertions at `deletion.bats:74-83` pass unchanged after the two `rev-parse` keys were added to that fixture directory. |
| AC18 | PASS | `verify_consolidation_merged fails closed on an empty rev-parse` passes with status 2, `ANCESTRY_ERROR`, no `MERGED_CLEAN`, and no `branch -D documentationandmemories`. |
| AC19 | PASS | `grep -nE "mktemp\|BATS_TMPDIR\|BATS_TEST_TMPDIR\|git init"` over the new suite returns no match. All 16 detached scenario directories and `deletion/consolidated_zero_commit/` are tracked, confirmed with `git ls-files`. All coverage runs through the `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` seams. |
| AC20 | PASS | `SKILL.md` contains the literal `WORKTREE\|<path>\|DETACHED\|<state>\|<flags>` (lines 67 and 139), the literal `BLOCKED-LOCKED` (line 144), and a sentence in the apply-mode workflow step stating that a consolidation branch whose tip equals `main` is not delete-eligible (line 130). This cycle added the apply-mode exit-code paragraph at line 150. |
| AC21 | PASS | `git hash-object` on `.claude/skills/cleanup-merged-worktrees/SKILL.md` and its bundled mirror both return `123aa988ebd7af19108d0022ae533115c5bf7c74`. The named pytest case fails locally on an untracked, gitignored `.claude/state/` file (issue #510, unrelated, green in CI); the hash-object comparison is the stronger check and was used instead. |
| AC22 | PASS | `sh scripts/bash/cleanup-worktrees.sh --help` exits 0 and its stdout contains the literal `WORKTREE\|<path>\|DETACHED\|<state>\|<flags>` at line 17. Re-run by this reviewer at head. The automated guard, which the prior review found weaker than the AC text, now asserts that literal directly. |
| AC23 | PASS | `wc -l scripts/bash/*.sh` reports a maximum of 483 (`cleanup_worktrees_lib.sh`). `scripts/bash/cleanup_worktrees_detached_lib.sh` exists in git at 301 lines and is sourced by `scripts/bash/cleanup-worktrees.sh` with a `shellcheck source=` directive. |
| AC24 | PASS | `sh scripts/bash/shell-qc.sh check` exits 0 with empty stdout and empty stderr, re-run by this reviewer at head — the falsifiable observation the AC names, since `shfmt -d` prints a diff for any unformatted discovered file. The format stage rewrote nothing (byte-identical porcelain listings before and after). CI run 34142466852 at `12cc5766` prints TAP `1..321` with zero lines beginning `not ok` and the headline `Bash coverage (lines): 94.2%`, which is at or above 85.0. No file in `scripts/bash/` exceeds 500 lines. The loop completed in a single iteration. |

**Result: 24 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.**

---

## Summary

All 24 acceptance criteria in `spec.md` are satisfied at head `2742c417`. Each verdict above rests
on evidence this reviewer re-derived at head, not on the executor's or the caller's reported
figures: the entire `tests/shell/` suite was re-run locally at head (exit 0, TAP `1..321`, 321 `ok`,
zero `not ok`, matching the CI plan line exactly), the six cleanup suites were additionally run in
isolation to rule out ordering effects (83 of 83 green), the lint gate was re-run
(exit 0, empty output), the CLI help contract, file-size cap, rejected-guard absence, push-down
mirror parity, temp-file prohibition, and fixture tracking were each re-checked directly, and both
CI coverage runs were verified by `gh run view --json headSha,conclusion` and by downloading and
parsing their Cobertura XML.

The two Major blocking findings from the prior review are closed in substance:

- All three entries on the delete-eligible allowlist that authorize `git worktree remove` are now
  produced by tests and driven end-to-end through the destructive path to
  `ACTION|worktree-remove|/repo-wt/det|OK` with no force flag. This reviewer confirmed the
  `MERGED_CONTENT_NEUTRAL` case independently outside bats. `MERGED_EQUIVALENT` is produced at two
  distinct ladder rungs. `HAS_UNIQUE_RESIDUALS` is produced and its non-eligibility asserted.
- Each of the five previously unexercised fail-closed guards on the destructive path now has an
  asserting case, and the fixtures are constructed so that exactly one git probe fails per scenario,
  which makes the guard under test unambiguous.

The coverage FAIL is closed. The new library's per-file line rate is 1.000 and the repo-wide bash
aggregate is 0.942, against a merge-base baseline of 0.936. None of the three modified production
files regressed.

The remediation introduced no new defect. No executable statement under `scripts/` changed. The
`usage()` heredoc addition was traced claim-by-claim to the implementation and is accurate. The four
pre-existing bats suites gained only a sourcing link and appended cases, with every pinned assertion
intact and green.

One new Minor finding is recorded in `code-review.2026-09-07T17-00.md`: the AC9 assertion on the
absence of a `merge-base` argv line is not falsifiable, because `classify_ancestry` discards that
command's stderr. This corrects a statement the prior review made. The behavior AC9 describes is
correct by code inspection and the criterion's primary assertion is sound, so AC9 remains PASS and
no remediation is required.

**No blocking findings. No `remediation-inputs` artifact is produced by this pass.**
**Recommendation: Go for PR against `epic/cleanup-merged-worktrees-hardening-integration`.**

---

## Acceptance Criteria Check-off

All 24 criteria in `spec.md` were already marked `[x]` before this audit and each is evaluated PASS
above, so the checkbox state is correct and no edit was required. This reviewer verified the
checkbox state at head and made no change to `spec.md`.

No criterion was newly checked off by this pass, and none was un-checked. No phantom criterion was
added.

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md
- Total AC items: 24
- Checked off (delivered): 24
- Remaining (unchecked): 0
- Items remaining: none
```
