# Cycle 3 Pass 6 PowerShell Ownership

Timestamp: 2026-08-15T11:40:07-04:00
Command: Count lines and compute SHA-256 for the five PowerShell paths defined by [P0-T6].
EXIT_CODE: 0
Output Summary: Starting line counts are 463, 463, 35, 259, and 579. The two `PoshQC.Testing.psm1` copies are byte-identical. `PoshQC.Tests.ps1` is read-only for this pass.

| Path | Lines | Bytes | SHA-256 | Disposition |
|---|---:|---:|---|---|
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | 463 | 21381 | `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280` | Authorized only if [P1-T3] establishes a genuine branch collector |
| `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` | 463 | 21381 | `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280` | Required byte-identical shipped counterpart if the root module changes |
| `scripts/powershell/PoshQC/convert-poshqc-coverage.ps1` | 35 | 1155 | `D2EBD92B2A0C071A364486AF5E38071723AEFEA6489147DC8C15D7D100B6379F` | Authorized only if [P1-T3] establishes a genuine branch collector |
| `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` | 259 | 15652 | `AD167E1218BE92637F750F73EFA26BE4B8A4ED94C79DDECE9F298E7F8E05DFB8` | Authorized only if [P1-T3] establishes a genuine branch collector |
| `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` | 579 | 27618 | `8202A5BD80305FB6E649B2CE874B4483687CE88AE19AFDEDBF0AD6B16186497C` | Read-only for pass 6 |

- Root module SHA-256 equals shipped module SHA-256: `true`
- Root and shipped module bytes are identical: `true`
- `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` may be read but must not be modified: `true`
