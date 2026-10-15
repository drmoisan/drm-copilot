# Coverage Remediation ([P10-T2])

Timestamp: 2026-10-10T05-56
Command: created eleven `<base>.Coverage.Tests.ps1` files for the BELOW-FLOOR files and the files with non-candidate UNCOVERED-CHANGED lines of [P10-T1]; R-SCOPED over the eleven files; R-ISOLATION over tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1; closure-seams census per file
EXIT_CODE: 0
Output Summary: The eleven created files pass (145 passed, 0 failed, 0 failed containers), and each is at most 500 lines. R-ISOLATION passes (315 passed, 0 failed), with no FAILED: line naming any created or extended file. No production file is edited by this task. Two test-construction corrections from the investigation of full-run coverage loss are recorded in deviations.md under [P10-T2]: literal-scriptblock B1 mocks in both behaviour suites, and native invocation paths through Get-HookInvocationPath. No line was found that cannot be reached in-process, so no fail-before-exception.coverage.md was written.

Created files (LINES):
- tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | 43
- tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 296
- tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | 46
- tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | 54
- tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | 46
- tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | 70
- tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 128
- tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 94
- tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 180
- tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 113
- tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 199

Extended files (LINES): tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 196; tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 210; tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | 236; tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1 | 328

CLOSURE-SEAMS and PROBE-FORM per created file:
- enforce-epic-merge-gate.Coverage | CLOSURE-SEAMS: Get-ChildOrchestratorCheckpointContent, Get-EpicOrchestratorCheckpointContent, Get-ParallelOrchestratorCheckpointContent, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText | PROBE-FORM: Claude baseline-mock probe (Get-WorktreeRunCheckpointText, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot)
- validate-feature-review-coverage.Coverage (claude) | CLOSURE-SEAMS: Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-JacocoRepoCoverage, Get-LcovRepoCoverage | PROBE-FORM: none (no named probe seam; baseline mocks in the outermost BeforeAll)
- validate-planner-output.Coverage, validate-pr-author-output.Coverage, validate-prd-feature-output.Coverage | CLOSURE-SEAMS: NONE | PROBE-FORM: none
- codex-epic-child-launch-attestation.Coverage | CLOSURE-SEAMS: Test-CodexEpicChildRoutingLaunchAuthority | PROBE-FORM: none (Codex conditional baseline mock)
- enforce-codex-model-routing.Coverage, enforce-epic-root-invocation.Coverage, validate-codex-subagent-routing.Coverage | CLOSURE-SEAMS: NONE | PROBE-FORM: none
- enforce-epic-wave-barrier.Coverage | CLOSURE-SEAMS: Get-EpicWaveBarrierCheckpointContent, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText, Test-CodexEpicChildRoutingLaunchAuthority | PROBE-FORM: Claude baseline-mock probe (Get-WorktreeRunCheckpointText, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot)
- validate-feature-review-coverage.Coverage (codex) | CLOSURE-SEAMS: Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-JacocoRepoCoverage, Get-LcovRepoCoverage | PROBE-FORM: none (Codex conditional baseline mocks)

```text
CLOSURE-SEAMS: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | Get-ChildOrchestratorCheckpointContent, Get-EpicOrchestratorCheckpointContent, Get-ParallelOrchestratorCheckpointContent, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText
  REQ: Get-ChildOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-EpicOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-ParallelOrchestratorCheckpointContent | module= | class=HookLocalContentSeam
  REQ: Get-WorktreeItemCheckpointText | module=WorktreeItemResolution | class=ModuleTextSeam
  REQ: Get-WorktreeItemLiveRoot | module=WorktreeItemResolution | class=ModuleTextSeam
  REQ: Get-WorktreeRunCheckpointText | module=WorktreeRunResolution | class=ModuleTextSeam
  COMPLIANCE: 
  PROBE-SEAMS: Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-JacocoRepoCoverage, Get-LcovRepoCoverage
  REQ: Get-ArtifactFileContent | module= | class=HookLocalContentSeam
  REQ: Get-ChangedLanguageSet | module= | class=HookLocalContentSeam
  REQ: Get-JacocoRepoCoverage | module= | class=HookLocalContentSeam
  REQ: Get-LcovRepoCoverage | module= | class=HookLocalContentSeam
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | NONE
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | NONE
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | NONE
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | Test-CodexEpicChildRoutingLaunchAuthority
  REQ: Test-CodexEpicChildRoutingLaunchAuthority | module= | class=HookLocalContentSeam
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
CLOSURE-SEAMS: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | NONE
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
CLOSURE-SEAMS: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Get-ArtifactFileContent, Get-ChangedLanguageSet, Get-JacocoRepoCoverage, Get-LcovRepoCoverage
  REQ: Get-ArtifactFileContent | module= | class=HookLocalContentSeam
  REQ: Get-ChangedLanguageSet | module= | class=HookLocalContentSeam
  REQ: Get-JacocoRepoCoverage | module= | class=HookLocalContentSeam
  REQ: Get-LcovRepoCoverage | module= | class=HookLocalContentSeam
  COMPLIANCE: 
  PROBE-SEAMS: 
  PROBE-FINDING: 
```

```text

Starting discovery in 11 files.
Discovery found 145 tests in 300ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 968ms (611ms|264ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 604ms (481ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 64ms (30ms|22ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 64ms (30ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 46ms (16ms|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 123ms (72ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 332ms (269ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 223ms (161ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 381ms (317ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 222ms (164ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 465ms (387ms|62ms)
Tests completed in 3.52s
Tests Passed: 145, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 145
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | result=Passed | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=43 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | result=Passed | passed=1 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | result=Passed | passed=2 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | result=Passed | passed=1 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | result=Passed | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | result=Passed | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=29 | failed=0
PASSED: baseline mock interception probe
PASSED: exits 0 without a deny for a command that is not a merge
PASSED: reports an absent file
PASSED: wraps a single-line file in an array
PASSED: returns an empty line array for an empty file
PASSED: keeps a multi-line file as its line array
PASSED: returns null line coverage for an absent report
PASSED: sums LF and LH counters into a percent
PASSED: returns null line coverage when no lines are found
PASSED: returns null branch coverage for an absent report
PASSED: sums BRF and BRH counters into a percent
PASSED: returns null branch coverage when no branches are found
PASSED: returns null for an absent line report
PASSED: computes line coverage from LINE counters
PASSED: returns null when the report has no LINE counter
PASSED: returns null when the LINE counters total zero
PASSED: returns null for an absent branch report
PASSED: computes branch coverage from BRANCH counters
PASSED: returns null when the report has no BRANCH counter
PASSED: returns null when the BRANCH counters total zero
PASSED: routes TypeScript to its line and branch report
PASSED: routes Python to its line and branch report
PASSED: routes PowerShell to its line and branch report
PASSED: routes CSharp to its line and branch report
PASSED: returns null for an unknown language
PASSED: fails when the audit does not mention the language
PASSED: fails when no coverage-scoped row mentions the language
PASSED: fails when a coverage row narrows scope
PASSED: fails when coverage rows carry no verdict
PASSED: fails when line coverage is below the floor without a FAIL verdict
PASSED: fails when branch coverage is below the floor
PASSED: accepts a FAIL verdict for coverage below the line floor
PASSED: blocks an empty payload
PASSED: blocks a malformed payload
PASSED: blocks an empty agent output
PASSED: blocks an artifact path outside the required location
PASSED: blocks an advertised artifact that does not exist
PASSED: blocks an artifact whose timestamp differs from the policy audit
PASSED: blocks a remediation-inputs path outside the required location
PASSED: blocks a remediation-inputs artifact with a different timestamp
PASSED: blocks an advertised remediation-inputs artifact that does not exist
PASSED: allows valid artifacts when the branch changes no tracked language
PASSED: blocks when a changed language has no coverage verdict
PASSED: allows a changed language whose coverage row carries a verdict
PASSED: blocks through Write-Error when CLAUDE_HOOK_INPUT is empty
PASSED: blocks when CLAUDE_HOOK_INPUT is empty
PASSED: exits 1 when CLAUDE_HOOK_INPUT is empty
PASSED: exits 0 when the output reports a pull request URL
PASSED: blocks when CLAUDE_HOOK_INPUT is empty
PASSED: reads every launch field from its environment variable
PASSED: joins a relative path to its base path
PASSED: denies an epic child when its receipt cannot be read from the environment path
PASSED: allows a receipt outside the epic child contexts
PASSED: throws on an empty or malformed payload
PASSED: derives a 64-character lowercase attestation key
PASSED: rejects an attestation missing a required field
PASSED: rejects an attestation missing a well-formed profile hash
PASSED: rejects an attestation whose agent profile cannot be read
PASSED: rejects an attestation whose profile binding does not hold
PASSED: accepts an attestation whose profile and payload agree
PASSED: allows a valid attestation and denies a routed agent without one
PASSED: allows an unrouted agent without an attestation
PASSED: exits 2 for whitespace stdin
PASSED: exits 2 for malformed stdin
PASSED: reads the transcript-keyed attestation and denies profile drift
PASSED: falls back to the agent-id attestation scan
PASSED: allows an unrouted agent with no attestation
PASSED: throws on an empty or malformed payload
PASSED: derives a 64-character lowercase attestation key
PASSED: allows a non-epic agent without an attestation
PASSED: denies an epic agent without an attestation
PASSED: allows an attestation for a non-epic agent
PASSED: allows an epic agent with valid provenance
PASSED: denies an epic agent whose provenance is not valid
PASSED: exits 2 for whitespace stdin
PASSED: exits 2 for malformed stdin
PASSED: reads the transcript-keyed attestation and allows valid provenance
PASSED: falls back to the agent-id attestation scan and denies missing provenance
PASSED: baseline mock interception probe
PASSED: reads optional, empty, and malformed JSON
PASSED: derives the feature key from the epic context or returns empty
PASSED: finds no feature without a checkpoint or a match
PASSED: finds the launch feature by issue and folder
PASSED: judges dependency readiness
PASSED: classifies Write as mutation True
PASSED: classifies mcp__other__write as mutation True
PASSED: classifies mcp__drm-copilot__validate_plan as mutation False
PASSED: classifies mcp__drm-copilot__promote as mutation True
PASSED: classifies shell_command as mutation True
PASSED: classifies Read as mutation False
PASSED: allows a non-mutating tool
PASSED: allows a preparation child and denies an unknown launcher context
PASSED: denies an execution child without launch authority
PASSED: allows a ready launch feature and denies an unready one
PASSED: judges a local child by its checkpoint and its epic dependencies
PASSED: exits 0 for a non-mutating tool with no local or launcher state
PASSED: reads the local checkpoint and exits 2 for an empty payload
PASSED: exits 0 without a deny for a ready execution child
PASSED: writes the deny for an unready execution child
PASSED: throws on a blank or malformed payload
PASSED: gates a tiered agent name
PASSED: stops the loop when a continuation was already requested
PASSED: allows an ungated agent
PASSED: reports a missing epic attestation
PASSED: reports a missing routed attestation
PASSED: reports an identity mismatch
PASSED: reports missing epic provenance
PASSED: reports invalid routing
PASSED: reports a model change
PASSED: allows a matching attestation
PASSED: returns nothing when the state root is absent
PASSED: returns the attestation whose agent id matches and skips unreadable files
PASSED: returns nothing when no attestation matches
PASSED: exits 2 for blank stdin
PASSED: exits 2 for a missing session id
PASSED: requests a continuation for a routed agent without an attestation
PASSED: resolves the repository root two levels above the hooks folder
PASSED: returns no audit when the active folder is absent
PASSED: returns the most recently written audit
PASSED: returns no language when the PR summary is absent
PASSED: maps changed files to their languages
PASSED: parses LCOV line counters
PASSED: returns null LCOV coverage when absent or empty
PASSED: parses JaCoCo LINE counters
PASSED: returns null JaCoCo coverage when absent, counter-free, or zero
PASSED: routes TypeScript to its report
PASSED: routes Python to its report
PASSED: routes PowerShell to its report
PASSED: routes CSharp to its report
PASSED: returns null for an unknown language
PASSED: reports an unmentioned language
PASSED: reports no coverage row
PASSED: reports a narrowing row
PASSED: reports a row without a verdict
PASSED: reports low coverage without FAIL
PASSED: accepts a FAIL verdict for low coverage
PASSED: requests one continuation, then stops when the stop hook is already active
PASSED: exits 2 for empty stdin
PASSED: exits 2 for malformed stdin
PASSED: exits 2 for a missing stop_hook_active
PASSED: exits 2 for a non-review payload
PASSED: exits 0 when no policy audit exists
PASSED: exits 0 when the branch changes no tracked language
PASSED: requests a continuation when a changed language lacks a verdict
PASSED: stops the continuation loop when a validator error occurs with the stop hook active
```

```text

Starting discovery in 1 files.
Discovery found 315 tests in 21.99s.
Running tests.
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 81.64s (59.23s|427ms)
Tests completed in 81.64s
Tests Passed: 315, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 315
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | result=Passed | passed=315 | failed=0
PASSED: AC-2 non-vacuity claude-hooks yields at least one suite
PASSED: AC-2 non-vacuity codex-hooks yields at least one suite
PASSED: AC-4 tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/persist-session-id.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-bash.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-provenance.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-6 tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 suite lacking a probe call yields a finding
PASSED: AC-6 suite with a probe call yields none
PASSED: AC-5 process-spawning report claude-hooks
PASSED: AC-5 process-spawning report codex-hooks
PASSED: AC-2 no hard-coded suite list in N2
PASSED: AC-2 no hard-coded suite list or decision D9 note in the legacy guard
PASSED: AC-3 closure-only variable-driven load is detected
PASSED: AC-3 suite whose rows never reach the seam is still flagged
PASSED: AC-5 process-spawning fixture is reported and does not fail
PASSED: AC-2 missing suite yields a finding
PASSED: AC-2 unparseable suite yields a finding
PASSED: AC-4 helper form satisfies the requirement
PASSED: AC-4 helper form naming the wrong seam is a finding
PASSED: AC-4 script-scope seam needs no import
PASSED: AC-4 form F2 fixture complies
PASSED: AC-4 form F3 fixture complies
PASSED: AC-4 helper form with a -ForEach-bound -Seam variable satisfies the requirement
PASSED: AC-4 helper form with an unresolvable -Seam variable is a finding
PASSED: AC-4 helper form with ExtraSeam entries adds a seam and an empty entry adds none
```
