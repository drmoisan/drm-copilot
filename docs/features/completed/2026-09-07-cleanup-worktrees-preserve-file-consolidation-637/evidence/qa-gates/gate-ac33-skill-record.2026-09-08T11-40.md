# Gate — AC-33, the `PRESERVE|` record shape is documented in the skill

Timestamp: 2026-09-08T11-40
Task: `[P8-T2]`
Command: grep -n -F -- PRESERVE| .claude/skills/cleanup-merged-worktrees/SKILL.md
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: one match at line 81, which falls between the `## Report Line Contract` heading at
line 58 and the `## End-to-End Workflow` heading at line 102, so the token is inside that bullet
list. Both greps exited 0.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'grep -n -F -- PRESERVE\| /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5/.claude/skills/cleanup-merged-worktrees/SKILL.md && grep -n -E ^##[[:space:]] /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5/.claude/skills/cleanup-merged-worktrees/SKILL.md'"`
- Substitute actually run: the identical two `grep` invocations executed locally in Git Bash against
  the same file by absolute path. Only the hosting shell differs; the tool, the flags, the literal,
  and the file are the same.
- Reason: the `pwsh`-wrapped WSL form is refused unconditionally in this worktree, and a bare `wsl`
  invocation is prohibited by binding amendment EA-1.

## Matched line and the bracketing headings

    81:- `PRESERVE|<worktree-path>|<source-path>|<verdict>` — a manifest `preserved_files[]`

    58:## Report Line Contract
    102:## End-to-End Workflow

58 < 81 < 102, so the matched line is inside the `## Report Line Contract` bullet list. The literal
asserted is `PRESERVE|`, which this task creates; the count was 0 before it ran.

## Placement, and one observation the plan did not anticipate

The plan anchors the new bullet to the `ACTION|<verb>|<target>|<result>` bullet rather than to a
line number, and states that the ACTION bullet "is the last bullet of that list and today sits at
line 71". On this branch it is neither: it sits at line 80 and is followed by four further bullets
(`ORPHAN_DIR`, `STALE_REF`, `CHILD_OF`, and `WARN|registration-lost`) that a sibling child added
after the plan was written. The anchoring instruction is what governs, and it was followed exactly:
the new bullet was inserted immediately after the `ACTION|<verb>|<target>|<result>` bullet. Every
other bullet in the list, before and after, is byte-unchanged.

The bullet follows the list's observed conventions: an inline code span holding the shape, a spaced
em dash, angle-bracketed lowercase-hyphenated placeholders, an inline enumerated verdict set with
` | ` separators, and two-space continuation indents.

Verdict: PASS.
