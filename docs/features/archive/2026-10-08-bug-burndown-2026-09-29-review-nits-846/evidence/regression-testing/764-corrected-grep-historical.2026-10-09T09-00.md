# Regression: #764 corrected anchored grep against the pre-change trees ([P7-T5], AC-21)

Timestamp: 2026-10-09T21-37
Command: git log --format=%H -S"route it through the standard remediation handoff." -- .claude/skills/feature-review-workflow/SKILL.md
EXIT_CODE: 0
Output Summary: two SHAs printed, newest first: 2114d13d87765c9d2e4de62a1850b2b3d604fd90, b19874ea347e1a1b1726c1b43987cdd6999d8ab2. X1 = 2114d13d87765c9d2e4de62a1850b2b3d604fd90 (`2114d13d8 docs(484): document review verdicts, remediability, and attempt accounting (B11)`).

## Block 2 (X1 parent tree, root copy)

Command: git grep -n -e "^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$" "2114d13d87765c9d2e4de62a1850b2b3d604fd90^" -- .claude/skills/feature-review-workflow/SKILL.md
EXIT_CODE: 0
Output Summary: exactly one line, ending in `handoff.`:

```
2114d13d87765c9d2e4de62a1850b2b3d604fd90^:.claude/skills/feature-review-workflow/SKILL.md:75:- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff.
```

## Block 3 (derivation of X2, bundled copy)

Command: git log --format=%H -S"route it through the standard remediation handoff." -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md
EXIT_CODE: 0
Output Summary: two SHAs printed, newest first: 2114d13d87765c9d2e4de62a1850b2b3d604fd90, b19874ea347e1a1b1726c1b43987cdd6999d8ab2. X2 = 2114d13d87765c9d2e4de62a1850b2b3d604fd90 (`2114d13d8 docs(484): document review verdicts, remediability, and attempt accounting (B11)`). X1 and X2 are the same commit; the commit changed both copies.

## Block 4 (X2 parent tree, bundled copy)

Command: git grep -n -e "^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$" "2114d13d87765c9d2e4de62a1850b2b3d604fd90^" -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md
EXIT_CODE: 0
Output Summary: exactly one line, ending in `handoff.`:

```
2114d13d87765c9d2e4de62a1850b2b3d604fd90^:extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md:75:- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff.
```

Subject lines: `git log -1 --format="%h %s" 2114d13d87765c9d2e4de62a1850b2b3d604fd90` printed `2114d13d8 docs(484): document review verdicts, remediability, and attempt accounting (B11)` (applies to both X1 and X2).

Acceptance (AC-21 validity of the corrected form): each `git grep` against its parent tree exits 0 and prints exactly one line ending in `handoff.`. PASS.
