# Helper Definitions (P2-T10, AC-6)

Timestamp: 2026-10-08T02-38
Command: git grep -n -E "function (sortedSet|relativeToPosix|escapeRegExp|splitLines)\(" -- extensions/drm-copilot/src/lib/pr-context ; git grep -n -E "(const|let|var) (sortedSet|relativeToPosix|escapeRegExp|splitLines)[ :=]" -- extensions/drm-copilot/src/lib/pr-context
EXIT_CODE: 0
Output Summary: PASS (loop pass 3). First command: exactly 4 lines, each containing `export function`: sortedSet, escapeRegExp, splitLines in models.ts and relativeToPosix in feature-docs-parsers.ts (P0-T17 recorded 12). Second command: no match (exit 1).

## Command 1 (exit 0)

```
extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:305:export function relativeToPosix(root: string, path: string): string {
extensions/drm-copilot/src/lib/pr-context/models.ts:226:export function splitLines(value: string): string[] {
extensions/drm-copilot/src/lib/pr-context/models.ts:378:export function sortedSet(values: Iterable<string>): string[] {
extensions/drm-copilot/src/lib/pr-context/models.ts:389:export function escapeRegExp(value: string): string {
```

## Command 2 (exit 1)

(no output)
