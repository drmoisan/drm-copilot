# Regression: #723 loose exit-1 assertions removed ([P8-T6], AC-31 text half)

Timestamp: 2026-10-09T21-44
Command: git grep -n -F -e "Should -Match '(?m)^\s*exit 1\s*$'" -- tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: no output. None of the three loose `Should -Match '(?m)^\s*exit 1\s*$'` assertions remain; each was replaced by a count assertion plus a block-scoped `if (...) { ... ::error:: ... exit 1 ... }` match ([P8-T2] to [P8-T4]). The generic all-pwsh-steps `$exitsExplicitly` line (line 148) uses `-match`, not `Should -Match`, and is unchanged.

Acceptance (AC-31 text half): exit 1 and nothing printed. PASS.
