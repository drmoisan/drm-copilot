# Special Cases ([P6-T7])

Timestamp: 2026-10-10T00-03
Command: R-SCOPED over tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 (run 1); C8 harness correction (deviations.md, [P6-T7]); R-SCOPED again (final run); R-ISOLATION over tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 after the suite edit (302 passed, 0 failed)
EXIT_CODE: 0
Output Summary: Final run: 11 passed, 0 failed; every C1 to C8 expanded row is on a PASSED: line. All three C4 rows passed on the first run, so RS-10 was not applied and no -Global was added. Run 1 failed only C8: the in-process & route let the CommandNotFound error raised in the validator's catch (helper absent) propagate to the It's try, which a registered hook running in its own pwsh -File process does not have. C8 now drives the hook in a fresh runspace with runspace-local Join-Path and Import-Module failures (no enclosing try); a probe confirmed that this route still fails when `$ErrorActionPreference = 'Stop'` precedes the import, so C8 still detects the RS-8 hazard.

FR-7.3: confirmed

```text
Run 1 (before the C8 harness correction), R-SCOPED over tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1, exit 1:
PassedCount: 10
FailedCount: 1
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: C8: .claude/hooks/validate-orchestrator-output.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail | The term 'Add-HookDependencyFailure' is not recognized as a name of a cmdlet, function, script file, or executable program.
PASSED: baseline mock interception probe
PASSED: C1: reports a nested EpicScopeReadiness.psm1 failure under enforce-pr-author-skill-helpers.ps1 as that top-level dependency
PASSED: C2: reports a nested hook-command-scanner.ps1 load failure under enforce-pr-author-skill.epic-base-branch.ps1 as that top-level dependency
PASSED: C3: denies through the merge gate when enforce-epic-merge-gate-authorization.ps1 fails to load
PASSED: C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1
PASSED: C4: makes the pre-loaded OrchestratorStateCompletion visible to the lazy-load check in .claude/hooks/validate-orchestrator-output.ps1
PASSED: C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1
PASSED: C5: enforce-mermaid-validation.ps1 returns no deny when MermaidValidation is unavailable
PASSED: C6: enforce-mermaid-validation.ps1 denies naming HookPayload.psm1 when that import fails
PASSED: C7: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED:

Probe (scratch scripts, not committed): a catch that calls an undefined function, run through pwsh -File, reaches the tail and exits 2;
run with & inside a caller's try, the CommandNotFound error propagates to the caller's catch (the It's try); run in a fresh
runspace, it reaches the tail and exits 2, and with $ErrorActionPreference = 'Stop' set before the try it does not reach the tail (exit 0).
probe-child.ps1: out=reached-tail,2 hadErrors=True
probe-child-stop.ps1: out=0 hadErrors=True
```

```text

Starting discovery in 1 files.
Discovery found 11 tests in 3.4s.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 5.77s (2.13s|269ms)
Tests completed in 5.79s
Tests Passed: 11, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 11
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | result=Passed | passed=11 | failed=0
PASSED: baseline mock interception probe
PASSED: C1: reports a nested EpicScopeReadiness.psm1 failure under enforce-pr-author-skill-helpers.ps1 as that top-level dependency
PASSED: C2: reports a nested hook-command-scanner.ps1 load failure under enforce-pr-author-skill.epic-base-branch.ps1 as that top-level dependency
PASSED: C3: denies through the merge gate when enforce-epic-merge-gate-authorization.ps1 fails to load
PASSED: C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1
PASSED: C4: makes the pre-loaded OrchestratorStateCompletion visible to the lazy-load check in .claude/hooks/validate-orchestrator-output.ps1
PASSED: C4: makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1
PASSED: C5: enforce-mermaid-validation.ps1 returns no deny when MermaidValidation is unavailable
PASSED: C6: enforce-mermaid-validation.ps1 denies naming HookPayload.psm1 when that import fails
PASSED: C7: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED:
PASSED: C8: .claude/hooks/validate-orchestrator-output.ps1 reaches the tail check without a script-terminating error when the helper and a dependency both fail
```
