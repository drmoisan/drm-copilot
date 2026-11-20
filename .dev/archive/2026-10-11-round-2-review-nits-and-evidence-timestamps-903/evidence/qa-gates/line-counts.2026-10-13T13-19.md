# AC-43 Line Counts (P12-T16)

Timestamp: 2026-10-13T13-19
Command: git fetch origin main; git diff --name-only origin/main...HEAD -- '*.py' '*.ts' '*.ps1' '*.psm1' | xargs wc -l; git status --porcelain
EXIT_CODE: 0
HEAD: 92e85dd747c6cbabda41de18c0637c3139cb0414

The diff pathspec selects every `.py`, `.ts`, `.ps1`, and `.psm1` file changed on the branch; it includes the 10 Python and TypeScript files of Phases 2-5 (8 Python, 2 TypeScript) and every `.ps1`/`.psm1` path. `git status --porcelain` (run at 2026-10-13T13-18) listed only `<FEATURE>` paths, so no edited code file is uncommitted.

## Explicitly required counts

| File | Lines |
|---|---|
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 496 |
| tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | 496 |
| tests/scripts/dev_tools/test_workflow_npm_token_guard.py | 388 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 424 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 424 |

## Full wc -l output (worktree prefix removed)

```
   488 .claude/hooks/enforce-completion-consistency.ps1
   267 .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
   496 .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
   424 .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
   373 .claude/hooks/feature-folder-resolution.ps1
   269 .claude/lib/blast-radius/BlastRadiusTokenShape.psm1
   210 .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
   493 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
   424 .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
   373 .codex/hooks/feature-folder-resolution.ps1
   488 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1
   267 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
   496 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
   424 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
   373 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-folder-resolution.ps1
   269 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
   210 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
   493 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
   424 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
   373 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-folder-resolution.ps1
    70 extensions/drm-copilot/test/subagent-tree-command-test-support.ts
   221 extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts
   225 scripts/dev_tools/_blast_radius_token_shapes.py
   179 tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1
   267 tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
   496 tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
   108 tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1
   335 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
   288 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
   362 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
   293 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
    64 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
   386 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
   286 tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1
   359 tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
   150 tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1
    81 tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1
   205 tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
   268 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
   290 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
   286 tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
   178 tests/scripts/dev_tools/npm_token_guard_test_support.py
   224 tests/scripts/dev_tools/test_blast_radius_token_shapes.py
   458 tests/scripts/dev_tools/test_check_quality_tiers.py
   426 tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py
   212 tests/scripts/dev_tools/test_evidence_timestamp_contracts.py
   223 tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py
   388 tests/scripts/dev_tools/test_workflow_npm_token_guard.py
   270 tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
 15232 total
```

Output Summary: PASS. 49 code files counted; the largest is 496 lines (`-modes.ps1` Claude copy and `EpicStateIsolation.Helpers.ps1`). Every file is at most 500 lines. Porcelain lists no path outside `<FEATURE>`.
