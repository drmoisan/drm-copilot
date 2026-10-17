# Jest Baseline: workspace-encoding.test.ts (P0-T16, Issue #934)

Timestamp: 2026-10-16T00-19
Command: npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts   (working directory: extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 1 passed, 1 total`
- `Tests:       9 passed, 9 total`
- Observed test count (AC-3 baseline): 9.
- Title-list capture note: in this agent environment (`CLAUDECODE`/`AI_AGENT` set) Jest prints only the summary block and omits the `--verbose` per-test lines. The title list below was read from a supplementary run of the same command with `--json --outputFile=../../SCRATCH/issue-934/jest-we-baseline.json` appended (EXIT_CODE 0, `numPassedTests` 9, `numTotalTests` 9).
- Passing test titles (full names, durations removed):
  1. encodeWorkspacePath replaces backslashes, forward slashes, and colons with hyphens
  2. encodeWorkspacePath encodes a forward-slash workspace path identically to a backslash one
  3. matchEncodedDirectories matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name
  4. matchEncodedDirectories includes a per-worktree sibling folder among the matched candidate directories
  5. matchEncodedDirectories includes a nested worktree-of-a-worktree sibling folder
  6. matchEncodedDirectories returns an empty array when no directory name matches
  7. matchEncodedDirectories matches a new-scheme nested worktree sibling encoded name
  8. matchEncodedDirectories matches a new-scheme worktree-of-a-worktree encoded name
  9. matchEncodedDirectories matches by exact equality when the workspace root is the nested leaf
