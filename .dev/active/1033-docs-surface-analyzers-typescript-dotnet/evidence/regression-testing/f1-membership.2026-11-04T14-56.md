# F1 membership assertions - pass-after run ([P1-T3])

Timestamp: 2026-11-04T14-56
Command: sh SCRATCH/issue-1033-pester-files.sh with tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1, DocsInventorySnapshot.Tests.ps1, DocsInventoryProperties.Tests.ps1, DocsAnalyzerConfigFiles.Tests.ps1 (one `Invoke-Pester` process, `Run.PassThru`; counts from the result object)
EXIT_CODE: 0
Output Summary: Total=48, Passed=48, Failed=0, Skipped=0, failed containers 0. Fail-before run: `evidence/remediation-baseline/pester-coverage.2026-11-04T14-36.md` ([P0-T3]), where the two F1 tests failed on the exact five-entry analyzer list. CI: `poshqc / PowerShell QC`.

## Change

- `DocsInventory.Tests.ps1` `It 'exits 0 with a dry-run snapshot, no finding, no WriteText call, revision null and the fixed clock'`: the exact five-id list assertion is replaced with one `-ccontains` check per 1022 id (`config-files`, `python-architecture`, `python-cli`, `python-http`, `python-public-api`), each with a `-Because` naming the id, and a check that the id list equals its ordinal sort. Targeted run: 13 of 13 passed.
- `DocsInventorySnapshot.Tests.ps1` `It 'validates against surface-inventory-snapshot through Test-DocsArtifactText with no finding and carries the header fields'`: the exact five-entry `id:analysis_method:version` assertion is replaced with one `-ccontains` check per 1022 entry and `Test-TestOrdinalOrder` over the id list. Targeted run: 11 of 11 passed.
- No row count or exclusivity of the committed registry is asserted. Every other assertion in both tests is unchanged (diff against `CYCLE_HEAD`: one removed line per file, in the analyzer assertion region only).
