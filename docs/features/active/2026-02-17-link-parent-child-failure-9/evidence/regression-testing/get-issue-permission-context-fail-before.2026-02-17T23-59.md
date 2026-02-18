Timestamp: 2026-02-18T01:20:17Z
Command: Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -FullNameFilter '*permission/repo-context failure messaging*'
EXIT_CODE: 1
Failure: Expected message like '*child*#321*access*repository*', but actual was 'Unable to fetch child issue #321. Check the number and gh auth.'.
