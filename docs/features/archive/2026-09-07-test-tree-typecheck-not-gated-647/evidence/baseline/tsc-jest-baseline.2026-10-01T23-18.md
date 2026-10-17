# Baseline tsc -p tsconfig.jest.json (#647)

Timestamp: 2026-10-01T23-18
Command: node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit > FEATURE/evidence/baseline/tsc-jest-diagnostics.2026-10-01T23-18.log 2>&1; echo "TSC_EXIT=$?"
EXIT_CODE: 2
ExpectedExitCode: 2

TSC_EXIT: 2
error TS count (new log): 355
Old paths file line count (2026-09-29T20-15): 71
New paths file line count (2026-10-01T23-18): 71
New-minus-old (grep -vxF -f old.paths.txt new.paths.txt): (no output)
Old-minus-new (grep -vxF -f new.paths.txt old.paths.txt): (no output)

Output Summary: TSC_EXIT=2 as expected. 355 diagnostics (plan cited 353; recorded as deviation D1) across the same 71 files as the 2026-09-29T20-15 baseline. Both set differences are empty, so no file is outside the planned phases and no planned file was fixed upstream. The new log and its paths file are the prev references for P1-T19.
