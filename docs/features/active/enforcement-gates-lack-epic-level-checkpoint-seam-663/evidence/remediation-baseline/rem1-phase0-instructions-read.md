# Remediation Cycle 1 Policy Reading ([P0-T1])

Timestamp: 2026-09-25T21-08

Policy Order:
1. CLAUDE.md
2. docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/baseline/phase0-instructions-read.md
3. .claude/rules/general-code-change.md
4. .claude/rules/general-unit-test.md
5. .claude/rules/quality-tiers.md
6. .claude/rules/powershell.md
7. .github/instructions/powershell-code-change.instructions.md
8. .github/instructions/powershell-unit-test.instructions.md
9. .claude/rules/tonality.md
10. .claude/rules/plan-acceptance-gates.md

Files Read:
- CLAUDE.md
- docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/baseline/phase0-instructions-read.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/quality-tiers.md
- .claude/rules/powershell.md
- .github/instructions/powershell-code-change.instructions.md
- .github/instructions/powershell-unit-test.instructions.md
- .claude/rules/tonality.md
- .claude/rules/plan-acceptance-gates.md

Notes: No conflicting instructions were identified. The PowerShell instruction files name the PoshQC MCP functions as the agent toolchain; plan rule 1 (main-plan rule 4) requires every count to come from the module functions `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCTest` or from R-SCOPED, because MCP results carry no output. The 500-line cap, the no-temporary-file rule for tests, and the mock-signature parity rule apply to the four test files this cycle edits.
