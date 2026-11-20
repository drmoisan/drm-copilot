# Preflight Fixes — Stage A plan (planning refresh 2026-11-14)

Timestamp: 2026-11-14T19-15
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T18-59.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>; MCP validate_orchestration_artifacts (artifact_type plan)
EXIT_CODE: 0
Output Summary: both validators pass before and after the fixes below; the plan has 187 physical lines and 29 canonical tasks (legacy pair 40/400 applies to this pre-cutoff stamp). Substantive defects are returned separately in the preflight signal.

## Fixes (task text only; no task added, removed or reordered)

1. [P0-T3] | missing mechanical precondition (tool route) | Prefixed the dependency install of `extensions/drm-copilot` (`npm --prefix extensions/drm-copilot ci`); the worktree holds no `node_modules`, so format, lint, type check and Jest cannot run without it. Assertions unchanged.
2. [P0-T4] | tool route rejected by a hook | Replaced "one run of the `test:coverage` script" with one coverage run through the test-execution launcher route of the `execution-environment` skill using the `test:coverage` reporter arguments; the test-execution PreToolUse hook denies an npm `test:` script and a direct `run-jest.cjs` call. Assertions unchanged.
3. [P2-T7] | tool route rejected by a hook | Same route correction for the coverage-mode phase gate. Assertions unchanged.
4. [P4-T3] | tool route rejected by a hook | Same route correction for the final coverage gate. Assertions unchanged.
5. [P2-T3] | acceptance wording names a runner that cannot run the named suites | "one Jest run over ... every existing suite named above" covered Python and Pester readers; narrowed to the named Jest suites and stated that the named Python and Pester readers run in the task check through the launcher with 0 failed.
6. [P2-T4] | enumeration omission in a pass-through test row | Added `--workspace` -> `workspace_root` to the flags asserted to reach the execute function, matching the task's flag list and spec `### CLI`.
7. Scope and Conventions (test gates bullet) and [P2-T5] | missing existing-test disposition | Recorded that `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` reads `extensions/drm-copilot/jest.config.cjs` through the `0010-early-dependent-starts.patch` hunk, gave "PRC-LEDGER-CHAIN-HOLDS" and "PRC-LEDGER-SUBCHAIN-HOLDS" the disposition unchanged (merge line beside `...docsCoverageThresholds`, outside the hunk context), and added that file to the [P2-T5] task-check acceptance. No ledger file is edited.
