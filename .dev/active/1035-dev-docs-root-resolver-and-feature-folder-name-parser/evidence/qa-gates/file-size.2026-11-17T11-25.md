# File Size (P9-T11)

Timestamp: 2026-11-17T11-25
Command: sh SCRATCH/issue-1035-p9t11-sizes.sh (logical line counts with `awk 'END { print NR }'`, so a trailing terminator adds no line, for every `.ps1`, `.psm1`, `.py`, `.ts`, `.cjs`, `.sh`, `.json` and `.toml` file added or modified since the merge base of origin/main and HEAD; each file is also looked up in config/file-size-baseline.json)
EXIT_CODE: 0
Output Summary: 327 new or changed code, test and configuration files. None is above 800 lines and none is listed in config/file-size-baseline.json. Six files are at or above the 700-line advisory tier (non-blocking): three copies of one module, two copies of another, and one test suite. 42 further files are in the 500-line guidance tier. FileSizePolicy.RepoGate.Tests.ps1 ran and passed in the P9-T8 Pester gate (powershell-tests.2026-11-17T11-20.md: 27678 tests, 0 failures).

## Files at or above 700 lines

| File | Lines | Lines at the merge base | Tier |
| --- | --- | --- | --- |
| .claude/lib/epic-wave/EpicCrossDependency.psm1 | 780 | 769 | advisory (700) |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/EpicCrossDependency.psm1 | 780 | byte copy | advisory (700) |
| extensions/drm-copilot/resources/lib/epic-wave/EpicCrossDependency.psm1 | 780 | byte copy | advisory (700) |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 756 | 695 | advisory (700) |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 711 | 687 | advisory (700) |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 711 | byte copy | advisory (700) |

## Largest files in the 500-line guidance tier

enforce-epic-merge-gate-review.ps1 (four copies, 699), tests/scripts/dev_tools/test_new_active_feature_folder.py (686), extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts (648), scripts/dev_tools/resolve_file_prompt.py (614), extensions/drm-copilot/jest.config.cjs (610), tests/scripts/dev_tools/test_json_config.py (592), scripts/dev_tools/resolve_execute_plan_prompt.py (583); the remaining 31 guidance-tier files are between 500 and 577 lines (SCRATCH/p9t11-sorted.log lists every file and count). Codex hook files stay within the 500-line cap that legacy-codex-hook-contracts.Tests.ps1 applies to the hooks it names, and that suite passed in P9-T8.
