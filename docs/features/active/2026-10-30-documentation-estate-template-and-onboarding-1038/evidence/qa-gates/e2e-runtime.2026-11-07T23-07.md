# End-to-end suite runtime comparison ([P4-T6])

Timestamp: 2026-11-07T23-07
Command: compare BEFORE-SECONDS of evidence/remediation-baseline/e2e-suite-time.2026-11-07T22-42.md with the EndToEndDocumentationEstate.Tests.ps1 per-file `time` in evidence/regression-testing/pester-coverage.2026-11-07T23-06.md (read by sh SCRATCH/issue-1038-pester-summary-c1.sh from the `testsuite` element of artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: the suite time fell from 211.119 s to 82.588 s, ratio 0.391 (39.1 percent of the before value), within the 60 percent limit. The scenario is replayed 4 times per file run instead of 10.

BEFORE-SECONDS: 211.119
AFTER-SECONDS: 82.588
RATIO: 0.391
REPLAYS-BEFORE: 10
REPLAYS-AFTER: 4
LIMIT: at most 60 percent of the before value (126.671 s)
RESULT: PASS

The per-test times after the change are 0.005 s to 0.029 s, because the replay now runs in each `Context` `BeforeAll`, which the JUnit report does not attribute to a test case; the per-file `time` includes it.
