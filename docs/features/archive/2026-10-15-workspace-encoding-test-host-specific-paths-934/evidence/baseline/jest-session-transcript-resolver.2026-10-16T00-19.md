# Jest Baseline: session-transcript-resolver.test.ts (P0-T17, Issue #934)

Timestamp: 2026-10-16T00-19
Command: npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/session-transcript-resolver.test.ts   (working directory: extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 1 passed, 1 total`
- `Tests:       12 passed, 12 total`
- Observed test count (AC-3 baseline): 12 (7 `it.each` rows plus 5 `it` blocks).
- Title-list capture note: in this agent environment (`CLAUDECODE`/`AI_AGENT` set) Jest prints only the summary block and omits the `--verbose` per-test lines. The title list below was read from a supplementary run of the same command with `--json --outputFile=../../SCRATCH/issue-934/jest-str-baseline.json` appended (EXIT_CODE 0, `numPassedTests` 12, `numTotalTests` 12).
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
