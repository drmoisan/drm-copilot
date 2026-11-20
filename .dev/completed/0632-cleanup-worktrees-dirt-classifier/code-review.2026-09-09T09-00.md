# Code Review — issue #632, remediation cycle 3 EXIT REAUDIT

Timestamp: 2026-09-09T09-00
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` @ `8afb0611`
Cycle 3 work range: `fcefa802..8afb0611`
Method: mutation probes on a scratch copy under
`scratchpad/probe1/` (`cp -r` of `scripts/` and `tests/`), run with `npx --yes bats`.
The repository tree was never modified.

## Part 1 — N3, the third data-loss path

### The shipped fix

`scripts/bash/cleanup_worktrees_dirt_lib.sh:297`

```bash
[[ $x == [MARCTU] && $y == [MARCTU] ]] && bothloc=1 # guard:index-and-worktree-both-hold-content
```

nested at the two positive emissions rather than placed as an early return:

- `:321-325` — rung 4's `CONTENT_ON_MAIN` emission, inside
  `guard:rung4-index-blob-unaccounted`
- `:370-374` — rung 5's `CONTENT_IN_HISTORY` emission, inside
  `guard:rung5-index-blob-unaccounted`

### Is the nesting placement correct? PASS

The nested form is the safer of the two options actually available. An early return after
rung 3 would have had to choose a verdict for the two-blob entry at that point; the nested
form instead lets the entry continue down the ladder and reach rung 6's `UNIQUE`, which is
the fail-closed direction. It also leaves rung 4's `drc > 1` hard-fail arm at `:327` still
reachable for a two-blob entry, so a hard read failure is still distinguished from a
negative answer.

Falling through rung 4 with `bothloc=1` does not create a new escape. I traced every
downstream emission: rung 4's untracked half at `:352` requires `untracked == 1`, which
requires `xy == "??"`, which forces `x == '?'` and therefore `bothloc == 0`. Rung 5's
emission is gated. Rung 6 is `UNIQUE`. There is no third positive emission below the gate.

### Is `[MARCTU]` the right class? PASS

The class must select exactly the entries where the index blob and the working-tree blob
are two distinct objects, neither of which is reachable from `HEAD`.

- `M A R C T U` each assert that side holds a blob. `U` holds content at index stages 2
  and 3.
- `D` is correctly excluded: a `D` in a column means that side holds no blob. `AD` and `MD`
  therefore have one blob, and the existing N1 fix already handles `AD`.
- ` ` (space) is correctly excluded: a space in Y means index and working tree hold the
  *same* blob, so the single working-tree probe accounts for both. A space in X means the
  index equals `HEAD`, so the index-side content survives `reset --hard` by definition.
- `?` and `!` are correctly excluded: the path is not in the index.

I could not construct a status pair that holds two distinct non-`HEAD` blobs and is not
selected by `[MARCTU]`.

### Is `U` genuinely reachable? PASS

Reachable, and pinned. Porcelain v1 emits `U` only for unmerged entries, in the
combinations `DD AU UD UA DU AA UU`. Of these, `AA`, `UU`, `AU` and `UA` are both-columns
content-bearing and are selected by the class. `UU` is exercised by a checked-in fixture
(`tests/fixtures/cleanup_worktrees/scenarios/dirt_index_and_worktree_delta/`, entry
`src/c.cs`), and probe C below proves the membership is load-bearing.

One note on the stated rationale rather than the behaviour. The test comment at
`test_cleanup_worktrees_dirt_failclosed.bats` says of the `UU` entry that "two index-side
blobs that are in no commit sit behind it". For an ordinary merge conflict, stage 2 comes
from `HEAD` and stage 3 from `MERGE_HEAD`, so those blobs usually *are* reachable from
commits. The justification is therefore stronger than the general case supports — but the
resulting behaviour errs toward `UNIQUE`, which is the safe direction, and costs only some
false "not disposable" verdicts. Not a defect; recorded for accuracy.

### Is rung 3 safe to leave ungated? PASS

The header comment claims "Rung 3 is not gated: `dirt_is_build_artifact` reads the cached
diff too." I verified the claim against the function at `:202-231` rather than accepting
it. `dirt_is_build_artifact` calls `dirt_diff_is_hintpath_confined` twice — once with an
empty mode (worktree diff) and once with `cached` (index diff) — and returns 1 if *either*
is unconfined, plus `guard:build-artifact-vacuous-confinement` rejecting a zero-line diff
pair. The index blob's delta is therefore genuinely examined and confined to HintPath
rewrites before `DISPOSABLE_BUILD_ARTIFACT` can be emitted. The exemption is justified.

### Reproduction and discrimination probes

Baseline: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` -> `1..15`,
0 `not ok`.

| Probe | Mutation | Result |
|---|---|---|
| A — neutralize the guard | `s/((bothloc == 0))/((1))/g` | `not ok` 12, 13, 14 — **guard is load-bearing** |
| B — disable the rung | `s/((bothloc == 0))/((0))/g` | `not ok` 9, 15 — **negative direction is pinned** |
| C — narrow the class | `[MARCTU]` -> `[MARC]` | `not ok` 14 — **`U` membership is load-bearing** |
| D — drop `T` | `[MARCTU]` -> `[MARCU]` | all 15 pass — **`T` membership is unpinned** (see Part 4) |
| E — true historical revert | `git show fcefa802:...` into the scratch copy | `not ok` 12, 13, 14 — same three, matching probe A |

Probe B is the one that matters most for the "did they just switch the feature off"
question. It fails test 9 (`dirt_tracked_staged_only_blob`: a tracked entry whose content
is on main is still `CONTENT_ON_MAIN`) and test 15 (the `M ` control entry in the N3
fixture). A change that stopped emitting disposable verdicts entirely would not pass.

**N3 verdict: CLOSED.**

## Part 2 — N4, the guard registry's `EXEMPT` floor

### The shipped fix

Three changes, all in `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`:

1. The `EXEMPT` arm of Obligation 5 was deleted (`:356-362` removed), so an `EXEMPT` row
   now falls to the `*)` default and accumulates into `OB5`.
2. A new Invariant 8 (`:245-255`) rejects any kind other than `SEPARATED` or `ARGV`, and is
   deliberately evaluated over *all* rows rather than only rows passing Obligation 1 — the
   comment states the reason, that a row naming a nonexistent scenario is skipped by
   Obligation 5 and would otherwise carry an inadmissible kind unreported. That reasoning
   is correct.
3. The third test was rewritten from an 18-row hand-written pin list to a floor over
   **every** marker id derived from the library, with a one-element `ARGV_ONLY_IDS`
   exception (`history-scan-bounded-range`). The `sibling_mutation` helper and Obligation 6
   were deleted as no longer needed.

### Registry shape — as stated

```
awk -F'\t' '!/^#/ && NF>1 {print $2}' dirt-guard-registry.tsv | sort | uniq -c
  ->  2 ARGV, 40 SEPARATED   (42 rows)
distinct ids: 40
grep -coE '# guard:[a-z0-9-]+$' cleanup_worktrees_dirt_lib.sh  ->  40
grep -n 'EXEMPT' <suite> <registry>  ->  no matches
```

40 markers, 40 distinct registered ids, 42 rows (two library lines carry both an arithmetic
and a named non-arithmetic guard and back two rows each). `EXEMPT` is fully gone.

### The cheapest passing registry — PASS

Under the shipped text, a row is admissible only if:

- Invariant 8: its kind is `SEPARATED` or `ARGV`.
- Obligation 1: its scenario directory exists and is named `dirt_*`.
- Obligation 5: for `SEPARATED`, `CH_REC != UREC[scen]`; for `ARGV`, `CH_ARGV != UARGV[scen]`
  with the record channel unchanged. Both demand an **observed difference** between the
  mutated and unmutated runs.
- Third test: every marker id carries at least one `SEPARATED` row, except
  `history-scan-bounded-range` which must carry an `ARGV` row.

`mutate_lib` is `sed "/# guard:$1\$/$2" "$DIRTLIB"` — the mutation is addressed to that
guard's own marked line only. So a channel difference implies that line executed *and* its
truth value changed the outcome. The cheapest passing registry therefore requires, for each
of the 40 ids, a checked-in scenario that actually drives the ladder to that guard and in
which the guard's decision is observable. **It cannot be satisfied without genuinely
exercising the guard.** The `EXEMPT` escape hatch — "unobservable, therefore exempt" — no
longer exists, so there is no verdict a row can name to excuse itself.

### The discrimination probe actually rejects the parked row — PASS

The suite contains no self-testing negative case; the discrimination is an evidence-time
probe recorded in `evidence/regression-testing/n4-parked-row-rejected.2026-09-09T01-30.md`.
I reproduced it independently on the scratch copy rather than trusting the artifact, and
extended it with two variants the evidence did not cover.

Baseline: `1..3`, 0 `not ok`.

| Attack | Row written | Result |
|---|---|---|
| A1 — the exact cycle-2 parked row | `staged-probe-skip-head EXEMPT dirt_unique ... RECORDS-AND-ARGV-IDENTICAL: ...` | all 3 tests fail: `INVARIANT-2`, `INVARIANT-8 inadmissible kind`, `OBLIGATION-5 channel comparison failed`, `PINS NOT SATISFIED: SEPARATED:staged-probe-skip-head` |
| A2 — same non-reaching scenario, relabelled `SEPARATED` | `staged-probe-skip-head SEPARATED dirt_unique ...` | test 2 fails: `OBLIGATION-5 channel comparison failed` |
| A3 — same non-reaching scenario, relabelled `ARGV` | `staged-probe-skip-head ARGV dirt_unique ...` | tests 2 and 3 fail: `OBLIGATION-5`, `PINS NOT SATISFIED` |

A2 is the attack the evidence artifact did not run and the one that matters: it asks
whether the fix merely renamed the loophole. It does not. Relabelling the parked row as
`SEPARATED` still fails, because Obligation 5 demands an observed difference and the guard
was never reached. Restoring the tracked registry returns the suite to `1..3` green.

**N4 verdict: CLOSED.**

## Part 3 — the missing-comparison check

`tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`, 208 lines, two tests.

### Design — PASS

The property is quantified over the classifier's own emitted `DIRTFILE` records across
every checked-in `dirt_*` scenario discovered from disk, not over a hand-written status-pair
table. For each record whose verdict is neither `UNIQUE` nor
`DISPOSABLE_SESSION_ARTIFACT`, the required content locations are derived from that
record's own status field, and a matching probe for that record's own path must appear in
the stub argv log. This is the right shape: it cannot be satisfied by editing an expected
table, and a future rung that resolves a disposable verdict for an unanticipated status
code is still in scope.

The two exclusions are named with reasons, and both hold up.
`DISPOSABLE_SESSION_ARTIFACT` is resolved at rung 2 by string comparison against a
hard-coded path array and issues no read at all, so there is no comparison for it to be
missing. `UNIQUE` is the fail-closed direction and asserts nothing about recoverability.

The two channels are separated via a `3>&1` swap with the stderr side tagged `ARGV `,
rather than merged — necessary, because a merged stream would let a path appearing only in
a record be read as a path named by an invocation.

### Would it catch R1, N1 and N3? PASS — all three, verified by reproduction

| Defect | Mutation applied to the scratch copy | Gate result |
|---|---|---|
| N1 | neutralize `guard:rung4-tracked-path-in-main` (`((erc == 0))` -> `((1))`) | `not ok 1`, offender `dirt_tracked_staged_only_blob:staged_only.md:CONTENT_ON_MAIN:index` |
| R1 | neutralize `guard:rung1-y-column-gate` (drop the `&& $y == " "` conjunct) | `not ok 1`, offender `dirt_staged_tree_worktree_delta:src/a.cs:STAGED_TREE_IS_COMMIT:worktree` |
| N3 | `s/((bothloc == 0))/((1))/g` | `not ok 1`, three offenders: `src/a.cs:CONTENT_ON_MAIN:index`, `src/b.cs:CONTENT_IN_HISTORY:index`, `src/c.cs:CONTENT_ON_MAIN:index` |
| N3 | true historical revert to `fcefa802` | `not ok 1` |

All three families are detected, each naming the correct scenario, path, verdict and the
specific unaccounted location. The gate is not merely present; it discriminates.

### Dodge analysis — two residual weaknesses, neither reachable, neither blocking

**Dodge 1 — empty the domain.** The first test iterates records and accumulates offenders;
if no scenario emits a disposable verdict, the offender set is empty and the test passes
vacuously. The in-domain count *is* computed (`examined`, 17 on the shipped tree, 19 under
the N3 mutation) but is only echoed to stderr — it is never asserted. There is no floor on
in-domain records.

The second test is the intended mitigation, but it is a floor on **status codes present in
scenario status fixtures** (`??`, `M `, `A `, `R `, ` M`, `AD`, `MM`, `UU`), not on records
reaching a disposable verdict. A fixture set could satisfy all eight codes while arranging
every entry to resolve `UNIQUE`, emptying the first test's domain.

Reachability: low. Emptying the domain requires rewriting checked-in fixtures so that no
scenario yields a disposable verdict, which would immediately break the sibling suites that
assert specific positive verdicts by name — `dirt_content_on_main` -> `CONTENT_ON_MAIN`,
`dirt_staged_tree_is_commit` -> `STAGED_TREE_IS_COMMIT`, `dirt_build_artifact` ->
`DISPOSABLE_BUILD_ARTIFACT`, plus failclosed tests 9 and 15. The dodge is not available
without loud failures elsewhere. **Non-blocking.**

**Dodge 2 — `has_index_probe` is path- and result-independent for one form.**
`has_index_probe` returns success if the argv log contains the substring
`diff-index --cached --quiet` *anywhere*, with no path suffix and no regard to the probe's
exit code. The stated justification — that this form asserts the whole index equals a
commit's tree and so accounts for every path — is sound only when the probe **exits 0**.
When it exits 1 (no ancestor tree matches), the index is not accounted for, yet the helper
still reports it as covered.

Consequence: in a scenario where the once-per-worktree staged probe issues that call, the
index leg of a two-blob entry can be satisfied spuriously. This is visible in the R1
reproduction above, where the `MM` entry was flagged only for `:worktree` — its `:index`
leg passed because `diff-index` had run.

This does not affect the shipped code. For a two-blob entry, `bothloc=1` forces rungs 4 and
5 closed, so no such entry reaches a disposable verdict. It weakens the gate as a
*future* regression detector, not as a statement about `8afb0611`. **Non-blocking**;
recommended follow-up is to require a path-scoped index read, or to key on the probe's
result rather than its invocation.

The gate's own header is candid about being a regression detector with zero live tuples on
a green tree ("it holds zero tuples on a passing tree and fails the moment any change
re-admits a two-blob entry to a disposable verdict"), which is accurate and was confirmed
by the mutation raising `examined` from 17 to 19.

**Missing-comparison check verdict: PASS.**

## Part 4 — NEW finding

### NF-1. The `T` member of `[MARCTU]` is unpinned — PARTIAL, non-blocking

Probe D: `sed -i 's/== \[MARCTU\]/== [MARCU]/g'` on the scratch copy. The full fail-closed
suite still returns `1..15` with zero failures. No checked-in scenario contains a
`T` in either status column, so removing `T` from the class breaks nothing.

Why it is not blocking:

- The shipped code is **correct**. `T` is in the class, so typechange entries with both
  columns content-bearing already fail closed. There is no data-loss path in `8afb0611`.
- The exposure is future-regression only: a later narrowing of the class would not be
  caught.
- Neither systemic gate covers it by construction, and both say so. The registry's mutation
  for this marker replaces the entire condition with `[[ -n "" ]]` and is caught; narrowing
  a character class is a finer mutation outside the registry's vocabulary. The
  content-locations coverage floor explicitly disclaims completeness: "This is not an
  enumeration of every pair porcelain can emit, and it makes no claim about `!!` ... or
  about within-class variants such as `MD` beside `AD`."
- Practical reachability of a `T` entry is low on the platform this tool primarily runs on:
  typechange requires a regular-file/symlink/gitlink transition.

Recommendation for a follow-up issue, not for this cycle: add a `TT` or `MT` entry to
`dirt_index_and_worktree_delta` so probe D flips.

## Part 5 — general code quality

| Area | Verdict | Note |
|---|---|---|
| Comment accuracy | PASS | I checked the two load-bearing claims rather than reading past them: that `dirt_is_build_artifact` reads the cached diff (true, `:225`), and that the marker derivation forces descriptive naming (true, end-anchored `grep`). The one overstated claim is the `UU` stage-blob rationale in the test comment, noted in Part 1 |
| Guard marker discipline | PASS | 40 markers, all registered, all reachable and observable under the strengthened registry |
| Fail-closed direction | PASS | Every new branch resolves toward `UNIQUE` |
| Dead code | PASS | `sibling_mutation` and Obligation 6 were deleted with the `EXEMPT` kind rather than left orphaned |
| Test independence and determinism | PASS | No temp files, no scratch repos, no clock or RNG reads; every scenario is a checked-in fixture directory |
| File size | PASS | classifier 495 / 500 |

## Summary

| Finding | Verdict | Blocking |
|---|---|---|
| N3 — two-blob entries reaching a disposable verdict | CLOSED | no |
| N4 — the registry's `EXEMPT` floor | CLOSED | no |
| Missing-comparison check (AC-48 support) | PASS, two disclosed non-reachable weaknesses | no |
| NF-1 — `T` membership unpinned | PARTIAL | **no** |

Blocking findings: 0.
