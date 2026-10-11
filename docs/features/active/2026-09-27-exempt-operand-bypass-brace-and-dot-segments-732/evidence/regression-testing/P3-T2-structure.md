# P3-T2 Claude EpicScopeTargets suite structure run (issue #738)

Timestamp: 2026-10-09T03-59
Task: [P3-T2]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 1 files)
EXIT_CODE: 1
ExpectedExitCode: 1

## Output

```text
FILES: 1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
PassedCount: 3
FailedCount: 9
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a second segment that targets a different not-ready worktree
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a relative -C selector in epic scope
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies an unresolvable -C selector in epic scope
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a directory-changing segment in epic scope
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a wrapper-led git segment in epic scope
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write into a not-ready epic worktree
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a target outside the epic scope of the session root
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).evaluates every value of a repeated -C selector
FAILED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies an ambiguous epic target
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).allows when every target is epic scope and ready
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).keeps the single-feature decision for a relative -C selector outside epic scope
PASSED: enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).keeps the single-feature decision for a directory change outside epic scope
```

Output Summary: PassedCount 3, FailedCount 9, FailedBlocksCount 0, FailedContainersCount 0; 9 FAILED: lines listed above.

