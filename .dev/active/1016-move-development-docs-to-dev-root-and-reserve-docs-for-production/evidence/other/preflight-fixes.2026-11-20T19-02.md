# Preflight Fixes — remediation cycle 1 plan

Timestamp: 2026-11-20T19-02
Plan: .dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/remediation-plan.2026-11-20T18-37.md
Signal: PREFLIGHT: REVISIONS REQUIRED (one substantive defect in [P1-T3], returned to the planner)
Validators: installed MCP `validate_orchestration_artifacts` plan route ok; branch CLI `scripts.dev_tools.validate_orchestration_artifacts plan` exit 0 after the fixes.

## Fixes (task text only; no task added, removed or reordered)

1. [P0-T1] | commit-set completeness | Added every untracked `evidence/other/preflight-fixes.*.md` record of this preflight to the commit set, so the record is not left untracked for the later porcelain checks.
2. [P1-T1] | count error | "the four existing cases" changed to "the five existing cases"; `migration-apply.test.ts` holds five `it` cases.
3. [P1-T2] | count error | Disposition "the four existing cases" of `migration-apply.test.ts` changed to "the five existing cases".
4. [P1-T2] | incomplete disposition list | Added the CLI, MCP handler, MCP tools, repo-automation and coverage-contract tests that call the planner, each unaffected because no fixture path lies under a mapped target.
5. [P1-T2] | stale anchor | The per-file `coverageThreshold` entries are stored in `extensions/drm-copilot/jest.development-docs-migration-coverage.json`, which `jest.config.cjs` loads; the acceptance now names that file.
6. [P1-T3] | ambient-state assertion | The porcelain check is now compared with a capture taken immediately before the dry run, so task-check and preflight files written earlier do not make it fail.
7. [P1-T4] | check ordering | The acceptance counts against `HEAD` are checked before the task's own commit.
8. [P1-T5] | check ordering | The `git diff HEAD` and count acceptance is checked before the task's own commit, so it cannot pass vacuously after the commit.
9. [P1-T7] | sweep scope (CI-only class) | Suffix matching is case-insensitive (`Integration.Tests.ps1` files), and the tracked `*.bats` files under `tests/shell/` are in scope, because the `shell-coverage` CI job runs them on a clean checkout and no local gate in the plan does. A preflight search found no moved-root token in any tracked bats or shell test file.
10. [P2-T3] | unsatisfiable observation | PoshQC format has no check mode; a clean format step is now observed as identical porcelain output before and after the formatter run.
