Timestamp: 2026-07-19T06-04
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_selection.py -k always_includes_core -v`
EXIT_CODE: 0
Output Summary: 1 passed, 15 deselected in 0.05s.
`test_compute_published_paths_always_includes_core` confirms the always-union-`core` mechanism
remains intact: any newly registered `core.json` path entry (none were added by this feature,
per the Phase 1 zero-count inventories) would be reachable from every scoped `--packs` selection.
