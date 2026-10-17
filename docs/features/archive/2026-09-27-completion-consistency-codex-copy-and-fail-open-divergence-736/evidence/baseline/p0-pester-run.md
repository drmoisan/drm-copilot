# Baseline Pester run with coverage ([P0-T11])

Timestamp: 2026-10-08T17-36
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/claude-hooks,tests/scripts/codex-hooks'
EXIT_CODE: 2
Output Summary: child exit code 2. The tool also printed a run summary of Passed 3413, Failed 2 (listed by [P0-T12]). artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml exist afterwards.
