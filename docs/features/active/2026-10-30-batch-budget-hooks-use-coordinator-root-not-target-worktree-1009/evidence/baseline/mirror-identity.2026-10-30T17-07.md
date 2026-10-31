# Mirror Identity at Branch Base (R8, issue #1009)

Timestamp: 2026-10-30T17-07
Command: sha256sum over each canonical file and its bundled copy (bundle roots `extensions/drm-copilot/resources/claude-customizations` = CB, `extensions/drm-copilot/resources/codex-and-agents-customizations` = XB)
EXIT_CODE: 0
Output Summary: every pair is byte-identical; no pre-existing mirror defect.

| Canonical | Bundle | SHA-256 (both) | Equal |
|---|---|---|---|
| `.claude/hooks/enforce-python-batch-budget.ps1` | CB `.claude/hooks/enforce-python-batch-budget.ps1` | cb048a124b0a7b26b060e47e251ce0e43a7766ab4c1dba0c8fc8901afe1696d8 | yes |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | CB `.claude/hooks/enforce-powershell-batch-budget.ps1` | c7d494269b6e60197ed8050396556e45a8c875d778331525601f2fbb0ae4520e | yes |
| `.codex/hooks/enforce-python-batch-budget.ps1` | XB `.codex/hooks/enforce-python-batch-budget.ps1` | b418246e69480033dc77b5117e39e4c471f8114a9ed50fe3d26993a1d67b9ed5 | yes |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | XB `.codex/hooks/enforce-powershell-batch-budget.ps1` | 26ab2689aa78272b263d00560cc0232cc2f1891f80d7025e0c93b6c047d5a2a4 | yes |
| `.claude/hooks/enforce-batch-budget-route.ps1` | `.codex/hooks/`, CB `.claude/hooks/`, XB `.codex/hooks/` copies (four copies) | 21849d79ead2e319d881f94139a8d47aa312c7c3eb504f6274323f5d1f6bbb69 | yes (all four) |
| `.claude/rules/orchestrator-state.md` | CB `.claude/rules/orchestrator-state.md` | dd5d012d8de65bc95ddfc7f0dee7d4b9dbec7355987bb07cfdbc8d5e2d455728 | yes |
