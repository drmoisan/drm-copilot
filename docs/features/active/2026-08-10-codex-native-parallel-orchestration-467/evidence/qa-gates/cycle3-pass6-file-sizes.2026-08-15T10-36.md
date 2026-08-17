# Cycle 3 Pass 6 File Sizes and Hashes

Timestamp: 2026-08-16T21-00

Command: `Get-Content <P0-T6 path> | Measure-Object -Line; Get-FileHash <P0-T6 path> -Algorithm SHA256`

EXIT_CODE: 0

Output Summary: Every P0-T6 production, test, and reusable-script owner retains its exact baseline line count and SHA-256. Both module copies remain byte-identical, the legacy PoshQC.Tests.ps1 remains read-only, and executor path/byte mutation is zero.

| Path | Baseline lines | Final lines | Baseline/final SHA-256 | Result |
|---|---:|---:|---|---|
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | 463 | 463 | `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280` | unchanged |
| `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` | 463 | 463 | `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280` | unchanged |
| `scripts/powershell/PoshQC/convert-poshqc-coverage.ps1` | 35 | 35 | `D2EBD92B2A0C071A364486AF5E38071723AEFEA6489147DC8C15D7D100B6379F` | unchanged |
| `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` | 259 | 259 | `AD167E1218BE92637F750F73EFA26BE4B8A4ED94C79DDECE9F298E7F8E05DFB8` | unchanged |
| `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` | 579 | 579 | `8202A5BD80305FB6E649B2CE874B4483687CE88AE19AFDEDBF0AD6B16186497C` | unchanged/read-only |

- Executor path mutation: 0
- Executor byte mutation: 0
- Root/bundled module byte-identical: `true`
- `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` remained read-only: `true`

Result: PASS
