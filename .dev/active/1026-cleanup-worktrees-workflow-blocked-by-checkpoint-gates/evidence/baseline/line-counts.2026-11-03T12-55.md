# Baseline Line Counts and Merge Base (Issue #1026)

Timestamp: 2026-11-03T12-55
Command: git -C <item worktree> merge-base origin/main HEAD; @(Get-Content -LiteralPath <path>).Count for each file (run through SCRATCH/issue-1026-ps.sh with SCRATCH/issue-1026-linecount.txt)
EXIT_CODE: 0
Output Summary: MERGE_BASE = 715241396b557ce198e44f5c4b606fbcd9082c3c (merge base of origin/main and HEAD after fetching origin main). Codex gate 491 (limit 491) and pr-author helpers 499 (limit 499): both preconditions hold.

MERGE_BASE: 715241396b557ce198e44f5c4b606fbcd9082c3c

| Physical lines | File |
|---|---|
| 471 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` |
| 491 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` |
| 499 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` |
| 224 | `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` |
| 352 | `.claude/hooks/enforce-model-routing-receipt.ps1` |
| 506 | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` |
| 191 | `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` |

Method: `@(Get-Content -LiteralPath <path>).Count`, which counts the final line whether or not it ends with a terminator (the Claude gate has no final terminator, so `wc -l` reports 470 for it).
