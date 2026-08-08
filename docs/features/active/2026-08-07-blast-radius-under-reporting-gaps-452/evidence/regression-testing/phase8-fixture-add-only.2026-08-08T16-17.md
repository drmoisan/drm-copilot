# [P8-T6] Fixture corpus is ADD-ONLY

Timestamp: 2026-08-08T16-17
Task: [P8-T6]

Hard constraint 2 makes `tests/fixtures/blast_radius/` add-only: no existing fixture expectation
may be relaxed to make a test pass. `spec.md` line 656 states the check as
`git diff --name-status -- tests/fixtures/blast_radius/` listing only `A` entries and no `M`
entries.

Command:

```
git add -A tests/fixtures/blast_radius/
git diff --cached --name-status -- tests/fixtures/blast_radius/
git diff --name-status -- tests/fixtures/blast_radius/
git reset -q tests/fixtures/blast_radius/
```

The five new fixtures are untracked, so `git diff --name-status` alone reports nothing for them.
They were staged, classified, and immediately unstaged; the staging was a read-only classification
step and left no residue (`git status --porcelain` afterwards reports all five back at `??`).

EXIT_CODE: 0

## Output Summary

Staged classification:

```
A	tests/fixtures/blast_radius/conflict-directory-vs-file.json
A	tests/fixtures/blast_radius/conflict-directory-vs-glob.json
A	tests/fixtures/blast_radius/conflict-sibling-prefix-disjoint.json
A	tests/fixtures/blast_radius/derivation-root-surface-not-configured.json
A	tests/fixtures/blast_radius/derivation-root-surface-reached.json
```

Unstaged working-tree diff against `HEAD`: empty.

| Status | Count |
| --- | --- |
| `A` (added) | 5 |
| `M` (modified) | 0 |
| `D` (deleted) | 0 |
| `R` (renamed) | 0 |

Zero `M` entries and zero `D` entries. All 21 fixtures committed before this change are byte
unchanged; the corpus grew from 21 to 26 files by addition only. No existing fixture expectation
was relaxed.
