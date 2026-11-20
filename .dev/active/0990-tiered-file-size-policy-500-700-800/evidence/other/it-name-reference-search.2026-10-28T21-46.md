# It-Name Reference Search (Phase 5)

Timestamp: 2026-10-28T21-46
Command: grep -rnF "<It name>" tests extensions/drm-copilot/test (one search per name below)
EXIT_CODE: 0
Output Summary: every name has exactly one hit, in its defining file; no hit outside the defining file, so no other file needs an update when the rows are renamed in [P5-T2] through [P5-T4].

| It name | Hits |
|---|---|
| `keeps every claude library module within the five hundred line limit` | `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (definition only) |
| `keeps hook, config, and agent files within the 500-line limit` | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` (definition only) |
| `the orchestrator-state module stays within the 500-line file cap` | `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` (definition only) |
| `keeps every surface copy of the targets module under the 500-line cap` | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` (definition only) |
| `keeps every surface copy of the helpers module under the 500-line cap` | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` (definition only) |
