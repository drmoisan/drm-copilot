Timestamp: 2026-07-21T21-11

# Mechanism Decision (Revision 2, P0-T9)

## Decision: ADOPT CANDIDATE A

Candidate A is the parse-once process-lifetime cache in `scripts/powershell/PoshQC/PoshQC.psm1`'s
bootstrap loop (cache the parsed sub-module ScriptBlock in an AppDomain data slot; dot-source on
every `-Force` reimport).

## Supporting artifacts

- `evidence/baseline/e-b-narrowed-fast-repro.2026-07-21T21-11.md` — confirmed the regression
  reproduces at narrowed scope (PoshQC.Testing.psm1 131/195 = 67.18%, 64 uncovered).
- `evidence/baseline/e-c-candidate-parse-cache.2026-07-21T21-11.md` — Candidate A `CANDIDATE
  VERDICT: PASS`: PoshQC.Testing.psm1 195/195 = 100% (0 uncovered), 0 test failures,
  PoshQC.ScanConfig.psm1 44/46 = 95.65% unchanged.
- `evidence/baseline/e-d-candidate-idempotent-import.2026-07-21T21-11.md` — Candidate B NOT RUN
  (Candidate A already selected).
- `evidence/baseline/remediation2-coverage-baseline.2026-07-21T21-11.md` — pre-fix baseline used
  for the no-regression comparison.

## Required confirmations for the adopted candidate

(i) `-Force` reimport semantics and module-collision guards unaffected — CONFIRMED. The E-C run
    executed the full PoshQC test folder (107 tests, 0 failed), which includes the four files
    whose `BeforeAll` performs the detect-and-remove-mismatched-instance guard
    (PoshQC.Comprehensive.Tests.ps1, PoshQC.ScanFolders.Tests.ps1, PoshQC.EntryPoints.Tests.ps1,
    PoshQC.ScanConfig.Tests.ps1). All passed, so `Import-Module -Force` still triggers the
    bootstrap loop, the cached ScriptBlock dot-sources and rebinds functions into each new module
    session state, and the guards still detect/remove a mismatched instance.

(ii) issue #344 breakpoint-binding requirement preserved — CONFIRMED. PoshQC.ScanConfig.psm1
     per-file LINE coverage is 44/46 = 95.65% both pre-fix (P0-T5) and under Candidate A (E-C),
     i.e. zero regression. Coverage breakpoints continue to bind to sub-module source files because
     the cached ScriptBlock retains the on-disk file association from `ParseFile`.

(iii) issue #392 global-hosting trampoline fix unaffected — CONFIRMED. 0 test failures in the
      Candidate A experiment run; the already-committed #392 fix (global-hosting trampoline,
      -Global Pester import, PoshQC.TestingSeamDefaults.Tests.ps1, 3-test injection fix) continues
      to pass.

## Outcome

Proceed to Phase 1 (implement Candidate A). The E-C edit is already retained in the working tree.
