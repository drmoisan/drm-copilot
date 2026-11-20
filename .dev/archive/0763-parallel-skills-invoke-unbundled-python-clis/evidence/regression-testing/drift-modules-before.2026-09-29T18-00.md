# Drift Module Suites Before the Modules Exist (P3-T11, expect-fail)

Timestamp: 2026-09-29T18-00
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 tests/scripts/claude-lib/parallel-drift ; poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml parallel-drift/ParallelDriftHalt.Tests.ps1 parallel-drift/ParallelDrift.Tests.ps1 parallel-drift/ParallelDrift.Manifest.Tests.ps1
EXIT_CODE: 62
ExpectedExitCode: 62
Output Summary:
- Pester: `Tests Passed: 0, Failed: 59, Skipped: 0` in 489ms; process EXIT_CODE 62 (non-zero)
- `JUNIT file=parallel-drift/ParallelDriftHalt.Tests.ps1 Total=28 Passed=0 Failed=28 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Tests.ps1 Total=26 Passed=0 Failed=26 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Manifest.Tests.ps1 Total=5 Passed=0 Failed=5 Other=0`
- No `MISSING` line.

Every container fails in BeforeAll: the two module suites cannot import their module, and the
manifest suite's discovery fails because `.claude/lib/parallel-drift` does not exist yet.
