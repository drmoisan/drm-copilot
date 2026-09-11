# test-tree-typecheck-not-gated (Issue #647)

- Date captured: 2026-09-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/test-tree-typecheck-not-gated/ (Issue #647)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #647
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/647
- Last Updated: 2026-09-07
## Summary

The extension's TypeScript test tree is never type-checked by any enforced gate. `npm run typecheck` compiles `src/**/*.ts` only, and ts-jest runs under `isolatedModules: true`, which suppresses diagnostics. `tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`, the only configuration that includes `test/**/*.ts`, exits 2 with 331 `error TS` lines across 69 files at main.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; also reproduced by the #614 feature review at branch head 645c40b0
- Python version: not applicable
- Command/flags used: `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
- Data source or fixture: repository at `main` (c3ffb080 or later); `extensions/drm-copilot/tsconfig.json` line 23 `"include": ["src/**/*.ts"]`, `tsconfig.jest.json` line 8 `"include": ["src/**/*.ts", "test/**/*.ts"]`, `package.json` line 209 `"typecheck": "tsc -p ./ --noEmit"`

## Steps to Reproduce

1. From the repository root run `npm --prefix extensions/drm-copilot run typecheck`; observe exit 0 with no output.
2. Run `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`.
3. Observe exit code 2 and 331 `error TS` diagnostics across 69 test files (for example `error TS2740` at `test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts(182,9)`, missing-member errors on `VirtualFileSystem` against newer `FileSystem` members, `noPropertyAccessFromIndexSignature` accesses, and Jest mock-typing mismatches).

## Expected Behavior

Either the test tree type-checks cleanly and a CI gate enforces it (the repository's TypeScript policy requires the type-check stage of the toolchain loop and treats untyped escape hatches as tier-gated), or the repository explicitly documents that test files are exempt from type checking and why. A plan gate of "the test tree type-checks with exit 0" is currently unsatisfiable at baseline, which the #614 CI remediation plan had to work around by gating on "no diagnostic absent from the baseline set".

## Actual Behavior

`npm run typecheck` reports success while the test tree carries 331 type errors; none of the CI jobs (`quality-checks`, `drm-copilot-extension-tests`, `root-typescript-tests`) fails on them because Jest transpiles without diagnostics. Of the 331 errors, 318 sit in 63 files untouched by recent feature work, so this is a repository-wide accumulation rather than a single regression.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: recorded in `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-test-tree-typecheck.2026-09-07T03-16.md` (full diagnostic list at head fca8c045) and in `policy-audit.2026-09-07T08-00.md`, out-of-scope observation 3.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Type errors in tests do not fail CI, so test code can drift from production types (for example a request literal missing newly required fields while the suite still passes, as R20 of the #614 review shows). Coverage and behavior gates still hold, so this is a quality-durability gap rather than a shipped defect.

## Suspected Cause / Notes

`tsconfig.json` was scoped to `src` to keep the production build clean, and `tsconfig.jest.json` was added for ts-jest module resolution rather than as a gate. `isolatedModules: true` in `tsconfig.jest.json` makes ts-jest skip type checking. No workflow invokes `tsc` against `tsconfig.jest.json`. Repository-level decision needed: gate the test tree (and fix or suppress the 331 errors, with suppressions governed by the TypeScript suppression policy) or record the exemption in `.claude/rules/typescript.md` and the TypeScript instructions.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: not applicable (type-level).
- [x] Integration scenario to retest: add a CI step (or extend `typecheck`) that runs `tsc -p tsconfig.jest.json --noEmit` and fails on any diagnostic once the backlog is cleared; until then, a ratchet that fails only on diagnostics absent from a committed baseline.
- [x] Manual verification notes: after the fix, `tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` exits 0 on `main`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
