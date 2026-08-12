# TypeScript Codex Portable Publisher Evidence

Timestamp: `2026-08-10T20-25`

Task: `[P5-T5]`

Command: `npx prettier --check src/lib/push-down/codex-agents-customizations.ts src/lib/push-down/codex-portable-assets.ts test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-portable-assets.test.ts`

EXIT_CODE: `0`

Output Summary: All four scoped files use the repository Prettier style.

Command: `npx eslint src/lib/push-down/codex-agents-customizations.ts src/lib/push-down/codex-portable-assets.ts test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-portable-assets.test.ts`

EXIT_CODE: `0`

Output Summary: ESLint completed without diagnostics.

Command: `npx tsc -p ./ --noEmit`

EXIT_CODE: `0`

Output Summary: TypeScript compilation completed without diagnostics.

Command: `npm run test:unit -- --runInBand test/lib/push-down/codex-portable-assets.test.ts test/lib/push-down/codex-agents-customizations.test.ts`

EXIT_CODE: `0`

Output Summary: 2 suites and 15 tests passed in 0.458 seconds.

## Verified Contract

- TypeScript and Python each define 15 portable destination paths in identical
  order: nine approved Bash files, five approved blast-radius PowerShell
  modules, and `config/blast-radius.json`.
- Normalized Python-versus-TypeScript comparison reported 15/15 ordered path
  matches and 15/15 effective source SHA-256 matches.
- Approved `.claude` assets use the canonical source when present and the
  generic resource copy as a packaged fallback.
- `config/blast-radius.json` remains generic-resource-only, excluding the
  repository-specific value from publication.
- Enumeration excludes unrelated `.claude/**` content and respects selected
  manifest membership.
- Unequal portable destination collisions are reported in the shared stable
  allowlist order before any publisher write.
- Existing public exports remain available.
- `codex-agents-customizations.ts` is 308 lines.
- `codex-portable-assets.ts` is 190 lines.
- Existing public test owner is 385 lines; direct helper test owner is 149 lines.
- `.claude` diff is zero, `.codex/state` is absent, and `git diff --check`
  exits 0. The existing `testResults.xml` line-ending warning is non-failing.
- `[P5-T6]` was not started.
