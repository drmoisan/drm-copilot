# Final QC — Delivery Tests

Timestamp: 2026-09-17T11-59

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

Output Summary:

- **17 passed, 0 failed** (`17 passed in 0.17s`)
- The three named delivery nodes pass: `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_claude_files_are_listed_in_some_pack_manifest`, and `test_poshqc_bundled_module_files_match_repo_root_sources` (node names read from the verbose run recorded in `batch-e-delivery-tests.2026-09-17T11-43.md`; the file set is unchanged since).

Pre-invocation `.claude/state` clearing (the **unfiltered** pipeline defined in `[P2-T1]`), recorded under that task's exit-code attribution:

- Removal command: `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName); Remove-Item -LiteralPath $_.FullName -Force }`
- Pre-removal file names: `.claude/state/powershell-batch-budget.worktree-agent-accbbbab931643b40-97dc4f8f.json`
- Removal step exit: `REMOVE_OK=True`, wrapper exit code 0
- Verification command: `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`
- Post-removal verification count: **0** (`VERIFY_OK=True`), wrapper exit code 0

The removal is required rather than optional: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")` at lines 51-60 and excludes only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines 130-134, so it does not honour the `.gitignore` entry for `.claude/state/` at line 68 and would report `Repo file missing from bundle:` for any file it found there. No production PowerShell write follows this removal.

This is step 4 of pass 2 of the `[P6-T1]` through `[P6-T4]` loop, and it completed with no failure and no file change.
