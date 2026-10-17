# Pester QC Baseline (pre-merge, 25 files)

Timestamp: 2026-10-08T22-10
Command: sh <SCRATCHPAD>/s-qc-pester.sh baseline
EXIT_CODE: 0
Output Summary: 25 FILE_RESULT lines, no QC_MISSING_FILE line, no FAILED_TEST line.

```text
QC_SET_SIZE: 25
PESTER_TOTAL: 1072
PESTER_PASSED: 1072
PESTER_FAILED: 0
PESTER_SKIPPED: 0
PESTER_FAILED_BLOCKS: 0
PESTER_FAILED_CONTAINERS: 0
FILE_RESULT tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 passed=43 failed=0
FILE_RESULT tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 passed=23 failed=0
FILE_RESULT tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 passed=26 failed=0
FILE_RESULT tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 passed=114 failed=0
FILE_RESULT tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 passed=184 failed=0
FILE_RESULT tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 passed=70 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 passed=68 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 passed=40 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 passed=40 failed=0
FILE_RESULT tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 passed=40 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 passed=24 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 passed=38 failed=0
FILE_RESULT tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 passed=22 failed=0
FILE_RESULT tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 passed=44 failed=0
FILE_RESULT tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 passed=39 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 passed=50 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 passed=5 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 passed=49 failed=0
FILE_RESULT tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 passed=3 failed=0
FILE_RESULT tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 passed=11 failed=0
FILE_RESULT tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 passed=5 failed=0
FILE_RESULT tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 passed=20 failed=0
FILE_RESULT tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 passed=10 failed=0
FILE_RESULT tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 passed=77 failed=0
FILE_RESULT tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 passed=27 failed=0
QC_PESTER_EXIT_CODE: 0
```
