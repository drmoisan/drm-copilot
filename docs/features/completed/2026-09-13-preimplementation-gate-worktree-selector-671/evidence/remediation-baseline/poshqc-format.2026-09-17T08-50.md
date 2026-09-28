# Remediation Baseline — PoshQC Format (issue #671, R1)

Timestamp: 2026-09-17T09-38
Task: [P0-T5]
Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686`, bracketed (D6) by `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/hashes7.ps1` (`(Get-FileHash -LiteralPath <p>).Hash` per path) and `git status --porcelain`, each taken immediately before and immediately after the call.
EXIT_CODE: 0
MCP disposition (D1): `ok: true`; summary `Ran bundled PoshQC format against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686'.` No output is carried by the MCP result.

## Hash table — before (captured 2026-09-17T09-38-42.692)

| Path | SHA256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | EA600CB7C3C488692545B0EE4BF3ED1C3B24D3721394C72C2CB540EE3B5ADADD | 350 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 4975F491CF94A10EA9E1419150DAB13B08E59EA79F6C7B8DBB7C550B0F899A4F | 357 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | C2066DD1FA37F9ADFBB91B0EBD86EA474033C4FD64A40236D1FF4DFE7A1B7F85 | 54 |

## Hash table — after (captured 2026-09-17T09-38-55.906)

| Path | SHA256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | EA600CB7C3C488692545B0EE4BF3ED1C3B24D3721394C72C2CB540EE3B5ADADD | 350 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 4975F491CF94A10EA9E1419150DAB13B08E59EA79F6C7B8DBB7C550B0F899A4F | 357 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | C2066DD1FA37F9ADFBB91B0EBD86EA474033C4FD64A40236D1FF4DFE7A1B7F85 | 54 |

## `git status --porcelain` — before

```
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-plan.2026-09-17T08-44.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-batch-budget-reset.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-inputs-read.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/remediation-baseline/
```

## `git status --porcelain` — after

```
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-plan.2026-09-17T08-44.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-batch-budget-reset.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-inputs-read.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/remediation-baseline/
```

Formatter-rewritten paths:
none

Output Summary: all seven before/after hash pairs are equal, and the two porcelain captures are identical; the formatter rewrote no tracked or untracked path. Phase 1 is not blocked by [P0-T5].
