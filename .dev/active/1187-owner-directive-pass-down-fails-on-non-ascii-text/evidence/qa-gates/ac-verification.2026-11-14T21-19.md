# Acceptance Criteria Verification (P3-T4)

Timestamp: 2026-11-14T21-19
Command: (1) awk 'END{print NR}' over every changed and new non-docs file; (2) MB=$(git merge-base origin/main HEAD); git diff --name-only $MB HEAD, with git status --porcelain as companion; (3) git diff $MB HEAD -- tests filtered to added lines, searched with grep -F for each forbidden token, and grep -oP '[^\x00-\x7F]' over every changed test file; (4) SCRATCH/issue-1187-help.ps1: [Parser]::ParseFile of each canonical dispatcher and GetHelpContent(), searched for the tokens UTF-8, ASCII, and per-process
EXIT_CODE: 0
Output Summary: every check below passes; AC-1 to AC-19 are verified, AC-20's local part is verified and its CI part is pending at S9.

## Check results

1. Logical line counts (AC-17; every file below 500):
   - .claude/hooks/invoke-pretooluse-dispatch.ps1 160; its bundle copy 160
   - .codex/hooks/invoke-pretooluse-dispatch.ps1 147; its bundle copy 147
   - tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 246
   - tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1 237
   - tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 319
   - tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1 198 (new)
   - tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1 423
   - tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1 197
   - tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1 362
2. Branch scope against the merge base of origin/main and HEAD (AC-2, AC-18, D-4): the name list holds the four dispatcher copies, the seven test files above, the promoted potential record, and this feature folder; git status --porcelain is empty outside the feature folder. No copy of execution-environment/SKILL.md, no file under .claude/lib/ (so .claude/lib/hook-payload/HookPayload.psm1 is unchanged), and no stop-hook or pass-down hook production file is in the list (the only name matching validate-orchestrator-output is the test suite tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1).
3. Test hygiene (AC-13): added test lines contain 0 'SetIn(', 0 'InputEncoding =', 0 'OutputEncoding =', 0 'GetTempFileName'; every changed test file has 0 characters above U+007F. Every MemoryStream a row creates is disposed by the reader under test (the 'disposes the stream it reads' rows assert CanRead is false), and the default-seam rows dispose the opened stream in finally.
4. Help tokens (AC-19): .claude dispatcher help: UTF-8=True, ASCII=True, per-process=True; .codex dispatcher help: UTF-8=True, ASCII=True; both parse with 0 errors.

## AC to evidence map

| AC | Status | Evidence |
|---|---|---|
| AC-1 | verified | P1-T1 reader rows fail before (evidence/regression-testing/fail-before.2026-11-14T19-40.md) and pass after (evidence/qa-gates/phase-gate.P2.2026-11-14T21-03.md, evidence/qa-gates/final-qc-pester.2026-11-14T21-17.md) |
| AC-2 | verified | row 'defaults ReadPayload to Read-ClaudeHookRawPayload with the UTF-8 reader' and the updated script-tail row pass (final-qc-pester); check 2 above |
| AC-3 | verified | Codex reader rows and 'defaults ReadPayload to the Codex UTF-8 reader' fail before and pass after (fail-before, final-qc-pester) |
| AC-4 | verified | 'defines the Claude and Codex stdin readers with equal bodies apart from the name' fails before and passes after |
| AC-5 | verified | the three output rows per dispatcher fail before (raw non-ASCII) and pass after |
| AC-6 | verified | NonAscii suite relay rows (evidence/other/task-check.P1-T4.2026-11-14T19-31.md; final-qc-pester) |
| AC-7 | verified | NonAscii suite ledger rows (same evidence) |
| AC-8 | verified | NonAscii decision-file rows and OrchestratorStateOwnerDirectiveDecision rows (evidence/other/task-check.P1-T5.2026-11-14T19-34.md); no production file reads decision-file content (check 2) |
| AC-9 | verified | stop-hook rows (evidence/other/task-check.P1-T6.2026-11-14T19-37.md); no stop-hook file changed (check 2) |
| AC-10 | verified | stop-hook ledger rows (same evidence) |
| AC-11 | verified | B5 rows (task-check.P1-T5); .claude/lib unchanged (check 2) |
| AC-12 | verified | contrast row fails before and passes after; fail-before run recorded under evidence/regression-testing/ |
| AC-13 | verified | check 3 above |
| AC-14 | verified | bundle hashes equal (evidence/other/task-check.P2-T3.2026-11-14T20-34.md); the three contract files pass (task-check.P2-T3; evidence/qa-gates/final-qc-pytest.2026-11-14T21-18.md) |
| AC-15 | verified | final Pester gate 0 failures over every listed suite (final-qc-pester); assertion text of existing rows unchanged apart from the two script-tail rows the plan updates |
| AC-16 | verified | both dispatchers 100.00% line coverage in the final gate (final-qc-pester) |
| AC-17 | verified | check 1 above |
| AC-18 | verified | check 2 above |
| AC-19 | verified | check 4 above |
| AC-20 | local part verified; CI part pending | final static loop (evidence/qa-gates/final-qc-static-powershell.2026-11-14T21-05.md), final Pester gate, and final pytest gate pass; CI on the PR head is checked by the orchestrator at S9. codex-pretooluse-integration.Tests.ps1 is integration-lane and runs in CI only (evidence/other/deviation-integration-lane.2026-11-14T20-32.md) |
