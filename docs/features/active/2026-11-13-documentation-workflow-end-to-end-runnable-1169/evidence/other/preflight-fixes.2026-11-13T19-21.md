# Preflight Fixes - Issue #1169 (round 2)

Timestamp: 2026-11-13T19-21
Plan: docs/features/active/2026-11-13-documentation-workflow-end-to-end-runnable-1169/plan.2026-11-13T12-10.md
Signal: PREFLIGHT: ALL CLEAR (task-text edits only; no task added, removed, or reordered; the round-1 record preflight-fixes.2026-11-13T19-06.md is unchanged)
Validators after the fixes: branch-current Python CLI `validate_orchestration_artifacts.py plan` exit 0; installed MCP `validate_orchestration_artifacts` ok.

## Fixes

1. [P5-T3] | stale anchor | The plan cited `### validate` of `command-reference.md`; the heading in the tree carries the subcommand name in backticks, as every subsection under `## Subcommands` does. The two citations now name the `validate` subsection and state its scope (level-three heading to the next level-three heading), so the section-scoped test locates it.
2. [P5-T3] | omitted edit within the stated intent | `command-reference.md` states that `-Revision` is required, and `## Receipt Persistence` of `workflow.md` shows `-Revision <head revision> -WriteReceipt`. Both contradict the default the task documents. The task text now names both edits. No assertion is added or changed.
3. [P5-T1] | executor-selected evidence | The step-order assertion did not state how each step is located, leaving the executor to choose the tokens it is judged against. The task now fixes the locating tokens (commit `git commit -F`, receipt `-WriteReceipt`, push `git push`, delegate `Agent(pr-author)`, first ordinal occurrence within the section) and the commit step's `git add --`, which are the forms spec A5 step 1 prescribes. The assertion is still the step order of the spec; the tokens satisfy the existing option-reference row (`-WriteReceipt` is a `validate` table option) and the rule that no `-Command` line holds a `git` or `gh` command.

## Round-1 Defects Confirmed Resolved

- [P2-T2]: `TestAncestor` and `ListChangedPath` are specified with argv, exit mapping (0, 1, other, timeout), NUL handling, invalid-revision throw, and tests in `Invoke-DocsCommand.RevisionContext.Tests.ps1`. `New-DocsTestContext`, `New-DocumentationEstateFixtureContext`, and `New-DocsLedgerTestContext` gain the members; the member-name pins in `DocsLedger.TestSupport.Tests.ps1` (updated) and `Invoke-DocsCommand.Tests.ps1` (order kept by appending after `ReadRevisionText`) were checked against the tree. The real context has ten members today, so twelve after the change matches the stated count.
- [P5-T1]: tracking-issue, checkpoint-at-root decline, and docs-path-only rules each have a section-scoped token assertion per copy.
- [P5-T3]: per-copy docs-init row and per-section onboarding, command-reference, and workflow cases with in-memory negative rows.
- [P5-T4]: one row per execution-environment copy (six named) for the bullet and the four suite names; the 0011 ledgered region is excluded.

## Checks Performed Without a Fix

- Every existing file and suite cited by the plan resolves in the tree; uncited names are files the plan creates.
- `Get-DocsCommandUsage` does not print a row note today; the tests reading the usage or the command table (`Invoke-DocsCommand.Tests.ps1` help case, `DocsReferenceWriter.Tests.ps1`, `DocsInventory.Tests.ps1`, `DocsPageCheck.Tests.ps1`, `DocsSurfaceDeltaCommands.Tests.ps1`, `DocumentationEstateOnboarding.Tests.ps1`) assert rows other than `validate`, row counts, or a usage count above one, so the note and the module change of the `validate` row break none of them.
- `cleanup-merged-worktrees.SkillText.Tests.ps1` asserts cleanup tokens in `## Hook Execution Context` only; a new bullet does not affect it. `test_execution_environment_brief_contracts.py` includes G11/G12 and consuming-name checks over the brief, which the new bullet text must also satisfy.
- Plan size: 29 tasks, 104 lines, non-empty `## Size Justification`.
