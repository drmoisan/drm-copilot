# Final QA remediation: first full Pester pass (P5-T4)

Timestamp: 2026-11-24T11-53
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (full gate, SCRATCH run p5-pester, 2026-11-24T11-31 to 11-44)
EXIT_CODE: 1
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 773.15 s, exit code 1, with two failures; both were caused by this change and are fixed; the final QA loop restarts from P5-T1.

Failures:
1. tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, row `AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1 complies with the baseline isolation form for every closure seam` — "seam Get-ChildOrchestratorCheckpointContent: Mock body is not exactly $null". The new Claude suite mocked the closure seam with a per-row body in its outermost BeforeAll. Fix: the outermost BeforeAll keeps `Mock Get-ChildOrchestratorCheckpointContent { $null }`, and a Describe-level `BeforeEach` supplies the per-row body.
2. tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1, row `issue #850 changed-file constraints.keeps every changed file within the line cap` — ".claude/hooks/enforce-epic-merge-gate.ps1 ... Expected <= 500 ... got 501". P2-T2 added three header lines. Fix: the header condition 1 note is rewrapped into two lines; the file has 500 lines; its bundle copy is re-copied (cmp-identical); the 0014 block is regenerated.

Neither suite was in the targeted selections of P2-T2 or the Phase 2 gate, because the selection rule searched for suites that name the child-CI helper, the new suites, and the completion files; the full gate is where they ran.

Verification of the fix:
- sh SCRATCH/issue-1233-ps-files.sh check <gate>,<suite> -> 0 (format drift=0 pssa findings=0)
- sh SCRATCH/issue-1233-ledger-verify.sh -> 0 (blocks=65 files=28 problems=0)
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 <Set L> -> 0 (every shard 0 failures)

Correction: task-check.P2-T2.2026-11-24T08-09.md and pre-push-review.P2.2026-11-24T09-03.md state 501 lines for the Claude gate; after this fix the file has 500 lines.
