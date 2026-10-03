# r1 P7-T9 — resolver call-site inventory re-derived; AC-17 audit addendum

Timestamp: 2026-10-03T13-23
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p7-t9.ps1 -Worktree WORKTREE (A0; the `-CommandWord '` file:line listing over .claude/hooks/*.ps1 and .codex/hooks/*.ps1; the CALL-SITES and FILES counts; the VERDICT line), then the Edit-tool addendum, then pwsh -NoProfile -File SCRATCH/steps/r1-p7-t9-check.ps1 -Worktree WORKTREE (the ABSENT-TOKENS check and its VERDICT line)
EXIT_CODE: 0
Output Summary:
- First script (exit 0): CALL-SITES=37 FILES=13
- New call sites (one in each gate): .claude/hooks/enforce-epic-worktree-removal-gate.ps1:364, .claude/hooks/enforce-parallel-worktree-removal-gate.ps1:370, .codex/hooks/enforce-epic-worktree-removal-gate.ps1:134
- Addendum appended to FEATURE/evidence/other/containment-path-hook-audit.md under `## Remediation cycle 1 addendum (issue #824)` with Timestamp, the CALL-SITES line, the three new call sites, the wrapped-operand statement, and the covering tests A824-WT3 to A824-WT9.
- Second script (exit 0): ABSENT-TOKENS=0
- EXIT_CODE is the larger of the two process exit codes (0).

Full listing printed by the first script (Windows separators as printed):

.claude\hooks\enforce-epic-merge-gate.ps1:128
.claude\hooks\enforce-epic-merge-gate.ps1:134
.claude\hooks\enforce-epic-merge-gate.ps1:342
.claude\hooks\enforce-epic-merge-gate.ps1:343
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:140
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:141
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:355
.claude\hooks\enforce-epic-worktree-removal-gate.ps1:364
.claude\hooks\enforce-orchestration-preimplementation-gate.ps1:142
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:201
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:202
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:361
.claude\hooks\enforce-parallel-worktree-removal-gate.ps1:370
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
.codex\hooks\enforce-epic-worktree-removal-gate.ps1:134
.codex\hooks\enforce-orchestration-preimplementation-gate.ps1:161
.codex\hooks\enforce-promotion-mcp-only.ps1:123
.codex\hooks\enforce-promotion-mcp-only.ps1:124
.codex\hooks\validate-bash.ps1:96
.codex\hooks\validate-bash.ps1:100
