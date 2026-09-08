# Remediation cycle 3 — preflight round 1 delta

- Plan under review: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-plan.2026-09-08T23-30.md`
- Reviewer: `atomic-executor` (preflight mode), full-pass validation against the tree at `fcefa802`
- Signal: **PREFLIGHT: REVISIONS REQUIRED**
- Convergence: NO FURTHER ROUNDS EXPECTED — every defect has a mechanical remedy confined to task text or one task's step list; none requires re-deriving a design decision, adding a phase, or re-authoring a fixture
- Counts: 3 blocking, 6 non-blocking

## All four design decisions SUSTAINED, and the declared exclusion SUSTAINED

**Decision 1, the `[MARCTU]` class.** `U` is reachable and the plan's own fixture proves it: a `UU` entry with `diff-quiet` rc 0 and `rev-parse.verify` rc 0 drives `drc=0` then `erc=0` and emits `CONTENT_ON_MAIN` at `:314-317` — exactly N3's route — while the index holds stage-2 and stage-3 content. The reaudit's `M A R C` list would not close it. `T` follows from the same both-columns-content-bearing derivation. The widening is not unnecessary scope.

**Decision 2, nested placement.** Sustained, but on one of its two supporting claims rather than both. See N4 below: sibling claim B is false, and the decision stands on claim A and the `expr_for` argument alone, both of which were verified. Registry row `:35` is the ARGV row keyed to `dirt_staged_tree_worktree_delta` and to the `hash-object` read, so an early return after rung 3 would make it inert on both channels. `expr_for`'s `head -n 1` at `:62`, with invariant 7 at `:231-249`, admits only a mutation of the FIRST comparison, so a second comparison on one marked line is unregisterable.

**Decision 3, deleting the `EXEMPT` kind.** Satisfiability confirmed against the shipped tree: 39 data rows, 37 `SEPARATED` plus 2 `ARGV`; `history-scan-bounded-range` at `:23` is the only id with no `SEPARATED` row; the three new rows are all `SEPARATED`, so the raised floor is met at 42 rows over 40 ids with no existing row re-authored. No guard becomes unregisterable: `kind` is an observation label consumed only by obligation 5, while registration is enforced by invariants 1 through 3 and 6 through 7, none of which the deletion touches.

**Decision 4, accounting over the classifier's own output.** The historical-defect table re-derives correctly, and all 28 existing scenarios were hand-traced post-fix: the property holds for every in-domain record, including `dirt_rename_split`, where the record path matches the probe path because `:421-422` reassigns `rel` before both. One qualification the reviewer states and the plan should absorb: because the fix makes every two-blob entry resolve `UNIQUE`, that class leaves the accounting test's domain by construction, so the test is a regression detector for that class rather than an ongoing positive check. That is what it is for, and it still fails the moment a rung re-admits a two-blob entry to a disposable verdict. The plan's sentence that a scenario set with no two-blob entry "would satisfy the accounting property trivially" is slightly overstated but not wrong in effect.

**The `DISPOSABLE_SESSION_ARTIFACT` exclusion.** Correct and honestly scoped. `dirt_is_session_artifact` at `:130-140` is a pure loop over the array at `:84-88` with no `cleanup_wt_git` call, resolved at rung 2 before any probe. The exclusion is load-bearing rather than cosmetic: `dirt_mixed_unique_blocks`'s session-artifact entry would otherwise demand a working-tree probe that is never issued. The list is complete — every other emitted verdict issues at least one read.

## Blocking defects

### B1 BLOCKING — P3-T4's `git checkout --` destroys P2-T4's three registry rows, and its acceptance demands that outcome

No task before P3-T4 stages anything (`git add -A` first appears in P5-T7), so the index still holds the `fcefa802` version of the registry with 39 data rows. `git checkout -- <path>` restores from the index, so step 3 silently discards the three rows P2-T4 appended. Step 4 then re-runs the registry suite expecting exit 0, but invariant 2 fails for the three new marker ids, so step 4's acceptance is unsatisfiable. The acceptance "the recorded `git status --porcelain` output after step 3 is empty" is satisfied only in the destroyed state and would fail in the correct one.

Remedy (lower churn; avoids both `git add` and `sed -i`): replace step 3 with the inverse row rewrite, using the same write mechanism step 1 uses, and quote the restore target verbatim in the task text as the tab-separated row

```
staged-probe-skip-head	SEPARATED	dirt_staged_tree_is_commit	ALL_DISPOSABLE	s/((first == 1))/((1))/	
```

with six fields and an empty `reason`. Replace the empty-status acceptance with: `grep -vc '^#'` over the registry reports `42`; `grep -cF 'EXEMPT'` over the registry reports `0`; `awk -F'\t' '$1=="staged-probe-skip-head"'` reproduces the row above verbatim; and step 4 exits 0 with zero lines beginning `not ok`.

Alternative, higher churn and exposed to the staging hook: add `git add <registry>` as step 0, keep `git checkout --`, and assert `git diff -- <registry>` is empty plus the same two counts.

### B2 BLOCKING — P0-T4 and P5-T3 are satisfied by the silent bats-skip path

`resolve_tool` at `scripts/bash/shell_qc_lib.sh:131-147` returns 1 when `SHELL_QC_BATS_BIN` names a non-executable, and `run_test` at `:227-248` then prints `bats not installed; skipping shell tests.` and **returns 0**, as its own contract comment at `:230-231` states. P0-T4's stated resolution command, `npx --yes bats --version`, prints a version string rather than a path, so the value placed in the variable is not produced by any command the task names. Under the skip path `EXIT_CODE:` is 0, the `not ok` count is 0, and `BaselineLocalTestTotal:` is 0 — which is "a number" — so the whole gate passes with zero tests executed.

This is the gate on which the entire safety argument of the cycle rests.

Remedy: in P0-T4, state the path-resolution command explicitly, one that emits an absolute path to an executable, and add to acceptance that the recorded combined output does not contain the literal `bats not installed; skipping shell tests.`; that the recorded TAP plan line matches the form `1..N` with N at least 1; and that `BaselineLocalTestTotal:` equals that N. Add the same three conditions to P5-T3, which already carries the plus-six delta check.

### B3 BLOCKING — P4-T2 leaves AC-47 asserting a count this cycle falsifies

`spec.md:858` reads "plus the eight named non-arithmetic verdict guards" and `:864` reads "either one of the eight non-arithmetic mutations the remediation plan fixes by literal". D3 and P2-T5 take the literal arrays from eight to nine. P4-T2 edits AC-47 in place but touches neither site, leaving a criterion that stays checked while stating a false count — the identical failure mode P4-T2 exists to remove for the `EXEMPT` token, in a criterion the exit audit re-evaluates.

Remedy: extend P4-T2 to change both occurrences from eight to nine and to add the new guard to the enumerated list. Add to P4-T2's acceptance, on the unwrapped stream it already uses: `grep -cF 'the nine named non-arithmetic verdict guards'` reports 1, `grep -cF 'the eight named non-arithmetic verdict guards'` reports 0, and `grep -cF 'the eight non-arithmetic mutations'` reports 0.

## Non-blocking defects

**N4 — the false sibling claim in D1's placement rationale.** The clause asserting that an early short-circuit would stop `dirt_tracked_staged_only_blob`'s `AD` entry before `((erc == 0))` and silently unpin the cycle-2 fix is incorrect: `AD` has `y=D`, which is not in `[MARCTU]`, so `bothloc` is 0 and a bothloc-gated short-circuit never fires for that entry. Registry row `:3` would keep separating under the early form. Remedy: delete the clause or replace it with a statement that the `AD` entry is unaffected under either placement because its `D` column keeps `bothloc` at 0. The paragraph's conclusion is unchanged, because it stands on sibling claim A and the `expr_for` argument.

**N5 — AC-48 claims six content-bearing letters; two are pinned by an executed direction.** `M` is pinned by P1-T4 tests 1 and 2, `U` by test 3, and the space and `D` exclusions by test 4. `A`, `R`, `C` and `T` are covered only by the character-class literal, which no checked-in test executes in the both-columns position, so dropping any of them would leave every test green. Remedy: add one clause to P4-T3 stating that `M` and `U` are pinned by executed directions and that the remaining four letters are held by the single guard whose character class is asserted literally, so the criterion does not claim a per-letter executed pin.

**N6 — P3-T1's instruction list does not cover `:198`, but its acceptance requires it.** Line 198 reads `if [ "$(pin_count "$id" any 'SEPARATED ARGV EXEMPT')" -eq 0 ]; then`. None of D4's five edits nor P3-T1's instruction names it, yet P3-T1's acceptance demands `grep -cF 'EXEMPT'` report 0. The edit is also semantically required, since an `EXEMPT` row must stop discharging invariant 2. Remedy: add it to D4 as edit 1b and to P3-T1's instruction, changing the kind list at `:198` to `'SEPARATED ARGV'`.

**N7 — four stale "eight" comment counts survive in the registry suite** at `:153`, `:220`, `:231` and `:438`. P2-T5 takes the arrays to nine but instructs only an added sentence. Remedy: place the update in P3-T3, which runs after `sibling_mutation` is deleted and after the title rename removes "eighteen", with the acceptance `grep -ci 'eight'` over the suite reporting 0.

**N8 — lowercase "exempt" survives in AC-47 after P4-T2.** `spec.md:866` reads "rather than recorded as an exempt guard", describing the deleted mechanism and invisible to the case-sensitive acceptance. Remedy: name that clause in P4-T2's delete list and change the acceptance to `grep -ci 'exempt'` over `spec.md` reporting 0. Verified that `:866`, `:876`, `:878` and `:879` are the only case-insensitive occurrences.

**N9 — P2-T6 says "the five dirt suites" and its command lists six.** Remedy: change five to six.

## Verified clean

The 14-line budget and the 497 threshold check out: the classifier is 481 lines, P2-T1 adds 7 and modifies `:241` without adding a line, P2-T2 adds 7, giving 495 with five lines to the cap; the threshold is consistent across P2-T2, P2-T7 and P5-T4.

Every line and file citation in the plan was re-derived and is exact. Baseline counts confirmed: 31 arithmetic guard-shaped lines, 37 marker lines, 39 registry rows, 28 scenario directories, and the membership literal. End-state arithmetic is internally consistent and derivable.

AC arithmetic confirmed: 47 section-scoped, 47 checked, unscoped 55; the `EXEMPT` token occurs on exactly three lines, all inside AC-47, so the count-to-zero assertion is exact; both new criteria's asserted literals occur zero times today, so they can fail; the end state of 49 and then 49 checked is sound.

All three new registry rows satisfy invariants 1 through 7 and obligation 2, including that the shared mutation text across two rows is not an invariant 5 violation because the ids differ, and that the literal mutation's escapes, mid-pattern `$` and replacement are all correct.

Every fixture filename matches the stub's documented key derivation, and the missing-fixture default of empty stdout with exit 0 is what makes the omitted `rev-list.HEAD.out` behave as the plan describes, so no new stub arm is needed and the stub-digest equality assertion is satisfiable. Both the pre-fix and post-fix record streams reproduce by hand-tracing.

Ordering holds throughout, including the membership count staying constant across Phase 1, the registry suite's exclusion from P2-T3, the `1..3` plan line at P3-T3, and the plus-six delta at P5-T3. Scope holds: no task modifies `cleanup_worktrees_lib.sh`, no task attempts the denied tree digest, no task attempts to make the issue-510 leg pass, and every evidence path is canonical.
