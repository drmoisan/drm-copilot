# Dev Docs Migration Dry Run Command ([P3-T2])

Timestamp: 2026-11-20T07-41
Command: sh SCRATCH/issue-1016-dryrun.sh, which runs from the worktree root: git status --porcelain (before); node packages/mcp-server/out/mcp-server.js migrate-development-docs --workspace . --mode dry-run --report-dir docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/evidence/other; git status --porcelain (after). No decision file.
EXIT_CODE: 0
Output Summary: the branch build wrote `dev-docs-migration-dry-run.2026-11-20T07-40.md` and `dev-docs-migration-dry-run.2026-11-20T07-40.json` under `evidence/other/`; no move, rename or flip occurred (dry-run mode makes no `git mv` call and writes only the two reports). Run time about 36 seconds.

## Porcelain captures

Before:

```text
 M docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T18-59.md
?? docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/evidence/other/mcp-server-branch-build.2026-11-20T07-39.md
```

After:

```text
 M docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T18-59.md
?? docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/evidence/other/dev-docs-migration-dry-run.2026-11-20T07-40.json
?? docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/evidence/other/dev-docs-migration-dry-run.2026-11-20T07-40.md
?? docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/evidence/other/mcp-server-branch-build.2026-11-20T07-39.md
```

The only added paths are the two reports, both under `<FEATURE>/evidence/other/`; the two entries present before the run are this executor's plan check-off and the [P3-T1] artifact.

## Newest JSON (`dev-docs-migration-dry-run.2026-11-20T07-40.json`) checks

- `source_digest`: string, `2f33c96522d776b174bff9370652a8a676c6d03dedc2758570e7f6e87b936a75`
- `decision_skeleton`: object (45 decision entries with `action: null`, every global key `null`)
- `retained_documentation`: list, 0 entries (this repository has no production documentation under `docs/` outside the mapped trees)
- `held_items`: 45, each with `source`, `reason` and `candidate`
- `resolved_root`: `docs/features`

## Category counts

| Category | Count |
| --- | --- |
| Planned moves | 37 |
| Folder renames (mechanical) | 371 |
| Held items | 45 (33 non-matching, 12 multi-folder issue) |
| Formatter errors | 0 |
| Collisions and conflicts | 0 |
| Folders kept without a recoverable issue number | 7 |
| Unmapped entries under docs/features/ | 0 |
| Retained production documentation | 0 |
| Files to rewrite outside the moved trees | 771 |
| In-tree candidates, references-and-links | 10604 |
| In-tree candidates, links-only | 53 |
| Total files to rewrite (summary) / occurrences | 11375 / 145520 |
| Excluded files | 649 |
| Files with protected occurrences / protected occurrences | 187 files in the summary count of occurrences (`protected_occurrences: 187`) |
| Mapping-record candidates | 156 |
| Broken relative links | 296 |
| Files with backslash occurrences | 76 |
| Untracked and ignored files | 1 |
| Skipped files (NUL or invalid UTF-8) | 11 |
| OQ-1 alternative (`.dev/templates`) entry moves | 3 |
| Open global choices | 3 (`discovery_templates_target`, `in_tree_rewrite_scope`, `commit_split`) |

## Correction (appended 2026-11-20T07-41)

The protected-occurrences row above reads ambiguously. The value 187 is the summary `protected_occurrences`, the total number of protected `Write(`/`Edit(` occurrences across all files; the per-file list is `protected_occurrences` in the JSON report.
