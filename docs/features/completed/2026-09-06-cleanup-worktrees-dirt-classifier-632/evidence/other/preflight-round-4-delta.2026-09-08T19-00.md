# Remediation cycle 2 — preflight round 4 delta

- Plan under review: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-plan.2026-09-08T06-51.md`
- Reviewer: `atomic-executor` (preflight mode), full-pass validation against the tree
- Signal: **PREFLIGHT: REVISIONS REQUIRED**
- Convergence: FURTHER ROUNDS LIKELY, because the remaining work forces a count change through roughly twelve sites and mis-propagated counts were the whole of last round's BD3
- Counts: 2 blocking, 9 non-blocking

## Adjudication of the disclosed residual

The orchestrator asked for an explicit ruling. The reviewer's ruling, adopted here:

- The residual **mechanism** is acceptable. The 1,400-run sweep is correctly rejected: the both-direction rule already costs +22 child shells on a base of 78, which is roughly 100 child shells and 800 to 1,200 stub-git spawns for the suite and is not a fast-execution breach, whereas the sweep is a further 22 x 28 x 2 of about 1,232 child shells.
- The residual **as bounded and disclosed is not acceptable**, because the stated bound is untrue. D3 asserts that the fourteen pinned ids "include every guard this cycle's findings and cycle 1's findings implicate". `remediation-inputs.2026-09-08T06-51.md:34` gives N1's location as `cleanup_worktrees_dirt_lib.sh:294-305`, and that range contains `((untracked == 0))` at `:294` and `((drc == 0))` at `:297` — the gate admitting an entry to rung 4's tracked half and the gate emitting `CONTENT_ON_MAIN`. Neither is pinned and both are parkable. Two of D2 part two's eight non-arithmetic rows (`:311` `[[ -z $blob ]]`, `:321` `[[ -n $mainblob && $mainblob == "$blob" ]]`) are likewise unpinned and parkable, and both are fail-open-direction verdict guards.

The remedy is four additional pins. It adds no mechanism and no runtime cost, because each of those rows is already executed twice.

## Sustained (no action)

The three-kind partition; the both-direction rule, which does real work (it forces `385`, `414` and `415` off `EXEMPT` and is what makes the all-`dirt_unique` registry fail) and leaves no arithmetic row unsatisfiable; P3-T7's constant-switch authorization, which is properly bounded and re-runs and records the `(id, mutation)` uniqueness check; the three new mandatory ids and the pin-derivation section; the `:367` citation correction, where the plan is right and the round-3 delta was wrong; and all the count changes, re-derived independently.

All 14 current pins were hand-traced under their named witnesses and all 14 separate, so nothing blocks execution on satisfiability. The `hash-object-hard-fail` and `find-object-hard-fail` pins depend on the stub emitting `<key>.out` before exiting `<key>.rc`; `respond()` does exactly that.

The planner's five worked rows under `dirt_unique` are confirmed, and at least seven rows cannot be `EXEMPT` there: `294`, `318`, `333`, `371`, `385`, `414`, `415`. The `:280` residual instance is confirmed; its stated extent is not.

## Blocking defects

### BD-A BLOCKING — the cheapest passing artifact parks 22 of 39 rows on a scenario that never runs the marked line, and D3's bounding sentence is false

The `mutation` column is now constrained and `EXEMPT` is an executed observation in both directions. The `scenario` column is still free for the 25 unpinned rows, and a scenario under which the guard's line is never reached makes both constants inert, so all six obligations pass honestly and the row lands `EXEMPT`.

Constructed row by row against the current text:

- 20 arithmetic rows parkable: `97 102 109 113 167 207 208 210 211` and `387 388` against `dirt_unique` (`?? notes.md` gives `any_staged=0`, so `dirt_staged_tree_commit` is never called, and `untracked=1`, so `dirt_is_build_artifact` is never called); `280 282 286` against `dirt_unique` (the `((1))` direction at `:280` enters rung 3 but the path `case` at `:202-205` rejects `notes.md` with no git call); `294 297 318 321 333` against `dirt_build_artifact` (the ` M ...csproj` entry resolves at rung 3 and returns at `:283-284`, so nothing past rung 3 executes); `444` against `dirt_unique`.
- 2 literal rows parkable: `rung4-untracked-main-present` (`:321`) and the `hash-object-hard-fail` row carrying `s% || \[\[ -z $blob \]\]%%` (`:311`), both against `dirt_build_artifact`. Neither is subject to the both-direction rule, which D3 scopes to form-2 rows.
- Only 3 free rows are forced off `EXEMPT` by the new rule: `385` to `ARGV`, `414` and `415` to `SEPARATED`.

22 + 3 + 14 = 39, and every acceptance command in P2-T5 through P2-T10, P3-T7 and P3-T8 is satisfied, as is AC-47.

The rule is a real improvement over round 3, where 31 rows could be written `EXEMPT` with the mutated library never executed at all. The class has moved from "no execution" to "execution of an irrelevant scenario", and the population is 22 rows rather than the one the plan discloses.

Remedy — four additional pins, no new mechanism, zero additional child-shell runs. Every witness below was hand-traced by the reviewer.

1. Add two mandatory marker ids for cycle-start lines `294` and `297`. Suggested spellings `rung4-tracked-gate` and `rung4-tracked-content-equal`, both verified prefix-free against the existing 15 and against each other. Re-derive the property mechanically in the mandatory-id section.
2. Extend the pinned table from nine rows to thirteen:

| Marker id | Line | Mutation | Witness | Unmutated | Mutated | Pin |
|---|---|---|---|---|---|---|
| `rung4-tracked-gate` | 294 | `s/((untracked == 0))/((0))/` | `dirt_tracked_staged_only_blob` | `docs/tracked.md` gives `CONTENT_ON_MAIN` | gives `UNIQUE` (no `hash-object.docs_tracked.md` fixture, so empty blob at `:311`) | `SEPARATED` |
| `rung4-tracked-content-equal` | 297 | `s/((drc == 0))/((0))/` | `dirt_tracked_staged_only_blob` | `docs/tracked.md` gives `CONTENT_ON_MAIN` | gives `UNIQUE` | `SEPARATED` |
| `rung4-untracked-main-present` | 321 | the fixed literal for `:321` | `dirt_rename_split` | `?? notes -> draft.md` gives `UNIQUE` (no `rev-parse main:notes -> draft.md` fixture, so `mrc=0` and `mainblob` empty) | gives `CONTENT_ON_MAIN`, aggregate flips `HAS_UNIQUE` to `ALL_DISPOSABLE` | `SEPARATED` |
| `hash-object-hard-fail` with `s% || \[\[ -z $blob \]\]%%` | 311 | as fixed in D2 part two | `dirt_staged_tree_worktree_delta` | `MM src/a.cs` gives `UNIQUE` at `:311` (`hrc=0`, blob empty) | records identical; argv gains the rung-5 `rev-parse --verify --quiet main~1000` and `log --find-object=` calls | `SEPARATED` or `ARGV` |

3. P2-T7 must pin the fourth entry by **(`id`, `mutation`)**, not by `id`. `hash-object-hard-fail` already backs two rows, so an id-only pin — and P2-T8 acceptance command 9 as written — is satisfied by its arithmetic sibling and leaves the literal row unconstrained.
4. Propagate the counts: mandatory ids 15 to 17; pinned ids 14 to 18 (14 `SEPARATED`, 4 `SEPARATED`-or-`ARGV`); fixed `(id, mutation)` literal pairs 16 to 18; free-constant arithmetic rows 23 to 21; the section heading "The nine additionally pinned guards" to thirteen; P2-T8's "Nine rows do not take a freely chosen scenario" to thirteen and its command-9 id list; P2-T7's title and P2-T6/P2-T7's `sed` range addresses; and P2-T9, P2-T11, P3-T8 and AC-47's "fourteen". Marker lines stay 37, registry rows stay 39, scenario and record counts stay 28 and 34.
5. Replace D3's bounding sentence with one that is true, for example: the eighteen pinned ids include every guard named by a cycle-1 or cycle-2 finding, every guard inside N1's cited range `:294-305`, and every one of the eight named non-arithmetic verdict guards.

### BD-B BLOCKING — AC-47 omits its own bound

AC-47's per-kind clause is accurate and the round-3 "thirteen" to "eight" correction landed. But AC-47 says nothing about what an `EXEMPT` row does not establish, while D3 does. AC-47 is the permanent artifact a future audit reads, and this cycle exists because two consecutive cycles shipped data-loss defects that passed a 45-criterion set. A criterion that describes the assertions but omits their scope is the same failure mode.

Remedy, one clause. In P4-T3, add to AC-47's text the literal `EXEMPT is scenario-scoped` followed by wording to the effect that an `EXEMPT` row establishes only that the guard is unobservable under its own named scenario in both admissible directions, and does not establish that no checked-in scenario separates it, while the eighteen pinned ids carry that stronger property. Add the acceptance search

```
sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -cF 'EXEMPT is scenario-scoped'
```

reporting `1`. That literal occurs zero times in `spec.md` today, so the assertion can fail.

## Non-blocking defects

**NB-1** — the prefix-freeness derivation prose is wrong in two places. The three `clear-` ids diverge at the seventh character, not the sixth (the sixth is `-` in all three), and "every other adjacent pair differs within the first two characters" is false for (`rung1-y-column-gate`, `rung4-tracked-hard-fail`), which first differ at character 5, and for (`rung4-tracked-path-in-main`, `rung4-untracked-main-present`), which first differ at character 7. The conclusion is correct; prefix-freeness was re-derived mechanically over all 15. Restate as: no adjacent pair in sorted order is a prefix pair; the two closest are the `rung4-tracked-` pair, first differing at character 15, and the `clear-re` pair, first differing at character 9.

**NB-2** — "the widening moves exactly one live guard out of `EXEMPT`" is false, as is departure 6's "457 is the only guard whose separation depends on the widening". Counter-example: `((drc == 0))` at `:109` under `dirt_staged_tree_worktree_delta`. Forcing it `((0))` leaves `staged` empty, so `M  src/b.cs` resolves `CONTENT_ON_MAIN` instead of `STAGED_TREE_IS_COMMIT`; `unique_count` is 1 in both runs, so the aggregate is `HAS_UNIQUE` in both and only the `DIRTFILE|` record differs. Restate as "at least one", and as "the only one among the pinned set whose separation depends on the widening".

**NB-3** — NB-G's restatement is scoped to a glob that hides a second occurrence. `scripts/bash/cleanup-worktrees.sh:7` carries `set -euo pipefail`; the underscore glob excludes it while the plan's own departure 2 widened the glob to `cleanup[-_]worktrees*`. The argument is unaffected, since the harness does not source that file, but the sentence reads as a general claim. Restate naming both occurrences and stating that neither is sourced by the harness.

**NB-4** — P2-T1 acceptance command 4 needs `LC_ALL=C`. The task's own justification is that sorted order makes adjacency sufficient, which holds under byte order; a punctuation-folding collation can place a non-prefix id between a prefix pair.

**NB-5** — P2-T4's temporary-file check can be made unsatisfiable by the suite's own header. The task instructs the executor to write a header stating its subject and mechanism; a natural header mentioning `mktemp` matches the pattern and makes the count non-zero however correct the harness is. Lower-churn remedy: require the header to state the property as "the harness writes nothing to disk" and to contain none of the tokens the check searches for. Alternative: prefix the pipeline with `grep -v '^[[:space:]]*#'`.

**NB-6** — the `EXEMPT_SIBLING_DIFFERED` token is created by P2-T4 but only checked by P2-T6, so a different spelling in P2-T4 surfaces two tasks later. Add to P2-T4's acceptance that `grep -cF 'EXEMPT_SIBLING_DIFFERED' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` reports at least `1`.

**NB-7** — the exhaustiveness claim needs one qualifier. With the both-direction rule the (records-identical, argv-identical) cell maps to no kind when the sibling constant separates. D3 says this correctly two paragraphs later, but "mutually exclusive and exhaustive" and AC-47's "partition the outcome space of two comparisons" read unconditionally. Qualify both with "for an admissible (`mutation`, `scenario`) pair — one that survives the both-direction rule".

**NB-8** — D2 part five's "a pattern containing `/` (line 172)" is wrong. Line 172's fixed mutation pattern is `continue ;;`, which contains no `/`; the slashes are in the source line, not the pattern. Cite the two pipe-carrying literals instead, or drop the parenthetical.

**NB-9** — observation only. The plan file carries no `PLANNER-INTERNAL-REVIEW: PASS` block and no `SELF-REVIEW: RE-DERIVED THIS PASS` enumeration. Per `atomic-plan-contract` those are handoff-message signals rather than plan-file content, so this is not a plan defect. The orchestrator confirms it received both in the round-3 handoff.

## Verified clean

Task ordering holds against the state the tree will be in when each task runs, including P2-T3's two forward-referencing rows, P2-T8 command 9's satisfiability before Phase 3, both red windows of the classify membership suite, P2-T10's four-id prediction and bound, and P5-T12's observation ordering. The plan file being uncommitted affects no condition: none compares against `HEAD`, a literal SHA, or a clean worktree that a commit would invalidate.

AC arithmetic: section-scoped 45/45/0 today, 47/45/2 after Phase 4, 47/47 after P5-T10, unscoped 53 to 55. AC-8 is the eighth checkbox with its phrase at `:714`. `grep -c '^- \[ \] AC-4'` is 0 today, 2 after P4-T2 and P4-T3, and 0 after P5-T10, so P5-T10's assertion can fail.

No wrap-tolerant-assertion violation was found in the conditions added this round. Every asserted literal occurs zero times today or is quoted verbatim by the plan; the `sed` range addresses match their `@test` lines and terminate on a column-0 `}`; no asserted token carries a placeholder character; the coverage rules do not apply because bash coverage is CI-measured and no local figure is asserted.
