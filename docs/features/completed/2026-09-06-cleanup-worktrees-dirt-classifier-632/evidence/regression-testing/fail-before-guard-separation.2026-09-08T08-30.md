# Fail-before — the guard separation gate with the four N2 fixtures absent — [P2-T10]

Timestamp: 2026-09-08T08-30
Task: [P2-T10] `[expect-fail]`
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

Command: npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats
EXIT_CODE: 1
ExpectedExitCode: 1

State at the time of the run: the registry
`tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` is complete at 39 rows
(`grep -vc '^#'` reports 39), and none of the four Phase 3 fixture additions has been made.

## Verbatim TAP output

```
1..3
ok 1 every guard-shaped line in the dirt library is marked and every registry row names a marked id
not ok 2 every registered guard is observable under its own neutralization
# (in test file tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats, line 388)
#   `[ -z "$OB1" ]' failed
# OBLIGATION-1 scenario absent or not dirt_: build-artifact-vacuous-confinement rung4-tracked-hard-fail
# OBLIGATION-5 channel comparison failed: hash-object-hard-fail find-object-hard-fail
ok 3 the eighteen pinned guard rows carry the registry kinds this plan fixes
```

## Which of the four failed which obligation

| id | scenario named by its row | obligation failed | cause |
|---|---|---|---|
| `build-artifact-vacuous-confinement` | `dirt_build_artifact_empty_diff` | **1** — the scenario-directory check | The directory does not exist until [P3-T4]. |
| `rung4-tracked-hard-fail` | `dirt_tracked_probe_error_in_history` | **1** — the scenario-directory check | The directory does not exist until [P3-T3]. |
| `hash-object-hard-fail` (arithmetic row) | `dirt_classifier_read_error` | **5** — the `SEPARATED` channel comparison | The directory exists and the harness runs, but the two separating payload files are not added until [P3-T2], so the mutated record channel equals the unmutated one. |
| `find-object-hard-fail` | `dirt_history_read_error` | **5** — the `SEPARATED` channel comparison | The directory exists and the harness runs, but the separating payload file is not added until [P3-T1], so the mutated record channel equals the unmutated one. |

Two failed obligation 1 and two failed obligation 5, which is the split the plan predicts.

## The bound on the diagnostic

The failing test's diagnostic names exactly four ids and no fifth. The two accumulator lines
above enumerate `build-artifact-vacuous-confinement`, `rung4-tracked-hard-fail`,
`hash-object-hard-fail` and `find-object-hard-fail`; no other identifier appears on either
line. The bound matters because the [P2-T4] helper accumulates per-row outcomes rather than
asserting inside the row loop, so a single run reports every offending row. An unrelated
fifth failing row would otherwise have been recorded here as expected output and carried past
this gate unexamined.

`rung4-tracked-path-in-main` is **not** named. Its witness scenario
`dirt_tracked_staged_only_blob` was created by [P1-T1] and [P1-T2] and already separates the
guard: forcing `((erc == 0))` to `((1))` turns the `AD staged_only.md` entry from `UNIQUE`
into `CONTENT_ON_MAIN`, flips the aggregate from `HAS_UNIQUE` to `ALL_DISPOSABLE`, and turns
the clear from `REFUSED-UNIQUE` exit 1 into `OK` exit 0. That is the N1 data-loss path, and
it is observable now rather than after Phase 3.

## The other two tests

Both report a line beginning `ok `:

- `ok 1 every guard-shaped line in the dirt library is marked and every registry row names a marked id`
- `ok 3 the eighteen pinned guard rows carry the registry kinds this plan fixes`

The failure observed is therefore a separation and scenario-availability failure, not an
enumeration failure and not a registry-shape failure. All 31 arithmetic guard-shaped lines
carry a marker, all 37 markers back at least one row, all 39 rows name a marked id with an
admissible mutation, the eight named non-arithmetic `(id, mutation)` pairs are registered, and
all eighteen pins over seventeen distinct ids hold.

## Pass-after

The pass-after half of this gate is [P3-T7], recorded at
`evidence/regression-testing/pass-after-guard-separation.2026-09-08T09-00.md`.
