# Five Drift Suites After the Manifest and Bundle Updates (P5-T11)

Timestamp: 2026-09-29T18-37
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 tests/scripts/claude-lib/parallel-drift ; poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml parallel-drift/ParallelDriftHalt.Tests.ps1 parallel-drift/ParallelDrift.Tests.ps1 parallel-drift/ParallelDrift.Manifest.Tests.ps1 parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 parallel-drift/ParallelDrift.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary:
- `JUNIT file=parallel-drift/ParallelDriftHalt.Tests.ps1 Total=28 Passed=28 Failed=0 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Tests.ps1 Total=26 Passed=26 Failed=0 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Manifest.Tests.ps1 Total=5 Passed=5 Failed=0 Other=0`
- `JUNIT file=parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 Total=21 Passed=21 Failed=0 Other=0`
- `JUNIT file=parallel-drift/ParallelDrift.Parity.Tests.ps1 Total=20 Passed=20 Failed=0 Other=0`
- `JUNIT-ALL Total=100 Failed=0`
- Information only (the gate is P8-T5): with the new files registered in CodeCoverage.Path this
  folder run reported `JACOCO .../ParallelDriftHalt.psm1 Covered=67 Missed=0 LinePercent=100.00`,
  `.../ParallelDrift.psm1 Covered=123 Missed=0 LinePercent=100.00`,
  `.../Invoke-ParallelDriftDetection.ps1 Covered=91 Missed=5 LinePercent=94.79`.
