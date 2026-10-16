# Phase 0 Policy Reads (remediation cycle 1)

Timestamp: 2026-10-16T04-20
Plan: remediation-plan.2026-10-16T03-45.md, task P0-T1
Policy Order: CLAUDE.md -> general code change -> general unit test -> PowerShell -> Python -> Python suppressions -> quality tiers

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/python.md`
6. `.claude/rules/python-suppressions.md` (Python applies only to the unmodified pytest bundle-parity check)
7. `.claude/rules/quality-tiers.md` (applies: `quality-tiers.yml` exists at the repository root)

Key constraints carried into this cycle:

- PowerShell toolchain: format, analyze, test through the PoshQC MCP tools; no type-check stage.
- Line coverage >= 85% for changed PowerShell production files; no branch gate for Pester.
- No temporary files in tests; 500-line file limit; no weakening of assertions to make tests pass.
