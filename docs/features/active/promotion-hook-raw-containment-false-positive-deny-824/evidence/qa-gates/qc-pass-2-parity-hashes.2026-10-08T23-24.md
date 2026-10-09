# QC Pass 2: Parity Hashes ([P10-T14])

Timestamp: 2026-10-08T23-24
Command: sh <SCRATCHPAD>/s-hash.sh final
EXIT_CODE: 0
Output Summary:
16 groups, every group `DISTINCT=1` (SHA-256 via Get-FileHash).

```
GROUP shared-hook-command-scanner.ps1 DISTINCT=1                 4e1796edc01ebc272ef3f95d007c767beb892c714c25055267bae73a1c362460 (4 copies)
GROUP shared-hook-command-heredoc.ps1 DISTINCT=1                 1f6cc67221337f9cdc977bc9122ecb6b68c16e97633ac8d735f694125489c8d2 (4 copies)
GROUP shared-hook-command-payload.ps1 DISTINCT=1                 8c833c86cc2e5f742e69935576257d71e876380ce1fba1d3da291134a2a439ee (4 copies)
GROUP shared-hook-command-payload-powershell.ps1 DISTINCT=1      8d8ee3b39903eb09ffe91b51027f7f64126222e39e2cbea0478d3579cbeb95b5 (4 copies)
GROUP shared-hook-command-invocation.ps1 DISTINCT=1              a7ec95f8ea830740b40e0ab7c2556187cb1f32154ed12e9bd7bc00eb2d37665e (4 copies)
GROUP shared-hook-command-invocation-operands.ps1 DISTINCT=1     2cb871fa89cc79f41c92a0288f794e568cab5c5e6bd0361ec7226df78d91071b (4 copies)
GROUP claude-enforce-promotion-mcp-only.ps1 DISTINCT=1           c32f477de78bb65ef4b4f4085a79093a587d817207b0af49fa88135c7a5c6bd1 (2 copies)
GROUP claude-enforce-epic-worktree-removal-gate.ps1 DISTINCT=1   27b3737e6b666e44193cbfe1dfdd273a1998678c6a1b2ba7febbea3a99259f26 (2 copies)
GROUP claude-enforce-parallel-worktree-removal-gate.ps1 DISTINCT=1 9a52432215e6d4b2b7dba9549811a18afdced9ec57e7102b4247856e101ec531 (2 copies)
GROUP claude-enforce-pr-author-skill-helpers.ps1 DISTINCT=1      c9961fe247c9e9742971d1b26622321974073458b625dcc9b02151cff53d61d3 (2 copies)
GROUP claude-enforce-pr-author-command-allowlist.ps1 DISTINCT=1  952e15c2f42efb29de5fda1a047f9e6e81dbff1c6e4416dd5a4d811150ab59d3 (2 copies)
GROUP claude-pr-author.md DISTINCT=1                             d3ace9ae001849aaeccf37f96f1d2f4e55513ea9df9a88423c652ecb4ecaa819 (2 copies)
GROUP claude-SKILL.md DISTINCT=1                                 92628f1c7d1fe05a162464334cec0f9d10374d814bb0f40e31c60c9a17bdb6c5 (2 copies)
GROUP codex-enforce-promotion-mcp-only.ps1 DISTINCT=1            3bbe00e628b689ca3ae1221a204723bc0cb72f0c87d4482448e82513f2f09a18 (2 copies)
GROUP codex-enforce-epic-worktree-removal-gate.ps1 DISTINCT=1    30ae9f8b9b4d82dad889d589ae3b143d5d92b0a31c85a9a350eac55e7c0dd3ea (2 copies)
```

Shared-module groups compare `.claude/hooks/`, `.codex/hooks/`, and both bundled copies under `extensions/drm-copilot/resources/`; Claude-only and Codex-only groups compare each file with its bundled mirror. No write-set file with a bundle copy changed during QC pass 2, so no rule-6 mirror run was required before this task.
