# Cycle-2 closure — cleanup-worktrees dirt classifier, issue #632 (P5-T12)

Timestamp: 2026-09-08T10-00
WorkingDirectory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac72d35e7980bc69d`
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
Plan: `remediation-plan.2026-09-08T06-51.md`

## The seven items this cycle carried

### 1. N1 — rung 4's tracked half resolved a verdict from an empty pathspec

**Change.** Rung 4's tracked half keeps `diff --quiet main -- "$rel"` as its first read, but a zero
exit no longer resolves `CONTENT_ON_MAIN` on its own. The positive verdict is now conditional on the
path being present in `main`, probed through the same seam with
`cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet "main:$rel"` at
`scripts/bash/cleanup_worktrees_dirt_lib.sh:312`. The exit code is captured into a new local `erc`
and only `erc` equal to 0 emits `CONTENT_ON_MAIN`; any other value falls through without emitting,
so the entry advances to the `hash-object` guard, where an `AD` entry fails closed to `UNIQUE`. The
new read is redirected with `>/dev/null` only, never `2>&1`, so the stub's argv log still sees it.

**Tests that hold it.** `dirt_tracked_staged_only_blob: an AD entry whose content is only a staged
blob is UNIQUE` and `dirt_tracked_staged_only_blob: a tracked entry whose content is on main is
still CONTENT_ON_MAIN`, both in `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`, driven by
the single checked-in fixture
`tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_staged_only_blob/`. Both directions come
from one fixture, so one probe result serves both.

**Evidence.** `evidence/regression-testing/fail-before-rung4-path-in-main.2026-09-08T08-00.md` and
`evidence/regression-testing/pass-after-rung4-path-in-main.2026-09-08T08-00.md`.

### 2 through 5. N2 — the four guards whose removal changed nothing observable

Each of the four is now registered and each has a checked-in scenario under which neutralizing it
changes the emitted record channel. All four separate from refusing to clear to clearing, which is
the concrete form of "deleting the guard changes what the tool does".

| Cycle-start site | Registry id | Mutation | Scenario |
|---|---|---|---|
| `:213` `((total == 0)) && return 1` | `build-artifact-vacuous-confinement` | `s/((total == 0))/((0))/` | `dirt_build_artifact_empty_diff` (new) |
| `:301` `((drc > 1))` | `rung4-tracked-hard-fail` | `s/((drc > 1))/((0))/` | `dirt_tracked_probe_error_in_history` (new) |
| `:311` `((hrc != 0))` | `hash-object-hard-fail` | `s/((hrc != 0))/((0))/` | `dirt_classifier_read_error` (extended) |
| `:336` `((lrc != 0))` | `find-object-hard-fail` | `s/((lrc != 0))/((0))/` | `dirt_history_read_error` (extended) |

**Tests that hold them.** `every registered guard is observable under its own neutralization` and
`the eighteen pinned guard rows carry the registry kinds this plan fixes`, both in
`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`.

**Evidence.** `evidence/regression-testing/fail-before-guard-separation.2026-09-08T08-30.md` and
`evidence/regression-testing/pass-after-guard-separation.2026-09-08T09-00.md`.

### 6. The systemic finding — a machine-enforced guard gate

**Change.** Two consecutive cycles shipped a data-loss defect that passed the whole 45-criterion
set, and neither N1 nor N2 mapped to any criterion. This cycle makes the property machine-enforced
rather than asserted in prose. Every arithmetic guard-shaped line in
`scripts/bash/cleanup_worktrees_dirt_lib.sh` carries a `# guard:<id>` marker — 37 marker lines over
31 arithmetic lines plus six non-arithmetic-only lines. The registry at
`tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` carries 39 rows under (`id`, `mutation`)
row identity: 31 arithmetic rows plus the eight named non-arithmetic verdict guards, including the
three sites that produced findings R1, R2 and R5. Every row's mutation is a semantic neutralization,
so a comment-only or whitespace-only edit is rejected rather than parked as exempt. AC-47 in
`spec.md` records the property, including that `EXEMPT is scenario-scoped`.

**Tests that hold it.** The three tests in
`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`:
`every guard-shaped line in the dirt library is marked and every registry row names a marked id`,
`every registered guard is observable under its own neutralization`, and
`the eighteen pinned guard rows carry the registry kinds this plan fixes`.

**Evidence.** `evidence/other/guard-registry-design.2026-09-08T08-30.md`,
`evidence/qa-gates/guard-registry-classification.2026-09-08T08-30.md`,
`evidence/regression-testing/fail-before-guard-separation.2026-09-08T08-30.md`,
`evidence/regression-testing/pass-after-guard-separation.2026-09-08T09-00.md`,
`evidence/regression-testing/marker-pass-neutral.2026-09-08T08-30.md`.

### 7. O1 — AC-8's stale scenario count

**Change.** AC-8 read "no other verdict token is produced by any of the ten `dirt_*` scenarios".
The count was stale: there were 25 scenarios at cycle start and there are 28 at cycle end. The word
`ten` became `twenty-eight` at `spec.md:714`. The box stays checked; the code already exceeded the
criterion.

**Test that holds it.** The membership test at
`tests/shell/test_cleanup_worktrees_dirt_classify.bats:214-252`, which names each `dirt_*` scenario
explicitly, asserts the iterated count equals the on-disk directory count, and asserts a literal
record total — 34 records over 28 scenarios at cycle end.

**Evidence.** `evidence/other/ac-count-reconciliation.2026-09-08T09-30.md`.

## The eighteen pinned registry rows and what now separates each

Eighteen rows over seventeen distinct ids. The two `hash-object-hard-fail` rows are listed
separately and distinguished by their `mutation`, because that id backs two rows on one marker line
and an id-keyed pin on it would be discharged by either.

| # | Registry row (`id` and `mutation`) | Kind | Scenario | What separates it |
|---:|---|---|---|---|
| 1 | `build-artifact-vacuous-confinement` — `s/((total == 0))/((0))/` | SEPARATED | `dirt_build_artifact_empty_diff` | verdict moves from `UNIQUE` to `DISPOSABLE_BUILD_ARTIFACT`, aggregate from `HAS_UNIQUE` to `ALL_DISPOSABLE` |
| 2 | `rung4-tracked-path-in-main` — `s/((erc == 0))/((1))/` | SEPARATED | `dirt_tracked_staged_only_blob` | the `AD` entry moves from `UNIQUE` to `CONTENT_ON_MAIN`, aggregate to `ALL_DISPOSABLE` |
| 3 | `rung4-tracked-hard-fail` — `s/((drc > 1))/((0))/` | SEPARATED | `dirt_tracked_probe_error_in_history` | a hard read failure stops mapping to `UNIQUE` and the entry resolves from history instead |
| 4 | `hash-object-hard-fail` arithmetic row — `s/((hrc != 0))/((0))/` | SEPARATED | `dirt_classifier_read_error` | the fail-closed `UNIQUE` is lost and the aggregate becomes `ALL_DISPOSABLE` |
| 5 | `find-object-hard-fail` — `s/((lrc != 0))/((0))/` | SEPARATED | `dirt_history_read_error` | the fail-closed `UNIQUE` is lost and the aggregate becomes `ALL_DISPOSABLE` |
| 6 | `status-read-hard-fail` — `s/((srrc != 0))/((1))/` | SEPARATED | `dirt_unique` | the classifier returns 0 having emitted no record at all instead of one `DIRTFILE` and one `DIRTSUM` record |
| 7 | `clear-reset-hard-fail` — `s/((rrc != 0))/((0))/` | SEPARATED | `dirt_clear_reset_failed` | the clear record moves from `FAILED` exit 1 to `OK` exit 0, and the argv log gains the `clean -fd` invocation |
| 8 | `clear-clean-hard-fail` — `s/((clrc != 0))/((0))/` | SEPARATED | `dirt_clear_clean_failed` | the clear record moves from `FAILED` exit 1 to `OK` exit 0; the argv log is identical, so this is the pinned row whose separation depends on the widened record channel |
| 9 | `clear-requires-all-disposable` — `s%\[\[ $agg != "ALL_DISPOSABLE" \]\]%[[ -n "" ]]%` | SEPARATED | `dirt_unique` | `REFUSED-UNIQUE` exit 1 becomes `OK` exit 0 |
| 10 | `unique-verdict-tally` — `s%\[\[ $verdict == "UNIQUE" \]\]%[[ -n "" ]]%` | SEPARATED | `dirt_unique` | the aggregate moves from `HAS_UNIQUE` to `ALL_DISPOSABLE` |
| 11 | `history-hit-nonempty` — `s%\[\[ -n $found \]\]%[[ -n "" ]]%` | SEPARATED | `dirt_content_in_history` | the record's verdict moves from `CONTENT_IN_HISTORY` to `UNIQUE` with an empty detail |
| 12 | `diff-header-skip` — `s%continue ;;%;;%` | SEPARATED | `dirt_build_artifact` | the verdict moves from `DISPOSABLE_BUILD_ARTIFACT` to `CONTENT_ON_MAIN`; this is R5's site |
| 13 | `rung1-y-column-gate` — `s% && $y == " "%%` | SEPARATED | `dirt_staged_tree_worktree_delta` | the `MM src/a.cs` entry's verdict becomes `STAGED_TREE_IS_COMMIT`; this is R1's site |
| 14 | `rename-payload-split-gate` — `s%== C \]\]%== C || -n "x" \]\]%` | SEPARATED | `dirt_rename_split` | the untracked entry's path field collapses from `notes -> draft.md` to `draft.md`; this is R2's site |
| 15 | `rung4-tracked-gate` — `s/((untracked == 0))/((0))/` | SEPARATED | `dirt_tracked_staged_only_blob` | the `M  docs/tracked.md` entry moves from `CONTENT_ON_MAIN` to `UNIQUE` |
| 16 | `rung4-tracked-content-equal` — `s/((drc == 0))/((0))/` | SEPARATED | `dirt_tracked_staged_only_blob` | the `M  docs/tracked.md` entry moves from `CONTENT_ON_MAIN` to `UNIQUE` |
| 17 | `rung4-untracked-main-present` literal row — `s%\[\[ -n $mainblob && $mainblob == "$blob" \]\]%[[ -n "x" ]]%` | SEPARATED | `dirt_rename_split` | the untracked entry moves from `UNIQUE` to `CONTENT_ON_MAIN` and the aggregate to `ALL_DISPOSABLE` |
| 18 | `hash-object-hard-fail` literal row — `s% || \[\[ -z $blob \]\]%%` | **ARGV** | `dirt_staged_tree_worktree_delta` | **separates on the argv channel**: the record channel is byte-identical and the argv log gains the rung-5 `log --find-object=` invocation carrying an empty argument |

Fourteen rows are registered `SEPARATED` under the plan's fixed pins. Of the four rows pinned
`SEPARATED` or `ARGV` — rows 12, 13, 14 and 18 — three landed `SEPARATED` and row 18 landed `ARGV`,
which is an admitted outcome for that pin.

## Local gate state at cycle end

| Gate | Result | Artifact |
|---|---|---|
| `shell-qc.sh format` | exit 0, empty stream, tree unchanged | `evidence/qa-gates/shell-qc-format.2026-09-08T10-00.md` |
| `shell-qc.sh check` | exit 0, empty stream | `evidence/qa-gates/shell-qc-check.2026-09-08T10-00.md` |
| `shell-qc.sh test` | exit 0, plan `1..411`, 411 ok, 0 not ok | `evidence/qa-gates/shell-qc-test.2026-09-08T10-00.md` |
| File-size limit | all five files at or under 500; classifier 481, up 18 from 463 | `evidence/qa-gates/file-size-limit.2026-09-08T10-00.md` |
| Report mode non-mutating | exit 0, 14 ok, 0 not ok; stub digest unchanged | `evidence/qa-gates/report-mode-non-mutating.2026-09-08T10-00.md` |
| Push-down contract | exit 1, `1 failed, 10 passed` — pre-existing issue #510, identical at Phase 0 baseline | `evidence/qa-gates/single-consecutive-pass.2026-09-08T10-00.md` |
| Acceptance criteria | section-scoped 47 total, 47 checked | `evidence/other/ac-checkoff.2026-09-08T10-00.md` |

## Tasks left unchecked at executor exit

| Task | Reason |
|---|---|
| P0-T3 | tree-digest command denied by the worktree isolation guard; adjudicated in `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md` |
| P0-T10 | pre-existing push-down contract failure, issue #510; adjudicated in the same record |
| P4-T7 | the same pre-existing failure, recorded in `evidence/qa-gates/pytest-push-down-contract.2026-09-08T09-30.md` |
| P5-T1 | the same digest denial as P0-T3; the format stage itself exits 0 and rewrote nothing |
| P5-T6 | push withheld — the orchestrator owns pushing this branch |
| P5-T7 | CI dispatch of `_shell-coverage.yml` requires `gh`; owned by the orchestrator |
| P5-T8 | reads that run's merged Cobertura artifact; depends on P5-T7 |
| P5-T9 | coverage delta; depends on P5-T8's post-change figures |
| P5-T11 | the pre-existing contract failure, and the acceptance additionally requires the CI coverage run id, which does not yet exist |
| P5-T12 | this task; its acceptance requires a push and a post-push clean-status observation, both of which are the orchestrator's |

No inferred, estimated or locally-derived coverage figure is recorded anywhere in this cycle's
evidence. `kcov` has no local route in this worktree; `bash scripts/bash/shell-qc.sh test --coverage`
exits 127 here.

## Commits

| Phase | SHA |
|---|---|
| Phases 0 through 3 | `16cf6462`, `82cc20b2`, `ecb568d1`, `9ef2f892` |
| Phase 4 | `e8fe310f` |
| Phase 5, P5-T6 | `a30afbcc` |
| Phase 5, closing | the commit that carries this artifact |
