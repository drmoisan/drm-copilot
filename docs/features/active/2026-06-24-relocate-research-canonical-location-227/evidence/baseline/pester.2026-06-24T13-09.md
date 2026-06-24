# Baseline — PoshQC Pester (coverage mode)

Timestamp: 2026-06-24T13-09
Command:
- mcp__drm-copilot__run_poshqc_test (scan_folders: ["tests/scripts/claude-hooks"]) — full claude-hooks suite, includes both target test files.
- Targeted per-hook coverage measured directly via Pester (CodeCoverage.Path scoped to the two hooks), because the bundled PoshQC coverage scope in scripts/powershell/PoshQC/settings/pester.runsettings.psd1 does not instrument these two hooks. Pester invocation: Invoke-Pester with Run.Path = the two hook test files, CodeCoverage.Path = .claude/hooks/validate-task-researcher-output.ps1 and .claude/hooks/enforce-evidence-locations.ps1, OutputFormat JaCoCo.
EXIT_CODE: 0

Output Summary:
- Full claude-hooks suite (PoshQC): tests=248, failures=0, errors=0.
- Target test suites: validate-task-researcher-output.Tests.ps1 = 17 tests, 0 failures; enforce-evidence-locations.Tests.ps1 = 5 tests, 0 failures.
- Targeted coverage run: Total=22, Passed=22, Failed=0.
- Numeric line coverage (JaCoCo, baseline):
  - validate-task-researcher-output.ps1: LINE 52/59 = 88.1%
  - enforce-evidence-locations.ps1: LINE 19/27 = 70.4%
- Branch coverage: Pester's PowerShell coverage engine emits no BRANCH counters (command/line coverage only); branch coverage is not measured by this toolchain. The repository PowerShell policy thresholds are evaluated against the available line/command coverage; BRANCH is not produced for PowerShell.
- Note on enforce-evidence-locations.ps1 baseline (70.4%): the 8 uncovered lines are the entry-point block (the dot-source guard at line 137 and the script-execution tail at lines 141-150) which executes only when the script is invoked as an entry point, not when dot-sourced by tests. The tested logic function Test-EvidenceLocationForbidden (where this feature's changed lines live) is covered. This is the pre-change baseline; post-change coverage and changed-line coverage are evaluated in P9-T4.
