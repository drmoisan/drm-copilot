# End-to-end suite runtime before the cycle 1 change ([P0-T1])

Timestamp: 2026-11-07T22-42
Command: sh SCRATCH/issue-1038-suite-time.sh issue-1038-suite-time-before.txt (PowerShell 7 reads the root `tests` attribute and the per-file `time` attribute of the `testsuite` elements from the existing merged artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: root tests=19341, which equals the final parallel run reviewed in code-review.2026-11-07T22-11.md, so the JUnit value applies. EndToEndDocumentationEstate.Tests.ps1 time 211.119 s over 10 test cases (one full scenario replay per test).

BEFORE-SECONDS: 211.119
SOURCE: junit
REPLAYS-BEFORE: 10

Reference per-file times from the same JUnit file:

- DocumentationEstateEpicTemplate.Tests.ps1: 0.388 s
- DocumentationEstateOnboarding.Tests.ps1: 0.702 s

Per-test times of EndToEndDocumentationEstate.Tests.ps1 (seconds):

| Test | Time |
|---|---|
| passes docs-complete at revision R1 after inventory, ledger and generation | 14.449 |
| fails docs-complete at revision R2 with exit code 1 | 19.493 |
| reports DOCS_LEDGER_MISSING_DISPOSITION with the new command's element identifier and declaration | 17.236 |
| reports DOCS_STALE_PAGE with the stale page path and the changed command's declaration | 16.707 |
| returns a receipt whose validation_result is fail | 16.729 |
| passes docs-complete at revision R2 after the ledger and page are fixed | 26.390 |
| records analysis_method scanner on every inventory snapshot element in every step | 26.984 |
| records analysis_method scanner on every ledger entry in every step | 28.124 |
| records no InvokeProcess call under -AnalysisMethod scanner | 30.411 |
| fails closed with DOCS_SNAPSHOT_UNPINNED when inventory ran without a revision | 14.252 |
