# R3 Phase 0 Instructions Read (issue #935, remediation cycle 3)

Timestamp: 2026-10-16T12-31
Task: P0-T1
Policy Order: CLAUDE.md -> copilot-instructions -> tonality -> general code change (instructions, rule) -> general unit test (instructions, rule) -> quality tiers -> PowerShell code change -> PowerShell unit test -> PowerShell rule -> plan acceptance gates -> feature inputs (spec, remediation inputs, code review, feature audit) -> #936 research

Files read, in this order (17):
1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/tonality.md`
4. `.github/instructions/general-code-change.instructions.md`
5. `.claude/rules/general-code-change.md`
6. `.github/instructions/general-unit-test.instructions.md`
7. `.claude/rules/general-unit-test.md`
8. `.claude/rules/quality-tiers.md`
9. `.github/instructions/powershell-code-change.instructions.md`
10. `.github/instructions/powershell-unit-test.instructions.md`
11. `.claude/rules/powershell.md`
12. `.claude/rules/plan-acceptance-gates.md`
13. `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
14. `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-inputs.2026-10-16T11-25.md`
15. `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T11-25.md`
16. `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T11-25.md`
17. `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/research/hook-coverage-attribution-research.md`

Notes:
- `quality-tiers.yml` is present at the repository root; the uniform coverage gates apply. This cycle changes test files only (no production file under the coverage roots).
- PowerShell verification follows Option A (PoshQC MCP tools only); Pester stays on breakpoint coverage; no coverage configuration is changed.
