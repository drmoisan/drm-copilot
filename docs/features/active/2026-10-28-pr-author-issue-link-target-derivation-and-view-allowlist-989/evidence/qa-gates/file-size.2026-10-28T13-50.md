# File Size (P6-T8)

Timestamp: 2026-10-28T13-50
Command: sh SCRATCH/issue-989-run.sh SCRATCH/issue-989-filesize.ps1 (PowerShell 7: git merge-base origin/main HEAD; git diff --name-only <merge base> -- . plus git status --porcelain --untracked-files=all untracked entries; @(Get-Content -LiteralPath <path>).Count per file)
EXIT_CODE: 0

Scope: 48 files changed since the merge base of `origin/main` and `HEAD`, plus untracked files. Feature-folder Markdown and evidence files are listed by the script and are exempt from the cap; the PowerShell files are:

| File | Physical lines | At most 500 |
|---|---|---|
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 349 | yes |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 285 | yes |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 443 | yes |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | 149 | yes |
| bundle `.claude/hooks/enforce-model-routing-receipt.ps1` | 349 | yes |
| bundle `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 285 | yes |
| bundle `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 443 | yes |
| bundle `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | 149 | yes |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` | 267 | yes |
| `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` | 202 | yes |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1` | 247 | yes |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 137 | yes |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 425 | yes |
| `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1` | 148 | yes |

Other changed non-Markdown file: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, 243 lines.

Output Summary: PS_OVER_500=0; every `.ps1` file is at most 500 physical lines (largest: helpers 443).
