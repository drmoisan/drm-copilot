# Digest comparison ([P1-T1], repeated by [P1-T6] for a later-stamped DECISIONS)

Timestamp: 2026-11-20T12-28
Command: sh SCRATCH/issue-1016-p1t1r.sh (worktree root: npm --prefix packages/mcp-server ci; npm --prefix packages/mcp-server run build; node packages/mcp-server/out/mcp-server.js migrate-development-docs --workspace . --mode dry-run --decisions <OLD_FEATURE>/evidence/other/folder-rename-decisions.2026-11-20T12-24.json --report-dir <OLD_FEATURE>/evidence/other; git status --porcelain before and after); node SCRATCH/issue-1016-digest.cjs <FRESH_DRY_RUN> <DECISIONS> <folder-rename-decisions.2026-11-20T09-48.json>
EXIT_CODE: 0
Output Summary: TOOL rebuilt from the branch (packages/mcp-server/out/mcp-server.js, 1778554 bytes; ci exit 0, build exit 0). The dry run exited 0 and wrote FRESH_DRY_RUN = dev-docs-migration-dry-run.2026-11-20T12-28.json with its .md pair; the porcelain difference is exactly those two untracked reports. DECISIONS file: folder-rename-decisions.2026-11-20T12-24.json. source_digest: DECISIONS 2f33c96522d776b174bff9370652a8a676c6d03dedc2758570e7f6e87b936a75, FRESH_DRY_RUN 2f33c96522d776b174bff9370652a8a676c6d03dedc2758570e7f6e87b936a75: MATCH. Unmapped entries: 0. Retained production documentation: none (empty list). Summary with DECISIONS applied: 37 moves, 404 renames, 45 held items, 0 formatter errors, 0 collisions, 5055 files to rewrite with 43419 occurrences (4 files fewer than the 09-48 run, the four appended E-TEST globs), 32634 excluded files, 118 protected occurrences, 220 broken links, 0 untracked files, 7 kept folders, 0 open choices; resolved_root docs/features.

| Check | Value | Result |
| --- | --- | --- |
| DECISIONS file name | folder-rename-decisions.2026-11-20T12-24.json | n/a |
| source_digest (DECISIONS) | 2f33c96522d776b174bff9370652a8a676c6d03dedc2758570e7f6e87b936a75 | n/a |
| source_digest (FRESH_DRY_RUN) | 2f33c96522d776b174bff9370652a8a676c6d03dedc2758570e7f6e87b936a75 | MATCH |
| unmapped entries | 0 | PASS |
| retained documentation | [] | recorded |
