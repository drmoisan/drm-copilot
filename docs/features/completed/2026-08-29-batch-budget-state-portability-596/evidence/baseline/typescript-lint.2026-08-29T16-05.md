# [P0-T14] TypeScript lint baseline (ESLint)

Timestamp: 2026-08-29T20-49

Command: `cd extensions/drm-copilot && npx eslint --no-error-on-unmatched-pattern src test`

EXIT_CODE: 0

Output Summary: ESLint exited 0 and produced no output at all. It printed no per-file diagnostic
block and no problem-summary line, which together establish zero errors and zero warnings across
`src` and `test`. The TypeScript lint baseline is clean.

## Observed output

The command produced no output on either stream. The complete captured output was empty.

## Zero-count establishment

ESLint reports findings in two forms: a per-file diagnostic block listing each finding with its file,
line, column, severity, message, and rule id; and a trailing problem-summary line of the shape
`N problems (E errors, W warnings)`. Neither form appears in this run's output. The absence of both,
combined with the exit code of 0, establishes:

- Error count: 0
- Warning count: 0

## Observed-state clause

The observed-state clause was **not** triggered. The command exited 0, so no `ExpectedExitCode:` is
recorded (an absent expectation defaults to 0) and the `BLOCKED: TypeScript baseline not clean`
branch does not apply.

[P7-T8] runs the identical command and asserts the identical condition, so the comparison against
this baseline is direct.
