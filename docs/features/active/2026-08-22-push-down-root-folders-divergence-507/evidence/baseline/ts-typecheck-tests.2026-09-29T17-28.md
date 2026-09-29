# Baseline Test-Code Type Check (P0-T19)

Timestamp: 2026-09-29T17-28
Command: npx tsc -p tsconfig.jest.json --noEmit (working directory: extensions/drm-copilot)
EXIT_CODE: 2
ExpectedExitCode: 2

Output Summary:
- Exit code 2 (pre-existing errors; no change has been made yet).
- Count of `error TS` lines: 353
- Erroring file count: 72
- Erroring files (sorted, unique):
  src/lib/codex-native-converter/index.ts
  src/lib/codex-native-converter/models.ts
  test/codex-native-converter-handlers.test.ts
  test/codex-worktree-session-command.test.ts
  test/extension.collect-commit-context.integration.test.ts
  test/extension.collect-pr-context.test.ts
  test/extension.collect-pr-context-gh-resolution.test.ts
  test/extension.discovery-commands.test.ts
  test/extension.integration.test.ts
  test/extension.new-active-feature-folder.test.ts
  test/extension.new-active-feature-folder-inprocess.test.ts
  test/extension.new-potential-bug-entry-inprocess.test.ts
  test/extension.potential-to-issue.test.ts
  test/extension.resolve-atomic-plan-prompt.test.ts
  test/extension.resolve-hard-lock-prompt.test.ts
  test/extension.resolve-policy-audit-template.test.ts
  test/extension.run-poshqc-commands.test.ts
  test/extension.run-poshqc-suite.test.ts
  test/extension.test.ts
  test/extension.workflow-commands.test.ts
  test/extension-command-helpers.test.ts
  test/extension-test-harness.ts
  test/lib/codex-native-converter/models.test.ts
  test/lib/codex-native-converter/parser.test.ts
  test/lib/collect-commit-context.run-git.test.ts
  test/lib/collect-commit-context.test.ts
  test/lib/collect-commit-context.test-helpers.ts
  test/lib/executable-resolver.test.ts
  test/lib/file-system.test.ts
  test/lib/json-config.test.ts
  test/lib/markdown-label-formatter.test.ts
  test/lib/new-active-feature-folder/models.test.ts
  test/lib/new-potential-bug-entry.test.ts
  test/lib/new-potential-bug-entry-service-call.test.ts
  test/lib/pr-context/gh-client-core.test.ts
  test/lib/push-down/claude-config-carriage.test.ts
  test/lib/push-down/claude-pack-selection.test.ts
  test/lib/push-down/filesystem-adapter.test.ts
  test/lib/resolve/file-prompt-core.test.ts
  test/lib/resolve/file-prompt-variables.test.ts
  test/lib/resolve/hard-lock-prompt.test.ts
  test/lib/resolve/resolve-prompts-service-call.test.ts
  test/lib/validate/build-validate-orchestration-service-call-input.test.ts
  test/lib/validate/epic-orchestrator-state-core.test.ts
  test/lib/validate/epic-orchestrator-state-launch-binding.test.ts
  test/lib/validate/epic-planner-state-launch-binding.test.ts
  test/lib/validate/evidence-locations.test.ts
  test/lib/validate/json-validator.test.ts
  test/lib/validate/orchestration-handoff-authority-service.test.ts
  test/lib/validate/orchestration-handoff-contract.test.ts
  test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts
  test/lib/validate/orchestration-handoff-materializer-production.test.ts
  test/lib/validate/parallel-kickoff-template-seam.test.ts
  test/lib/validate/plan-gate-discrimination-cov.test.ts
  test/lib/validate/validate-orchestration-service-call.test.ts
  test/mcp-handlers/orchestration-handoff-handlers.test.ts
  test/mcp-provider.test.ts
  test/mcp-server.test.ts
  test/mcp-server-test-service.ts
  test/poshqc-folder-picker.test.ts
  test/push-down-claude-handler.test.ts
  test/remove-worktrees.test.ts
  test/remove-worktrees-runner.test.ts
  test/repo-automation-command-registration-admin.test.ts
  test/repo-automation-dispatch.test.ts
  test/repo-automation-dispatch-pr-context-verification.test.ts
  test/repo-automation-execute-discovery.test.ts
  test/repo-automation-hard-lock-prompt.test.ts
  test/repo-automation-orchestration-validation.test.ts
  test/repo-automation-service.resolve-atomic-plan-prompt.test.ts
  test/subagent-tree-command.test.ts
- `test/lib/push-down/claude-routing-merge-parity.test.ts` does not yet exist and is not in the set.
