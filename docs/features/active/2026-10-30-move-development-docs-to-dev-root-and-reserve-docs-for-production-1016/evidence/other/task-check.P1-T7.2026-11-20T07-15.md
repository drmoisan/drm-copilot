# Task Check [P1-T7]

Timestamp: 2026-11-20T07-15
Command: sh SCRATCH/issue-1016-fmtwrite.sh <files>; sh SCRATCH/issue-1016-taskcheck.sh (prettier --check, eslint, npm run typecheck, run-test-suite.sh jest-extension "--testPathPatterns=development-docs-migration/migration-apply")
EXIT_CODE: 0
Output Summary: changed files `src/lib/development-docs-migration/migration-apply.ts` (new) and its mirrored test (new). Prettier `All matched files use Prettier code style!`, ESLint exit 0, typecheck exit 0, Jest `Test Suites: 1 passed, 1 total`, `Tests: 5 passed, 5 total`. Recorded behavior: an empty plan writes nothing (no README on an already migrated tree); with moves-then-rewrites the second call re-plans against the moved tree, so only unmoved-file prefix rewrites remain (the accepted spec H2 halt branch).
