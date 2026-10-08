# TypeScript Jest-Config Diagnostics Baseline (P0-T14)

Timestamp: 2026-10-07T21-52
Task: [P0-T14]
Command: npx tsc -p tsconfig.jest.json --noEmit  (cwd: extensions/drm-copilot)
ExpectedExitCode: 0
EXIT_CODE: 0
Output Summary: empty output; 0 diagnostics. Planning values were exit 2 with 792 diagnostics; observed values differ (deviation DEV-7).

## Diagnostic list

none

## Per-group counts (file, TS code, message text)

| File | TS code | Message | Count |
|---|---|---|---|
| (none) | - | - | 0 |

- `test/mcp-handlers/orchestration-handoff-handlers.test.ts`: 0 diagnostics (upstream typed the three `jest.fn` calls; DEV-2(b)).
- TS2740 in `test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts`: not present.

## Deviation DEV-7

Per the coordinator instruction, ExpectedExitCode is set to the observed P0-T14 exit code. The observed code is 0, not 2, so `ExpectedExitCode: 0` is recorded here and P7-T10 uses `ExpectedExitCode: 0`. The per-group no-increase comparison is unchanged; with an empty baseline, P7-T10 requires zero diagnostics.

Environment note: before `npm ci` installed the extension's locked dependencies, this command exited 2 with 568 output lines (missing type packages). That run is superseded by the run recorded above.
