# Stage I PowerShell Static Final QC (P3-T1, restart pass after the P2-T3 commit)

Timestamp: 2026-11-08T17-45
Command: sh-launched PowerShell 7 script stored under SCRATCH importing scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat check-only (no-op -WriteFile that records the files it would write) and a direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file (up to 5 attempts on the known transient analyzer null-reference) over the 15 changed or created .ps1 and .psm1 files of the reduction, bundle copies included, plus the two P2-T3 files scripts/dev-tools/ProcessReductionChain.psm1 and tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1 (17 files)
EXIT_CODE: 0
Output Summary:
  Run after the P2-T3 fix commit (committed 2026-11-08T17-44 UTC); the pass of 2026-11-08T17-09 is void under the gate-restart rule.
  Format: command Invoke-PoshQCFormat (check-only), exit 0, files needing format 0 of 17.
  Lint: command Invoke-ScriptAnalyzer, exit 0, findings 0 in every file of the 17.
  Type check: not applicable for PowerShell.
  git status --porcelain digest identical before and after the formatter (no file changed).
  Compared with stage-i-powershell-static P0-T1 baseline: 0 files needing format and 0 findings before and after.
