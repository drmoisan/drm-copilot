# PR Notes: extension-tests-fail-in-container

## Summary
- Removed VS Code integration harness scaffolding to make tests container-safe.
- Updated npm scripts to run Jest-only test workflow.
- Documented Jest-only workflow for extension tests.

## Test Workflow
- `npm test` runs the Jest unit test suite (no VS Code test runner).
- `npm run test:integration` runs the same Jest unit tests for container-safe verification.

## QA Commands
- `npm run format`
- `npm run lint`
- `npm run typecheck`
- `npm run test:unit`

## Risks
- Jest-only validation does not exercise a live VS Code extension host.

## Validation
- `npm run test:unit -- --runTestsByPath tests/unit/vscode-test-removal.test.ts`
- `npm run test:unit`
