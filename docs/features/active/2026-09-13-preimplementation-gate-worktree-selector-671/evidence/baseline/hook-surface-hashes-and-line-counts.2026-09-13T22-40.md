# Baseline — Hook Surface Hashes and Line Counts (issue #671)

Timestamp: 2026-09-17T07-51
Task: [P0-T3]
Command: pwsh -NoProfile -NonInteractive -File <scratchpad>/hashes.ps1 (run from the worktree root via a scratchpad `sh` wrapper); for each of the 12 paths: `(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash` and `@(Get-Content -LiteralPath $path).Count`
EXIT_CODE: 0

Output Summary:
- 12 rows captured (3 files x 4 surfaces).
- The four `-helpers.ps1` rows carry one distinct hash (`45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B`) and 349 lines each.
- The two Codex gate rows carry 500 lines each; the two Claude gate rows carry 496 lines each.
- Modes files: Claude pair 480 lines (one hash), Codex pair 477 lines (one hash).

## Rows

| Path | SHA256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 218CBFADD55CC51547488332C33213339AF42E56B73408005F97101A06D9C176 | 496 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB | 500 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 218CBFADD55CC51547488332C33213339AF42E56B73408005F97101A06D9C176 | 496 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB | 500 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B | 349 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B | 349 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B | 349 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B | 349 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 5216EB9FD638C92761FFB553A8C8829BC3BA1EDAAA578AFF10755CB16A8806CD | 480 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A | 477 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 5216EB9FD638C92761FFB553A8C8829BC3BA1EDAAA578AFF10755CB16A8806CD | 480 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A | 477 |

Route note: no PowerShell tool is available in this session; the PowerShell commands ran in `pwsh` 7.6.6 launched by a scratchpad `sh` wrapper with the working directory set to the worktree root.
