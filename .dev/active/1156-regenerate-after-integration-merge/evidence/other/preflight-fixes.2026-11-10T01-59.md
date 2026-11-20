# Preflight Fixes

Timestamp: 2026-11-10T01-59
Plan: docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md
Branch: feature/regenerate-after-integration-merge-1156
Issue: #1156

Earlier preflight-fixes files in this folder are unchanged; this record is append-only.

## Fixes

1. [P2-T1] | validator-blind structure clarification, meaning kept | Script-layer AST check (b) requires the dot-source guard to precede every other statement outside function definitions. The existing entry script `.claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1` places `Set-StrictMode`, `$ErrorActionPreference`, and `Import-Module` before its functions and guard, so an executor following that layout would fail check (b). The task now states that the module imports and any strict-mode or error-preference line sit on the guarded path or inside a function that `Invoke-RegenerationPathCommand` calls, and that a dot-sourcing test imports any module it needs in `BeforeAll`. The asserted structure is unchanged.

## Substantive defects returned (not fixed in place)

1. [P3-T3] and [P3-T4] | design-check gap (spec `### Preimplementation allowance` rule 3, config read from the integration worktree; argument forwarding in the epic-scope wiring) | Returned to the planner as a `PREFLIGHT-DEFECT:` line.
