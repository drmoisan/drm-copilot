# Phase 0 Policy Reads — Issue #440 (parallel-enforcement-hooks, F7)

Timestamp: 2026-08-08T20-57

Task: [P0-T1]

Plan of record: `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md`

Branch: `feature/parallel-enforcement-hooks-440` (base `epic/parallel-orchestration-integration` at `c939b5b8`)

## Policy Order

The order mandated by [P0-T1] and by the `policy-compliance-order` skill was followed exactly:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/python.md`
6. `.claude/rules/python-suppressions.md`

## Files Read (explicit list)

| Order | Path | Read | Notes |
| --- | --- | --- | --- |
| 1 | `CLAUDE.md` | Yes | Tone policy, policy-compliance reading order, four-layer runtime architecture. |
| 2 | `.claude/rules/general-code-change.md` | Yes | Seven-stage toolchain loop with restart-on-change rule; 500-line file cap; fail-fast error handling; I/O-boundary isolation. |
| 3 | `.claude/rules/general-unit-test.md` | Yes | Five core test properties; line coverage >= 85% and branch coverage >= 75% uniform across tiers; Coverage Exclusion Policy prohibits excluding a production file from measurement (drives P2-T4); tests must live under `tests/` mirroring source; temp files in tests prohibited. |
| 4 | `.claude/rules/powershell.md` | Yes | PoshQC MCP toolchain (format -> analyze -> test, no type-check stage); per-batch cap of 3 production and 3 test files (drives the P2-T3 reset); wrapper-function/adapter mock seams; Pester 5.x with `*.Tests.ps1` naming; deterministic-test requirements. |
| 5 | `.claude/rules/python.md` | Yes | Black -> Ruff -> Pyright -> Pytest loop; full type annotations required; `--cov --cov-branch` coverage command; no temp files or external dependencies in unit tests. |
| 6 | `.claude/rules/python-suppressions.md` | Yes | Suppression pre-authorization list and escalation path. No suppression is anticipated for this feature. |

## Additional Standing Rules Loaded

The following path-scoped rules were auto-loaded into context by the runtime and are binding on this feature's scope:

- `.claude/rules/parallel-orchestration.md` — the F3-owned parallel artifact invariants (checkpoint required keys, cohort/conflict-edge/merge-status enums, the Cache Doctrine, the Enum Ownership table declaring that F7 consumes and never extends the enums, and the explicit `## F7 Seam` section). This is the authoritative upstream contract source for the P0-T9/P0-T10 U-row verification.
- `.claude/rules/orchestrator-state.md` — standard orchestrator-state invariants (not modified by this feature).
- `.claude/rules/quality-tiers.md` — T1-T4 tier matrix; uniform coverage thresholds.
- `.claude/rules/tonality.md` — professional tone requirement for all authored content.
- `.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md` — no workflow or benchmark files are in this feature's scope; read for completeness.

## Binding Constraints Acknowledged

The plan's `## Binding Constraints (apply to every task)` section (items 1-11) was read in full and governs every task executed. The constraints of immediate relevance to Phase 0 are:

- Constraint 7 (Evidence schema): every command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; PowerShell test evidence records the line/command coverage headline plus the explicit `BRANCH: not emitted by PoshQC/Pester coverage output` note; evidence resolves only under `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/<kind>/`.
- Constraint 8 (No SKIPPED): every command-bearing Phase 0 task executes its stated command.
- Constraint 10 (Phase 0 halt gate): any U1-U16 row that does not hold halts execution for re-planning per P0-T11.

EXIT_CODE: 0

Output Summary: All six mandated policy files read in the required order, plus five auto-loaded path-scoped rule files recorded above. No policy file was modified. No blocking conflict between the plan and repository policy was identified at this stage.
