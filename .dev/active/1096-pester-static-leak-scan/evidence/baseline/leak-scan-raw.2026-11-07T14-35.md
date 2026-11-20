# Baseline: First Repository Leak Scan (allowlist absent)

Timestamp: 2026-11-07T14-35
Command: sh SCRATCH/issue-1096-scan-raw.sh (pwsh imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCLeakScan -Root <item worktree> with a collecting -Logger; config/poshqc-leak-allowlist.json absent)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The scan threw as expected. 547 .ps1 files scanned under the configured test folders (tests/scripts; tests/powershell does not exist and was skipped with a warning). 71 FINDING rows and 0 PARSE-ERROR rows. Count per kind: env 3, global-function 1, global-variable 67. LASTEXITCODE rows (global-variable): 67.

## Rows

FINDING: tests/scripts/claude-hooks/discovery-entrypoints.Tests.ps1 | 44 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1 | 82 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1 | 65 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.HelperImportFailure.Tests.ps1 | 60 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | 174 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1 | 59 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1 | 61 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1 | 62 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1 | 63 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1 | 64 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | 118 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | 73 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 469 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 | 122 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | 44 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1 | 44 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1 | 29 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | 41 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-orchestrator-output.Envelope.Tests.ps1 | 54 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1 | 54 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1 | 118 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | 62 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | 32 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | 100 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | 38 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | 160 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1 | 46 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1 | 44 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | 38 | global-variable | LASTEXITCODE
FINDING: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | 193 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 61 | env | $name
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 88 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 105 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 121 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 137 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 233 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 250 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 263 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 279 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/discovery-entrypoints.Tests.ps1 | 44 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 27 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 26 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 31 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 104 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 27 | global-variable | LASTEXITCODE
FINDING: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 35 | global-variable | LASTEXITCODE
FINDING: tests/scripts/copilot-hooks/discovery-entrypoints.Tests.ps1 | 46 | global-variable | LASTEXITCODE
FINDING: tests/scripts/copilot-hooks/discovery-pre-tool.Tests.ps1 | 104 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | 42 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | 61 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | 74 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/bootstrap-host.Tests.ps1 | 86 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | 319 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 | 325 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | 201 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | 239 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | 250 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 95 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 113 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 128 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 216 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 218 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 293 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 308 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 310 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 | 44 | env | [string]$key
FINDING: tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 | 46 | env | $key
FINDING: tests/scripts/dev-tools/verify-host.Tests.ps1 | 57 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/verify-host.Tests.ps1 | 74 | global-variable | LASTEXITCODE
FINDING: tests/scripts/dev-tools/verify-host.Tests.ps1 | 89 | global-variable | LASTEXITCODE
FINDING: tests/scripts/powershell/Support/TestHelpers.ps1 | 1 | global-function | Import-ScriptFunction
