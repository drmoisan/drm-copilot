# Post-Apply Dry-Run Check [P4-T3] (ruling R4)

Timestamp: 2026-11-20T16-11
Command: sh SCRATCH/issue-1016-p4t3.sh (node SCRATCH/issue-1016-p4t3.cjs derive: SCRATCH/post-apply/issue-1016-post-apply-decisions.json from the moved DECISIONS folder-rename-decisions.2026-11-20T12-24.json with decisions empty and each of the 343 rewrite_exclusions globs mapped through the spec mapping table, longest prefix first, then RENAME_MAP (9 globs changed), plus a copy of FRESH_DRY_RUN dev-docs-migration-dry-run.2026-11-20T12-28.json beside it; node packages/mcp-server/out/mcp-server.js migrate-development-docs --workspace . --mode dry-run --decisions SCRATCH/post-apply/issue-1016-post-apply-decisions.json --report-dir <FEATURE>/evidence/other; node SCRATCH/issue-1016-p4t3.cjs compare <new report>)
EXIT_CODE: 0
Output Summary: The post-apply dry run (dev-docs-migration-dry-run.2026-11-20T16-11.json and .md) reports 0 moves, 0 renames, 0 refusals and 0 link rewrite candidates; the protected-occurrence count is unchanged (118 before, 118 after); 0 links are broken by the move (220 broken before, mapped through RENAME_MAP; 109 after, every one of them in the mapped pre-apply set; 111 pre-existing broken links now resolve). Rewrite candidates under links-only outside the mapped exclusions: 0 (decision D-P4T3-1 below for the 4572 reference-text entries the report lists).

## Counts

| Item | FRESH_DRY_RUN (pre-apply) | Post-apply | Result |
| --- | --- | --- | --- |
| Moves | 37 | 0 | PASS |
| Renames | 404 | 0 | PASS |
| Refusals | none | none | PASS |
| Link rewrite candidates (`links` > 0) | n/a | 0 | PASS |
| In-tree candidates (`links-only`, `references-and-links`) | n/a | 0, 0 | PASS |
| Protected occurrences | 118 | 118 | PASS |
| Broken links | 220 | 109 | PASS: 0 new by the move |
| Held items | 45 | 12 | the 12 `keep` folders of DECISIONS, still not issue-first, reported as held because the derived file carries no decisions; none is renamed |
| Retained production documentation | 0 | 1 (`docs/README.md`) | created by the apply |

## Decision D-P4T3-1 (autonomous, OD-1 and OD-4)

The report lists 4572 files under `rewrites_outside_moved_trees`, all with `links` 0:

- 4570 files under `.dev/` with 37610 reference occurrences. These are records inside the moved trees whose prefix text the decided in-tree scope `links-only` (A3, `DECIDED_VALUES`) leaves unchanged; after the apply no move is pending, so the tool classifies them as outside moved trees. They carry no link candidate, so under `links-only` none is a rewrite candidate.
- `tests/discovery_runtime/initialization_test_support.py` (2 references) and `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` (1 reference): the literal `docs/discovery/templates/` is the canonical package resource key, which A5 keeps unchanged ([P3-T7] reads the key from `.dev/discovery/templates/`). Rewriting the key would change the staged member keys and `resource-manifest.json`, which A5 forbids.

Options: (a) treat the 4572 entries as open candidates and stop, (b) rewrite them, which contradicts A3 and A5, (c) record them as outside the links-only candidate set with the reasons above. Selected (c). The condition the task asserts, zero rewrite candidates under links-only outside the mapped exclusions, holds with 0 link candidates.
