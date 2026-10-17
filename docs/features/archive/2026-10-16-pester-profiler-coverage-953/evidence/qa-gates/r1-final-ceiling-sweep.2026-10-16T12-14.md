# Remediation Cycle 1 - Final Ceiling and Pin Sweep (P5-T7, AC-04, AC-16)

Timestamp: 2026-10-16T12-14
Command: sh SCRATCH/issue-953-r1-p5-t7.sh (pwsh -NoProfile -Command: for every CEIL_R1 row and file, @(Select-String -LiteralPath <path> -SimpleMatch -Pattern '<token>').Count)
EXIT_CODE: 0
Output Summary: 27 rows, 0 mismatches; every count equals its CEIL_R1 expected value. P5-T3 recorded RS03-INSTALLER-PESTER-590, RS05-INSTALLER-PESTER-CEILING-BELOW-6, RS06-TEST-IMPORT-PESTER-MAXIMUM, and RS07-WORKFLOW-LINUX-PESTER-RANGE as PASS (evidence/qa-gates/r1-final-poshqc-test-coverage.2026-10-16T12-13.md).
CEIL: scripts/powershell/PoshQC/PoshQC.psm1 | 6.0.0 | 1
CEIL: scripts/powershell/PoshQC/PoshQC.psm1 | [version]$module.UpperBound | 1
CEIL: scripts/powershell/PoshQC/PoshQC.psm1 | Where-Object -FilterScript $isSupportedVersion | 2
CEIL: scripts/powershell/PoshQC/PoshQC.psm1 | 5.6.1 | 0
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 6.0.0 | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | [version]$module.UpperBound | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | Where-Object -FilterScript $isSupportedVersion | 2
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | 5.6.1 | 0
CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 5.99.99 | 1
CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | -MaximumVersion $MaximumVersion | 1
CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | -MinimumVersion $MinimumVersion | 1
CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | ModuleVersion = $MinimumVersion | 1
CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | MaximumVersion = $MaximumVersion | 1
CEIL: scripts/powershell/PoshQC/PoshQC.Testing.psm1 | '5.9.0' '5.99.99' | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | 5.99.99 | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | -MaximumVersion $MaximumVersion | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | -MinimumVersion $MinimumVersion | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | ModuleVersion = $MinimumVersion | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | MaximumVersion = $MaximumVersion | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1 | '5.9.0' '5.99.99' | 1
CEIL: .github/workflows/_poshqc.yml | -MaximumVersion 5.99.99 | 1
CEIL: .devcontainer/post-create.sh | 6.0.0 | 1
CEIL: .devcontainer/post-create.sh | [version]$module.UpperBound | 1
CEIL: .github/codex/codex-web-setup.sh | 6.0.0 | 1
CEIL: .github/codex/codex-web-setup.sh | [version]$module.UpperBound | 1
CEIL: scripts/powershell/PoshQC/README.md | below 6.0 | 1
CEIL: extensions/drm-copilot/resources/powershell/PoshQC/README.md | below 6.0 | 1
Note: a first invocation of this script failed with a PowerShell parse error (unbalanced parenthesis in the row literal) before any count was taken; no file was changed. The script was corrected and rerun; the counts above come from that run.
