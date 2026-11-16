# File-Size and Host Baseline (P0-T5)

Timestamp: 2026-11-16T01-18
Command: read of the JUnit record artifacts/pester/pester-junit.xml of the P0-T3 run (SCRATCH/issue-1025-pester-read.ps1 -ItName 'reports zero ratchet violations'); pwsh -NoProfile -Command '$PSVersionTable.PSVersion; (Get-Command Test-Json).Parameters.ContainsKey("SchemaFile")'
EXIT_CODE: 0
Output Summary: It `File-size policy repository gate.reports zero ratchet violations against config/file-size-baseline.json` (tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1): passed in the P0-T3 run. Host PowerShell version 7.6.10. Test-Json accepts -SchemaFile: True.
