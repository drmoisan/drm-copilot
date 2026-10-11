# Execution Deviations — Issue #791 (Phases 0-2 run)

Timestamp: 2026-10-10T08-02
Plan: `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/plan.2026-10-08T13-56.md`

Each entry records the task ID, the planned mechanism, the substituted mechanism, and the reason.

## [P0-T11]
- Planned mechanism: `npx --yes bats tests/shell/parallel_payload_only.bats tests/shell/parallel_bash_manifest_membership.bats` run locally; record EXIT_CODE, TAP plan line, and `not ok` lines.
- Substituted mechanism: command not run; artifact records `CI-DEFERRED: yes`; the baseline TAP plan count is to be taken from the CI bats job log on the pull request.
- Reason: operator constraint (local bats execution prohibited in this worktree).

## [P0-T13]
- Planned mechanism: create scratchpad runners `run-ps-791.sh`, `pssa-791.ps1`, `format-check-791.ps1`, `pester-791.ps1`; run `sh <scratchpad>/run-ps-791.sh <scratchpad>/pssa-791.ps1` and record `PSSA_FINDINGS=<count>`.
- Substituted mechanism: no runner created; `mcp__drm-copilot__run_poshqc_analyze` called with workspace_root = worktree root; call disposition recorded; `PSSA_FINDINGS` recorded as `CI-DEFERRED: yes` (from the CI PowerShell job log on the pull request).
- Reason: operator constraint (PowerShell verification only through the PoshQC MCP tools; no sh/bash/pwsh wrapper scripts).

## [P0-T14]
- Planned mechanism: `sh <scratchpad>/run-ps-791.sh <scratchpad>/format-check-791.ps1` (non-writing) and record `FORMAT_CLEAN`/`FORMAT_DRIFT`.
- Substituted mechanism: `mcp__drm-copilot__run_poshqc_format` called with workspace_root = worktree root; `git status --porcelain` recorded before and after (identical; no tracked file modified); FORMAT token recorded as `CI-DEFERRED: yes`.
- Reason: operator constraint (PowerShell verification only through the PoshQC MCP tools).

## [P0-T15]
- Planned mechanism: `sh <scratchpad>/run-ps-791.sh <scratchpad>/pester-791.ps1` with code coverage over `.claude/hooks/enforce-parallel-abandon-gate.ps1` and `.claude/hooks/hook-command-scanner.ps1`; record `Tests Passed:` and the `Covered` percentage; task incomplete when no `Covered` line is printed.
- Substituted mechanism: `mcp__drm-copilot__run_poshqc_test` called with scan_folders = `tests/scripts/claude-hooks`, `tests/scripts/claude-runtime`; call disposition recorded; `Tests Passed` and `Covered %` recorded as `CI-DEFERRED: yes` (from the CI PowerShell job log on the pull request). Task marked complete per the operator constraint.
- Reason: operator constraint (PowerShell verification only through the PoshQC MCP tools; MCP results carry no analyzer/test output).

## Phase-boundary commits
- Planned mechanism: the plan defines no per-phase commit.
- Substituted mechanism: `git add -A`, `git commit -F <scratchpad message file>`, and `git push origin bug/issue-763-parallel-skill-cli-port-follow-ups-791` after each of Phases 0, 1, and 2.
- Reason: operator constraint.

## Phases 3-4 run (2026-10-10T08-19)

## Phase-boundary commits (Phases 3 and 4)
- Task ID: phase boundaries after [P3-T9] and after [P4-T14].
- Planned mechanism: the plan defines no per-phase commit.
- Substituted mechanism: `git fetch origin main` and `git merge-base --is-ancestor origin/main HEAD` (merge `origin/main` with `--no-edit` when main has moved), then `git add -A`, `git commit -F <scratchpad message file>`, and `git push origin bug/issue-763-parallel-skill-cli-port-follow-ups-791` after Phase 3 and after Phase 4.
- Reason: operator constraint.

## Phase 3 pre-commit shell checks
- Task ID: [P3-T1], [P3-T2].
- Planned mechanism: the plan records the shfmt/shellcheck gate in Phase 8 only.
- Substituted mechanism: `shfmt -d` and `shellcheck` were additionally run on the two new bash files before the Phase 3 commit (both exit 0 after fixes); nothing is recorded as gate evidence here, and Phase 8 records the gate.
- Reason: operator constraint.

## [P4-T10]
- Planned mechanism: the task edits the TriggerScoping test only; the plan's PowerShell format/analyze gates use the scratchpad runners.
- Substituted mechanism: `mcp__drm-copilot__run_poshqc_format` and `mcp__drm-copilot__run_poshqc_analyze` (scan_folders = tests/scripts/claude-hooks) were called after the edit, with `git status --porcelain` and `git hash-object` of the edited file captured before and after format; dispositions recorded in `evidence/other/pester-trigger-scoping.2026-10-10T08-30.md`.
- Reason: operator constraint.

## [P4-T11]
- Planned mechanism: `npx --yes bats tests/shell/parallel_mutation_remove.bats` run locally.
- Substituted mechanism: not run; the plan's authorized CI-deferred branch taken with `CI-DEFERRED: yes`, `CI-DEFERRED-ACS: AC-8, AC-9`; verified from the CI bats job log on the pull request.
- Reason: operator constraint (operator constraint prohibits local bats execution).

## [P4-T12]
- Planned mechanism: `command -v python3`, then `npx --yes bats tests/shell/parallel_mutation_remove_parity.bats` run locally.
- Substituted mechanism: `command -v python3` run and recorded (exit 0); bats not run; the plan's authorized CI-deferred branch taken with `CI-DEFERRED: yes`, `CI-DEFERRED-ACS: AC-10`.
- Reason: operator constraint (operator constraint prohibits local bats execution).

## [P4-T13]
- Planned mechanism: `npx --yes bats tests/shell/parallel_payload_only.bats tests/shell/parallel_bash_manifest_membership.bats` run locally.
- Substituted mechanism: not run; the plan's authorized CI-deferred branch taken with `CI-DEFERRED: yes`, `CI-DEFERRED-ACS: AC-11, AC-12`.
- Reason: operator constraint (operator constraint prohibits local bats execution).

## [P4-T14]
- Planned mechanism: `sh <scratchpad>/run-ps-791.sh <scratchpad>/pester-791.ps1`; acceptance requires `Failed: 0` and the new case shown as passed.
- Substituted mechanism: `mcp__drm-copilot__run_poshqc_test` (scan_folders = tests/scripts/claude-hooks, tests/scripts/claude-runtime); call disposition recorded; `Failed` count and the new case result recorded as `CI-DEFERRED: yes`, `CI-DEFERRED-ACS: AC-13` (the MCP result carries no Pester output).
- Reason: operator constraint.

## Phases 5-9 run (2026-10-10T08-34)

## [P5-T6]
- Planned mechanism: `grep -rnE` through the Bash tool.
- Substituted mechanism: none. The operator authorized a Grep-tool substitution if the abandon PreToolUse gate denied the Bash command; the command was not denied (exit 1, no output), so the planned mechanism was used unchanged.
- Reason: operator constraint (recorded for completeness; no substitution taken).

## [P7-T1]
- Planned mechanism: cite the spec D5 line sets; re-read each and record current numbers if they differ.
- Substituted mechanism: none (task-authorized branch). Current numbers differ for `parallel-add` (101, 108, 150; +2) and `parallel-orchestrate` (658, 813, 821; +24) after the `main` merge; `parallel-close` (49, 55, 65) and `_parallel_mutation_errors.py:192` are unchanged. Both the spec and current numbers, with a note, are recorded in `follow-ups.md`.
- Reason: line drift from the earlier `main` merge (recorded per task text, not an operator constraint).

## Artifact timestamp accuracy (Phases 6-7)
- Task ID: [P6-T6], [P6-T7], [P6-T8], [P7-T1].
- Planned mechanism: `<timestamp>` is the execution time in `yyyy-MM-ddTHH-mm` form.
- Substituted mechanism: the artifact names `permission-surface-present.2026-10-10T08-41.md`, `permission-surface-absent.2026-10-10T08-41.md`, `permission-surface-tests.2026-10-10T08-42.md`, and the `Recorded: 2026-10-10T08-46` line of `follow-ups.md` were assigned without reading the clock; a `date` call at the start of Phase 8 returned `2026-10-10T08-39`, so those values are a few minutes later than the actual write times (approximately 08-36 to 08-38). The files were committed under those names and are not renamed (no deletions per operator constraint). From Phase 8 onward every timestamp was read from `date`.
- Reason: executor error; recorded for audit accuracy.

## [P8-T9]
- Planned mechanism: `npx --yes bats` over the four suites, after the `command -v python3` pre-check.
- Substituted mechanism: pre-check run (exit 0); bats not run; authorized bats-cannot-start-equivalent branch recorded with `Reason: operator constraint prohibits local bats execution`, `CI-DEFERRED: yes`, `CI-DEFERRED-ACS: AC-8, AC-9, AC-10, AC-11, AC-12`.
- Reason: operator constraint.

## [P8-T11]
- Planned mechanism: `sh <scratchpad>/run-ps-791.sh <scratchpad>/format-check-791.ps1`, acceptance on `FORMAT_CLEAN`.
- Substituted mechanism: `mcp__drm-copilot__run_poshqc_format` (scan_folders = tests/scripts/claude-hooks) with `git status --porcelain` and `git hash-object` of the TriggerScoping test before and after (identical, so no restart); `CI-DEFERRED: yes`.
- Reason: operator constraint.

## [P8-T12]
- Planned mechanism: record the `mcp__drm-copilot__run_poshqc_analyze` disposition, then `sh <scratchpad>/run-ps-791.sh <scratchpad>/pssa-791.ps1`, acceptance on `PSSA_FINDINGS=0`.
- Substituted mechanism: `mcp__drm-copilot__run_poshqc_analyze` (scan_folders = tests/scripts/claude-hooks) only; disposition recorded (returned, ok true); finding count `CI-DEFERRED: yes`.
- Reason: operator constraint.

## [P8-T13]
- Planned mechanism: `sh <scratchpad>/run-ps-791.sh <scratchpad>/pester-791.ps1`, acceptance on `Failed: 0` and the `Covered` percentage >= the [P0-T15] value.
- Substituted mechanism: `mcp__drm-copilot__run_poshqc_test` (scan_folders = tests/scripts/claude-hooks, tests/scripts/claude-runtime); disposition recorded (returned, ok true); counts and coverage `CI-DEFERRED: yes`, `CI-DEFERRED-ACS: AC-13`.
- Reason: operator constraint.

## [P9-T1] and [P9-T2]
- Planned mechanism: deferred AC set = union of `CI-DEFERRED-ACS:` lines across [P4-T11], [P4-T12], [P4-T13], [P8-T9]; acceptance: checked + unchecked = 21 and unchecked = 1 (AC-18) + that set's size.
- Substituted mechanism: AC-13 is additionally left unchecked as PENDING-CI; the union is taken across [P4-T11], [P4-T12], [P4-T13], [P4-T14], [P8-T9], [P8-T13] (AC-8, AC-9, AC-10, AC-11, AC-12, AC-13). Result: 14 checked, 7 unchecked (AC-8..AC-13, AC-18), sum 21. The adjustment is also recorded in `evidence/qa-gates/ac-checkoff.2026-10-10T08-46.md`.
- Reason: operator constraint (AC-13 Pester evidence is CI-deferred).

## Phase-boundary commits (Phases 5-9)
- Task ID: phase boundaries after [P5-T7], [P6-T8], [P7-T1], [P8-T17], and [P9-T2].
- Planned mechanism: the plan defines no per-phase commit.
- Substituted mechanism: `git fetch origin main` and `git merge-base --is-ancestor origin/main HEAD` (merge `origin/main` with `--no-edit` when main has moved), then `git add -A`, `git commit -F <scratchpad message file>`, and `git push origin bug/issue-763-parallel-skill-cli-port-follow-ups-791`.
- Reason: operator constraint.
