# [P7-T9] TypeScript type check (tsc) — final QA loop

Timestamp: 2026-08-29T22-43

Command: `cd extensions/drm-copilot && npx tsc -p ./ --noEmit`

Absolute prefix actually used:
`cd /c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/extensions/drm-copilot && npx tsc -p ./ --noEmit`

EXIT_CODE: 0

Output Summary: The compiler exited 0 and printed **no output at all**. It printed no diagnostic line
and no `Found N errors` summary, which establishes zero type errors across the project defined by
`extensions/drm-copilot/tsconfig.json`. Run in loop iteration **2**.

## Output, verbatim

The complete output of the run, with ANSI colour escapes stripped, was empty:

```
```

## What the empty output establishes

`tsc` reports each type error as a line of the form
`<file>(<line>,<col>): error TS<code>: <message>` and, when one or more errors are present, closes
with a `Found N errors` summary. Neither element was printed.

- **No diagnostic line** was printed.
- **No `Found N errors` summary** was printed.

Together with the zero exit code, this establishes zero type errors. `--noEmit` was used, so the
check produced no build output and the run is purely a verification.

## Compiler provenance

The compiler resolved is the one pinned by this repository's lockfile, at version **6.0.3**, as
established by [P0-T2] (`evidence/baseline/typescript-invocation-form.2026-08-29T16-05.md`) and
gated by the [P0-T1] dependency-tree check. That gate matters here: `npx` does not fail when a local
binary is missing, and `npx tsc` in particular falls through to an unrelated deprecated registry
package rather than the pinned compiler, so a run without that precondition could appear to succeed
while checking nothing.

## Comparison against the [P0-T15] baseline

| Run | EXIT_CODE | Diagnostic lines | `Found N errors` summary |
| --- | --- | --- | --- |
| [P0-T15] baseline | 0 | none | none |
| [P7-T9] final | 0 | none | none |

The result is unchanged from baseline. This feature's TypeScript changes introduced no type error.
