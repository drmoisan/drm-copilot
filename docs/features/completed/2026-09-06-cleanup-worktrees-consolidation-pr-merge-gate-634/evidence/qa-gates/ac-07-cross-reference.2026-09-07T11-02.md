Timestamp: 2026-09-07T11-02
Command: rg -F -n "enforce-epic-merge-gate.ps1" .claude/skills/cleanup-merged-worktrees/SKILL.md
EXIT_CODE: 0
Output Summary:
111:   `.claude/settings.json`) carries no `gh` entry; and `.claude/hooks/enforce-epic-merge-gate.ps1`
262:  checkpoint in order to satisfy `.claude/hooks/enforce-epic-merge-gate.ps1`. This
279:- `.claude/hooks/enforce-epic-merge-gate.ps1` — the PreToolUse gate on the consolidation

`## Cross-References` section boundary (current file state): heading at line 267, section
content through line 283 (end of file). The match at line 279 falls inside that range.
AC-7 uses at-least-one-match semantics, so the occurrences at lines 111 (inside step 5)
and 262 (inside `## Prohibited Shortcuts`) are permitted and do not affect the result.
AC-7 is satisfied.
