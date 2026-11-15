# Final QC static: PowerShell

Timestamp: 2026-11-15T01-16
Command: formatter check (Invoke-Formatter compared with each file text, no write) and Invoke-ScriptAnalyzer (Error, Warning, Information) with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over scripts/ci, tests/scripts/ci, and tests/scripts/workflows; actionlint 1.7.12 over .github/workflows/_poshqc.yml and .github/workflows/_quality-checks.yml; Pester selection of tests/scripts/workflows through the launcher pester suite before the static steps
EXIT_CODE: 0
Output Summary: Pester selection (tests/scripts/workflows): 98 tests, 0 failures, exit 0. Format: exit 0, 24 files, 0 would change (the tree was unchanged after the formatter: git status --porcelain listed no change). Lint: exit 0, 24 files, 0 findings (one retry of the known analyzer engine NullReferenceException on a module, no finding). Type check: not applicable for PowerShell. actionlint: exit 0, 0 findings. All steps clean in one pass.
