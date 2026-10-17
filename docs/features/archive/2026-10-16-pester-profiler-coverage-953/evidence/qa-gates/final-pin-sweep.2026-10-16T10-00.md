# Final Pin and Ceiling Sweep (issue #953, P6-T12, post-split restart pass)

Timestamp: 2026-10-16T10-00
Command: SCRATCH/issue-953-p6-t12.sh: `@(Select-String -LiteralPath <path> -SimpleMatch -Pattern '<token>').Count` for `5.6.1` and `5.9.0` on each PIN8 path, `5.6.1` on tests/scripts/host-tools.manifest.Tests.ps1, and every CEIL row token on each CEIL file
EXIT_CODE: 0
Output Summary: Every `5.6.1` count is 0 (8 PIN8 files plus the host-tools manifest test file). Every PIN8 `5.9.0` count is 1. Every CEIL count equals its expected count (CEIL_ALL_MATCH=True). P6-T3 (final-poshqc-test-coverage.2026-10-16T09-55.md) recorded RS03, RS05, RS06, RS07, AC03-POWERSHELL-MODULES-PINNED, AC06-POWERSHELL-MODULE-ZERO-FAILURES, and AC07-DRYRUN-COMMITTED-MANIFEST as PASS. scripts/host-tools.manifest.json carries no ceiling (decision D8-M) and is not in CEIL.

PIN8 scripts/powershell/PoshQC/PoshQC.psm1 | 5.6.1 | 0
PIN8 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 5.6.1 | 0
PIN8 scripts/powershell/PoshQC/README.md | 5.6.1 | 0
PIN8 extensions/drm-copilot/resources/powershell/PoshQC/README.md | 5.6.1 | 0
PIN8 .github/workflows/_poshqc.yml | 5.6.1 | 0
PIN8 scripts/host-tools.manifest.json | 5.6.1 | 0
PIN8 .devcontainer/post-create.sh | 5.6.1 | 0
PIN8 .github/codex/codex-web-setup.sh | 5.6.1 | 0
PIN8 scripts/powershell/PoshQC/PoshQC.psm1 | 5.9.0 | 1
PIN8 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 5.9.0 | 1
PIN8 scripts/powershell/PoshQC/README.md | 5.9.0 | 1
PIN8 extensions/drm-copilot/resources/powershell/PoshQC/README.md | 5.9.0 | 1
PIN8 .github/workflows/_poshqc.yml | 5.9.0 | 1
PIN8 scripts/host-tools.manifest.json | 5.9.0 | 1
PIN8 .devcontainer/post-create.sh | 5.9.0 | 1
PIN8 .github/codex/codex-web-setup.sh | 5.9.0 | 1
TESTS tests/scripts/host-tools.manifest.Tests.ps1 | 5.6.1 | 0
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
