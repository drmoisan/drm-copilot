# TypeScript final-QC static loop ([P4-T2], re-run after the origin/main merge)

Timestamp: 2026-11-13T18-55
Command: sh SCRATCH/issue-1161-pyts-static.sh (in `extensions/drm-copilot`; TypeScript steps listed below; `git status --porcelain` captured before and after)
EXIT_CODE: 0
Output Summary: Prettier `All matched files use Prettier code style!`; ESLint exit 0 with no output; `tsc --noEmit` 0 errors for both tsconfig files. `git status --porcelain` unchanged across the run.

Reason for the re-run: the origin/main merge changed `package-lock.json`, `extensions/drm-copilot/package-lock.json`, and `packages/mcp-server/package-lock.json`. `npm --prefix <worktree> ci` and `npm --prefix <worktree>/extensions/drm-copilot ci` were run first (both exit 0) so the lint and type checks read current dependencies.

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| 1. Format (check) | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | 0 | 0 files with drift |
| 2. Lint | `npx eslint --no-error-on-unmatched-pattern src test` | 0 | 0 |
| 3. Type check (src) | `npx tsc -p ./ --noEmit` | 0 | 0 errors |
| 3. Type check (jest) | `npx tsc -p tsconfig.jest.json --noEmit` | 0 | 0 errors |

Baseline (`evidence/baseline/typescript-static.2026-11-10T03-22.md`): the same four commands, 0 findings each.
