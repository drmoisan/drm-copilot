# Baseline PowerShell Coverage (P0-T5)

Timestamp: 2026-10-02T07-45
Command: CI-evidence deviation DEV-P0-T5 (replaces CX args '.', 'artifacts/pester/powershell-coverage.xml'). Source: CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380, job `poshqc / PowerShell QC` https://github.com/drmoisan/drm-copilot/actions/runs/36978425380/job/110747263219; artifact `poshqc-test-results` (powershell-coverage.xml) reduced by the orchestrator with `poetry run python artifacts/ci/ci_evidence.py cx artifacts/ci/run-36978425380/powershell-coverage.xml <CI_ROOT>` (Python port of rule CX, run root = the CI checkout root, written <CI_ROOT> below) into artifacts/ci/run-36978425380/cx.txt, read with the Read tool.
EXIT_CODE: 0
Output Summary: LINE_PCT=96.38 LINE_TOTAL=11887 FILES=127
- KEY scripts/powershell/PoshQC|PoshQC.Testing.psm1 missed=0 covered=202
- LINE_MISSED=430 LINE_COVERED=11457; KEYS_SHA256=ed011a15c71b182d5725ba76036784a0d06b5b4d343e836250ad88096b2833fd
- Pre-fix allow-list population baseline (the measured set is the runsettings CodeCoverage.Path list). Acceptance: numeric LINE_PCT and FILES > 0. Met.
- Measured tree identical to the branch baseline (branch differs from 71f8dcb4 only under the feature folder).

## Package-name shape observation (first three `package` elements, raw `name`)

The CI coverage XML emits package names as absolute forward-slash paths under the checkout root:

1. `<CI_ROOT>/.claude/hooks`
2. `<CI_ROOT>/.claude/lib/blast-radius`
3. `<CI_ROOT>/.claude/lib/ci-gate`

`<CI_ROOT>` is the GitHub Actions checkout root of the Windows runner. The raw names use forward slashes as recorded in the reduction output (`FIRST_PACKAGE_NAMES=` line).

## Full CX output

```text
LINE_MISSED=430
LINE_COVERED=11457
LINE_TOTAL=11887
LINE_PCT=96.38
FILES=127
KEYS_SHA256=ed011a15c71b182d5725ba76036784a0d06b5b4d343e836250ad88096b2833fd
FIRST_PACKAGE_NAMES=<CI_ROOT>/.claude/hooks ; <CI_ROOT>/.claude/lib/blast-radius ; <CI_ROOT>/.claude/lib/ci-gate
KEY .claude/hooks|check-powershell-test-purity.ps1 missed=4 covered=51
KEY .claude/hooks|check-python-test-purity.ps1 missed=4 covered=56
KEY .claude/hooks|enforce-batch-budget-route.ps1 missed=2 covered=32
KEY .claude/hooks|enforce-checkpoint-monotonic.ps1 missed=4 covered=90
KEY .claude/hooks|enforce-completion-consistency.ps1 missed=10 covered=117
KEY .claude/hooks|enforce-completion-helpers.ps1 missed=3 covered=40
KEY .claude/hooks|enforce-discovery-artifact-gate.ps1 missed=3 covered=59
KEY .claude/hooks|enforce-epic-invocation-origin.ps1 missed=7 covered=60
KEY .claude/hooks|enforce-epic-merge-gate-authorization.ps1 missed=0 covered=100
KEY .claude/hooks|enforce-epic-merge-gate-resolution.ps1 missed=4 covered=32
KEY .claude/hooks|enforce-epic-merge-gate.ps1 missed=4 covered=121
KEY .claude/hooks|enforce-epic-wave-barrier.ps1 missed=1 covered=100
KEY .claude/hooks|enforce-epic-worktree-removal-gate-resolution.ps1 missed=1 covered=22
KEY .claude/hooks|enforce-epic-worktree-removal-gate.ps1 missed=5 covered=104
KEY .claude/hooks|enforce-evidence-locations.ps1 missed=4 covered=36
KEY .claude/hooks|enforce-feature-folder-order.ps1 missed=4 covered=41
KEY .claude/hooks|enforce-mermaid-validation.ps1 missed=6 covered=73
KEY .claude/hooks|enforce-model-routing-receipt.ps1 missed=3 covered=64
KEY .claude/hooks|enforce-orchestration-preimplementation-gate-epic-scope.ps1 missed=0 covered=67
KEY .claude/hooks|enforce-orchestration-preimplementation-gate-helpers.ps1 missed=3 covered=169
KEY .claude/hooks|enforce-orchestration-preimplementation-gate-modes.ps1 missed=2 covered=132
KEY .claude/hooks|enforce-orchestration-preimplementation-gate.ps1 missed=5 covered=148
KEY .claude/hooks|enforce-parallel-abandon-gate.ps1 missed=5 covered=73
KEY .claude/hooks|enforce-parallel-cohort-barrier-helpers.ps1 missed=0 covered=77
KEY .claude/hooks|enforce-parallel-cohort-barrier.ps1 missed=1 covered=75
KEY .claude/hooks|enforce-parallel-drift-gate-helpers.ps1 missed=0 covered=66
KEY .claude/hooks|enforce-parallel-drift-gate.ps1 missed=1 covered=113
KEY .claude/hooks|enforce-parallel-worktree-removal-gate.ps1 missed=7 covered=100
KEY .claude/hooks|enforce-powershell-batch-budget.ps1 missed=6 covered=126
KEY .claude/hooks|enforce-pr-author-skill-helpers.ps1 missed=3 covered=97
KEY .claude/hooks|enforce-pr-author-skill.epic-base-branch.ps1 missed=1 covered=30
KEY .claude/hooks|enforce-pr-author-skill.ps1 missed=4 covered=46
KEY .claude/hooks|enforce-prd-feature-before-planner-helpers.ps1 missed=2 covered=57
KEY .claude/hooks|enforce-prd-feature-before-planner.ps1 missed=9 covered=84
KEY .claude/hooks|enforce-promotion-mcp-only.ps1 missed=4 covered=56
KEY .claude/hooks|enforce-python-batch-budget.ps1 missed=6 covered=126
KEY .claude/hooks|hook-command-invocation.ps1 missed=1 covered=123
KEY .claude/hooks|hook-command-scanner.ps1 missed=0 covered=183
KEY .claude/hooks|persist-session-id.ps1 missed=5 covered=37
KEY .claude/hooks|validate-bash.ps1 missed=5 covered=88
KEY .claude/hooks|validate-discovery-artifact-gate.ps1 missed=5 covered=56
KEY .claude/hooks|validate-orchestrator-output.ps1 missed=6 covered=104
KEY .claude/hooks|validate-planner-output.ps1 missed=7 covered=181
KEY .claude/lib/blast-radius|BlastRadius.psm1 missed=0 covered=107
KEY .claude/lib/blast-radius|BlastRadiusConfig.psm1 missed=0 covered=81
KEY .claude/lib/blast-radius|BlastRadiusConflict.psm1 missed=2 covered=95
KEY .claude/lib/blast-radius|BlastRadiusExtraction.psm1 missed=0 covered=86
KEY .claude/lib/blast-radius|BlastRadiusGlob.psm1 missed=0 covered=77
KEY .claude/lib/blast-radius|BlastRadiusNormalization.psm1 missed=0 covered=51
KEY .claude/lib/blast-radius|BlastRadiusScheduling.psm1 missed=0 covered=116
KEY .claude/lib/blast-radius|BlastRadiusTokenShape.psm1 missed=0 covered=20
KEY .claude/lib/blast-radius|BlastRadiusValidation.psm1 missed=3 covered=98
KEY .claude/lib/blast-radius|BlastRadiusWriteIntent.psm1 missed=0 covered=102
KEY .claude/lib/ci-gate|Invoke-CiGateParser.ps1 missed=2 covered=32
KEY .claude/lib/cleanup-manifest|CleanupWorktreeManifest.psm1 missed=8 covered=100
KEY .claude/lib/codex-routing|CodexDeployment.psm1 missed=0 covered=68
KEY .claude/lib/codex-routing|CodexTopology.psm1 missed=0 covered=109
KEY .claude/lib/discovery-validation|DiscoveryValidation.psm1 missed=6 covered=103
KEY .claude/lib/hook-payload|HookPayload.psm1 missed=4 covered=100
KEY .claude/lib/mermaid|MermaidGrammar.psm1 missed=1 covered=142
KEY .claude/lib/mermaid|MermaidLineScanner.psm1 missed=0 covered=164
KEY .claude/lib/mermaid|MermaidMarkdownFences.psm1 missed=0 covered=80
KEY .claude/lib/mermaid|MermaidValidation.psm1 missed=2 covered=148
KEY .claude/lib/model-routing|ModelRouting.psm1 missed=0 covered=47
KEY .claude/lib/orchestrator-state|OrchestratorState.psm1 missed=0 covered=110
KEY .claude/lib/orchestrator-state|OrchestratorStateCheckpointValue.psm1 missed=0 covered=66
KEY .claude/lib/orchestrator-state|OrchestratorStateCodexModelReceipts.psm1 missed=0 covered=81
KEY .claude/lib/orchestrator-state|OrchestratorStateCodexTopologyReceipts.psm1 missed=0 covered=81
KEY .claude/lib/orchestrator-state|OrchestratorStateCompletion.psm1 missed=0 covered=97
KEY .claude/lib/orchestrator-state|OrchestratorStateCompletionChecks.psm1 missed=1 covered=99
KEY .claude/lib/orchestrator-state|OrchestratorStateIssueAdoption.psm1 missed=0 covered=112
KEY .claude/lib/orchestrator-state|OrchestratorStateModelReceipts.psm1 missed=0 covered=91
KEY .claude/lib/orchestrator-state|OrchestratorStateReceipts.psm1 missed=0 covered=117
KEY .claude/lib/orchestrator-state|OrchestratorStateRemediationAccounting.psm1 missed=0 covered=100
KEY .claude/lib/orchestrator-state|OrchestratorStateRoutingContract.psm1 missed=1 covered=110
KEY .claude/lib/orchestrator-state|OrchestratorStateRoutingMatrix.psm1 missed=0 covered=74
KEY .claude/lib/orchestrator-state|OrchestratorStateUnconditional.psm1 missed=0 covered=29
KEY .claude/lib/parallel-drift|Invoke-ParallelDriftDetection.ps1 missed=5 covered=91
KEY .claude/lib/parallel-drift|ParallelDrift.psm1 missed=0 covered=123
KEY .claude/lib/parallel-drift|ParallelDriftHalt.psm1 missed=0 covered=67
KEY .claude/lib/project-file-merge|ProjectFileMerge.psm1 missed=0 covered=124
KEY .claude/lib/project-file-merge|ProjectFileMergeGrammar.psm1 missed=1 covered=121
KEY .claude/lib/project-file-merge|Resolve-MergeableConflict.ps1 missed=9 covered=56
KEY .claude/lib/worktree-resolution|EpicScopeReadiness.psm1 missed=2 covered=47
KEY .claude/lib/worktree-resolution|EpicScopeResolution.psm1 missed=8 covered=104
KEY .claude/lib/worktree-resolution|WorktreeItemResolution.psm1 missed=1 covered=105
KEY .claude/lib/worktree-resolution|WorktreeResolution.psm1 missed=2 covered=142
KEY .claude/lib/worktree-resolution|WorktreeRunResolution.psm1 missed=0 covered=149
KEY .claude/lib/worktree-resolution|WorktreeTargetResolution.psm1 missed=0 covered=104
KEY .codex/hooks|check-powershell-test-purity.ps1 missed=0 covered=62
KEY .codex/hooks|check-python-test-purity.ps1 missed=0 covered=67
KEY .codex/hooks|codex-pretooluse-file-mapping.ps1 missed=0 covered=101
KEY .codex/hooks|enforce-batch-budget-route.ps1 missed=2 covered=32
KEY .codex/hooks|enforce-checkpoint-monotonic.ps1 missed=1 covered=103
KEY .codex/hooks|enforce-completion-consistency.ps1 missed=0 covered=136
KEY .codex/hooks|enforce-completion-helpers.ps1 missed=9 covered=34
KEY .codex/hooks|enforce-epic-child-worktree-binding.ps1 missed=7 covered=153
KEY .codex/hooks|enforce-epic-merge-gate.ps1 missed=1 covered=150
KEY .codex/hooks|enforce-epic-planning-only.ps1 missed=10 covered=153
KEY .codex/hooks|enforce-epic-worktree-removal-gate.ps1 missed=1 covered=67
KEY .codex/hooks|enforce-evidence-locations.ps1 missed=0 covered=41
KEY .codex/hooks|enforce-orchestration-preimplementation-gate-epic-resolution.ps1 missed=11 covered=136
KEY .codex/hooks|enforce-orchestration-preimplementation-gate-epic-scope.ps1 missed=0 covered=44
KEY .codex/hooks|enforce-orchestration-preimplementation-gate-helpers.ps1 missed=3 covered=169
KEY .codex/hooks|enforce-orchestration-preimplementation-gate-modes.ps1 missed=2 covered=130
KEY .codex/hooks|enforce-orchestration-preimplementation-gate.ps1 missed=0 covered=164
KEY .codex/hooks|enforce-powershell-batch-budget.ps1 missed=1 covered=98
KEY .codex/hooks|enforce-promotion-mcp-only.ps1 missed=0 covered=65
KEY .codex/hooks|enforce-python-batch-budget.ps1 missed=1 covered=98
KEY .codex/hooks|hook-command-invocation.ps1 missed=3 covered=121
KEY .codex/hooks|hook-command-scanner.ps1 missed=0 covered=183
KEY .codex/hooks|record-subagent-routing-attestation.ps1 missed=89 covered=103
KEY .codex/hooks|validate-bash.ps1 missed=0 covered=75
KEY .codex/scripts|Resolve-CodexDeployment.ps1 missed=0 covered=31
KEY .codex/scripts|Resolve-CodexTopology.ps1 missed=0 covered=39
KEY .codex/scripts|codex-routing-cli-common.ps1 missed=0 covered=113
KEY scripts/dev-tools|Invoke-FullRelease.ps1 missed=9 covered=95
KEY scripts/dev-tools|Invoke-FullReleaseFlow.ps1 missed=7 covered=115
KEY scripts/dev-tools|Invoke-MarketplacePublish.ps1 missed=6 covered=56
KEY scripts/dev-tools|Invoke-ReleaseReconciliation.ps1 missed=3 covered=24
KEY scripts/dev-tools|Invoke-ReleaseTagPush.ps1 missed=2 covered=75
KEY scripts/dev-tools|Invoke-ReleaseVerification.ps1 missed=9 covered=56
KEY scripts/dev-tools|Invoke-ReleaseVerificationHelpers.ps1 missed=0 covered=29
KEY scripts/dev-tools|new-claude-worktree-session.ps1 missed=29 covered=46
KEY scripts/powershell/PoshQC|PoshQC.ScanConfig.psm1 missed=2 covered=44
KEY scripts/powershell/PoshQC|PoshQC.Testing.psm1 missed=0 covered=202
KEY scripts/powershell|Publish-DrmCopilotExtension.ps1 missed=7 covered=109
```
