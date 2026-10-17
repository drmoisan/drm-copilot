# Phase 0 policy reads (issue #905)

Timestamp: 2026-10-11T14-44
Policy Order: CLAUDE.md > .claude/rules/general-code-change.md > .claude/rules/general-unit-test.md > .claude/rules/powershell.md > .claude/rules/quality-tiers.md

Files read, in order:

1. `CLAUDE.md` ([P0-T14]; 56 lines) - tone policy, policy reading order, four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` ([P0-T15]; 80 lines) - design principles, seven-stage toolchain loop with restart, 500-line limit, fail-fast error handling, no temporary files in tests.
3. `.claude/rules/general-unit-test.md` ([P0-T16]; 106 lines) - test independence and determinism, line coverage >= 85% (PowerShell branch-coverage exemption), no coverage exclusion of production files, tests under `tests/`, Arrange-Act-Assert.
4. `.claude/rules/powershell.md` ([P0-T17]; 97 lines) - PoshQC format, analyze, Pester 5 test order; PowerShell 7+; 500-line limit; change budget enforced by `enforce-powershell-batch-budget.ps1`; wrapper-seam mocking rules; no sleeps or weakened assertions.
5. `.claude/rules/quality-tiers.md` ([P0-T18]; 55 lines) - T1-T4 tiers; uniform gates (format pass, 0 lint errors, line coverage >= 85%, no regression on changed lines).
