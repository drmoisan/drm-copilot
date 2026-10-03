# P6-T5 Python contract and parity suites (AC-24)

Timestamp: 2026-10-03T10-13
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py -q; $LASTEXITCODE; then the .claude/hooks vs Claude bundle Get-FileHash loop
EXIT_CODE: 0
Output Summary:
- pytest summary: 32 passed in 0.34s; exit 0 (ISSUE-510-BRANCH satisfied by the exit-0 case)
- hook-command-invocation.ps1 EQUAL=True
- hook-command-raw-invocation.ps1 EQUAL=True
- Python new-code coverage: N/A - no production file of this language changes
- Result: PASS
