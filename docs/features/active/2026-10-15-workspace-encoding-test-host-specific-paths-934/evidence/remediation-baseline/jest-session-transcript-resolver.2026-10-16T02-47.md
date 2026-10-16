# Baseline STR-TEST Jest Run (P0-T16, Issue #934, remediation cycle 1)

Timestamp: 2026-10-16T02-47
Command: npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/session-transcript-resolver.test.ts   (working directory: extensions/drm-copilot; output redirected to SCRATCH/issue-934/jest-str-rem-baseline.log)
EXIT_CODE: 0
Output Summary:
- First run printed only the summary block: `Test Suites: 1 passed, 1 total`; `Tests:       12 passed, 12 total`; `Snapshots:   0 total`; `Ran all test suites within paths "test/lib/subagent-tree/session-transcript-resolver.test.ts".` No per-test title lines.
- Command: `npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/session-transcript-resolver.test.ts --json --outputFile=../../SCRATCH/issue-934/jest-str-rem-baseline.json` -> EXIT_CODE: 0; stdout `Tests:       12 passed, 12 total`; JSON file written to `SCRATCH/issue-934/jest-str-rem-baseline.json`.
- From the JSON file (Grep tool, content mode, `-o`, pattern `"num(Passed|Total|Failed)Tests":[0-9]+`): `numFailedTests` 0, `numPassedTests` 12, `numTotalTests` 12.
- Baseline title list from the JSON file (Grep tool, content mode, `-o`, pattern `"fullName":"[^"]*"`), 12 entries in execution order (count equals `numTotalTests`):
  1. resolveSessionTranscriptPath — validation rejects a malformed session id (forward-slash separator) naming the rule and never touches the filesystem
  2. resolveSessionTranscriptPath — validation rejects a malformed session id (backslash separator) naming the rule and never touches the filesystem
  3. resolveSessionTranscriptPath — validation rejects a malformed session id (dot-dot traversal) naming the rule and never touches the filesystem
  4. resolveSessionTranscriptPath — validation rejects a malformed session id (empty string) naming the rule and never touches the filesystem
  5. resolveSessionTranscriptPath — validation rejects a malformed session id (over-length (65 chars)) naming the rule and never touches the filesystem
  6. resolveSessionTranscriptPath — validation rejects a malformed session id (under-length (7 chars)) naming the rule and never touches the filesystem
  7. resolveSessionTranscriptPath — validation rejects a malformed session id (out-of-charset underscore) naming the rule and never touches the filesystem
  8. resolveSessionTranscriptPath — resolution resolves the transcript in the exact-match encoded directory
  9. resolveSessionTranscriptPath — resolution resolves the transcript in a -wt- worktree sibling directory
  10. resolveSessionTranscriptPath — resolution matches encoded directories case-insensitively
  11. resolveSessionTranscriptPath — resolution returns the first matching directory deterministically when several contain the transcript
  12. resolveSessionTranscriptPath — resolution throws a not-found error naming the searched directories for a valid but unknown id
- The JSON `name` field (absolute test-file path) is not copied into this artifact (redaction rule item 1).
