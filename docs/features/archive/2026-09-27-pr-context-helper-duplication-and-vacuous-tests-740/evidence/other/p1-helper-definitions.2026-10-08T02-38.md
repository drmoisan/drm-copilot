# Helper Definitions After Consolidation (P1-T20)

Timestamp: 2026-10-08T02-38
Command: git grep -n -E "function (sortedSet|relativeToPosix|escapeRegExp|splitLines)\(" -- extensions/drm-copilot/src/lib/pr-context
EXIT_CODE: 0
Output Summary: PASS. Exactly 4 output lines (P0-T17 recorded 12): sortedSet, escapeRegExp, splitLines in models.ts and relativeToPosix in feature-docs-parsers.ts; each line contains `export function`.

```
extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:305:export function relativeToPosix(root: string, path: string): string {
extensions/drm-copilot/src/lib/pr-context/models.ts:226:export function splitLines(value: string): string[] {
extensions/drm-copilot/src/lib/pr-context/models.ts:378:export function sortedSet(values: Iterable<string>): string[] {
extensions/drm-copilot/src/lib/pr-context/models.ts:389:export function escapeRegExp(value: string): string {
```
