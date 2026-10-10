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
