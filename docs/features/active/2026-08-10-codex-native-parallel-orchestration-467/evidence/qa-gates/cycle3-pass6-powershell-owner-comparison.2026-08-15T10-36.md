# Cycle 3 Pass 6 PowerShell Owner Comparison

Timestamp: 2026-08-16T21-00

Command: `compare Phase 3 format, analyze, test, and coverage receipts with P0-T11 and the preserved 25-owner matrix; verify governed input fingerprint and fresh bundled owner intersection`

EXIT_CODE: 0

Output Summary: The ordered format -> analyze -> test loop passed cleanly. Fresh tests and line coverage match Phase 0, the fresh bundled report's issue-owner intersection matches 157/159, all 25 preserved owners remain attributable because their governed inputs are unchanged, and every owner threshold/no-regression gate passes. The raw branch result remains 0/0 unavailable and only the compliance disposition is authorized.

## Ordered Loop

| Step | Receipt SHA-256 | Result |
|---|---|---|
| Format | `FEEA63C5FBD75B5FD57E1C87C0D05BFF06F72CC1EDC6FA4BC9D80E0A6590475C` | PASS; zero mutation |
| Analyze | `0D813D40AC23E119EB8C1978696170E6D4B4E9AC79C20D5A0AD67F3A8237388A` | PASS; zero findings |
| Test | `B30E7BDDE38C16BA5AB6A2CA3AACBC1D48C73162D6C6578F3FEB2496A7DF7451` | PASS; 2,456/2,447/9/0 |
| Coverage | `68E0A5EE77247B50CC8AD7EF6705017B239B8647B41302FFF92C20A0B02B354B` | PASS for retained line gate; raw branch unavailable |

- Clean format -> analyze -> test loop: PASS.
- Toolchain restart required: `false`.

## Baseline and Fresh Measurements

- Phase 0 coverage/owner receipt SHA-256: `AB48291C6E511C51555865F6DFED2C73FFCD148B07775C2C5475ED1754703187`
- Tests: baseline 2,456 total / 2,447 passed / 9 disabled / 0 failures or errors; final identical.
- Line coverage: baseline 4,040/4,260 = 94.835681%; final identical.
- Fresh `.codex/hooks/enforce-completion-consistency.ps1`: 157/159 lines, matching the preserved matrix.
- Governed executable-input fingerprint delta: 0 paths and 0 bytes.

## Preserved Owner Matrix

- Source-attributed owners: 25/25 — PASS.
- Added owners at or above 90%: 17/17 — PASS.
- Modified owners meeting at least 80% or their explicit no-regression requirement: 8/8 — PASS.
- Added-owner minimum: 90.000000%.
- Modified-owner minimum: 80.888889%.
- Changed-owner coverage regression: none.
- PowerShell format gate: PASS.
- PowerShell analysis gate: PASS.
- PowerShell test gate: PASS.
- PowerShell line gate: PASS.
- PowerShell owner gates: PASS.

## Raw Branch and Disposition

- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`
- Source-attributable branch numerator: 0
- Source-attributable branch denominator: 0
- `RAW_BRANCH_RESULT: 0/0 UNAVAILABLE`
- `COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED`
- Measured 75% PowerShell branch threshold passed: `false`
- Proxy or synthetic branch percentage used: `false`

Result: PASS under the issue-scoped one-time disposition, with every retained gate passing independently.
