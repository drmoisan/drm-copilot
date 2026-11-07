# Stage R Cycle 2 Baseline Reference (Phase 0 baseline read from artifacts)

Timestamp: 2026-11-07T19-21
Command: read the greatest stage-r-powershell-test-baseline.*.md, stage-r-powershell-static.*.md, stage-r-powershell-format-lint.*.md, stage-r-powershell-test.*.md, and stage-r-patch-chain-gate.*.md artifacts under evidence/baseline/, evidence/qa-gates/, and evidence/other/; no suite was run
EXIT_CODE: 0
Output Summary:
  Test baseline (stage-r-powershell-test-baseline.2026-11-07T18-01.md): 15675 tests, 15665 passed, 0 failed, 10 disabled; repo-wide PowerShell line coverage 94.01% (24050 of 25582 lines); scripts/dev-tools/ProcessReductionLedger.psm1 100% (195 of 195).
  Static state (stage-r-powershell-static.2026-11-07T17-53.md): the four ProcessReductionLedger files already formatted, analyzer findings 0.
  Chain file state (stage-r-powershell-format-lint.2026-11-07T18-27.md): ProcessReductionChain.psm1 and its two test files already formatted, analyzer findings 0 each.
  Chain file coverage (stage-r-powershell-test.2026-11-07T18-33.md): 15718 tests, 15708 passed, 0 failed, 10 disabled; repo-wide 94.05% (24251 of 25784); ProcessReductionChain.psm1 99.5% (201 of 202 lines; no earlier baseline run); ProcessReductionLedger.psm1 100% (195 of 195). ProcessReductionChain suites 39 + 4 tests, ProcessReductionLedger suites 72 + 15 + 4 tests, 0 failures.
  Git-level chain gate (stage-r-patch-chain-gate.2026-11-07T18-26.md): 0006 and 0001 git apply -R --cached --check both exit 0; full chain IsValid True with 0 errors; end-state comparison equal 119, attributed 18, unattributed 0.
  Python baseline: not owed, no Python file changes in this cycle.
