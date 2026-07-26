# root-vscode-test-entrypoint-unrunnable (Issue #421)

- Date captured: 2026-07-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/root-vscode-test-entrypoint-unrunnable/ (Issue #421)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #421
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/421
- Last Updated: 2026-07-26
- Work Mode: full-bug

## Summary

The repository-root npm scripts `test` and `test:integration` are both defined as `vscode-test`, but no `.vscode-test.*` configuration file exists anywhere in the repository. `npm test` and `npm run test:integration` therefore fail for every developer at the repository root, and no CI job exercises the path, so the breakage is undetected.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (condition is environment-independent; also reproduces on CI runners)
- Node/npm: repository-standard toolchain
- Command/flags used: `npm test` and `npm run test:integration` from the repository root
- Data source or fixture: repository root `package.json` at `origin/main` (`fb483b84`)

## Steps to Reproduce

1. Check out `origin/main` at commit `fb483b84`.
2. Run `npm ci` at the repository root.
3. Run `npm test` (or `npm run test:integration`) from the repository root.

## Expected Behavior

`npm test` at the repository root ends in a defined, passing state — either by running a real test suite or by being an honest entry point that does not claim to run a harness that does not exist.

## Actual Behavior

The command exits 1 before any test runner starts:

```
> drm-copilot@1.0.0 test:integration
> vscode-test

Error: Could not find a .vscode-test file in this directory or any parent. You can specify one with the --config option.
```

`@vscode/test-cli` fails in `loadDefaultConfigFile` because no configuration file exists.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior. Prior verification is recorded at `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md` and `.../evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

`npm test` is the conventional entry point a developer or external tool reaches for first. It is unconditionally broken at the repository root, but no production behavior is affected and no CI gate is currently red.

## Suspected Cause / Notes

Verified conditions at `fb483b84`:

- Root `package.json` declares `"test:integration": "vscode-test"` and `"test": "vscode-test"`.
- No `.vscode-test.mjs`, `.vscode-test.js`, `.vscode-test.cjs`, or `.vscode-test.json` exists anywhere in the repository. `vscode-test` requires such a config file.
- No `tsconfig.vscode-test.json` exists. Only `tsconfig.json`, `tsconfig.jest.json`, and `tsconfig.tests.json` are present at the root.
- There are no root integration-test sources: no `*integration*` directory under `tests/`, and no `*.integration.*` files at the root.
- No file under `.github/workflows/**` references `test:integration` or `vscode-test`, so no CI job exercises this path.

Two neighbouring scripts silently paper over the gap:

- `compile:integration-tests` exits 0 with a "Skipping" message when `tsconfig.vscode-test.json` is absent.
- `format` / `format:check` include `.vscode-test.mjs` in their glob lists under `--no-error-on-unmatched-pattern`.

Contextual signals relevant to the scope decision:

- The repository root contains exactly one TypeScript source file (`src/hello-typescript.ts`) and one root TypeScript test (`tests/unit/hello-typescript.test.ts`). The root is not a VS Code extension.
- The VS Code extension lives at `extensions/drm-copilot/` and has its own test job in CI (`_drm-copilot-extension-tests.yml`, ubuntu-latest and windows-latest). That extension's own `test` script is jest-based (`node run-jest.cjs`) and it likewise has no `.vscode-test.*` config.

This pattern is consistent with leftovers from a `yo code` extension scaffold that was applied at the repository root before the extension was moved under `extensions/`.

This defect was identified and recorded for separate filing during issue #414; see `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/preexisting-defects-for-filing.2026-07-25T22-28.md` (Condition 2).

## Proposed Fix / Validation Ideas

The scope decision must be researched and justified, not assumed. Two candidate directions:

- (a) Remove the dead integration-test entry points and their vestigial supporting references so the root scripts are honest, and point root `test` at a suite that actually runs.
- (b) Wire a real, runnable VS Code integration-test harness at the repository root.

Weigh whether a second, root-level integration harness is genuinely needed given that `extensions/drm-copilot/` already has its own extension test job in CI.

- [ ] Unit coverage areas: root npm script definitions; any guard test asserting root entry points are runnable
- [ ] Integration scenario to retest: `npm test` and `npm run test:integration` at the repository root
- [ ] Manual verification notes: whichever direction is chosen, `npm test` at the repository root must end in a defined, passing state, and the choice must not silently reduce test coverage.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
