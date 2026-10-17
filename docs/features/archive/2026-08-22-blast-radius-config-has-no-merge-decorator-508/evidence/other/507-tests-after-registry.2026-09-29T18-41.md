# #507 Tests After Registry Extension (P4-T3)

Timestamp: 2026-09-29T18-41
Command: poetry run pytest -rA tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive.py tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core.py tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core_guard.py tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_manifests.py tests/scripts/dev_tools/test_push_down_claude_config_carriage.py tests/scripts/dev_tools/test_push_down_claude_destination_writes.py tests/scripts/dev_tools/test_push_down_claude_routing_merge.py
Command actually executed: the same command with `-p no:cacheprovider` appended.
Expansion note: the trailing path list is every `tests/scripts/dev_tools/test_*.py` path with a non-`D` status in evidence/other/507-change-set.2026-09-29T18-41.md, in that artifact's order, with PARITY_TEST_FILE and test_push_down_claude_customizations.py not repeated.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Result line: `2 failed, 138 passed in 1.23s`
- Failing node IDs (verbatim):
  - tests/scripts/dev_tools/test_push_down_claude_parity.py::test_merged_relative_paths_match_typescript
    - `AssertionError: extensions/drm-copilot/src/lib/push-down/claude-customizations.ts merged paths: {'config/blast-radius.json', 'config/orchestration-routing.json'}` / `assert 2 == 1` (the TypeScript/Python set comparison itself passed; the failing line pins a merged-path count of 1).
  - tests/scripts/dev_tools/test_push_down_claude_destination_writes.py::test_merged_relative_paths_initial_registry_is_routing_only
    - `Left contains 1 more item: {'config/blast-radius.json': <function merge_blast_radius_overlay ...>}` (asserts the Python registry is routing-only).
- Both failures are in the permitted class (registry routing-only, or merged-path count exactly 1). Their expected values are updated in P5-T5; neither is deleted.
- Routing behavior preserved: every routing-merge, destination-writes, config-carriage, and routing-merge fixture parity case passed, including the absent-destination case.

Pre-acceptance run (superseded): a first run also failed `tests/scripts/dev_tools/test_push_down_claude_destination_writes.py::test_module_docstring_names_downstream_seams` because the docstring sentence "#508 extends `MERGED_RELATIVE_PATHS` by registering `config/blast-radius.json`." had been reworded. The sentence was restored verbatim in scripts/dev_tools/push_down_claude_destination_writes.py (the test was not changed), and the run above followed.

Additional checks:
- `git diff origin/epic/push-down-payload-correctness-integration -- scripts/dev_tools/push_down_claude_destination_writes.py | grep -n -e "^-[[:space:]]*class " -e "^-[[:space:]]*def "`: exit 1 (no removed class or def line).
- Same diff grepped for added `type: ignore`, `noqa`, `pyright: ignore`: exit 1 (no new suppression).
- `wc -l scripts/dev_tools/push_down_claude_destination_writes.py`: 399 (<= 500).
- black: unchanged; ruff: All checks passed!; pyright on the file: 0 errors.
- Registry case applied: REGISTRY_ENTRY_TYPE NONE and REGISTRY_MAPPING `MERGED_RELATIVE_PATHS` not NONE, so (a) adapter `merge_blast_radius_overlay` added with key `"config/blast-radius.json"`, (b) `INPUT_RELATIVE_PATHS` added and `DestinationMergeFileSystem.write_text` reads `INPUT_RELATIVE_PATHS.get(rel, rel)` (class name, constructor, `merges` parameter unchanged), (c) frozen dataclass `DestinationMerge` and `MERGED_PATHS` view added.
