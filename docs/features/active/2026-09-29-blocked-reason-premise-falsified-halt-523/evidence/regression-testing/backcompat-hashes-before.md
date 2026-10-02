# Back-Compat Capture Hashes (P1-T12)

Timestamp: 2026-09-30T15-01
Command: Get-ChildItem -LiteralPath tests/fixtures/orchestrator_state_blocked_reason_backcompat -File | ForEach-Object FullName | Get-FileHash -Algorithm SHA256; Get-FileHash -Algorithm SHA256 -LiteralPath tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json,extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-backcompat.test.ts,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1
EXIT_CODE: 0
Output Summary: Twelve SHA256 hashes recorded: nine fixtures, the expected file, and the TypeScript and PowerShell back-compat test files. The Python back-compat test file is excluded by design (P7-T1 checks it with an additive-only diff).

Execution route: PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command`, run with `sh`). For rendering only, the two statements were wrapped in `& { ... }` and piped to a formatter that prints `Hash` and the repository-relative `Path` with `/` separators; the hashed inputs are unchanged. All twelve files carry `eol: lf` per `git check-attr` and are LF on disk.

| SHA256 | Path |
|---|---|
| 6BD35E40F45BF0D61B3878910BFDD64C41524D30BE0F1410D6249D184D6B7EF9 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/absent.json` |
| 81F47F927DD9381A1D963152E7B58628753EB627D3AE3F1D874D04475B7A38F4 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/delegate_contract_incomplete.json` |
| 8291ED78508F5A6A9AC42F3A877E98F2018208E087F887576F8C70CE37922414 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/delegate_no_receipt.json` |
| 03223306D06E22F7958074D74666BE708419FF02EBF978ABA02CF04739609B1F | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/delegation_launch_failed.json` |
| A87D983C6226FFECADDF34EC4030EE337469B4144091EB8C691A56ED3F81FC12 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/none.json` |
| 7EC97776B61458BFF695764006FE4D229C9475A1396CADB4CB968322FA7FE8E7 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/null.json` |
| C21BE45BF8BB357B3179BD157069D4235F0EC0E800471A42A854B50A91C8B049 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/spawn_agent_unavailable.json` |
| F5809097327EF537518996FBB51C62741A365B5DC7ACD5E7B8D74DCDA17DB103 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/user_requested_stop.json` |
| 90E9F05C06A3F6033F97F4FB84FD9B999B24EB5FECC22AC32EEC240FF001DC24 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/validator_failed.json` |
| A3980139E197A5432B5C92C811311F83FCA013018D04A86777962B6C56F029A5 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json` |
| 05D2079497605F26CF117AE3BC41654FC4E18BADB6501D3F50B72C1B4E39E7F3 | `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-backcompat.test.ts` |
| D14067B0F3DC1A1A1AD48086A80B5938DE890AFA0703E5F8F5F7792B7BE47FAE | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1` |
