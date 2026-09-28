# SKILL.md bundle mirror parity

Timestamp: 2026-09-08T07-06

Task: [P7-T3] of `remediation-plan.2026-09-08T05-00.md`

Command:

```
sha256sum .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md
```

EXIT_CODE: 0

## Digests

| File | sha256 |
|---|---|
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | `f17f40a455394064dfa501a7ce60aedf031f9090ad66092755b2d61e56b0dd97` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | `f17f40a455394064dfa501a7ce60aedf031f9090ad66092755b2d61e56b0dd97` |

DigestsEqual: yes

## What was mirrored

Two edits, both in `## Report Line Contract`:

- [P7-T1] a paragraph in the `DIRTSUM|` bullet block recording the report-mode exit-status
  behaviour on a hard status read, carrying the single occurrence of `indistinguishable` in
  the file.
- [P7-T2] a sentence extending the `DIRTFILE|` bullet with Decision B, carrying the single
  occurrence of `repository-agnostic` in the file.

Output Summary: The canonical file and its bundle mirror are byte-identical, which is the
condition `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enforces.
That suite is re-run at [P8-T9] and must report `11 passed`, unchanged from the [P0-T9]
baseline.
