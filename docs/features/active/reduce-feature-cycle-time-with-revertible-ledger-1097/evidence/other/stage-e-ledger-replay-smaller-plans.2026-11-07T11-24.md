# Stage E Ledger Replay: Smaller Plans

Timestamp: 2026-11-07T11-24
Command: sh SCRATCH/issue-1097-e-run.sh issue-1097-e-replay.ps1 -Entry 0004-smaller-plans.md
EXIT_CODE: 0
Output Summary:
    ledger-valid=True rows=4
    entry=0004-smaller-plans.md entry-at-HEAD=False blocks=3 new-blocks=3
    REPLAY .claude/skills/atomic-plan-contract/SKILL.md blocks=1 equals-HEAD=True
    REPLAY .agents/skills/atomic-plan-contract/SKILL.md blocks=1 equals-HEAD=True
    REPLAY .github/skills/atomic-plan-contract/SKILL.md blocks=1 equals-HEAD=True
    current-once-checked=69
    0001-patch-reverse-check-exit=1 (recorded only; reference at [P0-T3] is exit 1 on the two .github feature-review-workflow copies)
    0001-patch-failing-files=.agents/skills/atomic-plan-contract/SKILL.md, .agents/skills/execution-environment/SKILL.md, .claude/skills/atomic-plan-contract/SKILL.md, .claude/skills/execution-environment/SKILL.md, .github/skills/atomic-plan-contract/SKILL.md, .github/skills/execution-environment/SKILL.md, .github/skills/feature-review-workflow/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md
    0001-patch-newly-failing-files=.agents/skills/atomic-plan-contract/SKILL.md, .agents/skills/execution-environment/SKILL.md, .claude/skills/atomic-plan-contract/SKILL.md, .claude/skills/execution-environment/SKILL.md, .github/skills/atomic-plan-contract/SKILL.md, .github/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md
    0001-patch-failing-at-HEAD=.agents/skills/execution-environment/SKILL.md, .claude/skills/execution-environment/SKILL.md, .github/skills/execution-environment/SKILL.md, .github/skills/feature-review-workflow/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md
    0001-patch-moved-to-failing-by-this-commit=.agents/skills/atomic-plan-contract/SKILL.md, .claude/skills/atomic-plan-contract/SKILL.md, .github/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md
    failures=0
    exit=0

Derived entry number: `0004`. The ledger index held `0001` to `0003` at this commit, and `origin/main` held the same three entries, so `0004` is the next free number. File stem: `0004-smaller-plans`.

Replay: `Test-ProcessReductionLedger` returns `IsValid` true; applying the three new blocks of `0004` to the working text of each contract source yields its text at `HEAD` after line-ending normalization; every `Current` of every entry (69 blocks) occurs exactly once in its working file.

Reverse-patch result (recorded only, does not set EXIT_CODE): `git apply -R --check` of `patches/0001-parallel-only-test-gates.patch` already failed at [P0-T3] on the two `.github` `feature-review-workflow` copies. The [P1-T1] commit moved the six `execution-environment` brief copies to failing, because its contract-test bullet sits beside a `0001` hunk; that commit reduces nothing and writes no entry. This commit moves the six `atomic-plan-contract` copies to failing, because the `**Task target.**` bullet sits inside the `0001` hunk at the `**Size guideline.**` bullet. Entry `0004` therefore states in `## Revert Steps` step 1 that it is reverted before `0001`. Entry `0001` still reverts through its `Prior Text` blocks, whose `Current` text each occurs once.

Mechanical correction during the task: a `Current` fence holding only the bullet line left a blank line after revert, so each `Current` fence ends with an empty line, which removes the bullet's line terminator with it. `Prior` stays empty.
