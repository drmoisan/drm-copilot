# Remediation Cycle 1 — Inputs Review and Finding Inventory

Timestamp: 2026-08-09T06-18

Task: [P0-T2]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
Diff bases (both pinned): `a9e2463c` (pre-remediation commit recording the fully-executed base plan) and `c939b5b8` (wave-0-3 integration head, whole-branch confinement only)

## Files Read

| File | Purpose |
| --- | --- |
| `<FEATURE>/remediation-inputs.2026-08-09T00-19.md` | Consolidated findings R1 (Blocking), R2-R6 (Partial), A1-A9 (Advisory), exit criteria |
| `<FEATURE>/policy-audit.2026-08-09T00-19.md` | Independent policy audit; findings B1, P1-P5, A1-A9; toolchain and coverage figures |
| `<FEATURE>/code-review.2026-08-09T00-19.md` | Correctness concerns (Blocking / Partial / Advisory), test quality, skills review |
| `<FEATURE>/feature-audit.2026-08-09T00-19.md` | 24 AC evaluated (S1-S15, U1-U9); S9 PARTIAL; discrepancy D1; baseline comparison table |
| `<FEATURE>/spec.md` | AC source (S1-S15, 15 items), FR1-FR10, Recompute Boundary, API surface, Test Strategy, version 1.1 |
| `<FEATURE>/user-story.md` | AC source (U1-U9, 9 items) |
| `<FEATURE>/plan.md` | Fully executed base plan (51/51); MUST NOT be modified by this cycle |
| `.claude/rules/parallel-orchestration.md` | F3-owned invariants 1-21, P1-P9, M1-M7; nine consume-never-extend enums; F7 seam; cache doctrine |
| `docs/features/epics/parallel-orchestration/epic.md` § F6 (lines 261-269) | F6 scope and complexity band C4; wave-4 concurrency with F7 (#440) and F8 (#446) |

## Finding Inventory (read from the audit artifacts, not from the plan)

| ID | Class | Location (as recorded by the audit) | Planned disposition task IDs |
| --- | --- | --- | --- |
| R1 / B1 / D1 — admission ignores not-yet-launched current-cohort members | **Blocking** | `scripts/dev_tools/parallel_mutation_protocol.py:114-161`, `:127-130`; `.claude/skills/parallel-add/SKILL.md:69-79`; `spec.md:45-48`, `:535-536`; `user-story.md:88` | P1-T1, P1-T3, P1-T4, P1-T5, P1-T6, P1-T8, P1-T11, P1-T13, P2-T1, P2-T2, P3-T1, P3-T2, P3-T10, P4-T1, P4-T2, P4-T8, P5-T1, P5-T3, P7-T11 |
| R2 / P1 — F3 op-classification tuples copied without a binding assertion | Partial | `scripts/dev_tools/_parallel_mutation_models.py:109-113`; `scripts/dev_tools/_parallel_orchestrator_state_mutations.py:92-99`; F3 originals `_parallel_state_records.py:49-56` | P6-T1, P6-T2, P6-T3 |
| R3 / P2 — FR9 invariant 3 narrower than its spec/AC wording (S9 PARTIAL) | Partial | `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py:247-289`; `spec.md:170-173`, `:543` | P1-T10, P7-T11 |
| R4 / P3 — Python/TypeScript parity gap for the three FR9 invariants | Partial | `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` (unmodified) | P6-T7 (DEFERRED with recorded rationale; no TypeScript port on this branch) |
| R5 / P4 — unauthorized `# noqa: S311` suppression | Partial | `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py:125`, `:308` | P6-T4, P6-T5 |
| R6 / P5 — `# noqa: S603` rationale on an inert line | Partial | `scripts/dev_tools/parallel_mutation_abandon_cli.py:152-153` | P6-T6 |

**Audit-derived counts: 1 Blocking, 5 Partial.** These match the `## Summary` table of
`remediation-inputs.2026-08-09T00-19.md` (Blocking 1, Partial 5, Advisory 9) and the
`## Summary` table of `policy-audit.2026-08-09T00-19.md` (Blocking 1, Partial 5, Advisory 9)
exactly. `feature-audit.2026-08-09T00-19.md` records "Total Blocking findings: 1" and one
PARTIAL AC (S9), consistent with both.

## Additional Row — Preflight-Identified Design Gap C2 (adjudicated in scope for this cycle)

| ID | Class | Location | Disposition task IDs |
| --- | --- | --- | --- |
| C2 — `recolor_unstarted` drops the pinned CONSTRAINT along with the pinned VERTICES | **Blocking (adjudicated)** | `scripts/dev_tools/parallel_mutation_protocol.py:164-235`, induced-edge comment and comprehension at `:217-224` | P1-T2, P1-T3, P1-T5, P1-T7, P1-T9, P1-T12, P1-T13, P2-T3, P2-T4, P3-T3, P3-T4, P3-T5, P3-T6, P3-T7, P4-T3, P4-T4, P4-T5, P4-T8, P4-T10, P4-T11, P5-T1, P5-T2, P5-T3, P7-T11, P7-T12 |

C2 is NOT one of the six audit findings. It was identified during preflight validation of the
fix for C1 (recorded as preflight delta REV-5 in the remediation plan's
`## Preflight Revision Log`) and is **adjudicated in scope for this cycle** as a scope
expansion. Statement of the gap: `recolor_unstarted` builds `induced_edges` keeping an edge only
when both endpoints are unstarted. That correctly removes the pinned VERTICES from the coloring
input but also removes the pinned CONSTRAINT. F2's `compute_cohorts` places an edge-free key in
cohort 0, and the cohort barrier cannot advance `current_cohort` while any item is `in_flight`,
so a candidate deferred BECAUSE it conflicted with an in-flight item becomes an isolated vertex,
is assigned index 0, and — when `current_cohort == 0` — rejoins the very pinned item it
conflicts with. Without C2, C1's fix is cosmetic on its primary case.

## Advisory Items (not remediated by this cycle; not merge gates)

A1 (zero commits at audit time; now resolved — the branch carries commit `a9e2463c`), A2
(abandon-gate `=`-form evasion, mitigated by the CLI's independent refusal), A3 (tautological
seam comparison), A4 (P3 omits in-flight removals), A5 (no dedicated integration suite), A6
(Definition of Done and Seeded Test Conditions unchecked), A7 (three test files at 498-500
lines), A8 (PowerShell coverage inclusion allowlist, pre-existing), A9 (stale confinement diff
stats).

## Explicitly Out of Scope — Not Remediated, Not Edited

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, case "allows gh pr create
--body-file artifacts/pr_body_12.md when context exists" (`:142`),
`Expected: 'allow' But was: 'deny'`. The hook reads the real gitignored
`artifacts/orchestration/orchestrator-state.json` instead of a mocked seam, so its verdict
tracks live orchestration state. It fails identically at baseline, is not in the branch diff,
and must remain the ONLY PowerShell failure. It must not be edited.

Command: (documentary task; artifacts read with the Read and Grep tools, no shell command executed)
EXIT_CODE: 0
Output Summary: All nine input files read. Inventory records exactly 1 Blocking (R1/B1/D1) and 5 Partial (R2-R6) findings derived from the audit artifacts, each with at least one disposition task ID from the remediation plan, plus one additional row for the preflight-identified design gap C2 marked adjudicated-in-scope. Audit-derived counts match `remediation-inputs.2026-08-09T00-19.md` (1 Blocking / 5 Partial / 9 Advisory) exactly.
