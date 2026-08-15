# PowerShell Branch-Capability Decision

Timestamp: 2026-08-15T00-00
Command: Reconcile P0-T6 through P0-T8 coverage measurements, owner attribution, emitter semantics, approved dependencies, and mutation checks.
EXIT_CODE: 0
Output Summary: PowerShell line coverage is measured at 4,040/4,260 (94.835681%) for the bundled report, but it exposes no measured branch denominator. Pester branch fields are fixed placeholders rather than observed control-flow outcomes. The branch policy result is FAIL and remediation remains required.

GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO

## Measured results

- Bundled coverage SHA-256: `FC146941FA72DB4488278B952A3A2FA3808250757CACD6514181D31395768F67`
- Covered lines: `4,040`
- Missed lines: `220`
- Line denominator: `4,260`
- Line coverage: `94.835681%`
- Unique bundled source names: `46`
- BRANCH counter count: `0`
- Branch covered: `0`
- Branch missed: `0`
- Branch denominator: `0`
- Branch threshold result: `FAIL`

The zero denominator is unavailable branch data. It is not a passing percentage.

## Owner reconciliation

- Source-attributed owners preserved: `25/25`
- Added owners at or above 90% line coverage: `17/17`
- Modified owners meeting applicable line thresholds: `8/8`
- The supplemental bundled XML omits six modified owners and does not replace the prior owner-attributed receipt.

## Collector semantics

- `scripts/powershell/PoshQC/PoshQC.Testing.psm1:329-417` configures Pester command/line coverage and path relativization; it does not collect branch outcomes.
- `scripts/powershell/PoshQC/convert-poshqc-coverage.ps1:22-34` rewrites report paths only.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-23,188` enables coverage output with a zero tool target; it does not establish the repository's 75% branch metric.
- Installed Pester 5.6.1 lines 9634-9684 derive command and line hits from breakpoints; lines 9791-9797 emit fixed `mb=0` and `cb=0` values; lines 9813-9843 omit `BRANCH` counters.
- Official Pester 5.7.1 JaCoCo lines 1011-1012 retain fixed zero branch fields, and Cobertura lines 1136, 1159, and 1181-1183 emit fixed branch-rate/zero-denominator placeholders.

Command hits, line hits, AST source positions, and source-position correlation are not measured control-flow branch outcomes and are not classified as branch coverage.

## Dependency and policy disposition

- Approved deterministic source-attributable branch collector present: `NO`
- Dependency added: `NO`
- Policy or threshold changed: `NO`
- Waiver or exception created: `NO`
- PowerShell branch policy: `FAIL`
- `POWERSHELL_BRANCH_POLICY_UNRESOLVED`

REMEDIATION_REQUIRED: POWERSHELL_BRANCH_POLICY_UNRESOLVED
