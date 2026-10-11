# Remediation Cycle 1 Full Pester Coverage Baseline, Control Run C0 ([P0-T7])

Timestamp: 2026-10-10T08-31
Command: <SCRATCHPAD>/r1-wcp.ps1 (W-CHANGED-PROD: git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a together with git status --porcelain, prefixes .claude/hooks/, .claude/lib/, .codex/hooks/, .codex/scripts/); <SCRATCHPAD>/rpester.ps1 (R-PESTER: Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1); <SCRATCHPAD>/rpester.ps1 -SkipRun -CovList <SCRATCHPAD>/r1-wchangedprod.txt -ChangedBase 86e457a003be0c60b65e01156e4cccd6495dfd1a (R-JUNIT root, R-COV, R-CHANGED-LINES); <SCRATCHPAD>/r1-post.ps1 -Label c0 (report copies to <SCRATCHPAD>/r1-c0-coverage.xml and <SCRATCHPAD>/r1-c0-junit.xml; L, S, PRE, POST; floor and no-regression lists; T-SET). All route sh.
EXIT_CODE: 0
Output Summary: `Tests Passed: 9495, Failed: 0, Skipped: 10`; JUnit root tests 9505, failures 0, errors 0. 57 W-CHANGED-PROD files, every COVERAGE row SOURCEFILE_MATCHES: 1. Four Codex files below 85.00 and five Codex files regress, unchanged from the [P11-T3] run. L-COUNT 341 = PRE 238 + S 61 + POST 42 (S contiguous).

Note: the first rpester.ps1 invocation ran R-PESTER to completion (reports written) and then exited 1 in its own post-run R-COV step, because `git` threw inside the same process after the test run; the reporting step was re-run in a fresh process with `-SkipRun` over the same reports (the form used by the main plan's [P10-T3] and [P11-T3] records).

COVERAGE_LAST_WRITE: 2026-10-10T08-44-06
JUNIT_LAST_WRITE: 2026-10-10T08-45-56

Console:

```text
Tests completed in 724.88s
Tests Passed: 9495, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 87.07% / 0%. 25,713 analyzed Commands in 192 Files.
```

Root: tests=9505 failures=0 errors=0

W-CHANGED-PROD-COUNT: 57

BELOW-FLOOR: .codex/hooks/enforce-epic-child-worktree-binding.ps1 (74.70); .codex/hooks/enforce-epic-planning-only.ps1 (82.25); .codex/hooks/hook-dependency-guard.ps1 (57.89); .codex/hooks/validate-bash.ps1 (80.25)

REGRESSION: .codex/hooks/enforce-epic-child-worktree-binding.ps1 (95.62 missed=7 -> 74.70 missed=42); .codex/hooks/enforce-epic-merge-gate.ps1 (98.68 missed=2 -> 98.09 missed=3); .codex/hooks/enforce-epic-planning-only.ps1 (95.71 missed=7 -> 82.25 missed=30); .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 (100.00 missed=0 -> 86.55 missed=23); .codex/hooks/validate-bash.ps1 (100.00 missed=0 -> 80.25 missed=16)

NO-BASELINE-ROW: .claude/hooks/validate-orchestrator-output-resolution.ps1

T-SET:
- .codex/hooks/enforce-epic-child-worktree-binding.ps1
- .codex/hooks/enforce-epic-planning-only.ps1
- .codex/hooks/hook-dependency-guard.ps1
- .codex/hooks/validate-bash.ps1
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
- .codex/hooks/enforce-epic-merge-gate.ps1

L-COUNT: 341
S-COUNT: 61
PRE-COUNT: 238
POST-COUNT: 42

S paths (document order of the C0 JUnit testsuites):

```text
S: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
S: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
S: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
S: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
S: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
S: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
S: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
S: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
S: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
S: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
S: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
S: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
S: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
S: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
S: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
S: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
S: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
S: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
S: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
S: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
S: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
S: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
S: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
S: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
S: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
S: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
S: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
S: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
S: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
S: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
S: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
S: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
S: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
S: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
S: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
S: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
S: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
S: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
S: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
S: tests/scripts/codex-hooks/epic-provenance.Tests.ps1
S: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
S: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
S: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
S: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
S: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
S: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
S: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
S: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
S: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
S: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
S: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
S: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
S: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
```

R-JUNIT, R-COV, and R-CHANGED-LINES output:

```text
JUNIT_LAST_WRITE: 2026-10-10T08-45-56
COVERAGE_LAST_WRITE: 2026-10-10T08-44-06
JUNIT_ROOT: tests=9505 failures=0 errors=0
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
COVERAGE: .claude/hooks/check-powershell-test-purity.ps1 | 93.44 | covered=57 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/check-powershell-test-purity.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/check-python-test-purity.ps1 | 93.94 | covered=62 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/check-python-test-purity.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-checkpoint-monotonic.ps1 | 96.00 | covered=96 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-checkpoint-monotonic.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-completion-consistency.ps1 | 93.84 | covered=137 | missed=9 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-completion-consistency.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/enforce-discovery-artifact-gate.ps1 | 95.65 | covered=66 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-discovery-artifact-gate.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/enforce-epic-invocation-origin.ps1 | 90.41 | covered=66 | missed=7 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-invocation-origin.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 95.24 | covered=40 | missed=2 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | covered=2 | total=2
COVERAGE: .claude/hooks/enforce-epic-merge-gate.ps1 | 99.25 | covered=132 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-merge-gate.ps1 | covered=12 | total=12
COVERAGE: .claude/hooks/enforce-epic-wave-barrier.ps1 | 98.96 | covered=95 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-wave-barrier.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 98.04 | covered=50 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | covered=1 | total=1
COVERAGE: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 96.52 | covered=111 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | covered=11 | total=11
COVERAGE: .claude/hooks/enforce-evidence-locations.ps1 | 91.30 | covered=42 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-evidence-locations.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-feature-folder-order.ps1 | 93.94 | covered=62 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-feature-folder-order.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-mermaid-validation.ps1 | 94.12 | covered=80 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-mermaid-validation.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/enforce-model-routing-receipt.ps1 | 95.89 | covered=70 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-model-routing-receipt.ps1 | covered=9 | total=9
COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.63 | covered=72 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | covered=4 | total=4
COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 96.86 | covered=154 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=12 | total=12
COVERAGE: .claude/hooks/enforce-parallel-abandon-gate.ps1 | 94.05 | covered=79 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-parallel-abandon-gate.ps1 | covered=9 | total=9
COVERAGE: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 98.78 | covered=81 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | covered=10 | total=10
COVERAGE: .claude/hooks/enforce-parallel-drift-gate.ps1 | 99.15 | covered=116 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-parallel-drift-gate.ps1 | covered=10 | total=10
COVERAGE: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 93.64 | covered=103 | missed=7 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | covered=11 | total=11
COVERAGE: .claude/hooks/enforce-powershell-batch-budget.ps1 | 95.65 | covered=132 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-powershell-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/enforce-pr-author-skill.ps1 | 92.98 | covered=53 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-pr-author-skill.ps1 | covered=12 | total=12
COVERAGE: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 96.61 | covered=57 | missed=2 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | covered=1 | total=1
COVERAGE: .claude/hooks/enforce-prd-feature-before-planner.ps1 | 96.97 | covered=96 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-prd-feature-before-planner.ps1 | covered=10 | total=10
COVERAGE: .claude/hooks/enforce-promotion-mcp-only.ps1 | 93.94 | covered=62 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-promotion-mcp-only.ps1 | covered=9 | total=9
COVERAGE: .claude/hooks/enforce-python-batch-budget.ps1 | 95.65 | covered=132 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/enforce-python-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .claude/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/hook-dependency-guard.ps1 | covered=19 | total=19
COVERAGE: .claude/hooks/validate-bash.ps1 | 94.95 | covered=94 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-bash.ps1 | covered=9 | total=9
COVERAGE: .claude/hooks/validate-discovery-artifact-gate.ps1 | 92.65 | covered=63 | missed=5 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-discovery-artifact-gate.ps1 | covered=7 | total=7
COVERAGE: .claude/hooks/validate-feature-review-coverage.ps1 | 97.22 | covered=210 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-feature-review-coverage.ps1 | covered=6 | total=6
COVERAGE: .claude/hooks/validate-orchestrator-output-resolution.ps1 | 98.94 | covered=93 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-orchestrator-output-resolution.ps1 | covered=0 | total=0
COVERAGE: .claude/hooks/validate-orchestrator-output.ps1 | 95.42 | covered=125 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-orchestrator-output.ps1 | covered=15 | total=15
COVERAGE: .claude/hooks/validate-planner-output.ps1 | 97.94 | covered=190 | missed=4 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-planner-output.ps1 | covered=6 | total=6
COVERAGE: .claude/hooks/validate-pr-author-output.ps1 | 100.00 | covered=39 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-pr-author-output.ps1 | covered=6 | total=6
COVERAGE: .claude/hooks/validate-prd-feature-output.ps1 | 98.15 | covered=53 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .claude/hooks/validate-prd-feature-output.ps1 | covered=6 | total=6
COVERAGE: .codex/hooks/check-powershell-test-purity.ps1 | 100.00 | covered=68 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/check-powershell-test-purity.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/check-python-test-purity.ps1 | 100.00 | covered=73 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/check-python-test-purity.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 98.48 | covered=65 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/codex-epic-child-launch-attestation.ps1 | covered=1 | total=1
COVERAGE: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 99.09 | covered=109 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-checkpoint-monotonic.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-codex-model-routing.ps1 | 100.00 | covered=78 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-codex-model-routing.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-completion-consistency.ps1 | 100.00 | covered=153 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-completion-consistency.ps1 | covered=9 | total=9
COVERAGE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 74.70 | covered=124 | missed=42 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.09 | covered=154 | missed=3 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-merge-gate.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-epic-planning-only.ps1 | 82.25 | covered=139 | missed=30 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-planning-only.ps1 | covered=6 | total=6
COVERAGE: .codex/hooks/enforce-epic-root-invocation.ps1 | 100.00 | covered=56 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-root-invocation.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-epic-wave-barrier.ps1 | 95.68 | covered=133 | missed=6 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-wave-barrier.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.72 | covered=77 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-evidence-locations.ps1 | 100.00 | covered=47 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-evidence-locations.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 86.55 | covered=148 | missed=23 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466 | if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('PREIMPLEMENTATION_GATE_BLOCKED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'PREIMPLEMENTATION_GATE_BLOCKED:'
UNCOVERED-CHANGED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:468 | if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }
CHANGED-LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=9 | total=12
COVERAGE: .codex/hooks/enforce-powershell-batch-budget.ps1 | 99.05 | covered=104 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-powershell-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-promotion-mcp-only.ps1 | 100.00 | covered=71 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-promotion-mcp-only.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/enforce-python-batch-budget.ps1 | 99.05 | covered=104 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/enforce-python-batch-budget.ps1 | covered=8 | total=8
COVERAGE: .codex/hooks/hook-dependency-guard.ps1 | 57.89 | covered=11 | missed=8 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:103 | $reason = Get-HookDependencyFailureReason -ReasonPrefix $ReasonPrefix
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:104 | if ($HookEvent -eq 'SubagentStop') {
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:105 | return [pscustomobject]@{ ExitCode = 2; Reason = $reason }
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:107 | return [ordered]@{
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:108 | hookSpecificOutput = [ordered]@{
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:109 | hookEventName            = 'PreToolUse'
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:110 | permissionDecision       = 'deny'
UNCOVERED-CHANGED: .codex/hooks/hook-dependency-guard.ps1:111 | permissionDecisionReason = $reason
CHANGED-LINES: .codex/hooks/hook-dependency-guard.ps1 | covered=11 | total=19
COVERAGE: .codex/hooks/validate-bash.ps1 | 80.25 | covered=65 | missed=16 | SOURCEFILE_MATCHES: 1
UNCOVERED-CHANGED: .codex/hooks/validate-bash.ps1:304 | if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('HOOK_DEPENDENCY_LOAD_FAILED: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }
UNCOVERED-CHANGED: .codex/hooks/validate-bash.ps1:305 | $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'HOOK_DEPENDENCY_LOAD_FAILED:'
UNCOVERED-CHANGED: .codex/hooks/validate-bash.ps1:306 | if ($null -ne $dependencyDecision) { $dependencyDecision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0 }
CHANGED-LINES: .codex/hooks/validate-bash.ps1 | covered=5 | total=8
COVERAGE: .codex/hooks/validate-codex-subagent-routing.ps1 | 100.00 | covered=68 | missed=0 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/validate-codex-subagent-routing.ps1 | covered=7 | total=7
COVERAGE: .codex/hooks/validate-feature-review-coverage.ps1 | 99.29 | covered=140 | missed=1 | SOURCEFILE_MATCHES: 1
CHANGED-LINES: .codex/hooks/validate-feature-review-coverage.ps1 | covered=4 | total=4
```
