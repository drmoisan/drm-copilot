# Post-Split File-Size Check (Remediation Cycle 2026-08-26T02-36)

Timestamp: 2026-08-26T03-19

Stamp substitution: the plan fixes the evidence filename stamp at `2026-08-26T02-36`; the `Timestamp:`
field records the actual execution stamp.

Command: `pwsh -NoProfile -Command 'Get-ChildItem -Path ./scripts/dev-tools/Invoke-ReleaseVerification.ps1, ./scripts/dev-tools/Invoke-ReleaseTagPush.ps1, ./scripts/dev-tools/Invoke-ReleaseReconciliation.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1, ./scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1, ./tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | ForEach-Object { $_.Name + " " + @(Get-Content -LiteralPath $_.FullName).Count }'`

EXIT_CODE: 0

Output Summary: one integer line count per path, all seven at or below the 500-line cap from
`.claude/rules/general-code-change.md`.

| Path | Lines | Under 500 |
|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 373 | yes |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | 278 | yes |
| `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | 166 | yes |
| `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` | 285 | yes |
| `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` | 491 | yes |
| `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` | 155 | yes |
| `tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1` | 111 | yes |

The maximum line count across the seven paths is 491, so every path is at most 500.

`scripts/dev-tools/Invoke-ReleaseVerification.ps1` fell from 499 lines to 373, a reduction of 126
lines: the extraction removed 133 source lines (the four function blocks plus their blank separators)
and the dot-source of the sibling plus its five-line explanatory comment added 7 back. The file now
carries 127 lines of headroom under the cap, which is what allows Phase 2 to add the six per-check
budget parameters and their comment-based help, and Phase 3 to add the `RUN_INCOMPLETE` token and its
help text.

`tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` fell from 346 lines to 285 as the six
relocated `It` blocks left it, giving 215 lines of headroom for the Phase 2 and Phase 3 regression
tests.
