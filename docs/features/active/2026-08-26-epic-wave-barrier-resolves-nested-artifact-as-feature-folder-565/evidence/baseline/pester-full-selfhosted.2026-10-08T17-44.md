# Baseline Full Pester Suite with Coverage (self-hosted)

Timestamp: 2026-10-08T17-44
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P0-T19.ps1 (run_in_background; started 2026-10-08T17-44-52, finished 2026-10-08T17-53-19)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: Tests Passed: 6522, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0. Covered 84.33% / 0%. 21,894 analyzed Commands in 174 Files. Exit code 2 equals the failed-test count, so no block or container failure contributed.

Console lines:

```
Tests Passed: 6522, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 84.33% / 0%. 21,894 analyzed Commands in 174 Files.
```

Failing tests (console `[-]` lines, pre-existing; none in the plan write set):

```
[-] enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
[-] Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Coverage file: `artifacts/pester/powershell-coverage.xml` last written 2026-10-08 17:50:59 local, after the 17:44:52 start; `artifacts/pester/pester-junit.xml` last written 17:51:35.
