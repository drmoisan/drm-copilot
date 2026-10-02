# Phase 2 type-check gate, R-DIAG (#647)

Timestamp: 2026-10-01T23-18
Command: node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit > FEATURE/evidence/qa-gates/tsc-jest-phase-2.2026-10-01T23-18.log 2>&1; echo "TSC_EXIT=$?"
EXIT_CODE: 2
ExpectedExitCode: 2

List: FEATURE/evidence/other/phase-2-files.txt
Prev: FEATURE/evidence/qa-gates/tsc-jest-phase-1.2026-10-01T23-18.log

TSC_EXIT: 2
PHASE_HITS: 0
PREV_PHASE_HITS: 22
NEW_PATHS: none
TOTAL: 259
PREV_TOTAL: 281

Note (P2-T4/P2-T5 adaptation): typing the mock by direct `as jest.MockedFunction<withFileTypes signature>` cast reported TS2352 (an overloaded function is not comparable with a single-signature mocked type), and the existing `as unknown as ReturnType<typeof fs.readdirSync>` return casts resolve to `Dirent<NonSharedBuffer>[]`. The mock is therefore declared as `jest.mocked<(path: PathLike, options: { withFileTypes: true }) => Dirent[]>(fs.readdirSync)` (assignable through the `withFileTypes: true` overload, no cast), and the return casts inside the two `mockImplementation` callbacks were removed. No runtime value or assertion changed. Recorded as plan deviation D8.

Output Summary: gate passed. All 22 Phase 2 diagnostics cleared; no new path; total 281 -> 259.
