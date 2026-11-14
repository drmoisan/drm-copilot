# Preflight Fixes — H3 Sync-Writer Retirement Plan (2026-11-14 refresh)

Timestamp: 2026-11-14T19-22
Plan: plan-h3-sync-writer-retirement.md
Signal: PREFLIGHT: ALL CLEAR (the fixes below are trivial and were applied in place in task text only; no task was added, removed or reordered)

## Fix 1 — [P0-T2] unnamed Jest suites

- Defect class: anchor completeness (a set named by count only).
- Finding: the task named "four Jest suites" without naming them.
- Change: the task now names `extension.test.ts`, `extension.integration.test.ts`, `extension.workflow-commands.test.ts` and `lib/push-down/reference-rewrites.test.ts` under `extensions/drm-copilot/test`, the four suites P1-T2 and P1-T3 edit. The baseline scope is unchanged.

## Fix 2 — [P1-T2] disposition statement about `contributes.commands`

- Defect class: citation correction (changed-behavior test disposition).
- Finding: the task stated that no test counts `contributes.commands`. `test_cli_reference_lists_every_discovery_mcp_tool_and_command` in `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` counts the `contributes.commands` entries whose id holds `iscovery` (13); the writer command does not match that filter, so the test is unaffected, as the task already listed it. `registers the seven existing command ids and the six new ones` was cited without its file.
- Change: the sentence now states that the discovery test counts only discovery commands and that no test counts every entry, and names `extension.discovery-commands.test.ts` for the second test. Dispositions are unchanged.

## Fix 3 — [P1-T4] tests that read the repository `tasks.json`

- Defect class: citation correction (changed-behavior test disposition, validator-blind).
- Finding: the task stated that no test reads the repository `.vscode/tasks.json`. Two suites do: `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1` (indexes every task by label; `VT-DEPENDS-ON-RESOLVES` resolves every `dependsOn` name) and the `CODE` row of `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` (phrase scan with `.vscode/tasks.json` as a file root). The removed task carries only the script argument and the label `Dev: Sync AGENTS.md from Instructions`, and no `dependsOn` in the file names that label, so both suites are unaffected.
- Change: the task now names both suites with disposition unchanged (unaffected) and the reason; the three fixture-building tests keep their disposition. The acceptance is unchanged; the task-check selection rule already adds contract tests that read a changed configuration path.

## Fix 4 — [P2-T6] self-review input

- Defect class: wording aligned with the plan contract (`## Design-Level Plan Contract (Mandatory)`, final-phase self-review walks the templates against the branch diff from the merge base).
- Finding: the task walked the templates against this plan's commits only.
- Change: the task now walks the templates against the branch diff from `MB`, which includes this plan's commits, matching the main plan's P2-T9. The artifact name, `Plan:` value and no-FAIL acceptance are unchanged.

## Validation

- Command: repository Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` on the plan, run through Poetry in the item worktree after the fixes; and `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: plan`.
- EXIT_CODE: 0
- Output Summary: Python CLI printed `plan validation passed`; MCP returned `ok: true`. The plan holds 21 canonical tasks... see note below.

Note: the plan holds 20 canonical tasks (P0: 5, P1: 7, P2: 6 = 18) and 117 physical lines, within the 20-task and 250-line guideline.

## Correction (appended 2026-11-14T19-22)

- The `Output Summary:` line and the note above state the task count incorrectly. The plan holds 18 canonical tasks (Phase 0: 5, Phase 1: 7, Phase 2: 6) and 117 physical lines, within the 20-task and 250-line guideline. The validator results recorded above are unchanged: the Python CLI printed `plan validation passed` (exit 0) and MCP returned `ok: true`.
