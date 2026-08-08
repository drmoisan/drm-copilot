# Phase 0 Policy Read Evidence — parallel-planner-surface (#443)

Timestamp: 2026-08-08T13-49

Task: [P0-T1]
Plan: `docs/features/active/2026-08-07-parallel-planner-surface-443/plan.2026-08-07T11-11.md`
Branch: `feature/parallel-planner-surface-443`
Worktree root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59`

## Policy Order

The order below is the order defined by `.claude/skills/policy-compliance-order/SKILL.md`, as restated by plan task [P0-T1].

1. `CLAUDE.md` — standing instructions (tone policy, policy compliance reading order, language-rule routing, four-layer runtime architecture).
2. `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, module rigor tiers, seven-stage toolchain loop, 500-line file limit, error handling, naming, I/O boundaries).
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy (five core principles, coverage requirements >= 85% line / >= 75% branch, coverage exclusion policy, scenario completeness, AAA structure, test file location, determinism infrastructure).
4. Language rules in scope (Python is the only language with toolchain obligations in this plan):
   - `.claude/rules/python.md` — Python toolchain (`poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`), coding standards, Pytest rules, prohibited behaviors.
   - `.claude/rules/python-suppressions.md` — pre-authorized `# noqa` / `# type: ignore` patterns and the escalation path before requesting approval.

Additional referenced policies read per [P0-T1]:

5. `.claude/rules/tonality.md` — required professional tone; humor, hyperbole, and metaphor restrictions; evidence-first wording.
6. `.claude/rules/quality-tiers.md` — T1–T4 module rigor tiers and the uniform-versus-tier-dependent gate matrix (uniform line coverage >= 85%, branch coverage >= 75%).

## Files Read (explicit list)

| # | File | Read confirmation |
| --- | --- | --- |
| 1 | `CLAUDE.md` | Read (auto-loaded standing instruction, full text present in session context) |
| 2 | `.claude/rules/general-code-change.md` | Read (auto-loaded path-scoped rule, full text present in session context) |
| 3 | `.claude/rules/general-unit-test.md` | Read (auto-loaded path-scoped rule, full text present in session context) |
| 4 | `.claude/rules/python.md` | Read (explicit `Read` tool invocation, 101 lines) |
| 5 | `.claude/rules/python-suppressions.md` | Read (explicit `Read` tool invocation, 144 lines) |
| 6 | `.claude/rules/tonality.md` | Read (auto-loaded rule, full text present in session context) |
| 7 | `.claude/rules/quality-tiers.md` | Read (auto-loaded rule, full text present in session context) |

Additional rule files present in session context and reviewed for applicability (not required by [P0-T1], recorded for completeness):

- `.claude/rules/parallel-orchestration.md` — F3-landed parallel artifact invariants; directly relevant to this feature's Phase 1 upstream reconciliation and to the F3 ownership boundary.
- `.claude/rules/orchestrator-state.md` — orchestrator-state checkpoint invariants.
- `.claude/rules/benchmark-baselines.md` — benchmark baseline provenance (not in scope; no benchmark baselines are produced by this plan).
- `.claude/rules/ci-workflows.md` — `pwsh` workflow-step authoring (not in scope; this plan modifies no workflow).

## Applicability Notes

- Languages in scope per the plan Scope Summary: Markdown runtime surfaces, one Python test file, one JSON manifest edit. Python is the only language with baseline and final-QA toolchain obligations, so `.claude/rules/python.md` and `.claude/rules/python-suppressions.md` are the only language rules loaded for step 4.
- The 500-line file limit from `.claude/rules/general-code-change.md` is a hard requirement for both Markdown deliverables and the Python contract test; it is verified in plan tasks [P2-T3], [P3-T11], and [P4-T1].
- Test file location policy from `.claude/rules/general-unit-test.md` requires the contract test at `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`, mirroring the production tree; colocation is prohibited.
- Coverage thresholds are uniform (line >= 85%, branch >= 75%) per `.claude/rules/quality-tiers.md`; per spec R10 the base scope adds no production Python module, so the coverage obligation is no-regression plus threshold maintenance.

Result: PASS — all policy files listed in [P0-T1] were read in the specified order prior to any baseline command execution or file modification.
