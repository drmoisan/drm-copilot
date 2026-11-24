# Post-Sync Targeted Check (Issue #1233)

Timestamp: 2026-11-24T13-36
Command: sh SCRATCH/issue-1233-postsync-pester.sh (launcher `run-test-suite.sh pester -TestPath` over 45 targeted suites: every claude-hooks enforce-epic-merge-gate.* and enforce-epic-merge-gate-release.* suite, every codex-hooks enforce-epic-merge-gate-* suite, hook-dependency-failure.Claude and SpecialCases, release-merge.Parity, session-root-reads-850.Constraints, codex-epic-runtime-contracts, cross-tree-helper-identity, child-ci-opt-out-skill-contract, HarnessGeneration.RepoGate, ProcessReductionChain*, ProcessReductionLedger*)
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, all 8 shards exit 0; merged JUnit tests=2082 failures=0 errors=0. Run against head 16022bae3 (merge of origin/main 23458fade at 8dccd6cdf plus the line-cap fix). Targeted selection only; not gate coverage evidence.

Timestamp: 2026-11-24T13-36
Command: pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
EXIT_CODE: 0
Output Summary: harness-generation: no drift.

Timestamp: 2026-11-24T13-36
Command: wc -l .claude/hooks/enforce-epic-merge-gate.ps1; cmp against the claude-customizations bundle copy
EXIT_CODE: 0
Output Summary: 500 lines (cap 500 in session-root-reads-850.Constraints.Tests.ps1); bundle copy byte-identical.
