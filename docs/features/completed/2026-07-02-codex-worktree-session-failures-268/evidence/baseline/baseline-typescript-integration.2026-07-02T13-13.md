Timestamp: 2026-07-02T13-43
Command: Inspect extensions/drm-copilot/package.json, extensions/drm-copilot/jest.config.cjs, and extensions/drm-copilot/test/ for a distinct TypeScript integration-test gate
EXIT_CODE: 0
Output Summary: No distinct configured TypeScript integration-test gate exists for `extensions/drm-copilot`. Jest is configured to run all `test/**/*.test.ts` files through `npm run test:unit`; there is no separate `test:integration` or `test:e2e` script.

Inspected Files:
- extensions/drm-copilot/package.json
- extensions/drm-copilot/jest.config.cjs
- extensions/drm-copilot/test/

Observed Integration-Named Tests:
- extension.collect-commit-context.integration.test.ts
- extension.integration.test.ts

Gate Status: Not applicable as a separate gate; integration-named tests are covered by the configured Jest unit command.
