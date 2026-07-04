# Phase 0 — Instructions Read Evidence

Timestamp: 2026-06-27T23-40

Policy Order: copilot-instructions -> general-code-change -> general-unit-test -> powershell-code-change -> powershell-unit-test -> mirrored .claude rules

## Files Read (in required order)

1. `.github/copilot-instructions.md` — repository tone and communication policy
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules (500-line cap, toolchain loop, I/O boundaries, no temp files in tests)
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (independence, isolation, determinism, no temp files, no external deps)
4. `.github/instructions/powershell-code-change.instructions.md` — PowerShell code change rules (PoshQC MCP toolchain, advanced functions, <=500 lines)
5. `.github/instructions/powershell-unit-test.instructions.md` — PowerShell unit test rules (Pester 5.x, mock wrapper seams, no external deps)
6. `.claude/rules/general-code-change.md` — mirrored cross-language code change policy
7. `.claude/rules/general-unit-test.md` — mirrored cross-language unit test policy (>= 85% line, >= 75% branch coverage)
8. `.claude/rules/powershell.md` — mirrored PowerShell toolchain and design-seam standards

## Supporting research read

- `docs/features/active/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261/research/pr-author-receipt-and-governance-inventory.2026-06-27.md` — file-by-file inventory, seams, mirror map (ground truth)
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` — bundle-parity contract test logic
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` — confirms it calls `Get-PrAuthorSkillBlockDecision` directly (unaffected by receipt change)

## Key constraints confirmed

- Every `.ps1` must remain <= 500 lines (production, test, reusable scripts).
- Tests must not create temp files or touch disk/network; use injectable seams only.
- PowerShell toolchain order: format -> analyze -> test, restart on any change.
- Coverage thresholds: line >= 85%, branch >= 75%.
- Bundle mirrors must be byte-identical (.claude) and body-identical below the converted-hook header (.codex).
