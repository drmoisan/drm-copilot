# Suite Duration Before the Fix - Issue 1019

Timestamp: 2026-11-06T17-49
Command: sh SCRATCH/issue-1019-before2.sh (SCRATCH/issue-1019-before.ps1 -Root SCRATCH/unfixed, then timeout 600 SCRATCH/issue-1019-fullsuite.ps1 -Root SCRATCH/unfixed); the run was delivered by the orchestrator, and this task recorded its output files without re-running it
EXIT_CODE: 124
ExpectedExitCode: 124
Output Summary: The full suite on the unfixed module did not finish within the 600 s bound (exit 124), so no full-suite duration or test counts exist; the measured result is a lower bound of 600 s. The suite without the token-limit test, under a filter that also skipped 12 other cases, ran in 2.29 s. The token-limit test is extrapolated to about 49530 s, not measured. Verbatim figures follow.

SCRATCH/before.txt, verbatim:

```text
token-limit shape: chars=525289 tokensScanned=1000 code=PYTHON_LEXER_UNCLASSIFIED elapsedMs=47236 msPerToken=47.236
extrapolated token-limit test, unfixed, no coverage: 524287 tokens x 47.236 ms x 2 calls = 49530 s
suite without the token-limit test: passed=16 failed=0 skipped=0 notrun=13 seconds=2.29
before exit 0
```

SCRATCH/before-full.txt, verbatim:

```text
2026-11-06T17:36:04Z
fullsuite exit 124 (124 means the 600 s bound was reached)
2026-11-06T17:46:05Z
```

## Figure Labels

| File | Figure | Label |
| --- | --- | --- |
| `SCRATCH/before.txt` | `chars=525289`, `tokensScanned=1000`, `code=PYTHON_LEXER_UNCLASSIFIED`, `elapsedMs=47236`, `msPerToken=47.236` | measured |
| `SCRATCH/before.txt` | `524287 tokens x 47.236 ms x 2 calls = 49530 s` | extrapolated |
| `SCRATCH/before.txt` | `passed=16 failed=0 skipped=0 notrun=13 seconds=2.29` | measured |
| `SCRATCH/before.txt` | `before exit 0` | measured |
| `SCRATCH/before-full.txt` | start `2026-11-06T17:36:04Z`, end `2026-11-06T17:46:05Z` | measured |
| `SCRATCH/before-full.txt` | `fullsuite exit 124` | measured |

## Scope of the Figures

- The `notrun=13` in the line labeled `suite without the token-limit test` covers the token-limit test plus the 12 `reports <Code> as a blocking error for: <Case>` cases its filter also skipped. The label therefore understates what that run left out: the 2.29 s covers 16 tests, not every test other than the token-limit test.
- The full-suite run was stopped by its bound and printed no `full suite:` line, so `SCRATCH/before-full.txt` holds no pass, fail, or duration figure for the suite.
- An earlier first run of the same before script used a filter that wrongly selected the token-limit test. The orchestrator stopped that run, and it produced no figures. None of the figures above come from it.
- Both delivered runs read `SCRATCH/unfixed`, with no coverage. Host load varied, so the absolute times are specific to this host.
- The call-cost and tokenizer-time tables are in `evidence/baseline/root-cause-profile.2026-11-06T17-25.md`.
