Timestamp: 2026-08-28T23-45

Command: git diff --no-index -- .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md

EXIT_CODE: 1

Output Summary: Files differ under `--no-index` (exit 1, as expected for two distinct
paths with differing content). The repo-side copy contains an entire "Dirty Worktree
Triage Procedure" section (10 numbered steps) that is absent from the bundled copy, plus
`allowed-tools` frontmatter entries the bundled copy lacks (`Grep`, `Glob`, `Agent`,
`Bash(git status *)`, `Bash(git log *)`, `Bash(git show *)`, `Bash(git diff *)`,
`Bash(git branch -r*)`, `Bash(git worktree list*)`, `Bash(gh issue view *)`,
`mcp__drm-copilot__new_potential_bug_entry`, `mcp__drm-copilot__potential_to_issue`),
an added "When to Use This Skill" bullet about `BLOCKED-DIRTY`/`NOT_MERGED`/
`HAS_UNIQUE_RESIDUALS` triage, a "Nothing to Consolidate" cross-reference update, an
extended "Prohibited Shortcuts" section (origin-branch deletion and orphaned-directory
filesystem-removal confirmation rules), and a "Cross-References" entry pointing to
`.claude/skills/feature-promotion-lifecycle/SKILL.md`. These are exactly the sections
identified in `remediation-inputs.2026-08-28T23-45.md` as present only in the repo-side
copy.
