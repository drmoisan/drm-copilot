# Baseline: subagent-tree-command it( titles ([P0-T21])

Timestamp: 2026-10-09T21-03
Command: grep -n -E "^\s+it\(" extensions/drm-copilot/test/subagent-tree-command.test.ts (run from the repository root)
EXIT_CODE: 0
Output Summary: 14 lines printed at lines 162, 181, 197, 219, 239, 257, 278, 320, 349, 367, 388, 425, 445, 466 (matches the plan's expected line set exactly).

## Verbatim output

```
162:  it("resolves candidates from the user-global Claude projects directory rather than the workspace root", async () => {
181:  it("auto-selects a single discovered root session without prompting", async () => {
197:  it("prompts via showQuickPick among multiple candidates and renders the one selected", async () => {
219:  it("excludes flattened /subagents/ transcripts from candidates", async () => {
239:  it("names the real resolved user-global search location in the zero-candidates error message", async () => {
257:  it("writes the header plus full formatTree output to the terminal seam and reveals it", async () => {
278:  it("writes a multi-line formatTree body (root plus a subagent child) to the terminal seam", async () => {
320:  it("reuses the same terminal-writer instance across two consecutive invocations", async () => {
349:  it("routes a discovery failure to the error path and does not write to the terminal seam", async () => {
367:  it("routes a user-cancel selection to the output log and does not write to the terminal seam", async () => {
388:  it("shows quick-pick entries ordered most-recent-first with formatted timestamp labels and matchOnDetail", async () => {
425:  it("maps the selected quick-pick entry back to its full transcript path", async () => {
445:  it("auto-selects a single candidate without prompting even when a FileTimes is injected", async () => {
466:  it("keeps the prompt working when one candidate's mtime is unreadable, sorting it last as 'unknown'", async () => {
```
