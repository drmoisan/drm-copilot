# r1 P0-T3 — BASE_SHA, branch, pre-existing untracked list, clean pre-edit state

Timestamp: 2026-10-03T12-39
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t3.ps1 -Worktree WORKTREE
EXIT_CODE: 0
Output Summary:
- branch: bug/promotion-hook-raw-containment-false-positive-deny-824
- BASE_SHA: 079ebb9fad8fab1ee24e137e5bc605fc1df1948a (the caller reported preflight tree cab81581 plus the plan-file commit 079ebb9f; BASE_SHA is taken only from this output)
- ANCESTOR-EXIT=0 (f6ef5b2f is an ancestor of HEAD)
- PRE-UNTRACKED-COUNT=0 (no pre-existing untracked path outside FEATURE and .claude/agent-memory; SCRATCH/pre-untracked.txt is empty)
- STATUS-LINES=0 (every edited directory is clean before any edit)
- VERDICT held; step script exited 0.

Step script body (after the A0 preamble):

```powershell
$branch = git branch --show-current; $branch
$head = git rev-parse HEAD; $head
git merge-base --is-ancestor f6ef5b2f HEAD; $ancestorExit = $LASTEXITCODE; "ANCESTOR-EXIT=$ancestorExit"
Set-Content -LiteralPath "$Scratch/pre-untracked.txt" -Value @(git ls-files --others --exclude-standard -- . ':(exclude)docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824' ':(exclude).claude/agent-memory')
"PRE-UNTRACKED-COUNT=$(@(Get-Content -LiteralPath "$Scratch/pre-untracked.txt").Count)"
Get-Content -LiteralPath "$Scratch/pre-untracked.txt" | ForEach-Object { "PRE-UNTRACKED: $_" }
$status = @(git status --porcelain --untracked-files=all -- .claude/hooks .codex/hooks .codex/codex-web-setup.sh .claude/rules .claude/skills .claude/agents .agents .github/instructions .github/agents extensions/drm-copilot/resources tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/dev_tools docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md); $status; "STATUS-LINES=$($status.Count)"
exit ([int](-not ($branch -eq 'bug/promotion-hook-raw-containment-false-positive-deny-824' -and "$head" -match '^[0-9a-f]{40}$' -and $ancestorExit -eq 0 -and $status.Count -eq 0)))
```
