# P4-T4 Unchanged-Behavior Run (CR-PESTER-LIST, LIST-BASE)

Timestamp: 2026-09-27T10-14
Command: Route C (scratchpad cr-pester-list.ps1 = CR-PESTER-LIST with <LIST> = LIST-BASE selected by -ListName, ending `exit $code`; run by `pwsh -NoProfile -File` via `sh` from the worktree root), after all seven suite edits
EXIT_CODE: 0
Output Summary:
Tests Passed: 277, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
CONTAINER lines: all ten Result=Passed
SUITE: enforce-model-routing-receipt.EpicScope.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | Passed=20 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | Passed=33 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | Passed=119 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | Passed=19 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-orchestration-preimplementation-gate.Tests.ps1 | Passed=35 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | Passed=19 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-pr-author-skill.EpicScope.Tests.ps1 | Passed=5 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-pr-author-skill.TargetResolution.Tests.ps1 | Passed=5 | Failed=0 | Skipped=0 | NotRun=0
SUITE: enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | Passed=18 | Failed=0 | Skipped=0 | NotRun=0
TOTAL: Passed=277 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0

## Comparison with the baseline (evidence/baseline/pester-targeted-baseline.2026-09-27T10-01.md)

| Suite | Baseline line (P0-T10) | After line | Result |
|---|---|---|---|
| S1 enforce-pr-author-skill.TargetResolution.Tests.ps1 | Passed=5 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=5 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| S2 enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | Passed=18 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=18 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| S3 enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | Passed=20 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=20 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| S4 enforce-orchestration-preimplementation-gate.Tests.ps1 | Passed=35 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=35 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| S5 enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | Passed=19 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=19 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| S6 enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | Passed=119 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=119 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| S7 enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | Passed=33 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=33 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| enforce-pr-author-skill.EpicScope.Tests.ps1 | Passed=5 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=5 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| enforce-model-routing-receipt.EpicScope.Tests.ps1 | Passed=4 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=4 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |
| enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | Passed=19 \| Failed=0 \| Skipped=0 \| NotRun=0 | Passed=19 \| Failed=0 \| Skipped=0 \| NotRun=0 | EQUAL |

All ten rows are EQUAL.
