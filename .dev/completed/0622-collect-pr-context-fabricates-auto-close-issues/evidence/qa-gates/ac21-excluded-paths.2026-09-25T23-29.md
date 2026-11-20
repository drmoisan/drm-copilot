# AC 21 Excluded Paths (P10-T5)

Timestamp: 2026-09-26T20-32
Branch: N588

Command: git diff --exit-code --name-only ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 -- scripts/dev_tools/pr_context/github.py "extensions/drm-copilot/src/lib/pr-context/gh-client-*.ts" extensions/drm-copilot/src/lib/pr-context/executable-resolver.ts extensions/drm-copilot/src/lib/executable-resolver.ts extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts .claude/skills/pr-author/SKILL.md .agents/skills/pr-author/SKILL.md .github/agents/pr-author.agent.md .github/prompts/generate-pr.prompt.md extensions/drm-copilot/resources
EXIT_CODE: 0
Output Summary: No output. No excluded path differs from the scope anchor ae8d2ce32c95cf03d55ffb544f2514d83ebfc620.

Command: git status --porcelain -- scripts/dev_tools/pr_context/github.py "extensions/drm-copilot/src/lib/pr-context/gh-client-*.ts" extensions/drm-copilot/src/lib/pr-context/executable-resolver.ts extensions/drm-copilot/src/lib/executable-resolver.ts extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts .claude/skills/pr-author/SKILL.md .agents/skills/pr-author/SKILL.md .github/agents/pr-author.agent.md .github/prompts/generate-pr.prompt.md extensions/drm-copilot/resources
EXIT_CODE: 0
Output Summary: No output. No excluded path is modified or untracked in the worktree.

Command: git ls-files --cached --others -- tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py extensions/drm-copilot/src/lib/executable-resolver.ts extensions/drm-copilot/src/lib/pr-context/executable-resolver.ts
EXIT_CODE: 0
Output Summary: No output. In N588 neither `test_render_pr_helpers.py` nor either `executable-resolver.ts` path exists as a tracked or untracked file.
