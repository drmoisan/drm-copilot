# Final Pin and Ceiling Sweep (issue #953, P6-T12, AC-04, AC-05, AC-16)

Timestamp: 2026-10-16T08-55
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; foreach ($p in <PIN8>) { @(Select-String -LiteralPath $p -SimpleMatch -Pattern "5.6.1").Count }; foreach ($p in <PIN8>) { @(Select-String -LiteralPath $p -SimpleMatch -Pattern "5.9.0").Count }; @(Select-String -LiteralPath tests/scripts/host-tools.manifest.Tests.ps1 -SimpleMatch -Pattern "5.6.1").Count; foreach (<CEIL row>) { @(Select-String -LiteralPath <row path> -SimpleMatch -Pattern <row token>).Count }' (script SCRATCH/issue-953-p6-t12.sh, run with sh)
EXIT_CODE: 0
Output Summary: Every PIN8 5.6.1 count is 0; every PIN8 5.9.0 count is 1 (at least 1 required); tests/scripts/host-tools.manifest.Tests.ps1 5.6.1 count is 0; all 15 CEIL rows equal their expected counts. P6-T3 (final-poshqc-test-coverage.2026-10-16T08-50.md) recorded RS03, RS05, RS06, RS07, AC03-POWERSHELL-MODULES-PINNED, AC06-POWERSHELL-MODULE-ZERO-FAILURES, and AC07-DRYRUN-COMMITTED-MANIFEST as PASS. scripts/host-tools.manifest.json carries no ceiling (decision D8-M) and is not in CEIL.

## PIN8 counts

| Path | 5.6.1 | 5.9.0 |
|---|---|---|
| scripts/powershell/PoshQC/PoshQC.psm1 | 0 | 1 |
| extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 0 | 1 |
| scripts/powershell/PoshQC/README.md | 0 | 1 |
| extensions/drm-copilot/resources/powershell/PoshQC/README.md | 0 | 1 |
| .github/workflows/_poshqc.yml | 0 | 1 |
| scripts/host-tools.manifest.json | 0 | 1 |
| .devcontainer/post-create.sh | 0 | 1 |
| .github/codex/codex-web-setup.sh | 0 | 1 |

TESTS_5.6.1: tests/scripts/host-tools.manifest.Tests.ps1 | 0

## CEIL counts

CEIL: scripts/powershell/PoshQC/PoshQC.psm1 | 6.0.0 | 1
CEIL: scripts/powershell/PoshQC/PoshQC.psm1 | [version]$module.UpperBound | 2
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 6.0.0 | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | [version]$module.UpperBound | 2
CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 5.99.99 | 1
CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | -MaximumVersion $MaximumVersion | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | 5.99.99 | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | -MaximumVersion $MaximumVersion | 1
CEIL: .github/workflows/_poshqc.yml | -MaximumVersion 5.99.99 | 1
CEIL: .devcontainer/post-create.sh | 6.0.0 | 1
CEIL: .devcontainer/post-create.sh | [version]$module.UpperBound | 1
CEIL: .github/codex/codex-web-setup.sh | 6.0.0 | 1
CEIL: .github/codex/codex-web-setup.sh | [version]$module.UpperBound | 1
CEIL: scripts/powershell/PoshQC/README.md | below 6.0 | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/README.md | below 6.0 | 1

CEIL_ALL_MATCH: YES
