# r2 P8-T15 line counts (AC-28)

Timestamp: 2026-10-03T16-40
Command: step script SCRATCH/steps/r2-p8-t15.ps1 (SCOPE-ARRAY; Get-Content line count of every SCOPE-PATHS file; HOOKS-OVER-500 over .codex/hooks and .claude/hooks; VERDICT)
EXIT_CODE: 0
Output Summary: SCOPE-ARRAY-COUNT=31; every count is at most 500; CLAUDE-RAW 300 (at most 320) equals CODEX-RAW 300; CLAUDE-INV 494 equals CODEX-INV 494; HOOKS-OVER-500=0.

```text
.claude/hooks/hook-command-raw-invocation.ps1 300
.codex/hooks/hook-command-raw-invocation.ps1 300
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-raw-invocation.ps1 300
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-raw-invocation.ps1 300
.claude/hooks/hook-command-invocation.ps1 494
.codex/hooks/hook-command-invocation.ps1 494
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 494
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 494
.claude/hooks/enforce-epic-worktree-removal-gate.ps1 464
.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 481
.codex/hooks/enforce-epic-worktree-removal-gate.ps1 184
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 464
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 481
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1 184
.codex/codex-web-setup.sh 405
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh 405
tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 313
tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 299
tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 347
tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 284
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 332
tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 312
tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 303
tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1 191
tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1 191
tests/shell/test_codex_web_setup_codex_copy.bats 187
tests/fixtures/codex_web_setup/populated-packages/packages/placeholder.txt 1
.github/workflows/_shell-coverage.yml 97
scripts/dev-tools/KcovFunctionCoverageGate.ps1 247
tests/scripts/dev-tools/KcovFunctionCoverageGate.Tests.ps1 188
tests/scripts/workflows/ShellCoverageWorkflow.Tests.ps1 133
HOOKS-OVER-500=0
```
