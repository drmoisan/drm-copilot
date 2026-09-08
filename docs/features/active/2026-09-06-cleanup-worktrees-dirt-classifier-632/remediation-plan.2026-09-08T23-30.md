# Remediation Plan — cleanup-worktrees dirt classifier (Issue #632), cycle 3

- Timestamp: 2026-09-08T23-30 (UTC)
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/`
- Work mode: `full-bug` (`issue.md:12`). Acceptance-criteria source is `spec.md`,
  `## Acceptance Criteria` section only.
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
- Worktree: `.claude/worktrees/agent-ac72d35e7980bc69d`
- Findings source: `remediation-inputs.2026-09-08T23-30.md`,
  `code-review.2026-09-08T23-30.md`, `feature-audit.2026-09-08T23-30.md`,
  `policy-audit.2026-09-08T23-30.md`
- Blocking findings: 2 (N3 FAIL, N4 blocking-PARTIAL). Non-blocking carried into scope:
  2 (P2, P4 — both closed as side effects of the two blocking fixes).
- **This is the third and final remediation cycle.** The scope below is bounded to the two
  blocking findings, the systemic check the reaudit shows is still missing, and the two
  non-blocking items that the same edits close. Nothing else is opened.

## Scope

Three obligations and two corrections.

1. **N3** — for a status entry whose X column and Y column both carry a content-bearing
   letter, content exists in the index *and* in the working tree and the two differ. Rung
   4's tracked half compares `main` to the working tree
   (`scripts/bash/cleanup_worktrees_dirt_lib.sh:305-317`) and rung 5 hashes the
   working-tree file (`:327`, `:352-362`). Neither reads the index blob, so `MM`, `AM`,
   `RM` and `CM` entries resolve `CONTENT_ON_MAIN` or `CONTENT_IN_HISTORY`, the worktree
   aggregates `ALL_DISPOSABLE`, and `--clear-disposable` destroys the staged blob. Data
   loss. Both rungs fail closed for such an entry.
2. **N4** — the guard registry's `EXEMPT` kind can be satisfied by naming a scenario under
   which the ladder never reaches the guard, so 20 of 37 marker ids are parkable
   (`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:350-374`). The `EXEMPT`
   kind is **removed** rather than strengthened, and the pin floor is raised from 17 of 37
   ids to every marker id.
3. **The missing-comparison family** — R1, N1 and N3 are the same defect: a rung infers
   disposability from a probe that does not answer the question. The guard registry
   detects a *dead guard* and passes cleanly on a tree containing N3. This cycle adds a
   second, independent gate that states the property over the **inputs to a verdict**:
   every disposable verdict the ladder emits must be backed by git reads that account for
   every location holding that entry's content.
4. **P2** — `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md:78` cites
   `.gitignore:67`; the observed rule is at `.gitignore:68`.
5. **P4** — the registry's `GUARD_RE` predicate compels markers only onto arithmetic
   comparisons, so the one non-arithmetic guard this cycle adds is registered by name in
   the suite's literal list rather than picked up automatically.

Out of scope, carried forward unchanged: cycle 1's O2, O3, O4 and O5; F7 through F14;
P1 (`.claude/lib/bash/compute-concurrency-batches.sh` at 81.82%, zero changed lines on
this branch); the ten residual uncovered lines in the classifier library.
`scripts/bash/cleanup_worktrees_lib.sh` is **not** modified by this cycle.

**The two adjudicated blocked gates are not reopened.** `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`
records that the `discover_shell_scripts`-derived tree digest AC-31 requires is denied to
every agent in this environment, and that three legs of the push-down contract test fail
on the pre-existing gitignored-state defect, issue #510. No task in this plan attempts the
denied digest command, and no task attempts to make the #510 leg pass. The format-stage
observation this plan uses instead is stated in **Gate ownership** below, and the
push-down contract test is recorded as an `[expect-fail]` gate with `ExpectedExitCode: 1`
so its known outcome is auditable rather than left as an unchecked box.

## Constraints that bound every task

- `scripts/bash/cleanup_worktrees_dirt_lib.sh` is **481** lines at the start of this cycle
  and `scripts/bash/cleanup_worktrees_lib.sh` is **496**. No production, test, or reusable
  shell file may reach 500 lines. `cleanup_worktrees_lib.sh` is excluded from modification.
  The N3 fix as specified in D1 adds **14** lines, bringing the classifier library to
  **495**. See **File-size derivation** below for the line-by-line arithmetic and for the
  extraction target if the executor cannot land the change within that budget.
- No temporary files in tests. Every fixture is checked in under
  `tests/fixtures/cleanup_worktrees/scenarios/`.
- Every git call goes through the `cleanup_wt_git` seam; tests drive `CLEANUP_WT_GIT_BIN`
  and `CLEANUP_WT_STUB_SCENARIO`.
- Report mode stays non-mutating. No subcommand that writes the index or the object
  database may be introduced, and none may be added to
  `tests/fixtures/cleanup_worktrees/stub-bin/git`. This cycle adds **no** git read of any
  new shape and therefore requires **no** stub change.
- Both directions of every classification stay pinned.
- Every `.claude/**` edit is mirrored byte-identically into
  `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- All evidence goes to
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`.
  No `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/` or
  `artifacts/evidence/` path is valid for evidence in this plan.

## Gate ownership

`shfmt`, `shellcheck` and `bats` have a local route in this worktree; `bats` is supplied
through the documented `SHELL_QC_BATS_BIN` seam or invoked directly as `npx --yes bats`.
`kcov` has **no** local route: `bash scripts/bash/shell-qc.sh test --coverage` exits 127
here. Coverage is measured only by a `workflow_dispatch` of
`.github/workflows/_shell-coverage.yml` against a pushed commit, and the numbers are read
from that run's merged Cobertura artifact. **No task in this plan asserts a locally
derived bash coverage figure.**

The current measured position, from CI run `34229386300` (recomputed by the cycle-2
reaudit from the merged Cobertura artifact rather than read from the rounded `line-rate`
attribute): 93.69% repository-wide (2166/2312), 94.12% on
`scripts/bash/cleanup_worktrees_dirt_lib.sh` (160/170).

`run_check` at `scripts/bash/shell_qc_lib.sh:164-202` runs `shfmt -d` once over the
discovered file list and then `shellcheck` once per file. Neither tool prints anything on
a clean run and `run_check` prints no summary of its own, so **there is no findings count
to read from a passing invocation**. Every task that runs `bash scripts/bash/shell-qc.sh check`
therefore records the command's combined stdout and stderr verbatim and asserts that it is
empty, rather than asserting a printed count.

`run_format` at `:204-224` likewise prints nothing on success and exits 0 whether or not
it rewrote a file, so its exit code cannot distinguish a clean run from a repairing one.
The observation this plan pairs with each write-mode format run is therefore **twofold**:
`git status --porcelain --untracked-files=all` recorded verbatim immediately before and
immediately after the run, and — in the same task — a `bash scripts/bash/shell-qc.sh check`
run whose combined output must be empty. The check run is the leg that can fail: `shfmt -d`
prints a unified diff and returns non-zero for any file the write-mode pass did not bring
into conformance. The `discover_shell_scripts`-derived tree digest that AC-31's text names
is **not** attempted, for the reason recorded in
`evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`; AC-31 retains the PARTIAL
disposition the cycle-2 reaudit adjudicated and no task in this plan claims otherwise.

## The three questions this cycle answers

Recorded here so no task has to decide them.

**Q1 — what makes N3's fix sound rather than merely refusing?** An entry has at most two
distinct content blobs: the **index blob**, which exists and differs from `HEAD` when the
X column carries a content-bearing letter, and the **working-tree blob**, which exists and
differs from the index when the Y column carries one. When Y is a space the two are the
same blob and one probe accounts for both. When Y is `D` the working-tree blob does not
exist. Only when **both** columns carry a content-bearing letter are there two distinct
blobs, and rungs 4 and 5 read exactly one of them. So the gate condition is precisely
"both columns content-bearing", not "the entry is staged", and it leaves `AD` — the shape
N1 closed — untouched.

The content-bearing letters are `M A R C T U`. `M`, `A`, `R` and `C` are the four the
reaudit names. `T` (typechange) is included because a typechange on either side is a
content difference by the same argument. `U` (unmerged) is included because an unmerged
entry holds content at index stages 2 and 3, and a `UU` entry whose working-tree copy has
been edited back to `main`'s content resolves `CONTENT_ON_MAIN` by exactly the route N3
describes. ` `, `?`, `!` and `D` are excluded: a space means the two sides agree, `?` and
`!` mean the path is not in the index, and `D` means the blob on that side does not exist.

**Q2 — why remove `EXEMPT` rather than strengthen it?** The reviewer's preferred remedy
(a) is to require an `EXEMPT` row to demonstrate that the ladder reached its guard. Any
mechanical form of "the ladder reached this line" needs a third observation channel — an
`xtrace` stream, or a semantics-preserving sentinel mutation — which is a new mechanism
inside the gate and is out of scope for this cycle. Removing the kind achieves the same
end with a deletion: a row must be `SEPARATED` (record channel differs) or `ARGV` (argv
log differs), and **both require an observed difference, which is only possible if the
guard executed**. "Never reached" stops being a way to pass. The tree already satisfies
this: the shipped registry is 37 `SEPARATED` + 2 `ARGV` + 0 `EXEMPT`
(`tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`, 40 lines, one comment header
and 39 data rows), so the strengthened gate is satisfiable on the current tree without
re-authoring a single existing row.

**Q3 — what form does the missing-comparison check take?** The caller proposed an
exhaustive enumeration over the porcelain (X, Y) pairs, asserting for each pair which
content locations exist and that the deciding rung compares every location holding
content. That is the right property. It is adopted with one change of shape, for a reason
given in **Why the accounting form and not the enumeration form** below: the enumeration
is used as a **coverage floor** underneath the property rather than as the property
itself. The property is quantified over every disposable verdict every checked-in
scenario actually emits, so it detects a missing comparison in a rung the enumeration
never anticipated; the enumeration then guarantees that the scenario set reaches every
classifier-relevant status-code class.

### Why the accounting form and not the enumeration form

An enumeration keyed on (X, Y) pairs asserts a property of the *pairs the table lists*. A
future rung that resolves a disposable verdict for a pair the table did not anticipate is
invisible to it, and the table is a table — it can be edited to match whatever the code
does. That is the "enumeration predicate narrower than the property claimed" class the
caller names.

The accounting form inverts the quantifier. It reads the classifier's **own output** — the
`DIRTFILE|` records and the stub's argv log — and, for every record whose verdict is not
`UNIQUE`, derives the required content locations from that record's own `xy` field and
requires a matching probe in the argv log for that record's own path. Nothing in it is a
list of expected verdicts, so it cannot be satisfied by editing a table. Checked by hand
against the three historical defects:

| Defect | The record it emitted | Required locations | Probes issued | Accounting verdict |
|---|---|---|---|---|
| R1 | `STAGED_TREE_IS_COMMIT` for `MM` | index **and** worktree | `diff-index --cached --quiet` only | **fails** — no worktree probe |
| N1 | `CONTENT_ON_MAIN` for `AD` | index (Y is `D`, so no worktree blob) | `diff --quiet main --` only | **fails** — no index probe |
| N3 | `CONTENT_ON_MAIN` / `CONTENT_IN_HISTORY` for `MM` | index **and** worktree | worktree probes only | **fails** — no index probe |

The guard registry catches none of these three directly. The accounting gate catches all
three. The enumeration is retained as the second test in the same suite, and its role is
stated precisely rather than as a blanket anti-vacuity claim: it holds the risky status-code
classes in the scenario set, so the shapes the accounting property is about cannot silently
leave the corpus.

**One verdict is excluded and the exclusion is stated rather than assumed.**
`DISPOSABLE_SESSION_ARTIFACT` is resolved at rung 2 by exact string comparison against the
hard-coded `CLEANUP_WT_SESSION_ARTIFACT_PATHS` array
(`scripts/bash/cleanup_worktrees_dirt_lib.sh:84-88`, `:130-140`) and issues **no git call
at all**. It is a path authorization, not a content inference, so there is no comparison
for it to be missing. It is excluded by name, with that reason, in both the suite header
and AC-48. `UNIQUE` is excluded because it is the fail-closed direction and asserts
nothing about recoverability.

## Design decisions this plan fixes

### D1 — the N3 fix

`classify_dirt_entry` gains one flag and two arithmetic gates. Nothing is moved and no
existing read is removed or reordered.

*Part one — the flag.* `bothloc=0` is appended to the existing `local` declaration at
`scripts/bash/cleanup_worktrees_dirt_lib.sh:241`, which currently reads

```
	local drc=0 erc=0 vrc=0 lrc=0 range found
```

and becomes

```
	local drc=0 erc=0 vrc=0 lrc=0 bothloc=0 range found
```

That is a modification of an existing line and adds no line. The flag is set immediately
after the untracked test at `:287`, by this block, whose third line is quoted verbatim
because the registry mutation in D3 must match it character for character:

```
	# See INDEX AND WORKING TREE ARE TWO LOCATIONS in the header: two content-bearing
	# columns mean the index blob and the working-tree blob hold different content.
	[[ $x == [MARCTU] && $y == [MARCTU] ]] && bothloc=1 # guard:index-and-worktree-both-hold-content
```

*Part two — rung 4's tracked positive.* The block at `:314-317` becomes

```
			if ((erc == 0)); then # guard:rung4-tracked-path-in-main
				if ((bothloc == 0)); then # guard:rung4-index-blob-unaccounted
					printf 'CONTENT_ON_MAIN|\n'
					return 0
				fi
			fi
```

*Part three — rung 5's positive.* The block at `:359-362` becomes

```
	if [[ -n $found ]]; then # guard:history-hit-nonempty
		if ((bothloc == 0)); then # guard:rung5-index-blob-unaccounted
			printf 'CONTENT_IN_HISTORY|%s\n' "$found"
			return 0
		fi
	fi
```

A blocked entry emits nothing at either site and falls through to rung 6, which is
`UNIQUE`. The `((drc > 1))` hard-fail arm at `:319` and every other existing branch are
untouched.

*Why the gate is nested rather than folded into the existing condition.* Writing
`if ((erc == 0)) && ((bothloc == 0)); then` would put two arithmetic comparisons on one
marked line. `expr_for` in the registry harness
(`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:59-68`) takes the **first**
match with `head -n 1`, so the second comparison could never carry an admissible mutation
under Invariant 7 and the new guard would be unregisterable — exactly the class the
registry exists to prevent. The nested form gives each new guard its own marked line and
its own row.

*Why the gate sits at the two emissions and not before rung 4.* A single early
short-circuit after rung 3 would be two lines cheaper, and it is rejected on evidence
rather than on taste. Under it, `dirt_staged_tree_worktree_delta`'s `MM src/a.cs` entry —
the one checked-in entry whose two content-bearing columns set `bothloc` to 1 — would stop
before the `hash-object` read, which would make the registry's `hash-object-hard-fail`
**literal** row (`tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv:35`, scenario
`dirt_staged_tree_worktree_delta`) inert on both channels and fail Obligation 5. Under the
two-site form that same entry still reaches rung 5 and still issues the `hash-object` read
before either new gate can suppress an emission, so the row keeps separating.

*A withdrawn second claim, corrected rather than carried.* An earlier draft of this
paragraph also asserted that an early short-circuit would stop
`dirt_tracked_staged_only_blob`'s `AD` entry before `((erc == 0))` and thereby unpin
registry row `:3`. That claim is **false** and is withdrawn. The scenario's status fixture
(`tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_staged_only_blob/status._repo-wt_dirt.out:1`)
reads `AD staged_only.md`, and `D` is not in `[MARCTU]`, so `bothloc` stays 0 for that entry
and a `bothloc`-gated short-circuit never fires for it. Row `:3` keeps separating under
either placement. The placement decision is unchanged, because it rests on the
`hash-object` sibling above together with the `expr_for` argument, both re-derived against
the current tree in this pass.

*Reachability of the new gates against the current tree, re-derived this pass.* The only
checked-in status entry whose X and Y columns both carry a content-bearing letter is
`MM src/a.cs` in `tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_tree_worktree_delta/status._repo-wt_dirt.out:1`.
That scenario supplies `diff-quiet..src_a.cs.rc` containing `1`, so `drc` is 1, rung 4's
positive branch is not entered, and the entry reaches `hash-object` with no
`hash-object.src_a.cs.out` fixture, resolving `UNIQUE` at the empty-blob guard exactly as
it does today. Its record and its argv log are therefore **byte-identical** before and
after this change. Every other checked-in entry has a space, a `?` or a `D` in one of the
two columns, so `bothloc` is 0 for all of them and neither new gate can fire. **No
existing scenario's records or argv log change.** The change is observable only through
the new scenario D2 creates.

### D2 — the new scenario `dirt_index_and_worktree_delta`

One directory, four status entries, carrying both directions of both new gates and the
control that rejects a "fix" that simply disables the rungs. The stub key derivation is
documented at `tests/fixtures/cleanup_worktrees/stub-bin/git:10-61`; every key below was
derived from that contract in this pass.

`status._repo-wt_dirt.out`, four lines in this order:

```
MM src/a.cs
MM src/b.cs
UU src/c.cs
M  docs/tracked.md
```

Classifier fixture files:

| File | Content | Purpose |
|---|---|---|
| `diff-quiet..src_a.cs.rc` | `0` | rung 4's tracked probe says the worktree content equals `main` |
| `rev-parse.verify.main_src_a.cs.rc` | `0` | `main` holds content at that path, so N1's guard passes |
| `hash-object.src_a.cs.out` | `aaaa1111` | the entry reaches rung 5 rather than dying at the empty-blob guard |
| `diff-quiet..src_b.cs.rc` | `1` | rung 4 misses, so the entry is decided at rung 5 |
| `hash-object.src_b.cs.out` | `bbbb1111` | the working-tree blob id |
| `log.find-object.bbbb1111.out` | `ffff3333` | that blob is in history |
| `diff-quiet..src_c.cs.rc` | `0` | the unmerged entry's worktree content equals `main` |
| `rev-parse.verify.main_src_c.cs.rc` | `0` | `main` holds content at that path |
| `hash-object.src_c.cs.out` | `cccc1111` | reaches rung 5, which misses |
| `diff-quiet..docs_tracked.md.rc` | `0` | the control's worktree content equals `main` |
| `rev-parse.verify.main_docs_tracked.md.rc` | `0` | `main` holds content at that path |

The directory also carries the six non-classifier fixture files copied verbatim from
`tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/`: `worktree-list.out`,
`for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`,
`merge-base.feature-dirt.rc`, `worktree-remove.rc`. Those six are the complete
non-classifier set in `dirt_unique`, re-derived against the current tree in this pass. No
`rev-list.HEAD.out` is supplied, so the staged-tree probe replays the stub default of
empty stdout and exit 0, falls out of its loop, and returns 1; `staged` is therefore empty
and rung 1 never fires for the `M ` control.

*Derived verdicts, before the D1 fix* — this is the fail-before state Phase 1 records:

```
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||MM|src/a.cs
DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|ffff3333|MM|src/b.cs
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||UU|src/c.cs
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333
```

*Derived verdicts, after the D1 fix* — this is the pass-after state:

```
DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs
DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/b.cs
DIRTFILE|/repo-wt/dirt|UNIQUE||UU|src/c.cs
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

`src/a.cs` reaches rung 5 with blob `aaaa1111` and no `log.find-object.aaaa1111` fixture,
so `found` is empty and rung 6 resolves it. `src/c.cs` reaches rung 5 with blob
`cccc1111` and no fixture, likewise. `src/b.cs` reaches rung 5, finds `ffff3333`, and is
stopped by the new `guard:rung5-index-blob-unaccounted` gate.

### D3 — the three new registry rows and the ninth literal

The three guards D1 adds are registered. Two are arithmetic and are compelled by the
existing `GUARD_RE` predicate; the third is not, and is added to the suite's hard-coded
`LIT_IDS`/`LIT_MUTS` lists at
`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:157-176`, taking those lists
from eight entries to nine. **This is the whole of P4's remediation and its bound is
stated rather than implied:** it registers the one non-arithmetic guard this cycle adds.
It does not make future `[[ ... ]]` verdict guards register themselves. A general
`[[ ... ]]` predicate would match every conditional in the file rather than only the
verdict guards, so no such predicate is proposed.

| id | kind | scenario | baseline_aggregate | mutation | Mutated observation |
|---|---|---|---|---|---|
| `index-and-worktree-both-hold-content` | `SEPARATED` | `dirt_index_and_worktree_delta` | `HAS_UNIQUE` | `s%\[\[ $x == \[MARCTU\] && $y == \[MARCTU\] \]\]%[[ -n "" ]]%` | all four entries resolve disposable; the aggregate becomes `ALL_DISPOSABLE` |
| `rung4-index-blob-unaccounted` | `SEPARATED` | `dirt_index_and_worktree_delta` | `HAS_UNIQUE` | `s/((bothloc == 0))/((1))/` | `src/a.cs` and `src/c.cs` become `CONTENT_ON_MAIN` |
| `rung5-index-blob-unaccounted` | `SEPARATED` | `dirt_index_and_worktree_delta` | `HAS_UNIQUE` | `s/((bothloc == 0))/((1))/` | `src/b.cs` becomes `CONTENT_IN_HISTORY|ffff3333` |

The two arithmetic rows carry the **same** mutation text and different ids. That is
admissible and unambiguous: row identity is the pair (`id`, `mutation`), the `sed` address
is the `$`-anchored `/# guard:<id>$/`, and `expr_for` derives `bothloc == 0` from each
row's own marked line. Invariant 5 (no two rows share an (`id`, `mutation`) pair) is not
violated because the ids differ.

**Escaping.** The `\[` and `\]` in the literal mutation are genuine `sed` escapes: in a
POSIX basic regular expression `[` opens a bracket expression, so matching the literal
`[[` and the literal `[MARCTU]` requires them. `$x` and `$y` are mid-pattern, so `$` is a
literal dollar sign, not an anchor. There is no `|` in this mutation and therefore no
Markdown table escaping to strip — the cell above is the authoritative spelling and is
copied into the TSV verbatim. The composed program is passed to `sed` as a single argument
and is never `eval`ed, which is what keeps `$x` and `$y` unexpanded.

**Counts after this cycle**, each derived rather than asserted:

| Quantity | Cycle start | End state | Arithmetic |
|---|---:|---:|---|
| Arithmetic guard-shaped lines | 31 | **33** | the two `((bothloc == 0))` lines are added |
| Marker lines (`# guard:` at end of line) | 37 | **40** | 33 arithmetic + 7 non-arithmetic-only |
| Registry data rows | 39 | **42** | 33 arithmetic + 9 named non-arithmetic |
| Distinct registry ids | 37 | **40** | 42 rows less the two ids that back two rows each |
| Named non-arithmetic literals (`LIT_IDS`) | 8 | **9** | `index-and-worktree-both-hold-content` is added |

The two ids that back two rows each are `hash-object-hard-fail` and
`rung4-untracked-main-present`; each of their marked lines carries an arithmetic
comparison and a named non-arithmetic test together.

### D4 — the N4 remediation: the `EXEMPT` kind is removed and the pin floor is raised

Six concrete edits to `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`,
numbered 1, 1b, and 2 through 5. Edit 1b is carried inside item 1 below.

1. **Delete the `EXEMPT)` arm of Obligation 5** (`:350-356`). A row whose `kind` is not
   `SEPARATED` or `ARGV` then falls to the existing `*)` default at `:357-359` and is
   recorded in `OB5`.

   **Edit 1b — narrow Invariant 2's kind list** at `:198`, which reads
   `if [ "$(pin_count "$id" any 'SEPARATED ARGV EXEMPT')" -eq 0 ]; then`. The third
   argument becomes `'SEPARATED ARGV'`. This is the one site naming the deleted kind that
   lies outside Obligation 5, Obligation 6, the `EXEMPT_SIBLING_DIFFERED` accumulator and
   the file header, so no other edit in this decision reaches it. It is semantically
   required and not merely cosmetic: while `EXEMPT` stays in that list, a row carrying the
   deleted kind still discharges Invariant 2 for its marked id, so a marker id whose only
   registry row is inadmissible would report as registered. It is also what makes P3-T1's
   `grep -cF 'EXEMPT'`-reports-`0` acceptance satisfiable, since edits 1 and 2 alone leave
   this occurrence in the file. It is numbered `1b` so that the references to edits 3, 4
   and 5 in P3-T2 and P3-T3 keep pointing at the same edits.
2. **Delete Obligation 6 entirely** (`:362-374`), together with the `sibling_mutation`
   helper (`:119-136`), the `EXEMPT_SIBLING_DIFFERED` accumulator, its `echo` at
   `:384-386`, and its assertion at `:393`. The sibling rule existed only to constrain
   `EXEMPT`; with the kind gone it constrains nothing.
3. **Add Invariant 8 to the first test**: a `badkind` accumulator over the registry rows,
   recording any row whose `kind` is neither `SEPARATED` nor `ARGV`, printed as
   `INVARIANT-8 inadmissible kind:` and asserted empty. This is not redundant with the
   `*)` default: Obligation 5 is only evaluated for rows that pass Obligation 1, so a row
   naming a nonexistent scenario would otherwise carry an inadmissible kind unreported.
4. **Replace Groups A and B of the third test** (`:396-431`) with a floor over **every**
   marker id: for each id read from the library's markers, at least one registry row with
   that id must carry kind `SEPARATED`, except for the ids in a hard-coded
   `ARGV_ONLY_IDS` list, for which at least one row must carry kind `ARGV`.
   `ARGV_ONLY_IDS` has exactly one member, `history-scan-bounded-range`, and the comment
   at its site states why: the stub keys `log --find-object` on the object id alone
   (`tests/fixtures/cleanup_worktrees/stub-bin/git:321-331`), so the bounded-range
   endpoint changes the invocation without changing any record, and no scenario can make
   that guard separate on the record channel. Verified against the shipped registry in
   this pass: it is the only id with no `SEPARATED` row.
5. **Keep Group C unchanged** (`:432-448`). The three pair-keyed pins remain necessary:
   an id-keyed floor on `hash-object-hard-fail` or `rung4-untracked-main-present` is
   discharged by whichever of that id's two rows carries `SEPARATED` and leaves the other
   unconstrained.

The third test's title changes from `the eighteen pinned guard rows carry the registry
kinds this plan fixes` to `every marker id is pinned by kind and the two dual-row lines
are pinned by pair`, because the count in the old title is no longer the property.

*Satisfiability, checked against the shipped tree rather than assumed.*
`tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` holds 39 data rows of which 37
are `SEPARATED` and 2 are `ARGV`; the two `ARGV` rows are `history-scan-bounded-range`
(`:23`) and the `hash-object-hard-fail` literal row (`:35`), and `hash-object-hard-fail`
also holds a `SEPARATED` arithmetic row at `:5`. Every id except
`history-scan-bounded-range` therefore already has a `SEPARATED` row, and the three rows
D3 adds are all `SEPARATED`. The raised floor is satisfied by the end-state registry
without re-authoring any existing row.

*What the removal costs.* A guard that genuinely cannot be separated under any checked-in
scenario now **fails** the gate instead of being parked. That is the intended direction
for a classifier whose false "safe" verdict destroys work: the fix for such a failure is
to add a scenario that reaches the guard, which is the thing the `EXEMPT` kind was letting
authors skip.

### D5 — the content-location accounting gate

A new suite, `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`, carrying
exactly two tests. It sources the three libraries through the same
`CLEANUP_WT_GIT_BIN` + `CLEANUP_WT_STUB_SCENARIO` seam the existing suites use, captures
`classify_worktree_dirt`'s stdout as the record stream and its stderr as the stub argv log
**separately**, creates no file on disk, and uses no scratch directory.

*Test 1 — the accounting property.* For every directory matching `dirt_*` under
`tests/fixtures/cleanup_worktrees/scenarios/`, and for every `DIRTFILE|` record that run
emits whose verdict is neither `UNIQUE` nor `DISPOSABLE_SESSION_ARTIFACT`:

- read `xy` from field 5 and the path from field 6 onward, so a path containing the
  delimiter is recovered intact (`dirt_pipe_path` carries `docs/a|b.md`);
- set `x` to `${xy:0:1}` and `y` to `${xy:1:1}`;
- an **index blob** exists when `x` is one of `M A R C T U`;
- a **working-tree blob** exists when `y` is one of `M A R C T U`, or when `xy` is `??`;
- when both exist, **both** must be accounted for; when only one exists, that one must be;
  when `x` is content-bearing and `y` is a space, the two are the same blob and **either**
  probe accounts for it;
- an index probe for the record's path is an argv line containing `diff-index --cached --quiet`,
  or an argv line ending with `diff --no-color -U0 --cached -- <path>`, or an argv line
  ending with `rev-parse :<path>`;
- a working-tree probe for the record's path is an argv line ending with
  `diff --quiet main -- <path>`, or ending with `hash-object -- <path>`, or ending with
  `diff --no-color -U0 -- <path>`.

Every unaccounted (scenario, path, verdict, location) tuple is accumulated and printed
before the assertion, so one run names every offender.

The `diff-index --cached --quiet <commit> --` form is path-independent by design: it
asserts that the **whole index** equals an existing commit's tree, which accounts for
every path in it. That is why it is matched without a path suffix, and it is what makes
`STAGED_TREE_IS_COMMIT` accountable.

*Test 2 — the status-code coverage floor.* The union of two-character status codes across
every `dirt_*/status._repo-wt_dirt.out` fixture must contain each of these eight literals:

| Code | Classifier-relevant class it represents |
|---|---|
| `??` | untracked; the only shape that sets `untracked=1` |
| `M ` | staged, worktree clean; reaches rung 1 |
| `A ` | staged addition, worktree clean; the path may be absent from `main` |
| `R ` | staged rename; the only shape besides `C` that triggers the ` -> ` payload split |
| ` M` | unstaged only; the index equals `HEAD` |
| `AD` | staged content with the working-tree copy deleted; N1's shape |
| `MM` | both columns content-bearing, ordinary; N3's shape |
| `UU` | both columns content-bearing, unmerged; N3's shape at an index stage |

*What the floor does and does not establish, stated precisely.* Once the D1 fix lands,
every two-blob entry resolves `UNIQUE`, and `UNIQUE` is one of Test 1's two excluded
verdicts. That class therefore leaves Test 1's domain by construction, so for two-blob
entries Test 1 is a **regression detector** rather than an ongoing positive check: it holds
zero tuples for them on a passing tree, and it fails the moment any change re-admits a
two-blob entry to a disposable verdict, which is precisely the property N3 is about. The
earlier wording, that a scenario set with no two-blob entry "would satisfy the accounting
property trivially", overstated this and is withdrawn: such a set would satisfy the
two-blob part of the property for the same structural reason a fixed tree does, so the
floor's contribution is not to make that part non-trivial but to keep the shapes present so
the detector has something to detect. Membership in Test 1's domain is a property of a
record's **verdict**, not of its status code, so no claim is made here about which of the
other six floor codes carry in-domain records on any given tree; what the D1 fix does is
remove the two two-blob codes from the domain as a class. `UU` is present only because
D2's new scenario supplies it, so removing that entry fails Test 2 — the floor can fail.

The floor's scope is stated rather than left implicit. It covers the classes the
classifier's own branching distinguishes: the untracked test, rung 1's X-and-Y gate, the
rename/copy payload split, and D1's two-content-bearing-columns gate. It does **not**
enumerate every (X, Y) pair porcelain can emit, and it makes no claim about `!!` (which
the status read cannot produce, because it never carries `--ignored`) or about
within-class variants such as `MD` beside `AD`.

## File-size derivation

`scripts/bash/cleanup_worktrees_dirt_lib.sh` is 481 lines. D1 adds:

| Insertion | Lines |
|---|---:|
| The `INDEX AND WORKING TREE ARE TWO LOCATIONS.` header paragraph plus its blank separator | 6 |
| The `bothloc` block of D1 part one (two comment lines and one code line) | 3 |
| The nested `if`/`fi` at rung 4's positive | 2 |
| The nested `if`/`fi` at rung 5's positive | 2 |
| One line of rewrap in the rung-1 comment block at `:262-269`, whose sentence about falling through to the working-tree rungs must now point at the header paragraph | 1 |
| **Total** | **14** |

End state **495 of 500**, five lines of headroom. Modifying `:241` to add `bothloc=0` adds
no line. The header paragraph is bounded at six lines including its blank separator and
must open with the fixed heading sentence `INDEX AND WORKING TREE ARE TWO LOCATIONS.`, so
its length is not the executor's choice.

**The fix fits. If it does not**, the executor must stop rather than compress the header
or exceed the cap, and report the overage. The extraction target, fixed here so it is not
a decision made under pressure, is a new sibling library
`scripts/bash/cleanup_worktrees_dirt_ladder_lib.sh` holding `classify_dirt_entry` and
nothing else — it is the one function in the file with no caller other than
`classify_worktree_dirt` and no dependency on the file's other state, and moving it takes
the classifier library to roughly 340 lines while the new file lands near 155. That
extraction is **not** authorized by this plan; it is the named fallback if P2-T6's
line-count acceptance fails, and taking it requires the caller's approval because it adds
a `source` line to the wrapper and to five bats suites.

## Acceptance-criteria changes

`spec.md` carries 47 criteria in its `## Acceptance Criteria` section (`:678` to `:892`),
all checked. The section-scoped derivation is fixed here so no task chooses one:

```
awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['
```

Eight checkboxes sit **outside** that section, so an unscoped `grep -c '^- \['` reports 55
before this cycle and 57 after. Neither unscoped figure is the criterion count.

This cycle makes four changes:

1. **AC-48 is added** for the N3 property and the accounting gate.
2. **AC-49 is added** for the raised registry floor.
3. **AC-47 is edited in place**, box unchanged, to delete the clauses describing a kind the
   gate no longer has — including the literal `EXEMPT is scenario-scoped` — and to point
   its pin clause at AC-49. This is a correction, not a re-claim: AC-47's remaining text
   describes what the gate still does, and leaving the `EXEMPT` clauses would leave
   `spec.md` asserting a mechanism that was deleted. The three lines carrying the token
   `EXEMPT` in `spec.md` are `:876`, `:878` and `:879`, all inside AC-47, so the token's
   whole-file count going to zero is an exact check on the edit.
4. **AC-8's count phrase is corrected** from `twenty-eight` to `twenty-nine` at `:714`,
   because this cycle adds one scenario directory.

End state: **49** criteria in the section, all checked.

## Scenario and record counts

`tests/shell/test_cleanup_worktrees_dirt_classify.bats:214-255` names every `dirt_*`
scenario explicitly at `:220-231`, asserts the iterated count equals the on-disk directory
count at `:248-249`, and asserts a literal record total of `34` at `:253`. Both figures
were re-derived against the current tree in this pass: 28 `dirt_*` directories exist and
the asserted literal is `[ "$seen" -eq 34 ]`.

| Point in the plan | Scenarios | Records | Composition |
|---|---:|---:|---|
| Start | 28 | 34 | 22 one-entry + 6 two-entry |
| After Phase 1 | 29 | 38 | 22 one-entry + 6 two-entry + 1 four-entry |

The list, the literal and the explanatory comment at `:250-252` are all updated by the
**same** task that creates the directory, so the suite is never left failing on a count.
The record total is 38 both before and after the D1 fix — the fix changes verdicts, not
the number of records — so the count update is safe to make in Phase 1, ahead of the fix.

## Task-ordering note

Three orderings are load-bearing and each is stated with the failure it prevents.

1. **The fixture, the tests and the membership count go in together (Phase 1).** Creating
   the directory without updating `test_cleanup_worktrees_dirt_classify.bats` breaks that
   suite's on-disk count assertion immediately, and the Phase 1 fail-before run would then
   be unattributable.
2. **The library fix, its markers and its registry rows go in together (Phase 2).** The
   moment D1's two arithmetic lines exist without markers, Invariant 1 fails; the moment
   they carry markers without registry rows, Invariant 2 fails. The Phase 2 pass-after run
   in P2-T3 therefore names the failclosed and content-locations suites explicitly and
   does **not** include the registry suite, which is run green at the end of the phase in
   P2-T6.
3. **N4's `EXEMPT` removal comes after Phase 2 (Phase 3).** Removing the kind from a
   registry that is mid-edit would confuse two independent failures.

## Recorded correction to a cycle-2 evidence artifact

`evidence/other/phase0-blocked-gates.2026-09-08T22-00.md:78` states that
`git check-ignore -v .claude/state/current-session-id` reports `.gitignore:67`. The
observed rule is at `.gitignore:68`, which reads `.claude/state/`; `.gitignore:67` reads
`.claude/agent-memory`. Both were read directly in this pass. The reasoning in that
artifact is unaffected — the path is gitignored either way — so the correction is a
one-token edit and is made in Phase 4 rather than treated as a finding.

---

### Phase 0 — Baseline capture

- [x] [P0-T1] Read, in this order, `.github/copilot-instructions.md`,
  `.github/instructions/general-code-change.instructions.md`,
  `.github/instructions/general-unit-test.instructions.md`, and `.claude/rules/shell.md`.
  Write `evidence/remediation-baseline/phase0-instructions-read.2026-09-09T00-00.md`
  carrying `Timestamp:`, `Policy Order:`, and the explicit list of the four files read.
  Acceptance: the artifact exists and its file list names all four paths above.

- [x] [P0-T2] Read the four cycle-3 finding documents in the feature folder:
  `remediation-inputs.2026-09-08T23-30.md`, `code-review.2026-09-08T23-30.md`,
  `feature-audit.2026-09-08T23-30.md`, `policy-audit.2026-09-08T23-30.md`. Write
  `evidence/remediation-baseline/phase0-findings-read.2026-09-09T00-00.md` recording, for
  each of N3 and N4, the file and the line range the finding names. Acceptance: the
  artifact names `scripts/bash/cleanup_worktrees_dirt_lib.sh` with the ranges `303-320`
  and `344-362` for N3, and
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` with the range `338-373`
  for N4.

- [x] [P0-T3] Run `bash scripts/bash/shell-qc.sh format`, then run
  `bash scripts/bash/shell-qc.sh check` in the same task. Record
  `evidence/remediation-baseline/shell-qc-format.2026-09-09T00-00.md` with `Timestamp:`,
  `Command:` for both commands, `EXIT_CODE:` for both, `Output Summary:` reproducing each
  command's combined stdout and stderr verbatim, and the fields `StatusBefore:` and
  `StatusAfter:` carrying the verbatim output of
  `git status --porcelain --untracked-files=all` taken immediately before and immediately
  after the format run. `run_format` prints nothing and exits 0 whether or not it rewrote
  a file, so the paired check run is the observation that can fail: `shfmt -d` prints a
  unified diff and returns non-zero for any file the write-mode pass left unformatted.
  The `discover_shell_scripts`-derived tree digest AC-31 names is **not** attempted; the
  artifact must say so and cite
  `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md` as the adjudication. Acceptance:
  both `EXIT_CODE:` values are `0`; the check command's combined output is recorded as
  empty, quoted verbatim as an empty block rather than paraphrased; `StatusBefore:` and
  `StatusAfter:` each reproduce their output verbatim and carry the literal `(empty)` when
  that output is empty; and the artifact states explicitly whether `StatusAfter:` lists any
  path absent from `StatusBefore:`.

- [x] [P0-T4] Resolve the bats **executable path** and then run the full local test stage.
  The resolution is specified as a path-emitting command rather than a version-printing one,
  because the seam consumes a path: `resolve_tool` at `scripts/bash/shell_qc_lib.sh:134-141`
  returns 1 when `SHELL_QC_BATS_BIN` names anything that is not an executable, and `run_test`
  at `:240-243` then prints `bats not installed; skipping shell tests.` and **returns 0**, as
  its own contract comment at `:230-231` states. A version string placed in that variable is
  not a path, so the stage would exit 0 having executed no test. Three steps, in order:

  1. Run `npx --yes bats --version` and record its output as `ResolvedBatsVersion:`. This
     both confirms availability and populates the npx cache the next step reads.
  2. Resolve the path with `npm exec --yes --package=bats -- bash -c 'command -v bats'`,
     which runs `command -v` with the package's `.bin` directory on `PATH` and therefore
     prints the absolute path of the extensionless bats shim. Record its single line of
     stdout as `ResolvedBatsPath:`.
  3. Verify the resolved path independently, before it is used: run `test -x` on it and
     record the exit code as `ResolvedBatsExecutable:`, and run the path itself with
     `--version` and record that output as `ResolvedBatsPathVersion:`.

  Then run the stage as
  `env SHELL_QC_BATS_BIN=<the ResolvedBatsPath value> bash scripts/bash/shell-qc.sh test`,
  capturing combined stdout and stderr. Record
  `evidence/remediation-baseline/shell-qc-test.2026-09-09T00-00.md` with `Timestamp:`, every
  `Command:` above, `EXIT_CODE:` for the stage, `ResolvedBatsVersion:`, `ResolvedBatsPath:`,
  `ResolvedBatsExecutable:`, `ResolvedBatsPathVersion:`, `TapPlanLine:` carrying the first
  line of the captured stream verbatim, the count of lines beginning `ok`, the count of
  lines beginning `not ok`, and a field `BaselineLocalTestTotal:` carrying the `ok` count.
  A single plan line is expected because `find_bats_test_dirs`
  (`scripts/bash/shell_qc_lib.sh:104-120`) resolves only `tests/shell` in this tree —
  `tests/bash` does not exist — so bats is invoked once rather than once per directory.
  Acceptance: `ResolvedBatsPath:` is a single absolute path, `ResolvedBatsExecutable:` is
  `0`, and `ResolvedBatsPathVersion:` equals `ResolvedBatsVersion:`; the captured combined
  output does **not** contain the literal `bats not installed; skipping shell tests.`;
  `TapPlanLine:` matches the extended regular expression `^1\.\.[1-9][0-9]*$`, so the plan
  line names at least one test; `EXIT_CODE:` is `0`; the `not ok` count is `0`; and
  `BaselineLocalTestTotal:` equals the number after `1..` in `TapPlanLine:` and is the value
  P5-T3 compares against. If step 2 prints no path, or if any of the three resolution
  acceptance conditions fails, the executor stops and reports rather than running the stage,
  because the alternative outcome is a gate that passes with zero tests executed.

- [x] [P0-T5] Record the coverage baseline from the last successful CI coverage run rather
  than from any local invocation. Write
  `evidence/remediation-baseline/shell-coverage.2026-09-09T00-00.md` carrying `Timestamp:`,
  `Command:` naming the `gh` reads used, `EXIT_CODE:`, `BaselineRepoLineCoverage: 93.69`,
  `BaselineDirtLibLineCoverage: 94.12`, `Threshold: 85.0`, the run id `34229386300`, and a
  per-file table for the eight files matching `scripts/bash/cleanup[-_]worktrees*` with
  their current percentages. The eight are `cleanup-worktrees.sh`,
  `cleanup_worktrees_actions_lib.sh`, `cleanup_worktrees_detached_lib.sh`,
  `cleanup_worktrees_dirt_lib.sh`, `cleanup_worktrees_enumerate_lib.sh`,
  `cleanup_worktrees_lib.sh`, `cleanup_worktrees_report_records_lib.sh`,
  `cleanup_worktrees_scan_helper.sh`. Acceptance: both headline numeric fields are present
  as numbers, the table has exactly eight rows and names all eight files above, and the
  artifact states explicitly that `kcov` has no local route in this worktree and that
  `bash scripts/bash/shell-qc.sh test --coverage` exits 127 here.

- [x] [P0-T6] Measure the guard inventory in the classifier library. Run
  `grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  for the arithmetic count, `grep -cE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  for the marked count, and
  `grep -vc '^#' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` for the registry
  row count. Record all three in
  `evidence/remediation-baseline/guard-enumeration.2026-09-09T00-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the arithmetic count is
  `31`, the marked count is `37`, the registry row count is `39`, and the artifact states
  the derived end-state targets **33 arithmetic lines, 40 marker lines, 42 registry rows,
  40 distinct ids** together with the arithmetic that produces each.

- [x] [P0-T7] Record the current registry kind distribution, which is what makes D4's
  raised floor satisfiable. Run
  `awk -F'\t' '!/^#/ && NF {print $2}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort | uniq -c`
  and
  `awk -F'\t' '!/^#/ && NF && $2=="SEPARATED" {print $1}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort -u`.
  Record `evidence/remediation-baseline/registry-kind-distribution.2026-09-09T00-00.md`
  with `Timestamp:`, `Command:` for both, `EXIT_CODE:`, and `Output Summary:` carrying both
  outputs verbatim, plus a field `IdsWithNoSeparatedRow:` listing every distinct registry
  id absent from the second command's output. Acceptance: the kind tally records `37`
  `SEPARATED` and `2` `ARGV` and no third kind; and `IdsWithNoSeparatedRow:` names exactly
  one id, `history-scan-bounded-range`.

- [x] [P0-T8] Measure the current line count of every file this cycle may touch with
  `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  and record it in
  `evidence/remediation-baseline/file-size-limit.2026-09-09T00-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the per-file counts, and the headroom to 500 for each. The same
  artifact also records `StubDigest:`, the `md5sum` of
  `tests/fixtures/cleanup_worktrees/stub-bin/git`, which P5-T5 compares against to show
  this cycle added no stub arm. Acceptance:
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` is recorded as `481`,
  `scripts/bash/cleanup_worktrees_lib.sh` as `496`,
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` as `452`, `StubDigest:` is
  present and non-empty, and the artifact states the remaining headroom to 500 for each
  file.

- [x] [P0-T9] Measure the current scenario, record and criterion counts. Run
  `find tests/fixtures/cleanup_worktrees/scenarios -maxdepth 1 -type d -name 'dirt_*' | wc -l`,
  read the literal at `tests/shell/test_cleanup_worktrees_dirt_classify.bats:253`, and run
  the section-scoped criterion derivation

  ```
  awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['
  ```

  together with the same `awk` prefix piped to `grep -c '^- \[x\]'` and to
  `grep -c '^- \[ \]'`. Record
  `evidence/remediation-baseline/scenario-and-criterion-counts.2026-09-09T00-00.md` with
  `Timestamp:`, every `Command:`, `EXIT_CODE:`, `OnDiskScenarioCount:`,
  `AssertedRecordTotal:`, `SectionScopedCriterionTotal:`, `SectionScopedChecked:`, and
  `SectionScopedUnchecked:`, plus a fourth count field carrying the unscoped
  `grep -c '^- \['` figure alongside a statement that it is not the criterion count and
  why. Acceptance: `OnDiskScenarioCount:` is `28`, `AssertedRecordTotal:` is `34`,
  `SectionScopedCriterionTotal:` is `47`, `SectionScopedChecked:` is `47`,
  `SectionScopedUnchecked:` is `0`, and the unscoped figure is recorded as `55`.

- [x] [P0-T10] `[expect-fail]` Run
  `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  and record `evidence/remediation-baseline/pytest-push-down-contract.2026-09-09T00-00.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and `Output Summary:`
  reproducing the summary line and the assertion message. This gate is expected to fail on
  the pre-existing gitignored-state defect, issue #510, which is green in CI and is not
  attributable to this branch; the caller's adjudication forbids planning work to close it,
  so it is recorded as an expected non-zero exit rather than left unchecked. Acceptance:
  `EXIT_CODE:` is `1`, `ExpectedExitCode:` is `1`, `Output Summary:` contains the literal
  `1 failed, 10 passed`, and the artifact names issue `#510` and states that the half of
  the contract this feature owns is the `SKILL.md` mirror parity, which P4-T7 checks
  separately.

---

### Phase 1 — The N3 fixture, the failing tests, and the fail-before record

- [x] [P1-T1] Create the scenario directory
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_index_and_worktree_delta/` and copy into
  it, verbatim, the six non-classifier fixture files named in D2 from
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/`: `worktree-list.out`,
  `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`,
  `merge-base.feature-dirt.rc`, `worktree-remove.rc`. Acceptance: for each of the six
  filenames, `cmp -s` between the `dirt_unique` copy and the new copy exits `0`, and
  `git status --porcelain --untracked-files=all tests/fixtures/cleanup_worktrees/scenarios/dirt_index_and_worktree_delta`
  lists the new directory as untracked.

- [x] [P1-T2] Write the twelve classifier fixture files for
  `dirt_index_and_worktree_delta` exactly as tabulated in D2:
  `status._repo-wt_dirt.out`, `diff-quiet..src_a.cs.rc`,
  `rev-parse.verify.main_src_a.cs.rc`, `hash-object.src_a.cs.out`,
  `diff-quiet..src_b.cs.rc`, `hash-object.src_b.cs.out`,
  `log.find-object.bbbb1111.out`, `diff-quiet..src_c.cs.rc`,
  `rev-parse.verify.main_src_c.cs.rc`, `hash-object.src_c.cs.out`,
  `diff-quiet..docs_tracked.md.rc`, and `rev-parse.verify.main_docs_tracked.md.rc`.
  Acceptance: `status._repo-wt_dirt.out` has exactly four lines and its four lines are, in
  order, `MM src/a.cs`, `MM src/b.cs`, `UU src/c.cs`, and `M  docs/tracked.md`; the five
  `.rc` files `diff-quiet..src_a.cs.rc`, `rev-parse.verify.main_src_a.cs.rc`,
  `diff-quiet..src_b.cs.rc`, `diff-quiet..src_c.cs.rc`,
  `rev-parse.verify.main_src_c.cs.rc` contain `0`, `0`, `1`, `0`, `0` respectively; the two
  remaining `.rc` files `diff-quiet..docs_tracked.md.rc` and
  `rev-parse.verify.main_docs_tracked.md.rc` both contain `0`; and the four `.out` files
  contain `aaaa1111`, `bbbb1111`, `cccc1111`, and `ffff3333` respectively for
  `hash-object.src_a.cs.out`, `hash-object.src_b.cs.out`, `hash-object.src_c.cs.out`, and
  `log.find-object.bbbb1111.out`.

- [x] [P1-T3] Update the membership test in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats` in this same task: add
  `dirt_index_and_worktree_delta` to the explicit scenario list at `:220-231`, change the
  asserted record literal at `:253` from `34` to `38`, and update the explanatory comment
  at `:250-252` so it reads as twenty-nine scenarios producing thirty-eight records, of
  which six carry two status entries each and one carries four. Acceptance:
  `grep -cF 'dirt_index_and_worktree_delta' tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  reports `1`; `grep -cF '"$seen" -eq 38' tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  reports `1`; `grep -cF '"$seen" -eq 34' tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  reports `0`; and
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  exits `0` with zero lines beginning `not ok`. That suite passes here because the record
  **count** is 38 both before and after the D1 fix and the pre-fix verdicts are still
  members of the six defined tokens; only the verdicts change, and this test asserts
  membership and counts rather than particular verdicts.

- [x] [P1-T4] Add four tests to
  `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`, driving
  `classify_worktree_dirt` through the existing `dirt` helper at that file's `:41-44`. The
  titles are fixed here so the later TAP searches have exact targets:

  1. `dirt_index_and_worktree_delta: an MM entry whose working-tree content is on main is UNIQUE`
     — asserts the record `DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs`, the record
     `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and the absence of both
     `CONTENT_ON_MAIN||MM|src/a.cs` and `ALL_DISPOSABLE`.
  2. `dirt_index_and_worktree_delta: an MM entry whose working-tree blob is in history is UNIQUE`
     — asserts `DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/b.cs` and the absence of
     `CONTENT_IN_HISTORY|ffff3333|MM|src/b.cs`.
  3. `dirt_index_and_worktree_delta: a UU entry whose working-tree content is on main is UNIQUE`
     — asserts `DIRTFILE|/repo-wt/dirt|UNIQUE||UU|src/c.cs` and the absence of
     `CONTENT_ON_MAIN||UU|src/c.cs`.
  4. `dirt_index_and_worktree_delta: the M-space control entry in the same fixture is still CONTENT_ON_MAIN`
     — asserts `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md`.

  Test 4 is the direction that rejects a "fix" that simply disables rungs 4 and 5, and it
  shares the fixture with tests 1 through 3 so one status read serves both directions.
  Each of the three negative assertions is paired with a positive record assertion in the
  same test, so none of them can pass in a build where no classification ran. Acceptance:
  each of the four `@test` titles above appears exactly once in that file, checked with
  `grep -cF` on each title.

- [x] [P1-T5] Create `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
  implementing exactly the two tests specified in D5, with a header stating the subject
  (the missing-comparison defect family: R1, N1 and N3), the mechanism, the two excluded
  verdicts and why each is excluded, and the statement that no temporary file is created.
  The two `@test` titles are fixed here:

  1. `every disposable verdict is backed by a git read of every location holding that entry's content`
  2. `every classifier-relevant status-code class is covered by a checked-in dirt scenario`

  The suite sources `scripts/bash/cleanup_worktrees_enumerate_lib.sh`,
  `scripts/bash/cleanup_worktrees_lib.sh` and
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` from disk in that order, binds the worktree
  path to the literal `/repo-wt/dirt`, discovers scenarios with
  `find "${SCEN}" -maxdepth 1 -type d -name 'dirt_*'` rather than from a written list, and
  captures the record stream and the stub argv log into separate variables. Acceptance:
  both `@test` titles appear exactly once, checked with `grep -cF` on each;
  `grep -cE 'mktemp|BATS_TMPDIR|TMPDIR|mkdir -p' tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
  reports `0`; `grep -cF 'DISPOSABLE_SESSION_ARTIFACT' tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
  reports at least `1`, which is the exclusion being written into the suite rather than
  left implicit; and `wc -l` on the file reports at most `300`.

- [x] [P1-T6] `[expect-fail]` Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
  before any library change and record
  `evidence/regression-testing/fail-before-index-blob-unaccounted.2026-09-09T00-30.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, the TAP plan line,
  and the verbatim TAP lines for the six tests P1-T4 and P1-T5 added. The artifact also
  records, verbatim, the five-line record stream `classify_worktree_dirt /repo-wt/dirt`
  emits under `dirt_index_and_worktree_delta` before the fix, obtained through the same
  seam, so the data-loss verdicts are on the record rather than described. Acceptance:
  the output contains a line beginning `not ok` whose text ends with each of these four
  titles —
  `dirt_index_and_worktree_delta: an MM entry whose working-tree content is on main is UNIQUE`,
  `dirt_index_and_worktree_delta: an MM entry whose working-tree blob is in history is UNIQUE`,
  `dirt_index_and_worktree_delta: a UU entry whose working-tree content is on main is UNIQUE`,
  and `every disposable verdict is backed by a git read of every location holding that entry's content`;
  it contains a line beginning `ok ` whose text ends with
  `dirt_index_and_worktree_delta: the M-space control entry in the same fixture is still CONTENT_ON_MAIN`,
  which proves the fixture drives the ladder rather than failing to load; it contains a
  line beginning `ok ` whose text ends with
  `every classifier-relevant status-code class is covered by a checked-in dirt scenario`,
  which proves the coverage floor is already satisfied and that the accounting failure is
  not a fixture-availability artefact; and the recorded pre-fix record stream contains the
  literal `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333`.

---

### Phase 2 — The N3 library fix, its markers, and its registry rows

- [x] [P2-T1] Apply decision D1 to `scripts/bash/cleanup_worktrees_dirt_lib.sh`. Add
  `bothloc=0` to the existing `local` declaration at `:241`; insert the three-line
  `bothloc` block of D1 part one immediately after the untracked test at `:287`, with its
  code line written exactly as quoted in D1; nest the rung-4 positive emission inside
  `if ((bothloc == 0)); then # guard:rung4-index-blob-unaccounted`; and nest the rung-5
  positive emission inside `if ((bothloc == 0)); then # guard:rung5-index-blob-unaccounted`.
  All three new guard-shaped lines carry their markers in this same task, so the tree never
  holds an unmarked guard. The four literals this task creates, quoted here verbatim so the
  searches below have defined targets: `bothloc=1`, `# guard:index-and-worktree-both-hold-content`,
  `# guard:rung4-index-blob-unaccounted`, and `# guard:rung5-index-blob-unaccounted`.
  Acceptance, all against `scripts/bash/cleanup_worktrees_dirt_lib.sh`:
  `grep -cF 'bothloc=1'` reports `1`;
  `grep -cF '# guard:index-and-worktree-both-hold-content'` reports `1`;
  `grep -cF '# guard:rung4-index-blob-unaccounted'` reports `1`;
  `grep -cF '# guard:rung5-index-blob-unaccounted'` reports `1`;
  `grep -cF '((bothloc == 0))'` reports `2`;
  `grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)'` reports `33`;
  `grep -cE '# guard:[a-z0-9-]+$'` reports `40`; and the prefix check

  ```
  grep -oE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh | cut -d: -f2 | LC_ALL=C sort -u | awk 'NR>1 && index($0,p)==1 {print p" "$0} {p=$0}'
  ```

  produces no output. That check is load-bearing rather than stylistic: the registry's
  `sed` address is `/# guard:<id>$/`, and an id that is a prefix of another id would still
  address one line only under the `$` anchor, but a future id added without the anchor
  would mutate two guards under one row. `LC_ALL=C` on the `sort` is what makes adjacency
  sufficient, because a punctuation-folding collation can place a non-prefix id between the
  two members of a prefix pair.

- [x] [P2-T2] Extend the library header with the `INDEX AND WORKING TREE ARE TWO LOCATIONS`
  paragraph, placed after the `EMPTY PATHSPEC IS NOT A MATCH` paragraph that ends at `:56`,
  in the same register and layout as the existing `TWO-WAY CLASSIFICATION OF NON-ZERO EXITS`
  (`:40-46`) and `NO --ignored ON THE STATUS READ` (`:29-33`) paragraphs. Following the
  file's convention the paragraph opens with an all-capital heading sentence, and this plan
  fixes that heading verbatim as `INDEX AND WORKING TREE ARE TWO LOCATIONS.` so the
  acceptance search has a short single-line target that cannot be split by rewrapping. The
  paragraph states: which letters are content-bearing and why — written as the literal
  `M, A, R, C, T, U` so the list is legible in prose rather than as a bracket expression;
  that two
  content-bearing columns mean two distinct blobs; that rung 4's tracked half and rung 5
  read only the working-tree blob; that both therefore fail closed for such an entry; and
  that rung 3 is not gated because `dirt_is_build_artifact` reads the cached diff as well
  as the worktree diff. In the same task, amend the rung-1 comment block at `:262-269` so
  its sentence about falling through to the working-tree rungs points at the new paragraph
  rather than ending at the unstaged delta. The paragraph including its blank separator is
  bounded at six lines. Acceptance:
  `grep -cF 'INDEX AND WORKING TREE ARE TWO LOCATIONS.' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  reports `1`;
  `grep -cF '$x == [MARCTU] && $y == [MARCTU]' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  reports `1`, which is a line count and not an occurrence count — both bracket expressions
  sit on the single guard line P2-T1 added, so the expected value is one line and not two;
  and `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh`
  reports a value at or below `497`, with the artifact in P2-T7 recording the exact count
  and its delta from the `481` P0-T8 recorded.

- [x] [P2-T3] Re-run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
  and record
  `evidence/regression-testing/pass-after-index-blob-unaccounted.2026-09-09T01-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the TAP plan line, and the `ok`/`not ok` counts.
  The artifact also records, verbatim, the five-line record stream
  `classify_worktree_dirt /repo-wt/dirt` now emits under `dirt_index_and_worktree_delta`,
  for direct comparison with the pre-fix stream P1-T6 recorded. The registry suite is
  deliberately **not** included in this command: its Invariant 2 fails until P2-T4 adds the
  three rows, and including it here would make this task's acceptance unsatisfiable.
  Acceptance: `EXIT_CODE:` is `0`; the `not ok` count is `0`; the output contains a line
  beginning `ok ` whose text ends with
  `dirt_index_and_worktree_delta: an MM entry whose working-tree content is on main is UNIQUE`;
  and the recorded post-fix record stream contains the literal
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|` and does not contain the literal `ALL_DISPOSABLE`.

- [x] [P2-T4] Append the three rows tabulated in D3 to
  `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`, tab-separated in the existing
  column order `id`, `kind`, `scenario`, `baseline_aggregate`, `mutation`, `reason`, with
  `reason` left empty for all three because all three are `SEPARATED`. The
  `index-and-worktree-both-hold-content` row's `mutation` value is copied verbatim from the
  D3 table cell, which is the authoritative spelling: it carries `\[` and `\]` as genuine
  `sed` escapes and carries no `|`, so no Markdown unescaping applies to it. Acceptance:
  `grep -vc '^#' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` reports `42`;
  `grep -c '^$' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` reports `0`;
  `grep -cF 'index-and-worktree-both-hold-content' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
  reports `1`; `grep -cF 'rung4-index-blob-unaccounted' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
  reports `1`; `grep -cF 'rung5-index-blob-unaccounted' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
  reports `1`; and
  `awk -F'\t' '!/^#/ && NF && $3=="dirt_index_and_worktree_delta"' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | wc -l`
  reports `3`.

- [x] [P2-T5] Add `index-and-worktree-both-hold-content` to the `LIT_IDS` array and its
  mutation to the `LIT_MUTS` array in
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:157-176`, at the **same
  index** in both arrays, taking each array from eight elements to nine. Invariant 6 pairs
  the two arrays by index, so a mismatch between the two positions registers the wrong
  pair. Extend the comment above `LIT_IDS` with one sentence naming the new guard as the
  fail-closed test that N3 adds. Acceptance:
  `grep -cF 'index-and-worktree-both-hold-content' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports `1`, and
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  exits `0` with zero lines beginning `not ok`, which is the check that the ninth literal
  matches the source line character for character — Invariant 6 fails when it does not, and
  Obligation 2 fails when the substitution does not change the line.

- [x] [P2-T6] Run the six dirt suites together to establish that Phase 2 left the tree
  consistent — `classify`, `failclosed`, `clear`, `regression`, `guard_registry` and the
  `content_locations` suite P1-T5 creates:
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`.
  Record `evidence/regression-testing/phase2-sibling-check.2026-09-09T01-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the TAP plan line, and the `ok`/`not ok` counts.
  The artifact must additionally state, as a separate finding with its supporting
  observation, that `dirt_staged_tree_worktree_delta`'s `MM src/a.cs` entry is unchanged by
  this phase: it records that scenario's `diff-quiet..src_a.cs.rc` value, the entry's
  verdict before and after, and whether the scenario's stub argv log differs. This is the
  sibling that D1 identifies as the one at risk, because the registry's
  `hash-object-hard-fail` literal row is keyed to it and would go inert if that entry
  stopped reaching the `hash-object` read. Acceptance: `EXIT_CODE:` is `0`; the `not ok`
  count is `0`; the artifact records `diff-quiet..src_a.cs.rc` as `1`; it records the
  entry's verdict as `UNIQUE` both before and after; and it states explicitly that the
  scenario's argv log is unchanged.

- [x] [P2-T7] Record the file-size position after the library change. Run
  `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh`
  and write `evidence/qa-gates/file-size-after-fix.2026-09-09T01-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, both counts, the delta of the classifier library from the `481`
  P0-T8 recorded, and the remaining headroom to 500. Acceptance: the classifier library's
  count is at or below `497`; `scripts/bash/cleanup_worktrees_lib.sh` is recorded as `496`,
  unchanged, which is the observation that this cycle did not touch the excluded file; and
  the artifact states the delta as a number. If the classifier library exceeds 497 the
  executor stops here and reports the overage together with the extraction target this plan
  names, rather than compressing the header paragraph.

---

### Phase 3 — N4: the `EXEMPT` kind is removed and the pin floor is raised

- [x] [P3-T1] Apply edits 1, 1b and 2 of D4 to
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`: delete the `EXEMPT)` arm
  of Obligation 5; narrow Invariant 2's kind list at `:198`, which reads
  `if [ "$(pin_count "$id" any 'SEPARATED ARGV EXEMPT')" -eq 0 ]; then`, by changing its
  third argument to `'SEPARATED ARGV'`; delete Obligation 6 in full; delete the
  `sibling_mutation` helper; and delete the `EXEMPT_SIBLING_DIFFERED` local, its `echo`, and
  its assertion. The `:198` edit is enumerated explicitly because it is the one occurrence
  of the deleted kind that no other instruction in this task reaches. The token appears on
  eleven lines of the file today — `:33`, `:198`, `:269`, `:350`, `:362`, `:364`, `:365`,
  `:371`, `:384`, `:385` and `:393` — and every one of those except `:198` is inside the
  `OBSERVATION CHANNEL` paragraph this task rewrites, the `EXEMPT_SIBLING_DIFFERED` local
  and its two uses, the Obligation 5 arm, or Obligation 6. Without the `:198` edit the
  `grep -cF 'EXEMPT'`-reports-`0` acceptance below is unsatisfiable. Rewrite the
  `OBSERVATION CHANNEL` paragraph of the file header so it describes two kinds rather than
  three and states the reason for the removal: a row must show an observed difference on
  one of the two channels, and an observed difference is only possible if the guard
  executed, so a scenario under which the ladder never reaches the guard is a way to fail
  rather than a way to pass. The header must not use the uppercase token that names the
  deleted kind, so the acceptance search below is exact. Acceptance:
  `grep -cF 'EXEMPT' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` reports
  `0`; `grep -cF 'RECORDS-AND-ARGV-IDENTICAL' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports `0`; `grep -cF 'sibling_mutation' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports `0`; and `grep -cF 'OBLIGATION-6' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports `0`.

- [x] [P3-T2] Apply edit 3 of D4: add Invariant 8 to the first test — a `badkind`
  accumulator recording every registry row whose `kind` is neither `SEPARATED` nor `ARGV`,
  printed to stderr as `INVARIANT-8 inadmissible kind:` followed by the offending ids, and
  asserted empty alongside the seven existing invariant assertions. The comment at its site
  states why it is not redundant with Obligation 5's default arm: Obligation 5 is evaluated
  only for rows that pass Obligation 1, so a row naming a nonexistent scenario would
  otherwise carry an inadmissible kind unreported. Acceptance:
  `grep -cF 'INVARIANT-8 inadmissible kind:' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports `1`, and
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  exits `0` with zero lines beginning `not ok`.

- [x] [P3-T3] Apply edits 4 and 5 of D4: replace Groups A and B of the third test with a
  floor over every marker id, keep Group C unchanged, and change the test title to
  `every marker id is pinned by kind and the two dual-row lines are pinned by pair`. The
  floor reads the id set from the library's markers with the same
  `grep -oE '# guard:[a-z0-9-]+$' | cut -d: -f2` derivation the first test uses, never from
  a list written into the test, and requires for each id at least one registry row of kind
  `SEPARATED`, except for ids in the hard-coded `ARGV_ONLY_IDS` array, for which at least
  one row of kind `ARGV` is required instead. `ARGV_ONLY_IDS` has exactly one member,
  `history-scan-bounded-range`, and the comment at its site states the reason recorded in
  D4. Unsatisfied entries accumulate into the existing `missing` variable and are printed
  as `PINS NOT SATISFIED:`.

  In the same task, correct the four comment counts that P2-T5 made stale by taking
  `LIT_IDS` and `LIT_MUTS` from eight elements to nine. Their pre-Phase-3 line numbers are
  `:153`, `:220`, `:231` and `:438`, and they are named by their text as well, because
  P3-T1's deletions shift every number after `:119`: the `LIT_IDS` preamble beginning `The
  eight named non-arithmetic verdict guards`, Invariant 6's `each of the eight named
  non-arithmetic (id, mutation) pairs is registered`, Invariant 7's `every row's mutation is
  one of the eight literals`, and Group C's `every one of the eight fixed literals begins`.
  Each `eight` becomes `nine`. This correction is placed here rather than in P2-T5 because
  the acceptance below is a whole-file count, and it can only reach zero once P3-T1 has
  deleted the `sibling_mutation` helper — whose comment at `:121` also reads `eight` — and
  this task's own rename has removed `eighteen` from the third test's title. Acceptance:
  `grep -ci 'eight' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` reports
  `0`, which today reports `6` for the lines `:121`, `:153`, `:220`, `:231`, `:396` and
  `:438`, so it is a condition that can fail;
  `grep -cF 'ARGV_ONLY_IDS' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports at least `2`, being the array declaration and its use;
  `grep -cF 'every marker id is pinned by kind and the two dual-row lines are pinned by pair' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports `1`;
  `grep -cF 'the eighteen pinned guard rows carry the registry kinds this plan fixes' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports `0`; and
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  exits `0` with zero lines beginning `not ok` and a TAP plan line of `1..3`.

- [x] [P3-T4] `[expect-fail]` Demonstrate that the strengthened gate rejects the artefact
  the reaudit built, rather than asserting that it would. The suite binds `REGISTRY` in
  `setup()` with no environment override
  (`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:47`), so the probe is run
  by editing the tracked registry in place and then undoing that one edit in place, which
  creates no temporary file and adds no override seam to the gate.

  **The restore is an inverse row rewrite, not `git checkout --`.** No task before this one
  stages anything: `git add -A` first appears in P5-T7. The index therefore still holds the
  pre-P2-T4 version of the registry, and `git checkout -- <path>` restores from the index,
  so it would silently discard the three rows P2-T4 appended. Step 4 would then re-run the
  registry suite against a 39-row registry whose three new marker ids have no row, Invariant
  2 would fail, and step 4's exit-0 acceptance would be unsatisfiable. In sequence:

  1. Replace the `staged-probe-skip-head` row of
     `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` with the row the reaudit
     demonstrated — id `staged-probe-skip-head`, kind `EXEMPT`, scenario `dirt_unique`,
     baseline aggregate `HAS_UNIQUE`, mutation `s/((first == 1))/((0))/`, and a `reason`
     beginning with the token `RECORDS-AND-ARGV-IDENTICAL:` — leaving every other row
     untouched.
  2. Run `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
     and capture its combined stdout and stderr.
  3. Undo step 1 by the inverse row rewrite, using the same in-place write mechanism step 1
     used, so that the `staged-probe-skip-head` row returns to the exact six-field,
     tab-separated form it carries in the tree today and every other row stays untouched.
     The restore target is quoted here verbatim so the comparison has a defined target; the
     six fields are `id`, `kind`, `scenario`, `baseline_aggregate`, `mutation`, `reason`,
     the sixth is empty, and the line ends with the tab that precedes it:

     ```
     staged-probe-skip-head	SEPARATED	dirt_staged_tree_is_commit	ALL_DISPOSABLE	s/((first == 1))/((1))/	
     ```

  4. Re-run the same bats command to confirm the restoration.

  Record `evidence/regression-testing/n4-parked-row-rejected.2026-09-09T01-30.md` with
  `Timestamp:`, the four `Command:` values, `EXIT_CODE:` for each, `ExpectedExitCode: 1`
  for step 2, the verbatim stderr the suite printed in step 2, and — taken after step 3 —
  the verbatim output of
  `awk -F'\t' '$1=="staged-probe-skip-head"' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`,
  the value of `grep -vc '^#' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`, and
  the value of `grep -cF 'EXEMPT' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`.
  Acceptance: step 2's exit code is `1`; step 2's recorded stderr contains each of the three
  literals `INVARIANT-8 inadmissible kind:`, `OBLIGATION-5 channel comparison failed:` and
  `PINS NOT SATISFIED:`; after step 3 the recorded `awk` output is exactly one line and
  reproduces the row quoted above field for field, the recorded `grep -vc '^#'` value is
  `42` — 39 data rows at cycle start plus the three P2-T4 appended — and the recorded
  `grep -cF 'EXEMPT'` value is `0`; step 4's exit code is `0` with zero lines beginning
  `not ok`; and the artifact
  states that the identical variant registry passed all three tests before this phase,
  citing `code-review.2026-09-08T23-30.md` Part 3 as the source of the variant. This is the
  discrimination probe for N4's fix: without it the strengthened gate is only known to pass
  on a tree that already satisfies it.

- [x] [P3-T5] Record the end-state registry position. Run the two commands P0-T7 used and
  write `evidence/qa-gates/registry-kind-distribution.2026-09-09T01-30.md` with
  `Timestamp:`, both `Command:` values, `EXIT_CODE:`, `Output Summary:` carrying both
  outputs verbatim, `IdsWithNoSeparatedRow:`, and a `MarkerIdCount:` field carrying
  `grep -oE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh | sort -u | wc -l`.
  Acceptance: the kind tally records `40` `SEPARATED` and `2` `ARGV` and no third kind;
  `IdsWithNoSeparatedRow:` names exactly one id, `history-scan-bounded-range`; and
  `MarkerIdCount:` is `40`, equal to the distinct-id count D3 derives.

---

### Phase 4 — Acceptance criteria, documentation, mirror, and the P2 correction

- [x] [P4-T1] Correct AC-8's count phrase in
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`. The
  phrase sits at `spec.md:714`, reading `by any of the twenty-eight \`dirt_*\` scenarios.`;
  the word `twenty-eight` becomes `twenty-nine`. The box stays checked; this is a text
  correction to a criterion the code already satisfies. Because the phrase sits in a
  rewrapped prose block, both acceptance searches run over an unwrapped stream:

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -cF 'twenty-nine `dirt_*` scenarios'
  ```

  Acceptance: that command reports `1`, and the same unwrapped stream piped to
  `grep -cF 'twenty-eight `dirt_*` scenarios'` reports `0`.

- [x] [P4-T2] Edit AC-47 in place at `spec.md:856-891`, leaving its box checked. Three
  groups of edit, all inside that criterion.

  *Group one — delete every clause describing the deleted kind.* The `EXEMPT` disjunct in
  the three-kinds sentence, the sibling-constant qualifier, and the whole sentence beginning
  `EXEMPT is scenario-scoped`. Also delete the trailing clause `rather than recorded as an
  exempt guard` at `:866`, which is the file's one lowercase occurrence of the token and is
  invisible to a case-sensitive search. That clause's host sentence states a property the
  gate still has — Obligation 2 still rejects a mutation that edits only a comment or only
  whitespace — so the sentence is trimmed to end after `is rejected by the suite` rather
  than removed.

  *Group two — correct the two counts this cycle falsifies.* D3 and P2-T5 take the literal
  arrays from eight entries to nine. `spec.md:858` reads `the eight named non-arithmetic
  verdict guards` and `:864` reads `the eight non-arithmetic mutations`; both become `nine`.
  Add the new guard to the enumerated list that follows `:858`, which today names eight
  sites; the ninth item is written as the two-content-bearing-columns fail-closed test,
  registered as `index-and-worktree-both-hold-content`, so the list carries that id
  verbatim. Leaving either count would leave a checked criterion asserting a number this
  cycle falsifies, which is the same failure mode this task exists to remove for the
  `EXEMPT` token, in a criterion the exit audit re-evaluates.

  *Group three — repoint the pin sentence.* Replace the sentence that states `Eighteen
  registry rows over seventeen distinct ids are pinned by kind` at `:883` with a sentence
  stating that the pin floor is specified by AC-49, and keep the pair-keyed-pin sentence at
  `:887-890` and the closing failure sentence at `:890-891` unchanged. The edited criterion
  must state that a registry row's kind is `SEPARATED` or `ARGV` and that no other kind is
  admissible.

  Acceptance. The unwrapped stream referred to below is

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md
  ```

  Then: `grep -ci 'exempt' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `0`. That search is case-insensitive rather than case-sensitive, and it is exact:
  the token occurs case-insensitively on four lines of the file today — `:866` in lowercase
  and `:876`, `:878`, `:879` in uppercase — and all four are inside AC-47, re-derived
  against the current tree in this pass. The unwrapped stream piped to
  `grep -cF 'the nine named non-arithmetic verdict guards'` reports `1`; to
  `grep -cF 'the eight named non-arithmetic verdict guards'` reports `0`; to
  `grep -cF 'the nine non-arithmetic mutations'` reports `1`; to
  `grep -cF 'the eight non-arithmetic mutations'` reports `0`; to
  `grep -cF 'index-and-worktree-both-hold-content'` reports at least `1`; and to
  `grep -cF 'Eighteen registry rows over seventeen distinct ids'` reports `0`. Finally
  `grep -c '^- \[x\] AC-47 —' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `1`, which is the check that the box was not disturbed. The two `nine` searches
  are stated as positives as well as negatives so the task cannot be discharged by deleting
  the phrases instead of correcting them. All three positive literals —
  `the nine named non-arithmetic verdict guards`, `the nine non-arithmetic mutations` and
  `index-and-worktree-both-hold-content` — occur **zero** times in `spec.md` today,
  re-derived against the current tree in this pass, so each of them can fail.

- [x] [P4-T3] Append AC-48 to the `## Acceptance Criteria` section of `spec.md` as an
  **unchecked** box. Its text states, without claiming more than the delivery establishes:
  that when a status entry's X column and Y column both carry a content-bearing letter —
  `M`, `A`, `R`, `C`, `T` or `U` — the entry's content exists in the index and in the
  working tree and the two differ, so rung 4's tracked half and rung 5, which compare only
  working-tree content, do not resolve a disposable verdict for it and the entry falls to
  `UNIQUE`; that `AD` and `MD` are unaffected because a `D` in the Y column means the
  working tree holds no content; that rung 3 is unaffected because `dirt_is_build_artifact`
  reads the cached diff as well as the worktree diff; that both directions are pinned by a
  single checked-in fixture, `dirt_index_and_worktree_delta`, carrying an `MM` entry
  decided at rung 4, an `MM` entry decided at rung 5, a `UU` entry, and a control entry
  that must still resolve `CONTENT_ON_MAIN`; and that
  `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats` additionally requires,
  for every `DIRTFILE|` record whose verdict is neither `UNIQUE` nor
  `DISPOSABLE_SESSION_ARTIFACT` across every checked-in `dirt_*` scenario, that the stub
  argv log carry a read of every location holding that entry's content, and requires each
  of the eight status codes `??`, `M `, `A `, `R `, ` M`, `AD`, `MM` and `UU` to appear in
  some checked-in scenario. The criterion must also state the **strength of the letter
  pin**, so it does not read as a per-letter executed claim. Exactly three of the letter
  decisions carry an executed direction: `M` in the both-columns position by P1-T4 tests 1
  and 2, `U` by test 3, and the exclusion of the space by test 4, whose `M ` control must
  still resolve `CONTENT_ON_MAIN` and would resolve `UNIQUE` if the space were admitted to
  the class. Every other letter decision — the inclusion of `A`, `R`, `C` and `T`, and the
  exclusion of `D`, `?` and `!` — is held only by the character class `[MARCTU]` on the
  single guard line, which is asserted literally by the registry's
  `index-and-worktree-both-hold-content` row and by P2-T2's acceptance search. No
  checked-in test drives any of those in the both-columns position, so changing any one of
  them would leave every test green. The `D` case is the one worth stating explicitly,
  because it is easy to assume `dirt_tracked_staged_only_blob` pins it and it does not: that
  scenario's `AD` entry already resolves `UNIQUE` through N1's `((erc == 0))` guard, since
  its `rev-parse.verify.main_staged_only.md.rc` fixture holds `1` and the path is therefore
  absent from `main`, so admitting `D` to the class would block a branch that entry never
  takes and no assertion would move. The criterion must state the two exclusions and their
  reasons:
  `UNIQUE` is the fail-closed direction and asserts nothing about recoverability, and
  `DISPOSABLE_SESSION_ARTIFACT` is an exact-path authorization that issues no git call and
  makes no content inference. It must also state the bound on the coverage floor: it covers
  the classes the classifier's own branching distinguishes and does not enumerate every
  porcelain pair. Acceptance:
  `grep -c '^- \[ \] AC-48 —' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `1`; and the unwrapped-stream search

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -cF 'test_cleanup_worktrees_dirt_content_locations.bats'
  ```

  reports `1` — that literal occurs zero times in `spec.md` at the start of this cycle,
  re-derived against the current tree in this pass, so the assertion can fail.

- [x] [P4-T4] Append AC-49 to the same section as an **unchecked** box. Its text states:
  that `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` admits exactly two row
  kinds, `SEPARATED` and `ARGV`, and that a row carrying any other kind fails the gate on a
  named invariant; that both admissible kinds require an observed difference between the
  mutated and the unmutated run, so a scenario under which the ladder never reaches the
  guard makes the row fail rather than pass; that every marker id read from the library
  must carry at least one `SEPARATED` row, with the single exception of
  `history-scan-bounded-range`, which is pinned `ARGV` because the stub keys
  `log --find-object` on the object id alone and no scenario can make that guard change a
  record; and that the two library lines carrying an arithmetic guard and a named
  non-arithmetic guard together remain pinned by the pair (`id`, `mutation`), because an
  id-keyed pin on either is discharged by one of that id's two rows and leaves the other
  unconstrained. The criterion must not claim that the gate detects a missing comparison —
  that property is AC-48's — and must say so explicitly, so the two criteria are not read
  as overlapping. Acceptance:
  `grep -c '^- \[ \] AC-49 —' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `1`; and the unwrapped-stream search

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -cF 'ARGV_ONLY_IDS'
  ```

  reports `1` — that literal occurs zero times in `spec.md` at the start of this cycle,
  re-derived against the current tree in this pass, so the assertion can fail.

- [x] [P4-T5] Reconcile the criterion count. Run the section-scoped derivation fixed in
  **Acceptance-criteria changes** for the total, and the same `awk` prefix piped to
  `grep -c '^- \[x\]'` and to `grep -c '^- \[ \]'` for the checked and unchecked counts.
  Record `evidence/other/ac-count-reconciliation.2026-09-09T02-00.md` with `Timestamp:`,
  all three `Command:` values, `EXIT_CODE:`, the three counts, and a fourth field recording
  the unscoped `grep -c '^- \['` figure alongside a statement that it is not the criterion
  count and why. State that the two unchecked boxes are AC-48 and AC-49. Acceptance: the
  artifact records a section-scoped total of `49`, a checked count of `47`, an unchecked
  count of `2`, and an unscoped figure of `57`.

- [x] [P4-T6] Add one sentence to the `DIRTFILE|` bullet of the Report Line Contract in
  `.claude/skills/cleanup-merged-worktrees/SKILL.md` — the bullet beginning at `:81` and
  ending at `:100` — stating that an entry whose porcelain status shows content in both the
  index and the working tree is reported `UNIQUE`, because the rungs that could otherwise
  resolve it compare working-tree content only. The sentence must contain the literal
  `content in both the index and the working tree`, quoted here verbatim so the acceptance
  search has a defined target that this task creates. The bullet is a rewrapped prose
  block, so the acceptance search runs over an unwrapped stream rather than line by line:

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -cF 'content in both the index and the working tree'
  ```

  Acceptance: that command reports `1`. A line-oriented search over the wrapped file would
  return `0` whenever the sentence happened to span two lines, whatever the executor wrote.

- [x] [P4-T7] Mirror the edited skill file to
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  and verify byte identity with `md5sum` over both paths. Record
  `evidence/qa-gates/skill-mirror-parity.2026-09-09T02-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and both digests. Acceptance: the two recorded digests are
  identical, the artifact states so explicitly, and `diff` between the two paths produces
  no output, recorded verbatim as an empty block.

- [x] [P4-T8] Correct the P2 citation. In
  `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md:78`, change `.gitignore:67` to
  `.gitignore:68`. The observed rule at `.gitignore:68` is `.claude/state/`; `.gitignore:67`
  is `.claude/agent-memory`, which does not match the path in question. Nothing else in
  that artifact changes. Acceptance:
  `grep -cF '.gitignore:68' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`
  reports `1`, and
  `grep -cF '.gitignore:67' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`
  reports `0`.

---

### Phase 5 — Final QA loop, coverage, and reconciliation

- [x] [P5-T1] Run `bash scripts/bash/shell-qc.sh format`, then run
  `bash scripts/bash/shell-qc.sh check` in the same task, and record
  `evidence/qa-gates/shell-qc-format.2026-09-09T02-30.md` with the same field set and the
  same two-legged observation P0-T3 defines: `Timestamp:`, both `Command:` values, both
  `EXIT_CODE:` values, `Output Summary:` reproducing each command's combined output
  verbatim, and `StatusBefore:`/`StatusAfter:` from
  `git status --porcelain --untracked-files=all` around the format run. The denied
  tree-digest command is not attempted, for the reason stated in P0-T3. Acceptance: both
  `EXIT_CODE:` values are `0`; the check command's combined output is recorded as empty,
  quoted verbatim as an empty block; both status fields reproduce their output verbatim and
  carry the literal `(empty)` when that output is empty; and the artifact states explicitly
  whether `StatusAfter:` lists any path absent from `StatusBefore:` and, if it does, names
  each such path and whether it is in this cycle's scope. If the check leg returns non-zero
  the toolchain loop restarts at this task.

- [x] [P5-T2] Run `bash scripts/bash/shell-qc.sh check` a second time, after P5-T1, as the
  standalone lint stage, and record `evidence/qa-gates/shell-qc-check.2026-09-09T02-30.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` reproducing the
  command's combined stdout and stderr verbatim. No findings count is asserted, for the
  reason stated in **Gate ownership**. Acceptance: `EXIT_CODE:` is `0` and the artifact
  states that the combined output was empty, quoting it verbatim as an empty block rather
  than paraphrasing it.

- [x] [P5-T3] Run the full local test stage, repeating P0-T4's three-step path resolution
  in this task rather than citing P0-T4's recorded value, so the stage is driven by a path
  verified against the tree as it stands now. Run `npx --yes bats --version`, then
  `npm exec --yes --package=bats -- bash -c 'command -v bats'`, then `test -x` and
  `--version` on the resolved path, and then the stage as
  `env SHELL_QC_BATS_BIN=<the ResolvedBatsPath value> bash scripts/bash/shell-qc.sh test`,
  capturing combined stdout and stderr. Record
  `evidence/qa-gates/shell-qc-test.2026-09-09T02-30.md` with `Timestamp:`, every `Command:`,
  `EXIT_CODE:`, `ResolvedBatsPath:`, `ResolvedBatsExecutable:`, `ResolvedBatsVersion:`,
  `ResolvedBatsPathVersion:`, `TapPlanLine:` carrying the first line of the captured stream
  verbatim, the `ok` count, the `not ok` count, and a field `PostChangeLocalTestTotal:`.
  This plan adds exactly six tests and removes none: four in P1-T4 and two in P1-T5. P3-T3
  renames one existing test, which changes no count. Acceptance: `ResolvedBatsPath:` is a
  single absolute path, `ResolvedBatsExecutable:` is `0`, and `ResolvedBatsPathVersion:`
  equals `ResolvedBatsVersion:`; the captured combined output does **not** contain the
  literal `bats not installed; skipping shell tests.`, which is the line
  `scripts/bash/shell_qc_lib.sh:241` prints on the skip path that returns 0 with no test
  executed; `TapPlanLine:` matches the extended regular expression `^1\.\.[1-9][0-9]*$`;
  `PostChangeLocalTestTotal:` equals the number after `1..` in `TapPlanLine:`; `EXIT_CODE:`
  is `0`; the `not ok` count is `0`; and `PostChangeLocalTestTotal:` equals
  `BaselineLocalTestTotal:` from P0-T4 plus exactly `6`. The artifact enumerates the six
  added `@test` titles and the one renamed title, so the delta is attributable rather than
  merely arithmetic. If any resolution acceptance condition fails, the executor stops and
  reports rather than recording a stage result, because the skip path is indistinguishable
  from a clean pass on exit code alone.

- [x] [P5-T4] Confirm the file-size limit across every file this cycle touched with
  `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
  and record `evidence/qa-gates/file-size-limit.2026-09-09T02-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and the per-file counts with the headroom to 500 for each.
  Acceptance: every recorded count is at or below `500`; the classifier library's count is
  at or below `497`; `scripts/bash/cleanup_worktrees_lib.sh` is recorded as `496`; and the
  artifact states the classifier library's growth relative to the `481` recorded in P0-T8.

- [x] [P5-T5] Confirm report mode is still non-mutating. Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_clear.bats` and
  record `evidence/qa-gates/report-mode-non-mutating.2026-09-09T02-30.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the `ok`/`not ok` counts, an explicit statement
  that this cycle added no git read of any new shape — the `bothloc` flag is derived from
  the porcelain status text already in hand and issues no invocation — and the field
  `StubDigest:` recomputed as the `md5sum` of
  `tests/fixtures/cleanup_worktrees/stub-bin/git`. Acceptance: `EXIT_CODE:` is `0`, the
  `not ok` count is `0`, and the recomputed `StubDigest:` equals the value P0-T8 recorded,
  which is what shows this cycle added no arm to the stub.

- [x] [P5-T6] Check off AC-48 and AC-49 in `spec.md` and record
  `evidence/other/ac-checkoff.2026-09-09T02-30.md` with `Timestamp:`, the evidence artifact
  path supporting each of the two criteria, the total checkbox count inside the
  `## Acceptance Criteria` section, and the checked count, both using the section-scoped
  derivation fixed in **Acceptance-criteria changes**. Acceptance: the artifact records a
  section-scoped total of `49` and a section-scoped checked count of `49`, and
  `grep -c '^- \[ \] AC-4' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `0`.

- [ ] [P5-T7] Stage the cycle-3 changes with `git add -A`, commit them, and push the branch.
  Record `evidence/other/remediation-commit-and-push.2026-09-09T02-30.md` with
  `Timestamp:`, the commands, `EXIT_CODE:` for each, the branch name, the
  `git status --porcelain` output taken immediately after `git add -A` and before the
  commit, and the list of changed paths obtained from
  `git diff --name-only origin/epic/cleanup-merged-worktrees-hardening-integration` after
  the commit. The staged-status span is recorded because an anchored name-listing diff
  enumerates tracked changes only and would not show the fixture directory this cycle
  creates until it is staged. Acceptance: the push command's `EXIT_CODE:` is `0`, and the
  recorded path list contains `scripts/bash/cleanup_worktrees_dirt_lib.sh`,
  `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`,
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`, and
  `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`.

- [ ] [P5-T8] Obtain a coverage run against the pushed commit. The dispatch is
  `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`;
  the workflow accepts `workflow_dispatch` (`.github/workflows/_shell-coverage.yml:5`). If
  the caller runs the dispatch instead, the executor records the caller-supplied run id and
  verifies it independently. Either way the recorded values must be re-read from GitHub
  with `gh run view <run-id> --json status,conclusion,headSha,event,url` rather than
  restated. Record `evidence/qa-gates/shell-coverage-dispatch.2026-09-09T02-30.md` with
  `Timestamp:`, `Command:` for the dispatch and for the verification read, `EXIT_CODE:`,
  the run id, the run conclusion, the run's head SHA, and the TAP figures from the run log.
  Acceptance: the recorded conclusion is `success`; the recorded `not ok` count is `0`; and
  the recorded head SHA equals the commit P5-T7 pushed, recorded as an observation of the
  two values side by side rather than asserted against any literal written into this plan.

- [ ] [P5-T9] Download that run's merged Cobertura artifact and read the figures directly
  from `kcov-merged/cov.xml`, counting `<line hits>` per `<class>` rather than reading the
  rounded `line-rate` attribute. Record
  `evidence/qa-gates/dirt-lib-coverage.2026-09-09T02-30.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, `PostChangeRepoLineCoverage:`, `PostChangeDirtLibLineCoverage:`,
  `Threshold: 85.0`, and the covered-over-total line pair for
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`. Acceptance: both percentage fields are
  numbers, both are at or above `85.0`, and the artifact states that kcov measures no
  branch coverage so no branch gate applies to bash.

- [ ] [P5-T10] Compare against the P0-T5 baseline and record
  `evidence/qa-gates/coverage-delta.2026-09-09T02-30.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, `BaselineRepoLineCoverage:`, `PostChangeRepoLineCoverage:`,
  `BaselineDirtLibLineCoverage:`, `PostChangeDirtLibLineCoverage:`, a per-file table
  covering the eight files matching `scripts/bash/cleanup[-_]worktrees*` — the same eight
  named in P0-T5 — with a "fell below baseline" column, and a changed-lines section naming
  the three guard sites P2-T1 added and, for each, the test that executes it in both
  directions. Acceptance: the table has exactly eight rows and names all eight files; no
  file's post-change percentage is below its baseline percentage; and the changed-lines
  section names `dirt_index_and_worktree_delta` as the fixture that executes all three new
  guards and names the four `@test` titles from P1-T4 as the assertions that hold them.

- [ ] [P5-T11] `[expect-fail]` Run
  `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  **in this task**, after P5-T1 through P5-T3 have run, and record the
  single-consecutive-pass declaration in
  `evidence/qa-gates/single-consecutive-pass.2026-09-09T02-30.md`. The artifact lists the
  four local stages in executed order — format (P5-T1), lint (P5-T2), test (P5-T3),
  contract (this task) — with each stage's artifact path and exit code, and records this
  task's own `Command:`, `EXIT_CODE:`, and `ExpectedExitCode: 1` for the contract stage. The
  contract run is repeated here rather than cited from P0-T10 because P0-T10 executes
  before this cycle's own edits are formatted by P5-T1, so a citation of it would describe a
  superseded tree state and the four stages would not have run consecutively. Acceptance:
  the first three stages are listed with exit code `0`; the contract stage records
  `EXIT_CODE: 1` with `ExpectedExitCode: 1` and the literal `1 failed, 10 passed`, together
  with the statement that the single failure is issue `#510`, is identical at the P0-T10
  baseline, and is green in CI; the artifact records that the half of the contract this
  feature owns is `SKILL.md` mirror parity and cites P4-T7's artifact for it; and the
  artifact names the coverage stage as CI-measured with the run id from P5-T8 rather than
  claiming a local run.

- [ ] [P5-T12] Write the cycle-3 closing summary at
  `evidence/other/cycle3-closure.2026-09-09T02-30.md`, stating for each of N3, N4, the
  missing-comparison gate, P2 and P4 the change made, the test that holds it, and the
  evidence artifact. Then stage and commit the documentation and evidence written after
  P5-T7 — the spec check-off from P5-T6 if it postdates the commit, the coverage artifacts
  from P5-T8 through P5-T10, the declaration from P5-T11, this summary, **and this plan
  file with its check-offs through P5-T11** — and push, so the branch tip carries the
  complete cycle rather than only its code half. The plan file is enumerated explicitly
  because it lives inside the feature folder this task's clean-status acceptance inspects
  and it acquires check-offs after P5-T7's commit, so a commit that omitted it would leave
  the folder dirty and make the acceptance below unsatisfiable. Acceptance: the artifact
  names all five items; for N3 it names the three guard ids `index-and-worktree-both-hold-content`,
  `rung4-index-blob-unaccounted` and `rung5-index-blob-unaccounted` together with their
  registry rows; for N4 it names `evidence/regression-testing/n4-parked-row-rejected.2026-09-09T01-30.md`
  as the demonstration that the parked-row artefact is now rejected; and after the push,
  `git status --porcelain docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632`
  produces no output, which is the observation that no evidence file was left uncommitted.
  That observation is taken **before** this task's own checkbox in this plan file is
  checked, because this plan file lives under the same feature folder and checking its final
  box first would dirty the very path the command inspects. The final check-off commit that
  follows is the orchestrator's to make and is outside this plan's own acceptance.

---

## Evidence index

| Kind | Path |
|---|---|
| Remediation baseline | `evidence/remediation-baseline/*.2026-09-09T00-00.md` |
| Regression testing | `evidence/regression-testing/fail-before-index-blob-unaccounted.2026-09-09T00-30.md`, `evidence/regression-testing/pass-after-index-blob-unaccounted.2026-09-09T01-00.md`, `evidence/regression-testing/phase2-sibling-check.2026-09-09T01-00.md`, `evidence/regression-testing/n4-parked-row-rejected.2026-09-09T01-30.md` |
| QA gates | `evidence/qa-gates/file-size-after-fix.2026-09-09T01-00.md`, `evidence/qa-gates/registry-kind-distribution.2026-09-09T01-30.md`, `evidence/qa-gates/skill-mirror-parity.2026-09-09T02-00.md`, `evidence/qa-gates/*.2026-09-09T02-30.md` |
| Other | `evidence/other/ac-count-reconciliation.2026-09-09T02-00.md`, `evidence/other/ac-checkoff.2026-09-09T02-30.md`, `evidence/other/remediation-commit-and-push.2026-09-09T02-30.md`, `evidence/other/cycle3-closure.2026-09-09T02-30.md` |

All evidence paths in this plan resolve under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`.
No `artifacts/` sub-path is used for evidence.
