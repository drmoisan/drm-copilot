Timestamp: 2026-08-28T18-43
Command: awk '/^## Cross-References/,0' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c "^- "
EXIT_CODE: 0
Output Summary: `4`. This command's end pattern is the literal `0` (never matches), so it is not subject to the self-termination defect seen in the "When to Use This Skill" and "Prohibited Shortcuts" checks; it correctly runs to end-of-file. Matches the plan's expected post-cherry-pick count exactly (P0-T5 baseline of 3, +1). PASS.
