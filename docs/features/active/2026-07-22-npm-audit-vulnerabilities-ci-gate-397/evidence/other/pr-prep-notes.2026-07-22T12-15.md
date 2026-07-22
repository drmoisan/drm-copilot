# [P8-T1] PR Preparation Notes (Not Yet Opened)

**Status: PR NOT OPENED.** The delegating session directive for this execution run explicitly states: "Do NOT commit or push — leave changes staged/unstaged for the orchestrator to review and commit." Opening or updating a PR requires a commit and a push, which conflicts with that explicit instruction. This artifact prepares the PR content; the orchestrator is responsible for committing, pushing, and opening/updating the PR (and then completing P8-T2's CI confirmation once a PR head SHA exists).

## Proposed PR Title

`fix(deps): resolve npm audit moderate/high advisories in 3 manifests (#397)`

## Proposed PR Body

### Summary
- Fixes issue #397: the `NPM Audit Gate` required CI check fails on `main` for all three npm manifests (root `.`, `extensions/drm-copilot/`, `packages/mcp-server/`).
- Root cause: `@modelcontextprotocol/sdk@1.29.0` declares an unused, vulnerable `@hono/node-server@^1.19.9` dependency (GHSA-frvp-7c67-39w9); four additional advisories (`fast-uri`, `hono`, `brace-expansion`, `js-yaml`/`body-parser`) are ordinary transitive-range issues.

### Files touched (exactly 6, no source code changes)
- `package.json` / `package-lock.json` (root)
- `extensions/drm-copilot/package.json` / `extensions/drm-copilot/package-lock.json`
- `packages/mcp-server/package.json` / `packages/mcp-server/package-lock.json`

### Change detail
- Added `"@hono/node-server": "^2.0.5"` to the `overrides` block in all three manifests.
- Raised `overrides.fast-uri` to `^3.1.4` and `overrides.hono` to `^4.12.27` in all three manifests.
- Raised the `c8`-scoped `overrides.brace-expansion` to `^5.0.7` in root and `extensions/drm-copilot/` only (this override does not exist in `packages/mcp-server/package.json`).
- Regenerated each `package-lock.json` via `npm install` + `npm audit fix` (no `--force`) per manifest.

### `@modelcontextprotocol/sdk` unchanged
- Confirmed `^1.29.0` (declared) / `1.29.0` (resolved) in all three manifests, both before and after the fix. `npm audit fix --force` was never run (it would have downgraded the SDK to `1.24.3`, a breaking change — see the baseline evidence).

### Evidence links (this feature folder)
- Baseline: `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/baseline/`
- Lock regeneration: `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/other/lock-regeneration-root.2026-07-22T12-15.md`, `lock-regeneration-extensions.2026-07-22T12-15.md`, `lock-regeneration-mcp-server.2026-07-22T12-15.md`
- Post-fix validation (Phase 5): `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/npm-audit-postfix-root.2026-07-22T12-15.md` (+ extensions, mcp-server), `scope-confirmation.2026-07-22T12-15.md`
- Final QA loop (Phase 6): `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/evidence/qa-gates/compile-final-root.2026-07-22T12-15.md`, `test-unit-final-root.2026-07-22T12-15.md`, `test-coverage-final-root.2026-07-22T12-15.md`, `compile-final-extensions.2026-07-22T12-15.md`, `test-unit-final-extensions.2026-07-22T12-15.md`, `test-coverage-final-extensions.2026-07-22T12-15.md`, `build-final-mcp-server.2026-07-22T12-15.md`, `stdio-smoke-final-mcp-server.2026-07-22T12-15.md`, `final-qa-loop-integrity.2026-07-22T12-15.md`

### Test plan
- [x] `npm ci && npm audit --audit-level=moderate` exits 0 in all 3 manifests.
- [x] `npm run compile` (root, `extensions/drm-copilot/`) and `npm run build` (`packages/mcp-server/`) pass unchanged.
- [x] Jest unit test suites pass unchanged (identical pass counts, identical coverage percentages).
- [x] Manual stdio smoke check of the rebuilt mcp-server bundle confirms a valid `initialize` response.
- [ ] `NPM Audit Gate` required check green on PR head SHA (pending PR creation — P8-T2).

Closes #397.
