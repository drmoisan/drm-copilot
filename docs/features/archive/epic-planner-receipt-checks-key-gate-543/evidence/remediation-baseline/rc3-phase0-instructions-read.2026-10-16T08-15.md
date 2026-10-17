# Remediation Cycle 3 Policy Reads (P0-T1)

Timestamp: 2026-10-16T08-15
Command: read policy files in order (session-loaded standing instructions plus cat from the worktree root)
EXIT_CODE: 0
Policy Order: CLAUDE.md -> general code change -> general unit test -> Python (code, suppressions) -> TypeScript (code, suppressions) -> quality tiers -> evidence conventions
Files Read:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/python.md
5. .claude/rules/python-suppressions.md
6. .claude/rules/typescript.md
7. .claude/rules/typescript-suppressions.md
8. .claude/rules/quality-tiers.md
9. .claude/skills/evidence-and-timestamp-conventions/SKILL.md
Tiers: quality-tiers.yml present; scripts/dev_tools T4, extensions/drm-copilot T3; no property-test or mutation gate applies
Output Summary: All nine files read in the stated order. The root CLAUDE.md states no coverage threshold, so the defaults govern (85% line, 75% branch). Suppressions require pre-authorized patterns; 500-line file limit; no temporary files in tests; tests live under the mirrored tests/ tree; evidence under <FEATURE>/evidence/<kind>/ with UTC write-time stamps.
