# Remediation Baseline: Leg Reference (Cycle 1)

Timestamp: 2026-11-14T15-42
Command: reads evidence/baseline/pester-parallel.2026-11-14T11-50.md and evidence/qa-gates/coverage-comparison.2026-11-14T14-36.md; wc -l on the hook and test file (no new test run)
EXIT_CODE: 0
Output Summary:
- Phase 0 baseline (evidence/baseline/pester-parallel.2026-11-14T11-50.md): tests 25297, passed 25281, failed 0, errors 0, skipped 16; repo-wide line coverage 96.02% (42083/43827).
- Per-file line coverage of .claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1 from the greatest-stamp evidence/qa-gates/coverage-comparison.*.md of the main plan (2026-11-14T14-36): 100.00% (32/32). The Phase 0 baseline holds no row for this file (new file in the main plan).
- Main-plan final gate for reference: tests 25398, passed 25382, failed 0, skipped 16; repo-wide 96.03% (42206/43950).
- Logical line counts: .claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1 is 130; tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1 is 280. Both under 500.
