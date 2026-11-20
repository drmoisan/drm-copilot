# Phase 0 Policy Reads - issue #1021, remediation cycle 1

Timestamp: 2026-11-04T00-38
Task: [P0-T1]
Policy Order: CLAUDE.md, then general code change, then general unit test, then the PowerShell language rule (the only language in scope).

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`

Notes: the PowerShell rule requires format, analyze and test in order with a restart on any change or failure, 85% line coverage with no branch gate, no temporary files in tests, and mocks registered before the code under test resolves commands.
