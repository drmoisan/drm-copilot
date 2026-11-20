# Task check [P1-T5]

Timestamp: 2026-11-20T11-24
Command: sh SCRATCH/issue-1016-pstc.sh <file> for each changed file (Invoke-Formatter comparison with scripts/powershell/PoshQC/settings/pssa.settings.psd1, non-writing; Invoke-ScriptAnalyzer with the same settings); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1 tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1
EXIT_CODE: 0
Output Summary: Format drift 0 and analyzer findings 0 for both changed files. Pester selection (Invoke-PoshQCParallelTest, workers=2, wall-clock 144.12s, exit code 0): 61 tests, 0 failures, 0 errors; PRC-READ-COLLECTS-INPUT and the three new cases PRC-READ-FALLBACK-MOVED-TEMPLATE, PRC-READ-FALLBACK-LEDGER-ROOT and PRC-READ-FALLBACK-BOTH-ABSENT passed; ProcessReductionChain.Ledger.Tests.ps1 passed unchanged.

Changed files: scripts/dev-tools/ProcessReductionChain.psm1 (internal function Resolve-ProcessReductionLivePath; Read-ProcessReductionChainInput reads the ledger root and each live path through it; LiveText keys and the LedgerPath default unchanged; 638 lines); tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1 (three cases; 624 lines).
Selection rule: the mirrored test file of the changed module plus every test file that names it (git grep ProcessReductionChain over tests and extensions/drm-copilot/test): ProcessReductionChain.Tests.ps1 and ProcessReductionChain.Ledger.Tests.ps1.
