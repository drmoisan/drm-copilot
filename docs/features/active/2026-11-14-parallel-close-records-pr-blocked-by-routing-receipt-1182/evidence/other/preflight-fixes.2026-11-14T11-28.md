# Preflight Fixes (issue #1182, second preflight)

Timestamp: 2026-11-14T11-28
Plan: docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182/plan.2026-11-14T05-32.md
Validators after the fix: branch-current Python CLI `plan` subcommand exit 0; installed MCP `validate_orchestration_artifacts` ok.
Round-1 defect: AC-13 AST test. Resolved by the [P2-T4] AST rows in `tests/scripts/claude-hooks/hook-parallel-records-context.Tests.ps1`; the rows target files that exist by the end of [P2-T4], and the suite they extend is created in [P2-T2], so the task order is valid.

## Fix 1 - [P2-T4] - validator-blind class (epic-state isolation discovery closure) and Terms wording

The AST rows added by the revision name the two sibling leg files by path. `Get-EpicStateLoadedSourceClosure` in `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` seeds a suite's loaded-source closure from every `hooks/<name>.ps1` string literal, and `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` then requires the suite to comply with every read seam in that closure. The task selection rule would not select that guard suite, so a closure change would first appear at the [P2-T5] gate. The task now names the guard suite in its test selection and acceptance. The task also states that the AST parse reads a committed source file and is not a fixture read, so the Terms rule that every fixture read goes through a mocked seam is not contradicted. The AC-13 assertion is unchanged.
