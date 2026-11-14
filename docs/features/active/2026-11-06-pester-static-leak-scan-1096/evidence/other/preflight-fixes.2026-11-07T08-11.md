# Preflight Fixes (Issue #1096, Round Two)

Timestamp: 2026-11-07T08-11
Plan: docs/features/active/2026-11-06-pester-static-leak-scan-1096/plan.2026-11-07T02-06.md

Every fix edits task text. No task was added, removed, or reordered, and no box was checked.

## Fixes

1. [P6-T2]. Defect class: validator-blind acceptance that cannot fail for one value; the correction keeps the assertion. The title `resolves a relative path against the PowerShell location, not the process directory` exists in both `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` and `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1`, so a repository-wide title search stays satisfied if the first file loses the case. The acceptance now reads the two titles under the `Enter-DrmCopilotShell.Tests.ps1` testsuite.
2. [P3-T2]. Defect class: citation correction. The task did not state the disposition of the same-titled case in `HostBootstrapWorkspace.Tests.ps1`. Spec `### 3. Process-directory independence`, the delta research, and section E of the base research name only the `Enter-DrmCopilotShell.Tests.ps1` cases, and section E records the host suite as not reported failing. The task now states that it leaves that file unchanged and that P3-T3 reaches it only through a class T row. The file set is unchanged.
