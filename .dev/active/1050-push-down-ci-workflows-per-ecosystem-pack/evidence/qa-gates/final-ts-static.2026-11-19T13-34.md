# Final QC: TypeScript Static (advisory-fix plan, P2-T1)

Timestamp: 2026-11-19T13-34
Command: npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" README.md; npm run lint; npm run typecheck (in extensions/drm-copilot, through SCRATCH/issue-1050-advisory-gate-static.sh afinal)
EXIT_CODE: 0
Output Summary: Prettier `All matched files use Prettier code style!`; ESLint 0 problems; tsc 0 `error TS`. Covers `push-down-ci-contract.test-helpers.ts`, `push-down-ci-contract.test.ts`, and `README.md`.

| Step | Command | Exit code | Findings |
| --- | --- | --- | --- |
| Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" README.md` | 0 | 0 |
| Lint | `npm run lint` | 0 | 0 |
| Type check | `npm run typecheck` | 0 | 0 |

Porcelain observation: `git status --porcelain` 0 lines before and after the static run (identical); `--check` writes no file.

Stage 4 (architecture boundaries): no `.dependency-cruiser.cjs` in the repository; not applicable. Harness generator `-Surface all -Check`: exit 0, `harness-generation: no drift`.
