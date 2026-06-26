# F4 Baseline — TypeScript Format / Lint / Typecheck (pre-change)

Timestamp: 2026-06-26T00-24

Command:
- `npm run format` (Prettier write) — run from `extensions/drm-copilot/`
- `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`)
- `npm run typecheck` (`tsc -p ./ --noEmit`)

EXIT_CODE:
- format: 0
- lint: 0
- typecheck: 0

Output Summary:
- Format: pass. All tracked source/test files reported `(unchanged)`. `git status --porcelain` after format showed only new untracked F4 evidence and plan files; no source file was reformatted.
- Lint: pass. 0 errors, 0 warnings.
- Typecheck: pass. 0 type errors.
