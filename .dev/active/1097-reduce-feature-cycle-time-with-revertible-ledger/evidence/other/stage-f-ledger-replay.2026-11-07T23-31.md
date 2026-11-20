# Stage F Ledger Replay and Final Cutoff (P2-T5)

Timestamp: 2026-11-07T23-31
Command: SCRATCH/sf/issue-1097-sf-p2t5.sh (one UTC clock read by SCRATCH/sf/issue-1097-sf-cutoff.py; the final pair written at the five labelled positions; git add of the Files Changed paths outside the ledger folder; git diff --cached --binary --no-renames HEAD into patches/0008-g13-guideline-cutoff.patch; git apply -R --check of that patch; SCRATCH/sf/issue-1097-sf-ledger.ps1 with -StopBefore 0006,0001)
EXIT_CODE: 0
Output Summary:
  UTC clock reading, to the second: 2026-11-07T23:31:26Z (at or after the P2-T4 reading 2026-11-07T23:26:05Z).
  Final pair: America/New_York 2026-11-07T18-31, UTC 2026-11-07T23-31; written to scripts/dev_tools/plan_gate_document.py, extensions/drm-copilot/src/lib/validate/plan-gate-document.ts, .claude/rules/plan-acceptance-gates.md, its bundle copy, and the 0008 entry, each labelled position found exactly once.
  The reduction commit's author and committer dates are set to this reading; the clock is not read again for them.
  Stored patch: 1834 lines; git apply -R --check exit 0.
  Ledger check and chain replays (0008 in the ledger): see the log below; the commit is made only when every one reports IsValid true with zero errors.

## Replay Log

```text
ledger IsValid=True entries=8 errors=0 names=0001-parallel-only-test-gates.md,0002-concurrent-review.md,0003-light-remediation.md,0004-smaller-plans.md,0005-policy-read-removal.md,0006-test-suite-baseline-restored.md,0007-epic-main-sync-plain-merge.md,0008-g13-guideline-cutoff.md
chain full IsValid=True errors=0
stored-patch entries: 0001-parallel-only-test-gates.md, 0006-test-suite-baseline-restored.md, 0008-g13-guideline-cutoff.md
chain StopBefore 0001-parallel-only-test-gates.md IsValid=True errors=0
chain StopBefore 0006-test-suite-baseline-restored.md IsValid=True errors=0
hunk 0001-parallel-only-test-gates.patch .agents/skills/atomic-plan-contract/SKILL.md start=32 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0001-parallel-only-test-gates.patch .claude/agents/atomic-planner.md start=46 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=1 prior-lines=1
hunk 0001-parallel-only-test-gates.patch .claude/skills/atomic-plan-contract/SKILL.md start=32 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0001-parallel-only-test-gates.patch .github/skills/atomic-plan-contract/SKILL.md start=32 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0001-parallel-only-test-gates.patch extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md start=46 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=1 prior-lines=1
hunk 0001-parallel-only-test-gates.patch extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md start=32 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0001-parallel-only-test-gates.patch extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md start=32 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0001-parallel-only-test-gates.patch extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md start=32 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0006-test-suite-baseline-restored.patch .claude/agents/atomic-planner.md start=46 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=1 prior-lines=1
hunk 0006-test-suite-baseline-restored.patch extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md start=46 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=1 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch .agents/skills/atomic-plan-contract/SKILL.md start=31 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch .agents/skills/atomic-plan-contract/SKILL.md start=215 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch .claude/agents/atomic-planner.md start=49 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch .claude/skills/atomic-plan-contract/SKILL.md start=31 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch .claude/skills/atomic-plan-contract/SKILL.md start=233 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch .github/agents/atomic_planning.agent.md start=109 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch .github/skills/atomic-plan-contract/SKILL.md start=31 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch .github/skills/atomic-plan-contract/SKILL.md start=201 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md start=49 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md start=31 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md start=233 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md start=31 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md start=215 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md start=109 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md start=31 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md start=201 kind=modify marker='a plan above 40 tasks or 400 lines' current-lines=0 prior-lines=1
hunk 0008-g13-guideline-cutoff.patch tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 start=176 kind=modify marker='**Size guideline.**' current-lines=1 prior-lines=0
current-fence-hits=0
failures=0
```
