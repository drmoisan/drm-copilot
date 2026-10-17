# ChecksWait Suite Size (Issue #931)

Timestamp: 2026-10-16T01-36
Command: wc -l tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
EXIT_CODE: 0
Output Summary: 297 lines (limit 500; baseline 141). The Grep tool finds exactly 19 lines matching `^\s+It "`: 6 existing tests plus 13 new tests. No condensing was needed.

## It-line inventory (Grep tool, pattern `^\s+It "`)

Existing (6): lines 15, 37, 59, 77, 95, 116.

New, Context `all-checks classification` (13):

| Line | Title | Task |
|---|---|---|
| 161 | polls gh pr checks without the required flag | P1-T16 (1) |
| 171 | returns failure when a non-required check fails | P1-T16 (2) |
| 182 | returns failure when a check is cancelled | P1-T16 (3) |
| 190 | keeps polling and times out on an empty check set | P1-T16 (4) |
| 200 | returns failure on an unrecognized bucket | P1-T17 (5) |
| 211 | returns failure on a check with no bucket property | P1-T17 (6) |
| 220 | reports a failed check ahead of an unrecognized bucket | P1-T17 (7) |
| 229 | returns success when buckets are a mix of pass and skipping | P1-T18 (8a) |
| 239 | returns success when every bucket is skipping | P1-T18 (8b) |
| 247 | returns failure without throwing on unparsable check output | P1-T18 (9) |
| 257 | continues after a non-zero completion poll | P1-T19 (10) |
| 271 | continues after an unparsable completion poll | P1-T19 (11) |
| 284 | times out when completion polls keep failing | P1-T19 (12) |

Each title occurs exactly once.

## Note on the P1-T15 count

P1-T15 expects `git grep -c -F -e "A check failed for PR #291"` to print `:1`. The line-110 edit and the P1-T16 and P1-T17 additions were applied in one pass, so the count was first observed after those additions and read `:3`. The three occurrences are line 110 (the P1-T15 edit), line 177 (P1-T16 test 2), and line 226 (P1-T17 test 7). Both added tests are required by their task text to assert this message. `git diff -U0 HEAD` shows that line 110 is the only pre-existing line changed. `git grep -c -F -e "A required check failed"` exits 1, so the old string is absent.

The Mocks for `Invoke-GhExe`, `Invoke-Sleep`, and `Write-StderrLine` in the new Context are registered once in the Context's `BeforeEach`. Each test supplies its responses through `$script:responses`. Pester 5 applies a `BeforeEach` mock to every `It` in the block, so each test runs with all three mocks in place.
