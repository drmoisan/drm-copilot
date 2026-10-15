# Regression: subagent-tree command tests after the split ([P5-T4], AC-13)

Timestamp: 2026-10-09T21-26
Command: npm run test:unit -- subagent-tree-command (run from extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: `Test Suites: 2 passed, 2 total`; `Tests:       14 passed, 14 total`. Baseline ([P0-T20]): 1 suite, 14 tests.

```
> drm-copilot@1.0.0 test:unit
> node run-jest.cjs subagent-tree-command
Test Suites: 2 passed, 2 total
Tests:       14 passed, 14 total
```

## Block 2

Command: grep -h -E "^\s+it\(" extensions/drm-copilot/test/subagent-tree-command.test.ts extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts (run from the repository root)
EXIT_CODE: 0
Output Summary: 14 lines; the first ten from the kept file, the last four from the quick-pick file. The sorted output equals the sorted 14 [P0-T21] lines with the `N:` prefix removed (mechanical check: `sort` of both lists followed by `diff` printed nothing; both lists have 14 lines).

```
  it("resolves candidates from the user-global Claude projects directory rather than the workspace root", async () => {
  it("auto-selects a single discovered root session without prompting", async () => {
  it("prompts via showQuickPick among multiple candidates and renders the one selected", async () => {
  it("excludes flattened /subagents/ transcripts from candidates", async () => {
  it("names the real resolved user-global search location in the zero-candidates error message", async () => {
  it("writes the header plus full formatTree output to the terminal seam and reveals it", async () => {
  it("writes a multi-line formatTree body (root plus a subagent child) to the terminal seam", async () => {
  it("reuses the same terminal-writer instance across two consecutive invocations", async () => {
  it("routes a discovery failure to the error path and does not write to the terminal seam", async () => {
  it("routes a user-cancel selection to the output log and does not write to the terminal seam", async () => {
  it("shows quick-pick entries ordered most-recent-first with formatted timestamp labels and matchOnDetail", async () => {
  it("maps the selected quick-pick entry back to its full transcript path", async () => {
  it("auto-selects a single candidate without prompting even when a FileTimes is injected", async () => {
  it("keeps the prompt working when one candidate's mtime is unreadable, sorting it last as 'unknown'", async () => {
```

Acceptance (AC-13): first block exit 0 with 2 suites and 14 tests passed; second block 14 lines, sorted-equal to the baseline, ordered kept-file then quick-pick file. PASS.
