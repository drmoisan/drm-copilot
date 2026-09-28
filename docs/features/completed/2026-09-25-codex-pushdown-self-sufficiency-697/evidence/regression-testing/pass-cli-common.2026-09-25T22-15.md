# Pass: codex-routing CLI Common Helper (Issue #697, AC-4.9 resolution cases)

Timestamp: 2026-09-25T22-15
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 0
Output Summary: `Tests Passed: 31, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. Includes the four candidate cases (first wins when both exist; second used when the first is missing; non-zero exit naming both candidates when none exists; destination-then-self-hosting order), 13 token-parser cases, and 11 serializer cases.
Note: a first run reported `Failed: 2` (the non-ASCII and astral serializer cases) because the file-writing tool had stored the expected `\u` escapes as decoded characters in the test data; the two expected strings were rebuilt with `[char]92` and the recorded run above followed. No production file changed between the two runs.
