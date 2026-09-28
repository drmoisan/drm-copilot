# Batch E Delivery Tests

Timestamp: 2026-09-17T11-43

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`

EXIT_CODE: 0

Output Summary:

- 17 passed, 0 failed.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` — **PASSED**. This closes the second intermediate parity window, which opened when Phase 4 changed the repository hook and its sibling before batch E re-mirrored them.
- The other named delivery nodes also pass: `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_documented_exceptions_remain_absent_from_every_manifest`, and `test_poshqc_bundled_module_files_match_repo_root_sources`. A verbose run (`-v --no-header -p no:cacheprovider`) was used to read the node names; all 17 collected nodes report `PASSED`.

Text identity of the two re-mirrored files, verified directly by `[P5-T2]` and `[P5-T3]`:

| file pair | `Compare-Object` difference objects | SHA-256 |
| --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` ↔ its bundled counterpart | 0 | `FDAAF5C9A215BEE12EA99DFF0A32819AC7DAE688B2A779008EE224B68A60139D` |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` ↔ its bundled counterpart | 0 | `EF5C648660FDC03A784F38D0760FAFBD9A57A9D264125B8D84F56E964B4CFB24` |

An equal line count alone is not accepted as evidence of text identity; both pairs are verified by a zero-difference `Compare-Object` and by matching content hashes.

Pre-invocation `.claude/state` clearing (the **unfiltered** pipeline defined in `[P2-T1]`), recorded under that task's exit-code attribution:

- Removal command: `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName); Remove-Item -LiteralPath $_.FullName -Force }`
- Pre-removal file names: none (the state file had already been removed by the `[P5-T1]` boundary, and the batch-E mirror writes were made with `Copy-Item`, which the `Write|Edit` PreToolUse matcher does not observe)
- Removal step exit: `REMOVE_OK=True`, wrapper exit code 0
- Verification command: `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`
- Post-removal verification count: **0** (`VERIFY_OK=True`), wrapper exit code 0

The unfiltered pipeline is required here rather than the filtered one because `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")` at lines 51-60 and excludes only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines 130-134, so it does not honour the `.gitignore` entry for `.claude/state/` at line 68. No production PowerShell write follows this removal inside the same batch.
