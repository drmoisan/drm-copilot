# Remediation Cycle 1 Mirror Baseline ([P0-T12])

Timestamp: 2026-09-25T21-20
Command: sh <SCRATCHPAD>/rem1/runout.sh hashes  (fresh PowerShell 7 process: Get-FileHash -Algorithm SHA256 and git hash-object for the four helpers copies and the two EpicScopeResolution.psm1 copies)
EXIT_CODE: 0
Output Summary: Six 64-hexadecimal SHA-256 hashes. Helpers set: all four 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77. Module set: both 7d5d603e61480732326c05bca7848f765c33e98e5a5265e917ec28f91cd80a61.

## Hashes

```
## helpers set
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | SHA256 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | git hash-object ebb3a95392b8b8eb02e2d692804de55ac40503f5
- .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | SHA256 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | git hash-object ebb3a95392b8b8eb02e2d692804de55ac40503f5
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | SHA256 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | git hash-object ebb3a95392b8b8eb02e2d692804de55ac40503f5
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | SHA256 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | git hash-object ebb3a95392b8b8eb02e2d692804de55ac40503f5
SHA256 equal within set: True
git hash-object equal within set: True
## module set
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | SHA256 7d5d603e61480732326c05bca7848f765c33e98e5a5265e917ec28f91cd80a61 | git hash-object 2bdcadee2697a19d96a028b744aaa89ebaff92ab
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/EpicScopeResolution.psm1 | SHA256 7d5d603e61480732326c05bca7848f765c33e98e5a5265e917ec28f91cd80a61 | git hash-object 2bdcadee2697a19d96a028b744aaa89ebaff92ab
SHA256 equal within set: True
git hash-object equal within set: True
PROCESS_EXIT_CODE: 0
```
