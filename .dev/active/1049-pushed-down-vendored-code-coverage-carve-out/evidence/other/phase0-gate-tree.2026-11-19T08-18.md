# Phase 0 Gate (c) - Current Tree - [P0-T3]

Timestamp: 2026-11-19T08-18
Command: sh SCRATCH/issue-1049-brief-hashes.sh; sh SCRATCH/issue-1049-linecounts.sh <files>; Grep of the PoshQC function, parameter, sub-module and export anchors; Grep of `_BRIEF_COPIES` and `POSHQC_PARITY_PATHS`
EXIT_CODE: 0
Output Summary: Every item PRESENT; IDENTICAL: yes for the six brief copies. Recorded line count of PQ/PoshQC.Testing.psm1 is 554 logical lines (493 at planning), above the [P2-T4] acceptance cap of 515 before any edit.

## Brief copies

BRIEF_COPIES:
- .claude/skills/execution-environment/SKILL.md 8b14c277ef92caec5c90a941554b7a1cdd0a518093341f0fdb62bff9a466ae18
- .agents/skills/execution-environment/SKILL.md 8b14c277ef92caec5c90a941554b7a1cdd0a518093341f0fdb62bff9a466ae18
- .github/skills/execution-environment/SKILL.md 8b14c277ef92caec5c90a941554b7a1cdd0a518093341f0fdb62bff9a466ae18
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md 8b14c277ef92caec5c90a941554b7a1cdd0a518093341f0fdb62bff9a466ae18
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md 8b14c277ef92caec5c90a941554b7a1cdd0a518093341f0fdb62bff9a466ae18
- extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md 8b14c277ef92caec5c90a941554b7a1cdd0a518093341f0fdb62bff9a466ae18
IDENTICAL: yes

`_BRIEF_COPIES` in tests/scripts/dev_tools/test_execution_environment_brief_contracts.py asserts the same six paths.

## Anchors on HEAD

| Item | Status |
| --- | --- |
| `Get-PoshQCCoverageConfigRoot` in PQ/PoshQC.Coverage.psm1 | PRESENT |
| `Resolve-PoshQCCoveragePopulation` in PQ/PoshQC.Coverage.psm1 | PRESENT |
| `Invoke-PoshQCTest` with `-CoverageOutputPath` in PQ/PoshQC.Testing.psm1 | PRESENT |
| `Get-PoshQCParallelShardArgument` in PQ/PoshQC.Parallel.psm1 passing per-shard `-CoverageOutputPath` (AD-2 premise) | PRESENT |
| Sub-module list in PQ/PoshQC.psm1 (includes `PoshQC.Coverage.psm1`) | PRESENT |
| `Export-ModuleMember` list in PQ/PoshQC.psm1 | PRESENT |
| `FunctionsToExport` in PQ/PoshQC.psd1 | PRESENT |
| `scripts/powershell/PoshQC/README.md` in `POSHQC_PARITY_PATHS` (AD-4) | PRESENT |
| `## Coverage Verification` in scripts/harness-generation/sources/agents/feature-review.md (recorded owner) | PRESENT (two sections) |
| `## Coverage and File-Size Gates` in the brief | PRESENT |

## Logical line counts

| File | Lines | Plan figure or cap |
| --- | --- | --- |
| PQ/PoshQC.Coverage.psm1 | 314 | cap 360 after [P2-T3] |
| PQ/PoshQC.Testing.psm1 | 554 | 493 at planning; cap 515 after [P2-T4] |
| PQ/PoshQC.psm1 | 169 | - |
| PQ/PoshQC.psd1 | 39 | - |
| PQ/README.md | 120 | - |
| PQT/PoshQC.CoverageConfig.Tests.ps1 | 253 | cap 500 after [P2-T6] |
| PQT/PoshQC.Coverage.Tests.ps1 | 405 | 405 at planning |

PQ/PoshQC.Testing.psm1 grew after planning through the #1158 change (lane exclusion parameters and the MCP template lock branch). The [P2-T4] acceptance cap of 515 is already exceeded on HEAD by 39 lines, so [P2-T4] cannot meet its acceptance as written.
