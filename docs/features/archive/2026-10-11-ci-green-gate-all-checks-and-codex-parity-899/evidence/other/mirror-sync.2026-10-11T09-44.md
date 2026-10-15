# Mirror Sync Evidence (Phase 1)

Each entry records one source and bundle-mirror pair after the identical Edit-tool operations were applied to the mirror.

Timestamp correction (recorded during Phase 2): the per-entry timestamps were originally estimated rather than read from the host clock. Because this file was appended to once per entry, only its final write time (2026-10-12T16-26) is recoverable from the filesystem; each entry's `Timestamp:` is therefore set to that value as an upper bound. The entries ran in the order listed, after the P1-T2 run at 16-20.

## P1-T7 — claude-orchestrate

Timestamp: 2026-10-12T16-26
Command: git hash-object .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
EXIT_CODE: 0
Hashes:
- .claude/skills/orchestrate/SKILL.md: 1225177772f7d9bc7df8a25b0a3163d5471c0ab0
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md: 1225177772f7d9bc7df8a25b0a3163d5471c0ab0
Output Summary: PAIR_EQUAL=true claude-orchestrate

## P1-T10 — claude-parallel-orchestrate

Timestamp: 2026-10-12T16-26
Command: git hash-object .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
EXIT_CODE: 0
Hashes:
- .claude/skills/parallel-orchestrate/SKILL.md: 3fdd875331fe1f478f0d2b562da5554d7a31d7d3
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md: 3fdd875331fe1f478f0d2b562da5554d7a31d7d3
Output Summary: PAIR_EQUAL=true claude-parallel-orchestrate

## P1-T15 — agents-orchestrate

Timestamp: 2026-10-12T16-26
Command: git hash-object .agents/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md
EXIT_CODE: 0
Hashes:
- .agents/skills/orchestrate/SKILL.md: e4ee425e0884f70abc3bfa3fff23d0340f328e0c
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md: e4ee425e0884f70abc3bfa3fff23d0340f328e0c
Output Summary: PAIR_EQUAL=true agents-orchestrate

## P1-T17 — claude-orchestrator-agent

Timestamp: 2026-10-12T16-26
Command: git hash-object .claude/agents/orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md
EXIT_CODE: 0
Hashes:
- .claude/agents/orchestrator.md: e134c9fd5e4f7370db5530f5762c003a98776274
- extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md: e134c9fd5e4f7370db5530f5762c003a98776274
Output Summary: PAIR_EQUAL=true claude-orchestrator-agent

## P1-T22 — agents-orchestrator-workflow

Timestamp: 2026-10-12T16-26
Command: git hash-object .agents/skills/orchestrator-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md
EXIT_CODE: 0
Hashes:
- .agents/skills/orchestrator-workflow/SKILL.md: 65be34639e79b5310fab68987adaca6dc7500433
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md: 65be34639e79b5310fab68987adaca6dc7500433
Output Summary: PAIR_EQUAL=true agents-orchestrator-workflow

## P1-T25 — claude-remediation-handoff

Timestamp: 2026-10-12T16-26
Command: git hash-object .claude/skills/remediation-handoff-atomic-planner/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md
EXIT_CODE: 0
Hashes:
- .claude/skills/remediation-handoff-atomic-planner/SKILL.md: 5ffdd8dd48a2371f16fccaf28ae8b663de4d00f0
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md: 5ffdd8dd48a2371f16fccaf28ae8b663de4d00f0
Output Summary: PAIR_EQUAL=true claude-remediation-handoff

## P1-T29 — claude-ci-gate-parser

Timestamp: 2026-10-12T16-26
Command: git hash-object .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1
EXIT_CODE: 0
Hashes:
- .claude/lib/ci-gate/Invoke-CiGateParser.ps1: 27a7e9581622f924a59bc8b4814aefa92fe0f0ce
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1: 27a7e9581622f924a59bc8b4814aefa92fe0f0ce
Output Summary: PAIR_EQUAL=true claude-ci-gate-parser
