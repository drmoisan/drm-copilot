# run-jest.cjs Diff vs Base — Inline Prohibited-Flag Guard

Timestamp: 2026-07-26T01-05

Task: [P2-T3]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC8 (review evidence)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `git diff fb483b84 -- run-jest.cjs extensions/drm-copilot/run-jest.cjs`
EXIT_CODE: 0

## Full Diff

```diff
diff --git a/extensions/drm-copilot/run-jest.cjs b/extensions/drm-copilot/run-jest.cjs
index b3e8267a..e2d96771 100644
--- a/extensions/drm-copilot/run-jest.cjs
+++ b/extensions/drm-copilot/run-jest.cjs
@@ -1,5 +1,23 @@
 const cp = require("node:child_process");
 
+// Prohibited-flag guard (issue #423). These are the flags on Jest's `exitWith0`
+// path (`passWithNoTests || lastCommit || onlyChanged`); any of them converts
+// zero discovered tests into a green run, which would mask a test-discovery
+// defect. Reject them before Jest is spawned so no run can ever be silently
+// empty. Kept inline and exact-match, matching the `--testPathPattern` rewrite
+// style below.
+const PROHIBITED_FLAGS = ["--passWithNoTests", "--onlyChanged", "--lastCommit"];
+
+const rawArgs = process.argv.slice(2);
+const prohibitedFlag = rawArgs.find((arg) => PROHIBITED_FLAGS.includes(arg));
+
+if (prohibitedFlag !== undefined) {
+  console.error(
+    `${prohibitedFlag} is prohibited in this repository: zero discovered tests must fail (issue #423).`,
+  );
+  process.exit(1);
+}
+
 const rewrittenArgs = process.argv
   .slice(2)
   .map((arg) => (arg === "--testPathPattern" ? "--testPathPatterns" : arg));
diff --git a/run-jest.cjs b/run-jest.cjs
index 101ffb1c..00af9c73 100644
--- a/run-jest.cjs
+++ b/run-jest.cjs
@@ -1,5 +1,23 @@
 const { runNodeTool } = require("./run-node-tool.cjs");
 
+// Prohibited-flag guard (issue #423). These are the flags on Jest's `exitWith0`
+// path (`passWithNoTests || lastCommit || onlyChanged`); any of them converts
+// zero discovered tests into a green run, which would mask a test-discovery
+// defect. Reject them before Jest is spawned so no run can ever be silently
+// empty. Kept inline and exact-match, matching the `--testPathPattern` rewrite
+// style below.
+const PROHIBITED_FLAGS = ["--passWithNoTests", "--onlyChanged", "--lastCommit"];
+
+const rawArgs = process.argv.slice(2);
+const prohibitedFlag = rawArgs.find((arg) => PROHIBITED_FLAGS.includes(arg));
+
+if (prohibitedFlag !== undefined) {
+  console.error(
+    `${prohibitedFlag} is prohibited in this repository: zero discovered tests must fail (issue #423).`,
+  );
+  process.exit(1);
+}
+
 const rewrittenArgs = process.argv
   .slice(2)
   .map((arg) => (arg === "--testPathPattern" ? "--testPathPatterns" : arg));
```

## AC8 Review Checklist

| Requirement | Verdict | Evidence in diff |
|---|---|---|
| Guard is inline in each file (no new helper module created) | PASS | Both hunks are additions inside the existing `run-jest.cjs` files. The diff contains no new-file hunk (`new file mode`) and touches only the two named paths. No module is `require`d by the guard. |
| Guard executes before Jest is spawned | PASS | In the root file the guard's `process.exit(1)` precedes the `runNodeTool("jest/bin/jest", ...)` call. In the extension file it precedes `cp.spawnSync(...)` and even precedes `require.resolve("jest/bin/jest")`. |
| Guard covers all three flags | PASS | `PROHIBITED_FLAGS = ["--passWithNoTests", "--onlyChanged", "--lastCommit"]` in both files. |
| Message names the flag and cites issue #423 | PASS | Template literal interpolates `${prohibitedFlag}`; the literal text ends `(issue #423).` |
| `--testPathPattern` → `--testPathPatterns` rewrite unchanged | PASS | The three `rewrittenArgs` lines appear as unchanged context (leading space) in both hunks — zero `-`/`+` markers on them. |
| Exit-code propagation unchanged | PASS | Neither hunk touches the tail of either file. Root retains `process.exit(runNodeTool(...))`; extension retains `if (result.error) { ... process.exit(1); }` and `process.exit(result.status ?? 1)`. All are outside the diff hunks entirely. |
| No other behavior change for non-rejected arguments | PASS | The guard is a read-only `Array.prototype.find` over `process.argv.slice(2)`. When no prohibited flag is present, `prohibitedFlag` is `undefined`, the `if` block is skipped, and control reaches the pre-existing code path unmodified. `rewrittenArgs` is still computed from `process.argv` exactly as before (the guard's `rawArgs` is a separate local and is not fed into the rewrite). |

## Diff Scope

Two files changed, both in-scope. 18 lines added per file, 0 lines removed, 0 lines modified. No new
files created by this phase. No forbidden file appears in the diff.

Output Summary: PASS. The diff shows only the inline guard additions in the two `run-jest.cjs` entry
points — 18 added lines each, zero removals. No new helper module was created, the
`--testPathPattern` rewrite lines appear as unchanged context, and the exit-code propagation code is
untouched (outside both hunks). AC8 review evidence satisfied.
