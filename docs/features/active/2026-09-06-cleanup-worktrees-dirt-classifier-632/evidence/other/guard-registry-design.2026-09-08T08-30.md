# Guard registry harness design — [P2-T11]

Timestamp: 2026-09-08T08-30
Task: [P2-T11]
Subject: `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` and
`tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`

## 1. The arithmetic guard-shaped predicate

The mechanical enumeration selects a line of `scripts/bash/cleanup_worktrees_dirt_lib.sh` by
this extended regular expression, stated verbatim:

```
\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)
```

It matches an arithmetic comparison of a variable against a numeric literal. Against the
current tree it selects exactly **31** lines. Each of the 31 carries a `# guard:<id>` marker
and at least one registry row.

## 2. Why the predicate alone is under-inclusive

The registry's obligation is a **superset** of that enumeration, because the predicate matches
none of the following eight guards, and three of them are the exact sites that produced
cycle 1's findings R1, R2 and R5. A gate derived from the predicate alone would have excluded
the shapes that carried the real defects, which is why the sale of that gate as "every guard
is registered" would have been false.

| Marker id | Library line | Source shape | Cycle-1 finding |
|---|---:|---|---|
| `diff-header-skip` | 182 | the four-form diff header `case` arm ending `continue ;;` | R5 |
| `rung1-y-column-gate` | 270 | `[[ ... && $y == " " ]]` | R1 |
| `hash-object-hard-fail` | 329 | `[[ -z $blob ]]`, the second half of `if ((hrc != 0)) \|\| [[ -z $blob ]]` | — |
| `rung4-untracked-main-present` | 339 | `[[ -n $mainblob && $mainblob == "$blob" ]]`, the second half of line 339 | — |
| `history-hit-nonempty` | 359 | `if [[ -n $found ]]` | — |
| `rename-payload-split-gate` | 421 | `if [[ ${xy:0:1} == R \|\| ${xy:0:1} == C ]]` | R2 |
| `unique-verdict-tally` | 428 | `[[ $verdict == "UNIQUE" ]] && unique_count=$((unique_count + 1))` | — |
| `clear-requires-all-disposable` | 465 | `if [[ $agg != "ALL_DISPOSABLE" ]]` | — |

The `\|` sequences in the table above are Markdown table escaping for a literal pipe, not
`sed` escapes. Six of the eight are non-arithmetic-only lines and carry a marker of their own;
lines 329 and 339 already match the predicate and carry exactly one marker each.

Counts: 31 arithmetic lines + 6 non-arithmetic-only lines = **37 marker lines**;
31 arithmetic rows + 8 named non-arithmetic rows = **39 registry rows**.

## 3. Row identity is the pair (`id`, `mutation`)

Lines 329 and 339 each carry an arithmetic guard **and** a named non-arithmetic guard on one
physical line, and each receives exactly one marker. One marker line therefore backs more than
one registry row, so row identity is the pair (`id`, `mutation`), not `id` alone. Two rows
sharing a marker id must carry different `mutation` values and each row's mutation must target
its own sub-expression. The enumeration test asserts that no two rows share an (`id`,
`mutation`) pair, and it asserts "at least one" registry row per marker rather than "exactly
one" so that these two lines may back two rows each.

## 4. The three kinds are a partition, for an admissible pair

| Kind | Record channel | Argv log |
|---|---|---|
| `SEPARATED` | differs | either |
| `ARGV` | identical | differs |
| `EXEMPT` | identical | identical, in **both** admissible directions |

Each kind asserts the **presence and the absence** it names. `ARGV` asserts that the record
channel is identical as well as that the argv log differs; `EXEMPT` asserts that both are
identical. That is what makes `EXEMPT` an **observed outcome rather than a written verdict**:
a registry that recorded every unpinned row `EXEMPT` against a scenario it never exercised
would fail the gate rather than satisfy it.

The three kinds partition the outcome space of the two channel comparisons **for an admissible
(`mutation`, `scenario`) pair** — one that survives the both-direction rule of section 5. The
qualifier is load-bearing and not decorative. Without it the claim is false in one cell: a
form-2 row whose recorded constant leaves both channels identical, but whose sibling constant
separates, lands in the records-identical, argv-identical cell and yet maps to no kind, because
the both-direction rule denies it `EXEMPT` while neither `SEPARATED` nor `ARGV` describes an
observation it did not make. Such a pair is inadmissible, and its remedy is to rewrite the row
to carry the separating constant, at which point it is admissible again and falls into exactly
one kind.

## 5. The six obligations

Obligations 1 through 4 apply to **every** row regardless of kind. Obligation 5 is the
kind-specific channel comparison. Obligation 6 applies to `EXEMPT` form-2 rows only.

1. The `scenario` column names a directory that exists under
   `tests/fixtures/cleanup_worktrees/scenarios/` **and** its name begins with `dirt_`.
2. The composed `sed` program actually changed the library source; exactly one line differs;
   that line carries a `# guard:` marker; and the two versions of that line still differ after
   the trailing `# guard:` comment is stripped from both and runs of whitespace are collapsed
   in both.
3. `bash -n` accepts the mutated source.
4. The **unmutated** `classify_worktree_dirt` call under that scenario emitted at least one
   `DIRTFILE|` record — the proof that the ladder actually executed rather than
   short-circuiting. The obligation is scoped to that call and not to the two-call group, and
   it does not accept a non-zero classifier exit as an alternative.
5. The kind-specific channel comparison, asserting both the difference and the identity the
   table in section 4 states, and additionally requiring an `ARGV` row's `reason` to begin
   `ARGV-ONLY:` followed by at least one non-space character and an `EXEMPT` row's `reason` to
   begin `RECORDS-AND-ARGV-IDENTICAL:` followed by at least one non-space character.
6. The both-direction rule of section 6.

A row that fails obligation 1 is recorded in that obligation's accumulator and is **not**
evaluated against obligations 2 through 6, because a missing scenario directory makes the two
channels unobtainable rather than unequal. Obligations 2 through 6 are evaluated independently
of one another, so a row may appear in more than one accumulator.

## 6. The `EXEMPT` both-direction rule and the defect it closes

For a row whose `mutation` is form 2 — the derived arithmetic form of section 8 — an `EXEMPT`
classification additionally requires the harness to run the row's marked line under the
**other** constant and observe that both channels are identical there too. The harness composes
the sibling program itself from the row's own marked line; no registry column carries it. The
accumulator that collects rows failing this is named `EXEMPT_SIBLING_DIFFERED`.

**The free-direction defect this closes.** Without the rule, the choice between `((0))` and
`((1))` is a free choice, and an author can park a separable guard at `EXEMPT` by picking
whichever constant happens to be inert. That is exactly the defect the row for
`((srrc != 0))` at library line 389 carried in an earlier draft of this cycle's plan: `srrc` is
initialised to 0 by the declaration at `cleanup_worktrees_dirt_lib.sh:385` and no `dirt_*`
scenario supplies a `status.<path>.rc` fixture, so the `((0))` direction is inert while the
`((1))` direction empties the record stream entirely. With the rule, a row is `EXEMPT` only
when the guard's outcome is unobservable under that scenario **however** the guard is forced,
and any row for which one direction separates must be recorded `SEPARATED` or `ARGV` with that
direction as its `mutation`.

The rule is scoped to form-2 rows. The eight literal-fixed rows of section 2 have no sibling
constant, so for them `EXEMPT` remains the single-direction observation.

## 7. `EXEMPT` is scenario-scoped

**EXEMPT is scenario-scoped.** It claims that under the row's named scenario the guard is
unobservable in both admissible directions. It does **not** claim that no checked-in scenario
could separate the guard: outside the eighteen pinned rows the `scenario` column is the
registry author's choice, and a guard that is simply not reached under the chosen scenario is
honestly `EXEMPT` there.

Closing that stronger property mechanically would require sweeping every `EXEMPT` row against
all `dirt_*` scenarios in both directions, on the order of 1,400 additional child-shell runs
each spawning several stub-git processes, which conflicts with the fast-execution requirement
in `.claude/rules/general-unit-test.md`. The stronger property is therefore established by
**naming** rather than by sweeping: eighteen rows are pinned to a required kind against a named
checked-in witness scenario.

## 8. The eighteen pinned rows over seventeen distinct ids

The pin count is **eighteen rows**, and those rows carry **seventeen distinct ids**. The row
count exceeds the id count by one because `hash-object-hard-fail` is pinned twice, once for its
arithmetic row and once for its literal row.

The seventeen distinct pinned ids: `build-artifact-vacuous-confinement`,
`rung4-tracked-path-in-main`, `rung4-tracked-hard-fail`, `hash-object-hard-fail`,
`find-object-hard-fail`, `status-read-hard-fail`, `clear-reset-hard-fail`,
`clear-clean-hard-fail`, `clear-requires-all-disposable`, `unique-verdict-tally`,
`history-hit-nonempty`, `rung4-tracked-gate`, `rung4-tracked-content-equal`,
`rung1-y-column-gate`, `rename-payload-split-gate`, `diff-header-skip`,
`rung4-untracked-main-present`.

**Three of the eighteen pins are keyed to the pair (`id`, `mutation`).** `hash-object-hard-fail`
and `rung4-untracked-main-present` are the two ids that each back two registry rows on one
marked line, so an id-keyed pin on either is discharged by whichever of that id's two rows
happens to carry the demanded kind and leaves the other row unconstrained. The three affected
pins are `hash-object-hard-fail`'s arithmetic row, `hash-object-hard-fail`'s literal row, and
`rung4-untracked-main-present`'s literal row.

The key is a plain string test on whether the row's `mutation` begins with the four characters
`s/((`. The test is exact rather than heuristic: every arithmetic mutation is exactly
`s/((EXPR))/((0))/` or `s/((EXPR))/((1))/` and therefore begins `s/((`, and every one of the
eight fixed literals begins `s%`. Using the prefix test rather than a quoted copy of the
mutation literal keeps the `%`, `$` and `\[` characters those literals carry out of a shell
quoting round-trip.

## 9. Why the `sed` address is `$`-anchored and marker-addressed

The address is `/# guard:<id>$/`, immediately followed by the row's `mutation` value, which
carries its own delimiter. An unanchored `/# guard:<id>/` matches every line whose marker
merely **begins** with `<id>`, so an id that is a prefix of another id would silently mutate two
guards under one registry row and destroy per-guard attribution. The prefix-freedom of the
37-id set is separately checked mechanically under `LC_ALL=C`, and the anchor is what makes the
address correct even so.

The address is marker-addressed rather than pattern-only because a pattern-only program would
fire on every line the pattern matches. Several arithmetic comparison texts occur on more than
one line — `rc != 0` at 107 and 177, `drc == 0` at 119 and 307, `drc > 1` at 123 and 319,
`untracked == 0` at 290 and 304 — so a pattern-only mutation would neutralize two guards at
once and no row could be attributed.

The composed program is passed to `sed` as a **single argument** and is never itself evaluated
by the shell, because two of the fixed mutations contain `$blob` and `$agg`, and evaluating the
program would expand them to the empty string before `sed` saw them.

## 10. Why the observation channel is the full record stream, not the aggregate

The record channel is the function group's full emitted record stream and its exit status:
stdout of `classify_worktree_dirt`, that call's exit status, stdout of `clear_disposable_dirt`,
that call's exit status. It is not the `DIRTSUM|` aggregate alone.

The widening is load-bearing. `((clrc != 0))` at library line 475 — `clear-clean-hard-fail`, the
failure check on `clean -fd` — separates on the record channel only: the unmutated run prints
`ACTION|dirt-clear|/repo-wt/dirt|FAILED` and returns 1 while the mutated run prints
`ACTION|dirt-clear|/repo-wt/dirt|OK` and returns 0, the `DIRTSUM|` aggregate is
`ALL_DISPOSABLE` in both runs, and the argv log is identical in both because 475 is the last
guard in the sequence and no further git call follows it. An aggregate-only channel would have
forced a live guard on an irreversible action into `EXEMPT`.

A second case the widening is required for is a two-entry scenario in which only the per-entry
record changes: under `dirt_tracked_staged_only_blob`, both `rung4-tracked-gate` and
`rung4-tracked-content-equal` change the `docs/tracked.md` entry's verdict from
`CONTENT_ON_MAIN` to `UNIQUE` while the aggregate stays `HAS_UNIQUE`, because the scenario's
other entry is `UNIQUE` in every run.

The stub's `stub-git: <argv>` log travels on stderr and is captured into a **separate** argv
channel, tagged with an `ARGV ` prefix the harness itself adds, so the log can never contaminate
the record channel.

## 11. Why the mutated source is evaluated from a shell variable rather than written to disk

`.claude/rules/general-unit-test.md` prohibits the creation and use of temporary files in tests.
The harness applies the `sed` program into a shell variable, checks the result with `bash -n`
reading from a here-string, pipes the text into a child shell on stdin, and evaluates it there
with `eval` in place of sourcing the real library. Nothing is written to disk and no scratch
directory is used. The child still sources `cleanup_worktrees_enumerate_lib.sh` and
`cleanup_worktrees_lib.sh` from disk, in that order, before evaluating the mutated text, because
the `cleanup_wt_git` seam that `CLEANUP_WT_GIT_BIN` drives is defined in the enumerate library:
a child that sourced only the mutated dirt library would fail at the first git call for a reason
unrelated to the guard under test.

A second reason to keep the mutated text off disk is that a mutated copy of a production library
written into the source tree would be picked up by the formatter, the linter, and the coverage
run, and a crash mid-test would leave it there.

## 12. The two constraints that keep an inert mutation out of the registry

An inert mutation is the mechanism by which the whole gate could be made vacuous: a change that
edits only a comment, only the marker, or only whitespace is a real source change that passes
`bash -n`, leaves both observation channels byte-identical, and would land its row in `EXEMPT`
with every other obligation satisfied. Two constraints close that.

**Constraint one — the `mutation` column is constrained, not free.** Every registry row's
`mutation` value must be either exactly one of the **eight** non-arithmetic literals fixed in
section 2, matched as a whole string, or exactly

```
s/((EXPR))/((0))/
```

or exactly

```
s/((EXPR))/((1))/
```

where `EXPR` is the arithmetic comparison text — the substring the enumeration predicate matches
— taken from that row's marked line in the **unmutated** library with the surrounding `((` and
`))` removed. The enumeration test derives `EXPR` from the library rather than holding a table of
expected strings, so the constraint fails when a row's mutation targets a line other than its own
marker, and it cannot be satisfied by editing the test. For a marked line carrying no arithmetic
comparison — the six non-arithmetic-only lines, where the extraction yields nothing — only the
eight-literal disjunct applies.

*Class closed:* a comment-only or marker-only edit, and a whitespace-only reindent. Neither is
expressible in either admissible form.

**Constraint two — obligation 2 normalizes before comparing.** The single changed line must
still differ between the two versions after both have had their trailing `# guard:` comment
stripped and their runs of whitespace collapsed to a single space. The comment strip rejects a
mutation that edits only the marker comment. The whitespace collapse rejects a mutation that only
reindents the code, which the comment strip alone does **not** reject: a mutation inserting a
second space inside the code region survives the strip, because the two stripped strings still
differ as byte sequences.

*Class closed:* the same two classes, closed a second time at the point of observation, and closed
for the eight literal-fixed rows as well, which constraint one does not reach.

## 13. The escape hatch is eight rows wide and its residual is stated

The literal escape hatch is exactly the eight non-arithmetic rows, not thirteen. All five
mutations in the plan's remediated-guard table are already instances of the derived arithmetic
form, so a thirteen-literal hatch would have admitted exactly the same string for each of those
five rows' own marked lines that the derived form admits; the narrowing therefore does not remove
five otherwise-unconstrained rows.

The reason the narrowing is taken is narrower than that. A whole-string membership test against a
set of literals lets a literal fixed for one row be **borrowed by another row** whose marked line
it does not target. The narrowing shrinks that borrowable set from thirteen strings to eight. It
does not eliminate it: the eight remaining literals are still whole-string admissible for any row,
and obligation 2's requirement that the substitution change the row's **own** marked line remains
the backstop for them. The claim made here is the bounded one — eight borrowable strings rather
than thirteen — and nothing stronger.

## 14. Observed state at the end of Phase 2

37 `SEPARATED`, 2 `ARGV`, 0 `EXEMPT`, over 39 rows and 37 distinct marker ids. The full
per-row classification is at
`evidence/qa-gates/guard-registry-classification.2026-09-08T08-30.md`.
