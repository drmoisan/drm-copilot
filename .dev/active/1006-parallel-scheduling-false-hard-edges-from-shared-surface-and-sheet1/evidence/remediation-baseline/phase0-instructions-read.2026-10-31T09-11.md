# Phase 0 Instructions Read (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-11
Command: Read tool over each file below, in order
EXIT_CODE: 0
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> quality-tiers -> language rules (PowerShell, TypeScript, TypeScript suppressions, commenting) -> plan-acceptance-gates -> execution-environment skill -> evidence-and-timestamp-conventions skill -> cycle inputs
Output Summary: All 13 files read in the order below; no file missing.

## Files read

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/typescript.md`
7. `.claude/rules/typescript-suppressions.md`
8. `.claude/rules/self-explanatory-code-commenting.md`
9. `.claude/rules/plan-acceptance-gates.md`
10. `.claude/skills/execution-environment/SKILL.md`
11. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
12. `FEATURE/remediation-inputs.2026-10-31T08-57.md`
13. `FEATURE/code-review.2026-10-31T08-57.md`

## Notes

- `quality-tiers.yml` exists at the repository root, so the tier gate matrix applies; coverage thresholds are the 85 percent line and 75 percent branch defaults (the root `CLAUDE.md` states none).
- The Pester route is the self-hosted PoshQC module launched from a `sh` script under SCRATCH; counts are read from JUnit files.
