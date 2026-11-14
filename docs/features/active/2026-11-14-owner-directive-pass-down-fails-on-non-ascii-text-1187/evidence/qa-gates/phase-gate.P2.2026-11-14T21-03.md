# Phase Gate P2 (P2-T4)

Timestamp: 2026-11-14T20-35
Command: stages 1-6 across the repository, one clean pass
EXIT_CODE: 0
Output Summary: every stage passes in one pass; zero test failures (the Phase 0 baseline names no pre-existing failure); every expected-fail row of Phase 1 now passes.

Stage 1 - format
- Command: pwsh -NoProfile -File SCRATCH/issue-1187-repostatic.ps1 (Invoke-PoshQCFormat -Root <worktree> with a no-op -WriteFile seam; counts 'Formatted:' and 'Already formatted:' logger lines)
- EXIT_CODE: 0
- Result: would-format=0, already-formatted=1753.

Stage 2 - analyze
- Command: same script, Invoke-PoshQCAnalyze -Root <worktree> with scripts/powershell/PoshQC/settings/pssa.settings.psd1
- EXIT_CODE: 0
- Result: PSScriptAnalyzer passed: no findings.

Stage 3 - type check: not applicable (PowerShell only).

Stage 4 - architecture-boundary tests: not applicable (no boundary surface touched).

Stage 5 - unit tests
- Pester command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (2026-11-14T20-37 to 2026-11-14T20-49; workers=8; wall-clock=678.01s)
- EXIT_CODE: 0
- Counts (merged artifacts/pester/pester-junit.xml): tests=26585, passed=26567, failed=0, errors=0, skipped=18.
- Coverage (artifacts/pester/powershell-coverage.xml): repo-wide 43696/45535 = 95.96%; .claude/hooks/invoke-pretooluse-dispatch.ps1 42/42 = 100.00%; .codex/hooks/invoke-pretooluse-dispatch.ps1 40/40 = 100.00%.
- pytest command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest
- First attempt 2026-11-14T20-49: EXIT_CODE 75, TEST_EXECUTION_QUEUE_TIMEOUT (lock held by a Pester suite of another worktree); a queue timeout, not a failure.
- Re-run 2026-11-14T21-02: EXIT_CODE 0; 16928 passed, 6 skipped, 0 failed (identical to the Phase 0 baseline).

Stage 6 - contract checks: the three push-down contract files ran inside the pytest stage and passed; the P2-T3 task check also ran them alone (41 passed).

Formerly failing rows, now passing (26):
- tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 (12): script tail / denies a payload without a tool name through the registry beside the script when run in process; Read-PreToolUseDispatchStandardInput (issue #1187) / decodes an em dash, decodes curly quotes, decodes a non-BMP character from UTF-8 bytes exactly, strips a leading UTF-8 byte order mark, maps an invalid byte to U+FFFD without throwing, disposes the stream it reads, opens the process standard input through the default stream seam without reading it; Invoke-PreToolUseDispatchEntryPoint non-ASCII output (issue #1187) / emits the decision with every character below U+0080 and restores the reason, writes the trace line with every character below U+0080 and restores the reason, emits the dependency-failure deny of the script tail with every character below U+0080, defaults ReadPayload to Read-ClaudeHookRawPayload with the UTF-8 reader. All pass.
- tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1 (12): the Codex script tail row, the seven Read-CodexPreToolUseDispatchStandardInput (issue #1187) rows, and the four Invoke-CodexPreToolUseDispatchEntryPoint non-ASCII output (issue #1187) rows. All pass.
- tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 (1): defines the Claude and Codex stdin readers with equal bodies apart from the name. Passes.
- tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 (1): denies the Latin1 decode and allows the UTF-8 reader decode of the same relay bytes. Passes.

Count reconciliation with the Phase 1 gate: the per-suite test counts of all 801 suites are identical between the Phase 1 gate shard JUnit and this run. The Phase 1 total of 26581 was a count of testcase nodes across failed-run shard files, while 26585 here is the testsuite total attribute of the merged JUnit; no suite lost or gained a row between the two gates. Against the Phase 0 baseline (26522 by the same merged attribute), this run has 63 more tests: the 61 rows Phase 1 adds and 2 rows from existing per-suite guard enumerations that now include the new NonAscii suite file (for example the discovery guard row 'AC-6 <Path> calls the interception probe from inside an It').

Verification (appended 2026-11-14T21-04): the merged JUnit holds exactly two rows that name the new suite file, both in enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: discovery guard (both hook surfaces) / AC-4 tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 complies with the baseline isolation form for every closure seam; and / AC-6 tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 calls the interception probe from inside an It. Both pass.
