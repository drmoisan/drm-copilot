# Ledger Check

Timestamp: 2026-11-07T06-25
Command: pwsh -NoProfile -File SCRATCH/issue-1094-ledger-check.ps1 -Mode Committed
EXIT_CODE: 0
Output Summary:

- Item 1 checker: IsValid True, Errors 0, RowCount 1
- Item 2 index agreement: title, date, and issue cells equal the entry (Parallel-only test gates; 2026-11-07; #1094)
- Item 3 patch: git apply -R --check exit 0 on the committed patch; 238 patch paths equal the 238 reduction paths, and each is listed in ## Files Changed
- Item 4 blocks: 4 blocks replay, each Current once in the live file and each Prior once at the merge base; 5 brief copies and 3 atomic-plan-contract bundle copies match by hash
- Item 5 commit: subject 'docs(process-reductions): record parallel-only test gates (#1094), reduction: 0001' holds exactly the entry, the patch, and the README; token commits 1
