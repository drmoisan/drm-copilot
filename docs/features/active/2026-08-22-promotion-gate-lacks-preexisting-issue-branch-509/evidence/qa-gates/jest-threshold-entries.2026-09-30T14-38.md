# Jest Per-File Threshold Entries — P6-T3

Timestamp: 2026-09-30T14-38
Task: P6-T3
Working directory: worktree root

Edit: inside `coverageThreshold` in `extensions/drm-copilot/jest.config.cjs`, after the `"./src/lib/validate/orchestrator-state-core.ts"` entry, inserted a two-line comment naming issue #509 (it names neither file) followed by the `"./src/lib/validate/orchestrator-state-issue-adoption.ts"` and `"./src/lib/validate/orchestrator-state-routing.ts"` entries, each with `lines: 85,` and `branches: 75,`. No `global` key, `exclude`, or path-ignore entry was added.

## Step 1

Command: grep -n -F -A2 -e "orchestrator-state-issue-adoption.ts" extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary:
```
79:    "./src/lib/validate/orchestrator-state-issue-adoption.ts": {
80-      lines: 85,
81-      branches: 75,
```
Exactly three lines: the key line, `lines: 85,`, `branches: 75,`.

## Step 2

Command: grep -n -F -A2 -e "orchestrator-state-routing.ts" extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary:
```
83:    "./src/lib/validate/orchestrator-state-routing.ts": {
84-      lines: 85,
85-      branches: 75,
```
Exactly three lines: the key line, `lines: 85,`, `branches: 75,`.

Enforcement is the P8-T4 coverage run (no output line may contain the token `coverage threshold`).

Result: PASS
