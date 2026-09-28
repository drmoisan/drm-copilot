# TS Baseline Formatting ([P0-T10])

Timestamp: 2026-09-26T21-15

Command:
1. `test -f node_modules/jest/bin/jest.js` (from `extensions/drm-copilot`)
2. `test -f node_modules/prettier/package.json` (from `extensions/drm-copilot`)
3. `npm ci` (from `extensions/drm-copilot`, run because the precondition failed)
4. `test -f node_modules/jest/bin/jest.js` (repeat)
5. `test -f node_modules/prettier/package.json` (repeat)
6. `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (from `extensions/drm-copilot`)

EXIT_CODE:
1. 1
2. 1
3. 0
4. 0
5. 0
6. 0

Output Summary:
- Precondition failed (node_modules absent in the fresh worktree); `npm ci` summary line: `added 452 packages, and audited 453 packages in 5s`; both `test -f` checks then exited 0.
- Prettier check output: `Checking formatting...` then `All matched files use Prettier code style!`
- No pre-existing drift. Check mode only; no source written.
