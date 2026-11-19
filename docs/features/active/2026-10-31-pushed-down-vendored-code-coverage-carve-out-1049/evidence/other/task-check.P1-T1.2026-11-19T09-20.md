# Task Check [P1-T1]

Timestamp: 2026-11-19T09-20
Command: sh SCRATCH/issue-1049-corpus-check.sh (od byte scan; node JSON parse)
EXIT_CODE: 0
Output Summary: Changed files: tests/fixtures/push-down-manifest-hash/corpus.json (new); evidence/other/corpus-digests.2026-11-19T09-19.md. Selection rule: a new JSON fixture selects the tests that read it; none exists until [P1-T2] and [P2-T5], which run it in their own task checks. No formatter, linter or type checker applies to the fixture (outside the extension Prettier scope). Check results: parses as JSON, 9 cases, CR_BYTES 0, HIGH_BYTES 0.
