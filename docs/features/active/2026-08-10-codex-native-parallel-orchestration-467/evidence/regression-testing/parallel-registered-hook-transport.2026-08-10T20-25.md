# P4-T9 Registered Parallel Hook Transport Evidence

Timestamp: 2026-08-11T11:18:52-04:00

## Scope

This receipt covers only P4-T9 registered-process transport, registration-existence, parser, and line-limit acceptance. It does not claim root/bundle publication parity, which P5-T3 owns.

## Commands

- Command: `mcp__drm-copilot__run_poshqc_format` for the three P4-T9 test owners.
  - EXIT_CODE: 0
- Command: `mcp__drm-copilot__run_poshqc_analyze` for the three P4-T9 test owners.
  - EXIT_CODE: 0
- Command: focused PoshQC/Pester for `codex-parallel-registered-transport.Tests.ps1`.
  - EXIT_CODE: 0
  - Result: 4 passed, 0 failed, 0 skipped.
- Command: focused Pester filters for the new registration-existence and parse/line-count assertions.
  - EXIT_CODE: 0
  - Result: 2 passed, 0 failed, 0 skipped, 50 not run.

## Output Summary

- Parsed `.codex/config.toml` resolved nine parallel registration rows: seven direct entrypoints plus the existing SubagentStart and SubagentStop dispatchers.
- The process matrix passed 54 of 54 cells: 42 direct cells and 12 dispatcher cells.
- The matrix covered allow or valid transport, deny or invalid evidence, malformed stdin, missing stdin, poisoned `CLAUDE_TOOL_INPUT`, poisoned `CLAUDE_SESSION_ID`, exact stdout bytes, exact stderr bytes, and exact exit codes.
- SubagentStart exercised `parallel-planner`; SubagentStop exercised `parallel-orchestrator`.
- `command` and `command_windows` matched for every resolved row, both persona matchers were present, and every resolved script existed.
- `validate-parallel-agent-output.ps1` had zero direct registrations, proving the sourced stop validator was not registered for duplicate invocation.
- The new registration-existence assertion passed 1 of 1.
- The new root parse and 500-line-limit assertion passed 1 of 1.
- Final physical line counts were 454 for `codex-parallel-registered-transport.Tests.ps1`, 191 for `codex-epic-runtime-contracts.Tests.ps1`, and 494 for `legacy-codex-hook-contracts.Tests.ps1`.

## Downstream Plan-Ordering Defect

The combined three-owner Pester run discovered 56 tests, with 54 passing and two pre-existing root/bundle parity assertions failing. These failures are outside P4-T9's test-only ownership:

- `.codex/config.toml`: root `577B242F835C06DF8E4F1D6A17A6D8A8E4BFB8DF6739EAEC5018CECCED147284`; bundle `016C65064CDCD1D3C4C1B923F5B75EF30AE965EA270A98BAB7B9B242864ECDA4`.
- `.codex/hooks/record-subagent-routing-attestation.ps1`: root `5CC5BDD808219B23AC26B84C057C9727DDB6706EE8C1816F19286AAA5EAA74EC`; bundle `277BE595CA83D1FCB53DE72507A86C76499302F9A4244853CD3DB3C72DEDC095`.
- `.codex/hooks/enforce-codex-model-routing.ps1`: root `154DBF32D87A01AD1221575DC80D8240622648EEA39DA856D238408C6D5E9FAB`; bundle `F4F68A1DBE6545AE10756ED73E133BE66C1D9E69EAF46B5B35DE90EC3105B354`.
- `.codex/hooks/validate-codex-subagent-routing.ps1`: root `8258011DCBCBE4C204824268AD8A898B2E111ECF807C9CA73FAEF4A6406140D7`; bundle `5E6477174AB7D4907F286040CDDA28264EC65CC0A9C017E8D8285BDD47446477`.
- `.codex/hooks/enforce-completion-consistency.ps1`: root `749C72A5EA8CF84A9B6971E8FD724EB91E4CB2A7D409B6DB21CD5E7A5218513E`; bundle `CF301A28CA7F159D8E0A60F94F93AC55A57BFA3660F809B0CD8B7230925EBEC3`.

P5-T3 explicitly owns byte-identical bundle counterparts. P4-T12 runs the full PowerShell hook suite before P5-T3, so P4-T12 cannot exit zero as currently ordered unless the plan adds an explicit pre-P4-T12 parity synchronization. No root or bundle parity file was changed in P4-T9.
