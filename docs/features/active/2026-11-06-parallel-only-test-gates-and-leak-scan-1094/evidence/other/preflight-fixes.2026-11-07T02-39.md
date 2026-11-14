# Preflight Fixes

Timestamp: 2026-11-07T02-39
Plan: docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/plan.2026-11-06T20-01.md

Trivial defects fixed in place, in task text and phase preamble only. No task was added, removed, or reordered.

## Fixes

1. Phase 1 `**Sweep tokens.**` paragraph. Defect class: stale literal. The list held `failing-test delta`, but `.claude/skills/powershell-qa-gate/SKILL.md`, its `.agents` copy, and their bundle copies spell the phrase `failing-tests delta`, which that token does not match. Added the second spelling, so the sweep covers the wording P1-T3 removes.
2. P1-T6, Tests bullet. Defect class: asserted literal absent from one named file. `.codex/agents/powershell-atomic-executor.toml` does not hold the `**PowerShell**: MCP server functions` list form, so that row could not fail. Its row now forbids `run_poshqc_test`, the tool the task removes from that file's description.
3. P1-T8, Tests bullet. Defect class: literal incomplete for the asserted result. The validator also requires `Disposition:` and `Evidence:` in the comparison line, and a new-code percentage where the row has one. The task now names those parts, so the empty error list it asserts is reachable. The assertion is unchanged.
4. P2-T2. Defect class: evidence selection left to the executor. Named the P0-T3 file set for Black, Ruff, and Pyright, as P2-T1 already does for the P0-T2 file set.
