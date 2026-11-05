# Final QA: Mirror Contracts (P6-T10)

Timestamp: 2026-11-04T04-19
Command: poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q ; git hash-object scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1
EXIT_CODE: 0
Output Summary:
- Pytest summary line: `24 passed in 0.50s` (no failed or error count).
- git hash-object, source: f3723438e1c3f69451c670a465c0ca0f2439b3b1
- git hash-object, bundle mirror: f3723438e1c3f69451c670a465c0ca0f2439b3b1 (equal; AC6, AC10)
