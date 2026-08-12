# Native Hook Translation Invariance

Timestamp: `2026-08-11T12-41-04:00`

Task: `[P4-T12]`

Command: `verify five root/bundle SHA-256 pairs; mcp__drm-copilot__run_poshqc_test(workspace_root, scan_folders=[tests/scripts/codex-hooks]); python tomllib parse .codex/config.toml; PowerShell Parser.ParseFile for nine new hook files; verify snapshot, ledger, compensating-control, .claude, state, and diff contracts`

EXIT_CODE: `0`

Output Summary: The five synchronized pairs were exact before PoshQC started. The authoritative run produced a fresh 538/538 green JUnit receipt, root TOML and all nine new PowerShell files parsed, 25/25 snapshots remained exact, the ledger remained 16/2/0, all 54 registered transport cells and 37 compensating-control owner tests were green, and `.claude/` remained byte-identical to P0-T7.

## Mandatory pair precondition

| Root file | Bundle file | SHA-256 | Result |
|---|---|---|---|
| `.codex/config.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` | `577B242F835C06DF8E4F1D6A17A6D8A8E4BFB8DF6739EAEC5018CECCED147284` | exact |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1` | `5CC5BDD808219B23AC26B84C057C9727DDB6706EE8C1816F19286AAA5EAA74EC` | exact |
| `.codex/hooks/enforce-codex-model-routing.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1` | `154DBF32D87A01AD1221575DC80D8240622648EEA39DA856D238408C6D5E9FAB` | exact |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-codex-subagent-routing.ps1` | `8258011DCBCBE4C204824268AD8A898B2E111ECF807C9CA73FAEF4A6406140D7` | exact |
| `.codex/hooks/enforce-completion-consistency.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1` | `749C72A5EA8CF84A9B6971E8FD724EB91E4CB2A7D409B6DB21CD5E7A5218513E` | exact |

Pair count: `5`; mismatch count: `0`.

## Authoritative PoshQC test

- Invocation: `mcp__drm-copilot__run_poshqc_test` with the required workspace root and `scan_folders=["tests/scripts/codex-hooks"]`.
- The MCP response channel timed out after 300 seconds. The invoked wrapper had already completed and wrote a fresh run-owned JUnit receipt at `2026-08-11T12:38:13.6449692-04:00`.
- Receipt: `artifacts/pester/pester-junit.xml`.
- Tests: `538`; passed: `538`; failures: `0`; errors: `0`; duration: `273.652` seconds.
- Root coordination accepted this fresh terminal receipt and directed that the wrapper not be rerun without a concrete test failure.

## Native structure

- `.codex/config.toml`: TOML parse passed; `6` top-level sections; `14,045` bytes.
- New PowerShell files parsed: `9`; parser errors: `0`.
- All nine files remain below 500 physical lines.
- Translation mapping rows: `16`.
- Translation snapshot manifest rows: `25`.

## Snapshot and ledger proof

- Snapshot sources expected: `25`.
- Snapshot files present: `25`.
- Byte/SHA mismatches: `0`.
- Containment failures: `0`.
- Snapshot files over 500 lines: `0`.
- Ledger rows: `18`; duplicate gate IDs: `0`.
- PRESERVED: `16`.
- DEGRADED: `2`.
- LOST: `0`.

## Registered transport and compensating controls

- Direct registered transport matrix: `7 x 6 = 42` cells, all green.
- Config-resolved dispatcher matrix: `2 x 6 = 12` cells, all green.
- Registered process cells total: `54`; failures: `0`.
- P4-T10 owner suites: `37` tests; failures: `0`.
- G02 owners: `parallel-provenance.Tests.ps1`, `parallel-child-worktree-launcher.Tests.ps1`, and `codex-parallel-registered-transport.Tests.ps1` prove forced profiles, permission/sandbox and PreToolUse denials, plus sealed external launch.
- G16 owner: `parallel-completion-compensating-controls.Tests.ps1` proves one continuation, repeated-stop and full-state root refusal, immutable receipt rejection, and required-job failure semantics.

## Protected and repository state

- P0-T7 `.claude/` manifest: `150` files.
- Current `.claude/` manifest: `150` files.
- SHA-256 manifest delta: `0`.
- `.codex/state` exists: `false`.
- `git diff --check` exit: `0`.

P4-T12 acceptance is satisfied. P5-T1 was not started during this gate.
