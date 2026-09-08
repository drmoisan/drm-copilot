# Remediation Plan — cleanup-worktrees dirt classifier (Issue #632), cycle 2

- Timestamp: 2026-09-08T06-51 (UTC)
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/`
- Work mode: `full-bug` (`issue.md:12`). Acceptance-criteria source is `spec.md`,
  `## Acceptance Criteria` section only.
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
- Worktree: `.claude/worktrees/agent-ac72d35e7980bc69d`
- Findings source: `remediation-inputs.2026-09-08T06-51.md`,
  `code-review.2026-09-08T06-51.md`, `feature-audit.2026-09-08T06-51.md`,
  `policy-audit.2026-09-08T06-51.md`
- Preflight round 1 delta applied:
  `evidence/other/preflight-round-1-delta.2026-09-08T14-00.md` (D-1 through D-10).
- Preflight round 2 delta applied:
  `evidence/other/preflight-round-2-delta.2026-09-08T15-10.md` (B1 through B7, NB-1 through
  NB-7). Four round-2 departures are recorded in the departures section below.
- Preflight round 3 delta applied:
  `evidence/other/preflight-round-3-delta.2026-09-08T17-00.md` (BD1 through BD3, NB-A
  through NB-H). Three round-3 departures are recorded in the departures section below.
- Preflight round 4 delta applied:
  `evidence/other/preflight-round-4-delta.2026-09-08T19-00.md` (BD-A, BD-B, NB-1 through
  NB-9; NB-9 is an observation about handoff signals and required no plan change). Two
  round-4 departures are recorded in the departures section below.
- Blocking findings: 2 (N1, N2). Non-blocking carried into scope: 1 (O1).
- Cycle 1 exit status: all six cycle-1 findings (R1 through R6b) verified closed. This
  cycle does not revisit them; it must not disturb them.

## Scope

Three obligations.

1. **N1** — rung 4's tracked half resolves `CONTENT_ON_MAIN` from a `git diff --quiet`
   exit 0 that also means "the pathspec matched nothing". An `AD` entry, whose content
   exists only as a staged blob, therefore aggregates `ALL_DISPOSABLE` and is destroyed
   by `--clear-disposable`. Data loss.
2. **N2** — four guards at `scripts/bash/cleanup_worktrees_dirt_lib.sh:213`, `:301`,
   `:311`, and `:336` whose removal leaves every checked-in `dirt_*` scenario
   byte-identical. Each is covered and named by a passing test that cannot fail when the
   guard is violated.
3. **The systemic finding** — two consecutive cycles have shipped a data-loss defect
   that passed the whole 45-criterion set. Neither N1 nor N2 maps to any criterion. This
   cycle adds the general criterion the reviewer proposed and, more importantly, makes it
   machine-enforced: the guards are enumerated from the library source, each is
   registered, and a bats gate fails when a registered guard's neutralization is not
   observable through a named checked-in scenario.

Out of scope, carried forward unchanged: F7 through F13, F14's documentation half, the
ten residual uncovered lines, and observations O2 through O5. `cleanup_worktrees_lib.sh`
is not modified by this cycle.

## Constraints that bound every task

- `scripts/bash/cleanup_worktrees_dirt_lib.sh` is **463** lines at the start of this
  cycle. `scripts/bash/cleanup_worktrees_lib.sh` is **496** and is excluded from
  modification. No production, test, or reusable shell file may reach 500 lines.
- No temporary files in tests. Every fixture is checked in under
  `tests/fixtures/cleanup_worktrees/scenarios/`.
- Every git call goes through the `cleanup_wt_git` seam; tests drive
  `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO`.
- Report mode stays non-mutating. No new subcommand that writes the index or the object
  database may be introduced, and none may be added to
  `tests/fixtures/cleanup_worktrees/stub-bin/git`.
- Both directions of every classification stay pinned.
- All evidence goes to
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`.
  No `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or
  `artifacts/evidence/` path is valid for evidence in this plan.

## Gate ownership

`shfmt`, `shellcheck`, and `bats` have a local route in this worktree; `bats` is supplied
through the documented `SHELL_QC_BATS_BIN` seam or invoked directly as
`npx --yes bats`. `kcov` has **no** local route: `bash scripts/bash/shell-qc.sh test --coverage`
exits 127 here. Coverage is measured only by a dispatch of
`.github/workflows/_shell-coverage.yml` against a pushed commit, and the numbers are read
from that run's merged Cobertura artifact. No task in this plan asserts a local coverage
figure.

The current measured position, from CI run `34194469882`: 404 tests, 0 failures, 93.7%
repository-wide line coverage, 94.05% on `scripts/bash/cleanup_worktrees_dirt_lib.sh`.

`run_check` at `scripts/bash/shell_qc_lib.sh:164-202` runs `shfmt -d` once over the
discovered file list and then `shellcheck` once per file. Neither tool prints anything on
a clean run, and `run_check` prints no summary of its own, so **there is no findings count
to read from a passing invocation**. Every task in this plan that runs
`bash scripts/bash/shell-qc.sh check` therefore records the command's combined stdout and
stderr verbatim and asserts that it is empty, rather than asserting a printed count.
`run_format` at `:204-224` likewise prints nothing on success, which is why the format
tasks carry before-and-after tree observations instead of an output assertion.

## Design decisions this plan fixes

These are settled here so no task has to choose.

**D1 — the N1 guard.** Rung 4's tracked half keeps `git diff --quiet main -- "$rel"` as
its first read. When that read exits 0, the positive verdict becomes conditional on the
path being present in `main`, probed through the same seam with
`cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet "main:$rel"`.
The exit code is captured in the parent shell into a new local `erc`, following the
library's stated capture rule. Only `erc` equal to 0 emits `CONTENT_ON_MAIN`; any other
value falls through without emitting, so the entry advances to the `hash-object` guard,
which is where an `AD` entry fails closed to `UNIQUE`.

`ls-files --error-unmatch` was considered and rejected: an `AD` path is present in the
index, so that probe exits 0 for exactly the entry the guard must catch. `rev-parse
--verify --quiet main:<path>` answers the question the inference actually rests on —
whether `main` has content at that path to be equal to — and it is a read.

The stub already keys `rev-parse --verify --quiet <ref>` as
`rev-parse.verify.<sanitized ref>` at `tests/fixtures/cleanup_worktrees/stub-bin/git:270-271`,
and its documented sanitizer maps `branch:path` to `branch_path`
(`stub-bin/git:17-18`), so `main:staged_only.md` keys as
`rev-parse.verify.main_staged_only.md`. No stub change is required, and no existing
scenario supplies that key for a tracked path, so every existing scenario replays the
documented stub default of empty stdout and exit 0 (`stub-bin/git:16`) and its verdict is
unchanged.

The new read is redirected with `>/dev/null` only, **not** with `>/dev/null 2>&1`. The
existing bounded-range probe at `cleanup_worktrees_dirt_lib.sh:331-332` suppresses both
streams, and that is the one shape not to copy here: the stub writes its `stub-git: <argv>`
log to stderr (`stub-bin/git:74`), so `2>&1` would erase this invocation from the argv log
and make it unobservable to every argv assertion and to the `ARGV` row kind defined in D3.
`--quiet` already suppresses real git's own diagnostic on the negative answer, so nothing
is gained by the second redirect.

Reachability of the new read, re-derived against the current tree so the narrowing does
not change an existing verdict. The read is issued only when `drc` is 0. Every one of the
eighteen tracked (non-`??`) status entries across the twenty-five checked-in `dirt_*`
scenarios was traced through the ladder. **Six** of them reach rung 4's tracked half:

| Scenario | Status entry | `diff-quiet..<path>.rc` | `drc` | Reaches the new read |
|---|---|---:|---:|---|
| `dirt_rename_split` | `R  old.md -> new.md` | no fixture, stub default `0` | `0` | **yes** |
| `dirt_build_artifact_mixed` | ` M src/Legacy/Legacy.csproj` | `1` | `1` | no |
| `dirt_build_artifact_plus_content` | ` M src/Legacy/Legacy.csproj` | `1` | `1` | no |
| `dirt_staged_tree_no_match` | `M  src/a.cs` | `1` | `1` | no |
| `dirt_staged_tree_worktree_delta` | `MM src/a.cs` | `1` | `1` | no |
| `dirt_tracked_read_errors` | ` M docs/tracked.md` | `128` | `128` | no |

Five of the six supply a non-zero `diff-quiet` fixture and therefore never reach the new
read. `dirt_rename_split` is the single entry that reaches it; the R-entry's payload is
split at `:403` so the classified path is `new.md`, it supplies no
`rev-parse.verify.main_new.md` fixture, and it therefore replays the stub default of empty
stdout and exit 0 (`stub-bin/git:16`), keeping its `CONTENT_ON_MAIN` verdict.

`dirt_build_artifact_added_file` was checked and does **not** belong in that table, which
is a correction to this plan's earlier seven-row form. Its entry is
`A  src/Legacy/Legacy.csproj`. Rung 1's gate at `:260` is true for `A `, but the scenario
supplies no `rev-list.HEAD.out`, so the staged-tree probe replays the stub default, returns
1, and `staged` is empty; the branch falls through without emitting. Rung 3 then resolves
it: the scenario supplies no worktree-diff payload, so
`dirt_diff_is_hintpath_confined` sees empty stdout with rc 0 and echoes `0` changed lines,
while `diff-cached._repo-wt_dirt.src_Legacy_Legacy.csproj.out` carries one
`+      <HintPath>...` content line and echoes `1`. `total` is therefore 1,
`((total == 0))` at `:213` does not fire, `dirt_is_build_artifact` returns 0, and the entry
resolves `DISPOSABLE_BUILD_ARTIFACT` at `:283-284` — the verdict is printed at `:283` and
the function returns at `:284`. It never issues `diff --quiet main`, so its
`diff-quiet..src_Legacy_Legacy.csproj.rc` fixture — which does exist and contains `1` — is
never read. `tests/shell/test_cleanup_worktrees_dirt_classify.bats:354` pins that verdict.

The twelve tracked entries that do not reach rung 4's tracked half at all resolve earlier:
`dirt_build_artifact`, `dirt_clear_all_disposable`, `dirt_clear_clean_failed`,
`dirt_clear_reset_failed`, `dirt_clear_reverify_order`, and
`dirt_build_artifact_added_file` resolve `DISPOSABLE_BUILD_ARTIFACT` at rung 3;
`dirt_tracked_read_errors`' csproj entry resolves `UNIQUE` at `:287` because its worktree
diff read returns 128; `dirt_staged_probe_diffindex_error` and
`dirt_staged_probe_revlist_error` resolve `UNIQUE` at `:262` on `staged == "ERROR"`; and
both entries of `dirt_staged_tree_is_commit` plus `dirt_staged_tree_worktree_delta`'s
`M  src/b.cs` resolve `STAGED_TREE_IS_COMMIT` at `:266`.

**D2 — the guard registry and its coverage obligation.** The registry's obligation is a
**superset** of the arithmetic enumeration, because the arithmetic regex alone excludes
every guard shape that carried R1, R2, and R5 in cycle 1.

*Part one — the mechanical enumeration.* A guard-shaped line is any line in
`scripts/bash/cleanup_worktrees_dirt_lib.sh` matching the extended regular expression
`\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)` — an arithmetic comparison of a
variable against a numeric literal. Re-derived against the current tree, there are exactly
**30** such lines: 97, 102, 109, 113, 167, 207, 208, 210, 211, 213, 280, 282, 286, 294,
297, 301, 311, 318, 321, 333, 336, 371, 385, 387, 388, 414, 415, 444, 452, 457. After D1
adds `((erc == 0))` there are **31**. Every one of the 31 must carry a `# guard:<id>`
marker and must have at least one registry row.

*Part two — the named non-arithmetic verdict guards.* The registry must additionally carry
a row for each of these eight guards, none of which the regex matches, and three of which
are the exact sites that produced R1, R2, and R5:

| Cycle-start line | Source text | Marker id | Mutation (complete `sed` `s` command) | Cycle-1 finding |
|---:|---|---|---|---|
| 172 | `"--- a/"* \| "+++ b/"* \| "--- /dev/null" \| "+++ /dev/null") continue ;;` | `diff-header-skip` | `s%continue ;;%;;%` | R5 |
| 260 | `if [[ $x != " " && $x != "?" && $x != "!" && $y == " " ]]; then` | `rung1-y-column-gate` | `s% && $y == " "%%` | R1 |
| 311 | `[[ -z $blob ]]`, the second half of `if ((hrc != 0)) \|\| [[ -z $blob ]]; then` | `hash-object-hard-fail` | `s% \|\| \[\[ -z $blob \]\]%%` | — |
| 321 | `[[ -n $mainblob && $mainblob == "$blob" ]]`, the second half of line 321 | `rung4-untracked-main-present` | `s%\[\[ -n $mainblob && $mainblob == "$blob" \]\]%[[ -n "x" ]]%` | — |
| 341 | `if [[ -n $found ]]; then` | `history-hit-nonempty` | `s%\[\[ -n $found \]\]%[[ -n "" ]]%` | — |
| 403 | `if [[ ${xy:0:1} == R \|\| ${xy:0:1} == C ]]; then` | `rename-payload-split-gate` | `s%== C \]\]%== C \|\| -n "x" \]\]%` | R2 |
| 410 | `[[ $verdict == "UNIQUE" ]] && unique_count=$((unique_count + 1))` | `unique-verdict-tally` | `s%\[\[ $verdict == "UNIQUE" \]\]%[[ -n "" ]]%` | — |
| 447 | `if [[ $agg != "ALL_DISPOSABLE" ]]; then` | `clear-requires-all-disposable` | `s%\[\[ $agg != "ALL_DISPOSABLE" \]\]%[[ -n "" ]]%` | — |

**Two escaping classes appear in the `Mutation` column above and they are not the same
thing.** `\[` and `\]` are genuine `sed` escapes and MUST be carried into the registry
verbatim: in a POSIX basic regular expression `[` opens a bracket expression, so matching a
literal `[[` requires `\[\[`. `\|` is **not** a `sed` escape here. It is GitHub-flavoured
Markdown table escaping for a literal `|`, which cannot appear unescaped inside a table
cell. In GNU `sed`'s basic regular expressions `\|` is the alternation operator, so a
pattern carrying `\|` where a literal pipe was meant matches an empty alternative at
column 0, substitutes nothing, leaves the library source unchanged, and fails P2-T6's
assertion 2. Two rows are affected. Their `mutation` values, quoted here outside the table
so the executor copies the unescaped form into
`tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`, are exactly:

```
s% || \[\[ -z $blob \]\]%%
s%== C \]\]%== C || -n "x" \]\]%
```

The first belongs to the `hash-object-hard-fail` row at line 311 and reduces
`if ((hrc != 0)) || [[ -z $blob ]]; then` to `if ((hrc != 0)); then`. The second belongs to
the `rename-payload-split-gate` row at line 403 and widens
`if [[ ${xy:0:1} == R || ${xy:0:1} == C ]]; then` to
`if [[ ${xy:0:1} == R || ${xy:0:1} == C || -n "x" ]]; then`, which is always true. `$` in
both patterns is mid-pattern and therefore a literal dollar sign in a basic regular
expression, not an anchor; the harness must pass the composed program to `sed` as a single
argument and must never `eval` it, because `eval` would expand `$blob` and `$agg` to the
empty string before `sed` saw them. The `Mutation` cells of the other six rows contain no
`\|` and are copied from the table verbatim; the `\|` occurrences in the `Source text`
column of the row for line 172 are display escaping only and that row's `Mutation` cell,
`s%continue ;;%;;%`, is unaffected.

*Part three — row identity.* Lines 311 and 321 each carry an arithmetic guard **and** a
named non-arithmetic guard on the same physical line. One marker line may therefore back
more than one registry row. Row identity is the pair **(`id`, `mutation`)**, not `id`
alone. Two rows that share a marker id MUST carry different `mutation` values, and each
row's `mutation` must target its own sub-expression. That is why the table above assigns
lines 311 and 321 the same ids their arithmetic halves carry: the second row is
distinguished by its mutation, not by a second marker.

*Part four — the derived counts.*

| Quantity | Cycle start | After D1 and P2-T1 |
|---|---:|---:|
| Arithmetic guard-shaped lines | 30 | 31 |
| Marker lines (`# guard:` at end of line) | 0 | **37** |
| Registry rows | 0 | **39** |

37 marker lines, not 39: the 31 arithmetic lines plus the six non-arithmetic-only lines
172, 260, 341, 403, 410, 447. Lines 311 and 321 are already counted among the 31. 39 rows
= 31 arithmetic + 8 named non-arithmetic.

*Part five — the mutation mechanism.* A new bats suite neutralizes each row by applying a
marker-addressed `sed` program to the library **in memory** — no temporary file — checks
the result with `bash -n` reading from a here-string, and evaluates it in a child shell in
place of sourcing the real library.

The address is `/# guard:<id>$/`, **anchored with `$`**. An unanchored `/# guard:<id>/`
matches every line whose marker merely *begins* with `<id>`, so an id that is a prefix of
another id would silently mutate two guards and destroy per-guard attribution. The
`mutation` column holds a complete `sed` substitute command including its own delimiter,
so a pattern that would collide with `/` can choose another delimiter. Exactly two of the
eight fixed literals carry a literal `|` and both use `%`: the `hash-object-hard-fail` row
at line 311 and the `rename-payload-split-gate` row at line 403. The `diff-header-skip` row
at line 172 uses `%` for consistency only — its pattern is `continue ;;`, which contains
neither `/` nor `|`. An earlier revision of this plan cited line 172 as a `/`-carrying
pattern; that was wrong, because the slashes at line 172 are in the source line, not in the
mutation. The harness composes the program as `<address><mutation>` and passes the composed
string to `sed` as a single argument, never through `eval`.

*Part six — the `mutation` column is constrained, not free.* Eighteen `(id, mutation)`
pairs are fixed as literals by this plan: the five in the remediated-guard table, the eight
in part two, and the five arithmetic rows `status-read-hard-fail`,
`clear-reset-hard-fail`, `clear-clean-hard-fail`, `rung4-tracked-gate` and
`rung4-tracked-content-equal` in the thirteen-pinned-guards table. The arithmetic is
5 + 8 + 5 = 18 fixed pairs against a registry of 39 rows. The 21 rows that remain are exactly
the arithmetic rows whose constant this plan does not fix — 31 arithmetic rows less the five
in the remediated-guard table and the five in the thirteen-pinned-guards table — because all
eight non-arithmetic rows are themselves among the fixed eighteen and have no constant to
choose. Leaving those remaining twenty-one rows free would reopen the vacuous-gate
class this cycle exists to close, because a mutation that changes only a comment or only
whitespace — for example `s%# guard:foo%#  guard:foo%` — is a real source change that
passes `bash -n`, leaves both observation channels byte-identical, and lands the row in
`EXEMPT` with every obligation satisfied. Every registry row's `mutation` value must
therefore be either

1. exactly one of the **eight** non-arithmetic literals fixed in part two, matched as a
   whole string, or
2. exactly `s/((EXPR))/((0))/` or exactly `s/((EXPR))/((1))/`, where `EXPR` is the
   arithmetic comparison text — the substring the enumeration regex of part one matches —
   taken from that row's marked line in the **unmutated** library, with the surrounding
   `((` and `))` removed.

The escape hatch is eight rows wide rather than thirteen. All five mutations in the
remediated-guard table are already instances of form 2, checked one by one:
`s/((total == 0))/((0))/` against line 213, `s/((erc == 0))/((1))/` against the line D1
adds, `s/((drc > 1))/((0))/` against 301, `s/((hrc != 0))/((0))/` against 311, and
`s/((lrc != 0))/((0))/` against 336. A thirteen-literal hatch would therefore admit exactly
the same string for each of those five rows' own marked lines as the derived form does, so
the narrowing does not remove five otherwise-unconstrained rows; that reason, stated in an
earlier revision of this plan, was wrong and is corrected here. The reason the narrowing is
still taken is different and narrower: a thirteen-literal hatch is a whole-string
membership test against a thirteen-element set, so a literal fixed for one row could be
**borrowed by another row** whose marked line it does not target, and the only thing left
to catch that is P2-T6 assertion 2's requirement that the substitution change the row's own
marked line. The narrowing shrinks that borrowable set from thirteen strings to eight. It
does not eliminate it: the eight remaining literals are still whole-string admissible for
any row, and assertion 2 remains the backstop for them. The claim made here is the bounded
one — eight borrowable strings rather than thirteen — and nothing stronger.

Form 2 is well-formed for all 31 arithmetic lines, re-derived line by line against the
current tree. Every matched `EXPR` consists only of an identifier, a single space, one of
the six comparison operators, a single space, and a decimal literal, so it contains no
character that is special in a basic regular expression and no `/`, and the `/` delimiter
is safe on every line. The two compound lines take the form on their arithmetic
sub-expression alone and leave the non-arithmetic half in place: line 311 becomes
`if ((0)) || [[ -z $blob ]]; then` and line 321 becomes
`if ((0)) && [[ -n $mainblob && $mainblob == "$blob" ]]; then`, which is exactly why each
of those two lines backs a second row whose mutation targets the other half. The nine
`&&`-suffixed lines — 207, 208, 210, 211, 213, 333, 387, 388, 414 — take the form on the
arithmetic head and keep the `&&` tail, for example `((0)) && return 1` at 213. Under
`((0))` such a line has exit status 1. That is safe for a reason decidable from the tree
and independent of what any suite happens to execute: **none of the three sourced libraries
sets `errexit`**, and the harness's `bash -c` child does not set it either. Re-derived this
pass over the widened glob `scripts/bash/cleanup[-_]worktrees*` that departure 2 adopts,
`set -euo pipefail` occurs at exactly two sites: `scripts/bash/cleanup-worktrees.sh:7` and
`scripts/bash/cleanup_worktrees_scan_helper.sh:41`. Both are standalone executable scripts
and neither is one of the three files the harness sources
(`cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_lib.sh`,
`cleanup_worktrees_dirt_lib.sh`). An earlier revision named only the second site, because it
used the underscore-only glob while this plan's own departure 2 had already widened it;
naming both is what makes the sentence a general claim rather than a glob-scoped one. A
statement exiting 1 in the
middle of a function body therefore cannot abort the run. The earlier justification — that
the checked-in suites already execute each of those lines in its false direction — is
replaced by this one, because it rested on suite coverage rather than on a property of the
code.

Which of the two constants a row carries is **not** free. D3 fixes the rule: a row's `kind`
is a function of what the harness observes for the recorded constant, and an `EXEMPT` row
must additionally show that the *other* constant is equally unobservable under the same
scenario. An executor who picks the inert direction for a guard that separates in the other
direction produces a row that fails the gate rather than a row recorded `EXEMPT`. Both
constants are semantic neutralizations, and neither is satisfiable by a comment or
whitespace edit.

**D3 — registry row kinds and the observation channel.**

The observation channel is the function group's **full emitted record stream and its exit
status**, not the `DIRTSUM|` aggregate alone. For a row naming scenario `S`, the harness
computes the channel as the concatenation of:

1. stdout of `classify_worktree_dirt "$WT"` — the `DIRTFILE|` and `DIRTSUM|` records,
2. that call's exit status,
3. stdout of `clear_disposable_dirt "$WT"` — the `ACTION|dirt-clear|...` record,
4. that call's exit status.

Both calls are made under the same scenario with stderr captured **separately** into the
argv log, so the stub's `stub-git: <argv>` lines never contaminate the record channel. Both
calls use the worktree path `/repo-wt/dirt` for every row, which is the path every
checked-in `dirt_*` scenario is keyed to and the value the existing suites already bind to
`WT` (`test_cleanup_worktrees_dirt_classify.bats:36`,
`test_cleanup_worktrees_dirt_failclosed.bats:37`). The registry deliberately carries no
worktree-path column.

Widening the channel from the aggregate to the full stream moves **at least one** live guard
out of `EXEMPT`, and the one this plan pins is `((clrc != 0))` at 457. The count is stated as
"at least one" rather than "exactly one", which is a correction to an earlier revision of
this plan: `((drc == 0))` at `cleanup_worktrees_dirt_lib.sh:109`, inside
`dirt_staged_tree_commit`, is a further row the widening promotes from `ARGV` to
`SEPARATED`, because its argv log differs as well, and is not pinned. Re-derived this pass
under `dirt_staged_tree_worktree_delta`, forcing it to `((0))` makes the probe fall out of
its loop and `return 1` at `:117`, so `staged` is empty and the `M  src/b.cs` entry resolves
`CONTENT_ON_MAIN` at rung 4 instead of `STAGED_TREE_IS_COMMIT` at `:266`; the scenario
supplies no `diff-quiet..src_b.cs.rc` and no `rev-parse.verify.main_src_b.cs.rc`, so both
reads replay the stub default of exit 0. `unique_count` is 1 in both runs — the `MM src/a.cs`
entry is `UNIQUE` either way — so the `DIRTSUM|` aggregate is `HAS_UNIQUE` in both and only
the `DIRTFILE|` record differs. Under `dirt_clear_clean_failed`, whose single
` M src/Legacy/Legacy.csproj` entry resolves `DISPOSABLE_BUILD_ARTIFACT` and whose
`clean.rc` fixture makes the clean read fail, the unmutated run prints
`ACTION|dirt-clear|/repo-wt/dirt|FAILED` and returns 1 while `s/((clrc != 0))/((0))/` prints
`ACTION|dirt-clear|/repo-wt/dirt|OK` and returns 0. The `DIRTSUM|` aggregate is
`ALL_DISPOSABLE` in both runs and the argv log is identical in both, because 457 is the
last guard in the sequence and no further git call follows it. The aggregate-only channel
would therefore have forced a live guard on an irreversible action into `EXEMPT`. The
sibling guard `((rrc != 0))` at 452 separates under `dirt_clear_reset_failed` on **both**
channels — neutralizing it lets execution reach `clean -fd`, so the argv log gains an
invocation as well as the record changing from `FAILED` to `OK` — so 452 does not depend on
the widening; 457 does. Stated precisely: 457 is the only guard **among the pinned set**
whose separation depends on the widening, not the only guard in the library.

`((srrc != 0))` at 371 is **`SEPARATED`, not `EXEMPT`**, and this is a correction to the
round-2 form of this plan. The guard's two directions are not symmetric, because `srrc` is
initialised to 0 by the declaration at `cleanup_worktrees_dirt_lib.sh:367`
(`local wt="$1" out srrc=0 line xy rel res verdict detail`) and the `status --porcelain`
read at `:370` leaves it at 0 under every `dirt_*` scenario, none of which supplies a
`status.<path>.rc` fixture. The only such fixture in the checked-in set is
`tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree_status_error/status._repo-wt_dirty.rc`,
which is keyed to `/repo-wt/dirty` and belongs to a scenario outside the `dirt_*` set this
registry is restricted to. Consequently:

- under `s/((srrc != 0))/((0))/` the guard is inert: the branch was already not taken, and
  both channels are byte-identical;
- under `s/((srrc != 0))/((1))/` lines `:371-373` read `if ((1)); then return "$srrc"; fi`,
  so the mutated `classify_worktree_dirt` returns **0 having emitted no record at all**,
  while the unmutated call under any `dirt_*` scenario emits at least one `DIRTFILE|` and
  one `DIRTSUM|`. The record channel differs, and the argv log differs as well because no
  probe past the status read is issued.

Row 371 therefore carries the literal mutation `s/((srrc != 0))/((1))/` with `kind`
`SEPARATED`, and its id is mandatory so P2-T7 can pin it. This is what the free direction
choice cost: the round-2 text granted the executor the choice of constant and then asserted
an outcome only one of the two constants produces. D2 part six now removes the free choice
for every arithmetic row, and the general rule is stated below.

The witness scenario for row 371 is `dirt_unique`. No twenty-ninth scenario is added:
`dirt_unique` already exists, so the D4 arithmetic in P0-T9, P1-T9, P3-T6 and P5-T3 and the
AC-8 wording in P4-T1 are untouched, as are the scenario and record counts. The propagation
property 371 implements is separately pinned by AC-43.

The three kinds partition the outcome space of two executed comparisons **for an admissible
(`mutation`, `scenario`) pair** — one that survives the both-direction rule stated below. For
such a pair they are mutually exclusive and exhaustive, so a row's kind is a **function of
what the harness observes** rather than a verdict the registry author writes. Each kind
asserts the presence *and* the absence it names, so no kind is satisfiable by editing the
registry alone.

The qualifier is load-bearing rather than decorative. Without it the claim is false in one
cell: a form-2 row whose recorded constant leaves both channels identical, but whose sibling
constant separates, lands in the (records-identical, argv-identical) cell and yet maps to no
kind, because the both-direction rule denies it `EXEMPT` and neither `SEPARATED` nor `ARGV`
describes an observation it did not make. The rule's own remedy is that such a pair is
inadmissible: the row must be rewritten to carry the separating constant, at which point it
is admissible again and falls into exactly one kind.

| Kind | What the gate proves | Record channel | Argv log |
|---|---|---|---|
| `SEPARATED` | Under the named scenario the mutated library's record channel differs from the unmutated library's. The argv log may differ or not; the record difference is what the kind claims. | differs | either |
| `ARGV` | The record channel is byte-identical and the stub argv log differs, so the guard is observable only in what git was asked. | identical | differs |
| `EXEMPT` | Neither channel differs, in **either** admissible direction of the mutation. The row carries a named scenario that was actually run and a `reason` beginning with the fixed token `RECORDS-AND-ARGV-IDENTICAL:`. | identical | identical |

**The `EXEMPT` both-direction rule.** For a row whose `mutation` is form 2 of D2 part six —
that is, every arithmetic row — an `EXEMPT` classification additionally requires the
harness to run the row's marked line under the *other* constant and observe that both
channels are identical there too. The test composes the sibling program itself from the
row's marked line; no registry column carries it. The rule exists because without it the
choice between `((0))` and `((1))` is a free choice that lets a separable guard be parked
at `EXEMPT` by picking whichever constant happens to be inert, which is exactly the defect
row 371 carried. With it, a row is `EXEMPT` only when the guard's outcome is unobservable
under that scenario however the guard is forced, and any row for which one direction
separates must be recorded `SEPARATED` or `ARGV` with that direction as its `mutation`.
Every arithmetic row therefore has a satisfying assignment that the tree determines, so
the rule tightens the gate without making any row unsatisfiable. It is scoped to form-2
rows: the eight literal-fixed rows of D2 part two have no sibling constant, so for them
`EXEMPT` remains the single-direction observation.

Forcing a guard in either direction cannot hang the harness. Every one of the 31 arithmetic
guards controls a `return`, a variable assignment, or a branch; the three loops in the
library (`:100`, `:377`, `:390`) are driven by `read` over a here-string and by no guard,
so neither constant can produce a non-terminating run.

**What `EXEMPT` does and does not claim.** `EXEMPT` is scenario-scoped. It claims that under
the row's named scenario the guard is unobservable in both admissible directions. It does
**not** claim that no checked-in scenario could separate the guard: outside the eighteen
pinned rows, whose scenarios this plan fixes in the remediated-guard and
thirteen-pinned-guards tables, the row's `scenario` column remains the executor's choice, and
a guard that is simply not reached under the chosen scenario is honestly `EXEMPT` there.

The size of that residual is stated rather than left implicit. With the eighteen rows pinned,
21 of the 39 registry rows retain a free `scenario` column, and a scenario under which the
marked line is never reached makes both constants inert, so such a row can be recorded
`EXEMPT` with every obligation honestly satisfied. Closing that stronger property
mechanically would require sweeping every `EXEMPT` row against all 28 `dirt_*` scenarios in
both directions, on the order of 1,400 additional child-shell runs each spawning several
stub-git processes, which conflicts with the fast-execution requirement in
`.claude/rules/general-unit-test.md`. The stronger property is therefore established by
naming rather than by sweeping.

The bound on that naming is stated exactly, because an earlier revision of this plan stated
it too widely. The eighteen rows P2-T7 pins must separate, and they cover:

- every guard site named by a cycle-1 or a cycle-2 finding that falls inside the registry's
  enumerated set (the 31 arithmetic lines plus the eight named non-arithmetic verdict
  guards) — R1's Y-column gate at 260, R2's payload-split gate at 403, R5's diff-header skip
  at 172, N1's rung-4 tracked half, and N2's four sites at 213, 301, 311 and 336;
- every guard-shaped line inside N1's cited range `cleanup_worktrees_dirt_lib.sh:294-305`
  (`remediation-inputs.2026-09-08T06-51.md:34`), which is 294, 297 and 301 at cycle start
  plus the `((erc == 0))` line D1 adds inside that range;
- every one of the eight named non-arithmetic verdict guards of D2 part two, at 172, 260,
  311, 321, 341, 403, 410 and 447.

Cycle-1 finding R4 (`remediation-inputs.2026-09-08T05-00.md:75-88`) additionally names a
rung-1 hard-read failure mapping to `UNIQUE`, whose two gates — `[[ $staged == "ERROR" ]]` at
`:261` and `[[ -n $staged ]]` at `:265` — are neither arithmetic nor among the eight named
non-arithmetic guards, so they lie outside the registry's enumerated set and are held instead
by the checked-in `dirt_staged_probe_diffindex_error`, `dirt_staged_probe_revlist_error` and
`dirt_staged_tree_no_match` scenarios, with R4 recorded closed at cycle-1 exit.

The earlier form of this sentence claimed the pinned set included every guard the two cycles'
findings implicate, and that was untrue for four guards: 294 and 297, which sit inside N1's
own cited range, and the `[[ -z $blob ]]` half of 311 and the `[[ -n $mainblob && ... ]]` half
of 321, which are fail-open-direction verdict guards named in D2 part two. Those four are the
rows this revision adds to the pinned set.

The six obligations the gate asserts. Obligations 1 through 4 apply to **every** row
regardless of kind; obligation 5 is the kind-specific channel comparison and obligation 6
applies to `EXEMPT` form-2 rows only. Together they are what stops `EXEMPT` from being
satisfiable by editing the registry. P2-T6's assertions carry the same numbering:

1. the `scenario` column names a directory that exists under
   `tests/fixtures/cleanup_worktrees/scenarios/` **and** its name begins with `dirt_`;
2. the composed `sed` program actually changed the library source, and the single changed
   line still differs between the two versions after the trailing `# guard:` comment is
   stripped from both and runs of whitespace are collapsed in both;
3. `bash -n` accepts the mutated source;
4. the **unmutated** `classify_worktree_dirt` call under that scenario emitted at least one
   `DIRTFILE|` record — the proof that the ladder actually executed rather than
   short-circuiting;
5. the kind-specific channel comparison, which for every kind asserts both the difference
   and the identity its row of the table above states:
   - `SEPARATED` — the mutated record channel **differs from** the unmutated record
     channel;
   - `ARGV` — the mutated record channel **equals** the unmutated record channel, the
     mutated argv log **differs from** the unmutated argv log, and the `reason` begins with
     `ARGV-ONLY:` followed by at least one non-space character;
   - `EXEMPT` — the mutated record channel **equals** the unmutated record channel, the
     mutated argv log **equals** the unmutated argv log, and the `reason` begins with
     `RECORDS-AND-ARGV-IDENTICAL:` followed by at least one non-space character;
6. for an `EXEMPT` row whose `mutation` is form 2, the both-direction rule stated above:
   the sibling-constant run leaves both channels equal to the unmutated ones as well. The
   obligation is not evaluated for a row whose mutation is one of the eight literals, which
   have no sibling constant, and is not evaluated for a `SEPARATED` or an `ARGV` row.

Obligation 4 is scoped to the `classify_worktree_dirt` call specifically, and not to the
two-call group the channel spans. Scoped to the group it would be satisfiable by a scenario
under which the ladder never ran at all: a scenario directory that exists but supplies no
`status._repo-wt_dirt.out` replays the stub default of empty stdout and exit 0,
`classify_worktree_dirt` returns 0 at `cleanup_worktrees_dirt_lib.sh:374` having emitted
nothing, and `clear_disposable_dirt` then prints
`ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE` and returns 1, so a group-scoped
obligation would pass on that non-zero exit. Obligation 4 also demands a `DIRTFILE|` record
rather than accepting a non-zero classifier exit as an alternative, because a non-zero exit
requires a `status.<path>.rc` fixture and no `dirt_*` scenario supplies one; admitting it
would add a disjunct that nothing in the checked-in set can satisfy honestly. All 28
end-state `dirt_*` scenarios emit at least one `DIRTFILE|` record, so obligation 4 is
satisfiable for every row and fails exactly when the ladder did not run. Obligation 1's
`dirt_` prefix requirement is what confines the registry to that set; without it every
non-`dirt_*` scenario directory under `scenarios/` is admissible, including
`dirty_worktree_status_error`, which is keyed to a different worktree path and supplies no
`status._repo-wt_dirt.out` at all.

Obligation 5 asserts the *absence* of a difference for an `ARGV` and an `EXEMPT` row as
well as the presence of one, which is a change from an earlier revision of this plan and is
the point on which the whole gate turns. Without it, `EXEMPT` was a verdict the registry
author wrote rather than an outcome the harness observed, so a registry recording every
unpinned row `EXEMPT` against a scenario it never exercised satisfied every acceptance
command in this plan without the mutated library ever being executed. The objection the
earlier text raised — that asserting absence makes the gate fail when a later change gives
an exempt guard a separating scenario — is real and is answered by P3-T7, which is
explicitly authorized to re-classify a row: the failure is precise, it names the row, and
its fix is a two-column registry edit the plan already permits. A gate that has to be
updated when the code improves is the correct trade against a gate that certifies an
unexercised registry.

**D4 — scenario and record counts.** The membership test at
`tests/shell/test_cleanup_worktrees_dirt_classify.bats:214-252` names each `dirt_*`
scenario explicitly, asserts the iterated count equals the on-disk directory count
(`:245-246`), and asserts a literal record total of 30 over 25 scenarios (`:247-250`).
Both figures were re-derived against the current tree: 25 `dirt_*` directories exist and
the asserted literal is `[ "$seen" -eq 30 ]`. This cycle adds three scenario directories
carrying four status entries in total, so the end state is 28 scenarios and 34 records.
Each task that adds a directory updates the list, the literal, and the explanatory comment
in the same task, so the suite is never left failing on a count.

| Point in the plan | Scenarios | Records | Two-entry scenarios |
|---|---:|---:|---:|
| Start | 25 | 30 | 5 |
| After Phase 1 | 26 | 32 | 6 |
| After Phase 3 | 28 | 34 | 6 |

## New scenarios and fixture payloads this plan creates

Fixed here so the acceptance conditions can name concrete literals.

**`dirt_tracked_staged_only_blob`** (Phase 1, two entries)

| File | Content |
|---|---|
| `status._repo-wt_dirt.out` | `AD staged_only.md` then `M  docs/tracked.md` |
| `diff-quiet..staged_only.md.rc` | `0` |
| `rev-parse.verify.main_staged_only.md.rc` | `1` |
| `hash-object.staged_only.md.rc` | `128` |
| `diff-quiet..docs_tracked.md.rc` | `0` |
| `rev-parse.verify.main_docs_tracked.md.rc` | `0` |

**`dirt_tracked_probe_error_in_history`** (Phase 3, one entry)

| File | Content |
|---|---|
| `status._repo-wt_dirt.out` | ` M docs/tracked.md` |
| `diff-quiet..docs_tracked.md.rc` | `128` |
| `hash-object.docs_tracked.md.out` | `dddd4444` |
| `log.find-object.dddd4444.out` | `aaaa5555` |

**`dirt_build_artifact_empty_diff`** (Phase 3, one entry)

| File | Content |
|---|---|
| `status._repo-wt_dirt.out` | ` M src/Legacy/Legacy.csproj` |
| `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` | empty file, zero bytes |
| `diff-cached._repo-wt_dirt.src_Legacy_Legacy.csproj.out` | empty file, zero bytes |
| `diff-quiet..src_Legacy_Legacy.csproj.rc` | `1` |
| `hash-object.src_Legacy_Legacy.csproj.out` | `bbbb3333` |

Each of the three directories also carries the six non-classifier fixture files copied
verbatim from `tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/`:
`worktree-list.out`, `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`,
`rev-parse.show-toplevel.out`, `merge-base.feature-dirt.rc`, `worktree-remove.rc`. Those
six are the complete non-classifier set in `dirt_unique`, re-derived against the current
tree.

**Additions to two existing scenarios** (Phase 3). Both leave the scenario's emitted
records byte-identical while the guard is present, because the guard returns before the
added payload is read.

| Scenario | Added file | Content |
|---|---|---|
| `dirt_history_read_error` | `log.find-object.cccc2222.out` | `ffff8888` |
| `dirt_classifier_read_error` | `hash-object.notes.md.out` | `bbbb6666` |
| `dirt_classifier_read_error` | `rev-parse.main_notes.md.out` | `bbbb6666` |

Three of the four separating fixtures need two files rather than one. For
`dirt_classifier_read_error` with only `hash-object.notes.md.out` added, the mutated run
reaches rung 4's untracked half with no `rev-parse.main_notes.md` payload, so `mainblob`
is empty and rung 5 has no `log.find-object` fixture either: the entry lands on `UNIQUE`
by a second route rather than by the route the mutation is meant to expose. The paired
file is what makes the mutated verdict differ.

## The five remediated guards

| Guard id | Site at cycle start | Mutation | Scenario | Baseline aggregate |
|---|---|---|---|---|
| `build-artifact-vacuous-confinement` | `:213` `((total == 0)) && return 1` | `s/((total == 0))/((0))/` | `dirt_build_artifact_empty_diff` | `HAS_UNIQUE` |
| `rung4-tracked-path-in-main` | new, added by Phase 1 | `s/((erc == 0))/((1))/` | `dirt_tracked_staged_only_blob` | `HAS_UNIQUE` |
| `rung4-tracked-hard-fail` | `:301` `((drc > 1))` | `s/((drc > 1))/((0))/` | `dirt_tracked_probe_error_in_history` | `HAS_UNIQUE` |
| `hash-object-hard-fail` | `:311` `((hrc != 0))` | `s/((hrc != 0))/((0))/` | `dirt_classifier_read_error` | `HAS_UNIQUE` |
| `find-object-hard-fail` | `:336` `((lrc != 0))` | `s/((lrc != 0))/((0))/` | `dirt_history_read_error` | `HAS_UNIQUE` |

Every one of the five must produce `ALL_DISPOSABLE` under mutation. That is the concrete
form of "deleting the guard changes the record channel", and for all five the change is
precisely from refusing to clear to clearing.

## The thirteen additionally pinned guards

P2-T7 pins thirteen further registry rows beyond the five above, so the pinned set is
**eighteen rows over seventeen distinct marker ids**. Nine are pinned to `SEPARATED` and four
to `SEPARATED` or `ARGV`. Adding those to the five remediated rows, all five of which are
pinned `SEPARATED`, gives 14 `SEPARATED` pins and 4 `SEPARATED`-or-`ARGV` pins. The row count
exceeds the id count by exactly one because `hash-object-hard-fail` backs two rows and both
are pinned: its arithmetic row `s/((hrc != 0))/((0))/` in the remediated-guard table above,
and its literal row `s% || \[\[ -z $blob \]\]%%` in this table.

A pin that cannot be satisfied makes the gate unsatisfiable, so each of the thirteen is
derived here against a checked-in scenario, with the observation that separates it. The
`scenario` column of each row is fixed to the witness named here rather than left to the
executor, so the pin is reproducible.

| Marker id | Line | Mutation | Witness scenario | Unmutated observation | Mutated observation |
|---|---:|---|---|---|---|
| `status-read-hard-fail` | 371 | `s/((srrc != 0))/((1))/` | `dirt_unique` | one `DIRTFILE\|` and one `DIRTSUM\|/repo-wt/dirt\|HAS_UNIQUE\|`, exit 0 | no record at all, exit 0 |
| `clear-reset-hard-fail` | 452 | `s/((rrc != 0))/((0))/` | `dirt_clear_reset_failed` | `ACTION\|dirt-clear\|/repo-wt/dirt\|FAILED`, exit 1 | `ACTION\|dirt-clear\|/repo-wt/dirt\|OK`, exit 0 |
| `clear-clean-hard-fail` | 457 | `s/((clrc != 0))/((0))/` | `dirt_clear_clean_failed` | `ACTION\|dirt-clear\|/repo-wt/dirt\|FAILED`, exit 1 | `ACTION\|dirt-clear\|/repo-wt/dirt\|OK`, exit 0 |
| `clear-requires-all-disposable` | 447 | `s%\[\[ $agg != "ALL_DISPOSABLE" \]\]%[[ -n "" ]]%` | `dirt_unique` | `ACTION\|dirt-clear\|/repo-wt/dirt\|REFUSED-UNIQUE`, exit 1 | `ACTION\|dirt-clear\|/repo-wt/dirt\|OK`, exit 0 |
| `unique-verdict-tally` | 410 | `s%\[\[ $verdict == "UNIQUE" \]\]%[[ -n "" ]]%` | `dirt_unique` | `DIRTSUM\|/repo-wt/dirt\|HAS_UNIQUE\|` | `DIRTSUM\|/repo-wt/dirt\|ALL_DISPOSABLE\|` |
| `history-hit-nonempty` | 341 | `s%\[\[ -n $found \]\]%[[ -n "" ]]%` | `dirt_content_in_history` | `DIRTFILE\|/repo-wt/dirt\|CONTENT_IN_HISTORY\|ffff8888\|??\|docs/old.md` | the same record with verdict `UNIQUE` and an empty detail |
| `diff-header-skip` | 172 | `s%continue ;;%;;%` | `dirt_build_artifact` | `DIRTFILE\|` verdict `DISPOSABLE_BUILD_ARTIFACT` | `DIRTFILE\|` verdict `CONTENT_ON_MAIN` |
| `rung1-y-column-gate` | 260 | `s% && $y == " "%%` | `dirt_staged_tree_worktree_delta` | the `MM src/a.cs` entry's verdict is not `STAGED_TREE_IS_COMMIT` | that entry's verdict becomes `STAGED_TREE_IS_COMMIT` |
| `rename-payload-split-gate` | 403 | `s%== C \]\]%== C \|\| -n "x" \]\]%` | `dirt_rename_split` | the `??` entry's path field is `notes -> draft.md` | that path field becomes `draft.md` |
| `rung4-tracked-gate` | 294 | `s/((untracked == 0))/((0))/` | `dirt_tracked_staged_only_blob` | the `M  docs/tracked.md` entry's verdict is `CONTENT_ON_MAIN` | that entry's verdict becomes `UNIQUE` |
| `rung4-tracked-content-equal` | 297 | `s/((drc == 0))/((0))/` | `dirt_tracked_staged_only_blob` | the `M  docs/tracked.md` entry's verdict is `CONTENT_ON_MAIN` | that entry's verdict becomes `UNIQUE` |
| `rung4-untracked-main-present` | 321 | `s%\[\[ -n $mainblob && $mainblob == "$blob" \]\]%[[ -n "x" ]]%` | `dirt_rename_split` | the `?? notes -> draft.md` entry is `UNIQUE` and the aggregate is `HAS_UNIQUE` | that entry becomes `CONTENT_ON_MAIN` and the aggregate becomes `ALL_DISPOSABLE` |
| `hash-object-hard-fail`, literal row | 311 | `s% \|\| \[\[ -z $blob \]\]%%` | `dirt_staged_tree_worktree_delta` | the `MM src/a.cs` entry is `UNIQUE`, decided at `:311` on an empty blob | the record channel is byte-identical and the argv log gains the rung-5 `log --find-object=` invocation |

Nine of the thirteen are pinned `SEPARATED`: `status-read-hard-fail`,
`clear-reset-hard-fail`, `clear-clean-hard-fail`, `clear-requires-all-disposable`,
`unique-verdict-tally`, `history-hit-nonempty`, `rung4-tracked-gate`,
`rung4-tracked-content-equal`, and the `rung4-untracked-main-present` **literal** row. Four
are pinned `SEPARATED` or `ARGV`: `rung1-y-column-gate`, `rename-payload-split-gate`,
`diff-header-skip`, and the `hash-object-hard-fail` **literal** row.

**Three of the eighteen pins are keyed to the pair (`id`, `mutation`) rather than to `id`.**
Lines 311 and 321 each carry one marker and back two registry rows, so an id-keyed pin on
either of those two ids is satisfied by whichever of that id's two rows happens to carry the
demanded kind, and leaves the other row unconstrained. The three affected pins are
`hash-object-hard-fail`'s arithmetic row in the remediated-guard table,
`hash-object-hard-fail`'s literal row in this table, and `rung4-untracked-main-present`'s
literal row in this table. Each is keyed by testing whether the row's `mutation` begins with
the four characters `s/((`: by D2 part six every arithmetic row's mutation is exactly
`s/((EXPR))/((0))/` or `s/((EXPR))/((1))/` and every one of the eight literals begins `s%`, so
that prefix test partitions each id's two rows exactly and needs no `%`, `$` or backslash to
survive shell quoting. The remaining fifteen pins are id-keyed, which is unambiguous because
each of their ids backs exactly one registry row.

The **arithmetic** row on line 321 — `rung4-untracked-main-present` with a mutation of the
form `s/((mrc == 0))/((0))/` or `s/((mrc == 0))/((1))/` — is deliberately **not** pinned. It
retains a free constant and a free scenario, and it is one of the twenty-one free rows D2
part six counts. Under `dirt_rename_split` it is inert in both directions, because `mrc` is 0
from the stub default and the second half of line 321 is false either way, so pinning it
`SEPARATED` there would be unsatisfiable. Pinning the literal half by pair rather than the
whole id is what keeps the fail-open verdict guard bound without making that arithmetic
sibling's pin unsatisfiable.

The two escaping classes D2 part two defines apply to this table unchanged. `\[` and `\]`
are genuine `sed` escapes and are copied verbatim. The `\|` occurrences — in the
`rename-payload-split-gate` mutation cell, in the `hash-object-hard-fail` literal row's
mutation cell, and in every `DIRTFILE\|`, `DIRTSUM\|` and `ACTION\|` record quoted in the
observation columns — are Markdown table escaping for a literal `|` and must be written
unescaped in the registry and in the evidence. The authoritative unescaped spelling of both
`\|`-carrying mutations is the fenced form in D2 part two, not these cells. The
`rung4-untracked-main-present` mutation cell carries `\[` and `\]` only, so it is copied from
the cell verbatim; it contains no `\|`.

Derivations, re-derived against the current tree in this pass:

- **371.** `srrc` is 0 under every `dirt_*` scenario, so `((1))` returns from
  `classify_worktree_dirt` at `:372` before any record is printed. `dirt_unique`'s
  `status._repo-wt_dirt.out` is the single line `?? notes.md`, whose unmutated verdict is
  `UNIQUE`, so the unmutated run emits one `DIRTFILE|` and satisfies obligation 4.
- **452 and 457.** `dirt_clear_reset_failed/reset-hard.rc` and
  `dirt_clear_clean_failed/clean.rc` each contain `1`. Both scenarios carry the single
  status entry ` M src/Legacy/Legacy.csproj` with a HintPath-only worktree diff, so both
  aggregate `ALL_DISPOSABLE` and the clear proceeds to the failing step. 452 separates on
  the argv log as well, because neutralizing it lets execution reach `clean -fd`; 457 does
  not, because it is the last guard in the sequence, which is the case that motivates the
  widened channel.
- **447 and 410.** `dirt_unique` aggregates `HAS_UNIQUE`: its `?? notes.md` entry gets a
  blob from `hash-object.notes.md.out`, `rev-parse.main_notes.md.rc` contains `128` so
  rung 4's untracked half misses, and no `log.find-object` fixture exists so rung 5 misses
  too. Neutralizing 410 leaves `unique_count` at 0 and flips the aggregate to
  `ALL_DISPOSABLE`; neutralizing 447 removes the clear's precondition so the sequence runs
  to `OK`. Neither depends on the other, because each row is mutated alone.
- **341.** `dirt_content_in_history` supplies `hash-object.docs_old.md.out` containing
  `cccc2222` and `log.find-object.cccc2222.out` containing `ffff8888`, so `found` is
  non-empty and the unmutated verdict is `CONTENT_IN_HISTORY`. Forcing the test false drops
  the entry to rung 6.
- **172.** `dirt_build_artifact`'s worktree diff carries `--- a/src/Legacy/Legacy.csproj`
  and `+++ b/src/Legacy/Legacy.csproj` header lines. Removing the `continue` counts the
  first of them as a changed content line; it holds no `HintPath`, so
  `dirt_diff_is_hintpath_confined` returns 1, rung 3 misses, and the entry falls to rung 4,
  which resolves `CONTENT_ON_MAIN` on the stub-default `diff --quiet` exit 0.
- **260.** `dirt_staged_tree_worktree_delta`'s `MM src/a.cs` entry has a non-space Y column,
  so the unmutated gate rejects it; the scenario supplies `rev-list.HEAD.out` and
  `diff-index.eeee7777.rc`, so with the Y-column term removed the entry takes rung 1.
- **403.** `dirt_rename_split`'s `status._repo-wt_dirt.out` carries `?? notes -> draft.md`
  followed by `R  old.md -> new.md`, and the scenario supplies both
  `hash-object.notes_-__draft.md.out` and `hash-object.draft.md.out`. Widening the gate to
  always split truncates the untracked entry's path, which is visible in the `DIRTFILE|`
  record's last field.
- **294 and 297.** Both are witnessed by `dirt_tracked_staged_only_blob`, the two-entry
  scenario Phase 1 creates, so both witnesses exist before Phase 2 runs. Its second entry
  `M  docs/tracked.md` reaches rung 4's tracked half: rung 1's gate at `:260` admits it but
  the scenario supplies no `rev-list.HEAD.out`, so the staged-tree probe replays the stub
  default and leaves `staged` empty and the branch falls through; rung 2 does not match;
  rung 3's path `case` at `:202-205` rejects `docs/tracked.md`, so `dirt_is_build_artifact`
  returns 1 at `:204` with no git call and `:213` is never reached. At rung 4
  `diff-quiet..docs_tracked.md.rc` gives `drc=0` and
  `rev-parse.verify.main_docs_tracked.md.rc` gives `erc=0`, so the
  unmutated verdict is `CONTENT_ON_MAIN`. Forcing `:294` to `((0))` skips rung 4's tracked
  half entirely; forcing `:297` to `((0))` skips only its positive branch, and `((drc > 1))`
  at `:301` is false because `drc` is 0. Either way the entry reaches the `hash-object` read
  at `:309`, and the scenario supplies no `hash-object.docs_tracked.md` fixture, so the stub
  default gives `hrc=0` with an empty blob and `[[ -z $blob ]]` at `:311` resolves `UNIQUE`.
  The `DIRTFILE|` record for `docs/tracked.md` therefore differs in both mutated runs, so
  both rows are `SEPARATED`. The scenario's first entry `AD staged_only.md` is `UNIQUE` in
  every one of the three runs, so the `DIRTSUM|` aggregate stays `HAS_UNIQUE` throughout and
  the separation is carried by the per-entry record, which is a second case the widened
  observation channel is required for. Note that `((untracked == 0))` also occurs at `:280`;
  the `$`-anchored marker address confines the `:294` row's substitution to its own line, and
  the two rows are distinct under (`id`, `mutation`) because their ids differ.
- **321.** Witnessed by `dirt_rename_split`, whose first entry is `?? notes -> draft.md`.
  The rename-payload split at `:403` fires only for an `R` or `C` X column, so the untracked
  entry keeps the whole `notes -> draft.md` string as its path. `hash-object.notes_-__draft.md.out`
  gives a non-empty blob, and the scenario supplies no `rev-parse.main_notes_-__draft.md`
  fixture, so the `rev-parse` at `:319` replays the stub default: `mrc` stays 0 and
  `mainblob` is empty. Unmutated, `[[ -n $mainblob && ... ]]` is false and the entry falls to
  rung 5, which has no `log.find-object` fixture either, so the verdict is `UNIQUE` and the
  worktree aggregates `HAS_UNIQUE`. Under the fixed literal the second half becomes
  `[[ -n "x" ]]`, which is true while `((mrc == 0))` already is, so the entry resolves
  `CONTENT_ON_MAIN`. The scenario's other entry `R  old.md -> new.md` is tracked, so `:318`
  excludes it and it is `CONTENT_ON_MAIN` in both runs. `unique_count` therefore falls from 1
  to 0 and the aggregate flips `HAS_UNIQUE` to `ALL_DISPOSABLE`, which is a fail-open flip on
  the guard that authorizes `--clear-disposable`. `SEPARATED`.
- **311, literal row.** Witnessed by `dirt_staged_tree_worktree_delta`, whose `MM src/a.cs`
  entry has a non-space Y column, so rung 1 rejects it; rung 3 does not match; and
  `diff-quiet..src_a.cs.rc` contains `1`, so `drc` is 1 and rung 4's tracked half falls
  through at both `:297` and `:301`. The scenario supplies no `hash-object.src_a.cs` fixture,
  so `hrc` is 0 and `blob` is empty, and the unmutated `[[ -z $blob ]]` half of `:311`
  resolves `UNIQUE`. Removing that half leaves `if ((hrc != 0)); then`, which is false, so
  execution continues past `:311` with an empty blob: `:318` is false because the entry is
  tracked, and rung 5 issues `log --find-object=` with an empty object argument, finds
  nothing, and rung 6 resolves `UNIQUE` again. **The record channel is byte-identical**, and
  the argv log gains the `log --find-object=` invocation, so this row is `ARGV`. The pin is
  written `SEPARATED` or `ARGV` rather than `ARGV` alone so that a Phase 3 fixture addition
  that promotes it to `SEPARATED` does not fail the pin. One correction to the round-4
  delta's witness note is recorded here: the rung-5 bounded-range probe at `:331-332` is
  redirected `>/dev/null 2>&1`, and the stub writes its `stub-git: <argv>` line to stderr
  (`stub-bin/git:74`), so that `rev-parse --verify --quiet main~...` invocation does **not**
  appear in the argv log. The `log --find-object=` invocation at `:334-335` has no stderr
  redirect and does appear, and it alone is what makes the argv logs differ. The pin is
  therefore satisfiable, but by one added argv line rather than two.

## Mandatory marker ids

P2-T1 assigns marker ids freely except for these seventeen, which are fixed here because
later tasks name them as literals. No id may be a prefix of any other id.

`build-artifact-vacuous-confinement` (213), `rung4-tracked-path-in-main` (new),
`rung4-tracked-hard-fail` (301), `hash-object-hard-fail` (311),
`find-object-hard-fail` (336), `diff-header-skip` (172), `rung1-y-column-gate` (260),
`rung4-untracked-main-present` (321), `history-hit-nonempty` (341),
`rename-payload-split-gate` (403), `unique-verdict-tally` (410),
`clear-requires-all-disposable` (447), `status-read-hard-fail` (371),
`clear-reset-hard-fail` (452), `clear-clean-hard-fail` (457),
`rung4-tracked-gate` (294), `rung4-tracked-content-equal` (297).

`status-read-hard-fail`, `clear-reset-hard-fail` and `clear-clean-hard-fail` were added by
the round-3 revision so P2-T7 could pin the cycle-start lines 371, 452 and 457 by literal.
`rung4-tracked-gate` and `rung4-tracked-content-equal` are added by the round-4 revision so
P2-T7 can pin the two remaining guard-shaped lines inside N1's cited range `:294-305`. All
five sit on lines already counted among the 31 arithmetic lines, so the marker count stays
**37** and the row count stays **39**.

The prefix property is re-derived mechanically here over all seventeen rather than asserted.
Sorted in byte order (`LC_ALL=C`), the set is `build-artifact-vacuous-confinement`,
`clear-clean-hard-fail`, `clear-requires-all-disposable`, `clear-reset-hard-fail`,
`diff-header-skip`, `find-object-hard-fail`, `hash-object-hard-fail`,
`history-hit-nonempty`, `rename-payload-split-gate`, `rung1-y-column-gate`,
`rung4-tracked-content-equal`, `rung4-tracked-gate`, `rung4-tracked-hard-fail`,
`rung4-tracked-path-in-main`, `rung4-untracked-main-present`, `status-read-hard-fail`,
`unique-verdict-tally`.

In sorted order a prefix pair must be adjacent, and no adjacent pair in this set is one. The
two closest adjacent pairs are the four `rung4-tracked-` ids, whose consecutive members first
differ at **character 15** — `c`, `g`, `h`, `p` immediately after the fourteen-character
common prefix `rung4-tracked-` — and `clear-requires-all-disposable` against
`clear-reset-hard-fail`, which first differ at **character 9**, `q` against `s`, after the
eight-character common prefix `clear-re`. Every remaining adjacent pair first differs at or
before character 7; the two that go as far as character 7 are `clear-clean-hard-fail` against
`clear-requires-all-disposable` (`c` against `r` after the six-character prefix `clear-`) and
`rung4-tracked-path-in-main` against `rung4-untracked-main-present` (`t` against `u` after the
six-character prefix `rung4-`).

Two statements in an earlier revision of this paragraph were wrong and are corrected here.
The three `clear-` ids diverge at the **seventh** character, not the sixth: the sixth
character is `-` in all three. And "every other adjacent pair differs within the first two
characters" was false even for the fifteen-id set, because `rung1-y-column-gate` against
`rung4-tracked-hard-fail` first differ at character 5 and `rung4-tracked-path-in-main`
against `rung4-untracked-main-present` first differ at character 7. The conclusion was
correct in both revisions; only the supporting derivation was.

P2-T1 acceptance command 4 re-runs this check mechanically over the full 37-marker set under
`LC_ALL=C`, so the seventeen fixed ids are checked together with the twenty freely assigned
ones rather than in isolation.

## Task-ordering note

At the end of Phase 2 the full local bats stage is expected to fail: the new gate suite is
in place and the four N2 fixtures are not, which is the fail-before evidence Phase 3
closes. No acceptance condition in Phase 2 or Phase 3 requires a clean full-suite run.
The first task that requires one is in Phase 5.

## Recorded departures from the preflight deltas

Both departures sustained in round 1 are retained unchanged: `rev-parse --verify --quiet
main:<path>` over `ls-files --error-unmatch` (D1), and the two-file fixture requirement
with the 28-scenario / 34-record end state (D4). Three further round-1 departures are
recorded below, followed by four round-2 departures, three round-3 departures, and two
round-4 departures.

1. **D-1 names P4-T4 as carrying guard arithmetic; it does not.** P4-T4's figures are
   acceptance-criterion checkbox counts (47 total, 45 checked, 2 unchecked), re-derived
   against `spec.md` in this pass: the `## Acceptance Criteria` section beginning at
   `spec.md:678` carries 45 checkboxes, all `[x]`, the last being AC-45 at `:848`. Those
   counts are unaffected by the 30 → 39 registry change. The Phase 4 task that does carry
   guard arithmetic is P4-T3 (AC-47), which is rewritten in full under D-1. P4-T4 is left
   with its existing figures and this note explains why.
2. **D-5 offers two options; the eight-file option is taken.** `scripts/bash/cleanup_worktrees*`
   matches seven files, confirmed by enumeration:
   `cleanup_worktrees_actions_lib.sh`, `cleanup_worktrees_detached_lib.sh`,
   `cleanup_worktrees_dirt_lib.sh`, `cleanup_worktrees_enumerate_lib.sh`,
   `cleanup_worktrees_lib.sh`, `cleanup_worktrees_report_records_lib.sh`,
   `cleanup_worktrees_scan_helper.sh`. `cleanup-worktrees.sh` uses a hyphen and does not
   match. This plan widens the glob to `scripts/bash/cleanup[-_]worktrees*` and states
   **eight**, because `cleanup-worktrees.sh` is production bash inside `kcov`'s
   `--include-pattern` (`shell_qc_lib.sh:335`) and is the file that arms
   `--clear-disposable`; excluding it from the per-file coverage table would leave a blind
   spot in the one file whose regression would be most consequential. P0-T6 and P5-T9 both
   use the widened glob and both name the eight files.
3. **D-2's "reason names the scenario tried" is implemented as a stronger, mechanical
   form.** The registry already carries a `scenario` column, so requiring the prose
   `reason` to repeat the scenario name would be a prose assertion of the class this run
   has already shipped. Instead: the `scenario` column must name a directory that exists
   on disk, that directory's name must begin with `dirt_`, the gate must observe that the
   unmutated `classify_worktree_dirt` call under it emitted at least one `DIRTFILE|`
   record, and the `reason` must begin with one of two fixed single-token prefixes naming
   the channel observed identical. All four are checkable by a command and all four can
   fail. The second and third of the four were tightened in round 2 under B2.

Round-2 departures.

4. **B1's second remedy does not reject a whitespace-only mutation, and this plan does not
   claim that it does.** The round-2 delta states that requiring the changed line to still
   differ after the trailing `# guard:...` comment is stripped from both versions "rejects
   comment-only and marker-only mutations directly". That is correct for those two classes
   and only those two. A mutation of the form `s%if ((rc != 0))%if  ((rc != 0))%` inserts a
   second space in the **code** region; stripping the comment leaves `if ((rc != 0)); then`
   against `if  ((rc != 0)); then`, which still differ as strings, so the stated assertion
   passes and the inert mutation survives. This plan therefore does two things rather than
   one. D2 part six constrains the `mutation` column itself, which is what actually closes
   the whitespace class for the twenty-one otherwise-free rows. D3 obligation 2 and P2-T6
   assertion 2 additionally collapse runs of whitespace in both versions before comparing,
   so the whitespace class is closed a second time at the point of observation and is
   closed for the eight literal-fixed rows as well. A second narrowing is taken in the same
   place: the delta describes the literal escape hatch as covering "the 13 literals this
   plan fixes", but all five mutations in the remediated-guard table are already instances
   of the derived arithmetic form, so the hatch is written as the eight non-arithmetic rows
   only. The reason recorded here in the round-2 revision — that a five-row-wider hatch
   would leave five rows with an unconstrained `mutation` column — was wrong, and round 3
   corrected it. Because those five mutations are form-2 instances, a thirteen-literal hatch
   would admit exactly the same string for each of the five rows' own marked lines that the
   derived form admits, so no row would have been left unconstrained. The narrowing is
   retained for the smaller reason D2 part six now states: it shrinks the set of literals a
   row could borrow from a marked line that is not its own from thirteen to eight, leaving
   P2-T6 assertion 2 as the backstop for the remaining eight rather than for thirteen.
5. **B2's obligation-4 remedy is adopted with its disjunct removed.** The delta's wording
   keeps "or `classify_worktree_dirt` itself returned a non-zero exit status". Under
   obligation 1's new `dirt_` prefix requirement that disjunct is unsatisfiable by any
   checked-in scenario, because a non-zero classifier exit requires a `status.<path>.rc`
   fixture and no `dirt_*` scenario has one. A disjunct that no admissible scenario can
   satisfy is not a weakening in the present tree but is one the moment such a fixture is
   added, so it is dropped. Every one of the 28 end-state `dirt_*` scenarios emits at least
   one `DIRTFILE|` record, so the remaining conjunct is satisfiable for every row.
6. **B6 is adopted as option (b), with 452 named alongside 457 for contrast.** The delta
   names 457 as the single guard the widening moves out of `EXEMPT`. Re-derived against the
   tree, `dirt_clear_reset_failed/reset-hard.rc` exists, so `((rrc != 0))` at 452 is also
   separable — but on the argv channel as well as the record channel, because neutralizing
   it lets execution reach `clean -fd`. D3 records that distinction so a reader does not
   conclude that 452 was overlooked. The delta's substantive claim is adopted in a corrected
   form: 457 is the only one **among the pinned set** whose separation depends on the
   widening, not the only guard in the library. Round 4 supplied the counter-example that
   forced the qualifier — `((drc == 0))` at `:109`, which D3 now derives — and the earlier
   unqualified spelling here and in D3 was false. The 371 half of this departure —
   the conclusion that `((srrc != 0))` at 371 is `EXEMPT` under every `dirt_*` scenario — was
   overturned in round 3 and is superseded by D3 and by round-3 departure 8. It held only
   for the `((0))` direction.
7. **B5's six rows are adopted; two of its status strings are corrected.** The delta's
   table gives `dirt_build_artifact_mixed` and `dirt_build_artifact_plus_content` the entry
   `M  src/Legacy/Legacy.csproj`. Both scenario files actually contain
   ` M src/Legacy/Legacy.csproj`, with the modification flag in the Y column and a leading
   space in X. The distinction is load-bearing for the trace rather than cosmetic: a `M `
   entry passes rung 1's gate at `:260` and an ` M` entry does not, so a reader checking the
   table against the ladder would reach a different rung-1 outcome from the delta's
   spelling. D1 and P1-T10 carry the corrected strings. The membership of the six-row set,
   the four `1` values, the single `128`, and the `dirt_rename_split` stub-default row are
   all confirmed exactly as the delta states, as is the `total=1` derivation for
   `dirt_build_artifact_added_file`.

Round-3 departures.

8. **The round-3 delta cites `srrc=0` at `:369`; it is assigned at `:367`.** The
   substantive claim is confirmed and adopted in full — `srrc` is 0 under every `dirt_*`
   scenario, so `((1))` is the separating direction for the guard at `:371` — but the
   declaration that sets it is `local wt="$1" out srrc=0 line xy rel res verdict detail` at
   `cleanup_worktrees_dirt_lib.sh:367`. Line `:369` is
   `local entry_count=0 unique_count=0 agg_detail=""`, which declares three other locals and
   does not mention `srrc`. D3 carries `:367`. The correction is recorded because a reader
   checking the derivation against `:369` would find nothing there and could conclude the
   trace was fabricated.
9. **BD1(a) is adopted and extended from one kind to all three.** The delta requires an
   `EXEMPT` row to assert that both channels are identical. This plan additionally requires
   an `ARGV` row to assert that the record channel is identical, which makes the three kinds
   a partition of the outcome space of the two comparisons: exactly one kind is correct for
   a given **admissible** (`mutation`, `scenario`) pair — one that survives the
   both-direction rule departure 10 adds — and each kind asserts both the presence and the
   absence it names. The admissibility qualifier is a round-4 correction: without it the
   claim is false for a form-2 pair whose recorded constant is inert while its sibling
   separates, which lands in the records-identical, argv-identical cell and yet maps to no
   kind. The extension costs one comparison and removes the remaining path by
   which a row could carry a weaker claim than the observation supports. `SEPARATED` is left
   permissive on the argv log, because a guard whose neutralization changes the records is
   separated whether or not it also changes what git was asked, and requiring identity there
   would misclassify `clear-reset-hard-fail`, which differs on both.
10. **BD1(a) is further extended with a both-direction rule for `EXEMPT`.** The delta's
    remedy makes `EXEMPT` an executed observation but leaves intact the free choice between
    `((0))` and `((1))` that BD2 identifies as the mechanism by which row 371 acquired a
    false `EXEMPT`. That mechanism is general: 26 arithmetic rows carried the same freedom
    before the round-3 revision, 23 still chose their constant after it, and 21 still do
    after the round-4 revision fixed the constants for 294 and 297.
    D3 therefore requires an `EXEMPT` form-2 row to be unobservable under the sibling
    constant as well, which the harness composes from the row's marked line. A row for which
    either constant separates must be recorded `SEPARATED` or `ARGV` with that constant, so
    the rule tightens the gate without making any row unsatisfiable. It is not extended to a
    sweep over all 28 scenarios: that would be on the order of 1,400 additional child-shell
    runs and conflicts with the fast-execution requirement in
    `.claude/rules/general-unit-test.md`. The residual this leaves — a guard parked at
    `EXEMPT` under a scenario that does not reach it — is stated in D3 and is covered for the
    eighteen rows P2-T7 pins.

Round-4 departures.

11. **BD-A's remedy is adopted; its "pinned ids 14 to 18" arithmetic is adopted with a
    precision correction.** The four additional pins and their witnesses are adopted exactly
    as the delta tabulates them, and all four were re-traced against the tree in this pass.
    The delta counts the result as eighteen pinned **ids**. That is one too many for a count
    of ids: `hash-object-hard-fail` is pinned twice, once for its arithmetic row and once for
    its literal row, so the pinned set is eighteen **rows** over **seventeen distinct ids**.
    This plan therefore writes "eighteen pinned rows" wherever a row count is meant and
    "seventeen distinct ids" wherever an id count is meant — P2-T7's title, its literal-count
    acceptance, and the mandatory-marker-id section are each written to the count they
    actually assert. The eighteen and the fourteen-`SEPARATED`-plus-four arithmetic the delta
    gives are otherwise correct and are adopted unchanged.
12. **BD-A's witness note for the `:311` literal row overstates the argv difference by one
    invocation.** The delta states that under `dirt_staged_tree_worktree_delta` the mutated
    run's argv log gains "the rung-5 `rev-parse --verify --quiet main~1000` and
    `log --find-object=` calls". Re-derived this pass, only the second of those two appears.
    The bounded-range probe at `cleanup_worktrees_dirt_lib.sh:331-332` is redirected
    `>/dev/null 2>&1`, and the stub writes its `stub-git: <argv>` line to stderr
    (`tests/fixtures/cleanup_worktrees/stub-bin/git:74`), so that invocation is discarded
    before it can reach the argv log — which is the same property D1 cites as its reason for
    not copying that redirect shape onto the new rung-4 read. The `log --find-object=` call at
    `:334-335` carries no stderr redirect and does appear. The pin is satisfiable either way,
    because one added argv line is sufficient for an `ARGV` classification, so the remedy
    stands; only its stated magnitude is corrected. The correction is recorded because an
    executor who asserted two added argv lines against this row would write an unsatisfiable
    acceptance condition.
13. **BD-A item 3 pair-keys one pin; three pins need pair-keying, and this plan applies it to
    all three.** The delta requires the `hash-object-hard-fail` literal row to be pinned by
    (`id`, `mutation`) rather than by `id`, because that id backs two registry rows and an
    id-only pin is discharged by the arithmetic sibling. The reasoning is correct and is
    adopted, but the delta applies it to one pin where the same argument applies to three.
    D2 part three of this plan states that lines 311 **and 321** each carry an arithmetic
    guard and a named non-arithmetic guard on one physical line, and P2-T1 gives each of those
    two lines exactly one marker. `rung4-untracked-main-present` therefore backs two rows in
    the same way `hash-object-hard-fail` does, so the delta's new `SEPARATED` pin on that id
    is discharged by whichever of its two rows carries that kind and leaves the
    `[[ -n $mainblob && $mainblob == "$blob" ]]` verdict guard — the fail-open guard the pin
    exists for — unconstrained. The `SEPARATED` pin the remediated-guard table already holds
    on `hash-object-hard-fail`'s arithmetic row is exposed to the mirror-image failure once
    the literal row can be `SEPARATED`. This plan therefore pair-keys all three pins on those
    two lines and leaves the remaining fifteen id-keyed, each of whose ids backs exactly one
    row. The pin totals the delta gives are unaffected: eighteen pins, fourteen `SEPARATED`
    and four `SEPARATED`-or-`ARGV`, over seventeen distinct ids.

    The key is a prefix test on the `mutation` column rather than a quoted copy of the
    mutation literal. The literals carry `%`, `$` and `\[`, and an acceptance condition that
    reproduced one of them through a shell quoting round-trip would be fragile in the way this
    plan's D2 part two documents for `\|`. Every arithmetic mutation begins `s/((` and every
    one of the eight literals begins `s%`, so `index($5,"s/((")` partitions each id's two rows
    exactly, with no escaping.

    One consequence is recorded so it is not read as an omission. The **arithmetic** row on
    line 321 is left unpinned. Under its line's witness `dirt_rename_split` it is inert in both
    directions — `mrc` is 0 from the stub default, so `((mrc == 0))` forced to `((1))` changes
    nothing and forced to `((0))` short-circuits a condition whose second half is already
    false — so a `SEPARATED` pin on it would be unsatisfiable. It keeps a free constant and a
    free scenario and is one of the twenty-one free rows.

---

### Phase 0 — Baseline capture

- [x] [P0-T1] Read, in this order, `.github/copilot-instructions.md`,
  `.github/instructions/general-code-change.instructions.md`,
  `.github/instructions/general-unit-test.instructions.md`, and `.claude/rules/shell.md`.
  Write `evidence/remediation-baseline/phase0-instructions-read.2026-09-08T07-30.md`
  carrying `Timestamp:`, `Policy Order:`, and the explicit list of the four files read.
  Acceptance: the artifact exists and lists all four paths.

- [x] [P0-T2] Read the four cycle-2 finding documents in the feature folder:
  `remediation-inputs.2026-09-08T06-51.md`, `code-review.2026-09-08T06-51.md`,
  `feature-audit.2026-09-08T06-51.md`, `policy-audit.2026-09-08T06-51.md`. Write
  `evidence/remediation-baseline/phase0-findings-read.2026-09-08T07-30.md` recording, for
  each of N1 and N2, the file and the line range the finding names. Acceptance: the
  artifact names `scripts/bash/cleanup_worktrees_dirt_lib.sh` with the ranges `294-305`
  for N1 and the four sites `213`, `301-304`, `311-314`, `336-339` for N2.

- [ ] [P0-T3] Run `bash scripts/bash/shell-qc.sh format` and record it in
  `evidence/remediation-baseline/shell-qc-format.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and `Output Summary:` reproducing the command's combined
  stdout and stderr verbatim. `run_format` prints nothing and exits 0 whether or not it
  rewrote a file, so the exit code alone cannot distinguish a clean run from a repairing
  one and the artifact must carry two before-and-after tree observations taken around the
  run. Record `git status --porcelain` under the field names `StatusBefore:` and
  `StatusAfter:`, and a digest over the formatter's own discovered file set under the
  field names `TreeDigestBefore:` and `TreeDigestAfter:`, computed with

  ```
  bash -c 'source scripts/bash/shell_qc_lib.sh; discover_shell_scripts' | LC_ALL=C sort | xargs md5sum | md5sum
  ```

  The digest is derived from `discover_shell_scripts` rather than from a `find -name
  '*.sh'` predicate because the discovery predicate at `shell_qc_lib.sh:54-73` also
  accepts an extensionless file whose shebang resolves to `bash` or `sh`, and a
  `-name '*.sh'` digest is blind to a rewrite of such a file. Both the digest command and
  the `shell-qc.sh format` run are issued with the worktree root
  `.claude/worktrees/agent-ac72d35e7980bc69d` as the working directory, because
  `discover_shell_scripts` collects its roots as the relative paths `tools`, `scripts`, and
  `.claude/lib/bash` (`shell_qc_lib.sh:85`) and returns nothing at all from any other
  directory, which would make the two digests trivially equal. Acceptance: all four
  observation fields are present; `TreeDigestBefore:` and `TreeDigestAfter:` are non-empty;
  `StatusBefore:` and `StatusAfter:` reproduce the command's output verbatim and carry the
  literal `(empty)` when that output is empty, since `git status --porcelain` legitimately
  prints nothing on a clean tree and a non-empty requirement on those two fields would be
  unsatisfiable in exactly that case; the artifact records the working directory used; it
  states explicitly whether `TreeDigestBefore:` and `TreeDigestAfter:` are equal and whether
  `StatusAfter:` lists any path absent from `StatusBefore:`; and **if the digests differ,
  the artifact lists each rewritten path and states, for each, whether that path is in this
  cycle's scope**.

- [x] [P0-T4] Run `bash scripts/bash/shell-qc.sh check` and record it in
  `evidence/remediation-baseline/shell-qc-check.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and `Output Summary:` reproducing the command's combined
  stdout and stderr verbatim. No findings count is asserted, because `run_check`
  (`shell_qc_lib.sh:164-202`) prints nothing at all on a clean run and emits no summary
  line. Acceptance: `EXIT_CODE:` is `0` and `Output Summary:` records that the combined
  output was empty, quoting it verbatim (an empty block) rather than paraphrasing it.

- [x] [P0-T5] Resolve the bats binary with `npx --yes bats --version`, then run the full
  local test stage as
  `env SHELL_QC_BATS_BIN=<resolved path> bash scripts/bash/shell-qc.sh test`. Record
  `evidence/remediation-baseline/shell-qc-test.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, `ResolvedBatsVersion:`, the TAP plan line, the count of lines
  beginning `ok`, the count of lines beginning `not ok`, and a field
  `BaselineLocalTestTotal:` carrying the `ok` count. Acceptance: `EXIT_CODE:` is `0`, the
  `not ok` count is `0`, and `BaselineLocalTestTotal:` is a number the later delta task
  compares against.

- [x] [P0-T6] Record the coverage baseline from the last successful CI coverage run rather
  than from any local invocation. Write
  `evidence/remediation-baseline/shell-coverage.2026-09-08T07-30.md` carrying
  `Timestamp:`, `Command:` naming the `gh` read used, `EXIT_CODE:`,
  `BaselineRepoLineCoverage: 93.7`, `BaselineDirtLibLineCoverage: 94.05`, `Threshold: 85.0`,
  the run id `34194469882`, and a per-file table for the eight files matching
  `scripts/bash/cleanup[-_]worktrees*` with their current percentages. The eight are
  `cleanup-worktrees.sh`, `cleanup_worktrees_actions_lib.sh`,
  `cleanup_worktrees_detached_lib.sh`, `cleanup_worktrees_dirt_lib.sh`,
  `cleanup_worktrees_enumerate_lib.sh`, `cleanup_worktrees_lib.sh`,
  `cleanup_worktrees_report_records_lib.sh`, `cleanup_worktrees_scan_helper.sh`.
  Acceptance: both headline numeric fields are present as numbers, the table has exactly
  eight rows and names all eight files above, and the artifact states explicitly that
  `kcov` has no local route in this worktree and that
  `bash scripts/bash/shell-qc.sh test --coverage` exits 127 here.

- [x] [P0-T7] Measure the guard inventory in the classifier library. Run
  `grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  for the arithmetic count, `grep -c '# guard:' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  for the marked count, and
  `grep -nE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  for the numbered list. Record all three in
  `evidence/remediation-baseline/guard-enumeration.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and `Output Summary:`. The same artifact reproduces the source
  text of the eight named non-arithmetic verdict-guard sites at lines 172, 260, 311, 321,
  341, 403, 410, 447, taken with
  `sed -n '172p;260p;311p;321p;341p;403p;410p;447p' scripts/bash/cleanup_worktrees_dirt_lib.sh`.
  Acceptance: the arithmetic count is `30`, the marked count is `0`, the artifact lists
  thirty line numbers, the eight quoted source lines are present, and the artifact states
  the derived end-state targets **31 arithmetic lines, 37 marker lines, 39 registry rows**
  with the arithmetic that produces each.

- [x] [P0-T8] Measure the current line count of every shell file this cycle may touch with
  `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  and record it in `evidence/remediation-baseline/file-size-limit.2026-09-08T07-30.md`.
  The same artifact also records `StubDigest:`, the `md5sum` of
  `tests/fixtures/cleanup_worktrees/stub-bin/git`, which P5-T5 compares against to show
  this cycle added no stub arm. Acceptance:
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` is recorded as `463`,
  `scripts/bash/cleanup_worktrees_lib.sh` as `496`, `StubDigest:` is present and
  non-empty, and the artifact states the remaining headroom to 500 for each file.

- [x] [P0-T9] Measure the current scenario and record counts. Run
  `find tests/fixtures/cleanup_worktrees/scenarios -maxdepth 1 -type d -name 'dirt_*' | wc -l`
  and read the two literals in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats`. Record
  `evidence/remediation-baseline/scenario-counts.2026-09-08T07-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, `OnDiskScenarioCount:`, and `AssertedRecordTotal:`. Acceptance:
  `OnDiskScenarioCount:` is `25` and `AssertedRecordTotal:` is `30`.

- [ ] [P0-T10] Run `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  and record `evidence/remediation-baseline/pytest-push-down-contract.2026-09-08T07-30.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the passed
  count. Acceptance: `EXIT_CODE:` is `0` and the summary records `11 passed`.

---

### Phase 1 — N1: rung 4's tracked half must not resolve from an empty pathspec

- [x] [P1-T1] Create the scenario directory
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_staged_only_blob/` and copy
  into it, verbatim, the six non-classifier fixture files listed in this plan's fixture
  section from `tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/`. Acceptance: for
  each of the six filenames, `cmp -s` between the `dirt_unique` copy and the new copy exits
  `0`, and `git status --porcelain tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_staged_only_blob`
  lists the new directory as untracked.

- [x] [P1-T2] Write the six classifier fixture files for
  `dirt_tracked_staged_only_blob` exactly as tabulated in this plan's fixture section:
  `status._repo-wt_dirt.out`, `diff-quiet..staged_only.md.rc`,
  `rev-parse.verify.main_staged_only.md.rc`, `hash-object.staged_only.md.rc`,
  `diff-quiet..docs_tracked.md.rc`, and `rev-parse.verify.main_docs_tracked.md.rc`.
  Acceptance: `status._repo-wt_dirt.out` has exactly two lines, its first line is
  `AD staged_only.md`, and the five `.rc` files contain `0`, `1`, `128`, `0`, and `0`
  respectively.

- [x] [P1-T3] Add a test titled
  `dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE`
  to `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`, driving
  `classify_worktree_dirt` through the existing `dirt` helper at that file's `:41-44`. It
  asserts the record `DIRTFILE|/repo-wt/dirt|UNIQUE||AD|staged_only.md`, the record
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and the absence of the substrings
  `CONTENT_ON_MAIN||AD|` and `ALL_DISPOSABLE`. Acceptance: the `@test` title appears once
  in that file.

- [x] [P1-T4] Add the positive-direction test titled
  `dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN`
  to the same file, asserting the record
  `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md` from the same scenario.
  Acceptance: the `@test` title appears once in that file, and both new tests name the
  same scenario, so one probe result serves both directions.

- [x] [P1-T5] `[expect-fail]` Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  before any library change and record
  `evidence/regression-testing/fail-before-rung4-path-in-main.2026-09-08T08-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and the verbatim TAP
  lines for the two new tests. Acceptance: the output contains a line beginning `not ok`
  whose text ends with
  `dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE`,
  and a line beginning `ok ` whose text ends with
  `dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN`.
  The second line proves the fixture drives the ladder rather than failing to load.

- [x] [P1-T6] Apply decision D1 to `scripts/bash/cleanup_worktrees_dirt_lib.sh`: declare
  `erc=0` among the locals of `classify_dirt_entry`, and inside the existing
  `if ((drc == 0)); then` branch of rung 4's tracked half at `:297`, issue
  `cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet "main:$rel"`
  with its exit code captured into `erc` in the parent shell, redirected with `>/dev/null`
  and **not** with `>/dev/null 2>&1` for the reason given in D1, and emit `CONTENT_ON_MAIN`
  only under `if ((erc == 0)); then`. A non-zero `erc` emits nothing and falls through.
  The two literals this task creates, quoted here verbatim so the searches below have a
  defined target: `main:$rel` and `((erc == 0))`.
  Acceptance: `grep -cF 'main:$rel' scripts/bash/cleanup_worktrees_dirt_lib.sh` reports
  `2`, where it reported `1` before this task because rung 4's untracked half at `:319`
  already carries that token; `grep -cF '((erc == 0))' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  reports `1`; and `grep -cF '2>&1' scripts/bash/cleanup_worktrees_dirt_lib.sh` reports
  `1`, unchanged from the single pre-existing occurrence on the bounded-range probe at
  `:332`, which is the wrap-independent way to show the new read did not acquire a stderr
  redirect.

- [x] [P1-T7] Extend the library's header comment block with a paragraph explaining why
  rung 4's tracked positive answer is conditional, in the same register and layout as the
  existing `TWO-WAY CLASSIFICATION OF NON-ZERO EXITS` (`:40-46`) and
  `NO --ignored ON THE STATUS READ` (`:29-33`) paragraphs: `diff --quiet` exits 0 both when
  the compared content is identical and when the pathspec matched nothing, and only the
  first meaning supports a disposable verdict. Following the file's convention, the
  paragraph opens with an all-capital heading sentence, and this plan fixes that heading
  verbatim as `EMPTY PATHSPEC IS NOT A MATCH.` so the acceptance search has a short
  single-line target that cannot be split by rewrapping. Acceptance:
  `grep -cF 'EMPTY PATHSPEC IS NOT A MATCH.' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  reports `1`.

- [x] [P1-T8] Re-run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  and record `evidence/regression-testing/pass-after-rung4-path-in-main.2026-09-08T08-00.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, the TAP plan line, and the `ok`/`not ok`
  counts. Acceptance: `EXIT_CODE:` is `0`, the `not ok` count is `0`, and the output
  contains a line beginning `ok ` whose text ends with
  `dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE`.

- [x] [P1-T9] Update the membership test in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats`: add
  `dirt_tracked_staged_only_blob` to the explicit scenario list at `:220-228`, change the
  asserted record literal at `:250` from `30` to `32`, and update the explanatory comment
  at `:247-249` so the stated scenario count reads twenty-six and the two-entry count
  reads six. Acceptance:
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  exits 0 with 0 lines beginning `not ok`, and
  `grep -c 'dirt_tracked_staged_only_blob' tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  reports `1`.

- [x] [P1-T10] Re-run the three suites that exercise the rung-4 tracked half or the
  non-mutation property, to confirm the narrowing disturbed nothing:
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`.
  Record `evidence/regression-testing/sibling-check-phase1.2026-09-08T08-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, plan line, and `ok`/`not ok` counts. The artifact
  must also reproduce the reachability table stated in D1 over the **six** tracked entries
  that reach rung 4's tracked half — `dirt_rename_split`, `dirt_build_artifact_mixed`,
  `dirt_build_artifact_plus_content`, `dirt_staged_tree_no_match`,
  `dirt_staged_tree_worktree_delta`, `dirt_tracked_read_errors` — giving for each the
  status entry, the `diff-quiet` fixture value, and whether the new read was issued.
  Acceptance: `EXIT_CODE:` is `0`, the `not ok` count is `0`, the table has exactly six rows
  and names all six scenarios above, it records `1` for the four scenarios
  `dirt_build_artifact_mixed`, `dirt_build_artifact_plus_content`,
  `dirt_staged_tree_no_match`, and `dirt_staged_tree_worktree_delta`, `128` for
  `dirt_tracked_read_errors`, and "no fixture, stub default 0" for `dirt_rename_split`; it
  records that `dirt_rename_split`'s `R ` entry still resolves `CONTENT_ON_MAIN` while the
  other five never reach the new read; and it carries a separate statement, outside the
  table, that `dirt_build_artifact_added_file` was checked and does **not** reach rung 4
  because its `A  src/Legacy/Legacy.csproj` entry resolves `DISPOSABLE_BUILD_ARTIFACT` at
  rung 3 with `total` equal to 1 — 0 changed lines from the absent worktree diff plus 1 from
  the checked-in cached diff — so its `diff-quiet..src_Legacy_Legacy.csproj.rc` fixture,
  which exists and contains `1`, is never read.

---

### Phase 2 — Guard enumeration, the registry, and the enforcement gate

- [x] [P2-T1] Append a `# guard:<id>` trailing comment to every guard-shaped line in
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` — the 31 lines matching the arithmetic
  regex **and** the six non-arithmetic-only lines at cycle-start positions 172, 260, 341,
  403, 410, and 447. Lines 311 and 321 receive exactly one marker each, because each
  already matches the arithmetic regex; their second registry row is distinguished by its
  `mutation`, not by a second marker. Ids are lowercase, hyphen-separated, unique, and
  placed at end of line. The seventeen ids in this plan's mandatory-marker-id section must be
  spelled exactly as listed. No line is added or removed by this task; only trailing
  comments are appended. Acceptance, all four commands run against
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`:

  1. `grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' <file>` reports `31`;
  2. `grep -cE '# guard:[a-z0-9-]+$' <file>` reports `37`;
  3. `grep -oE '# guard:[a-z0-9-]+$' <file> | sort | uniq -d` produces no output;
  4. the prefix check

     ```
     grep -oE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh | cut -d: -f2 | LC_ALL=C sort -u | awk 'NR>1 && index($0,p)==1 {print p" "$0} {p=$0}'
     ```

     produces no output. Sorted order makes adjacency sufficient: if one id is a prefix of
     another, every id lexically between them shares that prefix, so the immediate
     successor exposes the pair. That argument holds under **byte** ordering and is not
     guaranteed under a punctuation-folding collation, which can place a non-prefix id
     between the two members of a prefix pair and break the adjacency the check relies on.
     `LC_ALL=C` on the `sort` is therefore load-bearing rather than stylistic, and the same
     variable is applied to the `sort` in this command and nowhere else in it, because
     `grep`, `cut` and `awk` here are byte-oriented already. This is the check D-3 requires;
     `uniq -d` alone does not detect a prefix, and an unanchored `sed` address over a prefix
     id would mutate two guards under one row.

- [x] [P2-T2] Verify the marker pass changed no behaviour and survived the formatter's
  layout rules. Re-run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
  and then run `bash scripts/bash/shell-qc.sh check`. Record
  `evidence/regression-testing/marker-pass-neutral.2026-09-08T08-30.md` with `Timestamp:`,
  `Command:` for both commands, `EXIT_CODE:` for both, plan line, `ok`/`not ok` counts, the
  library line count before and after the marker pass, and the combined stdout and stderr
  of the check command reproduced verbatim. Acceptance: both exit codes are `0`, the
  `not ok` count is `0`, the two line counts are equal, the check command's combined output
  is empty, and `grep -cE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh`
  still reports `37` after the check run. The re-count is what detects a formatter that
  relocated a trailing comment off the end of its line, which would silently break every
  `$`-anchored `sed` address in the registry.

- [x] [P2-T3] Create `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` with a
  single leading comment line documenting the columns and one tab-separated row per
  registry row, columns in this order: `id`, `kind`, `scenario`, `baseline_aggregate`,
  `mutation`, `reason`. The `mutation` column holds a complete `sed` substitute command
  including its own delimiter. The file carries no blank lines. Populate the five rows
  named in this plan's remediated-guard table with kind `SEPARATED` and the scenario,
  aggregate, and mutation given there; leave `reason` empty for them. Acceptance:
  `grep -vc '^#' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` reports `5`,
  `grep -c '^$' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` reports `0`, and
  each of the five literals `build-artifact-vacuous-confinement`,
  `rung4-tracked-path-in-main`, `rung4-tracked-hard-fail`, `hash-object-hard-fail`, and
  `find-object-hard-fail` appears exactly once in the file.

- [x] [P2-T4] Create `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` with a
  header stating its subject and mechanism, and with a helper that, given a registry row,
  composes the `sed` program as the `$`-anchored address `/# guard:<id>$/` immediately
  followed by the row's `mutation` value, applies it to the library with `sed` into a shell
  variable, rejects the result if `bash -n` reading from a here-string fails, and evaluates
  it with `eval` in a child shell in place of sourcing the real library. "In place of
  sourcing the real library" replaces the third `source` only. The child shell still sources
  `scripts/bash/cleanup_worktrees_enumerate_lib.sh` and `scripts/bash/cleanup_worktrees_lib.sh`
  from disk, in that order, before evaluating the mutated text, exactly as the existing
  helpers at `tests/shell/test_cleanup_worktrees_dirt_classify.bats:41-44` do: the
  `cleanup_wt_git` seam that `CLEANUP_WT_GIT_BIN` drives is defined in the enumerate
  library, so a child that sourced only the mutated dirt library would fail at the first
  git call for a reason unrelated to the guard under test. The address is
  `$`-anchored for the reason given in D2 part five. The composed program is passed to
  `sed` as a **single argument** and is never itself `eval`ed, because two of the fixed
  mutations contain `$blob` and `$agg` and `eval` would expand them to the empty string
  before `sed` saw them. The helper runs the child shell twice per row under
  `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO`, once unmutated and once mutated,
  with the worktree argument fixed at the literal `/repo-wt/dirt` for every row — the path
  every checked-in `dirt_*` scenario is keyed to, and the value bound to `WT` at
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats:36` — so the registry needs no
  worktree-path column. For each run it captures the record channel defined in D3 — stdout
  and exit status of `classify_worktree_dirt`, then stdout and exit status of
  `clear_disposable_dirt` — with stderr redirected to a separate variable holding the
  stub's argv log. The helper creates no file on disk and uses no scratch directory.

  For a row whose `kind` is `EXEMPT` and whose `mutation` is form 2 of D2 part six, the
  helper runs the child shell a **third** time under the sibling constant — `((1))` where
  the row carries `((0))` and `((0))` where the row carries `((1))` — composed by the helper
  from the row's own marked line rather than read from any registry column, and captures the
  same two channels from it. This is the both-direction rule stated in D3. The accumulator
  that collects rows failing it is named, verbatim, `EXEMPT_SIBLING_DIFFERED`, which fixes a
  short single-line token the acceptance search in P2-T6 can target. No third run is made
  for a row whose mutation is one of the eight literals of D2 part two, because those have
  no sibling constant, and none is made for a `SEPARATED` or `ARGV` row, because those
  already carry an observed difference.

  The helper **accumulates** per-row outcomes rather than asserting inside the row loop.
  For each of the obligations defined in D3 it appends the offending row's id to a
  per-obligation accumulator string and continues to the next row; the loop body contains
  no `return`, no `exit`, and no `[ ... ]` assertion. A row that fails obligation 1 is
  recorded in that obligation's accumulator and is **not** evaluated against obligations 2
  through 6, because a missing scenario directory makes the two channels unobtainable rather
  than unequal; recording such a row in the channel-comparison accumulator as well would
  make P2-T10's per-obligation attribution false. Obligations 2 through 6 are evaluated
  independently of one another, so a row may appear in more than one of their accumulators. The assertions are made once, after
  the loop, one per obligation, each requiring its accumulator to be empty and printing it
  when it is not. A bats test asserting inside the loop aborts on the first offending row,
  which would make P2-T10's prediction that the diagnostic names four ids unsatisfiable
  however many rows actually fail. Acceptance: the file exists;
  `grep -c 'bash -n' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` reports
  at least `1`;
  `grep -cF '# guard:' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports at least `1`; `grep -cF 'clear_disposable_dirt' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports at least `1`;
  `grep -cF 'EXEMPT_SIBLING_DIFFERED' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports at least `1`, which catches a divergent spelling of the accumulator **in this
  task** rather than two tasks later: the token is created here and is searched again by
  P2-T6, and without a check here a typo would first surface as a P2-T6 acceptance failure
  whose cause sits in a task already checked off; and the temporary-file check

  ```
  grep -v '^[[:space:]]*#' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats | grep -cE 'mktemp|tempfile|BATS_TMPDIR|BATS_TEST_TMPDIR|/tmp/|>[[:space:]]*"?\$\{?TMPDIR'
  ```

  reports `0`. The widened pattern is required because a bare `mktemp` search is satisfied
  by a harness that writes into `$BATS_TEST_TMPDIR`, `$BATS_TMPDIR`, `/tmp/`, or `$TMPDIR`,
  none of which is permitted by the no-temporary-files constraint. The leading
  `grep -v '^[[:space:]]*#'` is equally required, and for the opposite reason: this task
  instructs the executor to write a header stating the harness's subject and mechanism, and a
  natural header sentence explaining that the harness uses no `mktemp` scratch file would
  itself match the pattern and drive the count above zero however correct the harness is,
  making the condition unsatisfiable by the executor's own compliance. Stripping comment
  lines removes that interference without weakening the check, because a comment line cannot
  create a file.

- [x] [P2-T5] Add the enumeration test titled
  `every guard-shaped line in the dirt library is marked and every registry row names a marked id`
  to that suite. It derives the arithmetic-matched line set and the marked id set from
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`, derives the row set from the registry, and
  asserts:

  1. every line matching the arithmetic regex carries a marker;
  2. every marked id backs at least one registry row;
  3. every registry row's `id` is a marked id;
  4. no marker id occurs on two different library lines;
  5. no two registry rows share the same (`id`, `mutation`) pair;
  6. each of the eight (`id`, `mutation`) pairs tabulated in this plan's named
     non-arithmetic guard table is present in the registry, named as literals in the test
     body, with the two `\|`-carrying mutations spelled in the unescaped form fixed in D2
     part two;
  7. every registry row's `mutation` value is either exactly one of the eight
     non-arithmetic literals fixed in D2 part two, or exactly `s/((EXPR))/((0))/` or exactly
     `s/((EXPR))/((1))/`, where `EXPR` is **derived by the test from the library**, not
     written into the test: for the row's marked line the test extracts the arithmetic
     comparison the enumeration regex matches, strips the enclosing `((` and `))`, composes
     the two admissible strings, and asserts string equality against the registry's
     `mutation` column. All five mutations in this plan's remediated-guard table are
     already instances of the derived form, so the literal escape hatch is exactly the eight
     rows of D2 part two and no wider. **For a marked line carrying no arithmetic
     comparison** — the six non-arithmetic-only lines at cycle-start positions 172, 260,
     341, 403, 410 and 447, where the `EXPR` extraction yields nothing — only the
     eight-literal disjunct applies and the derived disjunct is not evaluated. The test must
     branch on the extraction being empty rather than composing `s/(())/((0))/` from an
     empty `EXPR` and comparing against it, because that composed string equals no admissible
     mutation and would fail all six rows.

  Invariant 2 is deliberately "at least one" rather than "exactly one", so that lines 311
  and 321 may each back two rows. Invariant 6 is what carries the non-arithmetic half of
  the obligation, which no regex over the library can derive; it is anchored to the library
  rather than to the table because P2-T6 independently requires every row's mutation to
  actually change the library source at its marked line. Invariant 7 constrains all 31
  arithmetic rows and is what stops the twenty-one of them whose mutation this plan does
  not otherwise fix from being satisfied by an inert
  mutation: without it the executor may choose any `sed` program, and a comment or
  whitespace edit changes the source, parses, leaves both channels identical, and is
  written `EXEMPT` with every other obligation met. Because the test derives `EXPR` from the
  library rather than holding a table of expected strings, invariant 7 fails when a row's
  mutation targets a different line than its marker, and it cannot be satisfied by editing
  the test. Acceptance: the `@test` title appears once in the file; the test body reads the
  marked id set from `scripts/bash/cleanup_worktrees_dirt_lib.sh` rather than from a list
  written in the suite; the eight literal ids `diff-header-skip`, `rung1-y-column-gate`,
  `hash-object-hard-fail`, `rung4-untracked-main-present`, `history-hit-nonempty`,
  `rename-payload-split-gate`, `unique-verdict-tally`, and
  `clear-requires-all-disposable` each appear at least once in the test body; and

  ```
  grep -cF '((0))' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats
  ```

  reports at least `1`, which is the wrap-independent evidence that invariant 7's composed
  admissible forms are present in the test body rather than the invariant being described
  only in a comment.

- [x] [P2-T6] Add the separation test titled
  `every registered guard is observable under its own neutralization` to that suite. For
  each registry row it runs the helper and asserts, in this order:

  1. `[ -d "${SCEN}/<scenario>" ]` — the named scenario directory exists — and the
     scenario name begins with `dirt_`;
  2. the mutated source differs from the unmutated source, so the `sed` program actually
     fired; exactly one line differs between the two versions; that line carries a
     `# guard:` marker; and the two versions of that line **still differ** after both have
     had their trailing `# guard:` comment stripped and their runs of whitespace collapsed
     to a single space. The comment strip rejects a mutation that edits only the marker
     comment; the whitespace collapse rejects a mutation that only reindents the code. Both
     are needed: a mutation that inserts a second space inside the code region survives the
     comment strip alone, because the two stripped strings still differ as byte sequences;
  3. `bash -n` accepts the mutated source;
  4. the **unmutated** `classify_worktree_dirt` call emitted at least one `DIRTFILE|`
     record, which is the proof that the ladder executed under that scenario. The
     obligation is scoped to that call and not to the two-call group, and it does not
     accept a non-zero exit as an alternative, for the reasons stated in D3;
  5. kind-specific, asserting for every kind both the difference and the identity the D3
     kind table states, so that no kind is satisfiable by writing a verdict into the
     registry:
     - `SEPARATED` — the mutated record channel **differs from** the unmutated record
       channel;
     - `ARGV` — the mutated record channel **equals** the unmutated record channel, the
       mutated argv log **differs from** the unmutated argv log, and the `reason` begins
       with `ARGV-ONLY:` followed by at least one non-space character;
     - `EXEMPT` — the mutated record channel **equals** the unmutated record channel, the
       mutated argv log **equals** the unmutated argv log, and the `reason` begins with
       `RECORDS-AND-ARGV-IDENTICAL:` followed by at least one non-space character;
  6. for an `EXEMPT` row whose `mutation` is form 2, the both-direction rule of D3: the
     sibling-constant run the P2-T4 helper composes must also leave both channels equal to
     the unmutated ones. Rows failing this accumulate into `EXEMPT_SIBLING_DIFFERED`. The
     rule is not applied to a row whose mutation is one of the eight literals.

  Every assertion applies to every row of its kind, including `EXEMPT` rows, which is what
  stops a row from being satisfied by editing the registry alone. Assertion 5 asserting the
  *absence* of a difference for `ARGV` and `EXEMPT` is the change this revision makes and
  the reason the gate is not vacuous; D3 records why the "fails on an improvement" objection
  is answered by P3-T7's re-classification authorization rather than by weakening the
  assertion.

  The assertions are made **after** the row loop, once each, over the accumulators the
  P2-T4 helper fills, and each prints its accumulated offending ids to
  stderr when non-empty. The row loop body makes no assertion and contains no `return` and
  no `exit`, so every row is evaluated and a failure names every offending id rather than
  only the first. Acceptance: the `@test` title appears once in the file;

  ```
  sed -n '/^@test "every registered guard is observable under its own neutralization"/,/^}/p' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats | grep -cE '^[[:space:]]*(return|exit)\b'
  ```

  reports `0`; `grep -cF 'RECORDS-AND-ARGV-IDENTICAL:' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports at least `1`;
  `grep -cF '# guard:' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports at least `2`, one occurrence for the P2-T4 address composition and at least one
  for assertion 2's comment strip; and
  `grep -cF 'EXEMPT_SIBLING_DIFFERED' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  reports at least `2`, the accumulator's assignment inside the row loop and its assertion
  after it. That literal is created by this task and by P2-T4 and is quoted verbatim in both
  so the search has a defined target; it is the wrap-independent evidence that the
  both-direction rule is implemented rather than only described, because a suite that
  merely documented the rule in a comment would carry the token at most once.

- [x] [P2-T7] Add the third test titled
  `the eighteen pinned guard rows carry the registry kinds this plan fixes`
  to that suite. It asserts eighteen pins over seventeen distinct ids, in three groups.

  **Group A — twelve id-keyed `SEPARATED` pins.** Each of these ids has at least one registry
  row whose `kind` is exactly `SEPARATED`:

  `build-artifact-vacuous-confinement`, `rung4-tracked-path-in-main`,
  `rung4-tracked-hard-fail`, `find-object-hard-fail`, `status-read-hard-fail`,
  `clear-reset-hard-fail`, `clear-clean-hard-fail`, `clear-requires-all-disposable`,
  `unique-verdict-tally`, `history-hit-nonempty`, `rung4-tracked-gate`,
  `rung4-tracked-content-equal`.

  **Group B — three id-keyed `SEPARATED`-or-`ARGV` pins.** Each of these ids has at least one
  registry row whose `kind` is `SEPARATED` or `ARGV`: `rung1-y-column-gate` (R1's Y-column
  gate at cycle-start line 260), `rename-payload-split-gate` (R2's ` -> ` split gate at 403),
  and `diff-header-skip` (R5's diff-header skip at 172).

  Every id in groups A and B backs exactly one registry row, so id-keying is unambiguous for
  all fifteen of them.

  **Group C — three pair-keyed pins on lines 311 and 321.** Those two lines each carry one
  marker and back two registry rows, so an id-keyed pin on either id is satisfied by whichever
  of that id's two rows happens to carry the demanded kind and leaves the other row
  unconstrained. Each group-C pin is therefore selected by `id` **together with** a test on
  whether the row's `mutation` begins with the four characters `s/((`:

  1. `id` is `hash-object-hard-fail` and `mutation` **begins** `s/((` — the arithmetic row —
     has `kind` exactly `SEPARATED`;
  2. `id` is `hash-object-hard-fail` and `mutation` does **not** begin `s/((` — the
     `[[ -z $blob ]]` literal row — has `kind` `SEPARATED` or `ARGV`;
  3. `id` is `rung4-untracked-main-present` and `mutation` does **not** begin `s/((` — the
     `[[ -n $mainblob && $mainblob == "$blob" ]]` literal row — has `kind` exactly
     `SEPARATED`.

  The prefix test is exact rather than heuristic. D2 part six admits exactly two shapes for a
  `mutation`: the arithmetic form `s/((EXPR))/((0))/` or `s/((EXPR))/((1))/`, which always
  begins `s/((`, and one of the eight fixed literals, every one of which begins `s%`. The test
  is written with a plain string comparison rather than a regular expression or a quoted copy
  of the mutation literal, so that the `%`, `$` and `\[` characters those literals carry never
  have to survive a shell quoting round-trip.

  The **arithmetic** row on line 321 is deliberately not pinned, for the reason given in the
  thirteen-pinned-guards section: it is inert in both directions under its line's witness
  scenario, so a `SEPARATED` pin on it would be unsatisfiable. Pinning the literal half by
  pair is what binds the fail-open verdict guard without that side effect.

  The five pins on the remediated-guard table's rows — four of them in group A and one, line
  311's arithmetic row, in group C — stop a downgrade re-opening N1 or N2. The three group-B
  pins are held because cycle 1 proved each separable, so a downgrade to
  `EXEMPT` would re-open the class of defect they represent. The six added by the round-3
  revision are each on the path between a classification and the irreversible action, and each
  is demonstrably separable under a checked-in scenario:

  - `clear-requires-all-disposable` (447) is the precondition that authorizes the clear at
    all, and `clear-reset-hard-fail` (452) and `clear-clean-hard-fail` (457) are the two
    failure checks inside it;
  - `unique-verdict-tally` (410) is what makes an entry's `UNIQUE` verdict reach the
    aggregate that 447 reads, so neutralizing it turns a `HAS_UNIQUE` worktree into an
    `ALL_DISPOSABLE` one;
  - `status-read-hard-fail` (371) is the guard whose neutralization empties the record
    stream entirely while still returning 0, which is the shape a downstream caller is least
    able to distinguish from a clean worktree;
  - `history-hit-nonempty` (341) is rung 5's verdict gate: it is the only site at which
    `CONTENT_IN_HISTORY` is produced, so neutralizing it makes that verdict unreachable,
    and its separability is demonstrated under `dirt_content_in_history`.

  The four pins added by the round-4 revision close the bound the earlier text claimed but
  did not hold. Each is a fail-open-direction verdict guard that a cycle-1 or cycle-2 finding
  implicates and that no earlier pin covered:

  - `rung4-tracked-gate` (294) is the gate admitting a tracked entry to rung 4's tracked half
    at all, and `rung4-tracked-content-equal` (297) is the gate that emits `CONTENT_ON_MAIN`
    from it. Both sit inside the range `cleanup_worktrees_dirt_lib.sh:294-305` that N1 itself
    cites (`remediation-inputs.2026-09-08T06-51.md:34`), so leaving them unpinned would have
    left two of the four guard-shaped lines in the finding's own range parkable at `EXEMPT`;
  - `rung4-untracked-main-present` (321) is rung 4's untracked main-blob equality test. It is
    the sole route by which an untracked entry can be called `CONTENT_ON_MAIN`, so forcing it
    true converts `HAS_UNIQUE` to `ALL_DISPOSABLE` under `dirt_rename_split` and arms
    `--clear-disposable` on a worktree holding unique content;
  - the `hash-object-hard-fail` **literal** row (311) is the empty-blob fail-closed test.
    Removing it lets the ladder proceed past a failed content read with an empty object id,
    which is a fail-open direction on the read whose failure carries no verdict.

  `clear-clean-hard-fail` is the specific case
  D3's widened observation channel exists to expose: it is the failure check on
  `clean -fd`, it separates on the record channel only, and without a pin a registry could
  record it `EXEMPT` against a scenario that never reaches the clear and the widening would
  never be exercised. Every one of the thirteen rows added or restated here is derived against
  a named checked-in witness scenario in this plan's thirteen-pinned-guards section, so no pin
  is unsatisfiable. All four round-4 witnesses exist before this task runs:
  `dirt_rename_split` and `dirt_staged_tree_worktree_delta` are checked in at cycle start, and
  `dirt_tracked_staged_only_blob` is created by P1-T1 and P1-T2.

  Acceptance: the `@test` title appears once in the file; all seventeen distinct pinned ids
  appear as literals in the test body; the range-scoped count

  ```
  sed -n '/^@test "the eighteen pinned guard rows carry the registry kinds this plan fixes"/,/^}/p' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats | grep -cF 'clear-clean-hard-fail'
  ```

  reports at least `1`; and the range-scoped count

  ```
  sed -n '/^@test "the eighteen pinned guard rows carry the registry kinds this plan fixes"/,/^}/p' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats | grep -cF 'hash-object-hard-fail'
  ```

  reports at least `2`; and the range-scoped count

  ```
  sed -n '/^@test "the eighteen pinned guard rows carry the registry kinds this plan fixes"/,/^}/p' tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats | grep -cF 's/(('
  ```

  reports at least `1`.

  `clear-clean-hard-fail` is the pin whose omission the round-3 review identified as the one
  that would let the widened observation channel go unexercised, so it is the id the first
  search names. The second search reports at least `2` because `hash-object-hard-fail` carries
  two pins in this test, one for each of its two registry rows, so a test body naming it once
  has implemented only one of them. The third search targets the `s/((` discriminator that
  keys all three group-C pins; a test body that omitted the discriminator entirely would carry
  the token zero times, so a count of at least `1` is the wrap-independent evidence that the
  keying is by mutation prefix rather than by id alone. The threshold is `1` and not `2`
  because an implementation that factors the discriminator into a single shared helper called
  from all three pin sites carries the token once while implementing the pair-keying exactly
  as specified, so a threshold of `2` would fail a conforming test body. The pair-keying
  itself is independently enforced by P2-T8 acceptance command 10, whose three
  `index($5,"s/((")` checks each read a distinct registry row and each can fail. `s/((` is a
  four-character single-line token containing none of `<`, `>`, `${`, `$(` or `%`, so it is a
  real assertion target rather than a documented command shape.
  All three counts are scoped to this test's own body rather than to the whole file because
  each token may legitimately appear elsewhere in the suite — in the header comment, or in
  P2-T5's invariant-7 composition — and a file-wide search would then report a non-zero count
  even if this test omitted the pin. All three `sed` range addresses quote this task's own
  `@test` title verbatim, and the range terminates on the first column-0 `}`, which is the
  closing brace of this test.

- [x] [P2-T8] Complete the registry: add a row for each of the **34** guards not named in
  this plan's remediated-guard table — the 26 remaining arithmetic guards and the eight
  named non-arithmetic guards — bringing the file to **39** rows. For each, run the harness
  against a checked-in `dirt_*` scenario that exercises it, observe whether the record
  channel defined in D3 changes, whether only the argv log changes, or whether neither
  changes, and set `kind` to `SEPARATED`, `ARGV`, or `EXEMPT` accordingly. The kind is
  **determined by that observation, not chosen**: the three kinds partition the outcome
  space of the two comparisons for an **admissible** (`mutation`, `scenario`) pair — one that
  survives the both-direction rule — so exactly one kind is correct for such a pair. A
  form-2 pair whose recorded constant is inert while its sibling separates is inadmissible and
  maps to no kind; the remedy is to rewrite the row onto the separating constant, not to
  record it `EXEMPT`. Before writing `EXEMPT` on a form-2 row, run the sibling constant as
  well and confirm it is equally unobservable; if it is not, the row takes the sibling
  constant as its `mutation` and the kind its observation gives. P2-T6 re-derives all of
  this at gate time, so a row whose recorded kind does not match the observation fails the
  suite.

  Thirteen rows do not take a freely chosen scenario. The `scenario` column of the thirteen
  rows named in this plan's thirteen-pinned-guards section is fixed to the witness scenario
  tabulated there — `dirt_unique` for `status-read-hard-fail`,
  `clear-requires-all-disposable` and `unique-verdict-tally`; `dirt_clear_reset_failed` for
  `clear-reset-hard-fail`; `dirt_clear_clean_failed` for `clear-clean-hard-fail`;
  `dirt_content_in_history` for `history-hit-nonempty`; `dirt_build_artifact` for
  `diff-header-skip`; `dirt_staged_tree_worktree_delta` for `rung1-y-column-gate` **and** for
  the `hash-object-hard-fail` literal row; `dirt_rename_split` for
  `rename-payload-split-gate` **and** for `rung4-untracked-main-present`; and
  `dirt_tracked_staged_only_blob` for `rung4-tracked-gate` and
  `rung4-tracked-content-equal` — and their `mutation` values are the literals tabulated
  there. Two witness scenarios each carry two pinned rows, which is permitted: the rows are
  distinct under (`id`, `mutation`) and each is mutated alone.

  The eight non-arithmetic rows use the `id` and `mutation` values fixed in this plan's D2
  table, with the two `\|`-carrying mutations taken from the unescaped fenced form rather
  than from the table cell. After this revision all eight also have their `scenario` column
  fixed by the thirteen-pinned-guards table, so only their `kind`, `baseline_aggregate` and
  `reason` columns are filled by observation. The `mutation` column of each of the 26
  arithmetic rows is **not** free: it must be exactly `s/((EXPR))/((0))/` or exactly
  `s/((EXPR))/((1))/` per D2 part six, and P2-T5's invariant 7 derives `EXPR` from the library
  and fails the suite otherwise. For five of those 26 — `status-read-hard-fail`,
  `clear-reset-hard-fail`, `clear-clean-hard-fail`, `rung4-tracked-gate` and
  `rung4-tracked-content-equal` — the constant is fixed by the thirteen-pinned-guards table
  and is not chosen here; the other 21 take whichever constant the observation supports,
  subject to D3's both-direction rule. Every row's `scenario` column names a real directory
  under
  `tests/fixtures/cleanup_worktrees/scenarios/` whose name begins with `dirt_`. Every
  `ARGV` row's `reason` begins with
  `ARGV-ONLY:` and every `EXEMPT` row's `reason` begins with
  `RECORDS-AND-ARGV-IDENTICAL:`, each followed by prose stating the mechanism that makes
  the guard unobservable on the other channel. All 34 rows this task adds name a scenario
  directory that already exists, so all 34 can be observed here; the only two rows naming a
  directory that does not yet exist are the two P2-T3 wrote against the scenarios P3-T3 and
  P3-T4 create. Completing the registry before the fail-before run is what makes P2-T10's
  failures attributable: the four ids it names fail on the scenario-directory check or on
  the channel comparison, and none fails on enumeration or registry shape. Acceptance:

  1. `grep -vc '^#' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` reports `39`;
  2. `grep -c '^$' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` reports `0`;
  3. `awk -F'\t' '!/^#/ && $2 !~ /^(SEPARATED|ARGV|EXEMPT)$/' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
     produces no output;
  4. `awk -F'\t' '!/^#/ && $2=="EXEMPT" && $6 !~ /^RECORDS-AND-ARGV-IDENTICAL: *[^ ]/' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
     produces no output;
  5. `awk -F'\t' '!/^#/ && $2=="ARGV" && $6 !~ /^ARGV-ONLY: *[^ ]/' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
     produces no output;
  6. `awk -F'\t' '!/^#/ && $3 != "dirt_tracked_probe_error_in_history" && $3 != "dirt_build_artifact_empty_diff" {print $3}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort -u | while read -r s; do [ -d "tests/fixtures/cleanup_worktrees/scenarios/$s" ] || echo "MISSING $s"; done`
     produces no output. The two exempted names are the scenarios P3-T3 and P3-T4 create;
     P2-T3 already writes registry rows naming them, so the unexempted form of this command
     cannot pass at this point in the plan and would leave the task permanently unchecked.
     P3-T7 runs the unexempted form once both directories exist, so the exemption is
     temporal rather than permanent;
  7. `awk -F'\t' '!/^#/ {print $1"\t"$5}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort | uniq -d`
     produces no output, confirming (`id`, `mutation`) row identity;
  8. `awk -F'\t' '!/^#/ && $3 !~ /^dirt_/' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
     produces no output, confining every row to the `dirt_*` scenario set. Without this
     restriction a row may name any of the non-`dirt_*` directories under `scenarios/`,
     including `dirty_worktree_status_error`, which is keyed to `/repo-wt/dirty`, supplies
     no `status._repo-wt_dirt.out`, and would let a row pass with the ladder never having
     executed;
  9. P2-T7's twelve **id-keyed** `SEPARATED` pins — group A — are present in the registry
     itself, not only in the suite:

     ```
     for id in build-artifact-vacuous-confinement rung4-tracked-path-in-main rung4-tracked-hard-fail find-object-hard-fail status-read-hard-fail clear-reset-hard-fail clear-clean-hard-fail clear-requires-all-disposable unique-verdict-tally history-hit-nonempty rung4-tracked-gate rung4-tracked-content-equal; do awk -F'\t' -v i="$id" '!/^#/ && $1==i && $2=="SEPARATED"{n++} END{if(n==0) print "MISSING " i}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv; done
     ```

     produces no output. Each of the twelve ids backs exactly one registry row, so the id key
     is unambiguous. This is a registry-shape check and is satisfiable at this point in the
     plan even though three of the twelve do not yet show a separating observation
     — `build-artifact-vacuous-confinement`, `rung4-tracked-hard-fail` and
     `find-object-hard-fail` — because it reads the `kind` column, while P2-T6 is what runs
     the harness and is what P2-T10 records failing for them;
  10. P2-T7's three **pair-keyed** pins — group C, on lines 311 and 321 — are present in the
      registry as well. Each is selected by `id` together with a prefix test on the `mutation`
      column rather than by a quoted copy of the mutation literal, so the `%`, `$` and `\[`
      characters those literals carry never have to survive a shell quoting round-trip. All
      three of

      ```
      awk -F'\t' '!/^#/ && $1=="hash-object-hard-fail" && index($5,"s/((")==1 && $2=="SEPARATED"{n++} END{if(n==0) print "MISSING hash-object-hard-fail arithmetic row"}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv
      ```

      ```
      awk -F'\t' '!/^#/ && $1=="hash-object-hard-fail" && index($5,"s/((")!=1 && ($2=="SEPARATED" || $2=="ARGV"){n++} END{if(n==0) print "MISSING hash-object-hard-fail literal row"}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv
      ```

      ```
      awk -F'\t' '!/^#/ && $1=="rung4-untracked-main-present" && index($5,"s/((")!=1 && $2=="SEPARATED"{n++} END{if(n==0) print "MISSING rung4-untracked-main-present literal row"}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv
      ```

      produce no output. `index($5,"s/((")==1` selects the arithmetic row of a marker that
      backs two rows and `!=1` selects the literal row, exactly, because D2 part six admits
      only `s/((EXPR))/((0))/` and `s/((EXPR))/((1))/` for an arithmetic row and every one of
      the eight fixed literals begins `s%`. Each command can fail: a registry that records the
      `[[ -z $blob ]]` row `EXEMPT` leaves `n` unset in the second command, which prints
      `MISSING hash-object-hard-fail literal row`, and a registry that records the
      `[[ -n $mainblob && ... ]]` row `EXEMPT` does the same in the third. The id-only forms of
      these two checks would pass in both of those states — satisfied by the arithmetic sibling
      that shares the marker — which is precisely the defect this command exists to close;
      the first command is written pair-keyed for the same reason in the opposite direction, so
      that the `SEPARATED` pin on line 311's arithmetic row cannot be discharged by its literal
      sibling. The three commands are registry-shape checks and are satisfiable here even
      though line 311's arithmetic row does not yet separate, for the reason command 9 gives.

- [x] [P2-T9] Record the classification evidence in
  `evidence/qa-gates/guard-registry-classification.2026-09-08T08-30.md`: a table of all
  **39** rows, one row per registry row, giving the `id`, the library line its marker sits
  on, the `mutation`, the `kind`, the `scenario`, and the observed difference or its
  absence. Rows sharing a marker id are listed separately and distinguished by their
  `mutation`.

  Four rows cannot yet show a separating observation at this point in the plan and their
  observation cells carry the fixed token `PENDING-PHASE-3` instead. Two of them —
  `build-artifact-vacuous-confinement` against `dirt_build_artifact_empty_diff` and
  `rung4-tracked-hard-fail` against `dirt_tracked_probe_error_in_history` — name a directory
  P3-T4 and P3-T3 have not created yet, so the harness cannot run for them at all. The other
  two — `hash-object-hard-fail` against `dirt_classifier_read_error` and
  `find-object-hard-fail` against `dirt_history_read_error` — name directories that exist but
  whose separating payload files P3-T2 and P3-T1 have not added, so the harness runs and
  observes no difference. All four are closed by P3-T8, which records the same rows with
  their post-Phase-3 observations.

  Acceptance: the table has 39 rows; the counts of `SEPARATED`, `ARGV`, and
  `EXEMPT` are stated and sum to 39; every non-`SEPARATED` row reproduces both its
  `scenario` value and its full `reason` value, so an unattempted classification is visible
  on the face of the evidence; **every `EXEMPT` row whose `mutation` is form 2 additionally
  records the sibling constant that was run and states that both channels were identical
  under it**, which is the recorded form of D3's both-direction rule and is what
  distinguishes a guard that is genuinely unobservable under its scenario from one parked
  at `EXEMPT` by choosing the inert constant; the artifact states that 37 distinct marker
  ids back the 39 rows, naming the two ids that back two rows each; and exactly four
  observation cells carry `PENDING-PHASE-3`, on the four rows named above and no others.

- [x] [P2-T10] `[expect-fail]` Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  with the registry complete at 39 rows and the four N2 fixtures not yet present.
  Record `evidence/regression-testing/fail-before-guard-separation.2026-09-08T08-30.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and the verbatim TAP
  output.

  The four ids expected in the diagnostic do **not** all fail on the same obligation, and
  the artifact must record which. `build-artifact-vacuous-confinement` names
  `dirt_build_artifact_empty_diff` and `rung4-tracked-hard-fail` names
  `dirt_tracked_probe_error_in_history`; neither directory exists until P3-T4 and P3-T3, so
  those two fail **obligation 1**, the scenario-directory check. `hash-object-hard-fail`
  and `find-object-hard-fail` name `dirt_classifier_read_error` and
  `dirt_history_read_error`, which do exist, so those two fail **obligation 5**, the
  `SEPARATED` channel comparison, because their separating payload files are not added
  until P3-T2 and P3-T1. Because P2-T4's helper accumulates rather than asserting per row,
  a single run reports all four. Acceptance: the output contains a line beginning `not ok`
  whose text ends with
  `every registered guard is observable under its own neutralization`; the diagnostic
  names all four of `build-artifact-vacuous-confinement`, `rung4-tracked-hard-fail`,
  `hash-object-hard-fail`, and `find-object-hard-fail`, does **not** name
  `rung4-tracked-path-in-main`, whose Phase 1 fixture already separates it, **and names no
  id other than those four**; the bound matters because the accumulating helper reports
  every offending row in one run, so an unrelated fifth failing row would otherwise be
  recorded as expected output and carried past this gate unexamined; the artifact
  states which two of the four failed obligation 1 and which two failed obligation 5, using
  the split above; and the other two tests each report a line beginning `ok `, so the
  failure observed is a separation and scenario-availability failure and not an enumeration
  or registry-shape failure.

- [x] [P2-T11] Record the harness design in
  `evidence/other/guard-registry-design.2026-09-08T08-30.md`, stating the arithmetic
  guard-shaped regular expression verbatim, the eight named non-arithmetic guard sites and
  why the regex alone is under-inclusive for the property the gate is sold as enforcing,
  the (`id`, `mutation`) row identity and why lines 311 and 321 need it, the three row
  kinds as a **partition** of the outcome space of the two channel comparisons **for an
  admissible (`mutation`, `scenario`) pair** — one that survives the both-direction rule —
  each kind asserting both the difference and the identity it names, so that `EXEMPT` is an
  observed outcome rather than a written verdict, together with the reason the qualifier is
  needed: a form-2 row whose recorded constant is inert while its sibling separates lands in
  the records-identical, argv-identical cell and maps to no kind until it is rewritten to
  carry the separating constant. It must also state the six obligations from D3 of which the
  first four are kind-independent, the both-direction rule that an `EXEMPT` form-2 row must
  also be unobservable under the sibling constant and the free-direction defect that rule
  closes, the bounded scope of an `EXEMPT` claim — it is scenario-scoped, meaning
  unobservable under *that* scenario in both admissible directions and not under every
  scenario — and the eighteen pinned rows over seventeen distinct ids that carry the stronger
  property instead, of which three are keyed to a (`id`, `mutation`) pair because
  `hash-object-hard-fail` and `rung4-untracked-main-present` each back two rows on one marked
  line, together with the `s/((` prefix test that distinguishes an arithmetic row from a
  literal row without quoting either mutation,
  why the `sed` address is `$`-anchored and marker-addressed rather than pattern-only, why
  the observation channel is the full record stream plus exit status rather than the
  `DIRTSUM|` aggregate, and why the mutated source is evaluated from a shell variable
  rather than written to disk. It must additionally state the two constraints that keep an
  inert mutation out of the registry: that the `mutation` column of every row other than the
  eight named non-arithmetic rows must be exactly `s/((EXPR))/((0))/` or `s/((EXPR))/((1))/`
  with `EXPR` derived from the library by P2-T5's invariant 7, and that P2-T6's assertion 2
  requires the single
  changed line to still differ after the trailing `# guard:` comment is stripped and
  whitespace runs are collapsed in both versions. It must name the class each constraint
  closes: a comment-only or marker-only edit, and a whitespace-only reindent, each of which
  is a real source change that parses, leaves both channels identical, and would otherwise
  be written `EXEMPT`. Acceptance: the artifact contains the regular expression verbatim,
  names all three kinds, names all eight non-arithmetic guard ids, contains the two
  literals `s/((EXPR))/((0))/` and `s/((EXPR))/((1))/`, contains the literal
  `EXEMPT_SIBLING_DIFFERED`, contains the literal `EXEMPT is scenario-scoped`, lists all
  seventeen distinct pinned ids, states the pin total as eighteen rows, and names
  `hash-object-hard-fail` and `rung4-untracked-main-present` as the two ids that each back two
  registry rows and therefore carry pair-keyed pins.

---

### Phase 3 — The four separating fixtures

- [x] [P3-T1] Add `log.find-object.cccc2222.out` containing `ffff8888` to
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_history_read_error/`. Acceptance: the
  file exists with that single line, and
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  still exits 0 with 0 lines beginning `not ok`, proving the existing
  `dirt_history_read_error` verdict is unchanged while the guard is present.

- [x] [P3-T2] Add `hash-object.notes.md.out` containing `bbbb6666` and
  `rev-parse.main_notes.md.out` containing `bbbb6666` to
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_classifier_read_error/`. Both files are
  required: with only the first, the mutated run reaches rung 4's untracked half with no
  `main` blob and lands on `UNIQUE` by a second route, so the mutation would not be
  observable. Acceptance: both files exist with that single line each, and
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats`
  exits 0 with 0 lines beginning `not ok`, proving the `UNIQUE` verdict and the refused
  clear are unchanged while the guard is present.

- [x] [P3-T3] Create
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_probe_error_in_history/` with
  the six copied non-classifier files and the four classifier files tabulated in this
  plan's fixture section. Acceptance: `status._repo-wt_dirt.out` contains the single line
  ` M docs/tracked.md`, `diff-quiet..docs_tracked.md.rc` contains `128`,
  `hash-object.docs_tracked.md.out` contains `dddd4444`, and
  `log.find-object.dddd4444.out` contains `aaaa5555`.

- [x] [P3-T4] Create
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact_empty_diff/` with the
  six copied non-classifier files and the five classifier files tabulated in this plan's
  fixture section, including the two zero-byte diff payloads. Acceptance:
  `wc -c tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact_empty_diff/diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out`
  reports `0`, the cached counterpart also reports `0`,
  `diff-quiet..src_Legacy_Legacy.csproj.rc` contains `1`, and
  `hash-object.src_Legacy_Legacy.csproj.out` contains `bbbb3333`.

- [x] [P3-T5] Add two tests to `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`,
  titled
  `dirt_tracked_probe_error_in_history: a rung-4 hard read failure is UNIQUE even when the blob is in history`
  and
  `dirt_build_artifact_empty_diff: a csproj whose diff pair is empty is UNIQUE not a build artifact`.
  The first asserts `DIRTFILE|/repo-wt/dirt|UNIQUE|| M|docs/tracked.md`,
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and the absence of `CONTENT_IN_HISTORY`. The second
  asserts `DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj`,
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and the absence of `DISPOSABLE_BUILD_ARTIFACT`.
  Acceptance: both `@test` titles appear once in that file and the suite exits 0 with 0
  lines beginning `not ok`.

- [x] [P3-T6] Update the membership test in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats`: add
  `dirt_tracked_probe_error_in_history` and `dirt_build_artifact_empty_diff` to the
  explicit scenario list, change the asserted record literal from `32` to `34`, and update
  the explanatory comment so its stated scenario count is twenty-eight and its two-entry
  count is six. Acceptance:
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  exits 0 with 0 lines beginning `not ok`, and
  `find tests/fixtures/cleanup_worktrees/scenarios -maxdepth 1 -type d -name 'dirt_*' | wc -l`
  reports `28`.

- [x] [P3-T7] Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`
  and record `evidence/regression-testing/pass-after-guard-separation.2026-09-08T09-00.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, the plan line, and the `ok`/`not ok` counts.

  This task is also where the unexempted form of P2-T8's acceptance command 6 is run, now
  that P3-T3 and P3-T4 have created the two directories that command temporarily exempted.
  Run and record

  ```
  awk -F'\t' '!/^#/ {print $3}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort -u | while read -r s; do [ -d "tests/fixtures/cleanup_worktrees/scenarios/$s" ] || echo "MISSING $s"; done
  ```

  in the same artifact. Because this task may change a row's constant, it also re-runs
  P2-T8's acceptance command 7 and records it in the same artifact:

  ```
  awk -F'\t' '!/^#/ {print $1"\t"$5}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort | uniq -d
  ```

  This task is additionally the **only** point in the plan authorized to re-classify a
  registry row. P3-T1 and P3-T2 add payload files to `dirt_history_read_error` and
  `dirt_classifier_read_error`, and a row that P2-T8 classified against either of those
  scenarios may observe a different channel afterwards: a row recorded `EXEMPT` may begin
  separating, or a row recorded `SEPARATED` may stop. Where that happens, edit the row's
  `kind` and `reason` to match what the harness now observes.

  Two columns move here and one further move is permitted for a single, named reason. No
  row's `id` or `scenario` may be changed, so the enumeration is untouched. A row's
  `mutation` may be changed **only** by switching an arithmetic row between the two
  admissible constants `((0))` and `((1))` for its own marked line. That narrow permission
  is required by D3's both-direction rule and not by preference: when a Phase 3 payload
  makes a previously unobservable guard separate under the sibling constant, the row must
  become `SEPARATED` and `SEPARATED` asserts a difference for the constant the row actually
  records, so a row frozen on the inert constant could satisfy neither kind. The switch
  leaves P2-T5 invariant 7 satisfied, because both constants are derived from the same
  marked line, and it must leave the (`id`, `mutation`) pair unique, which P2-T8 acceptance
  command 7 re-checks. Every edit made here — of `kind`, of `reason`, or of the constant —
  is recorded in P3-T8's artifact with the row's id, its P2-T8 values, its new values, and
  the fixture addition that caused the change.

  Acceptance: `EXIT_CODE:` is `0`, the `not ok` count is `0`, the output contains a
  line beginning `ok ` whose text ends with
  `every registered guard is observable under its own neutralization`, and the recorded
  unexempted command 6 and the recorded command 7 each produced no output. This is the
  pass-after half of P2-T10 and the
  proof that all five remediated guards now change the record channel under neutralization.

- [x] [P3-T8] Record the per-guard separation evidence in
  `evidence/qa-gates/guard-separation-probe.2026-09-08T09-00.md`, giving for each of the
  **eighteen** pinned rows — the five remediated rows, the three R1/R2/R5 gate rows, the six
  added by the round-3 revision, and the four added by the round-4 revision — the scenario,
  the unmutated record channel, the mutated record channel, and the mutated `DIRTFILE|`
  verdict where the row produces one. The eighteen rows carry seventeen distinct ids, so the
  two `hash-object-hard-fail` rows are listed separately and distinguished by their
  `mutation`, exactly as P2-T9's table does.
  The same artifact carries a **re-classification section** listing every registry row whose
  `kind`, `reason`, or arithmetic constant P3-T7 changed relative to the value P2-T8
  recorded, giving the row's id, its P2-T8 values, its new values, and the Phase 3 fixture
  addition that caused the change.
  When no row changed, the section states `NO ROWS RE-CLASSIFIED` and names the two
  scenarios whose payloads were added — `dirt_history_read_error` and
  `dirt_classifier_read_error` — as the ones checked. Acceptance: the table has eighteen rows
  and all seventeen distinct pinned ids appear;
  for each of the five remediated ids the unmutated aggregate recorded is `HAS_UNIQUE` and
  the mutated aggregate recorded is `ALL_DISPOSABLE`; for each of the other thirteen rows the
  artifact quotes the specific record or argv line that differs, and for the
  `hash-object-hard-fail` literal row that quoted line is an **argv** line, because that row's
  record channel is byte-identical under its witness `dirt_staged_tree_worktree_delta`; the
  re-classification
  section is present, either listing changed rows with all four fields each or carrying the
  literal `NO ROWS RE-CLASSIFIED`; and

  ```
  grep -c 'PENDING-PHASE-3' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/qa-gates/guard-separation-probe.2026-09-08T09-00.md
  ```

  reports `0`. That token is P2-T9's placeholder for an observation that could not yet be
  made; this artifact is written after P3-T7 has run the gate clean, so any surviving
  occurrence would mean a post-Phase-3 observation cell was copied forward rather than
  observed.

---

### Phase 4 — Acceptance criteria and documentation

- [x] [P4-T1] Correct the stale count in AC-8 of
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`. AC-8 is
  the eighth checkbox of the `## Acceptance Criteria` section and its count phrase sits at
  `spec.md:714`, reading `by any of the ten \`dirt_*\` scenarios.`; the word `ten` becomes
  `twenty-eight`. The box stays checked; this is a text correction to a criterion the code
  already exceeds. Because the phrase sits in a rewrapped prose block, both acceptance
  searches run over an unwrapped stream:

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -cF 'twenty-eight `dirt_*` scenarios'
  ```

  Acceptance: that command reports `1`, and the same unwrapped stream piped to
  `grep -cF 'ten `dirt_*` scenarios'` reports `0`.

- [x] [P4-T2] Append AC-46 to the `## Acceptance Criteria` section of `spec.md` as an
  **unchecked** box: rung 4's tracked half resolves `CONTENT_ON_MAIN` only when the path
  is present in `main`; a `diff --quiet` exit 0 over a pathspec matching nothing in either
  tree advances the ladder rather than resolving a verdict, so an `AD` entry whose content
  exists only as a staged blob is `UNIQUE` and its worktree is `HAS_UNIQUE`; both
  directions are pinned by a single checked-in fixture carrying one `AD` entry and one
  tracked entry whose content is present in `main`. Acceptance:
  `grep -c '^- \[ \] AC-46 —' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `1`.

- [x] [P4-T3] Append AC-47 to the same section as an **unchecked** box. Its text must
  describe the set the gate actually enforces rather than a general property, in these
  terms: every line in `scripts/bash/cleanup_worktrees_dirt_lib.sh` that carries an
  arithmetic comparison of a variable against a numeric literal carries a `# guard:`
  marker; the marked lines plus the eight named non-arithmetic verdict guards — the
  diff-header skip, rung 1's Y-column gate, the empty-blob fail-closed test, rung 4's
  untracked main-blob equality test, rung 5's history-hit test, the ` -> ` payload split
  gate, the `UNIQUE` tally, and the clear's `ALL_DISPOSABLE` precondition, which are the
  sites that produced findings R1, R2, and R5 — are together registered in
  `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` under (`id`, `mutation`) row
  identity; every registered row's neutralization is a semantic one, being either one of
  the eight non-arithmetic mutations the remediation plan fixes by literal or the arithmetic
  guard's own comparison rewritten to a constant, so a mutation that edits only a comment or
  only whitespace is rejected by the suite rather than recorded as an exempt guard;
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` neutralizes each
  registered row in an in-memory copy of the library and requires, for every row, that the
  named scenario directory exists under a name beginning `dirt_`, that the substitution
  changed exactly one line and that the changed line still differs once the marker comment
  is stripped and whitespace runs are collapsed, that the mutated source parses, and that
  the unmutated `classify_worktree_dirt` call emitted at least one `DIRTFILE|` record;
  the three row kinds partition the outcome space of two comparisons for an admissible
  (`mutation`, `scenario`) pair — one that survives the sibling-constant requirement below —
  and each asserts both the difference and the identity it names, so a `SEPARATED` row's
  record stream and exit status must differ, an `ARGV` row's record stream must be identical
  while its argv log differs, and an `EXEMPT` row's record stream and argv log must both be
  identical — under the sibling constant as well, for a row whose mutation is an arithmetic
  constant — which makes `EXEMPT` an observed outcome rather than a verdict written into the
  registry; `EXEMPT is scenario-scoped`, meaning that an `EXEMPT` row establishes only that
  its guard is unobservable under its own named scenario in both admissible directions and
  does **not** establish that no checked-in scenario separates that guard, while the eighteen
  pinned registry rows carry the stronger property that a named checked-in scenario does
  separate them; eighteen registry rows over seventeen distinct ids are pinned by kind, the
  fourteen listed as `SEPARATED` in the remediation plan's remediated-guard and
  thirteen-pinned-guards tables being registered `SEPARATED`, and four rows — R1's Y-column
  gate, R2's payload-split gate, R5's diff-header skip, and the empty-blob fail-closed test —
  being registered `SEPARATED` or `ARGV`; the three pins that fall on the two library lines
  carrying an arithmetic guard and a named non-arithmetic guard together are keyed to the pair
  (`id`, `mutation`) rather than to `id`, because a single marker on such a line backs two
  registry rows and an id-keyed pin on it is discharged by either one; an arithmetic
  guard-shaped line with no marker, a marker with no registry row, or a registry row naming an
  unmarked id fails the suite.

  The scope clause is not decorative and its literal spelling is fixed. `spec.md` is the
  permanent artifact a future audit reads, and this cycle exists because two consecutive
  cycles shipped data-loss defects that passed the whole criterion set. A criterion that
  described the gate's assertions but omitted what they do not establish would repeat that
  failure mode at the level of the specification. The literal `EXEMPT is scenario-scoped`
  must appear in AC-47's text verbatim.

  Acceptance:
  `grep -c '^- \[ \] AC-47 —' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `1`; the unwrapped-stream search

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -cF 'EXEMPT is scenario-scoped'
  ```

  reports `1` — that literal occurs zero times in `spec.md` at the start of this cycle,
  re-derived against the current tree in this pass, so the assertion can fail; and the
  unwrapped-stream search

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -cF 'dirt-guard-registry.tsv'
  ```

  reports `1`.

- [x] [P4-T4] Reconcile the criterion count. The counts are **section-scoped** and the
  derivation is fixed here so the task does not choose one: `spec.md` carries eight
  checkboxes outside the `## Acceptance Criteria` section, at `:24`, `:25`, `:26`, `:27`,
  `:84`, `:595`, `:597`, and `:599`, so an unscoped `grep -c '^- \['` reports 53 before this
  phase and 55 after P4-T2 and P4-T3, neither of which is the figure this task records. Run

  ```
  awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['
  ```

  for the total, and the same `awk` prefix piped to `grep -c '^- \[x\]'` and to
  `grep -c '^- \[ \]'` for the checked and unchecked counts. Record
  `evidence/other/ac-count-reconciliation.2026-09-08T09-30.md` with `Timestamp:`, all three
  `Command:` values, `EXIT_CODE:`, the three counts, and a fourth field recording the
  unscoped `grep -c '^- \['` figure alongside a statement that it is not the criterion
  count and why. State that the two unchecked boxes are AC-46 and AC-47. These figures are
  checkbox counts and are unaffected by the guard arithmetic; the section began this cycle
  with 45 boxes, all checked, the last being AC-45 at `spec.md:848`. Acceptance: the
  artifact records a section-scoped total of `47`, a checked count of `45`, an unchecked
  count of `2`, and an unscoped figure of `55`.

- [x] [P4-T5] Add one sentence to the `DIRTFILE|` bullet of the Report Line Contract in
  `.claude/skills/cleanup-merged-worktrees/SKILL.md` — the bullet beginning at `:81` and
  ending at `:97` — stating that `CONTENT_ON_MAIN` is emitted for a tracked entry only when
  `main` contains the path, so an entry whose content exists only as a staged blob is
  reported `UNIQUE` rather than as content that is already on `main`. The bullet is a
  rewrapped prose block, so the acceptance search runs over an unwrapped stream rather than
  line-by-line:

  ```
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c 'only when `main` contains the path'
  ```

  Acceptance: that command reports `1`. A line-oriented search over the wrapped file would
  return 0 whenever the sentence happened to span two lines, whatever the executor wrote.

- [x] [P4-T6] Mirror the edited skill file to
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  and verify byte identity with `md5sum` over both paths. Record
  `evidence/qa-gates/skill-mirror-parity.2026-09-08T09-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and both digests. Acceptance: the two recorded digests are
  identical and the artifact states so explicitly.

- [ ] [P4-T7] Run `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  and record `evidence/qa-gates/pytest-push-down-contract.2026-09-08T09-30.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the passed count.
  Acceptance: `EXIT_CODE:` is `0` and the summary records `11 passed`.

---

### Phase 5 — Final QA loop, coverage, and reconciliation

- [ ] [P5-T1] Run `bash scripts/bash/shell-qc.sh format` and record
  `evidence/qa-gates/shell-qc-format.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, `Output Summary:` reproducing the combined stdout and stderr verbatim, and
  the same four observation fields defined in P0-T3 — `StatusBefore:`, `StatusAfter:`,
  `TreeDigestBefore:`, `TreeDigestAfter:` — computed with the identical commands, including
  the `discover_shell_scripts`-derived digest, and run from the same working directory
  P0-T3 used, the worktree root `.claude/worktrees/agent-ac72d35e7980bc69d`, for the reason
  stated there. Acceptance: `EXIT_CODE:` is `0`, all four fields are present, the two digest
  fields are non-empty, the two status fields reproduce their output verbatim and carry the
  literal `(empty)` when that output is empty, the artifact records the working directory
  used, and the artifact states whether the write-mode run rewrote any file and, if so,
  lists each rewritten path. If the two digests differ, the toolchain loop restarts from
  this task after the rewrite is reviewed.

- [x] [P5-T2] Run `bash scripts/bash/shell-qc.sh check` and record
  `evidence/qa-gates/shell-qc-check.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, and `Output Summary:` reproducing the command's combined stdout and stderr
  verbatim. No findings count is asserted, for the reason stated in P0-T4. Acceptance:
  `EXIT_CODE:` is `0` and the artifact states that the combined output was empty, quoting
  it verbatim.

- [x] [P5-T3] Run the full local test stage as
  `env SHELL_QC_BATS_BIN=<resolved path> bash scripts/bash/shell-qc.sh test` and record
  `evidence/qa-gates/shell-qc-test.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, the TAP plan line, the `ok` count, the `not ok` count, and a field
  `PostChangeLocalTestTotal:`. This plan adds exactly seven tests and removes none: two in
  P1-T3 and P1-T4, three in P2-T5 through P2-T7, and two in P3-T5. Acceptance: `EXIT_CODE:`
  is `0`, the `not ok` count is `0`, and `PostChangeLocalTestTotal:` equals
  `BaselineLocalTestTotal:` from P0-T5 plus exactly `7`. The artifact enumerates the seven
  added `@test` titles so the delta is attributable rather than merely arithmetic.

- [x] [P5-T4] Confirm the file-size limit with
  `wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  and record `evidence/qa-gates/file-size-limit.2026-09-08T10-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and the per-file counts with the headroom to 500 for each.
  Acceptance: every recorded count is at or under `500`, and the artifact states the
  classifier library's count and the number of lines it grew relative to the `463`
  recorded in P0-T8.

- [x] [P5-T5] Confirm report mode is still non-mutating after the new probe was added.
  Run `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_clear.bats`
  and record `evidence/qa-gates/report-mode-non-mutating.2026-09-08T10-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the `ok`/`not ok` counts, an explicit statement
  that the subcommand added by P1-T6 is `rev-parse`, which reads and does not write, and
  the field `StubDigest:` recomputed as the `md5sum` of
  `tests/fixtures/cleanup_worktrees/stub-bin/git`. Acceptance: `EXIT_CODE:` is `0`, the
  `not ok` count is `0`, and the recomputed `StubDigest:` equals the value P0-T8 recorded,
  which is what shows this cycle added no arm to the stub. The comparison is made against
  the cycle-start digest rather than against the epic base, because cycle 1 legitimately
  changed the stub and a base-anchored diff would report those changes as this cycle's.

- [ ] [P5-T6] Stage the cycle-2 changes with `git add -A`, commit them, and push the
  branch. Record `evidence/other/remediation-commit-and-push.2026-09-08T10-00.md` with
  `Timestamp:`, the commands, `EXIT_CODE:` for each, the branch name, the
  `git status --porcelain` output taken immediately after `git add -A` and before the
  commit, and the list of changed paths obtained from
  `git diff --name-only origin/epic/cleanup-merged-worktrees-hardening-integration`
  after the commit. The staged-status span is recorded because an anchored name-listing
  diff enumerates tracked changes only and would not show the fixture directories this
  cycle creates until they are staged. Acceptance: the push command's `EXIT_CODE:` is `0`
  and the recorded path list contains `scripts/bash/cleanup_worktrees_dirt_lib.sh`,
  `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`, and
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`.

- [ ] [P5-T7] Dispatch the coverage workflow against the pushed branch with
  `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`,
  wait for the run to conclude, and record
  `evidence/qa-gates/shell-coverage-dispatch.2026-09-08T10-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the run id, the run conclusion, the run's head SHA, and the
  TAP figures from the run log. The workflow accepts `workflow_dispatch`
  (`.github/workflows/_shell-coverage.yml:5`). Acceptance: the recorded conclusion is
  `success`, the recorded `not ok` count is `0`, and the recorded head SHA equals the
  commit P5-T6 pushed, recorded as an observation rather than asserted against a literal
  written into this plan.

- [ ] [P5-T8] Download that run's merged Cobertura artifact and read the figures directly
  from `kcov-merged/cov.xml`. Record
  `evidence/qa-gates/dirt-lib-coverage.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, `PostChangeRepoLineCoverage:`, `PostChangeDirtLibLineCoverage:`,
  `Threshold: 85.0`, and the covered-over-total line pair for
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`. Acceptance: both percentage fields are
  numbers, both are at or above `85.0`, and the artifact states that kcov measures no
  branch coverage so no branch gate applies to bash.

- [ ] [P5-T9] Compare against the P0-T6 baseline and record
  `evidence/qa-gates/coverage-delta.2026-09-08T10-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, `BaselineRepoLineCoverage:`, `PostChangeRepoLineCoverage:`,
  `BaselineDirtLibLineCoverage:`, `PostChangeDirtLibLineCoverage:`, a per-file table
  covering the eight files matching `scripts/bash/cleanup[-_]worktrees*` — the same eight
  named in P0-T6 — with a "fell below baseline" column, and a changed-lines section naming
  the region P1-T6 added and the test that executes it. Acceptance: the table has exactly
  eight rows and names all eight files; no file's post-change percentage is below its
  baseline percentage; and the changed-lines section names
  `dirt_tracked_staged_only_blob` as the fixture that executes the new guard in both
  directions.

- [ ] [P5-T10] Check off AC-46 and AC-47 in `spec.md` and record
  `evidence/other/ac-checkoff.2026-09-08T10-00.md` with `Timestamp:`, the evidence artifact
  path supporting each of the two criteria, the total checkbox count inside the
  `## Acceptance Criteria` section, and the checked count. Both counts use the same
  section-scoped derivation P4-T4 fixes:

  ```
  awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['
  ```

  for the total and the same `awk` prefix piped to `grep -c '^- \[x\]'` for the checked
  count. An unscoped count is not the criterion count, because eight checkboxes sit outside
  the section. Acceptance: the artifact records a section-scoped total of `47` and a
  section-scoped checked count of `47`, and
  `grep -c '^- \[ \] AC-4' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports `0`.

- [ ] [P5-T11] Run `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  **in this task**, after the Phase 5 formatter and linter have run, and record the
  single-consecutive-pass declaration in
  `evidence/qa-gates/single-consecutive-pass.2026-09-08T10-00.md`. The artifact lists the
  four local stages in executed order — format (P5-T1), lint (P5-T2), test (P5-T3),
  contract (this task) — with each stage's artifact path and exit code, and records this
  task's own `Command:`, `EXIT_CODE:`, and `11 passed` for the contract stage. The contract
  run is repeated here rather than cited from P4-T7 because P4-T7 executes before Phase 4's
  own edits are formatted by P5-T1, so a citation of P4-T7 would describe a tree state that
  the format stage may have changed and the four stages would not have run consecutively.
  Acceptance: all four stages are listed with exit code `0`; the contract stage's recorded
  output is `11 passed` and its `Command:` names this task's own invocation rather than
  P4-T7's artifact; and the artifact names the coverage stage as CI-measured with its run
  id rather than claiming a local run.

- [ ] [P5-T12] Write the cycle-2 closing summary at
  `evidence/other/cycle2-closure.2026-09-08T10-00.md`, stating for each of N1, N2's four
  sites, the systemic gate, and O1 the change made, the test that holds it, and the
  evidence artifact. Then stage and commit the documentation and evidence written after
  P5-T6 — the spec check-off from P5-T10, the coverage artifacts from P5-T7 through P5-T9,
  the declaration from P5-T11, this summary, **and this plan file with its check-offs
  through P5-T11** — and push, so the branch tip carries the
  complete cycle rather than only its code half. The plan file is enumerated explicitly
  because it lives inside the feature folder this task's clean-status acceptance inspects
  and it acquires check-offs for P5-T7 through P5-T11 after P5-T6's commit, so a commit that
  omitted it would leave the folder dirty and make the acceptance below unsatisfiable.
  Acceptance: the artifact names all seven
  items and, for each of the eighteen pinned guard rows, names the registry row that now
  separates it — the two `hash-object-hard-fail` rows listed separately and distinguished by
  their `mutation`, and the literal row named as separating on the argv channel; and after
  the push,
  `git status --porcelain docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632`
  produces no output, which is the observation that no evidence file was left uncommitted.
  That observation is taken **before** this task's own checkbox in this plan file is
  checked. This plan file lives under the same feature folder, so checking its final box
  before running the command would dirty the very path the command inspects and make the
  condition unsatisfiable. The final check-off commit that follows is the orchestrator's to
  make and is outside this plan's own acceptance.

---

## Evidence index

| Kind | Path |
|---|---|
| Baseline | `evidence/remediation-baseline/*.2026-09-08T07-30.md` |
| Regression testing | `evidence/regression-testing/*.2026-09-08T08-00.md`, `*.2026-09-08T08-30.md`, `*.2026-09-08T09-00.md` |
| QA gates | `evidence/qa-gates/*.2026-09-08T08-30.md`, `*.2026-09-08T09-00.md`, `*.2026-09-08T09-30.md`, `*.2026-09-08T10-00.md` |
| Other | `evidence/other/guard-registry-design.2026-09-08T08-30.md`, `evidence/other/ac-count-reconciliation.2026-09-08T09-30.md`, `evidence/other/remediation-commit-and-push.2026-09-08T10-00.md`, `evidence/other/ac-checkoff.2026-09-08T10-00.md`, `evidence/other/cycle2-closure.2026-09-08T10-00.md` |

Task-to-artifact map for the two artifacts whose phase moved during authoring:
`evidence/qa-gates/guard-registry-classification.2026-09-08T08-30.md` is written by P2-T9,
and there is no separate Phase 4 gate re-run artifact: the completed registry's clean gate
run is recorded by P3-T7 and again by the full local test stage at P5-T3.

All evidence paths in this plan resolve under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`.
No `artifacts/` sub-path is used for evidence.
