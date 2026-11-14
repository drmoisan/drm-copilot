# Pester Baseline (P0-T5)

Timestamp: 2026-11-07T16-10
Command: sh SCRATCH/issue-1037-pester-parallel.sh baseline (imports `scripts/powershell/PoshQC/PoshQC.psd1` and runs `Invoke-PoshQCParallelTest -Root <worktree>`; reads `ExitCode` from the returned object, then counts from the merged `artifacts/pester/pester-junit.xml` and line coverage from the merged `artifacts/pester/powershell-coverage.xml`)
EXIT_CODE: 0
Output Summary: Parallel run, 8 workers, wall clock 513.6 s, every shard exit 0, merged files written at 16:10 UTC. Total 17177, passed 17167, failed 0, skipped 10 (merged JUnit; the eight shard JUnit files give the same counts). Overall line coverage 95.30% (32788 covered, 1617 missed; report-level LINE counter of the merged JaCoCo file). Pre-existing failures: none. The run started before any file of this feature existed in the tree: neither file contains a `docs-role-contract` or `validate-docs-role-output` entry.

Owner directive 2026-11-07: parallel test gates only

The task text names a fresh single-process `Invoke-PoshQCTest` run over `tests/scripts`; under the owner directive this baseline is one `Invoke-PoshQCParallelTest` run with coverage (scan folders from `config/poshqc-scan.json`, coverage population from `config/poshqc-coverage.json`).
