# Skill Guidance Bullets (P6-T1, P6-T2, P6-T3)

Timestamp: 2026-10-01T17-13

P6-T1:

Command: git diff --numstat 41217012d31d35c2ee33a50be50684affd2f5f43 -- .claude/skills/atomic-plan-contract/SKILL.md
EXIT_CODE: 0
Output Summary: `2	0	.claude/skills/atomic-plan-contract/SKILL.md` (two added lines, no other line changed). The two bullets are lines 215 and 216, directly after the task-ordering bullet (line 214) and before the blank line above `## Plan-Path Continuity Contract (Mandatory)` (line 218).

P6-T2:

Command: cp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
EXIT_CODE: 0
Output Summary: no output.

Command: cmp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
EXIT_CODE: 0
Output Summary: no output; the files are byte-identical.

P6-T3:

Command: sh <session-scratchpad>/skill-bullet-tokens.sh .claude/skills/atomic-plan-contract/SKILL.md
EXIT_CODE: 0
Output Summary: both `BULLET:` lines report `lines=1`; 14 `TOKEN-PRESENT:` lines; no `TOKEN-MISSING:` line (AC-17, AC-18).

```
BULLET: **Name the runner and job for a Pester acceptance criterion.** | lines=1
TOKEN-PRESENT: windows-latest
TOKEN-PRESENT: ubuntu-latest
TOKEN-PRESENT: tests/scripts/claude-hooks
TOKEN-PRESENT: tests/scripts/codex-hooks
TOKEN-PRESENT: never for coverage
TOKEN-PRESENT: poshqc / PowerShell QC
TOKEN-PRESENT: poshqc / PowerShell hook suites (Linux)
BULLET: **Do not assert a fixed-string search literal that contains a backslash.** | lines=1
TOKEN-PRESENT: grep -F
TOKEN-PRESENT: Git for Windows grep 3.0
TOKEN-PRESENT: doubled backslash
TOKEN-PRESENT: one backslash
TOKEN-PRESENT: backslash-free substring
TOKEN-PRESENT: named test
TOKEN-PRESENT: byte-identity
```

Command: grep -n -F -e '## Wrap-Tolerant Assertion Authoring (Mandatory)' -e '**Name the runner and job for a Pester acceptance criterion.**' -e '**Do not assert a fixed-string search literal that contains a backslash.**' -e '## Plan-Path Continuity Contract (Mandatory)' .claude/skills/atomic-plan-contract/SKILL.md
EXIT_CODE: 0
Output Summary: four lines in order with ascending line numbers: 196 (section heading), 215 (runner/job bullet), 216 (backslash bullet), 218 (next section heading). Both bullets lie inside the section.
