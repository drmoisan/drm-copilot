# Preflight Fixes — Issue #1231

Timestamp: 2026-11-23T23-24
Plan: .dev/active/1231-pr-author-release-exemption/plan.2026-11-23T17-58.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive design-check gaps returned separately)

## Fixes Applied In Place

1. [P0-T1] | unsatisfiable literal (porcelain state) | "`git status --porcelain` is empty before and after" changed to "unchanged before and after". The worktree already holds the modified plan file and this record, so an empty porcelain listing cannot be observed; the asserted meaning (the formatter rewrites no file) is kept.
2. [P2-T2] | unanchored-to-working-tree absence check (G8b class) | "not in the diff from `MB`" changed to "neither in the diff from `MB` nor in `git status --porcelain`". A merge-base diff is blind to uncommitted edits, so the absence check could not fail before a commit; the meaning is kept.
3. [P3-T2] | same class as fix 2 | the `.codex/agents/pr-author.toml` absence check now also reads `git status --porcelain`.
4. [P3-T2] | incomplete mirror path list | the byte-copy step now names `.agents/skills/pr-author/SKILL.md` and its bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-author/SKILL.md`. The Decisions section (AC-14 scope) already states that this copy changes with its source; `test_push_down_codex_and_agents_resource_contracts.py` and `pr-author-docs-estate-delegation-contract.Tests.ps1` read it.
5. Decisions (AC-22 dispositions) | incomplete asserting-test citation | added `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, `docs-estate-workflow.EndToEnd.Tests.ps1`, and `parallel-records-workflow.EndToEnd.Tests.ps1` with disposition unchanged. Each dot-sources the three changed gates and uses the repository root or synthetic roots with no `Test-Path` mock, so the allowance file reads as absent.
6. [P2-T5] | targeted selection omits the suites of fix 5 | the phase-gate Pester selection now includes the three `*-workflow.EndToEnd.Tests.ps1` suites.

## Verification Performed

- `mcp__drm-copilot__validate_orchestration_artifacts` (plan): ok.
- Branch-current CLI `scripts.dev_tools.validate_orchestration_artifacts plan`: passed, exit 0.
- Every function the plan cites exists in the tree; every existing test file the plan names exists.
- `artifacts/orchestration/orchestrator-state.json` in the item worktree records `route_id` `large`, so the batch-budget exemption applies.
- `hook-release-allowance-context.Parity.Tests.ps1` matchers (`'enforce-orchestration-preimplementation-gate-release.ps1')`, `Get-OrchestrationReleaseAllowanceResult`, final deny ending `+ $release.DenySuffix)`) do not match the planned receipt-leg names, so that suite stays unchanged.
- `pr-author-docs-estate-delegation-contract.Tests.ps1`: both `.agents` and `.claude` pr-author skill copies carry `## Coordinator-Session Topology (issue #1011)`, so a new section after the #1169 section keeps that suite passing.
- The pr-author agent text lives in the `head` section of `scripts/harness-generation/sources/agents/pr-author.md`, which `pr-author.json` lists in its Claude `sections`; the plan's choice of the `.md` file is correct.
