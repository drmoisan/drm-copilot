# TypeScript formatter baseline (P0-T6)

Timestamp: 2026-09-30T07-14

Precondition: `extensions/drm-copilot/node_modules` was absent. Ran `npm ci --prefix extensions/drm-copilot` (the `cd` form is blocked by a Bash hook; `--prefix` is equivalent to running in extensions/drm-copilot). EXIT_CODE: 0. Outcome: added 452 packages, audited 453, 2 vulnerabilities reported (1 moderate, 1 high), no diff impact (node_modules is gitignored).

Command: git status --porcelain; npm run format --prefix extensions/drm-copilot (runs `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`); git status --porcelain
EXIT_CODE: 0
Output Summary:
- Porcelain before the run:
```
?? docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/
```
- Porcelain after the run:
```
?? docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/
```
- The two listings are identical. The run left every matched file unchanged: Prettier printed 471 file lines and all 471 ended in `(unchanged)` (verified by counting `(unchanged)` lines = 471 and listing the non-matching lines, which were only the two npm header lines).
- Tracked files rewritten by the run: none. No revert was needed.
