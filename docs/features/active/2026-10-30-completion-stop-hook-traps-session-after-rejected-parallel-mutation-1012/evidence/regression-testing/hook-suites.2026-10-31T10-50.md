# Hook Suite Regression Run (issue #1012)

Timestamp: 2026-10-31T10-50
Command: sh SCRATCH/issue-1012-hooksuites.sh (one Pester process through Invoke-PoshQCTest, branch-current, over: the two new suites; every tests/scripts/claude-hooks/validate-orchestrator-output*.Tests.ps1 suite (resolution, Envelope, FeatureFolder, Reentry, base, WaveBarrier, WorktreeResolution, artifact-type-dispatch, human-interaction, model-routing); hook-dependency-failure.Claude.Tests.ps1; hook-dependency-failure.SpecialCases.Tests.ps1; subagentstop-uncaught-error.Tests.ps1; enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1; tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1; tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1), then SCRATCH/issue-1012-summary.ps1 over artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary:
- JUnit: total 1564, passed 1564, failed 0, skipped 0
- Zero failures.

Named results:

| Test | Result |
| --- | --- |
| R8 blocks a parallel validation as NoTarget when no live parallel checkpoint exists | PASSED |
| R9 discovers the single live parallel run and reads its checkpoint | PASSED |
| R10 blocks as Ambiguous when two live parallel runs record distinct slugs | PASSED |
| R11 follows the parallel_slug the output names | PASSED |
| O-5 epic target not derivable blocks always | PASSED |
| E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved | PASSED |
| H5 does not run the port for the parallel checkpoint type | PASSED |
| denies a missing parallel checkpoint (fail closed) | PASSED |
| S2-6 passes the cross-check for every existing SubagentStop registration unchanged | PASSED |
| S1 through S6 for `.claude/hooks/validate-orchestrator-output.ps1` (repository and mirror rows, 12 rows) | PASSED |
| AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1 calls the interception probe from inside an It | PASSED |
| AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1 complies with the baseline isolation form for every closure seam | PASSED |
| AC-4 tests/scripts/claude-hooks/validate-orchestrator-output-rejection.Tests.ps1 complies with the baseline isolation form for every closure seam | PASSED |

Note on AC-6 for the unit suite: the discovery guard generates an AC-6 row only for a suite whose named seams comply by form F1 or the helper form (`Get-EpicStateProbeSeam`). `validate-orchestrator-output-rejection.Tests.ps1` complies by another form, so no AC-6 row is generated for it and its AC-4 row passes. The suite still carries the `baseline mock interception probe` row inside an `It`, and that row passes.

The mirror rows of S1 through S6 read the bundle copy, which still matched the pre-change hook at this point; the bundle copies are written in P4-T1 and the suites are re-run in P5-T3.
