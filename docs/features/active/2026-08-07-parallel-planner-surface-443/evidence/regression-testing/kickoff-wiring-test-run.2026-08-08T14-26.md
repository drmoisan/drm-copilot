# Kickoff-Wiring Test Run — [P3-T10]

Timestamp: 2026-08-08T14-26

The [P3-T9] conditional split fired, so
`extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact-tables.test.ts`
is appended to the Jest invocation as [P3-T10] directs.

## Command 1 — Python wiring dispatch

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py -v`

EXIT_CODE: 0

Output Summary: 16 passed, 0 failed. Includes the two cases updated by
[P3-T2]: `test_validate_from_args_routes_parallel_kickoff_to_its_validator`
(positive dispatch to `validate_parallel_kickoff_text`) and
`test_validate_from_args_returns_unsupported_for_an_unknown_parallel_type`
(fallback preserved using the genuinely unregistered probe name
`parallel-status-doc`).

## Command 2 — TypeScript wiring and parity

Command: `node run-jest.cjs extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact.test.ts extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact-tables.test.ts extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts extensions/drm-copilot/test/mcp-tool-inputs-parallel-validation.test.ts extensions/drm-copilot/test/mcp-parallel-validation-definitions.test.ts extensions/drm-copilot/test/mcp-server-parallel-validation.test.ts`

EXIT_CODE: 0

Output Summary: 6 suites passed, 6 total; 92 tests passed, 92 total. The
command line begins `node run-jest.cjs` and contains no `npx jest`, so the
issue-#423 prohibited-flag guard and the pinned `--config jest.config.cjs`
both apply.

Measured subtotals from separate runs during execution, which reconcile with
the 92 reported for the combined run: the two new kickoff suites reported
`2 passed, 2 total` suites and `60 passed, 60 total` tests; the four
previously-landed suites updated by [P3-T8] reported `4 passed, 4 total` suites
and `32 passed, 32 total` tests. 60 + 32 = 92.

## Measured Line Counts — [P3-T9] Test Modules

Verdict: **[P3-T9] SPLIT FIRED.**

The combined single-module form of
`extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact.test.ts`
measured **572 lines**, at or over the 500-line test-file limit, so the
[P3-T9] conditional split was applied as written: the positive,
structural-heading, and parity scenarios stay in
`parallel-kickoff-artifact.test.ts`, the item-table and integrity-table
negative scenarios moved to `parallel-kickoff-artifact-tables.test.ts`, and the
document-builder helpers moved to the non-test module
`parallel-kickoff-fixtures.ts`. That helper carries no `.test` infix, so it does
not match the root `jest.config.cjs` `testMatch` pattern
`**/extensions/drm-copilot/test/**/*.test.ts` and registers no duplicate suite;
the combined run above reports exactly 6 suites, confirming this.

| Module | Kind | Lines | Under 500 |
| --- | --- | --- | --- |
Line counts below are the final post-Prettier measurements. A Prettier
format check over every touched TypeScript file reported two files needing
formatting (`parallel-kickoff-artifact.ts` and
`parallel-kickoff-artifact-tables.test.ts`); `prettier --write` was applied, the
check was re-run clean, and the Jest set above was re-run and passed again
(6 suites, 92 tests), satisfying the toolchain restart rule. Prettier changed
`parallel-kickoff-artifact.ts` from 363 to 366 lines and
`parallel-kickoff-artifact-tables.test.ts` from 250 to 253 lines.

| Module | Kind | Lines | Under 500 |
| --- | --- | --- | --- |
| `extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact.test.ts` | test | 350 | yes |
| `extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact-tables.test.ts` | test | 253 | yes |
| `extensions/drm-copilot/test/lib/validate/parallel-kickoff-fixtures.ts` | non-test helper | 59 | yes |
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | production | 366 | yes |

## Parity Verification Note

The [P3-T9] parity block asserts against error strings hardcoded in the test
file. Those literals were transcribed from the Python module and independently
confirmed during execution by running the Python validator over the same eleven
fixture documents through a throwaway probe script kept outside the repository
(the scratchpad directory), never from a test. One transcription error was
found and corrected this way: the non-integer-cohort fixture was initially
expected to emit a trailing
`Parallel kickoff item table must contain at least one item row.` error, which
the Python runtime does not emit because the malformed row is still a
well-formed six-cell table row. No test, and no module, spawns a Python
process, reads a generated file, or otherwise depends on an external process.
