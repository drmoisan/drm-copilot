# npm Present-Version Probe — Positive Control (P0-T8)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `npm view @danmoisan/drm-copilot-mcp@1.1.0 version`

EXIT_CODE: 0

## Invocation Note

The logical command recorded in the `Command:` field above is what was executed. It was issued
through a `pwsh -NoProfile -Command` entry point because this executor's Bash allowlist does not
include `npm` directly. The wrapper does not mask the inner exit code: `$LASTEXITCODE` was read
immediately after the `npm` invocation and is what `EXIT_CODE:` records.

The query is read-only. It publishes nothing, consumes no version number, and mutates no registry
state.

## Observed Streams

- stdout line count: 1
- stderr line count: 0

stdout value, verbatim:

```
1.1.0
```

stderr produced no output.

Streams were separated by record type from a single invocation, using the same method as P0-T7, so
the two probes are directly comparable.

## Recorded Discrepancy — manifest version has moved since the plan was authored

The task text describes 1.1.0 as "the current published version per
`packages/mcp-server/package.json`". That parenthetical is now stale. Read at execution time,
`packages/mcp-server/package.json` declares:

- `name`: `@danmoisan/drm-copilot-mcp`
- `version`: `1.1.2`

The manifest advanced from 1.1.0 to 1.1.2 between plan authoring and execution. This does not
affect the task. The command operand is fixed by the plan at 1.1.0, that exact command was executed
verbatim, and 1.1.0 resolved successfully on the registry. The purpose of this task is a positive
control — demonstrating that an exact version that IS present returns exit code 0 and emits the
version string on stdout — and a published-but-no-longer-current version serves that purpose
exactly as well as the newest one. The discrepancy is recorded here rather than silently corrected,
because the parenthetical is descriptive text and the operand is the operative part of the task.

## Result

- Requested version: 1.1.0
- Returned version: 1.1.0
- Requested and returned values are equal.
- Exit code: 0

Output Summary: `npm view @danmoisan/drm-copilot-mcp@1.1.0 version` exited 0 and emitted `1.1.0` on
stdout with an empty stderr. This is the positive half of the registry behaviour the decisive
exact-version check depends on: a present exact version produces exit code 0 and echoes the exact
version string, which is what `Test-NpmVersionResolved` (P2-T2) requires for success alongside the
exit-code test. Together with the absent-version probe of P0-T7 (exit 1, empty stdout), this feeds
the decisiveness determination of P0-T9.
