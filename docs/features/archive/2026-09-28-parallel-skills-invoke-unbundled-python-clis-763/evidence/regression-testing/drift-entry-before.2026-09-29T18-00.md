# Entry-Script and Parity Suites Before the Entry Script Exists (P3-T18, expect-fail)

Timestamp: 2026-09-29T18-00
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 tests/scripts/claude-lib/parallel-drift ; poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 parallel-drift/ParallelDrift.Parity.Tests.ps1
EXIT_CODE: 47
ExpectedExitCode: 47
Output Summary:
- Pester process EXIT_CODE 47 (non-zero)
- `JUNIT file=parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 Total=21 Passed=0 Failed=21 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Parity.Tests.ps1 Total=20 Passed=0 Failed=20 Other=0`
- `JUNIT-ALL Total=100 Failed=45` (the 21 and 20 above plus the four Manifest cases that await
  Phase 5)
- No `MISSING` line.

Both containers fail in BeforeAll because `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`
does not exist yet, so the dot-source fails.
