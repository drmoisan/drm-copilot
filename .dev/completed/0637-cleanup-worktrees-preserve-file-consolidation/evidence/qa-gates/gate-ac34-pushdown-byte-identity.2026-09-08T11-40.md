# Gate — AC-34, the skill file and its push-down mirror are byte-identical

Timestamp: 2026-09-08T11-40
Task: `[P8-T4]`
Command: cmp .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: `cmp` printed nothing and exited 0, and the two md5 values are equal:
`3e1721f6481367a5c182bfee1cb4bfbf` for both files.

RouteSubstitution:
- Plan command (denied in this worktree):
  `pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5 && cmp .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md && md5sum ...'"`
- Substitute actually run: the identical `cmp` and `md5sum` invocations executed locally in Git Bash
  from the worktree root. Only the hosting shell differs.
- Reason: the `pwsh`-wrapped WSL form is refused unconditionally in this worktree, and a bare `wsl`
  invocation is prohibited by binding amendment EA-1.

## Observation

    cmp <repo copy> <bundle mirror>
    (no output)
    CMP_EXIT=0

    3e1721f6481367a5c182bfee1cb4bfbf  .claude/skills/cleanup-merged-worktrees/SKILL.md
    3e1721f6481367a5c182bfee1cb4bfbf  extensions/.../claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md

`cmp` printed no `differ` line and the two md5 values are equal to one another. The two named files
are the instances this condition is judged against; no other pair is admissible.

**The pre-edit hash differs from the one the plan records, and that is expected.** The plan states
that both files hashed to `a7a3d102d01028b239113d994b4247be` at authoring time. On this branch the
pre-edit pair hashed to `78284da49d3e5cec309c8bae4596278e`, because a sibling child edited the same
file after the plan was written. The property AC-34 asserts is that the two files are byte-identical
to each other, not that they hold any particular historical hash, and they were byte-identical to
each other both before and after this edit. The mirrored hunk was written from the same literal
string in a single operation, so it is identical rather than merely equivalent.

Verdict: PASS.
