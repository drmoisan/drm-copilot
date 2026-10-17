# QA Gate: Physical Line Counts (Issue #973, Phase 4 pass 1)

Timestamp: 2026-10-17T13-40
Command: wc -l <eight files> (physical line count, per the execution-environment brief)
EXIT_CODE: 0

| File | Physical lines | Limit |
|---|---|---|
| `scripts/ci/CiChangeScope.psm1` | 395 | 500 |
| `scripts/ci/Invoke-CiChangeScope.ps1` | 365 | 500 |
| `tests/scripts/ci/CiChangeScope.Tests.ps1` | 389 | 500 |
| `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` | 110 | 500 |
| `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` | 272 | 500 |
| `tests/scripts/workflows/CiWorkflow.Tests.ps1` | 258 | 500 |
| `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` | 340 | 500 |
| `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` (unchanged) | 411 | 500 |

Output Summary: all eight files are at most 500 physical lines (largest 411).
