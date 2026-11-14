# TypeScript static baseline (P0-T4)

Timestamp: 2026-11-10T03-21
Command: (in extensions/drm-copilot, through sh SCRATCH/issue-1162-tsstatic.sh, after npm --prefix extensions/drm-copilot ci) npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" ; npx eslint --no-error-on-unmatched-pattern src test ; npm run typecheck
EXIT_CODE: 0
Output Summary:
- Step 1 Prettier check: Command: npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" | EXIT_CODE: 0 | findings: 0 ("All matched files use Prettier code style!")
- Step 2 ESLint: Command: npx eslint --no-error-on-unmatched-pattern src test | EXIT_CODE: 0 | findings: 0 (no output)
- Step 3 Type check: Command: npm run typecheck (tsc -p ./ --noEmit, then tsc -p tsconfig.jest.json --noEmit) | EXIT_CODE: 0 | findings: 0
