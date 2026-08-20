# Final QC — single-clean-pass attestation (AC24)

Timestamp: 2026-08-20T09-53

Task: [P8-T10]

Command: the eight commands listed below, executed in this order in one uninterrupted pass
EXIT_CODE: 0

## The eight commands of the final uninterrupted pass, in execution order

| # | Task | Command | EXIT_CODE |
| --- | --- | --- | --- |
| 1 | [P8-T1] | `poetry run black .` | 0 |
| 2 | [P8-T2] | `poetry run ruff check .` | 0 |
| 3 | [P8-T3] | `poetry run pyright` | 0 |
| 4 | [P8-T4] | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 |
| 5 | [P8-T5] | (from `extensions/drm-copilot`) `npm run format` | 0 |
| 6 | [P8-T6] | (from `extensions/drm-copilot`) `npm run lint` | 0 |
| 7 | [P8-T7] | (from `extensions/drm-copilot`) `npm run typecheck` | 0 |
| 8 | [P8-T8] | (from `extensions/drm-copilot`) `npm run test:unit` | 0 |

All eight exit codes are `0`.

## No-modification statement

**No file was modified by either formatter during this pass.** `poetry run black .` reported
`428 files left unchanged` with 0 files reformatted, and `npm run format` reported every matched file
as `(unchanged)` with 0 files rewritten. Ruff, whose configuration enables `fix = true`, auto-fixed no
file. The working-tree status taken after the formatter stages listed only this change's intended
paths.

## The one restart, recorded for completeness

An earlier pass failed at step 3: Pyright reported one `reportPrivateUsage` error for the
module-private collector renderer imported by the new Python collector-level test module. That was
fixed, which modified a file, so the loop restarted at step 1 exactly as the toolchain rule requires.
The table above records the FINAL uninterrupted pass after that restart. The failure, the four
alternative resolutions tried and rejected, and the adopted line-scoped suppression are documented in
`final-py-pyright.2026-08-20T09-53.md`.

## Test and coverage results from the same pass

- Python: 3995 passed, 0 failed, 5 skipped; overall line 92.45%, overall branch 84.93%.
- TypeScript: 185 of 185 suites and 2580 of 2580 tests passed; overall line 96.62%, overall branch
  89.98%.

Output Summary: All eight final-QC commands succeeded consecutively with exit code 0 in one
uninterrupted pass, and no file was modified by either formatter during that pass. One earlier restart
occurred, caused by a Pyright `reportPrivateUsage` error that was fixed before the recorded pass.
AC24 is satisfied.
