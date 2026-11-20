# Main Merge, Post-Merge QA Record (PR #1166 merged into the item branch)

Timestamp: 2026-11-10T04-08
Command: git show --stat 25dcbcdc2; git diff --name-only 25dcbcdc2^1 25dcbcdc2; cmp of .claude/skills/parallel-orchestrate/SKILL.md and its bundle mirror; node JSON parse of pack-manifests/core.json; git diff --name-only <merge-base of origin/main and HEAD> HEAD
EXIT_CODE: 0
Output Summary:
- Merge commit: 25dcbcdc236f47b94a81e2bc357acb8e0dc64e04, "Merge remote-tracking branch 'origin/main' into feature/parallel-planner-time-based-edge-rule-1164". It is a plain merge made by the orchestrator, not a rebase. Parents: f9405174f65aecf2a131009fee134f044ac4d7e5 (branch) and 228e6f8c4606e53f36963dc9aa57d71b4882b49e (origin/main, "Merge pull request #1166 from drmoisan/bug/cd-chained-command-recurring-deny-1165"). origin/main is an ancestor of HEAD.
- Merged ref: origin/main. The merge brought 61 paths from main (31 outside docs/), including the bash-command-shape rule, skill, instruction and hook, the validate-bash cd-chain guidance, worktree-poetry-venv-policy edits, the execution-environment brief, and their tests.
- Conflicted files: none. Three files that this branch also changed were auto-merged by git:
  - .claude/skills/parallel-orchestrate/SKILL.md: main's two-line hunk (a reference to the Command-Text Restrictions table, and `reset --hard` replaced by `reset --keep`) applied cleanly alongside this branch's edits.
  - extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md: the same hunk. It is byte-identical to the source after the merge (cmp exit 0).
  - extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json: main's two entries (.claude/hooks/bash-command-shape-guidance.ps1, .claude/rules/bash-command-shape.md) were added in sorted position. The file parses as JSON with keys name, label and paths; it has 432 paths and 0 duplicates; and it still lists this branch's four new files (BlastRadiusAccess.psm1, ParallelDriftAccess.psm1, ParallelAdmissionPrecedenceGate.psm1, parallel-manifest-pairs.sh).
- The P5-T4 wording suite (tests/scripts/claude-runtime/parallel-scheduling-rule-wording.Tests.ps1) checks the merged parallel-orchestrate SKILL.md and its mirror. Its result is recorded in the post-merge pester-gate artifact. The pack-manifest completeness, dependency-closure and resource-contract tests pass in the post-merge pytest-gate artifact.
- Merge interaction fixes: none were needed. No gate failed.
- docs/features/parallel/harness-learnings-2026-11-09/ does not appear in the merge-base diff of origin/main and HEAD: 0 of 155 changed paths match. The in-flight parallel run was not touched.
- Parallel planning surfaces outside .claude (spec B8.2): git ls-files over .github, .agents and .codex lists no matching parallel planning file after the merge, so the twelve-file list of P5-T4 is unchanged.
