# Phase 0 AC-6.1 Parity Suites Baseline (Issue #697)

## Block 1

Timestamp: 2026-09-25T20-42
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts" "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity" "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_every_selected_pack_generates_identical_handoff_runtime_files" "tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources" -q
EXIT_CODE: 0
Output Summary: `4 passed`

## Block 2

Timestamp: 2026-09-25T20-42
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 10, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`; includes `[+] includes every epic runtime surface in the core pack manifest` and `[+] keeps root and tracked bundle runtime copies byte-identical`.

## Block 3

Timestamp: 2026-09-25T20-42
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 5, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`; includes `[+] mirrors every codex-routing module byte-identically into the bundle`.
