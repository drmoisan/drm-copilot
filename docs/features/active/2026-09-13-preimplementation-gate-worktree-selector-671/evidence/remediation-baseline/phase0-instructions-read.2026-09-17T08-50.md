# Phase 0 Instructions Read — Remediation R1 (issue #671)

Timestamp: 2026-09-17T09-36
Task: [P0-T1]
Plan: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-plan.2026-09-17T08-44.md` (git hash-object `6d323a2d94f73de7faa75068200b0c98872ba4c5`)
Workspace root: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686`

Policy Order: 1. CLAUDE.md -> 2. .claude/rules/general-code-change.md -> 3. .claude/rules/general-unit-test.md -> 4. .claude/rules/quality-tiers.md -> 5. .claude/rules/powershell.md -> 6. .claude/rules/plan-acceptance-gates.md

## Files read (in order, full content, from the worktree root)

1. `CLAUDE.md` (56 lines) — tone policy, policy reading order, four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` (80 lines) — design principles, mandatory toolchain loop with restart, 500-line cap, fail-fast error handling.
3. `.claude/rules/general-unit-test.md` (105 lines) — test principles, line coverage >= 85%, no branch gate for Pester, no production exclusions, no temporary files in tests.
4. `.claude/rules/quality-tiers.md` (51 lines) — T1–T4 tiers; uniform line-coverage threshold; no regression on changed lines.
5. `.claude/rules/powershell.md` (97 lines) — PoshQC format -> analyze -> test via MCP; Pester 5; mocking rules; no weakened assertions.
6. `.claude/rules/plan-acceptance-gates.md` (257 lines) — G1–G9 acceptance-gate rules; observe success-case output before asserting over it.

## Notes

- Execution route: the executor has no PowerShell tool; direct PowerShell steps run through `sh <scratchpad>/f671-r1/run.sh <absolute script path>` as the plan's "Execution environment and routing" section specifies. The runner was written before [P0-T1] with the three plan-mandated lines and probed: location `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686`, pwsh 7.6.6, Pester 5.6.1, PSScriptAnalyzer 1.25.0.
