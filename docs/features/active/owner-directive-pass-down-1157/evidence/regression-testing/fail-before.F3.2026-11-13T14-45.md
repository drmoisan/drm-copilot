# Fail-before evidence, finding F3 (issue #1157, cycle 1, P1-T1)

Timestamp: 2026-11-13T14-45
Command: sh SCRATCH/issue-1157-taskcheck.sh -Path tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1 (pwsh 7, New-PesterConfiguration with Run.Path set to the suite and Run.PassThru; the launcher exits 1 when any test, block, or container fails); run against the unmodified .claude/hooks/enforce-owner-directive-pass-down.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- 83 tests: 81 passed, 2 failed, 0 skipped.
- Failing cases (the two new rows): "ledger guard (AC-27).denies a subagent Write to the case-variant ledger path Artifacts/Orchestration/Owner-Directives.jsonl" and "... ARTIFACTS/ORCHESTRATION/OWNER-DIRECTIVES.JSONL"; each "Expected like wildcard 'OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_LEDGER_WRITE_DENIED: *' to match <empty>": the ordinal suffix comparison misses the case-variant path and the hook emits nothing.
- No other case failed.
