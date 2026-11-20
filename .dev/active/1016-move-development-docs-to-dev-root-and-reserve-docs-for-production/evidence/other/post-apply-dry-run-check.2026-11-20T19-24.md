# Post-Apply Dry-Run Check — remediation cycle 1 [P1-T3] (ruling R4, finding F1)

Timestamp: 2026-11-20T19-24
Command: sh SCRATCH/issue-1016-c1p1t3.sh (npm --prefix packages/mcp-server run build; node SCRATCH/issue-1016-c1p1t3.cjs derive; porcelain capture; node packages/mcp-server/out/mcp-server.js migrate-development-docs --workspace . --mode dry-run --decisions SCRATCH/post-apply/issue-1016-post-apply-decisions.json --report-dir <FEATURE>/evidence/other; porcelain capture; node SCRATCH/issue-1016-c1p1t3.cjs compare <new report json>)
EXIT_CODE: 0
Output Summary: Branch build of packages/mcp-server/out/mcp-server.js (exit 0) at head e49111fac, which carries the F1 fix. The post-apply dry run wrote dev-docs-migration-dry-run.2026-11-20T19-23.json and .md (exit 0). Values read from the new report JSON:
Moves: 0
Renames: 0
Refusals: none
Outside rewrites: 0
In-tree links-only candidates: 0
Non-candidates: `rewrites_in_tree_references_and_links` lists 4572 files (37616 reference occurrences, 0 links), all under `.dev/`. Under the decided A3 in-tree scope `links-only` they are not rewrite candidates, and with the F1 fix the tool now classifies them as in-tree, so the scope governs them (an apply-mode plan writes nothing for a file whose `links` is 0).
Excluded: `excluded_files` lists 32704 files, including all four Stay-row files.

## Derived decision file

Derivation as recorded in post-apply-dry-run-check.2026-11-20T16-11.md: start from folder-rename-decisions.2026-11-20T12-24.json, empty `decisions`, map each of the 343 `rewrite_exclusions` globs through the mapping table and the rename map (9 globs changed), keep `global_decisions` (in_tree_rewrite_scope `links-only`). Four Stay rows are appended (347 globs):

| Stay row | Reason | In `excluded_files` |
| --- | --- | --- |
| `tests/discovery_runtime/initialization_test_support.py` | A5: `docs/discovery/templates/` is the canonical package resource key | yes |
| `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` | A5: same resource key | yes |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CleanupTargetUnresolved.Tests.ps1` | added after the 2026-11-20T16-11 check; holds synthetic cleanup-leg `docs/` command literals, the same case as the excluded `enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` row | yes |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup-target-unresolved.Tests.ps1` | Codex twin of the row above; same case as the excluded `enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` row | yes |

## Tree checks

- `git -C <worktree> diff HEAD -- <FEATURE>/evidence/other/post-apply-dry-run-check.2026-11-20T16-11.md` is empty (0 lines); the earlier artifact is unchanged.
- Compared with the porcelain capture taken immediately before the dry run, the only added entries are `dev-docs-migration-dry-run.2026-11-20T19-23.json` and `dev-docs-migration-dry-run.2026-11-20T19-23.md`; this check file is the third added entry. All three are committed with this task.
