# Targets-Copy Hash Baseline, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T09-47
Task: P0-T7 (remediation-plan.2026-10-16T08-40.md)
Command: git hash-object <four copies>; for each copy: wc -l < <copy>; awk 'length > 120' <copy> | wc -l (run via sh SCRATCH/c2_targets_check.sh from WORKTREE)
EXIT_CODE: 0
Output Summary: All four copies hash to e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 (matches cycle 1 e92597ce1); each is 433 lines with 0 lines over 120 characters.

| Copy | git hash-object | wc -l | lines > 120 |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2` | 433 | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2` | 433 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2` | 433 | 0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2` | 433 | 0 |
