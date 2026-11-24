# Task check: P1-T3

Timestamp: 2026-11-24T07-10
Command: see the command list below (each run from the item worktree root or extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: Prettier, ESLint, and both tsc projects clean on the changed TypeScript files; the Jest selection passed (4 suites, 74 tests) and the new module measured 100% lines and 100% branches against its own 85/75 threshold; Set L passed (89 tests, 0 failures); the in-memory revert of every 0014 block restores the merge-base bytes of all four recorded files.

Changed files:
- extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts (created): `isChildCiIntegrationOnly`, `validateCompletionLocalQcGate`, `validateCompletionGateEvidence`, strings and order identical to the Python validator.
- extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts: imports the selector and calls it inside the `routeRequiresCiGate` branch; the now-unused `validateCompletionCiGate` specifier is dropped from the completion import. `orchestrator-state-completion.ts` is unchanged.
- extensions/drm-copilot/jest.config.cjs: `coverageThreshold` entry for the new module (lines 85, branches 75), placed after the `orchestrator-state-routing.ts` entry, outside the 0002, 0003, and 0010 regions.
- extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts (created): one row per corpus file, the corpus floor (>= 13), a predicate row, and two core-validator rows with completion required (accepted opt-out reports no gate error; opt-out removed reports exactly the existing ci_gate error).
- .dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md: blocks for orchestrator-state-core.ts and jest.config.cjs appended; Files Changed and Revert Steps step 1 extended.

Selection and rule: the new test, the existing tests that import the changed core module named by the plan (orchestrator-state-core.completion.test.ts, orchestrator-state-core.test.ts, orchestrator-state-concurrent-review.test.ts), and Set L because the task edits files carrying recorded regions and the ledger.

Commands and exit codes:
- SCRATCH/issue-1233-ts-files.sh (in extensions/drm-copilot): npx prettier --write (3 files unchanged) -> 0; npx prettier --check -> 0 ("All matched files use Prettier code style!"); npx eslint <3 ts files> -> 0; npx tsc -p ./ --noEmit -> 0 (0 errors); npx tsc -p tsconfig.jest.json --noEmit -> 0 (0 errors). jest.config.cjs was Prettier-checked (unchanged); it is outside the repository lint scope (`eslint src test`), where it reports 4 pre-existing no-require-imports findings.
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension "--testPathPatterns=test/lib/validate/(orchestrator-state-child-ci|orchestrator-state-core\.completion|orchestrator-state-core|orchestrator-state-concurrent-review)\.test\.ts" --coverage --collectCoverageFrom=src/lib/validate/orchestrator-state-child-ci.ts --coverageThreshold=<the new module's 85/75 entry only> -> 0 (Test Suites 4 passed; Tests 74 passed; orchestrator-state-child-ci.ts 100% statements, branches, functions, lines). A first run without the scoped --coverageThreshold exited 1 only because the configured per-file thresholds of unselected files reported "Coverage data ... was not found"; every test passed in that run too.
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <Set L> -> 0 (89 passed; launcher exit 75 queue timeouts before the run)
- sh SCRATCH/issue-1233-ledger-verify.sh -> 0 (blocks=10 files=4 problems=0)
