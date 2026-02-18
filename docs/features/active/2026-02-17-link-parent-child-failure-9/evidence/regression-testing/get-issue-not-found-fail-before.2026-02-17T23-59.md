Timestamp: 2026-02-18T01:20:17Z
Command: Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -FullNameFilter '*not-found failure messaging*'
EXIT_CODE: 1
Failure: Expected message like '*parent*#999*verify*issue number*', but actual was 'Unable to fetch parent issue #999. Check the number and gh auth.'.
