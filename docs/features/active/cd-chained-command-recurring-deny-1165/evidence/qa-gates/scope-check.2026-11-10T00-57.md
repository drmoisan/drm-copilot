# Scope, Size, and Literal Invariants (issue #1165)

Timestamp: 2026-11-10T00-57
Command: sh SCRATCH/issue-1165-scope.sh; sh SCRATCH/issue-1165-scope7.sh (MB = git merge-base origin/main HEAD; change set = git diff MB --name-status plus git status --porcelain; hunk checks with git diff -U0 MB -- <path>; wc -l for .ps1 production files)
EXIT_CODE: 0
Output Summary:
- Every check passed (both scripts exit 0, FAIL_FLAG=0).
- Change set (tracked, against MB): 20 modified paths; untracked additions: the new helper, rule, Codex skill, Copilot instruction, their bundle copies, three new test files, and the feature folder.
  CHECK 1 excluded paths absent from change set:
    ok   .codex/hooks/validate-bash.ps1 absent
    ok   extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 absent
    ok   .github/copilot-instructions.md absent
    ok   tests/scripts/claude-hooks/validate-bash.Tests.ps1 absent
    ok   tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 absent
    ok   tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 absent
    ok   tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 absent
    ok   tests/scripts/claude-hooks/review-verdict-status.HookAllowance.Tests.ps1 absent
    ok   tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 absent
    ok   tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 absent
    ok   Codex suite validate-bash-decision-surface absent
    ok   Codex suite validate-bash-trigger-scoping absent
    ok   Codex suite codex-pretooluse-integration absent
    ok   Codex suite legacy-codex-hook-contracts absent
    ok   Codex suite hook-dependency-failure.Codex absent
    ok   no existing .github/instructions file changed
    ok   no .py outside tests/ added or modified
  CHECK 2 validate-bash.ps1 hunks:
    @@ -47,0 +48,2 @@ try { . (Join-Path $PSScriptRoot 'hook-command-invocation.ps1') } catch { Add-Ho
    @@ -343 +345 @@ function Get-BashBlockReason {
  CHECK 3 brief hunks (section of each hunk start):
    ok   .claude/skills/execution-environment/SKILL.md hunk at new line 36 in ## Command-Text Restrictions
    ok   .claude/skills/execution-environment/SKILL.md hunk at new line 89 in ## Worktree Python Environment
    ok   .agents/skills/execution-environment/SKILL.md hunk at new line 36 in ## Command-Text Restrictions
    ok   .agents/skills/execution-environment/SKILL.md hunk at new line 89 in ## Worktree Python Environment
    ok   .github/skills/execution-environment/SKILL.md hunk at new line 36 in ## Command-Text Restrictions
    ok   .github/skills/execution-environment/SKILL.md hunk at new line 89 in ## Worktree Python Environment
    ok   extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md hunk at new line 36 in ## Command-Text Restrictions
    ok   extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md hunk at new line 89 in ## Worktree Python Environment
    ok   extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md hunk at new line 36 in ## Command-Text Restrictions
    ok   extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md hunk at new line 89 in ## Worktree Python Environment
    ok   extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md hunk at new line 36 in ## Command-Text Restrictions
    ok   extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md hunk at new line 89 in ## Worktree Python Environment
  CHECK 4 venv reason lines:
    ok   .claude/hooks/worktree-poetry-venv-policy.ps1 sha=4594fa9b9bef0158 contains poetry -C <worktree root>
    ok   .codex/hooks/worktree-poetry-venv-policy.ps1 sha=4594fa9b9bef0158 contains poetry -C <worktree root>
    ok   extensions/drm-copilot/resources/claude-customizations/.claude/hooks/worktree-poetry-venv-policy.ps1 sha=4594fa9b9bef0158 contains poetry -C <worktree root>
    ok   extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/worktree-poetry-venv-policy.ps1 sha=4594fa9b9bef0158 contains poetry -C <worktree root>
    distinct reason lines: 1
  CHECK 5 parallel-orchestrate copies:
    .claude/skills/parallel-orchestrate/SKILL.md keep=1 hard=0 markerC=1 markerD=1 tableRef=yes
    extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md keep=1 hard=0 markerC=1 markerD=1 tableRef=yes
  CHECK 6 wc -l of new or changed .ps1 production files:
    .claude/hooks/validate-bash.ps1 450
    .claude/hooks/bash-command-shape-guidance.ps1 178
    .claude/hooks/worktree-poetry-venv-policy.ps1 361
    .codex/hooks/worktree-poetry-venv-policy.ps1 361
    extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 450
    extensions/drm-copilot/resources/claude-customizations/.claude/hooks/bash-command-shape-guidance.ps1 178
    extensions/drm-copilot/resources/claude-customizations/.claude/hooks/worktree-poetry-venv-policy.ps1 361
    extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/worktree-poetry-venv-policy.ps1 361
  FAIL_FLAG=0
  CHECK 7 retained detection text of .claude/hooks/validate-bash.ps1 against MB:
    ok   line matching ^\$script:CdChainedReadCommandPattern =  unchanged
    ok   line matching ^\$script:CdChainedReadCommandWords =  unchanged
    ok   Get-CdChainedReadCommandMatch body unchanged (sha b129c5e405905266)
    git diff MB -- .codex/hooks/validate-bash.ps1 lines=0
    git diff MB -- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 lines=0
  FAIL_FLAG=0
