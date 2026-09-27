# P0-T10 Baseline Targeted Pester (CR-PESTER-LIST, LIST-BASE)

Timestamp: 2026-09-27T10-01
Command: Route C (scratchpad cr-pester-list.ps1 = CR-PESTER-LIST with <LIST> = LIST-BASE selected by a -ListName argument, ending `exit $code`; run by `pwsh -NoProfile -File` via `sh` from the worktree root; combined output captured to a scratchpad log)
EXIT_CODE: 0
Output Summary:
Tests Passed: 277, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
CONTAINER: enforce-pr-author-skill.TargetResolution.Tests.ps1 | Result=Passed
CONTAINER: enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | Result=Passed
CONTAINER: enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | Result=Passed
CONTAINER: enforce-orchestration-preimplementation-gate.Tests.ps1 | Result=Passed
CONTAINER: enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | Result=Passed
CONTAINER: enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | Result=Passed
CONTAINER: enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | Result=Passed
CONTAINER: enforce-pr-author-skill.EpicScope.Tests.ps1 | Result=Passed
CONTAINER: enforce-model-routing-receipt.EpicScope.Tests.ps1 | Result=Passed
CONTAINER: enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | Result=Passed
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
Process exit code: 0 (matches EXIT_CODE_COMPUTED)
FAILED lines: none
Precondition: artifacts/orchestration/epic-orchestrator-state.json absent (P0-T4), so this baseline reflects the CI condition.
