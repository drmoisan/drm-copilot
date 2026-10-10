# Conversion-Phase Verification ([P8-T9])

Timestamp: 2026-10-10T00-33
Command: R-SCOPED over the 25 files listed below (completeness test, exemption guard test, Claude and Codex behaviour suites, special cases, both proof files, every section 2.6.6 test file, every W-690-TESTS file, and the #737 isolation guard tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1)
EXIT_CODE: 0
Output Summary: PassedCount 1421, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; one CONTAINER: line per file (25). A first run failed one row: the Claude proof file's baseline mock interception probe, contaminated by duplicate module instances left by the C4 rows of the special-cases suite. The C4 cleanup is recorded in deviations.md under [P8-T9]. The output below is the final run.

```text
FILE: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
FILE: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1
FILE: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
FILE: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
FILE: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1
FILE: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
FILE: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1
FILE: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
FILE: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1
FILE: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
FILE-COUNT: 25

Starting discovery in 25 files.
Discovery found 1421 tests in 27.76s.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1 12.75s (11.85s|568ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\hook-import-failure-exemptions.Guard.Tests.ps1 7.12s (7.06s|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 7.79s (7.03s|172ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 3.74s (3.33s|91ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 4.58s (1.41s|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.24s (2.15s|54ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 345ms (307ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 293ms (218ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 357ms (255ms|64ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 308ms (228ms|52ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 285ms (203ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 213ms (146ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 204ms (141ms|42ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 207ms (156ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 474ms (429ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 582ms (539ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 481ms (419ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 364ms (308ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 244ms (205ms|24ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 222ms (184ms|26ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 2.46s (2.4s|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 281ms (231ms|36ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 191ms (149ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 215ms (173ms|28ms)
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 90.58s (67.35s|224ms)
Tests completed in 136.55s
Tests Passed: 1421, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 1421
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | result=Passed | passed=598 | failed=0
CONTAINER: tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | result=Passed | passed=139 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | result=Passed | passed=75 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Passed | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | result=Passed | passed=5 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | result=Passed | passed=18 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | result=Passed | passed=45 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | result=Passed | passed=26 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | result=Passed | passed=14 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | result=Passed | passed=13 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | result=Passed | passed=20 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | result=Passed | passed=10 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | result=Passed | passed=8 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | result=Passed | passed=7 | failed=0
CONTAINER: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | result=Passed | passed=302 | failed=0
PASSED: S1: repository claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S1: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 carries the bootstrap try and the tail check after the dot-source early return
PASSED: S2: repository claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try
PASSED: S2: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 guards every direct edge in its own single-statement try
PASSED: S2: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 guards every direct edge in its own single-statement try
PASSED: S3: repository claude PreToolUse .claude/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S3: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 uses -ErrorAction Stop on every guarded Import-Module
PASSED: S4: repository claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S4: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 leaves no transitive edge uncovered or non-terminating
PASSED: S5: repository claude PreToolUse .claude/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 pre-loads every runtime edge under a guard
PASSED: S5: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 pre-loads every runtime edge under a guard
PASSED: S5: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 pre-loads every runtime edge under a guard
PASSED: S6: repository claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function
PASSED: S6: repository codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-planner-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-prd-feature-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-pr-author-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror claude SubagentStop .claude/hooks/validate-orchestrator-output.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/validate-bash.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/check-python-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/check-powershell-test-purity.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-evidence-locations.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex PreToolUse .codex/hooks/enforce-completion-consistency.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 returns the dependency decision first in its decision function
PASSED: S6: mirror codex SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 returns the dependency decision first in its decision function
PASSED: S7: discovers hooks from .claude/settings.json and .codex/config.toml
PASSED: S8: names every exemption with its justification
PASSED: F1: reports an unguarded direct edge in a synthetic hook
PASSED: F2: reports a try body that holds more than the import statement
PASSED: F3: reports a guarded Import-Module without -ErrorAction Stop
PASSED: F4: reports a hook without the bootstrap try
PASSED: F5: reports a missing tail check or one placed before the dot-source early return
PASSED: F6: reports a runtime import that is not pre-loaded under a guard
PASSED: F7: reports a transitive Import-Module that is neither terminating nor covered
PASSED: F8: does not report the named exemptions
PASSED: G1: repository finds every named handler exemption at its handler site
PASSED: G1: mirror finds every named handler exemption at its handler site
PASSED: G2: repository reports no scoped import-failure handler outside the named-exemption list
PASSED: G2: mirror reports no scoped import-failure handler outside the named-exemption list
PASSED: G3: repository finds the deny code of every named handler exemption in its deny path
PASSED: G3: mirror finds the deny code of every named handler exemption in its deny path
PASSED: GF1: reports a named exemption whose handler site no longer exists
PASSED: GF2: reports a scoped import-failure handler that is not in the named-exemption list
PASSED: GF3: reports a named exemption whose deny code no longer appears in its deny path
PASSED: GF4: does not report a conforming named exemption
PASSED: baseline mock interception probe
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill.epic-base-branch.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming enforce-pr-author-skill-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-authorization.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 blocks naming enforce-epic-merge-gate-resolution.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming enforce-epic-worktree-removal-gate-resolution.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming CleanupWorktreeManifest.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/check-python-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 blocks naming DiscoveryValidation.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeTargetResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 blocks naming enforce-prd-feature-before-planner-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 blocks naming EpicScopeResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 blocks naming enforce-parallel-cohort-barrier-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming HookPayload.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 blocks naming enforce-parallel-drift-gate-helpers.ps1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 blocks naming DiscoveryValidation.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming validate-orchestrator-output-resolution.ps1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeItemResolution.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming WorktreeRunResolution.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateEpicWaveBarrier.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateCompletion.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorStateUnconditional.psm1 when that direct edge fails
PASSED: B1: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 blocks naming OrchestratorState.psm1 when that direct edge fails
PASSED: B2: PreToolUse .claude/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-planner-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-pr-author-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-pr-author-skill.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-abandon-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-feature-folder-order.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-mermaid-validation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-prd-feature-before-planner.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-model-routing-receipt.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-epic-invocation-origin.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-cohort-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .claude/hooks/enforce-parallel-drift-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-discovery-artifact-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-planner-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-prd-feature-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-pr-author-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .claude/hooks/validate-orchestrator-output.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B4: has a reason-prefix entry for every discovered Claude hook and no other
PASSED: baseline mock interception probe
PASSED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/validate-bash.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-helpers.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-modes.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming enforce-orchestration-preimplementation-gate-epic-scope.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-scanner.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 blocks naming hook-command-invocation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 blocks naming codex-agent-profile-attestation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 blocks naming codex-epic-child-launch-attestation.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/check-python-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 blocks naming enforce-batch-budget-route.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-checkpoint-monotonic.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming codex-pretooluse-file-mapping.ps1 when that direct edge fails
PASSED: B1: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 blocks naming enforce-completion-helpers.ps1 when that direct edge fails
PASSED: B1: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 blocks naming codex-authority-store.ps1 when that direct edge fails
PASSED: B2: PreToolUse .codex/hooks/validate-bash.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/check-python-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B2: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 sets the bootstrap flag without a function call when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/validate-bash.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-promotion-mcp-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-merge-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-worktree-removal-gate.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-root-invocation.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-codex-model-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-planning-only.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-wave-barrier.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-epic-child-worktree-binding.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/check-python-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-python-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/check-powershell-test-purity.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-powershell-batch-budget.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-evidence-locations.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-checkpoint-monotonic.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: PreToolUse .codex/hooks/enforce-completion-consistency.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .codex/hooks/validate-codex-subagent-routing.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B3: SubagentStop .codex/hooks/validate-feature-review-coverage.ps1 exits 2 with the bootstrap reason when hook-dependency-guard.ps1 fails to load
PASSED: B4: has a reason-prefix entry for every discovered Codex hook and no other
PASSED: X1: .codex/hooks/enforce-epic-wave-barrier.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure
PASSED: X1: .codex/hooks/enforce-epic-child-worktree-binding.ps1 skips the absent epic-child-launch-contract.ps1 without a dependency failure
PASSED: X2: .codex/hooks/enforce-epic-wave-barrier.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load
PASSED: X2: .codex/hooks/enforce-epic-child-worktree-binding.ps1 denies naming epic-child-launch-contract.ps1 when the present file fails to load
PASSED: X3: validate-bash denies a dependency failure with HOOK_DEPENDENCY_LOAD_FAILED:
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
PASSED: baseline mock interception probe
PASSED: H1 control: enforce-feature-folder-order.ps1 allows a full-bug plan write whose prerequisites exist when feature-folder-resolution.ps1 loads
PASSED: H1 enforce-feature-folder-order.ps1 denies that plan write with FEATURE_FOLDER_ORDER_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H1 enforce-feature-folder-order.ps1 calls no resolver function for a non-plan write when feature-folder-resolution.ps1 loads
PASSED: H1 enforce-feature-folder-order.ps1 returns the same allow for a non-plan write whether or not feature-folder-resolution.ps1 loads
PASSED: H2 control: claude preimplementation gate allows a ready epic delegation when feature-folder-resolution.ps1 loads
PASSED: H2 control: claude preimplementation gate allows a ready parallel delegation when feature-folder-resolution.ps1 loads
PASSED: H2 claude preimplementation gate denies that epic delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load
PASSED: H2 claude preimplementation gate denies that parallel delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load
PASSED: H3 control: enforce-prd-feature-before-planner.ps1 allows a planner delegation whose prerequisites exist when feature-folder-resolution.ps1 loads
PASSED: H3 enforce-prd-feature-before-planner.ps1 denies that delegation with PRD_FEATURE_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H4 control: enforce-epic-wave-barrier.ps1 allows the W10 delegation when feature-folder-resolution.ps1 loads
PASSED: H4 enforce-epic-wave-barrier.ps1 denies that delegation with EPIC_WAVE_BARRIER_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H5 control: enforce-parallel-drift-gate.ps1 allows the D1 delegation when feature-folder-resolution.ps1 loads
PASSED: H5 enforce-parallel-drift-gate.ps1 denies that delegation with PARALLEL_DRIFT_GATE_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H6 control: enforce-parallel-cohort-barrier.ps1 allows the C1 delegation when feature-folder-resolution.ps1 loads
PASSED: H6 enforce-parallel-cohort-barrier.ps1 denies that delegation with PARALLEL_COHORT_BARRIER_BLOCKED: when feature-folder-resolution.ps1 fails to load
PASSED: H7 validate-orchestrator-output.ps1 exits 2 naming WorktreeRunResolution.psm1 when that resolver import fails
PASSED: H8 validate-orchestrator-output.ps1 exits 2 naming OrchestratorStateEpicWaveBarrier.psm1 when the Layer 2 import fails
PASSED: baseline mock interception probe
PASSED: H2 control: codex preimplementation gate allows a ready epic delegation when feature-folder-resolution.ps1 loads
PASSED: H2 control: codex preimplementation gate allows a ready parallel delegation when feature-folder-resolution.ps1 loads
PASSED: H2 codex preimplementation gate denies that epic delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load
PASSED: H2 codex preimplementation gate denies that parallel delegation naming feature-folder-resolution-import when feature-folder-resolution.ps1 fails to load
PASSED: baseline mock interception probe
PASSED: W1: allows the target folder cited alone when its dependencies are merged
PASSED: W2a: allows the target folder cited together with a research artifact
PASSED: W2b: allows the target folder cited together with an evidence artifact
PASSED: W3a: allows a research artifact cited alone
PASSED: W3b: allows an evidence artifact cited alone
PASSED: W4a: prunes the cited upstream dependency and allows when it is merged
PASSED: W4b: evaluates the target, not the upstream, and denies when the dependency is pr_open
PASSED: W5a: denies as ambiguous and names both candidates
PASSED: W5b: denies as ambiguous for the reversed order with the longer slug first
PASSED: W6a: denies a bare docs/features/active/ token as naming no folder
PASSED: W6b: denies a docs/features/active/. token as naming no folder
PASSED: W7a: evaluates feature 621 and allows while 507 and 508 are merged
PASSED: W7b: evaluates feature 621 and denies when 508 is pr_open
PASSED: W8a: matches a minimal integer depends_on edge and allows when the dependency is merged
PASSED: W8b: matches a minimal integer depends_on edge and denies when the dependency is pr_open
PASSED: W9: denies naming feature-folder-resolution.ps1 and guards the dot-source
PASSED: W10: matches records recorded with active/ and docs/features/active/ prefixes
PASSED: denies an empty payload as an envelope anomaly (fail closed)
PASSED: allows when file_path is missing
PASSED: allows when file_path is not a plan.md path
PASSED: allows for plan.md outside docs/features
PASSED: denies unparseable JSON instead of throwing (exit 1 is non-blocking)
PASSED: denies the legacy flat root shape as a missing-tool_input anomaly
PASSED: allows when all three sibling files exist
PASSED: denies when issue.md is missing
PASSED: denies when spec.md is missing
PASSED: denies when user-story.md is missing
PASSED: deny reason names all missing files when multiple are absent
PASSED: serializes the deny decision into the PreToolUse hookSpecificOutput envelope
PASSED: normalizes backslashes in the file_path
PASSED: Get-FeatureFolderMissingFile defaults to the full-feature prerequisite set when no required set is supplied
PASSED: handles archive feature folders too
PASSED: returns exit code 0 and emits a deny when every transport is empty
PASSED: returns exit code 0 and emits an allow decision JSON for an out-of-scope path
PASSED: returns exit code 0 and emits a deny decision JSON when prerequisites are missing
PASSED: real Test-Path wrapper returns $false for a nonexistent path
PASSED: recognizes a canonical active plan.md path
PASSED: recognizes a canonical archive plan.md path
PASSED: rejects non-plan files
PASSED: rejects paths outside docs/features
PASSED: F1: recognizes a timestamped plan file in an active feature folder
PASSED: F2: recognizes a timestamped plan file in an archive feature folder
PASSED: F3: denies a timestamped plan write when the prerequisite documents are missing
PASSED: F4: rejects a plan file whose timestamp carries no time component
PASSED: F5: rejects a planning document whose name only starts with plan
PASSED: F6: rejects a plan file nested below the feature folder
PASSED: F7: allows a minor-audit plan write when only issue.md exists
PASSED: F8: allows a full-bug plan write when issue.md and spec.md exist
PASSED: F9: allows a full-feature plan write when all three documents exist
PASSED: F10: denies a legacy full plan write without user-story.md as full-feature
PASSED: F11: enforces the full-feature set when the marker is missing
PASSED: F12: enforces the full-feature set when issue.md is empty
PASSED: F13: enforces the full-feature set when the marker is malformed
PASSED: F14: enforces the full-feature set when the marker value is unrecognized
PASSED: F15: enforces the full-feature set when issue.md cannot be read
PASSED: F16: names the plan file, the work mode, and the missing file for a full-bug folder without spec.md
PASSED: F17: denies a minor-audit plan write when issue.md is missing
PASSED: F18: denies plan writes but allows other paths when the shared resolver failed to load
PASSED: F19: allows a literal plan.md write in a full-bug folder with issue.md and spec.md
PASSED: E1: returns the issue.md content when the file is present
PASSED: E2: returns $null without reading when issue.md is absent
PASSED: E3: returns $null when reading issue.md throws
PASSED: baseline mock interception probe
PASSED: M1: allows the target folder cited alone at decision level
PASSED: M2a: allows the target folder cited together with a research artifact
PASSED: M2b: allows the target folder cited together with an evidence artifact
PASSED: M3a: allows a research artifact cited alone
PASSED: M3b: allows an evidence artifact cited alone
PASSED: M4e: prunes a cited epic dependency and reports no readiness failure
PASSED: M4p: reports target-ambiguous for a parallel target cited with another item and no issue number
PASSED: M4q: resolves a parallel target cited with another item through the declared issue number
PASSED: M5: denies with target-ambiguous naming both candidates
PASSED: M5r: denies with target-ambiguous for the reversed order with the longer slug first
PASSED: M6a: falls back to the keyed issue number when the bare token yields no candidate
PASSED: M6b: reports target-record when the token yields no candidate and no issue number is cited
PASSED: M7: resolves feature 621 and does not fail the merge_status predicate
PASSED: M7d: allows the 621 launch at decision level
PASSED: M8: resolves the record by the keyed issue number when the folder record was renamed
PASSED: M9: returns no target folder and a feature-folder-resolution-import readiness failure
PASSED: M10p: denies a parallel delegation as target-ambiguous when only a bare #302 sibling reference is cited
PASSED: M10e: denies an epic delegation as target-ambiguous when only a bare #302 sibling reference is cited
PASSED: M11p: selects the terminal parallel target through the keyed issue number despite a bare #302 sibling reference
PASSED: M11e: selects the terminal epic target through the keyed issue number despite a bare #302 sibling reference
PASSED: M12a: returns no keyed issue number when only a bare hash form is present
PASSED: M12b: returns the keyed issue number and ignores a bare hash form
PASSED: M12c: keeps the bare hash form as the default issue-number source
PASSED: M8h: allows a zero-candidate delegation through the bare hash D3 fallback
PASSED: M8m: denies a zero-candidate delegation with no issue number as target-record
PASSED: baseline mock interception probe
PASSED: M1: allows the target folder cited alone at decision level
PASSED: M2a: allows the target folder cited together with a research artifact
PASSED: M2b: allows the target folder cited together with an evidence artifact
PASSED: M3a: allows a research artifact cited alone
PASSED: M3b: allows an evidence artifact cited alone
PASSED: M4e: prunes a cited epic dependency and reports no readiness failure
PASSED: M4p: reports target-ambiguous for a parallel target cited with another item and no issue number
PASSED: M4q: resolves a parallel target cited with another item through the declared issue number
PASSED: M5: denies with target-ambiguous naming both candidates
PASSED: M5r: denies with target-ambiguous for the reversed order with the longer slug first
PASSED: M6a: falls back to the keyed issue number when the bare token yields no candidate
PASSED: M6b: reports target-record when the token yields no candidate and no issue number is cited
PASSED: M7: resolves feature 621 and does not fail the merge_status predicate
PASSED: M7d: allows the 621 launch at decision level
PASSED: M8: resolves the record by the keyed issue number when the folder record was renamed
PASSED: M9: returns no target folder and a feature-folder-resolution-import readiness failure
PASSED: M10p: denies a parallel delegation as target-ambiguous when only a bare #302 sibling reference is cited
PASSED: M10e: denies an epic delegation as target-ambiguous when only a bare #302 sibling reference is cited
PASSED: M11p: selects the terminal parallel target through the keyed issue number despite a bare #302 sibling reference
PASSED: M11e: selects the terminal epic target through the keyed issue number despite a bare #302 sibling reference
PASSED: M12a: returns no keyed issue number when only a bare hash form is present
PASSED: M12b: returns the keyed issue number and ignores a bare hash form
PASSED: M12c: keeps the bare hash form as the default issue-number source
PASSED: M8h: allows a zero-candidate delegation through the bare hash D3 fallback
PASSED: M8m: denies a zero-candidate delegation with no issue number as target-record
PASSED: baseline mock interception probe
PASSED: C1: allows the target folder cited alone
PASSED: C2a: allows the target folder cited together with a research artifact
PASSED: C2b: allows the target folder cited together with an evidence artifact
PASSED: C3a: allows a research artifact cited alone
PASSED: C3b: allows an evidence artifact cited alone
PASSED: C4a: denies as ambiguous and names both folders when no canonical issue-number line is present
PASSED: C4b: allows when the canonical issue-number line selects the target
PASSED: C5a: denies as ambiguous and names both candidates
PASSED: C5b: denies as ambiguous for the reversed order with the longer slug first
PASSED: C6a: denies a bare docs/features/active/ token as naming no folder
PASSED: C6b: denies a docs/features/active/. token as naming no folder
PASSED: C7: denies naming feature-folder-resolution.ps1 and guards the dot-source
PASSED: C8: matches records recorded with active/ and docs/features/active/ prefixes
PASSED: baseline mock interception probe
PASSED: D1: allows the target folder cited alone when it has no drift event
PASSED: D2a: allows the target folder cited together with a research artifact
PASSED: D2b: allows the target folder cited together with an evidence artifact
PASSED: D3a: allows a research artifact cited alone
PASSED: D3b: allows an evidence artifact cited alone
PASSED: D4a: denies as ambiguous and names both folders when no canonical issue-number line is present
PASSED: D4b: allows when the canonical issue-number line selects the target
PASSED: D5a: denies as ambiguous and names both candidates
PASSED: D5b: denies as ambiguous for the reversed order with the longer slug first
PASSED: D6a: denies a bare docs/features/active/ token as naming no folder
PASSED: D6b: denies a docs/features/active/. token as naming no folder
PASSED: D7: denies naming feature-folder-resolution.ps1 and guards the dot-source
PASSED: D8: probes the target folder, not the nested evidence kind, for an unresolved drift event
PASSED: baseline mock interception probe
PASSED: K1: returns the recorded feature-folder and reads the exact path once with -Raw
PASSED: K2: returns $null when the checkpoint has no feature-folder field
PASSED: K3: returns $null when the feature-folder field is empty
PASSED: K4: returns $null when the checkpoint is not valid JSON
PASSED: K5: returns $null when reading the checkpoint throws
PASSED: K6: returns $null without reading when the checkpoint is absent
PASSED: P1: returns the parsed mode for a recognized marker
PASSED: P2: returns $null when the marker is missing
PASSED: P3: returns $null when the shared resolver failed to load
PASSED: P4: delegates to Resolve-FeatureFolderWorkMode with an empty -UnresolvedMode
PASSED: baseline mock interception probe
PASSED: H1 surfaces one unmerged dependency as an unwrapped line followed by the halt instruction
PASSED: H2 surfaces two violated edges in depends_on order before the halt instruction
PASSED: H3 instructs the agent to report and halt without suggesting an edit to history
PASSED: H4 passes a clean epic checkpoint whose dependency merged before the dependent started
PASSED: H5 does not run the port for the parallel checkpoint type
PASSED: H6 does not run the port for the orchestrator-state checkpoint type
PASSED: H7 keeps the routing block and does not run the port when the routing dispatch fails
PASSED: H8 blocks as unevaluable for an array issue_num and reports no violation line
PASSED: H9 blocks as unevaluable for a NaN literal that ConvertFrom-Json accepts
PASSED: H10 blocks as unevaluable for a value nested in 70 arrays
PASSED: H11 blocks as unevaluable when the port fails with any other error
PASSED: H12 blocks the epic leg naming OrchestratorStateEpicWaveBarrier.psm1 when its import failed
PASSED: baseline mock interception probe
PASSED: S2-1 accepts the canonical epic leaf and returns the canonical path
PASSED: S2-2 accepts a dot-prefixed backslash spelling of the epic leaf
PASSED: S2-3 rejects the item leaf for the epic kind and names the canonical epic path
PASSED: S2-4 rejects a rooted -CheckpointPath before any resolver call or read
PASSED: S2-5 rejects a parent-escaping -CheckpointPath before any resolver call or read
PASSED: S2-6 passes the cross-check for every existing SubagentStop registration unchanged
PASSED: S2-7 reports an unsupported artifact type as NoTarget with the shared reason code
PASSED: S2-8 joins a dot-prefixed runbook path beneath the resolved root
PASSED: S2-9 returns a rooted runbook path unchanged
PASSED: S2-10 collects only distinct epic-route branch values in discovery order
PASSED: S2-11 reports the runbook seam result from the filesystem
PASSED: S2-12 blocks naming WorktreeRunResolution.psm1 when the resolver import failed, before any read
PASSED: baseline mock interception probe
PASSED: authorizes a standalone merge from the item worktree checkpoint
PASSED: does not authorize from a session-root copy of another worktree's checkpoint
PASSED: denies an unresolvable item target with the no-target code
PASSED: denies an ambiguous item target with the ambiguity code
PASSED: observes module-scoped WorktreeItemResolution mocks
PASSED: does not resolve an item target for a bare merge command
PASSED: denies a merge when no checkpoint records the pull request number
PASSED: denies a merge whose pull request number differs from pr_gate
PASSED: re-checks the binding on the checkpoint the gate reads
PASSED: denies naming WorktreeItemResolution.psm1 when its import failed
PASSED: returns true for a bare command
PASSED: returns false for a null checkpoint
PASSED: returns the pr_gate equality result
PASSED: returns the pr_gate equality result
PASSED: returns true for a matching positive-integer standalone entry
PASSED: returns false for a standalone pr_number that is string
PASSED: returns false for a standalone pr_number that is zero
PASSED: returns false for a standalone pr_number that is fractional
PASSED: returns false when neither field records the number
PASSED: baseline mock interception probe
PASSED: M1 allows an epic integration merge whose ready checkpoint is only in another worktree
PASSED: M2 allows a parallel item merge whose ci_green checkpoint is only in another worktree
PASSED: M3 denies a child merge whose pr_gate.pr_number differs from the command PR number
PASSED: M4 allows a child merge whose pr_gate.pr_number equals the command PR number
PASSED: M5 denies a child merge whose checkpoint records neither pr_gate nor a standalone record for the number
PASSED: M6 reads every checkpoint beneath the session worktree for a bare command without resolving
PASSED: M7 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither run branch resolves and no record authorizes
PASSED: M8 denies with TARGET_WORKTREE_AMBIGUOUS when the epic branch is ambiguous
PASSED: M9 allows a standalone-authorized merge when neither run branch resolves
PASSED: M10 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: baseline mock interception probe
PASSED: V1 allows a removal authorized by an epic record held only in another worktree
PASSED: V2 allows a removal authorized by a parallel record held only in another worktree
PASSED: V3 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither kind resolves and the manifest declines
PASSED: V4 denies an ambiguous epic target before consulting the manifest
PASSED: V5 allows a manifest-authorized removal when neither kind resolves
PASSED: V6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: baseline mock interception probe
PASSED: W1 admits the reproduction at the barrier by reading the epic checkpoint under the other worktree
PASSED: W2 denies the reproduction with TARGET_WORKTREE_NOT_DERIVABLE when no worktree holds the epic checkpoint
PASSED: W3 denies an ambiguous target with TARGET_WORKTREE_AMBIGUOUS
PASSED: W4 keeps the dependency deny text for a resolved target whose dependency is not merged
PASSED: W5 decides a session-root checkpoint exactly as before the change
PASSED: W6 reads the worktree that has the integration branch checked out over a stale session-root copy
PASSED: W7 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: W8 allows a non-orchestrator delegation without resolving
PASSED: W9 allows an orchestrator delegation without the epic marker without resolving
PASSED: baseline mock interception probe
PASSED: O1 admits a Write inside another worktree whose checkpoint is ready, reading that checkpoint
PASSED: O2 denies a Write inside another worktree whose checkpoint is not ready
PASSED: O3 denies a Write inside another worktree whose checkpoint is absent
PASSED: O6 decides a Write inside the session worktree exactly as the injected checkpoint
PASSED: O9 denies a Write whose target is ambiguous, naming the reason code and the detail
PASSED: O4 reads the checkpoint of the worktree a git -C selector names
PASSED: O5 reads the session worktree checkpoint for a command with no selector
PASSED: O7 denies naming WorktreeRunResolution.psm1 when that import failed, and the entry point exits 0
PASSED: O8 denies naming WorktreeItemResolution.psm1 when that import failed
PASSED: O10 passes no relative checkpoint literal to Test-Path or Get-Content, and every read seam takes a mandatory Path
PASSED: baseline mock interception probe
PASSED: Y1 allows a removal authorized by a parallel record held only in another worktree
PASSED: Y2 allows a removal authorized by an epic record held only in another worktree
PASSED: Y3 denies with TARGET_WORKTREE_NOT_DERIVABLE when neither kind resolves and the manifest declines
PASSED: Y4 denies an ambiguous parallel target before consulting the manifest
PASSED: Y5 allows a manifest-authorized removal when neither kind resolves
PASSED: Y6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: Y7 emits a single leading token when both run kinds are unresolved
PASSED: baseline mock interception probe
PASSED: C1 admits a clear barrier by reading the parallel checkpoint under the other worktree
PASSED: C2 denies a kickoff without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE
PASSED: C3 denies two matching parallel checkpoints with TARGET_WORKTREE_AMBIGUOUS
PASSED: C4 decides a session-root checkpoint exactly as before the change
PASSED: C5 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
PASSED: C6 allows a non-orchestrator delegation without resolving
PASSED: C7 allows an orchestrator delegation without the parallel marker without resolving
PASSED: baseline mock interception probe
PASSED: D1 allows an undrifted item by reading the parallel checkpoint under the other worktree
PASSED: D2 denies a review delegation without parallel_slug with TARGET_WORKTREE_NOT_DERIVABLE
PASSED: D3 denies an ambiguous target
PASSED: D4 allows a non-feature-review delegation without resolving
PASSED: D5 allows a feature-review delegation without the parallel marker without resolving
PASSED: D6 denies naming WorktreeRunResolution.psm1 when the import failed, and the entry point exits 0
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
PASSED: AC-4 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 complies with the baseline isolation form for every closure seam
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
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED: AC-4 tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 complies with the baseline isolation form for every closure seam
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
PASSED: AC-6 tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 calls the interception probe from inside an It
PASSED: AC-6 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 calls the interception probe from inside an It
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
