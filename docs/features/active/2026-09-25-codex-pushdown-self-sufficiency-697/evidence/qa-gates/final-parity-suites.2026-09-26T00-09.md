# Final AC-6.1 Parity Suites (Issue #697)

## Block 1

Timestamp: 2026-09-26T00-09
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts" "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity" "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_every_selected_pack_generates_identical_handoff_runtime_files" "tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources" -q
EXIT_CODE: 0
Output Summary: `4 passed`

## Block 2

Timestamp: 2026-09-26T00-09
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 10, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`; listed as passed: `keeps root and tracked bundle runtime copies byte-identical`, `includes every epic runtime surface in the core pack manifest`.

## Block 3

Timestamp: 2026-09-26T00-09
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 5, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`; listed as passed: `mirrors every codex-routing module byte-identically into the bundle`.

The four named Pester `It` blocks of AC-6.1 (`keeps root and tracked bundle runtime copies byte-identical`, `includes every epic runtime surface in the core pack manifest`, `mirrors every codex-routing module byte-identically into the bundle`, and the AC-6.1 pytest parity nodes above) are all passed.
