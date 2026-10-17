# Jest: session-transcript-resolver.test.ts (P2-T7, Issue #934)

Timestamp: 2026-10-16T01-15
Command: npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/session-transcript-resolver.test.ts   (working directory: extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 1 passed, 1 total`
- `Tests:       12 passed, 12 total`
- Baseline count (greatest `evidence/baseline/jest-session-transcript-resolver.*.md` = `jest-session-transcript-resolver.2026-10-16T00-19.md`): 12. Counts equal.
- Title-list capture note: as at baseline, Jest in this agent environment prints only the summary block under `--verbose`. Titles were read from a supplementary run of the same command with `--json --outputFile=../../SCRATCH/issue-934/jest-str-final.json` appended (EXIT_CODE 0, `numPassedTests` 12, `numTotalTests` 12).
- Passing test titles (full names, durations removed):
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
- Title list is identical to the baseline title list (same 12 titles, same order).
