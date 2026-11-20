# Test-Hygiene Scan (issue #997)

Timestamp: 2026-10-29T16-40
Command: plain grep over tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1, enforce-epic-merge-gate.GreenCiDecision.Tests.ps1, enforce-epic-merge-gate.GreenCiRegression.Tests.ps1, and the C9 row of hook-dependency-failure.SpecialCases.Tests.ps1 (the new suites are untracked, so plain grep is used)
EXIT_CODE: 0
Output Summary: zero matches for every pattern.

| Pattern | Matches |
| --- | --- |
| `New-TemporaryFile` | 0 |
| `GetTempFileName` | 0 |
| `TestDrive` | 0 |
| `Start-Process` | 0 |
| `Set-Content` | 0 |
| `Out-File` | 0 |
| a line that invokes `gh` directly (line starting with `gh` or `& gh`) | 0 |
| drive-letter path literal (letter, colon, slash or backslash), excluding `https://` URL literals | 0 |
| backslash inside a single-quoted literal | 0 |
| C9 row: any of the patterns above | 0 |

Note: the unfiltered drive-letter pattern matched two lines, both the `https:` scheme of URL literals (a `/pull/` URL selector command and a `pr_url` fixture value); neither is a filesystem path. Fixture roots use `/synthetic-worktrees/<name>` built with `Join-Path`, and `gh` appears only inside command-text string literals passed to the gate.
