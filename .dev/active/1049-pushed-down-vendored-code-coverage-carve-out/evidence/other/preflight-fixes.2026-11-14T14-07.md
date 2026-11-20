# Preflight Fixes - Issue #1049

Timestamp: 2026-11-14T14-07
Plan: docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/plan.2026-10-31T14-03.md
Validator: branch Python CLI `plan` subcommand exit 0 after the fixes; installed MCP validator ok.

## Fixes

1. [P1-T1] | literal formatting | The JSON-escape list held the raw byte-order mark, U+00E9 and U+4E2D characters where the escapes were intended. They are replaced with the escape spellings `\ufeff`, `\u00e9` and `\u4e2d`, so the task text names the escapes that the acceptance condition ("no byte above `7F`") requires. The asserted digests and case list are unchanged.
2. [P1-T3] | wording / call shape | "run `runPushDownPipeline` then `applyPushDownPlan`" now reads "in the call shape recorded in [P0-T1]", with a note that child 4's pipeline applies through `applyPushDownPlan` unless `dryRun`, so the apply step runs once. The test names and assertions are unchanged.
3. [P0-T6] | result source (validator-blind) | Added that a non-zero `ExitCode` run reads its counts and coverage from the per-shard files under `artifacts/pester/parallel/`, because merged JUnit and coverage files exist only after a fully green run (`execution-environment`, `## PowerShell Route and PoshQC MCP Limits`). The recorded values are unchanged.
4. Preamble, gate loop, Stage 5 | result source (validator-blind) | Same restatement for the phase gates: a Pester run with a non-zero `ExitCode` is read from the per-shard JUnit files. The gate assertions are unchanged.
