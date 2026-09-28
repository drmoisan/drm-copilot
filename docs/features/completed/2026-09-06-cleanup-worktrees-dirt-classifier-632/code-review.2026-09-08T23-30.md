# Code Review — cleanup-worktrees dirt classifier (Issue #632), remediation cycle 2 EXIT REAUDIT

- Timestamp: 2026-09-08T23-30 (UTC)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `454bd523`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680e`
- Primary obligation applied: this classifier decides whether a dirty worktree is safe to delete, so
  correctness of the classifier is judged first and everything else second.
- Blocking findings in this artifact: **2** (N3 FAIL, N4 blocking-PARTIAL). Both are NEW.

## Method

Every verdict below on a claimed fix is established by reproduction against the tree, not by reading
the plan or the evidence artifacts. Each fix that is claimed to be pinned by a test was additionally
subjected to a discrimination probe: the fix was neutralized in a scratch copy of the library and
the checked-in suites were re-run, to establish that the pin fails when the fix is absent rather
than merely passing when it is present.

Workbench:

```
cp -r <worktree>/scripts/bash  <scratch>/probe/scripts/bash
cp -r <worktree>/tests         <scratch>/probe/tests
bats --tap <scratch>/probe/tests/shell/test_cleanup_worktrees_dirt_*.bats
```

Baseline on the unmutated scratch copy, five dirt suites: **64 ok, 0 not ok, exit 0**.
Baseline over all thirteen `test_cleanup_worktrees_*.bats` suites: **179 ok, 0 not ok, exit 0**.
No repository file was modified at any point.

## Part 1 — N1: rung 4 resolving `CONTENT_ON_MAIN` from an empty pathspec

### Verdict: **CLOSED — PASS**

The fix is at `scripts/bash/cleanup_worktrees_dirt_lib.sh:303-320`. Rung 4's tracked positive answer
is now conditional on a second read:

```bash
if ((drc == 0)); then # guard:rung4-tracked-content-equal
        cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet \
                "main:$rel" >/dev/null || erc=$?
        if ((erc == 0)); then # guard:rung4-tracked-path-in-main
                printf 'CONTENT_ON_MAIN|\n'
                return 0
        fi
fi
```

**Root cause and fix semantics confirmed against real git, not against the stub.** Read-only probes
in this worktree, git as installed here:

```
git diff --quiet main -- "no/such/path-xyz.md"        ; rc=0    <- the defect's premise
git rev-parse --verify --quiet "main:no/such/path-xyz.md" ; rc=1, no stdout
git rev-parse --verify --quiet "main:README.md"       ; rc=0, prints cad2034a…
```

So the new probe answers exactly the question the fix needs — "does `main` hold content at this path
to be equal to" — and its two exit codes match the two `.rc` values the new fixture encodes
(`rev-parse.verify.main_docs_tracked.md.rc` = 0, `rev-parse.verify.main_staged_only.md.rc` = 1).

**Discrimination probe A — minimal neutralization.** `s/((erc == 0))/((1))/` applied to the marked
line, then the four functional dirt suites:

```
not ok 32 dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE
#   `[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||AD|staged_only.md'* ]]' failed
```

**Discrimination probe B — the true historical revert.** The pre-cycle-2 library was extracted with
`git show 02150524:scripts/bash/cleanup_worktrees_dirt_lib.sh` into the scratch copy and the
post-change suites were run against it. Exactly one test fails, and it is the new one:

```
not ok 32 dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE
```

**Discrimination probe C — the positive direction.** A "fix" that simply stopped rung 4 emitting
`CONTENT_ON_MAIN` must also be rejected. `s/((erc == 0))/((0))/`:

```
not ok 21 dirt_rename_split: a genuine R entry is still split and the destination path is classified
not ok 33 dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN
```

Both directions are pinned by discriminating assertions. The `dirt_tracked_staged_only_blob` fixture
carries one `AD` entry and one `M ` entry in a single scenario, so the same status read serves both
directions; the negative test asserts the record, the aggregate, and the absence of both
`CONTENT_ON_MAIN||AD|` and `ALL_DISPOSABLE`
(`tests/shell/test_cleanup_worktrees_dirt_failclosed.bats:159-174`).

Quality note (non-blocking): the fix discards only stdout on the new read and the comment at
`:308-311` explains why — redirecting stderr as well would hide the invocation from the stub's argv
log and defeat the argv assertions. That is the correct call and it is documented at the site.

## Part 2 — N2: the four guards no checked-in fixture could distinguish from their absence

Each of the four was neutralized on the marked line and the four **functional** suites re-run. The
registry gate suite was excluded from these runs on purpose: the cycle-1 acceptance for N2 was
"deleting the guard must make at least one checked-in test fail", and a gate suite that reads the
registry would satisfy that trivially. All four are killed by a functional assertion.

| # | Guard | Mutation applied | Functional test that fails | Verdict |
|---|---|---|---|---|
| 1 | `find-object-hard-fail` (`((lrc != 0))`), `:354` | `s/((lrc != 0))/((0))/` | `not ok 31 dirt_history_read_error: a find-object read failure maps the untracked entry to UNIQUE` | **CLOSED** |
| 2 | `hash-object-hard-fail`, arithmetic half (`((hrc != 0))`), `:329` | `s/((hrc != 0))/((0))/` | `not ok 14 dirt_classifier_read_error: a non-zero classifier read yields UNIQUE and HAS_UNIQUE` **and** `not ok 41 dirt_classifier_read_error: a fail-closed UNIQUE refuses the clear` | **CLOSED** |
| 3 | `rung4-tracked-hard-fail` (`((drc > 1))`), `:319` | `s/((drc > 1))/((0))/` | `not ok 34 dirt_tracked_probe_error_in_history: a rung-4 hard read failure is UNIQUE even when the blob is in history` | **CLOSED** |
| 4 | `build-artifact-vacuous-confinement` (`((total == 0))`), `:223` | `s/((total == 0))/((0))/` | `not ok 35 dirt_build_artifact_empty_diff: a csproj whose diff pair is empty is UNIQUE not a build artifact` | **CLOSED** |

The fixture work is the right shape in each case. Sites 1 and 2 are one or two added `.out` files on
an existing scenario directory, so the failing read now carries stdout as well as a non-zero exit and
a weaker downstream condition can reach a different verdict. Sites 3 and 4 are new scenario
directories. Each of the four tests also carries a positive control on the argv log, so the absence
assertion cannot pass in a build where no classification ran — for example
`test_cleanup_worktrees_dirt_failclosed.bats:203-204` asserts both halves of the diff pair were
actually read before concluding that the vacuous-confinement guard is what produced `UNIQUE`.

**All five of N1 and N2's four sites: CLOSED.**

## Part 3 — the systemic gate (AC-47), judged on its merits

### Verdict: **PARTIAL — blocking (N4)**

#### What was shipped, verified rather than restated

```
registry data rows: 39
distinct ids:       37
kinds:              37 SEPARATED, 2 ARGV, 0 EXEMPT
markers in source:  37
diff(markers, registry ids) -> empty; MARKER SET == REGISTRY ID SET
bats tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats -> 1..3, 3 ok
```

The counts in the caller prompt are accurate. The pin test names 12 id-keyed `SEPARATED` pins
(Group A), 3 id-keyed `SEPARATED`-or-`ARGV` pins (Group B), and 3 pair-keyed pins (Group C), for 18
pins across 17 ids.

#### What the gate genuinely enforces

Four properties are real and cannot be talked around:

1. **The mutation cannot be cosmetic.** Invariant 7 admits only one of eight fixed literal
   substitutions or `s/((EXPR))/((0))/` / `s/((EXPR))/((1))/` where `EXPR` is re-derived at test time
   from the row's own marked line in the *unmutated* library (`expr_for`, lines 57-67). Obligation 2
   then requires exactly one changed line, that the line carries a marker, and that the two versions
   still differ after the marker comment is stripped and whitespace runs are collapsed (`norm_line`,
   lines 69-80). A comment-only or reindent-only mutation is rejected.
2. **Each kind asserts an identity as well as a difference**, so no kind is satisfiable by writing a
   verdict into the registry: `SEPARATED` demands a changed record stream; `ARGV` demands an
   unchanged record stream *and* a changed argv log *and* the `ARGV-ONLY:` reason token; `EXEMPT`
   demands both channels unchanged *and* the `RECORDS-AND-ARGV-IDENTICAL:` token.
3. **The channels are separated, not merged.** `run_child` (lines 90-113) tags stderr with an `ARGV `
   prefix through a `3>&1` swap before reading both back, so the stub's argv log cannot contaminate
   the record channel. The record channel includes both call sites' exit statuses, not just the
   `DIRTSUM|` aggregate.
4. **The gate is load-bearing against future guard removal.** Verified by probe, not assumed:
   stripping the marker comment from one line of a scratch copy produced

```
INVARIANT-1 unmarked guard lines: [                        if ((erc == 0)); then]
INVARIANT-3 rows naming an unmarked id: rung4-tracked-path-in-main
INVARIANT-7 inadmissible mutation: [rung4-tracked-path-in-main::s/((erc == 0))/((1))/]
OBLIGATION-2 mutation inert or not single-line: rung4-tracked-path-in-main
OBLIGATION-5 channel comparison failed: rung4-tracked-path-in-main
```

   and neutralizing the guard while keeping the marker produced the same Obligation 2 and 5 failures.

#### The cheapest passing registry a lazy executor could produce

Under the shipped text the executor's free variables are, per row: the `scenario`, and — for an
arithmetic mutation — which of the two constants to force. The cheapest artifact is constructed as
follows.

- **Forced content.** Invariant 1 forces a marker onto every line matching
  `\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)`; Invariant 2 forces at least one row per
  marker; Invariant 6 forces the eight named non-arithmetic `(id, mutation)` pairs to be registered.
  So the row set itself is not reducible.
- **Forced kinds.** Test 3 pins 17 ids to `SEPARATED` or `SEPARATED`-or-`ARGV`. All eight literal
  ids fall inside that pinned set (`diff-header-skip`, `rung1-y-column-gate`,
  `hash-object-hard-fail`, `rung4-untracked-main-present`, `history-hit-nonempty`,
  `rename-payload-split-gate`, `unique-verdict-tally`, `clear-requires-all-disposable`), so no
  literal-mutation row can be parked.
- **The remaining 20 ids are unpinned and arithmetic-only.** For each, the executor names a scenario
  in which the ladder never reaches the guard. Both admissible constants are then unobservable on
  both channels, Obligation 6's sibling rule is satisfied vacuously, and the row is `EXEMPT` with the
  fixed reason token. Obligation 4 is no obstacle: it requires only that the *unmutated* run emit at
  least one `DIRTFILE|` record, which any `dirt_*` scenario does; it does not require the ladder to
  reach the guard.

**Demonstrated, not argued.** In a scratch copy the `staged-probe-skip-head` row was replaced with

```
staged-probe-skip-head  EXEMPT  dirt_unique  HAS_UNIQUE  s/((first == 1))/((0))/
RECORDS-AND-ARGV-IDENTICAL: the staged-tree probe is never issued in this scenario, so
neither constant is observable.
```

`dirt_unique`'s status read is a single `??` entry, so `any_staged` stays 0, `dirt_staged_tree_commit`
is never called, and neither constant on `((first == 1))` can be observed. The gate result:

```
1..3
ok 1 every guard-shaped line in the dirt library is marked and every registry row names a marked id
ok 2 every registered guard is observable under its own neutralization
ok 3 the eighteen pinned guard rows carry the registry kinds this plan fixes
```

All three pass — while the shipped registry proves the very same guard *is* separable under
`dirt_staged_tree_is_commit`. So the gate's floor is 18 genuinely-killed rows plus up to 20 parked
rows, and it can be satisfied without exercising 20 of its 37 guards.

#### Assessment

The shipped artifact is far above that floor: all 37 ids are `SEPARATED` or `ARGV`, zero are
`EXEMPT`, and this reviewer confirmed the gate suite passes on the real tree and that its
neutralizations really do kill. Five preflight rounds produced a mechanism that is not vacuous for
what it contains.

Two things nevertheless make this blocking:

1. **By the caller's stated criterion.** "If the gate can still be satisfied without genuinely
   exercising a guard, that is a blocking finding regardless of how many rounds it has already
   taken." The demonstration above meets that condition exactly. AC-47's own text discloses the
   scenario-scoping, so the criterion is not *falsely* claimed — but the disclosure does not remove
   the hole, it documents it.
2. **The gate measures the wrong class of defect for the problem it was created to solve.** It
   detects a *dead guard*: a line whose neutralization changes nothing. The defect class that has now
   recurred in three consecutive cycles is a *missing comparison*: a rung that resolves a disposable
   verdict from a probe that does not establish it. R1 was one, N1 was one, and N3 below is one. The
   registry gate passes cleanly on a tree that contains N3. The general criterion cycle 1 proposed —
   "No rung resolves a disposable verdict from a probe whose result does not establish one" — was
   translated into a mechanical proxy that does not cover it.

Recommended remediation for N4, in order of preference: (a) require `EXEMPT` rows to demonstrate that
the ladder *reached* the guard under the named scenario, for example by asserting a specific argv
invocation, which converts "not reached" from a way to pass into a way to fail; and (b) restate
AC-47's floor so that every marker id is pinned by kind, not 17 of 37.

## Part 4 — N3, a NEW defect: rungs 4 and 5 never compare the index blob

### Verdict: **FAIL (NEW finding — opens a new cycle)**

- Location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:303-320` (rung 4, tracked half) and
  `:344-362` (rung 5).
- Severity: **FAIL.** Data loss on `--clear-disposable`. Same class and same consequence as N1.

#### Statement

For a status entry whose X column is one of `M A R C` **and** whose Y column is not a space, both an
index delta and a working-tree delta exist. Rung 1 correctly declines such an entry — that is cycle
1's R1 fix, and the Y-column gate at `:270` is right. But the rungs the entry then falls to compare
only **working-tree** content:

- rung 4 tracked half compares `main`'s tree to the **working tree** (`diff --quiet main -- <path>`);
- rung 5 hashes the **working-tree** file and looks for that blob in history.

Neither compares the **index** blob to anything. Rung 3 does read both sides
(`dirt_is_build_artifact` calls `dirt_diff_is_hintpath_confined` for both the worktree diff and the
cached diff, `:214-219`), which shows the authors knew the index side has to be examined; rungs 4 and
5 do not follow it. The library header at `:262-269` states the intended reasoning — "An entry with a
non-space Y column falls through to the rungs that compare WORKING-TREE content, which is the
comparison its unstaged delta actually needs" — and that sentence is true about the unstaged delta
and silent about the staged one.

Consequence: an entry whose working-tree content is on `main` or in history resolves
`CONTENT_ON_MAIN` or `CONTENT_IN_HISTORY`, the worktree aggregates `ALL_DISPOSABLE`, and
`clear_disposable_dirt` runs `reset --hard` followed by `clean -fd`. The staged blob exists in no
commit and, after `reset --hard` drops the index entry, becomes unreachable.

#### Reachability

Realizable with ordinary git operations: on a feature branch that has not itself touched the file,
`git add <file>` stages content D, then editing the working-tree copy back to `main`'s content C
yields porcelain `MM` (X compares index to HEAD, Y compares working tree to index — the two are
independent). The `AM`, `RM`, and `CM` shapes reach rung 5 by the same route. The `AD` and `MD`
shapes are **not** affected: `AD` is closed by the N1 fix, and for `MD` the path is present in `main`
while absent from the working tree, so `diff --quiet` exits 1 and the entry fails closed at the
`hash-object` guard.

#### Reproduction

Two scratch scenarios were built in the workbench copy by taking the checked-in
`dirt_staged_tree_worktree_delta` fixture — which already carries an `MM` entry — and changing only
the rung-4/rung-5 answers, plus setting `diff-index.eeee7777.rc` to 1 so the staged index matches no
ancestor tree and the staged content is genuinely unique.

Rung 4 variant (`diff-quiet..src_a.cs.rc` = 0, `rev-parse.verify.main_src_a.cs.rc` = 0):

```
stub-git: --no-optional-locks -C /repo-wt/dirt status --porcelain
stub-git: --no-optional-locks -C /repo-wt/dirt rev-list --max-count=201 HEAD
stub-git: --no-optional-locks -C /repo-wt/dirt diff-index --cached --quiet eeee7777 --
stub-git: --no-optional-locks -C /repo-wt/dirt diff --quiet main -- src/a.cs
stub-git: --no-optional-locks -C /repo-wt/dirt rev-parse --verify --quiet main:src/a.cs
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||MM|src/a.cs
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
--- clear ---
ACTION|dirt-clear|/repo-wt/dirt|OK
```

Rung 5 variant (`diff-quiet..src_a.cs.rc` = 1, `hash-object.src_a.cs.out` = `bbbb1111`,
`log.find-object.bbbb1111.out` = `ffff3333`):

```
DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|ffff3333|MM|src/a.cs
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333
--- clear ---
ACTION|dirt-clear|/repo-wt/dirt|OK
```

In both, `ACTION|dirt-clear|…|OK` is emitted only after `reset --hard` and `clean -fd` both returned
0, so the destructive sequence completed.

Contrast with the checked-in `dirt_staged_tree_worktree_delta`, which sets
`diff-quiet..src_a.cs.rc` to 1 and therefore never exercises the rung-4 positive answer for an `MM`
entry. The single fixture value separating the tested case from the data-loss case is that `.rc`
file.

#### Why the existing gates do not catch it

- The registry gate passes: N3 is a missing comparison, not a dead guard. Every marked guard is
  still observable.
- No acceptance criterion covers it. AC-39 pins that an `MM` entry is never
  `STAGED_TREE_IS_COMMIT`, which is the converse property and is satisfied. AC-46 pins the empty
  pathspec. Neither addresses an `MM` entry that resolves a *different* disposable verdict.
- The verdict-token membership test (AC-8) is a token check, not a correctness check.

#### Suggested remediation direction

An entry with a non-space Y column and a staged X column carries content in two places. A disposable
verdict for it must establish that **both** are recoverable. The cheapest sound rule is to fail
closed: when `x` is one of `M A R C` and `y` is not a space, the tracked half of rung 4 and rung 5
resolve `UNIQUE` unless the index blob is also accounted for — for example by comparing
`rev-parse ":$rel"` (the index blob) against `main:$rel` and against `log --find-object`. Pin it in
both directions with one fixture carrying an `MM` entry whose working-tree content is on `main`,
asserting the verdict is not `CONTENT_ON_MAIN` and the aggregate is not `ALL_DISPOSABLE`, plus the
existing `M ` control so the fix does not simply disable the rung.

## Part 5 — General code-quality review

| Dimension | Verdict | Notes |
|---|---|---|
| Simplicity | **PASS** | The N1 fix is one nested conditional with no new helper and no new state. The registry gate is intricate but the intricacy is load-bearing; each construct has a stated reason at its site (the `$`-anchored address, the single-argument `sed` program, the `3>&1` channel split). |
| Reusability | **PASS** | No duplication introduced. The marker comments are inert. |
| Extensibility | **PASS** | No public API changed. The record contract is unchanged. |
| Separation of concerns | **PASS** | I/O stays behind `cleanup_wt_git`. Every git-backed read whose exit code is authoritative is captured in the parent shell, per the rule stated at `cleanup_worktrees_dirt_lib.sh:36-38`; the new `rev-parse` read follows it. |
| Error handling / fail-fast | **FAIL at one site** | Every explicit guard fails closed. N3 is a failure to *have* a check, not a mishandled one. |
| Naming | **PASS** | `erc` matches the file's `<x>rc` convention for captured exit codes. Marker ids are descriptive and kebab-case. |
| File size | **PASS, low headroom** | 481/500 in the classifier library; 452/500 in the new gate suite. |
| Dependencies | **PASS** | None added. |
| Test structure (AAA) | **PASS** | Each new test arranges by naming a scenario, acts through the stub seam, and asserts the record, the aggregate, an absence, and a positive control for the absence. |
| Determinism | **PASS** | No clock, no RNG, no sleeps, no network. All fixture data is checked in. |
| Test file location | **PASS** | `tests/shell/` and `tests/fixtures/cleanup_worktrees/`; no colocation with production source. |
| Temporary files in tests | **PASS** | None. The registry gate keeps mutated source in a shell variable. |
| Coverage exclusions | **PASS** | No `exclude` entry matching a production source path. All eight `cleanup[-_]worktrees*` files remain in the coverage denominator. |
| Documentation | **PASS** | Both `SKILL.md` copies document the N1 narrowing and are byte-identical. The library header gained a precise `EMPTY PATHSPEC IS NOT A MATCH` paragraph. |

## Answer to the caller's question on the docs-only head advance

`454bd523` changes five files, all under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/` (three added evidence
artifacts, one modified evidence artifact, the remediation plan). It touches nothing under
`scripts/`, `.claude/lib/bash/`, or `tests/`.

`_shell-coverage.yml` measures bats suites under `tests/shell` against scripts discovered under
`tools/`, `scripts/`, and `.claude/lib/bash/`. None of those inputs differs between `7d7a661f` and
`454bd523`. **The docs-only delta is not material to the coverage gate or to the TAP count.** A
re-dispatch at the final head SHA is therefore not needed for gate validity; it is worth doing only
if the merge policy requires the recorded run's `headSha` to equal the merge head as a bookkeeping
invariant. Note that the N3 remediation will change the classifier library and will require a real
re-dispatch regardless.

## Summary of blocking findings

| ID | Severity | Location | Status |
|---|---|---|---|
| N3 | FAIL | `cleanup_worktrees_dirt_lib.sh:303-320`, `:344-362` | NEW — opens a new cycle |
| N4 | PARTIAL, blocking | `test_cleanup_worktrees_dirt_guard_registry.bats:338-373` | NEW — opens a new cycle |

**blocking_count = 2.**
