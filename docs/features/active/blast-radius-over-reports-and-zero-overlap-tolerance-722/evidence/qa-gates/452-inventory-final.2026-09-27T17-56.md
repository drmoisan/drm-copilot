# #452 Fixture Inventory, Final (P14-T2)

Timestamp: 2026-09-27T17-56
Command: git grep -l -F "#452" -- tests/fixtures/blast_radius ; git grep -l -F "#452" origin/main -- tests/fixtures/blast_radius (two separate invocations, run on the merged tree, HEAD 4dc5d488945ff59fb3ebbc67312b7bb87491072f, FINAL_BASE beae3f021674e64fa6662097fe48a332d8da62b8)
EXIT_CODE: 0
Output Summary: PASS. Both commands exited 0. The merged branch tree carries eight #452-tagged files: five gate fixtures directly in tests/fixtures/blast_radius (the five B1 fixtures) and three excluded paths in the scheduling subdirectory (the P1-T2 through P1-T4 fixtures, verified by P7-T1 and P7-T2). origin/main carries the same five gate fixtures. No sibling-added fixture exists: the set of origin/main fixtures not on this branch is empty, and no gate fixture outside the five B1 fixtures exists on the branch.

## Branch tree (merged)

```text
tests/fixtures/blast_radius/conflict-directory-vs-file.json
tests/fixtures/blast_radius/conflict-directory-vs-glob.json
tests/fixtures/blast_radius/conflict-sibling-prefix-disjoint.json
tests/fixtures/blast_radius/derivation-root-surface-not-configured.json
tests/fixtures/blast_radius/derivation-root-surface-reached.json
tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json
tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json
tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json
(exit 0)
```

## origin/main

```text
origin/main:tests/fixtures/blast_radius/conflict-directory-vs-file.json
origin/main:tests/fixtures/blast_radius/conflict-directory-vs-glob.json
origin/main:tests/fixtures/blast_radius/conflict-sibling-prefix-disjoint.json
origin/main:tests/fixtures/blast_radius/derivation-root-surface-not-configured.json
origin/main:tests/fixtures/blast_radius/derivation-root-surface-reached.json
(exit 0)
```

## Classification

Gate fixtures (files directly in tests/fixtures/blast_radius):

| File stem F | In block B1 | Kind |
| --- | --- | --- |
| conflict-directory-vs-file | yes | conflict |
| conflict-directory-vs-glob | yes | conflict |
| conflict-sibling-prefix-disjoint | yes | conflict |
| derivation-root-surface-not-configured | yes | derivation |
| derivation-root-surface-reached | yes | derivation |

Excluded paths (files in a subdirectory; the scheduling-452 fixtures of P1-T2 through P1-T4, verified
by P7-T1 and P7-T2):

```text
tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json
tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json
tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json
```

Set difference (origin/main gate fixtures not on this branch): none.
Gate fixtures not among the five B1 fixtures (sibling-added): none.
