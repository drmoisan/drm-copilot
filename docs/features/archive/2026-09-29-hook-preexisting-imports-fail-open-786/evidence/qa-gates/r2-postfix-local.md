# Remediation Cycle 2 Post-Fix Local Verification ([P2-T8])

Timestamp: 2026-10-10T21-12
Command: (a) sh <SCRATCHPAD>/r.sh r2-drivesim -Label post (R-DRIVESIM); (b) sh <SCRATCHPAD>/r.sh rscoped -Path <six section 3 files> (R-SCOPED, one run); (c) sh <SCRATCHPAD>/r.sh r2-ciparity -Label ciorder-fixed -ListFile <SCRATCHPAD>/r2-linux-order.list (R-CIPARITY, the [P1-T3] (c) list, background)
EXIT_CODE: 0
Output Summary: (a) every SIM-REPLACED count 0 and the R-SCOPED part reports FailedCount 0 (92 passed); (b) EXIT_CODE 0, FailedCount 0, 167 passed across six containers (29, 17, 14, 11, 21, 75); (c) PARITY ciorder-fixed containers=200 passed=5700 failed=0, ORDER-PRESERVED: yes, no FAILED line (so none names a section 3 file and none is outside the [P1-T3] (c) FAILED set), INTERCEPTION-ROW for hook-dependency-failure.Codex.Tests.ps1 passed.

Acceptance:
- (a) SIM-REPLACED: 0, 0, 0, 0, 0; FailedCount: 0
- (b) EXIT_CODE: 0; FailedCount: 0
- (c) ORDER-PRESERVED: yes; FAILED lines: none; INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed

## Outputs

Output of `<SCRATCHPAD>/r2-drivesim-post.out`:

```text
SIM-DRIVE: Z
SIM-REPLACED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 0
SIM-REPLACED: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 0
SIM-REPLACED: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 0
SIM-REPLACED: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 0
SIM-REPLACED: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 0

Starting discovery in 5 files.
Discovery found 92 tests in 398ms.
Running tests.
[+] <SCRATCHPAD>\r2-shadow-post\validate-feature-review-coverage.Coverage.Tests.ps1 1.12s (688ms|245ms)
[+] <SCRATCHPAD>\r2-shadow-post\validate-codex-subagent-routing.Coverage.Tests.ps1 294ms (194ms|60ms)
[+] <SCRATCHPAD>\r2-shadow-post\enforce-codex-model-routing.Coverage.Tests.ps1 362ms (279ms|39ms)
[+] <SCRATCHPAD>\r2-shadow-post\enforce-epic-root-invocation.Coverage.Tests.ps1 241ms (154ms|38ms)
[+] <SCRATCHPAD>\r2-shadow-post\enforce-epic-wave-barrier.Coverage.Tests.ps1 626ms (510ms|56ms)
Tests completed in 2.66s
Tests Passed: 92, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 92
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | result=Passed | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | result=Passed | passed=21 | failed=0
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
```

Output of `<SCRATCHPAD>/r2-postfix-scoped-summary.out`:

```text

Starting discovery in 6 files.
Discovery found 167 tests in 630ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 1.09s (690ms|286ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 303ms (211ms|73ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 322ms (257ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 215ms (157ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 680ms (576ms|84ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 5.01s (4.43s|167ms)
Tests completed in 7.64s
Tests Passed: 167, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 167
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | result=Passed | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | result=Passed | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | result=Passed | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | result=Passed | passed=75 | failed=0
```

Output of `<SCRATCHPAD>/r2-ciparity-ciorder-fixed.out`:

```text
PESTER-VERSION: 5.6.1

Starting discovery in 200 files.
Discovery found 5700 tests in 29.63s.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-powershell-test-purity.Tests.ps1 503ms (159ms|247ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\check-python-test-purity.Tests.ps1 128ms (83ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1 1.88s (1.73s|102ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-checkpoint-monotonic.Tests.ps1 146ms (77ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1 239ms (191ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 135ms (72ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditSemantics.Tests.ps1 137ms (84ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.EditTarget.Tests.ps1 106ms (66ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.FailClosed.Tests.ps1 115ms (72ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1 74ms (35ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1 239ms (138ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.Tests.ps1 191ms (118ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 136ms (89ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-invocation-origin.Tests.ps1 161ms (86ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 416ms (358ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 121ms (57ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 208ms (174ms|22ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 357ms (305ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 684ms (553ms|97ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 302ms (251ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 329ms (284ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 253ms (186ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 273ms (178ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 234ms (196ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 238ms (198ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 873ms (783ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 841ms (691ms|110ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 175ms (133ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 275ms (225ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-evidence-locations.Tests.ps1 134ms (72ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 316ms (233ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 104ms (66ms|26ms)
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 83.05s (59.7s|214ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 126ms (86ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 321ms (243ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1 379ms (311ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-mermaid-validation.Tests.ps1 737ms (658ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1 180ms (144ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1 185ms (136ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 1.27s (1.22s|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 290ms (229ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 206ms (160ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 135ms (68ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 146ms (72ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 44ms (14ms|20ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 305ms (239ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 393ms (257ms|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 44ms (8ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 400ms (311ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 936ms (844ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 115ms (77ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 1.36s (1.23s|109ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 495ms (432ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 432ms (379ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 199ms (159ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 2.16s (2.11s|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 909ms (813ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 388ms (314ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 377ms (324ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 296ms (247ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1 192ms (114ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 113ms (68ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 210ms (146ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 134ms (95ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 340ms (244ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 193ms (151ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 234ms (173ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 243ms (178ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 401ms (311ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 169ms (134ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 259ms (198ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 569ms (490ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 602ms (513ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 146ms (107ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 237ms (195ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget-routing.Tests.ps1 237ms (166ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 211ms (152ms|41ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-command-allowlist.Tests.ps1 303ms (236ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1 734ms (668ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 268ms (230ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1 471ms (429ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1 2.56s (2.49s|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 3.4s (3.34s|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 1.03s (985ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1 332ms (287ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1 889ms (845ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 1.14s (1.02s|81ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1 732ms (643ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 3.78s (3.72s|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 250ms (194ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 362ms (295ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 267ms (213ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 439ms (365ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1 390ms (306ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Issue824.Tests.ps1 669ms (587ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Tests.ps1 195ms (129ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 131ms (88ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget-routing.Tests.ps1 219ms (155ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 207ms (150ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\feature-folder-resolution.Tests.ps1 176ms (91ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-consumers.Issue824.Tests.ps1 1.05s (966ms|63ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation-operands.Tests.ps1 510ms (419ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824.Tests.ps1 770ms (634ms|107ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1 1.78s (1.7s|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-invocation.Tests.ps1 251ms (164ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1 440ms (373ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-payload.Tests.ps1 500ms (394ms|83ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Issue824.Tests.ps1 110ms (56ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-command-scanner.Tests.ps1 180ms (98ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 6.5s (5.95s|165ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 3.2s (1.34s|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 97ms (47ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.08s (1.99s|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 167ms (117ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUsePayload.Contract.Tests.ps1 230ms (138ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 663ms (619ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 869ms (830ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.Tests.ps1 228ms (142ms|65ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-bash.TriggerScoping.Tests.ps1 156ms (99ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Tests.ps1 804ms (738ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 108ms (56ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-executor-output.Tests.ps1 121ms (71ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 373ms (294ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1 72ms (35ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 588ms (520ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 686ms (605ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.human-interaction.Tests.ps1 307ms (271ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.model-routing.Tests.ps1 462ms (412ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1 569ms (486ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 455ms (412ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WorktreeResolution.Tests.ps1 747ms (691ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 45ms (15ms|19ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-planner-output.Tests.ps1 203ms (141ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 54ms (23ms|19ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-pr-author-output.Tests.ps1 996ms (953ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 46ms (13ms|22ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-prd-feature-output.Tests.ps1 123ms (85ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-required-artifact-output.Tests.ps1 61ms (22ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-task-researcher-output.Tests.ps1 186ms (105ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 351ms (281ms|51ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 118ms (56ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 13.65s (13.6s|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 102ms (55ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 266ms (223ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 79ms (43ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 403ms (365ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 258ms (188ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 85ms (34ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 211ms (158ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 190ms (118ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 226ms (166ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 172ms (88ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 30.57s (30.53s|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 23.92s (23.84s|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 178ms (112ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 269ms (195ms|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 172ms (109ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 286ms (224ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 100ms (64ms|23ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 159ms (79ms|47ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 121ms (78ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 94ms (46ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 106ms (63ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 356ms (294ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 284ms (233ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 208ms (162ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 170ms (115ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 298ms (246ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 360ms (294ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 568ms (493ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 175ms (132ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 1.4s (1.27s|94ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 450ms (359ms|69ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 405ms (356ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 696ms (612ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 278ms (174ms|59ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 384ms (263ms|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 241ms (164ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 178ms (140ms|27ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 455ms (377ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 307ms (253ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 145ms (93ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 112ms (66ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 313ms (270ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 183ms (115ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 4.48s (4.41s|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 220ms (176ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 144ms (97ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 173ms (99ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 221ms (154ms|45ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 201ms (114ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 3.32s (3s|87ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 87ms (47ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 302ms (259ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 11.54s (11.43s|90ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 111ms (76ms|22ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 369ms (284ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 113ms (68ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 176ms (126ms|34ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 357ms (290ms|51ms)
Tests completed in 258.5s
Tests Passed: 5700, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PARITY: ciorder-fixed | containers=200 | passed=5700 | failed=0
ORDER: 1 | tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1
ORDER: 2 | tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1
ORDER: 3 | tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1
ORDER: 4 | tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1
ORDER: 5 | tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
ORDER: 6 | tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1
ORDER: 7 | tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1
ORDER: 8 | tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
ORDER: 9 | tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1
ORDER: 10 | tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1
ORDER: 11 | tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
ORDER: 12 | tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1
ORDER: 13 | tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
ORDER: 14 | tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1
ORDER: 15 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1
ORDER: 16 | tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1
ORDER: 17 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1
ORDER: 18 | tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
ORDER: 19 | tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1
ORDER: 20 | tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
ORDER: 21 | tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
ORDER: 22 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
ORDER: 23 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1
ORDER: 24 | tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
ORDER: 25 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
ORDER: 26 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
ORDER: 27 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
ORDER: 28 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
ORDER: 29 | tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
ORDER: 30 | tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1
ORDER: 31 | tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
ORDER: 32 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
ORDER: 33 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
ORDER: 34 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
ORDER: 35 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1
ORDER: 36 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
ORDER: 37 | tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1
ORDER: 38 | tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1
ORDER: 39 | tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1
ORDER: 40 | tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
ORDER: 41 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 42 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
ORDER: 43 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
ORDER: 44 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1
ORDER: 45 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
ORDER: 46 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 47 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 48 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
ORDER: 49 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
ORDER: 50 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
ORDER: 51 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1
ORDER: 52 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
ORDER: 53 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
ORDER: 54 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
ORDER: 55 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1
ORDER: 56 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
ORDER: 57 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1
ORDER: 58 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
ORDER: 59 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
ORDER: 60 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1
ORDER: 61 | tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1
ORDER: 62 | tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1
ORDER: 63 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
ORDER: 64 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1
ORDER: 65 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1
ORDER: 66 | tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
ORDER: 67 | tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1
ORDER: 68 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
ORDER: 69 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
ORDER: 70 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
ORDER: 71 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
ORDER: 72 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
ORDER: 73 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
ORDER: 74 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
ORDER: 75 | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
ORDER: 76 | tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
ORDER: 77 | tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1
ORDER: 78 | tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
ORDER: 79 | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1
ORDER: 80 | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
ORDER: 81 | tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
ORDER: 82 | tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
ORDER: 83 | tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1
ORDER: 84 | tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
ORDER: 85 | tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1
ORDER: 86 | tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
ORDER: 87 | tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
ORDER: 88 | tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
ORDER: 89 | tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
ORDER: 90 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
ORDER: 91 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1
ORDER: 92 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1
ORDER: 93 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1
ORDER: 94 | tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1
ORDER: 95 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1
ORDER: 96 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1
ORDER: 97 | tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
ORDER: 98 | tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
ORDER: 99 | tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1
ORDER: 100 | tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
ORDER: 101 | tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1
ORDER: 102 | tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1
ORDER: 103 | tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1
ORDER: 104 | tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
ORDER: 105 | tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1
ORDER: 106 | tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
ORDER: 107 | tests/scripts/claude-hooks/hook-command-payload.Tests.ps1
ORDER: 108 | tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1
ORDER: 109 | tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
ORDER: 110 | tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
ORDER: 111 | tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
ORDER: 112 | tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1
ORDER: 113 | tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 114 | tests/scripts/claude-hooks/persist-session-id.Tests.ps1
ORDER: 115 | tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1
ORDER: 116 | tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
ORDER: 117 | tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1
ORDER: 118 | tests/scripts/claude-hooks/validate-bash.Tests.ps1
ORDER: 119 | tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
ORDER: 120 | tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
ORDER: 121 | tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1
ORDER: 122 | tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
ORDER: 123 | tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER: 124 | tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1
ORDER: 125 | tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
ORDER: 126 | tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1
ORDER: 127 | tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1
ORDER: 128 | tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1
ORDER: 129 | tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
ORDER: 130 | tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
ORDER: 131 | tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1
ORDER: 132 | tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
ORDER: 133 | tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
ORDER: 134 | tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
ORDER: 135 | tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
ORDER: 136 | tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
ORDER: 137 | tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
ORDER: 138 | tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1
ORDER: 139 | tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
ORDER: 140 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 141 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 142 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 143 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 144 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 145 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 146 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 147 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 148 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 149 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 150 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 151 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 152 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 153 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 154 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 155 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 156 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 157 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 158 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 159 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 160 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 161 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 162 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 163 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 164 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 165 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 166 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 167 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 168 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 169 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 170 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 171 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 172 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 173 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 174 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 175 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 176 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 177 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 178 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 179 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 180 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 181 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 182 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 183 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 184 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 185 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 186 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 187 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 188 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 189 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 190 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 191 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 192 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 193 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 194 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 195 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 196 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 197 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 198 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 199 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 200 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
ORDER-PRESERVED: yes
INTERCEPTION-ROW: tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed
```
