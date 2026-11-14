# Phase Gate P1 (P1-T8)

Timestamp: 2026-11-14T20-04
Command: stages 1-6 across the repository, loop pass 2 (pass 1 is recorded below)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: the unit stage fails only on the 26 named expected-fail rows of P1-T1 to P1-T4; every other stage and test passes. The Phase 0 baseline names no pre-existing failure.

## Loop pass 1 (2026-11-14T19-41 to 2026-11-14T19-57)

- Stage 1 format and stage 2 analyze: clean (see pass 2 commands).
- Stage 5 Pester gate (Invoke-PoshQCParallelTest, 8 workers, 665.71s): 27 failures. 26 were the expected-fail rows; one was not: `discovery guard (both hook surfaces) / AC-6 tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 calls the interception probe from inside an It` in tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1.
- Fix: the new NonAscii suite registers the epic-state baseline mocks (Register-EpicStateBaselineMock), and the existing discovery guard requires such a suite to call Invoke-EpicStateInterceptionProbe from inside an It, as enforce-owner-directive-pass-down.Tests.ps1 does. The row 'baseline mock interception probe' was added to the first Describe of the NonAscii suite. Confirmation run: launcher pester -TestPath over the NonAscii suite and the discovery guard suite at 2026-11-14T19-58: discovery guard suite 598 passed; NonAscii suite 20 passed, 1 failed (the expected contrast row). The loop restarted from stage 1.

## Loop pass 2

Stage 1 - format
- Command: pwsh -NoProfile -File SCRATCH/issue-1187-repostatic.ps1 (imports scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree> with a no-op -WriteFile seam, so no file is written; counts the 'Formatted:' and 'Already formatted:' logger lines)
- EXIT_CODE: 0
- Result: would-format=0, already-formatted=1753.

Stage 2 - analyze
- Command: same script, Invoke-PoshQCAnalyze -Root <worktree> with scripts/powershell/PoshQC/settings/pssa.settings.psd1
- EXIT_CODE: 0
- Result: PSScriptAnalyzer passed: no findings.

Stage 3 - type check: not applicable (PowerShell only; no Python or TypeScript file changed).

Stage 4 - architecture-boundary tests: not applicable (no dependency-cruiser or NetArchTest surface is touched).

Stage 5 - unit tests
- Pester command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (2026-11-14T20-07 to 2026-11-14T20-17; workers=8; wall-clock=650.87s)
- EXIT_CODE: 1 (shards 3, 4, 5 non-zero; no merged artifact; counts from per-shard JUnit)
- Counts: 26537 passed, 26 failed, 18 skipped (26581 tests).
- pytest command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (2026-11-14T20-18)
- EXIT_CODE: 0
- Counts: 16928 passed, 6 skipped, 0 failed (identical to the Phase 0 baseline).

Stage 6 - contract checks: the push-down contract tests (test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_pack_manifest_dependency_closure.py) ran inside the pytest stage and passed (no failure reported).

Expected failures (26, each confirmed failing, all named by P1-T1 to P1-T4):
- tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 (12): script tail / denies a payload without a tool name through the registry beside the script when run in process; Read-PreToolUseDispatchStandardInput (issue #1187) / decodes an em dash, decodes curly quotes, decodes a non-BMP character from UTF-8 bytes exactly, strips a leading UTF-8 byte order mark, maps an invalid byte to U+FFFD without throwing, disposes the stream it reads, opens the process standard input through the default stream seam without reading it; Invoke-PreToolUseDispatchEntryPoint non-ASCII output (issue #1187) / emits the decision with every character below U+0080 and restores the reason, writes the trace line with every character below U+0080 and restores the reason, emits the dependency-failure deny of the script tail with every character below U+0080, defaults ReadPayload to Read-ClaudeHookRawPayload with the UTF-8 reader.
- tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1 (12): Codex script tail / denies a payload without a tool name through the registry beside the script when run in process; Read-CodexPreToolUseDispatchStandardInput (issue #1187) / the same seven reader rows; Invoke-CodexPreToolUseDispatchEntryPoint non-ASCII output (issue #1187) / the three output rows and defaults ReadPayload to the Codex UTF-8 reader.
- tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 (1): PreToolUse dispatcher stdin reader parity (issue #1187) / defines the Claude and Codex stdin readers with equal bodies apart from the name.
- tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 (1): stdin decode contrast (issue #1187 AC-12) / denies the Latin1 decode and allows the UTF-8 reader decode of the same relay bytes.

Count observation: the Phase 0 baseline had 26522 tests and Phase 1 adds 61 rows (11 + 11 + 1 + 21 + 13 + 4), so 26583 were expected and 26581 ran. The per-suite counts of every changed suite match their task checks (Claude dispatcher 25, Codex dispatcher 24, Parity 92, NonAscii 21, OrchestratorStateOwnerDirectives 81, OrchestratorStateOwnerDirectiveDecision 42, stop-hook pass-down 55), so the difference of 2 is in an unchanged suite. The Phase 0 per-suite counts were overwritten by later runs, so the suite cannot be named here; this run's per-suite counts are saved in SCRATCH for comparison at the Phase 2 gate.
