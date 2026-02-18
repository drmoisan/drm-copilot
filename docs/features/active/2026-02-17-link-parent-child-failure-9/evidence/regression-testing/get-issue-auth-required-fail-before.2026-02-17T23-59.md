Timestamp: 2026-02-18T01:20:17Z
Command: Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -FullNameFilter '*auth-required failure messaging*'
EXIT_CODE: 1
Failure: Expected message like '*child*#2*gh auth status*', but actual was 'Unable to fetch child issue #2. Check the number and gh auth.'.
