# Preflight Fixes (round two)

Timestamp: 2026-10-30T23-50
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/plan.2026-10-30T18-40.md

## Round-one defect confirmation

The round-one substantive defect is resolved. [P2-T4] no longer runs `tests/scripts/claude-runtime/claude-settings.Tests.ps1`; the suite runs in [P6-T4], after the [P6-T1] bundle copy, where its test "requires one dedicated prd-feature stop-hook registration in byte-identical settings files" (`Test-PrdFeatureRegistrationContract`) can pass. The remaining [P2-T4] suites were re-checked: `hook-dependency-guard-completeness.Tests.ps1` builds repository and mirror rows from each root's own settings file, and `hook-imported-modules-no-stdout.Tests.ps1` `N2: mirror findings equal repository findings` compares offender findings rather than file bytes, so neither fails before [P6-T1]. Both are re-run in [P6-T4].

## Fixes (trivial, task text only; no task added, removed or reordered)

1. [P2-T1] Missing design pointer. `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`, run in [P2-T4], derives every PreToolUse hook from `.claude/settings.json` and requires each to reference `Read-ClaudeHookRawPayload`. The task enumerated the skeleton parts without the entry-point function that reads the payload. The task now names that entry-point function and the suite that pins it. No acceptance condition changed.
2. [P7-T1] Observation that could not fail. Identical `git status --porcelain` output before and after the formatter does not show a rewrite of a file that is already modified or untracked, because its status line is unchanged. The acceptance now also compares the SHA-256 of every target file before and after the run. The asserted outcome (the formatter changed nothing) is unchanged.
3. [P7-T11] Evidence source not stated. The executor runs before a pull request exists, so a pull-request run of `ci.yml` may not exist when the task runs. The task now names the run to use: the pull-request run into the integration branch when the pull request exists, otherwise a `workflow_dispatch` run of `ci.yml` on the branch, which is a full run. The listed contexts and the `success` condition are unchanged.

## Validation

- MCP `validate_orchestration_artifacts` (`plan`): ok before the fixes.
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`: passed before the fixes; re-run after the fixes is recorded in the preflight return.
