# Preparation Handoff - Issue #1221

Timestamp: 2026-11-23T06-35
Command: preparation-mode orchestration (promotion, research, spec, user story, atomic plan, preflight)
EXIT_CODE: 0
Output Summary: Preflight round 2 returned PREFLIGHT: ALL CLEAR with CONVERGENCE: NO FURTHER ROUNDS EXPECTED. Plan validation passed on the branch-current Python CLI and on the installed MCP validator. Next step: S5_atomic_execution, run by epic-orchestrator.

## Inputs and Outputs

- Issue: #1221 (epic #1217, wave 1, complexity C3)
- Plan: `.dev/active/1221-docs-family-gate-and-ia/plan.2026-11-23T00-39.md` (v1.1, 21 tasks, with a `## Size Justification` section)
- Research: `research/research.2026-11-23T05-52.md`
- Requirements: `spec.md` (26 acceptance criteria, `## Decisions` 1-20) and `user-story.md`
- Preflight fix records: `evidence/other/preflight-fixes.2026-11-23T06-19.md` (round 1) and `evidence/other/preflight-fixes.2026-11-23T06-34.md` (round 2)

## Orchestrator Decisions (autonomous mode)

1. The worktree branch did not contain `ab206193b`. It was reset onto `origin/epic/documentation-estate-families-integration` before any other work.
2. The family check lives in the docs-complete validation layer (`DocsValidation.psm1`, `DocsValidateCommands.psm1`) through a new `DocsFamilyCheck.psm1`. `DocsCompleteGate.psm1` is unchanged, so docs-review-cadence edits the validation layer rather than the hook module. The dependency edge between the two items still holds.
3. Sibling #1218 seeds ten `required: true` families in `New-DocsStarterProfile`, so Risk R1 applies. The plan updates `New-DocsLedgerTestProfile` and the end-to-end fixtures (spec AC-16 and AC-17).
4. The pre-existing `FINDINGS_LIMIT` envelope defect is unrelated to families and is out of scope. The research records it for a separate issue.
5. The constraints relayed by the epic planner were passed to every delegation as task constraints. They were not recorded as `owner_directives` entries, because no recorded `Owner directives:` block was supplied.

## Execution-Time Risks for epic-orchestrator

- Base: execution must branch from an integration tip that contains #1218. P0-T1 checks for `DocsProfileFamilies.psm1` and the `required_families` schema key, and stops with BLOCKED when either is absent.
- Batch budget: the plan edits five production PowerShell modules plus their bundle copies. Execution needs a non-terminal `large`, `preparation`, or `remediation` route checkpoint in the item worktree. An isolated subagent worktree has no checkpoint and falls under the three-file direct-mode cap.
- Pester baseline: merged JUnit and coverage files are written only after a fully green run. If the Phase 0 baseline has pre-existing failures, read counts from `artifacts/pester/parallel/shard-<i>/`.
