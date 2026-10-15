# Final hash-object groups (issue #732)

Timestamp: 2026-10-09T04-58
Task: [P7-T17]
Command: git hash-object <four helpers copies>; git hash-object <four targets copies> (literal paths below)
EXIT_CODE: 0

```text
$ git hash-object .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
6064dfb283fffdef435c4f8f61c7e1bcbb418c36
6064dfb283fffdef435c4f8f61c7e1bcbb418c36
6064dfb283fffdef435c4f8f61c7e1bcbb418c36
6064dfb283fffdef435c4f8f61c7e1bcbb418c36
$ git hash-object .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
2d617a94d5e29387f6b98a9770f247b8a1991bbc
2d617a94d5e29387f6b98a9770f247b8a1991bbc
2d617a94d5e29387f6b98a9770f247b8a1991bbc
2d617a94d5e29387f6b98a9770f247b8a1991bbc
```

HELPERS_GROUP_IDENTICAL: True (6064dfb283fffdef435c4f8f61c7e1bcbb418c36)
TARGETS_GROUP_IDENTICAL: True (2d617a94d5e29387f6b98a9770f247b8a1991bbc)

The targets ID differs from the [P4-T6] record (544b46c5...) because the [P5-T6] fix (AllowEmptyString on Token) and the pass-1 loop fix (rename to Get-OrchestrationTargetResult) changed the canonical file after [P4-T6]; each change was followed by R-MIRROR (mirror log).

Output Summary: PASS. Each group of four object IDs is identical (helpers 6064dfb2, targets 2d617a94); both commands exited 0.
