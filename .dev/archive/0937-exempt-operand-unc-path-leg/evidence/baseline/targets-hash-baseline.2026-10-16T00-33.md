# Targets-Copy Hash Baseline (issue #937)

Timestamp: 2026-10-16T00-33
Task: P0-T6
Command: git hash-object <four targets copies>; wc -l < <copy> (Git Bash, each copy)
EXIT_CODE: 0
Output Summary: all four copies hash to f7c526d0614429a53a5f773d6e967e6061d7a5c9; each copy is 424 lines.

| Copy | git hash-object | wc -l |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `f7c526d0614429a53a5f773d6e967e6061d7a5c9` | 424 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `f7c526d0614429a53a5f773d6e967e6061d7a5c9` | 424 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `f7c526d0614429a53a5f773d6e967e6061d7a5c9` | 424 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `f7c526d0614429a53a5f773d6e967e6061d7a5c9` | 424 |

Acceptance: four identical hashes; line counts recorded (424, as expected). PASS.
