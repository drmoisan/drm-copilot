# Final Per-File Line Counts — 500-Line Cap

Timestamp: 2026-09-08T04-19

Task: [P7-T5]

Command:
`wc -l <the ten measured files>`
`grep -c "" <the same ten measured files>`

EXIT_CODE: 0

## Measurement method

Two counts are recorded per file. `wc -l` counts newline-terminated lines and is the measure P0-T4
used, so the before-and-after comparison is like for like. `grep -c ""` counts every line including
a final line that carries no trailing newline, so it is the larger of the two whenever a file ends
without one, and it is the figure the 500-line cap is judged against here. Recording both makes the
one-line difference on the two gate hooks explicit rather than leaving it as an unexplained
discrepancy against P0-T4.

## Measured set

| # | Path | `wc -l` | `grep -c ""` | Cap | Headroom |
| --- | --- | --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 467 | **468** | 500 | 32 |
| 2 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 335 | **336** | 500 | 164 |
| 3 | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | 415 | **415** | 500 | 85 |
| 4 | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 495 | **495** | 500 | **5** |
| 5 | `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 457 | **457** | 500 | 43 |
| 6 | `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` | 152 | **152** | 500 | 348 |
| 7 | `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` | 318 | **318** | 500 | 182 |
| 8 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 467 | **468** | 500 | 32 |
| 9 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 335 | **336** | 500 | 164 |
| 10 | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | 415 | **415** | 500 | 85 |

Every recorded count is at most 500. **The closest file to the cap is
`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` at 495 lines, with 5 lines
of headroom.** The next closest are the epic gate hook and its mirror at 468 lines each, with 32
lines of headroom.

Each mirror in rows 8 through 10 carries the identical count to its source in rows 1 through 3,
which is consistent with the byte-identical mirroring Phase 5 performed.

## P3-T25 split contingency

No split suite was created. The three contingency names reserved by the plan —
`tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrixValues.Tests.ps1`,
`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate-manifest-pins.Tests.ps1`, and
`tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate-manifest-pins.Tests.ps1` — do not
exist in the tree, confirmed by listing `tests/scripts/claude-hooks/`. The measured set above is
therefore complete and no additional path was added to it.

The two `.TriggerScoping.Tests.ps1` suites present in `tests/scripts/claude-hooks/` are issue 545's
merged files. They are tracked, unmodified by this work, and outside the measured set.

## Files this work changed that the cap does not apply to

`.claude/rules/general-code-change.md` exempts Markdown from the 500-line cap, so
`.claude/skills/cleanup-merged-worktrees/SKILL.md` and its bundle mirror are not measured here. The
two `pester.runsettings.psd1` files and `pack-manifests/core.json` are configuration data rather than
production code, test code, or a reusable script; both runsettings files measure 280 lines by
`wc -l`, recorded for completeness and comfortably under the cap in any reading.

Output Summary: All ten measured PowerShell files this work changed or added are at or under the
500-line cap. The closest to the cap is
`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` at 495 lines, leaving 5
lines of headroom; every other file has at least 32 lines of headroom. No P3-T25 split contingency
suite was created, so the measured set is complete. Satisfies AC-27.
