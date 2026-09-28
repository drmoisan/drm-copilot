# Per-guard separation probe — the eighteen pinned rows — [P3-T8]

Timestamp: 2026-09-08T09-00
Task: [P3-T8]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d
Gate run this artifact reports on:
`evidence/regression-testing/pass-after-guard-separation.2026-09-08T09-00.md` (EXIT_CODE 0,
3 ok, 0 not ok)

The eighteen pinned rows carry **seventeen distinct ids**, because `hash-object-hard-fail`
backs two registry rows on one marked line. The two are listed separately below and are
distinguished by their `mutation`, exactly as the [P2-T9] table does.

Every observation below was taken with the worktree argument fixed at the literal
`/repo-wt/dirt`. The record channel is stdout of `classify_worktree_dirt`, that call's exit
status (`CLASSIFY_RC=`), stdout of `clear_disposable_dirt`, and that call's exit status
(`CLEAR_RC=`). The stub's `stub-git: <argv>` log is captured separately.

## The eighteen rows

The `mutation` column is abbreviated to the row discriminator, because the full values are
recorded in the registry and in the [P2-T9] table. `arith` marks a row whose mutation begins
`s/((`; `literal` marks a row carrying one of the eight fixed non-arithmetic literals. In the
observation columns a literal `|` is written `\|` for Markdown table escaping.

| # | id | row | scenario | unmutated | mutated | mutated `DIRTFILE\|` verdict |
|--:|---|---|---|---|---|---|
| 1 | `build-artifact-vacuous-confinement` | arith | `dirt_build_artifact_empty_diff` | `HAS_UNIQUE`, clear `REFUSED-UNIQUE` exit 1 | `ALL_DISPOSABLE`, clear `OK` exit 0 | `DISPOSABLE_BUILD_ARTIFACT` |
| 2 | `rung4-tracked-path-in-main` | arith | `dirt_tracked_staged_only_blob` | `HAS_UNIQUE`, clear `REFUSED-UNIQUE` exit 1 | `ALL_DISPOSABLE`, clear `OK` exit 0 | `CONTENT_ON_MAIN` |
| 3 | `rung4-tracked-hard-fail` | arith | `dirt_tracked_probe_error_in_history` | `HAS_UNIQUE`, clear `REFUSED-UNIQUE` exit 1 | `ALL_DISPOSABLE`, clear `OK` exit 0 | `CONTENT_IN_HISTORY` |
| 4 | `hash-object-hard-fail` | arith | `dirt_classifier_read_error` | `HAS_UNIQUE`, clear `REFUSED-UNIQUE` exit 1 | `ALL_DISPOSABLE`, clear `OK` exit 0 | `CONTENT_ON_MAIN` |
| 5 | `find-object-hard-fail` | arith | `dirt_history_read_error` | `HAS_UNIQUE`, clear `REFUSED-UNIQUE` exit 1 | `ALL_DISPOSABLE`, clear `OK` exit 0 | `CONTENT_IN_HISTORY` |
| 6 | `status-read-hard-fail` | arith | `dirt_unique` | one `DIRTFILE\|` and one `DIRTSUM\|`, exit 0 | no record at all, exit 0 | none produced |
| 7 | `clear-reset-hard-fail` | arith | `dirt_clear_reset_failed` | clear `FAILED` exit 1 | clear `OK` exit 0 | `DISPOSABLE_BUILD_ARTIFACT`, unchanged |
| 8 | `clear-clean-hard-fail` | arith | `dirt_clear_clean_failed` | clear `FAILED` exit 1 | clear `OK` exit 0 | `DISPOSABLE_BUILD_ARTIFACT`, unchanged |
| 9 | `clear-requires-all-disposable` | literal | `dirt_unique` | clear `REFUSED-UNIQUE` exit 1 | clear `OK` exit 0 | `UNIQUE`, unchanged |
| 10 | `unique-verdict-tally` | literal | `dirt_unique` | `DIRTSUM\|/repo-wt/dirt\|HAS_UNIQUE\|` | `DIRTSUM\|/repo-wt/dirt\|ALL_DISPOSABLE\|` | `UNIQUE`, unchanged |
| 11 | `history-hit-nonempty` | literal | `dirt_content_in_history` | `CONTENT_IN_HISTORY\|ffff8888` | `UNIQUE` with an empty detail | `UNIQUE` |
| 12 | `diff-header-skip` | literal | `dirt_build_artifact` | `DISPOSABLE_BUILD_ARTIFACT` | `CONTENT_ON_MAIN` | `CONTENT_ON_MAIN` |
| 13 | `rung1-y-column-gate` | literal | `dirt_staged_tree_worktree_delta` | the `MM` entry is `UNIQUE` | the `MM` entry is `STAGED_TREE_IS_COMMIT` | `STAGED_TREE_IS_COMMIT` |
| 14 | `rename-payload-split-gate` | literal | `dirt_rename_split` | the `??` entry's path is `notes -> draft.md` | that path is `draft.md` | `CONTENT_ON_MAIN` |
| 15 | `rung4-tracked-gate` | arith | `dirt_tracked_staged_only_blob` | the `M ` entry is `CONTENT_ON_MAIN` | that entry is `UNIQUE` | `UNIQUE` |
| 16 | `rung4-tracked-content-equal` | arith | `dirt_tracked_staged_only_blob` | the `M ` entry is `CONTENT_ON_MAIN` | that entry is `UNIQUE` | `UNIQUE` |
| 17 | `rung4-untracked-main-present` | literal | `dirt_rename_split` | the `??` entry is `UNIQUE`, aggregate `HAS_UNIQUE` | that entry is `CONTENT_ON_MAIN`, aggregate `ALL_DISPOSABLE` | `CONTENT_ON_MAIN` |
| 18 | `hash-object-hard-fail` | literal | `dirt_staged_tree_worktree_delta` | record channel; argv log without the rung-5 walk | record channel **byte-identical**; argv log gains the rung-5 walk | `UNIQUE`, unchanged |

## The five remediated guards: full record channels

Every one of the five turns a refusal to clear into a clear. The unmutated aggregate is
`HAS_UNIQUE` and the mutated aggregate is `ALL_DISPOSABLE` in all five cases.

### 1. `build-artifact-vacuous-confinement`, `s/((total == 0))/((0))/`, `dirt_build_artifact_empty_diff`

```
unmutated                                                        mutated
DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj        DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT|| M|src/Legacy/Legacy.csproj
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|                                 DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
CLASSIFY_RC=0                                                     CLASSIFY_RC=0
ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE                    ACTION|dirt-clear|/repo-wt/dirt|OK
CLEAR_RC=1                                                        CLEAR_RC=0
```

### 2. `rung4-tracked-path-in-main`, `s/((erc == 0))/((1))/`, `dirt_tracked_staged_only_blob`

```
unmutated                                                        mutated
DIRTFILE|/repo-wt/dirt|UNIQUE||AD|staged_only.md                  DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||AD|staged_only.md
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md        DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|                                 DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
CLASSIFY_RC=0                                                     CLASSIFY_RC=0
ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE                    ACTION|dirt-clear|/repo-wt/dirt|OK
CLEAR_RC=1                                                        CLEAR_RC=0
```

This is the N1 data-loss path stated as a mutation: the `AD` entry's content exists only as a
staged blob, and with the guard neutralized the worktree is authorized for `--clear-disposable`.

### 3. `rung4-tracked-hard-fail`, `s/((drc > 1))/((0))/`, `dirt_tracked_probe_error_in_history`

```
unmutated                                                        mutated
DIRTFILE|/repo-wt/dirt|UNIQUE|| M|docs/tracked.md                 DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|aaaa5555| M|docs/tracked.md
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|                                 DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|aaaa5555
CLASSIFY_RC=0                                                     CLASSIFY_RC=0
ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE                    ACTION|dirt-clear|/repo-wt/dirt|OK
CLEAR_RC=1                                                        CLEAR_RC=0
```

### 4. `hash-object-hard-fail` arithmetic row, `s/((hrc != 0))/((0))/`, `dirt_classifier_read_error`

```
unmutated                                                        mutated
DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes.md                        DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|notes.md
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|                                 DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
CLASSIFY_RC=0                                                     CLASSIFY_RC=0
ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE                    ACTION|dirt-clear|/repo-wt/dirt|OK
CLEAR_RC=1                                                        CLEAR_RC=0
```

### 5. `find-object-hard-fail`, `s/((lrc != 0))/((0))/`, `dirt_history_read_error`

```
unmutated                                                        mutated
DIRTFILE|/repo-wt/dirt|UNIQUE||??|docs/old.md                     DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|ffff8888|??|docs/old.md
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|                                 DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff8888
CLASSIFY_RC=0                                                     CLASSIFY_RC=0
ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE                    ACTION|dirt-clear|/repo-wt/dirt|OK
CLEAR_RC=1                                                        CLEAR_RC=0
```

## The other thirteen rows: the specific line that differs

Each entry quotes the one record line, or the one argv line, that differs.

**6. `status-read-hard-fail`**, `s/((srrc != 0))/((1))/`, `dirt_unique`. The unmutated run
emits two records that the mutated run does not emit at all:

```
DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes.md
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

The mutated `classify_worktree_dirt` returns 0 having emitted nothing, which is the shape a
downstream caller is least able to distinguish from a clean worktree.

**7. `clear-reset-hard-fail`**, `s/((rrc != 0))/((0))/`, `dirt_clear_reset_failed`:

```
ACTION|dirt-clear|/repo-wt/dirt|FAILED     becomes     ACTION|dirt-clear|/repo-wt/dirt|OK
```

with `CLEAR_RC` going from 1 to 0.

**8. `clear-clean-hard-fail`**, `s/((clrc != 0))/((0))/`, `dirt_clear_clean_failed`:

```
ACTION|dirt-clear|/repo-wt/dirt|FAILED     becomes     ACTION|dirt-clear|/repo-wt/dirt|OK
```

with `CLEAR_RC` going from 1 to 0. This is the row whose separation depends on the widened
observation channel: the `DIRTSUM|` aggregate is `ALL_DISPOSABLE` in both runs and the argv log
is identical in both, because 475 is the last guard in the sequence and no further git call
follows it. `ARGVDIFF` was observed `no` for this row and `yes` for its sibling
`clear-reset-hard-fail`, which is the contrast that makes the widening load-bearing.

**9. `clear-requires-all-disposable`**, literal, `dirt_unique`:

```
ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE     becomes     ACTION|dirt-clear|/repo-wt/dirt|OK
```

**10. `unique-verdict-tally`**, literal, `dirt_unique`:

```
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|     becomes     DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
```

**11. `history-hit-nonempty`**, literal, `dirt_content_in_history`:

```
DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|ffff8888|??|docs/old.md     becomes     DIRTFILE|/repo-wt/dirt|UNIQUE||??|docs/old.md
```

**12. `diff-header-skip`**, literal, `dirt_build_artifact`:

```
DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT|| M|src/Legacy/Legacy.csproj     becomes     DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN|| M|src/Legacy/Legacy.csproj
```

**13. `rung1-y-column-gate`**, literal, `dirt_staged_tree_worktree_delta`:

```
DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs     becomes     DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|MM|src/a.cs
```

**14. `rename-payload-split-gate`**, literal, `dirt_rename_split`:

```
DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes -> draft.md     becomes     DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|draft.md
```

The path field is truncated, which is the R2 defect stated as a mutation.

**15. `rung4-tracked-gate`**, `s/((untracked == 0))/((0))/`, `dirt_tracked_staged_only_blob`:

```
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md     becomes     DIRTFILE|/repo-wt/dirt|UNIQUE||M |docs/tracked.md
```

The `DIRTSUM|` aggregate is `HAS_UNIQUE` in both runs, because the scenario's first entry
`AD staged_only.md` is `UNIQUE` either way. The separation is carried entirely by the per-entry
record, which is the second case the widened observation channel is required for.

**16. `rung4-tracked-content-equal`**, `s/((drc == 0))/((0))/`, `dirt_tracked_staged_only_blob`:

```
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md     becomes     DIRTFILE|/repo-wt/dirt|UNIQUE||M |docs/tracked.md
```

Same aggregate-invariant shape as row 15.

**17. `rung4-untracked-main-present` literal row**, `dirt_rename_split`:

```
DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes -> draft.md     becomes     DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|notes -> draft.md
```

with the aggregate going `HAS_UNIQUE` to `ALL_DISPOSABLE` and the clear going
`REFUSED-UNIQUE` exit 1 to `OK` exit 0. This is a fail-open flip on the sole route by which an
untracked entry can be called `CONTENT_ON_MAIN`.

**18. `hash-object-hard-fail` literal row**, `dirt_staged_tree_worktree_delta`. This row's
record channel is **byte-identical** between the two runs — the `MM src/a.cs` entry is `UNIQUE`
either way, decided at rung 6 rather than at this guard — so the line quoted here is an **argv**
line, which the mutated run's log gains and the unmutated run's log does not contain:

```
stub-git: --no-optional-locks -C /repo-wt/dirt log main~1000..main --find-object= --format=%H --max-count=1
```

The invocation appears once per `classify_worktree_dirt` call, so twice across the two-call
channel, since `clear_disposable_dirt` re-runs the classifier. The empty `--find-object=`
argument is the observable consequence of letting the ladder proceed past a failed content read
with an empty object id. The rung-5 bounded-range `rev-parse --verify --quiet main~1000` probe
does **not** appear in either log, because it is redirected `>/dev/null 2>&1` and the stub
writes its log to stderr; one added argv line, not two, is what makes the two logs differ.

## Re-classification section

**NO ROWS RE-CLASSIFIED.**

[P3-T7] is the only point in the plan authorized to change a registry row's `kind`, `reason`,
or arithmetic constant. It changed none. The gate passed on the first run after the Phase 3
fixtures were added.

The two scenarios whose payloads Phase 3 added, and whose rows were therefore the ones checked
for a changed observation, are:

- **`dirt_history_read_error`** — [P3-T1] added `log.find-object.cccc2222.out` containing
  `ffff8888`. One registry row names this scenario: `find-object-hard-fail`. It was recorded
  `SEPARATED` by [P2-T8] and the harness now observes it separating, so no edit was required.
- **`dirt_classifier_read_error`** — [P3-T2] added `hash-object.notes.md.out` and
  `rev-parse.main_notes.md.out`, both containing `bbbb6666`. One registry row names this
  scenario: `hash-object-hard-fail`'s arithmetic row. It was recorded `SEPARATED` by [P2-T8] and
  the harness now observes it separating, so no edit was required.

No row's `id` or `scenario` was changed at any point, so the enumeration is untouched, and
[P2-T8] acceptance command 7 re-run in [P3-T7] confirms (`id`, `mutation`) row identity still
holds across all 39 rows.

## Registry composition at the end of Phase 3

37 `SEPARATED`, 2 `ARGV`, 0 `EXEMPT`, over 39 rows and 37 distinct marker ids — unchanged from
the [P2-T8] classification, which is the direct consequence of no row having been
re-classified.
