# F7 TypeScript Format/Lint/Typecheck Baseline (Pre-Change)

Timestamp: 2026-06-26T00-12
Command:
- npm run format (prettier --write)
- npm run lint (eslint --no-error-on-unmatched-pattern src test)
- npm run typecheck (tsc -p ./ --noEmit)
(all run from extensions/drm-copilot/)

EXIT_CODE:
- npm run format: 0
- npm run lint: 0
- npm run typecheck: 0

Output Summary:
- Format: PASS. All files unchanged (no reformatting). `git status` shows only untracked F7 evidence/plan files; no source file modified by format.
- Lint: PASS. 0 errors, 0 warnings.
- Typecheck: PASS. 0 type errors.
- src/repo-automation-service.ts current line count: 500 (matches expected 500-line watch threshold).
