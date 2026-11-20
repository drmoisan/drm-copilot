# Preflight Fixes — Main Plan Confirming Preflight (after the planner revision)

Timestamp: 2026-11-14T19-56
Plan: plan.2026-10-30T18-39.md
Signal: PREFLIGHT: ALL CLEAR

## Fix 1 — [P1-T1] task text did not state the port its own acceptance requires

- Defect class: task text inconsistent with its own acceptance condition and spec `## Scope` item 1 (intent unambiguous; assertion unchanged).
- Finding: the P1-T1 acceptance requires that "any owner-overridden port is quoted with its `.agents/skills/<name>/SKILL.md` location", and spec `## Scope` item 1 and AC3 require the port when child 1's `## Owner Overrides` overrides U1 or U2 or child 1 classes U3 `positive`. The task text stated only the default classes and gave no instruction to make the port.
- Change: the task text now states that in those cases the section is ported into `.agents/skills/<name>/SKILL.md`, the `.claude` copy is regenerated with child 3's generator, and both bundles are copied. The acceptance condition is unchanged.

## Fix 2 — `## Edit Set` did not list the conditional port target

- Defect class: preamble file list inconsistent with a task (conditional target named by spec `## Scope` item 1).
- Change: the Markdown line of `## Edit Set` now lists `.agents/skills/<name>/SKILL.md` with its generated `.claude` copy and bundle copies, only for a P1-T1 port, so the P0-T1 anchor re-check and the P0-T2 region map cover it.

## Round-1 Revisions Verified

- [P1-T2]: `test_execution_environment_fact_is_unchanged_across_copies` keeps its `rglob` discovery, leaves out both retired trees and asserts the `REMAINING-BRIEF-COPIES` count; with the retired copies present the remaining copies are byte-identical, so the test passes before and after P1-T9. The other Phase 1 test edits (P1-T3 to P1-T8) drop explicit retired rows or retarget to `.agents` copies that already exist and hold the asserted tokens (probed for `test_csharp_orchestration_contracts.py` and `test_minor_audit_acceptance_criteria_contracts.py`), so each passes before and after the deletion.
- [P1-T15]: the collision-controls record carries `## Child 4 Request`.
- [P0-T3], [P0-T4], [P0-T5]: `E6Result:`, `CodexAgentsProvenance:` and `DestinationCleanupOwner:` are recorded.
- `## Derivation Rules`: the result file names `e3-copilot-cli-cloud-claude-agents-result`, `e4-copilot-workspace-settings-result`, `e6-copilot-default-double-load-result` and the observation lines `CLI-Lists-Claude-Agent:`, `Cloud-Lists-Claude-Agent:`, `Workspace-Settings-Honored:` match child 1's `plan.2026-10-30T17-06.md` P3-T4 to P3-T6 and `owner-decision-plan.md` `## Decision Application Rules` rules 6 and 7.
- `plan-h3-sync-writer-retirement.md`: every main-plan term it cites (`<FEATURE>`, `MB`, `SCRATCH`, `GATE-RUN`, `LEDGER-STEP`, `GUARD-SUITE`, `LAST-PLAN-CRITERIA`, the `Plan:` rule) is defined in the main plan `## Terms`; `GUARD-SUITE` is created by P1-T17; the `plan-completion-branch.*.md` and `plan-completion-h3.*.md` records are written by the branch plans and the H3 plan respectively.

## Validation

- Command: repository Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` on the plan, through Poetry in the worktree, after the fixes.
- EXIT_CODE: 0
- Output Summary: `plan validation passed`; the MCP validator also returned `ok: true`.
