# Layout Check [P4-T1]

Timestamp: 2026-11-20T16-07
Command: node SCRATCH/issue-1016-p4t1.cjs (git ls-files .dev; git ls-files docs; git ls-tree --name-only of each area at the parent of the apply commit and at HEAD; RENAME_MAP from FRESH_DRY_RUN dev-docs-migration-dry-run.2026-11-20T12-28.json renames plus the rename entries of DECISIONS folder-rename-decisions.2026-11-20T12-24.json)
EXIT_CODE: 0
Output Summary: Every condition PASS with 0 mismatches. The top-level entries of git ls-files .dev are exactly potential, active, completed, archive, epics, parallel, templates, research, engineering, discovery and backlog.md; git ls-files docs lists only docs/README.md, which contains the token production; the folder names under .dev/active (95), .dev/completed (187) and .dev/archive (141) equal the names RENAME_MAP and the keep and kept entries predict; .dev/potential (35), .dev/epics (11), .dev/parallel (12) and .dev/research (27) equal their pre-move names.

## Listings

- `git ls-files .dev` top-level entries (observed = expected): `active, archive, backlog.md, completed, discovery, engineering, epics, parallel, potential, research, templates`.
- `git ls-files docs`: `docs/README.md`.

## Counts

| Area | Expected | Observed | Missing | Extra | Result |
| --- | --- | --- | --- | --- | --- |
| `.dev/active` | 95 | 95 | none | none | PASS |
| `.dev/completed` | 187 | 187 | none | none | PASS |
| `.dev/archive` | 141 | 141 | none | none | PASS |
| `.dev/potential` | 35 | 35 | none | none | PASS |
| `.dev/epics` | 11 | 11 | none | none | PASS |
| `.dev/parallel` | 12 | 12 | none | none | PASS |
| `.dev/research` (from `docs/research` and `docs/features/research`, two dry-run moves) | 27 | 27 | none | none | PASS |

FRESH_DRY_RUN counts: 37 moves, 404 renames (including the 33 rename decisions of DECISIONS), 45 held items (33 rename and 12 keep decisions), 7 kept folders. RENAME_MAP size 404.

The first run of the script compared `.dev/research` with `docs/research` only and reported `claude-ecosystem.md` as extra; the file came from `docs/features/research/`, which the dry run also moves to `.dev/research`, so the comparison was corrected to the union of both sources before this record.
