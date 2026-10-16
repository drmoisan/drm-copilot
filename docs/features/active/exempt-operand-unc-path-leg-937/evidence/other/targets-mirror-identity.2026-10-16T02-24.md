# Targets mirror identity (P2-T4)

Timestamp: 2026-10-16T02-24
Command: git hash-object .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
EXIT_CODE: 0
Output Summary: All four copies hash to ef89c7f2e603ec3667d0c09589628be8af187559, which differs from the baseline hash f7c526d0614429a53a5f773d6e967e6061d7a5c9 (targets-hash-baseline.2026-10-16T00-33.md). `git grep -c OrchestrationTargetNonLocalPattern` prints 2 for each of the four paths. Acceptance met.

## Hashes

| Copy | Hash |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `ef89c7f2e603ec3667d0c09589628be8af187559` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `ef89c7f2e603ec3667d0c09589628be8af187559` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `ef89c7f2e603ec3667d0c09589628be8af187559` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `ef89c7f2e603ec3667d0c09589628be8af187559` |

Baseline hash (all four copies): `f7c526d0614429a53a5f773d6e967e6061d7a5c9`.

## Pattern count

Command: git grep -c OrchestrationTargetNonLocalPattern -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
EXIT_CODE: 0

```
.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:2
.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:2
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:2
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:2
```
