# r2 P7-T6 resolver call-site re-derivation

Timestamp: 2026-10-03T16-23
Command: step script SCRATCH/steps/r2-p7-t6.ps1 (Select-String -Path .claude/hooks/*.ps1, .codex/hooks/*.ps1 -SimpleMatch -Pattern "-CommandWord '" with relative file:line output; CALL-SITES and FILES counts; VERDICT), then the Edit tool appends the "Remediation cycle 2 addendum (issue #824)" section to FEATURE/evidence/other/containment-path-hook-audit.md, then step script SCRATCH/steps/r2-p7-t6-check.ps1 (ABSENT-TOKENS; VERDICT)
EXIT_CODE: 0
Output Summary: first script CALL-SITES=37 FILES=13 (exit 0); second script ABSENT-TOKENS=0 (exit 0). EXIT_CODE is the larger of the two process exit codes.

```text
.claude\hooks\enforce-epic-merge-gate.ps1:128
.claude\hooks\enforce-epic-merge-gate.ps1:134
.claude\hooks\enforce-epic-merge-gate.ps1:342
.claude\hooks\enforce-epic-merge-gate.ps1:343
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:140
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:141
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:355
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:365
.claude\hooks\enforce-orchestration-preimplementation-gate.ps1:142
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:201
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:202
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:361
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:371
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
.codex\hooks\enforce-epic-worktree-removal-gate.ps1:135
.codex\hooks\enforce-orchestration-preimplementation-gate.ps1:161
.codex\hooks\enforce-promotion-mcp-only.ps1:123
.codex\hooks\enforce-promotion-mcp-only.ps1:124
.codex\hooks\validate-bash.ps1:96
.codex\hooks\validate-bash.ps1:100
CALL-SITES=37 FILES=13
```
