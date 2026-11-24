# Preflight Fixes - Issue #1233

Timestamp: 2026-11-24T04-42
Plan: .dev/active/1233-epic-child-ci-opt-out/plan.2026-11-23T22-42.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned to the planner; the fixes below are in place)

## Fixes

1. `## Conventions` (Ledger-region rule) | placement-rule correction keeping the chain-test meaning | The rule required new text at least four lines outside every block `Current` and hunk. That margin cannot be met in `## MCP Surfaces Run the Installed Extension` of the brief (blocks of entries 0002 and 0003 sit within three lines of both ends of the section) or by the P3-T4 bullets placed directly after the `Child-CI helper (#1130)` and `Epic-child dispatch (#1130)` bullets, which neighbour the 0002 blocks on the `Merge guard (#1097)` and `Concurrent-review join (#1097)` bullets. The chain module matches block `Current` text and hunk lines as whole-line sequences, so adjacency does not break a revert. The rule now forbids editing a recorded line or placing a new line between two lines of one recorded region, and keeps the four-line margin where the section allows it. The acceptance condition, `ProcessReductionChain.Ledger.Tests.ps1` passing, is unchanged.
2. `## Targeted Selections` (Set W) | selection citation aligned with the task-check rule | Set W omitted contract tests that read paths the plan edits. It now states that it includes every other test that reads an edited path, as the task-check rule selects it, and names `test_execution_environment_brief_contracts.py`, `test_epic_skill_script_citations_shipped.py`, and `cross-epic-skill-contract.Tests.ps1`.
3. [P0-T1] | validator-blind tool-mode defect | `Invoke-PoshQCFormat` has no check mode. The task now runs it with a non-writing `-WriteFile` seam, records the count of `Formatted:` lines as the drift count, and observes `git status --porcelain` before and after. The assertion (no file rewritten, finding count recorded) is unchanged.
4. [P5-T1] | validator-blind tool-mode defect | Same correction for the final format step: the non-writing seam prints no `Formatted:` line for a changed file and `git status --porcelain` is unchanged.
5. [P0-T6] | stale suite name | The launcher `jest` suite runs the repository-root Jest project; the extension files in scope run under the configured `jest-extension` suite (`config/test-execution-policy.json`). Changed to `jest-extension`.
6. [P5-T6] | stale suite name | Same correction: `jest-extension`.
7. [P5-T3] | validator-blind defect (tool not configured) | No `.dependency-cruiser.cjs` exists in the repository and no package script runs dependency-cruiser. The architecture-boundary stage is now recorded as the search for that configuration file with its command, exit code, and result, not as `SKIPPED`; the remaining static steps and the zero-finding acceptance are unchanged.
8. [P4-T1] (Content) | orchestrator note: stand-in ledger merge line | `Merge commit: pending (PR #N)` with N the open pull request became `Merge commit: pending (PR #1233)`, the canonical issue number as a stand-in (precedent: entries 0004 and 0005), which the orchestrator replaces with the pull request number right after PR creation. The form still satisfies `Get-ProcessReductionSummaryError`.
9. [P4-T1] (Precondition) | orchestrator note: no open pull request before Phase 4 | The precondition that an open pull request exists was replaced with "none beyond the Phase 3 push", because the pull request opens after the feature review.
10. `## Pre-Mortem` (Evidence bullet) | consistency with fix 8 | The bullet now states that `Merge commit:` is written as `pending (PR #1233)` and replaced with the pull request number right after PR creation.

## Self-check

Each fix was checked against the plan's rules and the tone policy: no fix adds, removes, or reorders a task, no fix changes what an acceptance condition asserts, and the fix text uses neutral wording.
