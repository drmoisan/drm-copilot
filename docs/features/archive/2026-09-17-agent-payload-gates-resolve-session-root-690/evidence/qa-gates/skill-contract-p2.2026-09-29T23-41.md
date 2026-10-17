# Skill Contract Token Counts (P2-T8)

Timestamp: 2026-09-29T23-41
Command: seven CMD-GIT-COUNT commands of P2-T1 through P2-T6 (git grep -c -F -e '<literal>' -- <skill file>), re-run in order
EXIT_CODE: 0
Output Summary:
- git grep -c -F -e 'enforce-orchestration-preimplementation-gate.ps1' -- .claude/skills/orchestrate/SKILL.md -> .claude/skills/orchestrate/SKILL.md:2 (required 2)
- git grep -c -F -e 'csharp-typed-engineer' -- .claude/skills/orchestrate/SKILL.md -> .claude/skills/orchestrate/SKILL.md:1 (required 1)
- git grep -c -F -e 'TARGET_WORKTREE_AMBIGUOUS' -- .claude/skills/epic-orchestrate/SKILL.md -> .claude/skills/epic-orchestrate/SKILL.md:1 (required 1)
- git grep -c -F -e 'TARGET_WORKTREE_AMBIGUOUS' -- .claude/skills/parallel-orchestrate/SKILL.md -> .claude/skills/parallel-orchestrate/SKILL.md:1 (required 1)
- git grep -c -F -e '## Delegation Identity Lines' -- .claude/skills/invoke-python-engineer/SKILL.md -> .claude/skills/invoke-python-engineer/SKILL.md:1 (required 1)
- git grep -c -F -e '## Delegation Identity Lines' -- .claude/skills/invoke-powershell-engineer/SKILL.md -> .claude/skills/invoke-powershell-engineer/SKILL.md:1 (required 1)
- git grep -c -F -e '## Delegation Identity Lines' -- .claude/skills/invoke-csharp-engineer/SKILL.md -> .claude/skills/invoke-csharp-engineer/SKILL.md:1 (required 1)
- Every count equals the value its task requires.
- P2-T3 negative check: git grep -n -F -e 'Epic mode: true' -- .claude/skills/parallel-orchestrate/SKILL.md exited 1 with no output.
- P2-T7 mirrors: PAIR-SUMMARY pairs=6 unequal=0.
