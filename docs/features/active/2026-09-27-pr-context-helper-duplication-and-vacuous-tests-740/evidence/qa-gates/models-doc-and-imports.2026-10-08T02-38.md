# models.ts Documentation and gh-client-details.ts Imports (P2-T12, AC-1 JSDoc, AC-8, AC-9, AC-10)

Timestamp: 2026-10-08T02-38
Command: git grep -c -F "Supported terminators:" -- extensions/drm-copilot/src/lib/pr-context/models.ts ; git grep -c -F "a subset of the Python" -- extensions/drm-copilot/src/lib/pr-context/models.ts ; git grep -n -E "compareCodePoint|sortedSet|escapeRegExp|splitLines|type CommandResult" -- extensions/drm-copilot/src/lib/pr-context/models.ts ; git grep -c -F 'from "./models"' -- extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts ; git grep -n -B 15 -F "export function compareCodePoint(" -- extensions/drm-copilot/src/lib/pr-context/models.ts
EXIT_CODE: 0
Output Summary: PASS (loop pass 3). (1) count 1; (2) count 1 (AC-8). (3) Header-line condition PASS: splitLines and compareCodePoint appear on line 19, and sortedSet and escapeRegExp on line 20, all before the `type CommandResult` import on line 26 (AC-9). (4) count 1 (AC-10). (5) The JSDoc opens at line 344 (`/**`). "UTF-16 code units" is on line 348 and "U+E000..U+FFFF" is on line 349, both before the export line 355 (AC-1 JSDoc).

## Command 3 output

```
models.ts:19: *     - Provide the shared pure helpers `splitLines`, `compareCodePoint`,
models.ts:20: *       `sortedSet`, and `escapeRegExp` (issue #740), the single definitions
models.ts:26:import { type CommandResult } from "../subprocess-runner";
models.ts:226:export function splitLines(value: string): string[] {
models.ts:255:  const lines = splitLines(text);
models.ts:355:export function compareCodePoint(left: string, right: string): number {
models.ts:376: * @returns A new array of distinct values ordered by {@link compareCodePoint}.
models.ts:378:export function sortedSet(values: Iterable<string>): string[] {
models.ts:379:  return [...new Set(values)].sort(compareCodePoint);
models.ts:389:export function escapeRegExp(value: string): string {
```

## Command 4 output

```
extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts:1
```

## Command 5 output (lines 340-355)

```
models.ts-344-/**
models.ts-345- * Compare two strings by Unicode code point, matching Python `str` comparison.
models.ts-346- *
models.ts-347- * This differs from the JavaScript `<` operator, which compares
models.ts-348- * UTF-16 code units: a supplementary character (a surrogate pair) sorts
models.ts-349- * before a BMP character in U+E000..U+FFFF under `<`, but after it here.
models.ts-350- * The first differing UTF-16 code unit is located and the code points at
models.ts-351- * that index are compared; a proper prefix sorts first.
models.ts-352- *
models.ts-353- * @returns Exactly -1, 0, or 1.
models.ts-354- */
models.ts:355:export function compareCodePoint(left: string, right: string): number {
```
