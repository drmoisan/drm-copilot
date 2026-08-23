# QA Gate — Fixture-Corpus Diff — [P5-T12]

Timestamp: 2026-08-23T02-55

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P5-T12]
Status: **PARTIAL — the path count is three, not the four the acceptance names. See the deviation
section; the cause is the [P5-T3] blocker, not a fixture this task failed to record.**

## Command 1 — porcelain status

Command: `git status --porcelain -- tests/fixtures/blast_radius`

EXIT_CODE: 0

```text
?? tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json
?? tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json
?? tests/fixtures/blast_radius/validation-placeholder-self-consistent.json
```

## Command 2 — main-anchored diff

Command: `git diff --name-status main -- tests/fixtures/blast_radius`

EXIT_CODE: 0

```text
```

Empty. Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`.

## Why the union of the two commands is required

Neither command alone suffices, and the reason is commit state:

- The **porcelain** form reports the new fixtures while they are untracked, but goes empty once they
  are committed.
- The **`main`-anchored diff** reports them once they are committed, but never reports an untracked
  file.

Taking the union makes the gate independent of whether the executor has committed. In this run the
fixtures are untracked, so the porcelain form carries all three entries and the anchored diff is
empty; after a commit the two would swap. Either way the union is the same set.

`git add --intent-to-add` was deliberately not substituted for either command: it mutates the index,
and the union form needs no such side effect. That prohibition is scoped to this task alone and does
not conflict with the `git add -A` step the five Phase 8 audits require. The two situations differ:
this gate asserts a file *set* and the union supplies it without touching the index, whereas those
audits need diff *content* and line counts, which no union of status output can supply. This task
also runs several phases earlier, before any staging step, and works in either state, so requiring
staging later does not disturb it.

## Union of the two outputs

| Path | Status | Created by |
| --- | --- | --- |
| `tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json` | untracked (`??`) | [P5-T2] |
| `tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json` | untracked (`??`) | [P5-T1] |
| `tests/fixtures/blast_radius/validation-placeholder-self-consistent.json` | untracked (`??`) | [P5-T4] |

**Three paths.** Every entry is one of the fixtures created in this phase and every entry carries an
untracked status.

## Zero modified entries — the pre-existing corpus is intact

The union carries **zero** entries with a modified status. Neither command reported an `M` or ` M`
entry under `tests/fixtures/blast_radius`, which proves all **32** pre-existing fixtures are
unmodified in both commit states. That includes
`tests/fixtures/blast_radius/conflict-path-overlap.json`, the reused negative control, whose
unmodified state is separately and more strongly established by [P5-T7]'s `--exit-code` diff against
`main`.

This is the half of the gate that carries the real risk. A change that quietly adjusted an existing
fixture's `expected` block to accommodate the new guard would be invisible to the parity suites,
because both suites read the fixture as their own source of truth. The zero-modified-entry
observation is what forecloses that.

## Deviation — three paths where the acceptance names four

The acceptance requires the union to name "exactly four paths". It names three. The missing fourth
is the conflict fixture of [P5-T3], which was not created because its acceptance condition is
unreachable: a conflict fixture is compared as literal recorded radii and the conflict relation never
invokes the classifier the guard lives in, so its verdict is invariant under this item's fix. The
full analysis, the measurement that establishes it, and a requested plan revision are recorded at
`docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/other/p5-t3-blocker-conflict-fixture-seam.md`.

The deviation is confined to the count. Both substantive conditions of this gate hold in full:

- every path in the union is a fixture this phase created, and each carries an added or untracked
  status;
- the union carries zero modified entries, so all 32 pre-existing fixtures are unmodified.

The count is recorded as observed rather than adjusted, and this task is **not** marked complete.

## Output Summary

The union of the porcelain status and the `main`-anchored diff names three paths, each a fixture
created in this phase and each untracked. Zero entries carry a modified status, proving all 32
pre-existing fixtures are unmodified in both commit states. The acceptance names four paths; the
count is three because [P5-T3] was blocked, and the shortfall is attributed rather than absorbed.
