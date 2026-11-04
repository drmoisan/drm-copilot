# Post-Integration-Merge Test Run (Issue 1033)

Timestamp: 2026-11-04T14-05
Command: Invoke-Pester (Pester 5, Run.Path = tests/scripts/claude-lib/docs, single process) from a SCRATCH launcher at merge commit 4bbba7c70
EXIT_CODE: 1
Output Summary:
- Merge of origin/epic/documentation-estate-tooling-integration (tip a94dea9a4, containing 1020, 1021, 1022, 1023) into the 1033 branch.
- Conflict: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json, resolved as the union of both append blocks with no duplicate entries.
- Total 1668, Passed 1666, Failed 2, Skipped 0.
- Failed: tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1, "Invoke-DocsInventoryCommand exits 0 with a dry-run snapshot, ..." expects the analyzer id list to be the five 1022 analyzers; the merged registry also carries the seven 1033 analyzers.
- Failed: tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1, "New-DocsInventorySnapshot over both corpora validates against surface-inventory-snapshot ..." pins the same five-entry id:method:version list.
- Both failures are semantic merge interactions (1022 tests pin the full registry set; 1033 adds rows). Element-level assertions in the same tests passed.

Command: poetry run pytest -q -n auto tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py
EXIT_CODE: 0
Output Summary: 34 passed.
