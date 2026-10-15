# Final full PowerShell suite with coverage (plan [P12-T5], issue #905)

Timestamp: 2026-10-11T23-57
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-full.ps1 (Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root <WORKSPACE_ROOT>), then <SCRATCHPAD>/r-junit.ps1
EXIT_CODE: 0
Output Summary: loop pass 2. Tests Passed: 9977, Failed: 0, Skipped: 10, NotRun: 0 (647.5s). JUNIT: tests=9987 failures=0 errors=0 skipped=10. Pester coverage headline: `Covered 88.28% / 0%. 25,988 analyzed Commands in 198 Files.` No `FAILED-TESTCASE:` line (BASELINE-FAILED-SET from [P0-T24] is empty, so the subset condition holds trivially). The reports were copied to the scratchpad immediately after r-junit:

COPY-SHA256: <SCRATCHPAD>/final-pester-junit.xml | 5779F4CAA13A19285BD78F71DC133BE71339993656C4945B194DEB5718119C71
COPY-SHA256: <SCRATCHPAD>/final-powershell-coverage.xml | C76CEB4E2F09054AD3E0A33A00369FCB2877C61A870E49B8203765C503421C58

Each copy hash equals the SHA256 of its source at copy time (SOURCE-SHA256 lines below).

```text
Tests completed in 647.5s
Tests Passed: 9977, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 88.28% / 0%. 25,988 analyzed Commands in 198 Files.
```

```text
JUNIT: tests=9987 failures=0 errors=0 skipped=10
```

```text
COPY-SHA256: <SCRATCHPAD>/final-pester-junit.xml | 5779F4CAA13A19285BD78F71DC133BE71339993656C4945B194DEB5718119C71
SOURCE-SHA256: artifacts/pester/pester-junit.xml | 5779F4CAA13A19285BD78F71DC133BE71339993656C4945B194DEB5718119C71 | equal
COPY-SHA256: <SCRATCHPAD>/final-powershell-coverage.xml | C76CEB4E2F09054AD3E0A33A00369FCB2877C61A870E49B8203765C503421C58
SOURCE-SHA256: artifacts/pester/powershell-coverage.xml | C76CEB4E2F09054AD3E0A33A00369FCB2877C61A870E49B8203765C503421C58 | equal
```
