# Phase 0 Gate (c) - Current Tree - [P0-T3] (re-run, plan revision 2.1)

Timestamp: 2026-11-19T08-48
Command: sh SCRATCH/issue-1049-tree.sh (sha256sum of the six brief copies; logical line counts by `awk 'END{print NR}'`, equivalent to `@(Get-Content -LiteralPath <path>).Count` for files ending in a line terminator); Grep of the PoshQC function, parameter, sub-module and export anchors; Grep of `_BRIEF_COPIES` and `POSHQC_PARITY_PATHS`; Grep of the feature-review source and brief anchors
EXIT_CODE: 0
Output Summary: Every item PRESENT; IDENTICAL: yes; every count equals its planning count (difference 0). No mismatch.

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
| Two `## Coverage Verification` sections in scripts/harness-generation/sources/agents/feature-review.md, each with `### Verification Procedure` step 2 `Check whether the coverage artifact exists for that language.` | PRESENT (both) |
| `## Coverage and File-Size Gates` in the brief, first bullet ending `No production file may be excluded from measurement.` | PRESENT |

## Logical line counts

| File | Lines | Planning count | Difference |
| --- | --- | --- | --- |
| PQ/PoshQC.Coverage.psm1 | 314 | 314 | 0 |
| PQ/PoshQC.Testing.psm1 | 554 | 554 | 0 |
| PQ/PoshQC.psm1 | 169 | - | - |
| PQ/PoshQC.psd1 | 39 | - | - |
| PQ/README.md | 120 | - | - |
| PQT/PoshQC.CoverageConfig.Tests.ps1 | 253 | 253 | 0 |
| PQT/PoshQC.Coverage.Tests.ps1 | 405 | 405 | 0 |

Result: no mismatch.
