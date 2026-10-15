# Claude Bundle Contract Suites (#769, P3-T5)

Timestamp: 2026-09-29T14-39
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 16 passed
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
Assertion message: "Repo file missing from bundle: .claude\state\current-session-id"
No output line contains "Bundle content differs from repo for:".
KL-510: STATE-ONLY
Every other node PASSED.

Phase 3 companion checks:
- P3-T1: psd1-parse printed `PSD1-OK file=scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; git grep -c for `enforce-powershell-batch-budget-route.ps1` printed `...pester.runsettings.psd1:1`.
- P3-T2: pair-hashes over the runsettings pair printed `PAIR-SUMMARY pairs=1 unequal=0`.
- P3-T3: json-parse printed `JSON-OK file=extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json`; git grep -c printed `...powershell.json:1`.
- P3-T4: pair-hashes over CHOOK and CROUTE pairs printed `PAIR-SUMMARY pairs=2 unequal=0`.
