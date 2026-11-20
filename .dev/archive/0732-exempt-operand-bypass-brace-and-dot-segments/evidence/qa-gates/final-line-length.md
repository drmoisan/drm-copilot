# Final line length (R-LINELEN; issue #732)

Timestamp: 2026-10-09T04-56
Task: [P7-T12]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p7-t11-t17.sh linelen (R-LINELEN over the four helpers copies against BASE_SHA)
EXIT_CODE: 0

## Output

```text
LONGEST_ADDED: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 31
BACKSLASH_TEST_LENGTH: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 107
LONGEST_ADDED: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 31
BACKSLASH_TEST_LENGTH: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 107
LONGEST_ADDED: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 31
BACKSLASH_TEST_LENGTH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 107
LONGEST_ADDED: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 31
BACKSLASH_TEST_LENGTH: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 107
```

Output Summary: OVER_120 lines 0; BACKSLASH_TEST_LENGTH values 107,107,107,107.

