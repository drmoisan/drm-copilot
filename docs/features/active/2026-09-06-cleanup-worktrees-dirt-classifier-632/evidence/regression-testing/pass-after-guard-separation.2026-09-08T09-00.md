# Pass-after — the guard separation gate with the four Phase 3 fixtures in place — [P3-T7]

Timestamp: 2026-09-08T09-00
Task: [P3-T7]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

Command: npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats
EXIT_CODE: 0

TAP plan line: 1..3
OkCount: 3
NotOkCount: 0

## Verbatim TAP output

```
1..3
ok 1 every guard-shaped line in the dirt library is marked and every registry row names a marked id
ok 2 every registered guard is observable under its own neutralization
ok 3 the eighteen pinned guard rows carry the registry kinds this plan fixes
```

The line this task's acceptance names is present:

```
ok 2 every registered guard is observable under its own neutralization
```

That line was `not ok` in the fail-before run recorded at
`evidence/regression-testing/fail-before-guard-separation.2026-09-08T08-30.md`, where it named
`build-artifact-vacuous-confinement` and `rung4-tracked-hard-fail` failing obligation 1 and
`hash-object-hard-fail` and `find-object-hard-fail` failing obligation 5. The only changes
between the two runs are [P3-T1] through [P3-T4]: two fixture files added to two existing
scenarios and two new scenario directories created. No library line, no registry cell, and no
assertion in the suite was altered between the two runs.

All five remediated guards now change the record channel under neutralization. Under
neutralization each of the five turns a refusal to clear into a clear:
`HAS_UNIQUE` becomes `ALL_DISPOSABLE` and `ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE`
exit 1 becomes `ACTION|dirt-clear|/repo-wt/dirt|OK` exit 0. The per-row records are in
`evidence/qa-gates/guard-separation-probe.2026-09-08T09-00.md`.

## The unexempted form of [P2-T8] acceptance command 6

[P2-T8] ran this command with `dirt_tracked_probe_error_in_history` and
`dirt_build_artifact_empty_diff` temporarily exempted, because [P3-T3] and [P3-T4] had not yet
created those directories. Both now exist, so the unexempted form is run here.

Command:

```
awk -F'\t' '!/^#/ {print $3}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort -u | while read -r s; do [ -d "tests/fixtures/cleanup_worktrees/scenarios/$s" ] || echo "MISSING $s"; done
```

EXIT_CODE: 0
Output: none. Every one of the 39 rows names a scenario directory that exists on disk.

## [P2-T8] acceptance command 7, re-run

Re-run because this task is authorized to change a row's arithmetic constant, which would
change the (`id`, `mutation`) pair.

Command:

```
awk -F'\t' '!/^#/ {print $1"\t"$5}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort | uniq -d
```

EXIT_CODE: 0
Output: none. Row identity by (`id`, `mutation`) still holds across all 39 rows.

## Re-classification

**No registry row was re-classified.** The gate passed on the first run after the Phase 3
fixtures were added, so no `kind`, no `reason`, and no arithmetic constant required an edit.
The bounded authorization this task carries was not exercised. The two scenarios whose payloads
were added and whose rows were therefore checked for a changed observation are
`dirt_history_read_error` and `dirt_classifier_read_error`. Each backs exactly one registry row
— `find-object-hard-fail` and `hash-object-hard-fail`'s arithmetic row respectively — and both
rows were already recorded `SEPARATED`, which is what the harness now observes.

## Output Summary

The separation gate exits 0 with 3 ok and 0 not ok. Both registry-shape commands re-run here
produce no output. No row was re-classified.
