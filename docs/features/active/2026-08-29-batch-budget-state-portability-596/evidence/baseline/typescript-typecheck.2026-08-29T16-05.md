# [P0-T15] TypeScript type-check baseline (tsc `--noEmit`)

Timestamp: 2026-08-29T20-51

Command: `cd extensions/drm-copilot && npx tsc -p ./ --noEmit`

EXIT_CODE: 0

Output Summary: The compiler exited 0 and produced no output at all. It printed no diagnostic line
and no `Found N errors` summary, establishing zero type errors across the project referenced by
`extensions/drm-copilot/tsconfig.json`. The TypeScript type-check baseline is clean.

## Observed output

The command produced no output on either stream. The complete captured output was empty.

## Zero-error establishment

`tsc` reports type errors in two forms: one or more diagnostic lines of the shape
`<file>(<line>,<col>): error TSxxxx: <message>`, and a trailing `Found N errors` summary when errors
are present. Neither form appears in this run's output. The absence of both, combined with the exit
code of 0, establishes zero type errors.

The compiler that ran is the locally pinned one: [P0-T2] recorded `Version 6.0.3` from
`cd extensions/drm-copilot && npx tsc --version` in this same worktree, and [P0-T1] confirmed the
local binary exists at `extensions/drm-copilot/node_modules/.bin/tsc`, so this check measured the
pinned compiler rather than a silently fetched package.

## Observed-state clause

The observed-state clause was **not** triggered. The command exited 0, so no `ExpectedExitCode:` is
recorded (an absent expectation defaults to 0) and the `BLOCKED: TypeScript baseline not clean`
branch does not apply.

[P4-T1], [P5-T3], and [P7-T9] each run the identical command and assert the identical condition, so
the comparison against this baseline is direct.
