# Coverage XML Copy Baseline (P0-T26)

Timestamp: 2026-10-16T01-06

Command: sh SCRATCH/issue-929/P0-T26-1.sh
Script: `Copy-Item -LiteralPath artifacts/pester/powershell-coverage.xml -Destination SCRATCH/issue-929/powershell-coverage.baseline.xml -Force; 'SOURCE_SHA256=' + (Get-FileHash -Algorithm SHA256 -LiteralPath artifacts/pester/powershell-coverage.xml).Hash; 'COPY_SHA256=' + (Get-FileHash -Algorithm SHA256 -LiteralPath SCRATCH/issue-929/powershell-coverage.baseline.xml).Hash`
EXIT_CODE: 0
Output:
```
SOURCE_SHA256=B1AAF5FCCCF7EB5C5230B0741BDE7F2E99B3B79F3F53F9323EF468BE59542FC1
COPY_SHA256=B1AAF5FCCCF7EB5C5230B0741BDE7F2E99B3B79F3F53F9323EF468BE59542FC1
```

Output Summary: the two SHA-256 values are equal. Baseline coverage XML copied to `SCRATCH/issue-929/powershell-coverage.baseline.xml` (the plan's `SCRATCH/929/` location, mapped to `SCRATCH/issue-929/` per the delegation directive).
