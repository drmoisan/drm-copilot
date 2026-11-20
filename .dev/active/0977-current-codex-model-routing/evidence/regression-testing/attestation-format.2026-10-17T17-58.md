Timestamp: 2026-10-17T17:58:42.365015+00:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root . -ScanFolders @(".codex/hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib/codex-routing", "tests/scripts/claude-lib/orchestrator-state")
EXIT_CODE: 0
Output Summary:

Already formatted: .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\epic-provenance.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\feature-review-coverage-floor-parity.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\feature-review-coverage-thresholds.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\hook-docs-only-diff.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1
Formatted: .\tests\scripts\codex-hooks\subagent-attestation-command.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\subagent-attestation-persistence.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-format.log
