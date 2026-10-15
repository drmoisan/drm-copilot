# Remediation Cycle 2 Isolation Guard ([P2-T7])

Timestamp: 2026-10-10T21-10
Command: sh <SCRATCHPAD>/r.sh closure-seams -Suite <six section 3 files> (main-plan rule 13 clause (i): Get-EpicStateSuiteState after dot-sourcing the three EpicStateIsolation helpers, fresh process); sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (R-ISOLATION)
EXIT_CODE: 0
Output Summary: six CLOSURE-SEAMS and six PROBE-FORM lines recorded (four suites with no named seam: form none; enforce-epic-wave-barrier.Coverage and hook-dependency-failure.Codex: form 2); R-ISOLATION passed 315 of 315 with FailedCount 0, so no FAILED line names any of the six paths.

## Records

CLOSURE-SEAMS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-JacocoRepoCoverage, Get-LcovRepoCoverage
PROBE-FORM: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | none
CLOSURE-SEAMS: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | NONE
PROBE-FORM: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | none
CLOSURE-SEAMS: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | NONE
PROBE-FORM: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | none
CLOSURE-SEAMS: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | NONE
PROBE-FORM: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | none
CLOSURE-SEAMS: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | Get-EpicWaveBarrierCheckpointContent, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText, Test-CodexEpicChildRoutingLaunchAuthority
PROBE-FORM: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 2
CLOSURE-SEAMS: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-CheckpointContent, Get-CheckpointFileContent, Get-ChildOrchestratorCheckpointContent, Get-CleanupWorktreeManifestContent, Get-EpicCheckpointContent, Get-EpicOrchestratorCheckpointContent, Get-EpicPlanningRegisteredMcpTool, Get-EpicScopeCheckpointText, Get-EpicWaveBarrierCheckpointContent, Get-EpicWorktreeGateCheckpointContent, Get-EpicWorktreeGateParallelCheckpointContent, Get-JacocoRepoCoverage, Get-LcovRepoCoverage, Get-ParallelCheckpointContent, Get-ParallelOrchestratorCheckpointContent, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeResolutionGitFileText, Get-WorktreeRunCheckpointText, Invoke-PowerShellBatchBudgetHook, Invoke-PythonBatchBudgetHook, Test-CodexEpicChildRoutingLaunchAuthority, Test-EpicPlanningBashAllowed
PROBE-FORM: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 2

Form derivation (main-plan rule 13 clause (iii)): the four suites without a named seam carry no probe (none). enforce-epic-wave-barrier.Coverage.Tests.ps1 has the named seams Get-WorktreeRunCheckpointText, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot (DefiningFile under .claude/lib/worktree-resolution, module text seams); its outermost BeforeAll dot-sources .codex/hooks/enforce-epic-wave-barrier.ps1, whose loaded closure does not define Resolve-EpicScopeCheckpoint (the only definition is .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1:432), so the form is 2 (the suite's probe at line 66 uses -Surface 'Claude'). hook-dependency-failure.Codex.Tests.ps1 has all four named seams (Get-EpicScopeCheckpointText has a .claude/lib DefiningFile in EpicScopeResolution); its outermost BeforeAll blocks dot-source test helpers only, no hook, so the form is 2 (probe at line 134 uses -Surface 'Claude'). The E-HDF insertion precedes every registration and follows the last dot-source, so clause (ii) still holds.

R-ISOLATION guard rows for the six suites (all PASSED):
- AC-4 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
- AC-4 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
- AC-4 tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
- AC-4 tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
- AC-4 tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
- AC-4 tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 complies with the baseline isolation form for every closure seam
- AC-6 tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 calls the interception probe from inside an It
- AC-6 tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 calls the interception probe from inside an It

No FAILED line was printed (FailedCount 0), so no FAILED line contains any of the six paths.

Output of `<SCRATCHPAD>/closure-seams.out`:

```text
CLOSURE-SEAMS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-JacocoRepoCoverage, Get-LcovRepoCoverage
  REQ: Get-ArtifactFileContent | module= | class=HookLocalContentSeam
  REQ: Get-ChangedLanguageSet | module= | class=HookLocalContentSeam
  REQ: Get-JacocoRepoCoverage | module= | class=HookLocalContentSeam
  REQ: Get-LcovRepoCoverage | module= | class=HookLocalContentSeam
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | NONE
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | NONE
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | NONE
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | Get-EpicWaveBarrierCheckpointContent, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText, Test-CodexEpicChildRoutingLaunchAuthority
  REQ: Get-EpicWaveBarrierCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-WorktreeItemCheckpointText | module=WorktreeItemResolution | class=ModuleTextSeam
  REQ: Get-WorktreeItemLiveRoot | module=WorktreeItemResolution | class=ModuleTextSeam
  REQ: Get-WorktreeRunCheckpointText | module=WorktreeRunResolution | class=ModuleTextSeam
  REQ: Test-CodexEpicChildRoutingLaunchAuthority | module= | class=HookLocalContentSeam
  COMPLIANCE: 
  PROBE-SEAMS: Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-CheckpointContent, Get-CheckpointFileContent, Get-ChildOrchestratorCheckpointContent, Get-CleanupWorktreeManifestContent, Get-EpicCheckpointContent, Get-EpicOrchestratorCheckpointContent, Get-EpicPlanningRegisteredMcpTool, Get-EpicScopeCheckpointText, Get-EpicWaveBarrierCheckpointContent, Get-EpicWorktreeGateCheckpointContent, Get-EpicWorktreeGateParallelCheckpointContent, Get-JacocoRepoCoverage, Get-LcovRepoCoverage, Get-ParallelCheckpointContent, Get-ParallelOrchestratorCheckpointContent, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeResolutionGitFileText, Get-WorktreeRunCheckpointText, Invoke-PowerShellBatchBudgetHook, Invoke-PythonBatchBudgetHook, Test-CodexEpicChildRoutingLaunchAuthority, Test-EpicPlanningBashAllowed
  REQ: Get-ArtifactFileContent | module= | class=HookLocalContentSeam
  REQ: Get-ChangedLanguageSet | module= | class=HookLocalContentSeam
  REQ: Get-CheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-CheckpointFileContent | module= | class=HookLocalContentSeam
  REQ: Get-ChildOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-CleanupWorktreeManifestContent | module=CleanupWorktreeManifest | class=ModuleTextSeam
  REQ: Get-EpicCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicPlanningRegisteredMcpTool | module= | class=HookLocalContentSeam
  REQ: Get-EpicScopeCheckpointText | module=EpicScopeResolution | class=ModuleTextSeam
  REQ: Get-EpicScopeCheckpointText | module= | class=HookLocalContentSeam
  REQ: Get-EpicWaveBarrierCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicWorktreeGateCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicWorktreeGateParallelCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-JacocoRepoCoverage | module= | class=HookLocalContentSeam
  REQ: Get-LcovRepoCoverage | module= | class=HookLocalContentSeam
  REQ: Get-ParallelCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-ParallelOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-WorktreeItemCheckpointText | module=WorktreeItemResolution | class=ModuleTextSeam
  REQ: Get-WorktreeItemLiveRoot | module=WorktreeItemResolution | class=ModuleTextSeam
  REQ: Get-WorktreeResolutionGitFileText | module= | class=HookLocalContentSeam
  REQ: Get-WorktreeRunCheckpointText | module=WorktreeRunResolution | class=ModuleTextSeam
  REQ: Invoke-PowerShellBatchBudgetHook | module= | class=CwdDerivedResolver
  REQ: Invoke-PythonBatchBudgetHook | module= | class=CwdDerivedResolver
  REQ: Test-CodexEpicChildRoutingLaunchAuthority | module= | class=HookLocalContentSeam
  REQ: Test-EpicPlanningBashAllowed | module= | class=HookLocalContentSeam
  COMPLIANCE: 
  PROBE-SEAMS: Get-EpicScopeCheckpointText, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText
  PROBE-FINDING: 
```

Output of `<SCRATCHPAD>/r2-isolation-p2-summary.out`:

```text

Starting discovery in 1 files.
Discovery found 315 tests in 21.83s.
Running tests.
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 80.01s (57.78s|421ms)
Tests completed in 80.02s
Tests Passed: 315, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 315
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | result=Passed | passed=315 | failed=0
```
