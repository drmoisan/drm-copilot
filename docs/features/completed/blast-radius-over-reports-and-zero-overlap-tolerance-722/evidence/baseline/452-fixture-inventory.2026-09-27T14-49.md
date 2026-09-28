# #452 Fixture Inventory (P0-T20)

Timestamp: 2026-09-27T14-49
Command: git grep -l -F "#452" -- tests/fixtures/blast_radius ; git grep -l -F "#452" origin/main -- tests/fixtures/blast_radius
EXIT_CODE: 0
Output Summary: Both commands exited 0. The branch tree and origin/main each carry the same five #452-tagged fixtures, which equal the five planning-time fixtures. Set difference (origin/main minus branch): empty. No sibling-added fixture.

## Branch tree (git grep -l -F "#452" -- tests/fixtures/blast_radius)

```text
tests/fixtures/blast_radius/conflict-directory-vs-file.json
tests/fixtures/blast_radius/conflict-directory-vs-glob.json
tests/fixtures/blast_radius/conflict-sibling-prefix-disjoint.json
tests/fixtures/blast_radius/derivation-root-surface-not-configured.json
tests/fixtures/blast_radius/derivation-root-surface-reached.json
```

## origin/main (git grep -l -F "#452" origin/main -- tests/fixtures/blast_radius)

```text
origin/main:tests/fixtures/blast_radius/conflict-directory-vs-file.json
origin/main:tests/fixtures/blast_radius/conflict-directory-vs-glob.json
origin/main:tests/fixtures/blast_radius/conflict-sibling-prefix-disjoint.json
origin/main:tests/fixtures/blast_radius/derivation-root-surface-not-configured.json
origin/main:tests/fixtures/blast_radius/derivation-root-surface-reached.json
```

## Set comparison

| Fixture | Branch | origin/main | Planning-time set |
| --- | --- | --- | --- |
| conflict-directory-vs-glob | yes | yes | yes |
| conflict-directory-vs-file | yes | yes | yes |
| conflict-sibling-prefix-disjoint | yes | yes | yes |
| derivation-root-surface-reached | yes | yes | yes |
| derivation-root-surface-not-configured | yes | yes | yes |

- Fixtures on origin/main not on this branch: none.
- Sibling-added fixtures: none.
