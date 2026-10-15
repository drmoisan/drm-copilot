# P7-T1 Back-Compat Hashes After the Change

Timestamp: 2026-09-30T10-59
Command: Get-ChildItem -LiteralPath tests/fixtures/orchestrator_state_blocked_reason_backcompat -File | ForEach-Object FullName | Get-FileHash -Algorithm SHA256; Get-FileHash -Algorithm SHA256 -LiteralPath tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json,extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-backcompat.test.ts,tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1; git diff --numstat 1101c89c9e97a82e1ff35d8ec08b640e9b5b2f77 HEAD -- tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py
EXIT_CODE: 0
Output Summary:
- Twelve SHA256 hashes recorded; all twelve equal the values in `backcompat-hashes-before.md` (nine fixtures, the expected file, and the TypeScript and PowerShell back-compat test files are unchanged since the capture commit).
- `git diff --numstat 1101c89c9e97a82e1ff35d8ec08b640e9b5b2f77 HEAD -- tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py` printed exactly one line: `91	0	tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py`. Removed-lines column is `0`: the Python file received additions only (P2-T4), and no back-compat line changed.

Execution route: PowerShell execution route (scratchpad `.sh` file that changes to the worktree root and calls `pwsh -NoProfile -Command`, run with `sh`) for the hash statements; `git diff` run directly. For rendering only, the two hash statements were wrapped in `& { ... }` and piped to a formatter that prints `Hash` and the repository-relative `Path` with `/` separators, as in P1-T12; the hashed inputs are unchanged. The capture SHA is taken from `backcompat-capture-commit.md`.

| SHA256 | Path | Equal to before |
|---|---|---|
| 6BD35E40F45BF0D61B3878910BFDD64C41524D30BE0F1410D6249D184D6B7EF9 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/absent.json` | yes |
| 81F47F927DD9381A1D963152E7B58628753EB627D3AE3F1D874D04475B7A38F4 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/delegate_contract_incomplete.json` | yes |
| 8291ED78508F5A6A9AC42F3A877E98F2018208E087F887576F8C70CE37922414 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/delegate_no_receipt.json` | yes |
| 03223306D06E22F7958074D74666BE708419FF02EBF978ABA02CF04739609B1F | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/delegation_launch_failed.json` | yes |
| A87D983C6226FFECADDF34EC4030EE337469B4144091EB8C691A56ED3F81FC12 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/none.json` | yes |
| 7EC97776B61458BFF695764006FE4D229C9475A1396CADB4CB968322FA7FE8E7 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/null.json` | yes |
| C21BE45BF8BB357B3179BD157069D4235F0EC0E800471A42A854B50A91C8B049 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/spawn_agent_unavailable.json` | yes |
| F5809097327EF537518996FBB51C62741A365B5DC7ACD5E7B8D74DCDA17DB103 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/user_requested_stop.json` | yes |
| 90E9F05C06A3F6033F97F4FB84FD9B999B24EB5FECC22AC32EEC240FF001DC24 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat/validator_failed.json` | yes |
| A3980139E197A5432B5C92C811311F83FCA013018D04A86777962B6C56F029A5 | `tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json` | yes |
| 05D2079497605F26CF117AE3BC41654FC4E18BADB6501D3F50B72C1B4E39E7F3 | `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-backcompat.test.ts` | yes |
| D14067B0F3DC1A1A1AD48086A80B5938DE890AFA0703E5F8F5F7792B7BE47FAE | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1` | yes |
