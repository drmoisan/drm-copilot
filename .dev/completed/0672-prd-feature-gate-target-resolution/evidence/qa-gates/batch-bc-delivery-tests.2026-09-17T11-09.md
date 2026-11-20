# Batch B/C Delivery Tests

Timestamp: 2026-09-17T11-09

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

Output Summary:

- 17 passed, 0 failed.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` — **PASSED**. This closes the intermediate parity window opened in Phase 0, during which `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` existed in the repository tree with no bundled mirror. `[P2-T2]` deferred this assertion here and `[P2-T3]` created the missing mirror.
- The other named delivery nodes also pass: `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_documented_exceptions_remain_absent_from_every_manifest`, and `test_poshqc_bundled_module_files_match_repo_root_sources`.
- A verbose re-run (`-v --no-header -p no:cacheprovider`) was used to read the node names; every one of the 17 collected nodes reports `PASSED`.

Pre-invocation `.claude/state` clearing (the **unfiltered** pipeline defined in `[P2-T1]`), recorded under that task's exit-code attribution:

- Removal command: `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName); Remove-Item -LiteralPath $_.FullName -Force }`
- Pre-removal file names: `.claude/state/powershell-batch-budget.worktree-agent-accbbbab931643b40-97dc4f8f.json` (recreated by the `Edit` writes in `[P2-T5]` through `[P2-T7]`, which the budget hook observes)
- Removal step exit: `REMOVE_OK=True`, wrapper exit code 0
- Verification command: `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`
- Post-removal verification count: **0** (`VERIFY_OK=True`), wrapper exit code 0

The unfiltered pipeline is required here rather than the filtered batch-budget one: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")` at lines 51-60 and excludes only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines 130-134, so it does not honour the `.gitignore` entry for `.claude/state/` at line 68 and would report `Repo file missing from bundle:` for any file found there. No production PowerShell write follows this removal inside the same batch.
