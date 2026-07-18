# Remediation Cycle 3 — CI Extension Test Command (P0-T2)

Timestamp: 2026-07-18T17-05

Command: Read `extensions/drm-copilot/package.json` (`scripts` block) and `.github/workflows/_drm-copilot-extension-tests.yml` (step "Run extension unit/integration tests").

EXIT_CODE: 0

Output Summary:
- Workflow step `run:` line (`.github/workflows/_drm-copilot-extension-tests.yml`, step "Run extension unit/integration tests"): `npm --prefix extensions/drm-copilot run test`, preceded by the install step `npm --prefix extensions/drm-copilot ci`.
- `package.json` `scripts.test` value: `node run-jest.cjs` (Jest with `jest.config.cjs`, forwarding extra arguments).
- Related scripts: `test:unit` = `node run-jest.cjs`; `test:coverage` = `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`; `format` = `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`; `lint` = `eslint --no-error-on-unmatched-pattern src test`; `typecheck` = `tsc -p ./ --noEmit`.
- Resolved command used by every extension test task in this plan: `npm --prefix extensions/drm-copilot run test` (targeted subsets append `-- <pattern>`; coverage uses `npm --prefix extensions/drm-copilot run test:coverage`). Confirmed the CI command matches the plan's stated repo-defined command.
