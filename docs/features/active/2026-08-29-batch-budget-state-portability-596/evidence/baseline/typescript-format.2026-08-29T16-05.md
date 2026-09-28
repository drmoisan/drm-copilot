# [P0-T13] TypeScript format baseline (Prettier `--check`)

Timestamp: 2026-08-29T20-47

Command: `cd extensions/drm-copilot && npx prettier --no-error-on-unmatched-pattern --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`

EXIT_CODE: 0

Output Summary: The read-only Prettier check passed with exit code 0. The complete output was the
two expected terminal lines and nothing else, matching the wording the plan pins verbatim. No
pre-existing TypeScript formatting drift exists, and none was repaired: this is the `--check`
invocation, which reports without writing.

## Verbatim output

```
Checking formatting...
All matched files use Prettier code style!
```

Both asserted lines are present verbatim:

- `Checking formatting...`
- `All matched files use Prettier code style!`

The complete output was those two lines and nothing else, matching the observation the plan records
against Prettier 3.9.6.

## Fallback clause

The fallback clause was **not** triggered. The installed Prettier printed exactly the pinned wording,
so no version query was required and no wording change needs to be reported to the orchestrator.
[P7-T7] can therefore assert the same two literals unchanged.

## Observed-state clause

The observed-state clause was **not** triggered. The command exited 0, so no `ExpectedExitCode:` is
recorded (an absent expectation defaults to 0) and the `BLOCKED: TypeScript baseline not clean`
branch does not apply. The TypeScript format baseline is clean.

## Read-only rationale

This is deliberately the `--check` form rather than `--write`. Using the write-mode form at baseline
would silently repair any pre-existing drift before the later gates run, which would turn [P7-T6] and
[P7-T7] into vacuous passes. The clean `--check` result recorded here establishes that the later
gates start from an already-clean format state.
