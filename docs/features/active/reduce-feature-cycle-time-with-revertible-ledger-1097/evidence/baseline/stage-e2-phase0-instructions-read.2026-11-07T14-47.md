# Stage E2 Phase 0 Policy Reads

Timestamp: 2026-11-07T14-47
Policy Order: .claude/skills/policy-compliance-order/SKILL.md (CLAUDE.md, general code change, general unit test, then the language rules for the files in scope: PowerShell, Python, TypeScript)
Scope: PowerShell (tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1, tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1), Python (two contract test modules), TypeScript (gate run only; no TypeScript file is edited), Markdown and TOML customization surfaces.

Files read, in order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/quality-tiers.md
5. .claude/rules/tonality.md
6. .claude/rules/powershell.md
7. .claude/rules/python.md
8. .claude/rules/python-suppressions.md
9. .claude/rules/typescript.md
10. .claude/rules/typescript-suppressions.md
11. .claude/rules/plan-acceptance-gates.md

No policy file under .claude/rules/ or .github/instructions/ is edited by this stage.
