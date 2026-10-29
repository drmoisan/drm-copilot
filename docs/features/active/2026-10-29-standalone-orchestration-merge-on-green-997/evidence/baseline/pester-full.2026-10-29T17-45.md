Timestamp: 2026-10-29T17-45
Command: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <repo> -ScanFolders tests/scripts (single process, via sh-launched pwsh from SCRATCH)
EXIT_CODE: 0
Output Summary: Passed 12188, Failed 0, Skipped 10 (pester-junit.xml). Line coverage from powershell-coverage.xml: enforce-epic-merge-gate-green-ci.ps1 100.00% (56/56); enforce-epic-merge-gate.ps1 100.00% (132/132); repository total 92.95% (18409 covered, 1396 missed).
