# Research: cleanup-worktrees bats test-suite blind spots (#660)

- Issue: #660 (consolidates #661)
- Scope: read-only research. No source, fixture, or test file was modified while
  producing this document.
- Method: every finding below was obtained by reading the current tree with `Read`,
  `Grep`, and `Glob`. This research agent has no `Bash`/`PowerShell` execution tool in
  this session, so no bats run, `shell-qc.sh` invocation, or sed/eval mutation was
  actually executed. Every claim about a git-call sequence or an expected DIRTFILE/
  DIRTSUM line is **derived** by tracing `scripts/bash/cleanup_worktrees_dirt_lib.sh`
  and the stub's key-derivation rules line by line, not observed from a run. This is
  stated once here and not repeated at every claim; any claim that was independently
  cross-checked against a second, unrelated source is called out as such.

## 1. Current State Analysis

### 1.1 Where `[MARCTU]` is used and what it classifies

`scripts/bash/cleanup_worktrees_dirt_lib.sh` uses the literal character-class token
`[MARCTU]` in exactly **one** place, line 297:

```
297		[[ $x == [MARCTU] && $y == [MARCTU] ]] && bothloc=1 # guard:index-and-worktree-both-hold-content
```

`x` and `y` are the two porcelain status characters (`x="${xy:0:1}"`, `y="${xy:1:1}"`,
set at line 246). The class is applied **separately to the index column (X) and the
worktree column (Y)**, and `bothloc` is set to `1` only when **both** columns are
content-bearing. `bothloc` is consumed at exactly two other lines:

```
325			if ((bothloc == 0)); then # guard:rung4-index-blob-unaccounted
...
372		if ((bothloc == 0)); then   # guard:rung5-index-blob-unaccounted
```

Line 325 gates rung 4's `CONTENT_ON_MAIN` print (reached only after `diff --quiet main
-- <path>` exits 0 and `rev-parse --verify --quiet main:<path>` exits 0). Line 372
gates rung 5's `CONTENT_IN_HISTORY` print (reached only after `git log --find-object`
returns a non-empty commit sha). In both cases, when `bothloc == 1` the print is
suppressed and the ladder falls through to rung 6, `UNIQUE`.

Narrowing the class to `[MARCU]` (dropping `T`) has **no effect anywhere else in the
file** — `[MARCTU]`/`[MARCU]` occurs nowhere else (confirmed by `Grep` over the whole
file; see Numeric Derivation Evidence §A). Its only observable effect is on `bothloc`,
and `bothloc` only matters when **one column is `T` and the other column is also
content-bearing** (e.g. `MT`, `TM`, `AT`, `TC`, …). When `T` sits opposite a space
(`T ` or ` T`), the other column already fails to match `[MARCTU]`/`[MARCU]` regardless
of whether `T` is in the class, so `bothloc` is `0` under both the correct code and the
mutant — **such an entry cannot distinguish the mutation**. This is why no single-column
`T ` scenario would satisfy AC-2; the scenario must pair `T` with a second
content-bearing column.

The header's own "INDEX AND WORKTREE ARE TWO LOCATIONS" note (lines 58–62) and the
`guard:index-and-worktree-both-hold-content` marker's comment in
`tests/shell/test_cleanup_worktrees_dirt_failclosed.bats:265-269` ("the reason the
guard's character class is not narrowed to M A R C… An unmerged entry holds content at
index stages 2 and 3…") explain *why* `U` is defended by an explicit dedicated
scenario (`dirt_index_and_worktree_delta`'s `UU` entry) — but that same comment never
mentions `T`, and no scenario anywhere in the corpus carries a `T` in either column
(Numeric Derivation Evidence §B). This is the exact blind spot the issue names.

### 1.2 Bats suites and helpers that drive dirt scenarios

- `tests/shell/test_cleanup_worktrees_dirt_classify.bats` — the primary verdict-pinning
  suite. Its `setup()`/`dirt()`/`dirt_log()`/`argv_log()` helpers (lines 26–58) source
  `cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_lib.sh`,
  `cleanup_worktrees_dirt_lib.sh` and call `classify_worktree_dirt '/repo-wt/dirt'`
  directly, with `CLEANUP_WT_GIT_BIN` pointed at `tests/fixtures/cleanup_worktrees/
  stub-bin/git` and `CLEANUP_WT_STUB_SCENARIO` pointed at a scenario directory. A test
  at lines 214–257 iterates a **hardcoded** list of every `dirt_*` scenario directory,
  asserts every DIRTFILE verdict is one of the six defined tokens, and cross-checks the
  list's length (`iterated`) against `find "${SCEN}" -maxdepth 1 -type d -name
  'dirt_*' | wc -l` (`on_disk`), plus a hardcoded total record count (`seen -eq 38`).
- `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` — pins the `bothloc`
  fail-closed direction specifically, using `dirt_index_and_worktree_delta`'s `MM`,
  `UU`, and `M ` entries (lines 232–283). This is the file whose own comment already
  argues *why the class isn't narrowed to M A R C*, immediately adjacent to where a `T`
  case belongs but is absent.
- `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats` — a
  discover-from-disk (not hardcoded-list) property suite. Its own case statement at
  lines 141–142 (`case "$x" in [MARCTU]) idx=1 ;; esac` / same for `$y`) is an
  **independent copy** of the content-bearing class, written directly in the test file
  rather than sourced from production. Because no scenario currently emits a `T`-column
  entry, this independent copy is currently never exercised on a `T` value either.
- `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` +
  `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` — a mutation-testing
  harness for every `# guard:` marker. Row 41 already registers
  `index-and-worktree-both-hold-content` against `dirt_index_and_worktree_delta`, but
  its mutation (`s%\[\[ $x == \[MARCTU\] && $y == \[MARCTU\] \]\]%[[ -n "" ]]%`)
  disables the **entire condition**, not the narrower `[MARCTU]→[MARCU]` character-class
  edit the issue is worried about. This registry entry does not, and structurally
  cannot without a code change of its own (see §4), protect against the issue's
  specific mutation.

### 1.3 Closest analogue scenario and its fixture encoding

`dirt_index_and_worktree_delta` (`tests/fixtures/cleanup_worktrees/scenarios/
dirt_index_and_worktree_delta/`) is the closest existing analogue — it is the *only*
scenario built specifically to exercise `bothloc`. Its
`status._repo-wt_dirt.out` is:

```
MM src/a.cs
MM src/b.cs
UU src/c.cs
M  docs/tracked.md
```

Each porcelain line is exactly `XY<space><path>` (`line:0:2` is XY, `line:3:` is the
path — confirmed against `classify_worktree_dirt`'s `xy="${line:0:2}"; rel="${line:3}"`
at lines 424–425). The stub's key-derivation rules (documented in the stub's own header,
`tests/fixtures/cleanup_worktrees/stub-bin/git:20-64`) name every other file:

| stub key | fixture file | purpose |
|---|---|---|
| `status.<sanitized -C path>` | `status._repo-wt_dirt.out` | the one status read |
| `rev-list.<HEAD-or-branch>` (unused here, empty default) | *(absent)* | staged-tree probe walk |
| `diff-quiet.<spec>.<path>` | `diff-quiet..src_a.cs.rc` etc. | rung 4 tracked-half `diff --quiet main -- <path>` |
| `rev-parse.verify.main_<path>` | `rev-parse.verify.main_src_a.cs.rc` etc. | rung 4's `rev-parse --verify --quiet main:<path>` |
| `hash-object.<path>` | `hash-object.src_a.cs.out` etc. | the working-tree blob id |
| `log.find-object.<blob>` | `log.find-object.bbbb1111.out` | rung 5's history scan |
| `for-each-ref.out`, `merge-base.feature-dirt.rc`, `rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`, `worktree-list.out`, `worktree-remove.rc` | (shared repo-shape baseline) | reused verbatim by every scenario in the family so the directory also works under the deletion/clear drivers other suites use |

Tracing `src/a.cs` (`MM`, `diff-quiet..src_a.cs.rc=0`, `rev-parse.verify.
main_src_a.cs.rc=0`) shows: `drc=0`, `erc=0`, `bothloc=1` (both `M` and `M` match) →
line 325's gate suppresses `CONTENT_ON_MAIN` → falls through to `UNIQUE`. This matches
`test_cleanup_worktrees_dirt_failclosed.bats:242` exactly. `src/b.cs` (`MM`,
`diff-quiet..src_b.cs.rc=1`) instead reaches rung 5 via `hash-object.src_b.cs.
out=bbbb1111` and `log.find-object.bbbb1111.out=ffff3333`; `bothloc=1` suppresses
`CONTENT_IN_HISTORY` too, so it is also `UNIQUE` (test at line 258). `docs/tracked.md`
(`M `, Y is a space) has `bothloc=0` regardless of the class definition and correctly
resolves `CONTENT_ON_MAIN` (the control at line 282) — this is exactly the "single
space column can't distinguish the mutation" property from §1.1.

### 1.4 Exact fixture set and expected records for a new `T` scenario

Proposed new scenario directory:
`tests/fixtures/cleanup_worktrees/scenarios/dirt_typechange_delta/`, one entry,
`XY="MT"`, `rel="src/typechange.dat"` (a non-project-file path so rung 3's
`dirt_is_build_artifact` case statement, `cleanup_worktrees_dirt_lib.sh:218-221`, never
matches and the trace stays on the `bothloc` path). `Y='T'` is deliberately paired with
a *different* content-bearing letter (`M`) rather than with a second `T`, matching the
existing `MM`/`UU` pairing style and avoiding rung 1 entirely, since rung 1's gate
(`cleanup_worktrees_dirt_lib.sh:277`, `$y == " "`) requires a **space** Y column and `T`
is not one.

Required files, traced call-by-call against `classify_worktree_dirt` /
`classify_dirt_entry`:

| file | content | why |
|---|---|---|
| `status._repo-wt_dirt.out` | `MT src/typechange.dat\n` | the one status read |
| `for-each-ref.out` | `feature-dirt dddd9999\nmain aaaa0000\n` | shared baseline (copy `dirt_unique`'s) |
| `merge-base.feature-dirt.rc` | `0` | shared baseline |
| `rev-parse.abbrev-ref-HEAD.out` | `main\n` | shared baseline |
| `rev-parse.show-toplevel.out` | `/repo/main\n` | shared baseline |
| `worktree-list.out` | 8-line worktree-list block (`/repo/main` @ `aaaa0000` on `main`; `/repo-wt/dirt` @ `dddd9999` on `feature-dirt`) | shared baseline |
| `worktree-remove.rc` | `1` | shared baseline (dirty worktree, matches `dirt_unique`) |
| `diff-quiet..src_typechange.dat.rc` | `0` | rung 4 tracked-half: `diff --quiet main -- src/typechange.dat` exits 0 (content equal to main) |
| `rev-parse.verify.main_src_typechange.dat.rc` | `0` | rung 4's `rev-parse --verify --quiet main:src/typechange.dat` exits 0 (path exists on main) |
| `hash-object.src_typechange.dat.out` | `abcd1234\n` | the working-tree blob id, read regardless of whether rung 4 prints, so it must resolve to a non-empty value or the entry would fail closed to UNIQUE for the *wrong* reason (the `hash-object-hard-fail` guard, not the `bothloc` guard) |

No `rev-list.HEAD.out` or `diff-index.<sha>.rc` fixture is needed: `any_staged` is `1`
for this entry (`X='M'` is not space/`?`/`!`), so `dirt_staged_tree_commit` is invoked
once per worktree, but with no `rev-list.HEAD.out` present the stub replays empty
stdout / exit 0, the probe's `while` loop reads nothing and returns `1` (no match), and
this entry never reads `staged` at all because rung 1's `$y == " "` gate is false for
`Y='T'`. No `log.find-object.abcd1234.out` fixture is needed either: its absence makes
rung 5's history scan resolve empty, which is the desired *correct-code* fall-through to
`UNIQUE` (see below) rather than an ambiguous early exit.

**Derived expected output, correct/current code** (verified by trace, not run):

```
DIRTFILE|/repo-wt/dirt|UNIQUE||MT|src/typechange.dat
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

Trace: rung 1 skipped (`Y='T'≠" "`) → rung 2 no match → rung 3 not a project file → rung
4 tracked-half: `drc=0`, `erc=0`, `bothloc=1` (`M` and `T` both match `[MARCTU]`) → gate
`bothloc==0` is false → **no print** → hash-object reads `abcd1234` → rung 5: bounded
range defaults to `main~1000..main` (no `rev-parse.verify.main_1000` fixture, so `vrc=0`
and the bounded form is selected — same default `dirt_index_and_worktree_delta` relies
on) → `log --find-object=abcd1234` has no fixture → `found=""` → no print → rung 6:
`UNIQUE`.

**Derived expected output under the `[MARCTU]`→`[MARCU]` mutation**:

```
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||MT|src/typechange.dat
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
```

Under the mutant, `Y='T'` no longer matches `[MARCU]`, so `bothloc=0` even though the
index blob (`M`) is a distinct, unaccounted blob. The gate at line 325 then passes and
`CONTENT_ON_MAIN` is printed immediately — the ladder never even reaches the
hash-object/rung-5 reads. This is the exact "clears content held only in the index"
failure the header's "TWO LOCATIONS" and "ONE-SIDED BOUND ASYMMETRY" notes describe.

A bats test pinning this (positive direction, modeled directly on the suite's existing
near-miss pattern, e.g. `test_cleanup_worktrees_dirt_classify.bats:191-201` or
`test_cleanup_worktrees_dirt_failclosed.bats:232-246`) would read:

```bash
@test "dirt_typechange_delta: an MT entry whose working-tree content is on main is UNIQUE" {
    dirt dirt_typechange_delta
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||MT|src/typechange.dat'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|'* ]]
    [[ "$output" != *"CONTENT_ON_MAIN"* ]]
    [[ "$output" != *"ALL_DISPOSABLE"* ]]
}
```

**Optional enrichment (not separately fixture-traced here).** For symmetry with
`dirt_index_and_worktree_delta`'s two-route (`MM` on `src/a.cs` reaches rung 4;
`MM` on `src/b.cs` reaches rung 5) and control (`M ` on `docs/tracked.md`) design, a
second entry with `X='T'` (e.g. `TM src/typechange2.dat`, driven to the rung-5 route by
giving `diff-quiet..src_typechange2.dat.rc=1`, a `hash-object.src_typechange2.dat.out`,
and a `log.find-object.<that-blob>.out` that resolves non-empty) would additionally pin
that the **index-column** half of the class (`$x == [MARCTU]`) also depends on `T`. This
is not required to satisfy AC-1/AC-2 (a single `MT` entry already makes the mutation
observable in both directions), but strengthens the scenario to the same rigor as its
closest analogue.

**Coupling the plan must not miss.** `test_cleanup_worktrees_dirt_classify.bats:214-257`
hardcodes the scenario list (`for s in …`) and the total record count (`[ "$seen" -eq
38 ]`, comment at lines 251-254: "twenty-nine scenarios… thirty-eight records").
Independently counted via `Glob` over
`tests/fixtures/cleanup_worktrees/scenarios/dirt_*/status._repo-wt_dirt.out`: **29**
directories today (Numeric Derivation Evidence §C). Adding one new single-entry
scenario requires updating that list to 30 scenario names and the assertion to `[ "$seen"
-eq 39 ]` (and the explanatory comment), or the new suite's own "every verdict… six
defined tokens" test will fail on the `on_disk` cross-check even though nothing is
functionally wrong.
`test_cleanup_worktrees_dirt_content_locations.bats` discovers scenarios from disk
(`find "${SCEN}" -maxdepth 1 -type d -name 'dirt_*'`, lines 163 and 185) rather than
from a hardcoded list, so it requires no corresponding edit — it will pick up the new
scenario automatically. Because the new scenario's only non-`UNIQUE` verdict only
appears under the mutation (never on the checked-in, unmutated tree), it does not
change that suite's `examined`/`offenders` counts either.

## 2. `T` reachability and porcelain format

`T` can appear in **either** the X (index) column or the Y (worktree) column of a
`git status --porcelain` v1 two-character code, independently of the other column, per
git's own documentation of the porcelain v1 format (`X` = status vs `HEAD`, `Y` =
status vs the index; each column's letter set is `M A D R C U ? !` plus the space and,
for a type change, `T`). A combination pairing `T` with a *different* content-bearing
letter in the other column (e.g. `MT`, `TM`, `AT`) is a legitimate porcelain v1 shape:
a path that was staged as one kind of change and then independently type-changed again
in the working tree (or vice versa).

`cleanup_wt_git … status --porcelain` (`cleanup_worktrees_dirt_lib.sh:402`) is called
with **no** `--porcelain=v2` and no `-z`. This is porcelain **v1**, fixed-width
two-character-code text output — the same format the stub's `status)` case and every
existing fixture already assume (`xy="${line:0:2}"`, `rel="${line:3}"`). `-z` is never
used anywhere in this file. `remove_worktree_safe`'s diagnostic status read
(`cleanup_worktrees_actions_lib.sh:299`) uses the same plain `status --porcelain` form.

**Rename interaction.** Porcelain v1's `OLD -> NEW` payload form is triggered only by
`X == R` or `X == C` (`cleanup_worktrees_dirt_lib.sh:435`, `if [[ ${xy:0:1} == R ||
${xy:0:1} == C ]]`). `T` is not itself a rename indicator and never carries a second
path. However, `X` and `Y` are independent single letters, so a combination such as
`RT` (staged rename, further type-changed in the working tree relative to the index) or
`CT` is representable: the classifier's rename-split gate is keyed on `X` alone, so it
would still correctly split the `OLD -> NEW` payload and classify the **destination**
path, and that destination's content-bearing accounting would then also run through the
`[MARCTU]` class (`Y='T'` counts, `X='R'`/`'C'` counts) exactly as for any other
two-content-bearing-column pair. No scenario in the current corpus exercises `RT`/`CT`;
this is noted as a further edge case beyond the issue's stated `T`-in-one-column
requirement, not as a required addition.

## 3. Blind spot 2: the stub header block

Current header of `tests/fixtures/cleanup_worktrees/stub-bin/git` (quoted verbatim,
lines 1–78):

```
  1	#!/usr/bin/env bash
  2	# Recording git stub for the cleanup-worktrees bats suites, wired through the
  3	# CLEANUP_WT_GIT_BIN seam. It never touches a real repository and writes nothing to
  4	# disk: it replays canned stdout and exit codes from the scenario directory named by
  5	# CLEANUP_WT_STUB_SCENARIO, and echoes each invocation as a `stub-git: <argv>` line
  6	# to STDERR so tests can assert which commands ran. The invocation log is on stderr
  7	# (not stdout) so a caller capturing git stdout via command substitution receives
  8	# only the canned data; under bats `run` the stderr log still merges into $output.
  9	#
 10	# Lookup contract (documented so scenario fixtures under
 11	# tests/fixtures/cleanup_worktrees/scenarios/<name>/ match exactly):
 ...
 20	#   Path/ref characters outside [A-Za-z0-9._-] are replaced with `_` when forming a
 21	#   KEY (so refs/heads/x -> refs_heads_x, branch:path -> branch_path).
 22	#
 23	# KEY scheme by subcommand:
 24	#   add [--] <path>...                       -> add.<last non-flag operand>
 ...
 68	# No arm is defined for any subcommand that writes to the index or the object database.
 69	# The dirt classifier must reach its staged-tree answer by reading only, so defining
 70	# such an arm would make the report-mode non-mutation assertion unable to fail. The
 71	# assertion in tests/shell/test_cleanup_worktrees_dirt_clear.bats searches this file's
 72	# argv log for those subcommand names; adding one here would defeat it.
 73	#
 74	# Polarity trap for check-ignore, stated because the default is the wrong answer:
 ...
 79	set -uo pipefail
```

Lines 68–72 are the false statement (`add)` already exists, added for the
preserve-staging arm at issue #637). The KEY-scheme comment block (lines 23–64) already
lists `add [--] <path>... -> add.<last non-flag operand>` at line 24 — the comment
block itself is internally consistent (it documents the `add` arm); only the later
"No arm is defined… that writes" paragraph (lines 68–72) contradicts it.

**Every case arm in the stub that writes to the index or the object database**, with
production call sites and the mode that reaches them:

| stub arm | stub lines | production call site(s) | mode reached |
|---|---|---|---|
| `add)` | 152–162 | `cleanup_worktrees_preserve_lib.sh:400,402` (`preserve_commit_plan`) | `preserve` / `--preserve` only |
| `worktree add` (sub-arm of `worktree)`) | 189–196 | `cleanup_worktrees_actions_lib.sh:103` (`create_consolidation_worktree`) | **not reachable from any wrapper dispatch arm** (`report`/`--apply`/`preserve`) — see below |
| `worktree remove` (sub-arm of `worktree)`) | 189–196 | `cleanup_worktrees_actions_lib.sh:191` (`cleanup_consolidation_on_abort`, unreachable, see below); `cleanup_worktrees_actions_lib.sh:292` (`remove_worktree_safe`, reached via `delete_candidate` → `run_apply`) | `--apply`/`apply` |
| `cherry-pick)` (sha form, `--skip`, `--abort`) | 311–322 | `cleanup_worktrees_actions_lib.sh:147,157,164` (`cherry_pick_candidates`) | **not reachable from any wrapper dispatch arm** |
| `branch)` (`-D` sub-arm) | 323–328 | `cleanup_worktrees_actions_lib.sh:198` (consolidation teardown, unreachable); `cleanup_worktrees_actions_lib.sh:317` (`delete_branch`, reached via `delete_candidate` → `run_apply`) | `--apply`/`apply` |
| `reset)` (`reset --hard`) | 378–382 | `cleanup_worktrees_dirt_lib.sh:483` (`clear_disposable_dirt`) | `--apply --clear-disposable` only (opt-in flag, `cleanup_worktrees_actions_lib.sh:346-351`) |
| `clean)` (`clean -fd`) | 383–387 | `cleanup_worktrees_dirt_lib.sh:488` (`clear_disposable_dirt`) | `--apply --clear-disposable` only |

**"Not reachable from any wrapper dispatch arm" finding.** `create_consolidation_
worktree`, `cherry_pick_candidates`, and `cleanup_consolidation_on_abort`
(`cleanup_worktrees_actions_lib.sh:79-206`) are defined but have **no caller** anywhere
under `run_report`, `run_apply`, or `run_preserve` (confirmed by `Grep` for each
function name across `scripts/bash/*.sh`: the only hits are the definitions themselves
and doc comments). `cleanup-worktrees.sh`'s dispatch (`main()`, lines 152-214) only
routes to `run_report | run_apply | run_preserve | usage`. These three functions are
exercised solely by `tests/shell/test_cleanup_worktrees_consolidation.bats`, which
drives them directly by function call, not through the wrapper. This means `worktree
add`, one of the two `worktree remove` call sites, and all of `cherry-pick` are
currently **dead from the CLI's perspective** — worth flagging to whoever writes AC-3's
header text, since "the code paths permitted to call each one" should record this
orphaned status rather than imply a live dispatch route that doesn't exist.

**Read-only arms** (for contrast, not requiring a header change): `check-ignore`,
`for-each-ref`, `merge-base`, `rev-list`, `diff` (including `--cached`, which *reads*
the index rather than writing it), `cherry`, `diff-tree`, `ls-tree`, `rev-parse`,
`status`, `fetch`, `remote`, `hash-object` (explicitly documented at stub lines 335-338
as read-only — "The stub defines no -w behavior because the dirt classifier never
writes an object"), `log`, `diff-index`.

Report mode (`run_report`) reaches **none** of the writing arms — this is exactly what
`test_cleanup_worktrees_dirt_clear.bats:205-222` already asserts (see §4), and is
consistent with the header's own "READ-ONLY GUARANTEE" paragraph in
`cleanup_worktrees_dirt_lib.sh:14-20`.

## 4. The report-mode non-mutation assertion

Test: `"dirt_staged_tree_is_commit: report mode issues no mutating git command and
redirects no index"`, file `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, lines
205–222.

```bash
@test "dirt_staged_tree_is_commit: report mode issues no mutating git command and redirects no index" {
    report_run dirt_staged_tree_is_commit
    log="$(argv_log)"
    [[ "$log" == *"diff-index --cached --quiet"* ]]
    [[ "$log" != *"write-tree"* ]]
    [[ "$log" != *"stub-git-env"* ]]
    [[ "$log" != *"/index"* ]]
    ! printf '%s\n' "$log" | grep -qE '(^| )reset( |$)'
    ! printf '%s\n' "$log" | grep -qE '(^| )clean( |$)'
    [[ "$log" != *"worktree remove"* ]]
    [[ "$log" != *"branch -D"* ]]
    [[ "$log" != *"hash-object -w"* ]]
}
```

Current denylist: `write-tree`, `stub-git-env` (the `GIT_INDEX_FILE` environment
sentinel), `/index`, `reset`, `clean`, `worktree remove`, `branch -D`, `hash-object -w`.
**`add`, `commit`, and `update-index` are absent.** `write-tree` is already present
(the issue names it alongside the three missing ones; it does not need to be added).

`argv_log()` is defined at lines 79–85 of the same file: `printf '%s\n' "$output" |
grep '^stub-git' `, reading the merged bats `$output` for lines the stub's
`printf 'stub-git: %s\n' "$*" >&2` (stub-bin/git line 82) writes to stderr. bats' `run`
merges stderr into `$output`, so this is the same "argv log" mechanism every other
absence assertion in this file already relies on. `report_run()` (lines 73-77) drives
`run_report` with the stub wired in via `CLEANUP_WT_GIT_BIN`/`CLEANUP_WT_SCAN_BIN`/
`CLEANUP_WT_STUB_SCENARIO`.

**Recommended smallest change (AC-4):** extend the same test's denylist with three more
negative assertions, in the same substring style as the existing ones:

```bash
    [[ "$log" != *" add "* ]]
    [[ "$log" != *" commit "* ]]
    [[ "$log" != *"update-index"* ]]
```

This is the "asserts that `add`, `commit`, `write-tree`, and `update-index` never
appear" branch of AC-4's either/or, and is the smaller of the two options: an allowlist
would require enumerating every legitimate report-mode-reachable subcommand (`status`,
`diff`, `diff-index`, `hash-object`, `log`, `rev-parse`, `rev-list`, `merge-base`,
`cherry`, `diff-tree`, `ls-tree`, `for-each-ref`, `worktree list`, `check-ignore`,
`fetch`, `remote`) and would touch more of the test's structure for no additional
protection given the fixed, small stub surface. The denylist extension is a 3-line
diff inside an already-existing test and matches the "smallest change" framing of AC-4
and the issue's stated minimal blast radius.

**AC-5 negative control, without temporary files or a persisted production edit.**
`test_cleanup_worktrees_dirt_guard_registry.bats` already establishes, and uses
throughout its suite, the pattern needed here: compose a modified library's source into
a shell variable with `sed` (`mutate_lib()`, lines 76–80), never write it to disk, and
`eval` it in a child `bash -c` process in place of `source`-ing the real file
(`run_child()`, lines 99–123). Its own header states the property this satisfies: "NO
TEMPORARY FILES. The mutated source never reaches disk." (lines 43–44).

Applying the same idiom to AC-5: compose a one-line-modified copy of
`scripts/bash/cleanup_worktrees_lib.sh` (the file that defines `run_report`, at line
452) that inserts one `cleanup_wt_git add -- test-negative-control` call near the top
of `run_report`'s body, entirely inside a `sed`-into-variable pipeline; `eval` that
variable in a child process (sourcing the real `cleanup_worktrees_enumerate_lib.sh`,
the real `cleanup_worktrees_report_records_lib.sh`, the real
`cleanup_worktrees_detached_lib.sh`, and the real `cleanup_worktrees_dirt_lib.sh`
unmodified — only `cleanup_worktrees_lib.sh`'s in-memory copy carries the injected
call); run the widened AC-4 assertion against that child's argv log and confirm it now
fails on the injected `add`. Because the mutated source is composed in a shell variable
and evaluated in a subshell, `scripts/bash/cleanup_worktrees_lib.sh` on disk is never
opened for writing, so "the production file is byte-identical to `origin/main`
afterward" is trivially and provably true (it was never touched), and no temporary file
is created — satisfying the general unit-test policy's prohibition even though this
one-time verification step is not itself a permanent, checked-in test. The captured
child output (the failing widened-assertion run, or the differing argv-log excerpt) is
what AC-5 asks to be "recorded as evidence."

## Rejected alternatives

- **A permanent `dirt-guard-registry.tsv` row for the narrower `[MARCTU]→[MARCU]`
  mutation**, reusing the existing guard-registry mechanism verbatim (add a second row
  under the `index-and-worktree-both-hold-content` id, alongside row 41's existing
  whole-condition mutation; multiple rows per id are already supported by that
  suite's `pin_count()`/obligation-2 logic). This would give *permanent*, ongoing
  regression protection against exactly this narrower mutation, not just a one-time
  verification. It is rejected as the primary recommendation only because it exceeds
  the issue's stated minimal blast radius (`tests/fixtures/cleanup_worktrees/stub-bin/
  git`, one new scenario directory, and "the affected suites under
  `tests/shell/test_cleanup_worktrees_*.bats`") by also requiring an edit to the
  `LIT_IDS`/`LIT_MUTS` arrays in `test_cleanup_worktrees_dirt_guard_registry.bats`'s
  first test (obligation 7 requires every registry row's mutation to be one of a fixed,
  enumerated set). AC-1's new bats test, asserted directly against the real,
  un-mutated production `dirt_lib.sh`, already provides equivalent ongoing regression
  protection for any *actual* future edit that narrows the class — the guard-registry
  route would only add protection against someone re-narrowing the class in a way that
  happens to leave the AC-1 test's own scenario byte-identical, which is a materially
  smaller residual gap. This alternative is worth flagging to the plan author as an
  optional follow-up, not a requirement of this ticket.

## 5. Toolchain

Per `.claude/rules/shell.md` (mirrored from `.github/instructions/`), the shell
toolchain is native bash, invoked via `scripts/bash/shell-qc.sh
{check|format|test [--coverage]}`, with no Python/Poetry dependency. `check` runs
`shfmt -d` once over the discovered file list then `shellcheck` once per file; `format`
runs `shfmt -w`; `test` runs `bats` once per discovered test directory
(`find_bats_test_dirs()`, `shell_qc_lib.sh:104-120`, which checks `tests/shell` then
`tests/bash`); `test --coverage` runs the same under `kcov`.

**Discovery does not reach the changed files.** `discover_shell_scripts()`
(`shell_qc_lib.sh:75-102`) walks only `tools/`, `scripts/`, and `.claude/lib/bash/`
(confirmed identical in `.claude/rules/shell.md`'s "Discovery Contract"). `tests/` is
not a search root. This means **shfmt and shellcheck never run against `.bats` files or
against the extensionless stub `tests/fixtures/cleanup_worktrees/stub-bin/git`** — the
stub's shebang would otherwise qualify it (`#!/usr/bin/env bash`), but it sits outside
every search root, so `is_shell_script()` is never even called on it. AC-7's "format,
lint" clause is therefore, for this issue's actual blast radius, vacuously satisfied by
`scripts/bash/shell-qc.sh check` — the command is still worth running as a whole-repo
regression check, but it will not itself see the header-comment edit or the new
scenario fixtures. The only stage of the toolchain that actually exercises the changed
files is `scripts/bash/shell-qc.sh test`, via `find_bats_test_dirs()` picking up
`tests/shell`.

**Expected output of a successful run**, derived from `run_test()`
(`shell_qc_lib.sh:226-254`): the wrapper prints nothing of its own beyond what `bats
"$test_dir"` prints for each of `tests/shell` (and `tests/bash` if present); it does not
add a custom pass-count summary line. `bats`'s own default (non-TTY) output is TAP:
a `1..N` header followed by one `ok <n> <description>` line per passing test and `not
ok <n> <description>` for a failure. A "successful run" is therefore identifiable by
the absence of any `not ok` line and by the final ordinal in the `ok` lines matching
the `1..N` header — there is no separate "X tests, Y failures" sentence unless a
different bats formatter is explicitly selected, which `run_test()` does not do.

**Windows / worktree execution route.** Per `.claude/rules/shell.md`, "On Windows, run
the toolchain under WSL," and CI runs on `ubuntu-latest`. Per this agent's own prior
memory of this repository's tooling (worktree isolation guard denies command text
containing `bash`, `pwsh`, or `wsl`), a direct `bash scripts/bash/shell-qc.sh test`
invocation is expected to be denied by that hook inside an agent worktree. A form that
avoids the literal substring `bash` — for example `sh scripts/bash/shell-qc.sh test` or
invoking `bats` directly via `npx --yes bats tests/shell` — is the documented
workaround; this research agent did not attempt either (no execution tool was
available in this session), so whether it actually succeeds on this Windows host is
**not verified here** and should be confirmed by whichever agent implements the fix, with
CI as the authoritative confirming gate per the issue's own "Dependencies / Risks"
section.

## 6. Coverage policy applicability

Per `.claude/rules/general-unit-test.md` and `.claude/rules/shell.md`: kcov measures
**line coverage only** for bash (no branch-coverage gate for bash/PowerShell), over the
same three discovery roots as shfmt/shellcheck (`tools/`, `scripts/`, `.claude/lib/
bash/`), explicitly **excluding `tests/`**. This issue's entire blast radius (a new
scenario directory under `tests/fixtures/`, edits to `.bats` files under `tests/shell/`,
and a comment-only edit to `tests/fixtures/.../stub-bin/git`) is therefore **outside the
kcov coverage denominator entirely** — no production file is touched (AC-6), so there is
no changed-line coverage obligation to satisfy for this change, and the repo-wide kcov
percentage is not expected to move (the new scenario re-exercises an already-covered
line, `cleanup_worktrees_dirt_lib.sh:297`, rather than covering a previously-uncovered
one). Running `shell-qc.sh test --coverage` and recording its "Bash coverage (lines):
NN.N%" line as evidence is still consistent with the repository's general
evidence-recording practice, but AC-7's literal text ("format, lint, and the
cleanup-worktrees bats suites") does not itself name coverage, and no coverage
regression is possible from a test-only change with zero production lines modified.

Note (out of scope, recorded for completeness): `CLAUDE.md` and
`.claude/rules/quality-tiers.md` both reference a repository-root `quality-tiers.yml` as
the tier-classification source of truth; a `Glob` for `**/quality-tiers.yml` in this
tree returned no match. This is a pre-existing inconsistency unrelated to #660 and does
not affect the bash-specific coverage rules above, which are stated directly and
completely in `.claude/rules/shell.md` without needing the tier file.

## Numeric Derivation Evidence

### §A — `[MARCTU]` occurs exactly once in `cleanup_worktrees_dirt_lib.sh`

- **Complete Family:** every occurrence of the literal substring `[MARCTU]` (or its
  mutant form `[MARCU]`) in `scripts/bash/cleanup_worktrees_dirt_lib.sh`.
- **Exhaustive Search Scope:** the single 496-line file
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`.
- **Inclusion Rules:** any line containing the substring.
- **Exclusion Rules:** none; the file was read in full.
- **Primary Search Strategy:** `Grep` tool, pattern `MARCTU|MARCU`, scoped to the file.
- **Primary Member Set:** `{line 297}`
- **Primary Count:** 1
- **Cross-check Search Strategy:** full-file `Read` of all 496 lines (performed at the
  start of this research) and a manual scan of the returned text for the token.
- **Cross-check Member Set:** `{line 297}`
- **Cross-check Count:** 1
- **Member-set Comparison:** identical; both methods name line 297 and no other line.

### §B — no existing scenario status fixture contains `T` in either column

- **Complete Family:** every porcelain status line in every `status*.out` fixture under
  `tests/fixtures/cleanup_worktrees/scenarios/`.
- **Exhaustive Search Scope:** `tests/fixtures/cleanup_worktrees/scenarios/**/
  status*.out`.
- **Inclusion Rules:** a line whose first or second character is the literal `T`.
- **Exclusion Rules:** none.
- **Primary Search Strategy:** `Grep` tool, pattern `^.T|^T.`, glob `status*.out`, path
  `tests/fixtures/cleanup_worktrees/scenarios`.
- **Primary Member Set:** `{}` (no matches).
- **Primary Count:** 0
- **Cross-check Search Strategy:** independent, code-level source —
  `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`'s own second test
  ("every classifier-relevant status-code class is covered by a checked-in dirt
  scenario", lines 173–208), which computes the union of every two-character status
  code across every `dirt_*` scenario's status fixture at bats runtime and asserts
  membership only for the eight classes `??`, `M `, `A `, `R `, ` M`, `AD`, `MM`, `UU`
  (its `want` list, line 199) — none containing `T`.
- **Cross-check Member Set:** `{}` (the enumerated eight-class `want` list names no
  `T`-bearing code, and its own explanatory comment at lines 187–198 does not mention
  `T`).
- **Cross-check Count:** 0
- **Member-set Comparison:** identical; both an independent grep over every fixture
  file and the pre-existing test's own hardcoded status-code coverage list agree that
  `T` is unrepresented in the corpus.

### §C — the hardcoded scenario list currently names 29 scenarios / 38 records

- **Complete Family:** every `dirt_*` scenario directory under
  `tests/fixtures/cleanup_worktrees/scenarios/` that carries a
  `status._repo-wt_dirt.out` fixture.
- **Exhaustive Search Scope:** `tests/fixtures/cleanup_worktrees/scenarios/dirt_*/`.
- **Inclusion Rules:** one member per directory.
- **Exclusion Rules:** none.
- **Primary Search Strategy:** direct `Read` of
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats` lines 214–257 and manual
  enumeration of the `for s in …` token list.
- **Primary Member Set:** `{dirt_build_artifact, dirt_build_artifact_added_file,
  dirt_build_artifact_empty_diff, dirt_build_artifact_mixed,
  dirt_build_artifact_plus_content, dirt_classifier_read_error,
  dirt_clear_all_disposable, dirt_clear_clean_failed, dirt_clear_reset_failed,
  dirt_clear_reverify_order, dirt_content_in_history, dirt_content_on_main,
  dirt_history_depth_fallback, dirt_history_read_error,
  dirt_index_and_worktree_delta, dirt_mixed_unique_blocks, dirt_pipe_path,
  dirt_quoted_path, dirt_rename_split, dirt_session_artifact,
  dirt_staged_probe_diffindex_error, dirt_staged_probe_revlist_error,
  dirt_staged_tree_is_commit, dirt_staged_tree_no_match,
  dirt_staged_tree_worktree_delta, dirt_tracked_probe_error_in_history,
  dirt_tracked_read_errors, dirt_tracked_staged_only_blob, dirt_unique}`
- **Primary Count:** 29 (with the same test's own `seen -eq 38` total-record
  assertion).
- **Cross-check Search Strategy:** `Glob` tool, pattern
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_*/status._repo-wt_dirt.out`
  (filesystem-level enumeration, independent of reading the test file's list).
- **Cross-check Member Set:** the 29 directory names returned by that `Glob` call
  (`dirt_build_artifact`, `dirt_build_artifact_added_file`, …, `dirt_unique` — the same
  29 names as the primary set, verified by direct comparison).
- **Cross-check Count:** 29
- **Member-set Comparison:** identical (29 == 29); confirms the plan must extend this
  list to 30 names and the record-count assertion to 39 when the new `dirt_
  typechange_delta` scenario (one entry) is added.

## Automation Feasibility

No step required by AC-1 through AC-7 requires human interaction. Writing the new
scenario fixture set, editing the stub header comment, extending the non-mutation
denylist, running the bats suites, and performing the two negative controls via the
established sed-into-variable/`eval`-without-disk-write idiom are all executable by an
agent with a working bash-capable shell tool. The only human-facing item in the issue is
explicitly marked informational and is **not** an acceptance criterion: "Manual
verification note from the issue… confirm on a real repository that `git status
--porcelain` reports `T` for a file-to-symlink replacement on the platform in use"
(issue.md, Verification Steps). Nothing in AC-1 through AC-7 depends on that manual
check having been performed.

The one caveat is environmental rather than procedural: this research session's own
tool set had no `Bash`/`PowerShell` execution capability, so none of the traces above
were run; a future implementing agent will need a route past the worktree's
bash/pwsh/wsl-text denial hook (e.g. `sh <file>.sh`, `npx --yes bats <path>`, or
executing from a non-denying shell) to actually execute the toolchain locally, with CI
as the confirming gate regardless, per the issue's own "Dependencies / Risks" section.

## Requirements Mapping (design summary)

| AC | Concrete design |
|---|---|
| AC-1 | New directory `tests/fixtures/cleanup_worktrees/scenarios/dirt_typechange_delta/` (fixture set in §1.4) + one new `@test` in `tests/shell/test_cleanup_worktrees_dirt_classify.bats` (or a new file, at the plan author's discretion) pinning `DIRTFILE|/repo-wt/dirt|UNIQUE||MT|src/typechange.dat` and `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`. Requires updating the hardcoded scenario list and `seen` count in `test_cleanup_worktrees_dirt_classify.bats:214-257` (29→30 scenarios, 38→39 records). |
| AC-2 | One-time verification using the `sed`-into-variable + `eval`-in-subshell idiom already established by `test_cleanup_worktrees_dirt_guard_registry.bats` (§4/§1.4), mutating `[MARCTU]`→`[MARCU]` at line 297 of an in-memory copy only, run against `dirt_typechange_delta`, showing the AC-1 assertion's expected line differs (`CONTENT_ON_MAIN`/`ALL_DISPOSABLE` instead of `UNIQUE`/`HAS_UNIQUE`); production file never written to disk, so "byte-identical to origin/main" is automatic. Captured output recorded as evidence. |
| AC-3 | Replace the false paragraph at `stub-bin/git:68-72` with the arm/call-site/mode table in §3, explicitly noting the three orphaned (wrapper-unreachable) arms. |
| AC-4 | Three-line denylist extension to the existing test at `test_cleanup_worktrees_dirt_clear.bats:205-222` (`add`, `commit`, `update-index`; `write-tree` already present). |
| AC-5 | Same sed/eval-without-disk-write idiom applied to an in-memory copy of `cleanup_worktrees_lib.sh` (which defines `run_report` at line 452), injecting one `cleanup_wt_git add -- test-negative-control` call and showing the widened AC-4 assertion fails against that child's argv log; production file never written to disk. |
| AC-6 | Confirmed achievable: every file named above is under `tests/` or `tests/fixtures/`; no path under `scripts/` needs to change for any of AC-1 through AC-5. |
| AC-7 | `scripts/bash/shell-qc.sh check` (vacuously passes — it does not discover `tests/`, §5) and `scripts/bash/shell-qc.sh test` (the stage that actually exercises the new scenario and the two edited `.bats` files) should both be run and their output recorded as evidence; no coverage regression is possible since no production file changes (§6). |

## File paths referenced

- `scripts/bash/cleanup_worktrees_dirt_lib.sh`
- `scripts/bash/cleanup_worktrees_actions_lib.sh`
- `scripts/bash/cleanup_worktrees_preserve_lib.sh`
- `scripts/bash/cleanup_worktrees_lib.sh`
- `scripts/bash/cleanup-worktrees.sh`
- `scripts/bash/shell-qc.sh`, `scripts/bash/shell_qc_lib.sh`
- `tests/fixtures/cleanup_worktrees/stub-bin/git`
- `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
- `tests/fixtures/cleanup_worktrees/scenarios/dirt_index_and_worktree_delta/*`
- `tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/*`
- `tests/shell/test_cleanup_worktrees_dirt_classify.bats`
- `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
- `tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
- `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
- `tests/shell/test_cleanup_worktrees_dirt_clear.bats`
- `.claude/rules/shell.md`, `.claude/rules/general-unit-test.md`
- `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/issue.md`
