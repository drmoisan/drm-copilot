# Preflight Fixes, Round 2 (issue #1201)

Timestamp: 2026-11-17T20-16
Plan: docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/plan.2026-11-17T14-05.md
Validators after the fixes: MCP `validate_orchestration_artifacts` (plan) ok; branch-current Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan` exit 0. Size: 18 canonical tasks, 93 physical lines.

Each fix edits task text or plan preamble only; no task was added, removed, or reordered. The round-1 record `preflight-fixes.2026-11-17T20-00.md` is unchanged.

## Round-1 Defects Re-Checked

All seven round-1 substantive defects are resolved in revision 1: parser rule rows (P1-T1), relevance rows for separate-value global options (P1-T1), container-seam throw rows (P1-T2, P1-T3 AC-12), the empty-segment `RELEASE_ALLOWANCE_COMMAND_NOT_MODELLED` row with its premise note (Terms, P1-T3 AC-13), staged-index call counts (P1-T3), the case-different `-C` allow row (P1-T3), and the `$script:ReleaseAllowance` naming assertion with its discriminating companion row (P2-T4). A classification probe run from SCRATCH confirmed that both gates classify every planned decision-row command as an implementation command, so each row reaches the release leg.

## Fixes

1. [P1-T3] | validator-blind: test isolation (suite reads ambient filesystem state) | Added null-shaped mocks of `Test-OrchestrationDocsEstateCheckpointPresent` and, behind a `Get-Command` guard, `Get-WorktreeResolutionGitFileText`. Without them the #1169 docs-estate leg, whose command shape admits `git add -- package.json` and a pathless `git commit`, resolves the session root and probes its `artifacts/` checkpoint files and docs profile on disk. The decision outcome and every asserted call count are the same with or without the mocks, because no docs profile exists; the mocks remove the read of gitignored state that the plan's Test isolation bullet and the spec's test constraints exclude.
2. `## Existing-Behavior Test Search` | validator-blind: brief readers not all named | Added `cleanup-merged-worktrees.SkillText.Tests.ps1`, `enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1`, `docs-authoring-roles.WorkflowText.Tests.ps1`, `test_bash_command_shape_surfaces.py`, `test_discovery_documentation_contracts.py`, and `test_single_pass_preflight_contracts.py` to the brief-reader disposition list. Each reads the execution-environment brief by section text or token containment and is unchanged by an added bullet and two added list entries.
