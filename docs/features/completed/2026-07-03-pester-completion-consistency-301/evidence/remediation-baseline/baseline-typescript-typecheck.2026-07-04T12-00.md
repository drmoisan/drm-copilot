# Baseline TypeScript Typecheck (Pre-Fix)

Timestamp: 2026-07-04T12-00
Command: `npm run typecheck` (repo root)
EXIT_CODE: 2

Output Summary: Three pre-fix errors confirmed:
- `src/hello-typescript.ts(1,1): error TS2584: Cannot find name 'console'. Do you need to change your target library? Try changing the 'lib' compiler option to include 'dom'.`
- `tests/unit/hello-typescript.test.ts(5,31): error TS2584: Cannot find name 'console'. Do you need to change your target library? Try changing the 'lib' compiler option to include 'dom'.`
- `tests/unit/hello-typescript.test.ts(10,5): error TS2591: Cannot find name 'require'. Do you need to install type definitions for node? Try 'npm i --save-dev @types/node' and then add 'node' to the types field in your tsconfig.`

Root cause: root `tsconfig.json` `compilerOptions` lacks `"types": ["node"]`, so ambient Node/console typings are not loaded.
