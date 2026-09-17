# Helpers Surface Parity After Mirroring (issue #671)

Timestamp: 2026-09-17T08-04
Task: [P2-T5]
Command: pwsh -NoProfile -NonInteractive -File <scratchpad>/hashes.ps1 — per path `(Get-FileHash -LiteralPath <path> -Algorithm SHA256).Hash` and `@(Get-Content -LiteralPath <path>).Count` (worktree root, via a scratchpad `sh` wrapper)
EXIT_CODE: 0

Output Summary:
- The four helpers copies share one distinct hash, 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1.
- Each helpers copy is 433 lines, at most 500.
- The gate and modes files keep their [P0-T3] hashes and line counts (unchanged).

| Path | SHA256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |

Unchanged reference rows (same values as [P0-T3]):

| Path | SHA256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 218CBFADD55CC51547488332C33213339AF42E56B73408005F97101A06D9C176 | 496 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB | 500 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 5216EB9FD638C92761FFB553A8C8829BC3BA1EDAAA578AFF10755CB16A8806CD | 480 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A | 477 |
