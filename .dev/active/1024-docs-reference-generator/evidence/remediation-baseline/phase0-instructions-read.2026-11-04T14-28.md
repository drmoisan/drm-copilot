# Phase 0 Instructions Read (issue 1024, remediation cycle 1)

Timestamp: 2026-11-04T14-28
Task: [P0-T1]
Policy Order: policy-compliance-order (CLAUDE.md, general code change, general unit test, language rule for PowerShell)

## Files read

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `docs/features/active/2026-10-30-docs-reference-generator-1024/remediation-inputs.2026-11-04T14-13.md`
6. `docs/features/active/2026-10-30-docs-reference-generator-1024/code-review.2026-11-04T14-03.md`
7. `docs/features/active/2026-10-30-docs-reference-generator-1024/policy-audit.2026-11-04T14-03.md`
8. `docs/features/active/2026-10-30-docs-reference-generator-1024/feature-audit.2026-11-04T14-03.md`

## Notes

- R1 (broad catch in `ConvertTo-DocsReferenceFrontMatterText`) is recorded as Minor in the code review and as PARTIAL (fail fast, no silent catch) in the policy audit.
- AC-24, US-17 and AC-27 are UNVERIFIED in the feature audit and CI-dependent; this cycle does not check them off.
