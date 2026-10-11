# Full Pester Baseline with Coverage ([P0-T16])

Timestamp: 2026-10-09T22-11
Command: sh <SCRATCHPAD>/r.sh rpester -CovList <SCRATCHPAD>/wfiles.txt (Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1; then R-JUNIT over artifacts/pester/pester-junit.xml and R-COV over artifacts/pester/powershell-coverage.xml for every W-FILES path)
EXIT_CODE: 0
Output Summary: Tests Passed: 8420, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0; JUnit root tests=8430 failures=0 errors=0; 80 COVERAGE lines, each with SOURCEFILE_MATCHES: 1; files below 85.00 on the baseline: .claude/hooks/validate-feature-review-coverage.ps1 (49.52), .claude/hooks/validate-pr-author-output.ps1 (84.85), .codex/hooks/codex-epic-child-launch-attestation.ps1 (77.27), .codex/hooks/enforce-codex-model-routing.ps1 (56.94), .codex/hooks/enforce-epic-root-invocation.ps1 (40.00), .codex/hooks/enforce-epic-wave-barrier.ps1 (65.41), .codex/hooks/validate-codex-subagent-routing.ps1 (32.26), .codex/hooks/validate-feature-review-coverage.ps1 (7.30).

JUNIT_LAST_WRITE: 2026-10-09T22-20-37 (at or after Timestamp)
COVERAGE_LAST_WRITE: 2026-10-09T22-19-14 (at or after Timestamp)
Console line: Tests Passed: 8420, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
JUnit root: tests=8430 failures=0 errors=0
Failing testcases: none

Note: the console line was read from the captured console output (<SCRATCHPAD>/rpester-console.txt line 812 onward, ANSI sequences removed); the CONSOLE line inside the block below is empty because the first capture pattern did not account for the leading ANSI sequence.

Output (packages and per-file coverage):

```text
RUN_START: 2026-10-09T22-11-29
CONSOLE: 
JUNIT_LAST_WRITE: 2026-10-09T22-20-37
COVERAGE_LAST_WRITE: 2026-10-09T22-19-14
JUNIT_ROOT: tests=8430 failures=0 errors=0
FAILING_TESTCASES: none
PACKAGES:
  <WORKSPACE_ROOT>/.claude/hooks
  <WORKSPACE_ROOT>/.claude/lib/blast-radius
  <WORKSPACE_ROOT>/.claude/lib/ci-gate
  <WORKSPACE_ROOT>/.claude/lib/cleanup-manifest
  <WORKSPACE_ROOT>/.claude/lib/codex-routing
  <WORKSPACE_ROOT>/.claude/lib/discovery-validation
  <WORKSPACE_ROOT>/.claude/lib/hook-payload
  <WORKSPACE_ROOT>/.claude/lib/mermaid
  <WORKSPACE_ROOT>/.claude/lib/model-routing
  <WORKSPACE_ROOT>/.claude/lib/orchestrator-state
  <WORKSPACE_ROOT>/.claude/lib/parallel-drift
  <WORKSPACE_ROOT>/.claude/lib/project-file-merge
  <WORKSPACE_ROOT>/.claude/lib/requirements
  <WORKSPACE_ROOT>/.claude/lib/worktree-resolution
  <WORKSPACE_ROOT>/.codex/hooks
  <WORKSPACE_ROOT>/.codex/scripts
  <WORKSPACE_ROOT>/scripts/dev-tools
  <WORKSPACE_ROOT>/scripts/powershell
  <WORKSPACE_ROOT>/scripts/powershell/PoshQC
COVERAGE: .claude/hooks/check-powershell-test-purity.ps1 | 92.73 | covered=51 | missed=4 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/check-python-test-purity.ps1 | 93.33 | covered=56 | missed=4 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-checkpoint-monotonic.ps1 | 95.74 | covered=90 | missed=4 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-completion-consistency.ps1 | 93.62 | covered=132 | missed=9 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-discovery-artifact-gate.ps1 | 95.16 | covered=59 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-epic-invocation-origin.ps1 | 89.55 | covered=60 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 90.00 | covered=45 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-epic-merge-gate.ps1 | 96.15 | covered=125 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-epic-wave-barrier.ps1 | 96.70 | covered=88 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 96.49 | covered=55 | missed=2 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 96.43 | covered=108 | missed=4 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-evidence-locations.ps1 | 90.00 | covered=36 | missed=4 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-feature-folder-order.ps1 | 91.67 | covered=55 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-mermaid-validation.ps1 | 92.41 | covered=73 | missed=6 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-model-routing-receipt.ps1 | 95.52 | covered=64 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.72 | covered=77 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 97.81 | covered=134 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 96.75 | covered=149 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-parallel-abandon-gate.ps1 | 93.59 | covered=73 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 96.10 | covered=74 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-parallel-drift-gate.ps1 | 98.23 | covered=111 | missed=2 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 92.66 | covered=101 | missed=8 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-powershell-batch-budget.ps1 | 95.45 | covered=126 | missed=6 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 97.30 | covered=108 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 93.55 | covered=29 | missed=2 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-pr-author-skill.ps1 | 91.84 | covered=45 | missed=4 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 94.92 | covered=56 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-prd-feature-before-planner.ps1 | 96.77 | covered=90 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-promotion-mcp-only.ps1 | 93.33 | covered=56 | missed=4 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/enforce-python-batch-budget.ps1 | 95.45 | covered=126 | missed=6 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/hook-command-invocation.ps1 | 100.00 | covered=147 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/hook-command-scanner.ps1 | 100.00 | covered=149 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-bash.ps1 | 94.62 | covered=88 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-discovery-artifact-gate.ps1 | 91.80 | covered=56 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | 49.52 | covered=104 | missed=106 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-orchestrator-output.ps1 | 94.62 | covered=123 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-planner-output.ps1 | 96.28 | covered=181 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-pr-author-output.ps1 | 84.85 | covered=28 | missed=5 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/hooks/validate-prd-feature-output.ps1 | 93.75 | covered=45 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/mermaid/MermaidLineScanner.psm1 | 100.00 | covered=164 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/mermaid/MermaidValidation.psm1 | 98.67 | covered=148 | missed=2 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 100.00 | covered=97 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | 99.00 | covered=99 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | 100.00 | covered=112 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | 100.00 | covered=91 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | 100.00 | covered=117 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1 | 100.00 | covered=100 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | 99.10 | covered=110 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1 | 100.00 | covered=74 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 100.00 | covered=29 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 92.86 | covered=104 | missed=8 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 98.53 | covered=134 | missed=2 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 100.00 | covered=149 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 100.00 | covered=104 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/check-powershell-test-purity.ps1 | 100.00 | covered=62 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/check-python-test-purity.ps1 | 100.00 | covered=67 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 77.27 | covered=51 | missed=15 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 99.04 | covered=103 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-codex-model-routing.ps1 | 56.94 | covered=41 | missed=31 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-completion-consistency.ps1 | 100.00 | covered=148 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.62 | covered=153 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.68 | covered=149 | missed=2 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.71 | covered=156 | missed=7 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-root-invocation.ps1 | 40.00 | covered=20 | missed=30 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-wave-barrier.ps1 | 65.41 | covered=87 | missed=46 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.61 | covered=71 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-evidence-locations.ps1 | 100.00 | covered=41 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 100.00 | covered=60 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 97.78 | covered=132 | missed=3 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=165 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-powershell-batch-budget.ps1 | 98.99 | covered=98 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-promotion-mcp-only.ps1 | 100.00 | covered=65 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/enforce-python-batch-budget.ps1 | 98.99 | covered=98 | missed=1 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-command-invocation.ps1 | 100.00 | covered=147 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/hook-command-scanner.ps1 | 100.00 | covered=149 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=75 | missed=0 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-codex-subagent-routing.ps1 | 32.26 | covered=20 | missed=42 | SOURCEFILE_MATCHES: 1
COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | 7.30 | covered=10 | missed=127 | SOURCEFILE_MATCHES: 1
```
