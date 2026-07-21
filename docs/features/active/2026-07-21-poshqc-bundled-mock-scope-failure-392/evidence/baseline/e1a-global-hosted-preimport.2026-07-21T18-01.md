# Experiment E1a — Global-hosted run WITH colliding bundled pre-import (Issue #392)

Timestamp: 2026-07-21T18-01
Command: `pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-Pester -Path tests/scripts/powershell/PoshQC -Output Detailed -PassThru"`
EXIT_CODE: 0
Output Summary:
- Passed=95, Failed=0, Skipped=7, Total=102.
- The bundled `PoshQC` module was pre-imported, yet the global-hosted `Invoke-Pester` run passed with 0 failures. No `Mock data are not setup for this scope` errors occurred.
- Conclusion: the pre-import collision alone is NOT sufficient to reproduce the defect when the run is hosted in the global session state. Module-session-state hosting is the necessary condition, so the E1 contingency (removing top-level PoshQC imports before the trampoline) is NOT required. See `e1-decision.<ts>.md`.
