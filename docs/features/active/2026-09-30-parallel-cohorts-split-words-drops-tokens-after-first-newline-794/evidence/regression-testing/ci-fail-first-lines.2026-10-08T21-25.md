# CI fail-first failing cases (P1-T10) [expect-fail]

Timestamp: 2026-10-09T07-06
Command: gh run view 37896730789 --json jobs --jq (check step conclusion) ; same for test step ; gh run view 37896730789 --log | awk (count of "not ok") ; awk (count of "not ok" with "separator-parity:") ; awk (the failing lines)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: check step `success`; test step `failure`; total `not ok` count 15 (= N0 0 + 15); `not ok` lines carrying `separator-parity:` count 15; all 15 failing lines listed below. Authoritative fail-before evidence for AC-9 together with ci-fail-first-run.

Check step conclusion: success
Test step conclusion: failure
Total `not ok` count: 15
`not ok` with `separator-parity:` count: 15

Failing lines (verbatim, CI log prefix omitted):
not ok 55 separator-parity: a newline-separated --keys value matches the single-line control
not ok 56 separator-parity: a newline-separated batching --keys value matches the single-line control
not ok 57 separator-parity: a newline-separated --edges value honors an edge after the first newline
not ok 58 separator-parity: newline-separated --keys and --edges together match the single-line control
not ok 59 separator-parity: a tab-separated value matches the single-line control
not ok 60 separator-parity: a CR-separated value matches the single-line control
not ok 61 separator-parity: a VT-separated value matches the single-line control
not ok 62 separator-parity: a FF-separated value matches the single-line control
not ok 63 separator-parity: a CRLF-terminated final token is kept
not ok 64 separator-parity: mixed separators with a trailing newline match the single-line control
not ok 65 separator-parity: whitespace-only and newline-only values yield the empty graph
not ok 66 separator-parity: a malformed token after a newline is rejected with exit 2
not ok 67 separator-parity: a duplicate key after a newline is rejected with the reference message
not ok 68 separator-parity: pcoh_split_words splits on every ASCII whitespace separator
not ok 69 separator-parity: the sourced library accepts multi-line keys and edges
