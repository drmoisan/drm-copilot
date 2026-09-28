# Guard registry classification — all 39 rows — [P2-T9]

Timestamp: 2026-09-08T08-30
Task: [P2-T8] observation, recorded by [P2-T9]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d
Registry: `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
Library: `scripts/bash/cleanup_worktrees_dirt_lib.sh` (481 lines, 31 arithmetic guard-shaped
lines, 37 `# guard:` markers)

Observation channel, per D3 of the remediation plan: stdout of `classify_worktree_dirt`, that
call's exit status, stdout of `clear_disposable_dirt`, that call's exit status, with the
stub's `stub-git: <argv>` log captured separately on stderr. The worktree argument is the
literal `/repo-wt/dirt` for every row.

Markdown table escaping: a literal `|` inside a table cell is written `\|`. Every `\|` below
is display escaping for one pipe character. The `\[` and `\]` sequences inside a `mutation`
cell are genuine `sed` escapes and are byte-for-byte what the registry holds.

## Row counts

| Kind | Rows |
|---|---:|
| `SEPARATED` | 37 |
| `ARGV` | 2 |
| `EXEMPT` | 0 |
| **Total** | **39** |

37 + 2 + 0 = 39, which is the row count `grep -vc '^#'` reports for the registry.

**37 distinct marker ids back the 39 rows.** Two ids back two rows each, because the library
line they mark carries an arithmetic guard and a named non-arithmetic guard on one physical
line: `hash-object-hard-fail` at line 329 (`if ((hrc != 0)) || [[ -z $blob ]]; then`) and
`rung4-untracked-main-present` at line 339
(`if ((mrc == 0)) && [[ -n $mainblob && $mainblob == "$blob" ]]; then`). Each of those two
ids appears twice in the table below and the two rows are distinguished by their `mutation`,
which is row identity per D2 part three. The remaining 35 ids back one row each:
35 + 2 + 2 = 39.

## The 39 rows

| id | marker line | mutation | kind | scenario | observed difference |
|---|---:|---|---|---|---|
| `build-artifact-vacuous-confinement` | 223 | `s/((total == 0))/((0))/` | SEPARATED | `dirt_build_artifact_empty_diff` | PENDING-PHASE-3 |
| `rung4-tracked-path-in-main` | 314 | `s/((erc == 0))/((1))/` | SEPARATED | `dirt_tracked_staged_only_blob` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|AD\|staged_only.md` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|AD\|staged_only.md`; aggregate `HAS_UNIQUE` becomes `ALL_DISPOSABLE` and the clear goes from `REFUSED-UNIQUE` exit 1 to `OK` exit 0 |
| `rung4-tracked-hard-fail` | 319 | `s/((drc > 1))/((0))/` | SEPARATED | `dirt_tracked_probe_error_in_history` | PENDING-PHASE-3 |
| `hash-object-hard-fail` | 329 | `s/((hrc != 0))/((0))/` | SEPARATED | `dirt_classifier_read_error` | PENDING-PHASE-3 |
| `find-object-hard-fail` | 354 | `s/((lrc != 0))/((0))/` | SEPARATED | `dirt_history_read_error` | PENDING-PHASE-3 |
| `staged-probe-revlist-hard-fail` | 107 | `s/((rc != 0))/((0))/` | SEPARATED | `dirt_staged_probe_revlist_error` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|M \|src/a.cs` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|M \|src/a.cs` |
| `staged-probe-skip-head` | 112 | `s/((first == 1))/((1))/` | SEPARATED | `dirt_staged_tree_is_commit` | `DIRTFILE\|/repo-wt/dirt\|STAGED_TREE_IS_COMMIT\|eeee7777\|M \|src/a.cs` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|M \|src/a.cs` |
| `staged-probe-tree-match` | 119 | `s/((drc == 0))/((1))/` | SEPARATED | `dirt_staged_tree_no_match` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|M \|src/a.cs` becomes `DIRTFILE\|/repo-wt/dirt\|STAGED_TREE_IS_COMMIT\|eeee7777\|M \|src/a.cs` |
| `staged-probe-diffindex-hard-fail` | 123 | `s/((drc > 1))/((0))/` | SEPARATED | `dirt_staged_probe_diffindex_error` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|M \|src/a.cs` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|M \|src/a.cs` |
| `hintpath-diff-read-hard-fail` | 177 | `s/((rc != 0))/((0))/` | SEPARATED | `dirt_tracked_read_errors` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\| M\|src/Legacy/Legacy.csproj` |
| `build-artifact-worktree-diff-hard-fail` | 217 | `s/((wrc == 2))/((0))/` | SEPARATED | `dirt_tracked_read_errors` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\| M\|src/Legacy/Legacy.csproj` |
| `build-artifact-worktree-diff-unconfined` | 218 | `s/((wrc == 1))/((0))/` | SEPARATED | `dirt_build_artifact_mixed` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|DISPOSABLE_BUILD_ARTIFACT\|\| M\|src/Legacy/Legacy.csproj` |
| `build-artifact-cached-diff-hard-fail` | 220 | `s/((crc == 2))/((1))/` | SEPARATED | `dirt_build_artifact` | `DIRTFILE\|/repo-wt/dirt\|DISPOSABLE_BUILD_ARTIFACT\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\| M\|src/Legacy/Legacy.csproj` |
| `build-artifact-cached-diff-unconfined` | 221 | `s/((crc == 1))/((1))/` | SEPARATED | `dirt_build_artifact` | `DIRTFILE\|/repo-wt/dirt\|DISPOSABLE_BUILD_ARTIFACT\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\| M\|src/Legacy/Legacy.csproj` |
| `rung3-tracked-only-gate` | 290 | `s/((untracked == 0))/((0))/` | SEPARATED | `dirt_build_artifact` | `DIRTFILE\|/repo-wt/dirt\|DISPOSABLE_BUILD_ARTIFACT\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\| M\|src/Legacy/Legacy.csproj` |
| `rung3-build-artifact-match` | 292 | `s/((brc == 0))/((0))/` | SEPARATED | `dirt_build_artifact` | `DIRTFILE\|/repo-wt/dirt\|DISPOSABLE_BUILD_ARTIFACT\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\| M\|src/Legacy/Legacy.csproj` |
| `rung3-build-artifact-hard-fail` | 296 | `s/((brc > 1))/((0))/` | SEPARATED | `dirt_tracked_read_errors` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\| M\|src/Legacy/Legacy.csproj` |
| `rung4-tracked-gate` | 304 | `s/((untracked == 0))/((0))/` | SEPARATED | `dirt_tracked_staged_only_blob` | `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|M \|docs/tracked.md` becomes `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|M \|docs/tracked.md` |
| `rung4-tracked-content-equal` | 307 | `s/((drc == 0))/((0))/` | SEPARATED | `dirt_tracked_staged_only_blob` | `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|M \|docs/tracked.md` becomes `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|M \|docs/tracked.md` |
| `rung4-untracked-gate` | 336 | `s/((untracked == 1))/((0))/` | SEPARATED | `dirt_content_on_main` | `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|??\|docs/copy.md` becomes `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|??\|docs/copy.md` |
| `rung4-untracked-main-present` | 339 | `s/((mrc == 0))/((0))/` | SEPARATED | `dirt_content_on_main` | `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|??\|docs/copy.md` becomes `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|??\|docs/copy.md` |
| `history-scan-bounded-range` | 351 | `s/((vrc == 0))/((0))/` | ARGV | `dirt_unique` | records byte-identical; the argv log's `log main~1000..main --find-object=9999aaaa --format=%H --max-count=1` becomes `log main --find-object=9999aaaa --format=%H --max-count=1` |
| `status-read-hard-fail` | 389 | `s/((srrc != 0))/((1))/` | SEPARATED | `dirt_unique` | the unmutated run emits `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|??\|notes.md` and `DIRTSUM\|/repo-wt/dirt\|HAS_UNIQUE\|`; the mutated run emits no record at all and still returns 0 |
| `staged-probe-issue-gate` | 403 | `s/((any_staged == 1))/((0))/` | SEPARATED | `dirt_staged_tree_is_commit` | `DIRTFILE\|/repo-wt/dirt\|STAGED_TREE_IS_COMMIT\|eeee7777\|M \|src/a.cs` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|M \|src/a.cs` |
| `staged-probe-no-match` | 405 | `s/((prc == 1))/((1))/` | SEPARATED | `dirt_staged_tree_is_commit` | `DIRTFILE\|/repo-wt/dirt\|STAGED_TREE_IS_COMMIT\|eeee7777\|M \|src/a.cs` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|M \|src/a.cs` |
| `staged-probe-error-map` | 406 | `s/((prc > 1))/((1))/` | SEPARATED | `dirt_staged_tree_is_commit` | `DIRTFILE\|/repo-wt/dirt\|STAGED_TREE_IS_COMMIT\|eeee7777\|M \|src/a.cs` becomes `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|M \|src/a.cs` |
| `aggregate-empty-entry-set` | 432 | `s/((entry_count == 0))/((1))/` | SEPARATED | `dirt_unique` | the `DIRTSUM\|/repo-wt/dirt\|HAS_UNIQUE\|` aggregate disappears from the record stream; the `DIRTFILE\|` record remains |
| `aggregate-all-disposable-gate` | 433 | `s/((unique_count == 0))/((1))/` | SEPARATED | `dirt_unique` | `DIRTSUM\|/repo-wt/dirt\|HAS_UNIQUE\|` becomes `DIRTSUM\|/repo-wt/dirt\|ALL_DISPOSABLE\|` |
| `clear-classify-exit-gate` | 462 | `s/((crc == 0))/((0))/` | SEPARATED | `dirt_clear_all_disposable` | `ACTION\|dirt-clear\|/repo-wt/dirt\|OK` becomes `ACTION\|dirt-clear\|/repo-wt/dirt\|REFUSED-UNIQUE` |
| `clear-reset-hard-fail` | 470 | `s/((rrc != 0))/((0))/` | SEPARATED | `dirt_clear_reset_failed` | `ACTION\|dirt-clear\|/repo-wt/dirt\|FAILED` becomes `ACTION\|dirt-clear\|/repo-wt/dirt\|OK` |
| `clear-clean-hard-fail` | 475 | `s/((clrc != 0))/((0))/` | SEPARATED | `dirt_clear_clean_failed` | `ACTION\|dirt-clear\|/repo-wt/dirt\|FAILED` becomes `ACTION\|dirt-clear\|/repo-wt/dirt\|OK` |
| `diff-header-skip` | 182 | `s%continue ;;%;;%` | SEPARATED | `dirt_build_artifact` | `DIRTFILE\|/repo-wt/dirt\|DISPOSABLE_BUILD_ARTIFACT\|\| M\|src/Legacy/Legacy.csproj` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\| M\|src/Legacy/Legacy.csproj` |
| `rung1-y-column-gate` | 270 | `s% && $y == " "%%` | SEPARATED | `dirt_staged_tree_worktree_delta` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|MM\|src/a.cs` becomes `DIRTFILE\|/repo-wt/dirt\|STAGED_TREE_IS_COMMIT\|eeee7777\|MM\|src/a.cs` |
| `hash-object-hard-fail` | 329 | `s% \|\| \[\[ -z $blob \]\]%%` | ARGV | `dirt_staged_tree_worktree_delta` | records byte-identical; the argv log gains `log main~1000..main --find-object= --format=%H --max-count=1`, one added line per `classify_worktree_dirt` call |
| `rung4-untracked-main-present` | 339 | `s%\[\[ -n $mainblob && $mainblob == "$blob" \]\]%[[ -n "x" ]]%` | SEPARATED | `dirt_rename_split` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|??\|notes -> draft.md` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|??\|notes -> draft.md`; aggregate `HAS_UNIQUE` becomes `ALL_DISPOSABLE` |
| `history-hit-nonempty` | 359 | `s%\[\[ -n $found \]\]%[[ -n "" ]]%` | SEPARATED | `dirt_content_in_history` | `DIRTFILE\|/repo-wt/dirt\|CONTENT_IN_HISTORY\|ffff8888\|??\|docs/old.md` becomes `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|??\|docs/old.md` |
| `rename-payload-split-gate` | 421 | `s%== C \]\]%== C \|\| -n "x" \]\]%` | SEPARATED | `dirt_rename_split` | `DIRTFILE\|/repo-wt/dirt\|UNIQUE\|\|??\|notes -> draft.md` becomes `DIRTFILE\|/repo-wt/dirt\|CONTENT_ON_MAIN\|\|??\|draft.md` — the path field is truncated |
| `unique-verdict-tally` | 428 | `s%\[\[ $verdict == "UNIQUE" \]\]%[[ -n "" ]]%` | SEPARATED | `dirt_unique` | `DIRTSUM\|/repo-wt/dirt\|HAS_UNIQUE\|` becomes `DIRTSUM\|/repo-wt/dirt\|ALL_DISPOSABLE\|` |
| `clear-requires-all-disposable` | 465 | `s%\[\[ $agg != "ALL_DISPOSABLE" \]\]%[[ -n "" ]]%` | SEPARATED | `dirt_unique` | `ACTION\|dirt-clear\|/repo-wt/dirt\|REFUSED-UNIQUE` becomes `ACTION\|dirt-clear\|/repo-wt/dirt\|OK` |

## The four rows whose observation is not yet available

Exactly four observation cells above carry the placeholder token, and they are these four
rows and no others:

| id | mutation | scenario | why the observation is unavailable here |
|---|---|---|---|
| `build-artifact-vacuous-confinement` | `s/((total == 0))/((0))/` | `dirt_build_artifact_empty_diff` | The directory does not exist until [P3-T4], so the harness cannot run for this row at all. |
| `rung4-tracked-hard-fail` | `s/((drc > 1))/((0))/` | `dirt_tracked_probe_error_in_history` | The directory does not exist until [P3-T3], so the harness cannot run for this row at all. |
| `hash-object-hard-fail` | `s/((hrc != 0))/((0))/` | `dirt_classifier_read_error` | The directory exists and the harness runs, but the separating payload files are not added until [P3-T2], so both channels are observed identical. |
| `find-object-hard-fail` | `s/((lrc != 0))/((0))/` | `dirt_history_read_error` | The directory exists and the harness runs, but the separating payload file is not added until [P3-T1], so both channels are observed identical. |

All four are closed by [P3-T8], which records the same rows with their post-Phase-3
observations. The first two are the rows [P2-T10] records failing obligation 1; the second
two are the rows it records failing obligation 5.

## Non-`SEPARATED` rows: scenario and full `reason`

Both non-`SEPARATED` rows are `ARGV`. Each is reproduced here with its `scenario` value and
the complete `reason` string the registry holds, so an unattempted classification would be
visible on the face of this evidence.

**Row `history-scan-bounded-range`**, marker line 351, mutation `s/((vrc == 0))/((0))/`,
scenario `dirt_unique`. Full `reason`:

```
ARGV-ONLY: the bounded-range endpoint selects only the rev range handed to log --find-object, and the stub keys that read on the object id alone, so the verdict and every record are identical while the log invocation changes from main~1000..main to main.
```

**Row `hash-object-hard-fail` literal**, marker line 329, mutation
`s% || \[\[ -z $blob \]\]%%` (written here unescaped, as the registry holds it), scenario
`dirt_staged_tree_worktree_delta`. Full `reason`:

```
ARGV-ONLY: removing the empty-blob half lets the ladder run past a failed content read carrying an empty object id; the entry is UNIQUE by rung 6 instead of by this guard, so the record channel is byte-identical and the argv log gains the rung-5 log --find-object= invocation with an empty argument.
```

## The `EXEMPT` both-direction rule

**No registry row is classified `EXEMPT`.** The `EXEMPT` count is 0, so D3's both-direction
rule — which requires an `EXEMPT` form-2 row to record the sibling constant that was run and
to state that both channels were identical under it — has no row to apply to in this
registry. The rule remains implemented in the harness (`EXEMPT_SIBLING_DIFFERED` in
`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`) and would fire if a later
change made a row `EXEMPT`. Recorded here as an observed count of zero rather than as a
claim that the rule is unnecessary.

## How each row's kind was determined

Every kind in the table above is an observation, not a verdict written by hand. For each row
the mutated library was composed with the `$`-anchored marker address, accepted by `bash -n`,
and evaluated in a child shell against the row's scenario; the record channel and the argv
log were compared against the unmutated run of the same scenario. A row whose record channel
differed is `SEPARATED`; a row whose record channel was identical and whose argv log differed
is `ARGV`; a row for which neither differed would be `EXEMPT`, and none was.
[P2-T6] re-derives all of this at gate time, so a row whose recorded kind does not match the
observation fails the suite rather than passing on the written value.
