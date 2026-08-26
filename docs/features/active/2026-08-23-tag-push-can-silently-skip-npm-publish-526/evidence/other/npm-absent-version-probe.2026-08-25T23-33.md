# npm Absent-Version Probe (P0-T7)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `npm view @danmoisan/drm-copilot-mcp@1.0.25 version`

EXIT_CODE: 1

## Invocation Note

The logical command recorded in the `Command:` field above is what was executed. It was issued
through a `pwsh -NoProfile -Command` entry point because this executor's Bash allowlist does not
include `npm` directly. The wrapper does not mask the inner exit code: `$LASTEXITCODE` was read
immediately after the `npm` invocation and is what `EXIT_CODE:` records. The observed value is the
`npm` process exit code, not the wrapper's.

Version 1.0.25 is known absent from the registry per the issue report. The query is read-only. It
publishes nothing, consumes no version number, and mutates no registry state.

## Observed Streams

- stdout line count: 0 (stdout was empty)
- stderr line count: 8

First line of stdout, verbatim:

```
```

(stdout produced no output at all; the line count is 0.)

First line of stderr, verbatim:

```
npm error code E404
```

Full stderr as observed, recorded for completeness:

```
npm error code E404
npm error 404 No match found for version 1.0.25
npm error 404
npm error 404  The requested resource '@danmoisan/drm-copilot-mcp@1.0.25' could not be found or you do not have permission to access it.
npm error 404
npm error 404 Note that you can also install from a
npm error 404 tarball, folder, http url, or git url.
npm error A complete log of this run can be found in: C:\Users\DanMoisan\AppData\Local\npm-cache\_logs\2026-08-26T03_41_24_935Z-debug-0.log
```

Streams were separated by record type (`System.Management.Automation.ErrorRecord` versus not) from a
single invocation, so the split is exact rather than inferred.

## Determination

NPM_ABSENT_VERSION_EXIT_NONZERO: true

The observed exit code is 1, which is non-zero, so the determination is true.

Output Summary: `npm view @danmoisan/drm-copilot-mcp@1.0.25 version` exited 1 against the absent
version. stdout was empty; stderr reported `npm error code E404` and `No match found for version
1.0.25`. This confirms the negative half of the registry behaviour the decisive exact-version check
depends on: an absent exact version produces a non-zero exit and emits no version string on stdout.
Combined with the positive control of P0-T8, this feeds the decisiveness determination of P0-T9.
Exactly one determination line is carried above.
