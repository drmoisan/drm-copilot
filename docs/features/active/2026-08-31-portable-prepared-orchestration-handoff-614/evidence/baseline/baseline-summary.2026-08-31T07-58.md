Timestamp: 2026-08-31T11-35
Command: `rg -n '^(EXIT_CODE:|Output Summary:|- Baseline result:|- Pre-existing failure:|- Repository .*coverage:|- Changed-script baseline)' 'docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline'`
EXIT_CODE: 0
Output Summary:
- Python baseline: Black, Ruff, and Pyright passed. Pytest recorded 1 pre-existing frozen-surface digest failure, 4244 passes, and 5 skips.
- Python coverage: line 92.7087% and branch 85.2994%.
- TypeScript baseline: Prettier passed. Initial ESLint/TSC/Jest attempts lacked installed development tools; `npm ci` restored locked dependencies and Jest then passed 2735 tests.
- TypeScript coverage: line 96.72% and branch 90.17%.
- PowerShell baseline: formatter equivalence and PSScriptAnalyzer passed. Pester recorded 32 process-launch environment failures among 627 tests.
- PowerShell coverage: repository line 18.8011%; target hook line 93.3333%; branch coverage is exempt because Pester does not measure it.
- Python zero-regression target: line >= 92.7087%, branch >= 85.2994%, and new/changed-line coverage >= 90%.
- TypeScript zero-regression target: line >= 96.72%, branch >= 90.17%, and new/changed-line coverage >= 90%.
- PowerShell final target required by the Plan of Record: repository line >= 85%, new/changed-line coverage >= 90%, no line regression, and one clean ordered pass.
- This reconciliation changed no production or test file.
