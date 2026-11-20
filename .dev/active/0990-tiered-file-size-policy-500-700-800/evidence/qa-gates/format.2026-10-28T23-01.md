# Format gate (write mode) on the two touched PowerShell files

Timestamp: 2026-10-28T23-01
Command: Invoke-PoshQCFormat restricted to scripts/ci/New-FileSizeBaseline.ps1 and tests/scripts/ci/New-FileSizeBaseline.Tests.ps1 through the -GetFileList seam (PowerShell 7 from a sh launcher under SCRATCH)
EXIT_CODE: 0
Output Summary:
- The formatter logged "Already formatted" for 2 of 2 files and "Formatted" for 0 files.
- SHA256 before the format run, scripts/ci/New-FileSizeBaseline.ps1: 52a8604634f8816aa8ba16600272397553128e8b7986a698e2a422e6a6e77fb8; after: 52a8604634f8816aa8ba16600272397553128e8b7986a698e2a422e6a6e77fb8 (unchanged).
- SHA256 before, tests/scripts/ci/New-FileSizeBaseline.Tests.ps1: 654c45cac31717ed1f24ebb7d6389d46b2cb5ca49d1eb32b7fc3060c1a17d286; after: 654c45cac31717ed1f24ebb7d6389d46b2cb5ca49d1eb32b7fc3060c1a17d286 (unchanged).
- This is the confirming pass: no file changed.
