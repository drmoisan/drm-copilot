# Remediation Cycle 2 — Mirrored Production Pair Hash Re-Verification

Timestamp: 2026-08-28T02-23
Task: [P3-T12]
Command: `pwsh -NoProfile -Command "<Get-FileHash -Algorithm SHA256 -LiteralPath <path> for each of the eight files of the four mirrored pairs, comparing each pair's two lowercase hashes for equality>"`
EXIT_CODE: 0

Hashes were **recomputed live** against the working-tree files, not copied from a prior artifact.

## The four pair hashes

| # | Pair | Self-hosted copy | Mirror copy | SHA-256 (both) | Verdict |
| --- | --- | --- | --- | --- | --- |
| 1 | **Claude gate hook** | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `0c8c55ce222ee9241b061a2964d5a0bb7154eb57f2b91a9d0f049b4da82b863e` | **MATCH** |
| 2 | **Claude modes sibling** | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `0ffab72ef27b3ae38f60a38dc1ba60a5f974fac91a4fa7d28f5094a790b455a4` | **MATCH** |
| 3 | **Codex gate hook** | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `b978bad8b304b2917afbe524f0043f5018ff0f06c7719a27550c6e888a3b706d` | **MATCH** |
| 4 | **Codex modes sibling** | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `8e1165818ae0ae20b63486d2aa51d98a7875fea9ba7d2f15e0762df850aa4f0a` | **MATCH** |

**Four pair hashes recorded. Each pair's two hashes are equal: 4 of 4 MATCH.**

## Equality against the values recorded in `policy-audit.2026-08-28T00-30.md`

| Pair | Value in `policy-audit.2026-08-28T00-30.md` | Value measured now | Equal |
| --- | --- | --- | --- |
| Claude gate hook | `0c8c55ce222ee9241b061a2964d5a0bb7154eb57f2b91a9d0f049b4da82b863e` | `0c8c55ce222ee9241b061a2964d5a0bb7154eb57f2b91a9d0f049b4da82b863e` | **yes** |
| Claude modes sibling | `0ffab72ef27b3ae38f60a38dc1ba60a5f974fac91a4fa7d28f5094a790b455a4` | `0ffab72ef27b3ae38f60a38dc1ba60a5f974fac91a4fa7d28f5094a790b455a4` | **yes** |
| Codex gate hook | `b978bad8b304b2917afbe524f0043f5018ff0f06c7719a27550c6e888a3b706d` | `b978bad8b304b2917afbe524f0043f5018ff0f06c7719a27550c6e888a3b706d` | **yes** |
| Codex modes sibling | `8e1165818ae0ae20b63486d2aa51d98a7875fea9ba7d2f15e0762df850aa4f0a` | `8e1165818ae0ae20b63486d2aa51d98a7875fea9ba7d2f15e0762df850aa4f0a` | **yes** |

**All four measured hashes equal the values `policy-audit.2026-08-28T00-30.md` recorded, confirming
that this remediation changed no production byte.**

The result is consistent with [P3-T10], whose deduplicated four-listing union over this cycle
contains zero paths under `.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/resources/`.
Two independent methods — a path-membership test over the cycle's change listings, and a content hash
of the files themselves — agree.

Output Summary: Four pair hashes recorded. **4 of 4 pairs MATCH** internally, and **all four equal
the values recorded in `policy-audit.2026-08-28T00-30.md`**. This remediation changed no production
byte. EXIT_CODE 0.
