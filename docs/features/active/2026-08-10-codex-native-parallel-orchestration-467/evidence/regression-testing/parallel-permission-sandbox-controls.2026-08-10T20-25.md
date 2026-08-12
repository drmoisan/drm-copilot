# Parallel Permission and Sandbox Controls

Timestamp: 2026-08-10T20-25
Command: P4-T7 terminal permission, profile, launcher, resume, provenance, and policy verification gate
EXIT_CODE: 0
Output Summary: P4-T7 verified additive profiles and configuration, forced routing, sealed launch and resume identity, `117/117` selected owner tests, `13/13` PreToolUse checks, `20/20` admission denials, and zero `.claude/` or diff violations.

## Result

P4-T7 passed. The parallel permission controls are additive and preserve the existing permission surface. G02 remains `DEGRADED`, with the compensating controls below verified mechanically.

## Monotonic Configuration and Profile Parity

- Root and bundle `.codex/config.toml` parsed successfully and are byte-identical at SHA-256 `016c65064cdcd1d3c4c1b923f5b75ef30ae965ea270a98bab7b9b242864ecda4`.
- The configuration change removed zero existing lines or permission values (`CONFIG_REMOVED_LINES=0`).
- Root and bundle `parallel-planner.toml` parsed successfully, are byte-identical at SHA-256 `e8adfc937f40fa009b2b9f2a2a91fa53056cb62e3b2be9584f73981fb350a3a4`, and bind `parallel-planner-workspace`.
- Root and bundle `parallel-orchestrator.toml` parsed successfully, are byte-identical at SHA-256 `e7bbe7abd46a7e40bdb85104cc63eae9965372b5b89e362d96349cac2d8d0b2b`, and bind `parallel-orchestrator-workspace`.
- Forced planner and orchestrator routing remains `gpt-5.6-sol` with `ultra` reasoning and no fallback.
- Planner implementation mutation is denied; orchestrator-only scheduling is enforced; child execution is restricted to `parallel-child-workspace`.

## Child Boundary and Sealed Identity

- Launch and resume preserve the routed agent, model, and reasoning identity while sealing `runtime_permissions=parallel-child-workspace`.
- Launch and resume bind the exact worktree, isolated `CODEX_HOME`, and approval policy `never`.
- Parent-repository and sensitive customization/state paths are denied to the child profile.
- The child MCP boundary contains 11 explicitly enabled tools and 9 explicitly disabled tools; network and filesystem access remain bounded by the dedicated child profile.
- Relaunch validation rejects a runtime-permission mismatch before execution.

## Mechanical Enforcement

- Selected permission, provenance, launcher, resume, and epic-compatibility owners: 117 passed, 0 failed across 9 test files.
- PreToolUse authority enforcement: 13 passed, 0 failed.
- Parallel admission denial matrix: 20 passed, 0 failed.
- Root and bundle profile parity, forced routing, sealed launch/resume identity, and legacy epic compatibility passed.

## Policy and Repository Checks

- TOML parsing: PASS.
- All changed production, test, and reusable files: at most 500 physical lines.
- `.claude` status entries: 0.
- `.claude` diff entries: 0.
- `git diff --check`: PASS.
- Ephemeral `.codex/state` batch receipt was limited to the completed P4-T7 production and test paths and was removed; the state directory is absent.

## File Size Evidence

- `.codex/config.toml`: 300 lines.
- `.codex/agents/parallel-planner.toml`: 63 lines.
- `.codex/agents/parallel-orchestrator.toml`: 74 lines.
- `.codex/scripts/parallel-child-launch-contract.ps1`: 233 lines.
- `.codex/scripts/launch-parallel-child-batch.ps1`: 486 lines.
- `.codex/scripts/resume-parallel-child.ps1`: 475 lines.
- `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1`: 105 lines.
- `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1`: 307 lines.
- `tests/scripts/codex-hooks/parallel-child-resume-live-truth.Tests.ps1`: 288 lines.
