# Static Baseline - TypeScript Type Check (P0-T2)

Timestamp: 2026-11-23T12-59
Command: sh SCRATCH/issue-1221-static-ts.sh typecheck (in extensions/drm-copilot: npx tsc -p ./ --noEmit && npx tsc -p tsconfig.jest.json --noEmit)
EXIT_CODE: 0
Output Summary: no diagnostics from either tsc project. Finding count: 0.

Note: a first attempt at 2026-11-23T12-58 exited 2 (TS2593/TS2304, missing @types/jest) because extensions/drm-copilot/node_modules was absent; re-run after npm ci.
