# Preflight Fixes — Stage B plan (planning refresh 2026-11-14)

Timestamp: 2026-11-14T20-11
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md
Command: env -u VIRTUAL_ENV poetry -C <worktree> run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>; MCP validate_orchestration_artifacts (artifact_type plan)
EXIT_CODE: 0
Output Summary: both validators pass before and after the fixes below; the plan has 39 canonical tasks and carries a `## Size Justification` section (the legacy 40/400 pair applies to this pre-cutoff plan stamp). Substantive defects are returned separately in the preflight signal (PREFLIGHT: REVISIONS REQUIRED).

## Fixes (task text and preamble only; no task added, removed or reordered)

1. Terms and Defined Sets (`UPDATE_SET`) | inconsistent set definition | `## Existing Tests Asserting Changed Behavior` states that `test_plan_templates_carry_premortem_skeleton` fails after the apply and passes after [P3-T4], but `UPDATE_SET` (the allowed-failure set of the [P2-T4] gate) admitted only tests that a Phase 3 task names as updated, so [P2-T4] could not pass. `UPDATE_SET` now also admits each test that table states fails after the apply and passes after a named Phase 3 task.
2. [P1-T3] (class `X`) | incomplete classification rule | With `in_tree_rewrite_scope` `links-only` (A3), files inside the moved trees keep their prefix text, so a test literal compared with such text and rewritten by the tool fails (for example the `docs/engineering/legacy-discovery-and-parity/enforcement.md` assertion over `claude-code-architecture.md` in `test_discovery_documentation_contracts.py`). Class `X` now also covers text of a file inside a moved tree that `links-only` leaves unrewritten.
3. [P0-T4] | missing mechanical precondition and non-existent tool modes | Added the `npm --prefix extensions/drm-copilot ci` install (the worktree holds no `node_modules`); dependency-cruiser has no configuration in the repository and is recorded as not configured, as in stage A; the PowerShell formatter check runs `Invoke-PoshQCFormat` with a non-writing `-WriteFile` seam and counts `Formatted:` lines, because the formatter has no check mode and a write run would repair drift before the baseline.
4. [P0-T5] | wrong launcher suite | The built-in `jest` suite runs the repository-root `run-jest.cjs` configuration, not the extension configuration that holds the per-file `coverageThreshold` map; the suite is now `jest-extension` with the `test:coverage` reporter arguments and no positional test path (a positional path after the launcher suite is consumed by the appended ignore-pattern option).
5. [P5-T1] | non-existent tool modes | Same dependency-cruiser and formatter-check corrections as fix 3; the final formatter check asserts 0 `Formatted:` lines.
6. [P5-T2] | wrong launcher suite | Same suite correction as fix 4.

Each fix keeps the meaning of the acceptance it supports and was checked against the tonality and evidence rules the plan enforces.
