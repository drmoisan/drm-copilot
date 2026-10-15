# Regression: #764 corrected anchored grep on the current tree ([P7-T4], AC-21, deviation D-2)

Timestamp: 2026-10-09T21-36
Command: git grep -n -e "^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$" -- .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: no output. The #764 exact-line text is not present on the current tree because line 75 of both SKILL.md copies was later changed to the `awaiting_ci` wording (block 2). This is the expected outcome under deviation D-2; validity of the corrected command form is demonstrated against the pre-change trees in 764-corrected-grep-historical.2026-10-09T09-00.md.

## Block 2

Command: git grep -n -F -e "When the rule fires and no qualifying green-run evidence is present" -- .claude/skills/feature-review-workflow/SKILL.md
EXIT_CODE: 0
Output Summary: one line, line 75, carrying the later `awaiting_ci` wording:

```
.claude/skills/feature-review-workflow/SKILL.md:75:- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding classified `awaiting_ci` (the remediation inputs carry `Remediability: awaiting_ci` and a `Remediability-Evidence:` line naming the awaited workflow) and route it to the wait path (`AWAITING_CI` when no other class is present) instead of the remediation handoff.
```

The same fixed-string search over extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md also prints line 75 with the same wording (supplementary observation).

Acceptance (D-2): exit 1 with no output; line 75 of both copies carries the `awaiting_ci` wording. PASS.
