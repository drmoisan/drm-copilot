# PoshQC Formatter, Final (P7-T1, AC-18)

Timestamp: 2026-10-09T04-30
Command: git status --porcelain; sha256sum <five P7-T1 files>; mcp__drm-copilot__run_poshqc_format scan_folders [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"]; git status --porcelain; sha256sum <five P7-T1 files>
EXIT_CODE: 0
Output Summary: ok:true. Porcelain before and after: empty (identical). The SHA256 listings before and after are identical for all five files, so the formatter rewrote nothing.

## Note on the hash route

The plan computes the listing with `Get-FileHash -Algorithm SHA256` in the PowerShell tool; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). `sha256sum` computes the same SHA256 digest.

## Hash listing (before = after)

```text
825b45308e0be1e216854771f61d9e71ebb30e455fdc295309fbea07be5025b6 .claude/lib/blast-radius/BlastRadiusExtraction.psm1
14127748b7a8ce8e2a6d1784cf7d38ac39d5fbacdac7047523fc5f3563e54494 .claude/lib/blast-radius/BlastRadiusTokenShape.psm1
f34ead3a9f6117461c5c460b606afe75a9915e479d6be28e8ee6040d6ecbdad8 tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
7198be2960690921af26713aa0c99ff6e599669b934e076d1868f40a8b1e8ffb tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
0483fbe6601a6bf9ce062172f37bbc9045d99a6535aeb2ad48f42c5cd13dc692 tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
```
