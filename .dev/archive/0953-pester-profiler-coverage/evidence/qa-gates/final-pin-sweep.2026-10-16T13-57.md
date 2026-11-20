# Final QC: Pin and Ceiling Sweep (P8-T16 / P6-T12, sharding path)

Timestamp: 2026-10-16T13-57
Command: sh "SCRATCH/issue-953-p8-t16-p6-t12.sh" — `@(Select-String -LiteralPath <path> -SimpleMatch -Pattern '<token>').Count` for each PIN8 path (`5.6.1`, `5.9.0`), for `tests/scripts/host-tools.manifest.Tests.ps1` (`5.6.1`), for every CEIL row, and, per P8-T16 substitution 4, for `.github/workflows/_poshqc.yml` (`-MaximumVersion 5.99.99` count compared with the `Import-Module Pester` count).
EXIT_CODE: 0

Output Summary:
- PIN8 `5.6.1` counts: all 0 (8 files). PIN8 `5.9.0` counts: PoshQC.psm1 1, bundled PoshQC.psm1 1, README.md 1, bundled README.md 1, _poshqc.yml 2, host-tools.manifest.json 1, post-create.sh 1, codex-web-setup.sh 1 (all at least 1).
- tests/scripts/host-tools.manifest.Tests.ps1 `5.6.1`: 0.
- CEIL: scripts/powershell/PoshQC/PoshQC.psm1 | 6.0.0 | 1
- CEIL: scripts/powershell/PoshQC/PoshQC.psm1 | [version]$module.UpperBound | 1
- CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 6.0.0 | 1
- CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | [version]$module.UpperBound | 1
- CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 5.99.99 | 1
- CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | -MaximumVersion $MaximumVersion | 1
- CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | 5.99.99 | 1
- CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | -MaximumVersion $MaximumVersion | 1
- CEIL: .github/workflows/_poshqc.yml | -MaximumVersion 5.99.99 | 2 (equal to the Import-Module Pester count 2; both at least 1; substitution 4)
- CEIL: .devcontainer/post-create.sh | 6.0.0 | 1
- CEIL: .devcontainer/post-create.sh | [version]$module.UpperBound | 1
- CEIL: .github/codex/codex-web-setup.sh | 6.0.0 | 1
- CEIL: .github/codex/codex-web-setup.sh | [version]$module.UpperBound | 1
- CEIL: scripts/powershell/PoshQC/README.md | below 6.0 | 1
- CEIL: extensions/drm-copilot/resources/powershell/PoshQC/README.md | below 6.0 | 1
- Every CEIL count equals its expected count (CEIL_ALL_MATCH=True).
- The latest final-poshqc-test-coverage evidence records RS03, RS05, RS06, RS07, AC03-POWERSHELL-MODULES-PINNED, AC06-POWERSHELL-MODULE-ZERO-FAILURES, and AC07-DRYRUN-COMMITTED-MANIFEST as PASS.
- Result: PASS (AC-04, AC-05, AC-16).
