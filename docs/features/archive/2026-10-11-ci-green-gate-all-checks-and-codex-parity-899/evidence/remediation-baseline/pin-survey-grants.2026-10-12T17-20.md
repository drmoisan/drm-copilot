# Pin Survey 3: Parser Grant Presence (P0-T8, remediation cycle 2)

Timestamp: 2026-10-12T17-58

Command: git grep -n -F -e "Invoke-CiGateParser.ps1*" -- .claude .codex .agents .github extensions

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:
- First command: exit 1, no output. The parser grant is absent from every persona surface.
- Second command: `git ls-files -- ".claude/*parallel-orchestrator*" ".codex/*parallel-orchestrator*" ".agents/*parallel-orchestrator*" ".github/*parallel-orchestrator*" "extensions/drm-copilot/resources/*parallel-orchestrator*"`. SECOND_COMMAND_EXIT=0. Output (verbatim):

```
.claude/agents/parallel-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
```

- Exactly the two expected lines; no other runtime surface declares a parallel-orchestrator tools list.
