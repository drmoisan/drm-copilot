# Repo-Wide Run-Output Copy Verification (R1, cycle 1)

- Timestamp: 2026-09-17T14:00:17Z
- Command: `Copy-Item -LiteralPath 'artifacts/pester/powershell-coverage.xml' -Destination 'docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/repo-wide-powershell-coverage.r1.2026-09-17T09-10.xml' -Force` and `Copy-Item -LiteralPath 'artifacts/pester/pester-junit.xml' -Destination 'docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/repo-wide-pester-junit.r1.2026-09-17T09-10.xml' -Force`
- EXIT_CODE: 0

## Output Summary

Both destination files exist. SHA-256 hash comparison for each source/destination pair
(`Get-FileHash -Algorithm SHA256`) evaluates to `True`:

### `powershell-coverage.xml`

- Source (`artifacts/pester/powershell-coverage.xml`) hash:
  `4B230FCA79A6924607BD28939E45C589000C8FC3AC2A1BFD78A7945DF6BA4DFC`
- Destination (`evidence/other/repo-wide-powershell-coverage.r1.2026-09-17T09-10.xml`) hash:
  `4B230FCA79A6924607BD28939E45C589000C8FC3AC2A1BFD78A7945DF6BA4DFC`
- Match: `True`

### `pester-junit.xml`

- Source (`artifacts/pester/pester-junit.xml`) hash:
  `3D1AC9D13C7BC99DC76AAC6003B4C0DA1E202974473CC53903736CA542CD72A9`
- Destination (`evidence/other/repo-wide-pester-junit.r1.2026-09-17T09-10.xml`) hash:
  `3D1AC9D13C7BC99DC76AAC6003B4C0DA1E202974473CC53903736CA542CD72A9`
- Match: `True`

Both hash pairs are byte-identical, confirming the copy operation captured the exact repo-wide run output
from `[P1-T1]` before any subsequent PoshQC invocation could overwrite `artifacts/pester/`.
