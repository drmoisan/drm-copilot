# Pester Shuffled File-Order Isolation (issue 1024, remediation cycle 1)

Timestamp: 2026-11-04T15-28
Task: [P3-T8]
Command: sh SCRATCH/issue-1024-shuffle.sh (for seeds 11, 23, 47: one PowerShell 7 process per seed running SCRATCH/issue-1024-shuffle.ps1 -Seed <seed>; the five suites are sorted ordinally, then Fisher-Yates shuffled with [System.Random]::new(<seed>); one Invoke-Pester call with Run.Path set to the shuffled list, Run.PassThru, JUnit written to SCRATCH/issue-1024-shuffle-<seed>.xml, no coverage, no strict mode in the runner)
EXIT_CODE: 0
Output Summary: Seeds 11, 23 and 47: 125 tests each, 125 passed, 0 failed, 0 failed containers (JUnit tests=125 failures=0 errors=0 for each seed). The executed container order equalled the shuffled order in every seed. No order dependence found.

## Seed 11 (passed 125, failed 0)

1. `tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1`
2. `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`
3. `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1`
4. `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Properties.Tests.ps1`
5. `tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1`

## Seed 23 (passed 125, failed 0)

1. `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1`
2. `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Properties.Tests.ps1`
3. `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`
4. `tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1`
5. `tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1`

## Seed 47 (passed 125, failed 0)

1. `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Properties.Tests.ps1`
2. `tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1`
3. `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`
4. `tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1`
5. `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1`

The fresh single-process run over all of `tests/scripts` and the concurrent-shard run are left to the CI shard jobs checked by the orchestrator at S9, as stated in the plan's Pre-Mortem.
