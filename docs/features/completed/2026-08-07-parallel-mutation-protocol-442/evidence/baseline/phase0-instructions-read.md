# Phase 0 — Policy Instructions Read (P0-T1)

Timestamp: 2026-08-08T21-24

Task: [P0-T1] Read policy files in the required order and record the read evidence.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442, F6 parallel-mutation-protocol)
Branch: `feature/parallel-mutation-protocol-442`
HEAD at read time: `c939b5b80c8c297db49febaebdd35dda2c869a3f`

## Policy Order

The order below is the order mandated by [P0-T1] of the approved plan, which composes the
repository baseline order from `.claude/skills/policy-compliance-order/SKILL.md` with the
language-specific and surface-specific rules in scope for this feature (Python and PowerShell
production code plus the parallel-orchestration checkpoint surface).

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/powershell.md`
7. `.claude/rules/quality-tiers.md`
8. `.claude/rules/orchestrator-state.md`
9. `.claude/rules/parallel-orchestration.md`

## Files Read (explicit list, in the order above)

| # | File | Present | Read | Notes |
| --- | --- | --- | --- | --- |
| 1 | `CLAUDE.md` | yes | yes | Tone policy; policy-compliance reading order; four-layer runtime architecture; orchestration checkpoint path. |
| 2 | `.claude/rules/general-code-change.md` | yes | yes | Design priorities; module rigor tiers pointer; mandatory seven-stage toolchain loop with restart-on-change; 500-line file cap; error handling; I/O boundaries; no temp files in tests. |
| 3 | `.claude/rules/general-unit-test.md` | yes | yes | Five core test properties; uniform coverage floors (line >= 85%, branch >= 75%); coverage-exclusion prohibition for production paths; scenario completeness; Arrange-Act-Assert; `tests/` mirror layout; determinism infrastructure (injected clock, seeded RNG with printed seed, banned wall-clock APIs). |
| 4 | `.claude/rules/python.md` | yes | yes | Toolchain `poetry run black .` -> `poetry run ruff check .` -> `poetry run pyright` -> `poetry run pytest --cov --cov-branch --cov-report=term-missing`; PEP 8 naming; frozen dataclasses for value objects; full type hints; dependency seams incl. `clock: Callable[[], datetime]`; pytest rules; prohibition on new dependencies without explicit instruction. |
| 5 | `.claude/rules/python-suppressions.md` | yes (present) | yes | Suppression authorization requirement and pre-authorized `# noqa` / `# type: ignore` pattern list; five-approach escalation path before requesting approval. No suppression is anticipated for this feature. |
| 6 | `.claude/rules/powershell.md` | yes | yes | Toolchain via MCP: `run_poshqc_format` -> `run_poshqc_analyze` -> `run_poshqc_test` (Pester v5, repo runsettings); PowerShell 7+; advanced functions with `CmdletBinding()`; minimal-DI design seams (wrapper-function seam preferred, injectable delegate/ScriptBlock second); mocking rules (never mock `git`/`gh` directly); 500-line cap; coverage floors. |
| 7 | `.claude/rules/quality-tiers.md` | yes | yes | T1-T4 definitions; `quality-tiers.yml` as source of truth; uniform gates (format 100%, 0 lint, 0 type errors, line >= 85%, branch >= 75%, no regression on changed lines); tier-dependent gates incl. property-test density >= 1 per pure function for T1/T2. |
| 8 | `.claude/rules/orchestrator-state.md` | yes | yes | Standard-checkpoint remediation-cycle, `human_interaction`, complexity-assessment, and model-routing-receipt invariants; foreign-schema prohibition; enforcement is Python validator logic, never an imported JSON Schema. |
| 9 | `.claude/rules/parallel-orchestration.md` | yes | yes | Authoritative parallel-surface schema prose: 21 orchestrator invariants (incl. invariant 16 mutation shape and invariant 17 in-flight-removal disposition), planner invariants P1-P9, manifest invariants M1-M7; `items[].issue_num` positive integer as primary key; cache doctrine; "Enum Ownership (F6/F7/F8 consume, never extend)" nine-enum table; the F7 seam in `validate_parallel_orchestrator_state.py`. |

Total policy files read: 9 of 9. The conditional entry (`.claude/rules/python-suppressions.md`) is
present in the repository and was read; no policy file in the mandated order was absent or skipped.

## Additional Policy Constraints Loaded for This Execution

The following were also read as governing constraints for this plan's execution and are recorded
for completeness (they are not part of the nine-file mandated order):

- `.claude/skills/atomic-plan-contract/SKILL.md` — plan format, Phase 0 requirements, coverage evidence contract, no-SKIPPED rule.
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — canonical evidence location `<FEATURE>/evidence/<kind>/`; ISO-8601 `yyyy-MM-ddTHH-mm`; required artifact fields.
- `.claude/skills/acceptance-criteria-tracking/SKILL.md` — AC source resolution for work mode `full-feature` (`spec.md` and `user-story.md`), check-off protocol (Phase 6 owns check-off for this plan).
- `.claude/skills/policy-compliance-order/SKILL.md` — baseline policy order and hard constraints (no edits to `.claude/rules/` or `.github/instructions/`).

## Confinement Acknowledged

Per the plan's "Wave-4 Contention Constraint (Mandatory)" section and the execution directive:

- No edit to `## Enforcement Hooks (F7)` or `## Radius Drift Detection (F8)` in `.claude/skills/parallel-orchestrate/SKILL.md`.
- No write inside the F7 extension seam in `scripts/dev_tools/validate_parallel_orchestrator_state.py`.
- No field or enum member added to F3's `mutations[]`, `drift_events[]`, or `conflict_edges[]`, or to any state or merge-status enum.
- No modification to any `enforce-epic-*` hook, epic validator, epic skill, or epic agent.
- Phases 0 and 1 make no production edit.

EXIT_CODE: 0

Output Summary: All nine mandated policy files read in the required order; the conditional file
`.claude/rules/python-suppressions.md` is present and was read, so 9 of 9 files were read with zero
absent and zero skipped. Four governing skill contracts were additionally loaded. No policy file was
modified. Wave-4 confinement constraints acknowledged and recorded.
