# Preflight Fixes (stage B, confirming preflight after the OD-6 planner revision)

Timestamp: 2026-11-20T10-27
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md
Signal: PREFLIGHT: ALL CLEAR

## Fixes

1. `## Scope and Conventions` (orchestrator-owned bullet) | ambiguous reference introduced by the revision | "the precondition record" became "the precondition record (`stage-b-preconditions.*.md`; the run-2 `hook-root-precondition.*.md` is written by [P3-T1])". The revision added an executor-written precondition record in [P3-T1] and `## Execution Preconditions`, so the unqualified phrase in the orchestrator-owned list could be read as covering it. The assertion of [P3-T1] is unchanged.

## Revision Check

- The run-2 hook-root defect returned by the previous preflight (`preflight-fixes.2026-11-20T10-03.md`) is closed: [P3-T1] writes `hook-root-precondition.<timestamp>.md` before any other run-2 write, its acceptance requires four `PASS` rows and `Result: PASS`, and a `FAIL` or a denial of the record's own write stops with `BLOCKED: re-plan-required`.
- The four observations were checked against the session-root checkout (detached at the `INTEGRATION` tip, recorded as `SESSION_ROOT`): `Get-DevelopmentDocsKnownRootPrefix` is called by `Test-FeatureDocumentationOrEvidencePath` and `Test-OrchestrationReady` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and by `.claude/hooks/enforce-completion-consistency.ps1`; `OrchestratorStateFeatureFolderRecord.psm1` builds its path pattern from `Get-DevelopmentDocsKnownRoot`; `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` exists and exports both functions, whose known-root list holds `docs/features` and `.dev`.
- `.claude/hooks/enforce-evidence-locations.ps1` is a denylist of `artifacts/` sub-paths and does not restrict `.dev/active/<feature>/evidence/` writes. `.claude/hooks/validate-executor-output.ps1` at the session root also carries the resolver (same #1035 change set).
- `INTEGRATION` has no commits ahead of the item branch, and the revision commit changed the plan file only, so the areas cleared by the previous preflight were not re-litigated.

## Validation

Command: env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: plan validation passed before and after the fix, with no Warning; 40 tasks, 317 lines (legacy pair 40/400 for a plan stamped before the cutoff).

## Deviations

- MCP drm-copilot was unavailable in this session (connection timeout); the branch-current Python CLI route was used. Non-blocking.
