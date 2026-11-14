# Remediation Inputs - Issue #1037 (feature review 2026-11-07T17-30)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate

- Feature folder: `docs/features/active/2026-10-30-docs-authoring-workflow-1037`
- Branch: `feature/docs-authoring-workflow-1037-r2` at `68845d93483433928502bfa4b75eb13cee8a5c30`
- Base: `origin/epic/documentation-estate-tooling-integration`; merge base `6baed77f6b3be8d98a70c15342d7c8722e35c342`; current tip `098b6edfe89b4c2d8a2095718b538d1edbeabf10`
- Source artifacts:
  - `docs/features/active/2026-10-30-docs-authoring-workflow-1037/policy-audit.2026-11-07T17-30.md`
  - `docs/features/active/2026-10-30-docs-authoring-workflow-1037/code-review.2026-11-07T17-30.md`
  - `docs/features/active/2026-10-30-docs-authoring-workflow-1037/feature-audit.2026-11-07T17-30.md`
- Target plan path: `docs/features/active/2026-10-30-docs-authoring-workflow-1037/remediation-plan.2026-11-07T17-30.md` (to be authored by `atomic-planner`)
- Findings requiring remediation: 2 (1 autonomous, 1 owner decision).

## Remediation-Required Findings

### PA-1 - The branch conflicts with the base tip

- Severity: Blocking
- Status: FAIL
- Source: `policy-audit.2026-11-07T17-30.md` `## Base Synchronization`; code review Findings Table row 1.
- File: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- Finding: `git merge-tree --write-tree HEAD origin/epic/documentation-estate-tooling-integration` reports one content conflict. The branch adds `.claude/hooks/enforce-docs-role-write-scope.ps1` and the base (main sync #1109) adds `.claude/hooks/enforce-epic-merge-gate-review.ps1` at the same line. The branch is 195 commits behind the tip. The Codex core manifest also changed on the base and merges cleanly. No other file the branch touches changed on the base.
- Remediability: autonomous
- Remediability-Evidence: the resolution keeps both manifest lines and is performed in the item worktree with no shared decision, owner input or external party.
- Finding-Scope: design
- Required action:
  1. Merge `origin/epic/documentation-estate-tooling-integration` into the branch.
  2. Resolve the conflict by keeping both lines in the existing order of the file.
  3. Re-run the Codex generator `--check`, the contract tests, one `Invoke-PoshQCParallelTest` run with coverage and one `pytest -n auto` run at the merged head, and record them under `evidence/`.
  4. Re-confirm the byte identity of the 64 bundle pairs and the three routing copies.
- Expected result: `git merge-tree` against the tip reports no conflict; all gates pass at the merged head; each new hook keeps at least 85% line coverage.
- On completion: re-evaluate spec AC 9, spec AC 12 and user-story AC 7 and 9 against the merged head.

### PA-2 - Spec AC 9, spec AC 11 and user-story AC 7 cannot be met as written

- Severity: Blocking
- Status: PARTIAL
- Source: `feature-audit.2026-11-07T17-30.md` rows spec 9, spec 11, story 7; code review Findings Table row 2; plan note N4.
- File: `docs/features/active/2026-10-30-docs-authoring-workflow-1037/spec.md`, `docs/features/active/2026-10-30-docs-authoring-workflow-1037/user-story.md`
- Finding: each criterion requires existing contract tests, including `hook-dependency-failure.Claude.Tests.ps1`, to pass "without modification". Test B4 of that file, test U2 of `subagentstop-uncaught-error.Tests.ps1` and the #1026 inventory test of `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` each fail when a registered hook has no row, so the in-scope hooks require one added row each. The branch adds rows only and removes or loosens no assertion. Every other part of the three criteria is met. The sibling 1034 specification worded its equivalent criterion as passing "with the new `$script:ReasonPrefix` row".
- Remediability: human_decision_required
- Remediability-Evidence: the only resolution is a change to acceptance-criterion text or an accepted deviation; the executor cannot meet the clause without breaking those guard tests, and the reviewer may not edit criterion text.
- Finding-Scope: design
- Decision requested from the owner (one of):
  1. Amend the three criteria to read that the named tests pass "with only the additive rows that their completeness checks require for the new hooks", then check them off; no code change is needed.
  2. Accept the deviation as recorded and check off the three criteria in a specification revision.
- Expected result: spec AC 9, spec AC 11 and user-story AC 7 are checked off or formally deviated.

## Non-Blocking Notes

These do not affect the verdict. Details are in the code review Findings Table.

- Minor: `docs-authoring-roles.Skills.Tests.ps1` asserts exactly nine dispatch rows; a later child that adds a subcommand breaks it. Replace it with a membership check or `Should -BeGreaterOrEqual 9` in the PA-1 cycle.
- Info: the write-scope hook allows an unparseable payload; the new PreToolUse group starts `pwsh` on every Write-class and Bash call in every session; rule 5 reads only the default profile path; Codex and Copilot `docs-author` copies have no write-scope hook (OQ-2).

## Waived, Not a Finding

Spec AC 16 (seeded shuffled and single-process runs) is waived by the owner directive of 2026-11-07.

## Pending, Not a Finding

Spec AC 17 and user-story AC 11 are CI-dependent and are owned by the S9 CI green gate after the pull request exists.

## Constraints for the Plan

- Parallel test gates only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run as the final gates.
- Hooks and their bundle copies stay byte-identical; no Python or TypeScript file is added or modified.
