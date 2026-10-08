# models.test.ts Structure (P2-T11, AC-3, AC-4, AC-5)

Timestamp: 2026-10-08T02-38
Command: git grep -c -F "agrees with the native" -- extensions/drm-copilot/test/lib/pr-context/models.test.ts ; git grep -c -F "same order as native comparison" -- (same file) ; git grep -n -E "left < right|left > right" -- (same file) ; git grep -c -F "? -1 :" -- (same file) ; git grep -c -F "expect(violations).toEqual([])" -- (same file) ; git grep -n -A 12 -F "const DOMAIN = [" -- (same file)
EXIT_CODE: 0
Output Summary: PASS (loop pass 3). Commands 1-4 find no match (exit 1 each). Command 5 prints 2. In command 6, the lines from `const DOMAIN = [` through `];` include one line containing the escape form of U+E000 followed by a comma (line 190) and one line containing the escape form of U+FFFF followed by a comma (line 191).

| # | Command | Exit | Output |
| --- | --- | --- | --- |
| 1 | `git grep -c -F "agrees with the native"` | 1 | (none) |
| 2 | `git grep -c -F "same order as native comparison"` | 1 | (none) |
| 3 | `git grep -n -E "left < right\|left > right"` | 1 | (none) |
| 4 | `git grep -c -F "? -1 :"` | 1 | (none) |
| 5 | `git grep -c -F "expect(violations).toEqual([])"` | 0 | `models.test.ts:2` |
| 6 | `git grep -n -A 12 -F "const DOMAIN = ["` | 0 | lines 180-192, below |

Command 6 output (the lines for U+E000 and U+FFFF are written in the file as four-hex-digit JavaScript escapes; they are described here by code point because the authoring tool decodes such escapes):

```
models.test.ts:180:  const DOMAIN = [
models.test.ts-181-    "",
models.test.ts-182-    "a",
models.test.ts-183-    "A",
models.test.ts-184-    "aa",
models.test.ts-185-    "ab",
models.test.ts-186-    "b",
models.test.ts-187-    "ba",
models.test.ts-188-    (U+00E9, existing raw element),
models.test.ts-189-    (U+1F600, existing raw element),
models.test.ts-190-    (escape of U+E000, with a trailing comma),
models.test.ts-191-    (escape of U+FFFF, with a trailing comma),
models.test.ts-192-  ];
```

The escape forms on lines 190 and 191 were confirmed separately with `grep -n -F` for the backslash-u sequence, which listed `190:    "\` + `uE000",` and `191:    "\` + `uFFFF",` (split here only to keep the escape from being decoded).

## Read-based statement

From a read of the file: no remaining test computes its expected value with the string `<` or `>` operators. The antisymmetry and transitivity tests compare numeric comparator results (`!==`, `<= 0`, `> 0`) and collect a `violations` array. The code-point, sortedSet, escapeRegExp, and splitLines tests assert literal expected values.
