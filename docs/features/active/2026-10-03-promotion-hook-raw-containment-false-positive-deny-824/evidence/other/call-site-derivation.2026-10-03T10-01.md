# P5-T1 Resolver call-site re-derivation

Timestamp: 2026-10-03T10-01
Command: Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern "-CommandWord '" | ForEach-Object { "$($_.Path | Resolve-Path -Relative):$($_.LineNumber)" }
EXIT_CODE: 0
Output Summary:
- 34 lines in 13 files (Claude 22 in 8 files, Codex 12 in 5 files)
- The file:line set equals the research Claim N1 primary member set exactly (Claude: epic-merge 128, 134, 342, 343; preimplementation 142; epic-worktree 140, 141, 355; validate-bash 123, 127; promotion 126, 127; epic-base-branch 92, 100, 138; pr-author-helpers 279, 280, 290, 291; parallel-worktree 201, 202, 361. Codex: epic-worktree 58, 59, 126; epic-merge 63, 69, 141, 142; preimplementation 161; promotion 123, 124; validate-bash 96, 100)
- Result: PASS

```text
.claude\hooks\enforce-epic-merge-gate.ps1:128
.claude\hooks\enforce-epic-merge-gate.ps1:134
.claude\hooks\enforce-epic-merge-gate.ps1:342
.claude\hooks\enforce-epic-merge-gate.ps1:343
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:140
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:141
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:355
.claude\hooks\enforce-orchestration-preimplementation-gate.ps1:142
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:201
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:202
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:361
.claude\hooks\enforce-pr-author-skill-helpers.ps1:279
.claude\hooks\enforce-pr-author-skill-helpers.ps1:280
.claude\hooks\enforce-pr-author-skill-helpers.ps1:290
.claude\hooks\enforce-pr-author-skill-helpers.ps1:291
.claude\hooks\enforce-pr-author-skill.epic-base-branch.ps1:92
.claude\hooks\enforce-pr-author-skill.epic-base-branch.ps1:100
.claude\hooks\enforce-pr-author-skill.epic-base-branch.ps1:138
.claude\hooks\enforce-promotion-mcp-only.ps1:126
.claude\hooks\enforce-promotion-mcp-only.ps1:127
.claude\hooks\validate-bash.ps1:123
.claude\hooks\validate-bash.ps1:127
.codex\hooks\enforce-epic-merge-gate.ps1:63
.codex\hooks\enforce-epic-merge-gate.ps1:69
.codex\hooks\enforce-epic-merge-gate.ps1:141
.codex\hooks\enforce-epic-merge-gate.ps1:142
.codex\hooks\enforce-epic-worktree-removal-gate.ps1:58
.codex\hooks\enforce-epic-worktree-removal-gate.ps1:59
.codex\hooks\enforce-epic-worktree-removal-gate.ps1:126
.codex\hooks\enforce-orchestration-preimplementation-gate.ps1:161
.codex\hooks\enforce-promotion-mcp-only.ps1:123
.codex\hooks\enforce-promotion-mcp-only.ps1:124
.codex\hooks\validate-bash.ps1:96
.codex\hooks\validate-bash.ps1:100
```
