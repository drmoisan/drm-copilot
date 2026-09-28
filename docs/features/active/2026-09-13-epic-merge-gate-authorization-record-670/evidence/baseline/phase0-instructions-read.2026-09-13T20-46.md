# Phase 0 Policy Reads — Issue #670

Timestamp: 2026-09-17T07-49
Task: [P0-T1]
Policy Order: policy-compliance-order (CLAUDE.md, general code change, general unit test, language-specific, then plan-named additional rules)

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/tonality.md`
7. `.claude/rules/orchestrator-state.md`

## Notes

- Work mode: `full-bug`; AC source is `spec.md` section `## Acceptance Criteria` only.
- Binding constraints carried forward: 500-line cap per production/test file; line coverage >= 85% (no PowerShell branch gate); no temporary files in tests; no `Mock git`/`Mock gh`; PowerShell toolchain order format -> analyze -> test.
- Execution amendment EA-4 applies: PoshQC MCP results carry no output, so every asserted value is derived from `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, direct `Invoke-ScriptAnalyzer` counts, and hash/porcelain captures.
