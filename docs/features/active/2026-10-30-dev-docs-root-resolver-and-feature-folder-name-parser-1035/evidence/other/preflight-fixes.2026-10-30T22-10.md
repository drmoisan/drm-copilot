# Preflight Fixes

Timestamp: 2026-10-30T22-10
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T17-11.md

All fixes are task-text edits only. No task was added, removed, or reordered.

## Fix 1 — [P0-T8] evidence source (validator-blind: value never printed)

- Defect: the acceptance demands per-file line and branch percentages, but `npm run test:coverage` passes `--coverageReporters=lcov --coverageReporters=text-summary`, and `text-summary` prints totals only.
- Change: the acceptance names `extensions/drm-copilot/coverage/lcov.info` (the Jest `coverageDirectory` output) as the source of the per-file figures. The asserted values are unchanged.

## Fix 2 — [P10-T6] evidence source (same class as Fix 1)

- Change: the per-file percentages are read from `extensions/drm-copilot/coverage/lcov.info`.

## Fix 3 — [P0-T9] write-mode formatter described as a check (rule G7 class, validator-blind)

- Defect: `Invoke-PoshQCFormat` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` has no check mode and rewrites files that differ. A baseline "format check" would repair existing formatting drift before Phase 1, and its exit code shows no difference between a clean run and a repairing run.
- Change: the format check runs `Invoke-PoshQCFormat` with a no-op `-WriteFile` script block, so no file is rewritten, and the baseline records the count of `Formatted:` log lines. The command is still a format check.

## Fix 4 — [P10-T7] success observation for the formatter (same class as Fix 3)

- Change: the task uses the no-op `-WriteFile` form, and the acceptance records the observable success output: no `Formatted:` line, with every file logging `Already formatted:`.

## Fix 5 — [P1-T5] stale description of a target

- Defect: the task said to "widen the module docstring", but `scripts/dev_tools/json_config.py` has no module docstring.
- Change: the task now says to add a module docstring that describes the module as repository layout configuration. The intent is unchanged.

## Fix 6 — [P4-T2] asserting tests not named (validator-blind: changed-behavior test disposition)

- Defect: `test/extension.workflow-commands.test.ts` (`newPotentialEntry passes the bundled script path and short-name args`) and `test/extension.integration.test.ts` (`newPotentialEntry succeeds in a workspace without docs/features/templates using bundled templates`) both assert the `newPotentialEntry` invocation, and the task did not name either one.
- Change: both tests are now named with the disposition "unchanged (default argv per D-P4)". The assertion is unchanged.

## Fix 7 — [P6-T3] parity verification timing

- Defect: `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` hash-compares the Claude and Codex helpers with their bundle copies, and those copies are produced only by P6-T12. The task stated that the suite passes at P6-T3.
- Change: the helpers `Parity` suite is verified after P6-T12. This follows the pattern P6-T5 already uses for `enforce-completion-consistency-codex.Tests.ps1`. The assertion is unchanged, and only the point at which it is checked moves.
