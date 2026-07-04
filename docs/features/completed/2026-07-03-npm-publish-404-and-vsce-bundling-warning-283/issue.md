# npm-publish-404-and-vsce-bundling-warning (Issue #283)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-publish-404-and-vsce-bundling-warning/ (Issue #283)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #283
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/283
- Last Updated: 2026-07-03
- Work Mode: minor-audit

## Summary

Two recent GitHub Actions failures/warnings were reported on release `full-20260703035807` (PR #278): (1) `Publish MCP Server to npm` fails with `npm error code E404` when publishing `@danmoisan/drm-copilot-mcp`, and (2) `Publish Extension to VS Code Marketplace` succeeds but emits a bundling-performance warning because the extension ships 128 unbundled compiled JavaScript files.

## Environment

- OS/version: `ubuntu-latest` GitHub Actions runner
- Command/flags used: `npm publish --access public` (mcp-server); `npx --yes @vscode/vsce publish --pat ...` (extension)
- Data source or fixture: GitHub Actions run logs for `mcp-server-v1.0.4` (run 28637721250) and `v1.0.4` (run 28637720717)

## Steps to Reproduce

1. Tag a release that triggers `.github/workflows/publish-mcp-npm.yml` (push tag `mcp-server-v*`).
2. Observe the `Publish to npm` step fail with `npm error code E404 ... PUT https://registry.npmjs.org/@danmoisan%2fdrm-copilot-mcp - Not found`.
3. Tag a release that triggers `.github/workflows/publish-extension.yml` (push tag `v*`).
4. Observe the `Publish to Marketplace` step succeed but log: "This extension consists of 650 files, out of which 128 are JavaScript files... you should bundle your extension."

## Expected Behavior

1. `npm publish --access public` succeeds for `@danmoisan/drm-copilot-mcp` given the package already exists on the registry (versions 0.0.1-1.0.1 published successfully).
2. The VS Code extension packaging step does not emit a bundling-performance warning; the extension's own compiled output is bundled into a small number of files.

## Actual Behavior

1. `npm publish` has failed with `E404 Not Found` on every tagged release since `1.0.2` (`1.0.2`, `1.0.3`, `1.0.4` all failed; `1.0.0` and `1.0.1` succeeded). Verified via `npm view @danmoisan/drm-copilot-mcp versions/time`: last successful publish was `1.0.1` at `2026-06-27T19:28:51.899Z`. No code, workflow, or `package.json` changes (other than the version bump) occurred between the `1.0.1` and `1.0.2` tags (`git log -p 5e53294..e52e165` shows only a version bump), which rules out a code-side regression and points to an npm-registry-side credential/authorization change (e.g., the `NPM_TOKEN` GitHub Actions secret was rotated, expired, or lost publish rights) after `2026-06-27T19:28:51Z`.
2. `vsce package`/`publish` reports 650 total files / 128 JavaScript files. `extensions/drm-copilot/src` contains exactly 128 `.ts` files, and `tsc` compiles each to a separate `out/*.js` file (one-to-one), which is not bundled. Only the embedded MCP server (`out/mcp-server.js`) is bundled via `esbuild-mcp-server.cjs`; the extension's own entry point (`out/extension.js`) is not.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:
  ```
  npm error code E404
  npm error 404 Not Found - PUT https://registry.npmjs.org/@danmoisan%2fdrm-copilot-mcp - Not found
  ```
  ```
  This extension consists of 650 files, out of which 128 are JavaScript files. For performance
  reasons, you should bundle your extension: https://aka.ms/vscode-bundle-extension.
  ```

## Impact / Severity

- [x] Blocker (npm publish is fully broken for all future mcp-server releases)
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- npm E404: credential/authorization issue on the npm registry side for the `NPM_TOKEN` GitHub Actions secret (rotation, expiry, or scope loss). Repo history shows a prior, different root cause for the same symptom (commit `605d7f5`, issue #220, `--provenance` flag), which was already removed — this recurrence is not that same cause. This portion of the fix requires a human to regenerate/verify the npm access token on npmjs.com and update the `NPM_TOKEN` GitHub Actions secret; it cannot be resolved by an in-repo code change alone.
- VS Code bundling warning: `extensions/drm-copilot/package.json` `compile`/`build` scripts run `tsc -p ./` (emits one `.js` per `.ts`) instead of bundling the extension entry point with `esbuild` the way `esbuild-mcp-server.cjs` already bundles the embedded MCP server.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: none required for the credential rotation (external, human action); add/adjust build-script coverage or a smoke check that `out/extension.js` and `out/mcp-server.js` exist as bundled files after `npm run compile`.
- [x] Integration scenario to retest: re-run `.github/workflows/publish-mcp-npm.yml` via `workflow_dispatch` after the `NPM_TOKEN` secret is fixed; re-run `.github/workflows/publish-extension.yml` and confirm the bundling warning no longer appears in `vsce package` output.
- [x] Manual verification notes: this bug requires a documented human-exception runbook for the `NPM_TOKEN` rotation step, since no repository automation has access to the npmjs.com account or GitHub repository secrets UI.

## Acceptance Criteria

> Scope note: These criteria cover the VS Code extension bundling warning only (Expected Behavior item 2). The npm E404 publish failure (Expected Behavior item 1) is resolved via the human-exception runbook at `runbooks/npm-token-rotation.runbook.md` and is out of scope for this criteria set.

- [x] `extensions/drm-copilot/esbuild-extension.cjs` exists and bundles `src/extension.ts` into `out/extension.js` via esbuild with `bundle: true`, `platform: "node"`, `target: "node18"`, and `external: ["vscode"]`.
- [x] `extensions/drm-copilot/package.json` `compile` and `build` scripts run `tsc -p ./ --noEmit` for type-checking, then `npm run bundle:extension` (new script wrapping `node esbuild-extension.cjs`), then the existing `npm run bundle:mcp-server`, and no longer invoke `tsc -p ./` in emit mode.
- [x] Running `npm --prefix extensions/drm-copilot run compile` succeeds and produces `extensions/drm-copilot/out/extension.js` and `extensions/drm-copilot/out/mcp-server.js`, with the total `.js` file count under `extensions/drm-copilot/out/` reduced from 128 to a documented small number, eliminating the "128 JavaScript files... bundle your extension" `vsce package` warning.
- [x] No file under `extensions/drm-copilot/test/**`, `extensions/drm-copilot/jest.config.cjs`, `.github/workflows/publish-extension.yml`, or `extensions/drm-copilot/.vscodeignore` depends on the previous one-file-per-source-file `out/*.js` layout; any dependency found during verification is updated as part of this fix.
- [x] `.github/workflows/publish-mcp-npm.yml` and all other workflow files remain unmodified by this fix.
- [x] The full TypeScript toolchain (format, lint, type-check, existing unit tests) passes cleanly after the change, per `.claude/rules/typescript.md` and `.claude/rules/general-code-change.md`.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
