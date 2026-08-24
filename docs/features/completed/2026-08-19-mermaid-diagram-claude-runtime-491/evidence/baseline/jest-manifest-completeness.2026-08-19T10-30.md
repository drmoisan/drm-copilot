# Baseline — TypeScript pack-manifest-completeness suite, issue #491

Timestamp: 2026-08-19T10-30

Preconditions: `extensions/drm-copilot/node_modules` was absent in this fresh worktree, so
`npm ci` was run first (not `npm install`, so `package-lock.json` is never rewritten).
`npm ci` output: `added 457 packages, and audited 458 packages in 5s`, `found 0 vulnerabilities`,
EXIT_CODE 0. `git status --porcelain package-lock.json` returned empty, confirming the lockfile is
unchanged.

Command: `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts`

EXIT_CODE: 0

Output Summary: `Test Suites: 1 passed, 1 total`; `Tests: 15 passed, 15 total`; `Time: 0.404 s`.
Baseline green, as expected.
