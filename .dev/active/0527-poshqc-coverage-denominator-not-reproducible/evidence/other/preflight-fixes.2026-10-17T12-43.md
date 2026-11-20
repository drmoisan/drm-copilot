# Preflight Fixes

Timestamp: 2026-10-17T12-43
Plan: docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-10-17T08-20.md

1. P5-T1, P5-T2, P5-T3, P5-T4, P5-T5 | hyphen-leading grep pattern without -e | Added `-e` before each `'- [x] ...'` and `'- [ ] ...'` pattern. Without `-e`, grep reads the pattern as an option and errors, so the stated count of 1 could not be produced.
2. Scratch Helper Contracts, H3 | relative OutputPath against current directory | Stated that H3 resolves the shipped relative `TestResult.OutputPath` and `CodeCoverage.OutputPath` against the Root, as `Invoke-PoshQCTest` does, so output location does not depend on the current directory.
3. Scratch Helper Contracts, H3 | ORDER_MATCH comparison basis | Stated that testsuite names are reduced to leaf file names, because Pester writes the absolute file path as the testsuite name (observed in the local `artifacts/pester/pester-junit.xml`), so a comparison with the leaf-name ORDER would otherwise never match.
4. P3-T5 | ambiguous search target | Stated that both searches (`SAMPLE_PRESENT=0` and `ExpectedExitCode: 1`) run against `fail-first-fixture-check.2026-10-02T07-55.md`. The companion run artifact contains no `ExpectedExitCode: 1` line, so applying the second search to it returns 0.
5. Files Written | missing artifact | Added this preflight fix record.
