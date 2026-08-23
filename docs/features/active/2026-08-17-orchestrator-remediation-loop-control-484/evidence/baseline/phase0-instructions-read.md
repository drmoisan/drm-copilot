Timestamp: 2026-08-17T10-55

Policy Order:
1. P0-T1 — repository standing policy
2. P0-T2 — cross-language code-change policy
3. P0-T3 — cross-language unit-test policy, then quality tiers
4. P0-T4 — Python policy, then Python suppression policy
5. P0-T5 — TypeScript policy, TypeScript suppression policy, then CI workflow policy

Files Read:
1. `AGENTS.md`
2. `.agents/skills/general-code-change/SKILL.md`
3. `.agents/skills/general-unit-test/SKILL.md`
4. `.agents/skills/quality-tiers/SKILL.md`
5. `.agents/skills/python/SKILL.md`
6. `.agents/skills/python-suppressions/SKILL.md`
7. `.agents/skills/typescript/SKILL.md`
8. `.agents/skills/typescript-suppressions/SKILL.md`
9. `.agents/skills/ci-workflows/SKILL.md`

Preflight Compatibility Files Read:
1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`

PowerShell Expected-Failure Exit-Reset Rule:
A GitHub Actions `pwsh` step that intentionally invokes a command expected to fail must explicitly reset `$LASTEXITCODE = 0` after verifying the expected failure or explicitly `exit 0` on the verified-success path. This rule constrains P6-T24.
