# Gate — renderer boundary untouched (Invariant C, AC13)

Timestamp: 2026-08-20T09-53

Task: [P5-T5]

Command: git diff 71aebdb9a1e4752b191b3c9d4e677b807ea6fdec -- scripts/dev_tools/pr_context/collector.py extensions/drm-copilot/src/lib/pr-context/collector-output.ts
Command (region locations after the change): grep -n for the filter, the fallback string, the sort key, and the section heading in both renderers
EXIT_CODE: 0

## The complete diff over both renderers

Every changed line in both files is an ADDITION; the diff contains no deleted line.

Python (`scripts/dev_tools/pr_context/collector.py`), 4 added lines, 0 deleted:

```
@@ -153,6 +153,9 @@
+        # Show a declared expectation only when non-zero; other rows render as before.
+        expected = record.expected_exit_code
+        expected_rows = [f"  - Expected EXIT_CODE: {expected}"] if expected else []
@@ -160,6 +163,7 @@
+                *expected_rows,
```

TypeScript (`extensions/drm-copilot/src/lib/pr-context/collector-output.ts`), 5 added lines, 0 deleted:

```
@@ -113,12 +113,17 @@
+    // Show a declared expectation only when non-zero; other rows render as before.
+    const expected = record.expectedExitCode;
+    const expectedRows =
+      expected === 0 ? [] : [`  - Expected EXIT_CODE: ${String(expected)}`];
@@ ...
+      ...expectedRows,
```

## Zero changed lines in every named region

| Region | Location after the change | Changed lines |
| --- | --- | --- |
| Python record filter `{"pass", "fail"}` | `collector.py:148` | 0 |
| TypeScript record filter | `collector-output.ts:100` | 0 |
| Python fallback string | `collector.py:151` | 0 |
| TypeScript fallback string | `collector-output.ts:103` (and the doc comment at 62) | 0 |
| Python sort key `key=lambda item: item.source_file` | `collector.py:155` (context line in the diff) | 0 |
| TypeScript sort comparator | `collector-output.ts:107-113` (context lines in the diff) | 0 |
| Python section heading | `collector.py:517` | 0 |
| TypeScript section heading | `collector-output.ts:241` | 0 |

The filter line at `collector.py:148` still reads
`item for item in records if item.normalized_result in {"pass", "fail"}` and the TypeScript filter at
`collector-output.ts:100` still reads
`item.normalizedResult === "pass" || item.normalizedResult === "fail"`, so the result vocabulary
remains closed at three members and `unparseable` records continue to be dropped. The fallback string
`No canonical verification evidence parsed` is byte-identical in both files. Both section headings
still read `Verification evidence (feature docs + canonical artifacts)`. The baseline anchors named in
the plan (`collector.py:147-149`, `collector-output.ts:98-101`, `collector.py:513-514`,
`collector-output.ts:236-237`) shifted by the added lines above but their CONTENT is unchanged; the
line-number shift is a consequence of the additions, not an edit to those regions.

Output Summary: The diff over both renderers contains only additions — 4 added / 0 deleted in
`collector.py` and 5 added / 0 deleted in `collector-output.ts`. Zero changed lines appear in the
`{"pass", "fail"}` filter, the `No canonical verification evidence parsed` fallback, the sort key, or
either section heading. Invariant C holds: the result vocabulary is unchanged and neither collector
filter was widened.
