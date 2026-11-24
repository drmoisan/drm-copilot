# Contract and Scope Checks (issue #1231)

Timestamp: 2026-11-24T01-17
Command: sh SCRATCH/issue-1231-p4t5.sh
EXIT_CODE: 0
Output Summary: both generator checks exit 0; sizes within limits; the scope lists contain no prohibited path.

## Generator checks
Command: pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
EXIT_CODE: 0
Output Summary: `harness-generation: no drift`.

Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: no drift reported.

## Sizes (@(Get-Content -LiteralPath <path>).Count; P0-T1 value in parentheses)
- .claude/hooks/enforce-pr-author-skill.ps1: 366 (359)
- .claude/hooks/enforce-pr-author-skill.cleanup.ps1: 268 (246)
- .claude/hooks/enforce-model-routing-receipt.ps1: 441 (425)
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 501 (499)
- .claude/hooks/enforce-pr-author-skill-helpers.ps1: 499 (499; not edited)
- .claude/hooks/hook-release-allowance-context.ps1: 495 (495; not edited)
- New: hook-release-pull-request-context.ps1 116; enforce-pr-author-skill.release.ps1 177; enforce-model-routing-receipt-release.ps1 108; enforce-orchestration-preimplementation-gate-release-receipt.ps1 113.
- Each new file is below 500 lines; no changed file exceeds 800 (AC-19). enforce-orchestration-preimplementation-gate.ps1 is at the 500-line guidance tier (501 by Get-Content count, 500 by wc -l); no gate fails below 801.

## Scope
Command: git diff --name-only <merge base of origin/main and HEAD>...HEAD (8 entries: the committed #1231 feature-folder documents) and git status --porcelain (51 entries: the uncommitted implementation, tests, bundle copies, generated documents, and evidence), searched together
EXIT_CODE: 0
Output Summary:
- `.codex/` paths: 0 (AC-14). The only changed bundle copies under codex-and-agents-customizations are the two .agents skill copies (.agents/skills/execution-environment/SKILL.md and .agents/skills/pr-author/SKILL.md), which the plan's Decisions section classifies as spec-named sources (AC-17).
- `.claude/release-commit-allowance.json`: 0 entries in either list, and no file of that name exists anywhere in the worktree (AC-16).
- hook-release-allowance-context.ps1: 0; enforce-orchestration-preimplementation-gate-release.ps1: 0; enforce-pr-author-skill-helpers.ps1: 0; enforce-epic-merge-gate.ps1: 0, in any copy (AC-12, D1).
