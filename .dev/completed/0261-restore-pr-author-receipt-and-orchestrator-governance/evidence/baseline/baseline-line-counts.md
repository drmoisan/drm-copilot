# Baseline — Line Counts (in-scope PowerShell files)

Timestamp: 2026-06-27T23-40

Command: wc -l on each in-scope PowerShell file

EXIT_CODE: 0

## Per-file line counts (cap = 500)

| File | Lines | Headroom under 500 |
|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.ps1` | 374 | 126 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | 374 | 126 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` | 336 | 164 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | 473 | 27 |

Output Summary: All four in-scope PowerShell files are under the 500-line cap at baseline. The test file has the least headroom (27 lines). The plan permits extracting receipt-seam test helpers into a sibling `.ps1` if the test file would exceed 500 lines (P1-T23).

Note: `wc -l` counts newline characters; the runtime hook ends with a final newline after `exit 0`, so the displayed count is 374 (the file body extends through line 375 in the editor view). The codex mirror count (336) reflects the converted-hook form, which is body-equivalent below its prepended header.
