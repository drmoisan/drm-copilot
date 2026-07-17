# Phase 0 Instructions Read (Issue #357, Remediation Cycle 1)

Timestamp: 2026-07-17T14-45

Policy Order:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`

Files read (in this order):
- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/powershell.md`

Output Summary: All four policy files were read in the specified order prior to any code or test change in this remediation cycle. Key constraints noted: uniform 85% line / 75% branch coverage threshold (`general-unit-test.md`), prohibition on excluding production files from coverage measurement, mandatory format -> analyze -> test toolchain loop for PowerShell (`powershell.md`), and the requirement to restart the toolchain loop from formatting whenever a step fails or modifies files.
