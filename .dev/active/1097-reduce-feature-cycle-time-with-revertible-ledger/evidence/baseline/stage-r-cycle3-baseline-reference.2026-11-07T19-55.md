# Stage R Cycle 3 Baseline Reference (Phase 0 baseline read from artifacts)

Timestamp: 2026-11-07T19-55
Command: read the greatest stage-r-powershell-test-baseline.*.md, stage-r-python-test-baseline.*.md, stage-r-powershell-static.*.md, and stage-r-cycle2-baseline-reference.*.md under evidence/baseline/; no suite was run
EXIT_CODE: 0
Output Summary:
  PowerShell test baseline (stage-r-powershell-test-baseline.2026-11-07T18-01.md): one Invoke-PoshQCParallelTest run, 15675 tests, 15665 passed, 0 failed, 10 disabled; repo-wide line coverage 94.01% (24050 of 25582 lines); scripts/dev-tools/ProcessReductionLedger.psm1 100% (195 of 195).
  Python test baseline (stage-r-python-test-baseline.2026-11-07T18-06.md): one pytest -n auto run with --cov --cov-branch, 16204 passed, 0 failed, 6 skipped; total line coverage 96.99% (32451 of 33459); total branch coverage 94.17% (11826 of 12558, summed BRF/BRH of artifacts/python/lcov.info).
  PowerShell static baseline (stage-r-powershell-static.2026-11-07T17-53.md): the four ProcessReductionLedger files already formatted (Formatted: 0 each); analyzer findings 0.
  Chain files (stage-r-cycle2-baseline-reference.2026-11-07T19-21.md): ProcessReductionChain.psm1, ProcessReductionChain.Tests.ps1, and ProcessReductionChain.Ledger.Tests.ps1 already formatted, analyzer findings 0 each; ProcessReductionChain.psm1 line coverage 99.5% (201 of 202 lines); ProcessReductionChain suites 39 + 4 tests, 0 failures.
  Git-level chain gate (stage-r-cycle2-baseline-reference.2026-11-07T19-21.md, from stage-r-patch-chain-gate.2026-11-07T18-26.md): 0006 and 0001 git apply -R --cached --check exit 0; full chain IsValid True, 0 errors; end-state comparison equal 119, attributed 18, unattributed 0.
  No suite was run for this artifact; every figure is read from the named artifacts.
