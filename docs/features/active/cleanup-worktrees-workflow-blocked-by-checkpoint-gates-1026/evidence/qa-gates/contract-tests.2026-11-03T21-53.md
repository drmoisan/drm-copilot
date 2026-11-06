# Final Contract Tests (P2-T2)

Timestamp: 2026-11-03T21-53
Command: sh SCRATCH/issue-1026-p2t2.sh (poetry run pytest --strict-markers --strict-config -q --junitxml=SCRATCH/issue-1026-pytest-final.xml over the ten CONTRACT_MODULES pytest files, serial; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; PowerShell 7 Invoke-Pester over tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1)
EXIT_CODE: 0
Output Summary: pytest exit 0, 175 passed, 0 failed (JUnit tests=175 failures=0 errors=0), including test_brief_copies_are_byte_identical and test_brief_has_no_g11_or_g12_findings as passing testcases; generator --check exit 0; hook-cleanup-context.Parity.Tests.ps1 total 4, passed 4, failed 0.

- Pytest exit code: 0
- Generator `--check` exit code: 0
- Parity suite: JUnit tests=4 failures=0 errors=0
