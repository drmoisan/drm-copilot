# Bundled-Mirror Log (issue #673, plan revision 4)

Timestamp: 2026-09-19T17-58

Command: per section, `pwsh -NoProfile -Command "Copy-Item -LiteralPath <source> -Destination <mirror> -Force"` followed by `pwsh -NoProfile -File <SCRATCHPAD>/r3-mirror-sha.ps1` to compute and compare SHA-256 for each pair. Copies are made through a shell rather than a Write or Edit tool, so they consume no PowerShell batch-budget slot and are byte copies.

EXIT_CODE: 0

Output Summary: Two pairs recorded so far, both equal. Every later mirror task appends a section to this file.

---

## `[P2-T5]` — identity-resolution module and the Pester run settings

Commands, with repository-relative paths:

```
Copy-Item -LiteralPath '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1' -Destination 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1' -Force
Copy-Item -LiteralPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -Destination 'extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1' -Force
```

| Source | Source SHA-256 | Mirror | Mirror SHA-256 | Verdict |
| --- | --- | --- | --- | --- |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | `1770818e05dc505f0628314d19c93b6a58463765c588a1e75b2761d7fcd136ab` | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | `1770818e05dc505f0628314d19c93b6a58463765c588a1e75b2761d7fcd136ab` | equal |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `34c0104700bfa36c0abf1f64d865d9c035f677dfc76f2a373f32e16484a391dc` | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `34c0104700bfa36c0abf1f64d865d9c035f677dfc76f2a373f32e16484a391dc` | equal |

ALL_PAIRS_EQUAL: True

Both pairs equal. The run-settings hash differs from its `[P0-T15]` baseline value because `[P2-T4]` added the new module to `CodeCoverage.Path`; the mirror carries the same change, which is what keeps the pair equal.
