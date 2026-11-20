# Remediation Baseline — Existing-Behavior Search

Timestamp: 2026-11-03T19-32
Command: git grep -l -F -e 'Test-OrchestrationCleanupContextAllowed' -e 'Implementation operations require artifacts/orchestration/orchestrator-state.json' -e 'preimplementation-gate-cleanup' -- tests/ ; git grep -l -F -e 'Get-PrAuthorPreflightExemption' -e 'CLEANUP_EXEMPTION_' -e 'Invoke-PrAuthorDocsOnlyGitExe' -- tests/
EXIT_CODE: 0

## R1-2 set

- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
- tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1

## R1-1 set

- tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1

Output Summary: R1-2 set is 8 files and R1-1 set is 5 files, each exactly the set the plan states; no unlisted file was found.
