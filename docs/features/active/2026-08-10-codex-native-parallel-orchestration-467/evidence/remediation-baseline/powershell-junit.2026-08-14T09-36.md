# PowerShell JUnit Baseline Receipt

Timestamp: 2026-08-14T23-25
Command: Hash `artifacts/pester/pester-junit.xml` with `Get-FileHash -Algorithm SHA256` and parse its existing XML root attributes and testcase result nodes without rerunning Pester.
EXIT_CODE: 0
Output Summary: The existing Pester JUnit report contains 2,456 tests: 2,447 passed, 9 disabled, 0 failures, and 0 errors.

- SHA-256: `7440CB81144BE1EDC1F0527FCE094ADCB4D74DAA0899C34E20C78A4A9B7EC8BB`
- Total: `2,456`
- Passed: `2,447`
- Disabled: `9`
- Failures: `0`
- Errors: `0`
- Parsed `testcase` nodes: `2,456`
- Parsed `skipped` nodes: `9`
