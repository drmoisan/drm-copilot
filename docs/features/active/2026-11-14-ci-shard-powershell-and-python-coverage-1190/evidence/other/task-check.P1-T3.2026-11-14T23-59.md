# Task check P1-T3

Timestamp: 2026-11-14T23-59
Command: launcher pester suite with -TestPath tests/scripts/ci/Select-PythonTestShard.Tests.ps1
EXIT_CODE: 0
Output Summary: New test file tests/scripts/ci/Select-PythonTestShard.Tests.ps1 (no temp files; all reads and writes through seams or mocks; one default-seam case reads the committed tests). 30 tests, 0 failures. Cases: SH01 balanced, SH02 deterministic order, SH03 CRLF equals LF (weights and assignment), SH04 size weighting (fails if the PowerShell weights file were read), SH05 empty shard and empty enumeration, SH06 manifest and list writes, SH07 no weights file, SH08 collect-count parse, SH09 verify pass, missing file, duplicate, JUnit-sum mismatch, SH10 entry exit codes, SH11 guard, SH12 default boundaries. Per-file line coverage of the helper 89.86% in this selection run; the gate figure is read at the P1-T4 phase gate and P4-T2.
