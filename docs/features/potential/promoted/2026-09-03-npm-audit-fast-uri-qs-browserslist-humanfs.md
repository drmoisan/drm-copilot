# npm-audit-fast-uri-qs-browserslist-humanfs (Issue #627)

- Date captured: 2026-09-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-fast-uri-qs-browserslist-humanfs/ (Issue #627)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #627
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/627
- Last Updated: 2026-09-03
## Summary

The `NPM Audit Gate` CI check fails (non-required, but genuinely flagging real advisories) across all three npm workspaces (`.`, `extensions/drm-copilot`, `packages/mcp-server`) due to known vulnerabilities in transitive dependencies: `fast-uri`, `qs`, `browserslist`, and `@humanfs/node`.

## Environment

- OS/version: ubuntu-latest (GitHub Actions runner)
- Python version: N/A (npm/Node.js)
- Command/flags used: `npm audit --audit-level=moderate` (CI job "NPM Audit Gate")
- Data source or fixture: PR #626 (`fix/bash-permission-cd-chain-forbidden-pattern`) CI run 33750279774; also observed on PR #624 CI run 33631731626

## Steps to Reproduce

1. Run `npm audit --audit-level=moderate` from the repo root (`.`).
2. Run the same from `extensions/drm-copilot/`.
3. Run the same from `packages/mcp-server/`.
4. Observe non-zero exit and the vulnerability listing below in all three.

## Expected Behavior

`npm audit` should report zero moderate-or-higher vulnerabilities in all three workspaces, so the `NPM Audit Gate` CI check passes.

## Actual Behavior

- **Root (`.`)**: 4 vulnerabilities (2 moderate, 2 high) — `@humanfs/node` (moderate, GHSA-p498-v437-472g), `browserslist` (high, GHSA-c83g-rgw3-j3cx, GHSA-73wf-gq98-2v4g), `fast-uri` (high, GHSA-5jgf-p345-68v8, GHSA-f65p-4m7j-42xc, GHSA-fph4-wmhf-6fwf, GHSA-jqff-g426-hqxp), `qs` (moderate, GHSA-x5fp-wj9c-mxmx, GHSA-4mjr-xmp4-gh2g).
- **`extensions/drm-copilot`**: 3 vulnerabilities (1 moderate, 2 high) — `browserslist` (high), `fast-uri` (high), `qs` (moderate); same advisories as above.
- **`packages/mcp-server`**: 2 vulnerabilities (1 moderate, 1 high) — `fast-uri` (high), `qs` (moderate); same advisories as above.
- All four packages report `fix available via npm audit fix` in the CI log.
- These findings are confirmed unrelated to any recent PR's own diff: neither PR #624 (config/blast-radius.json mandate_reads fix) nor PR #626 (validate-bash.ps1 hook fix) touched any package.json, package-lock.json, or npm dependency.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: CI job logs for `NPM Audit Gate / npm audit (.)`, `NPM Audit Gate / npm audit (extensions/drm-copilot)`, `NPM Audit Gate / npm audit (packages/mcp-server)` on run https://github.com/drmoisan/drm-copilot/actions/runs/33750279774 (PR #626).

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

`fast-uri` and `qs` are shared transitive dependencies across all three workspaces (likely pulled in via a common devDependency such as ESLint/AJV tooling for `fast-uri`, and an HTTP/query-string library for `qs`). `browserslist` is a transitive dependency of the root and `extensions/drm-copilot` workspaces (likely via a build tool such as postcss/autoprefixer or a bundler). `@humanfs/node` is a transitive dependency of the root workspace only (likely via ESLint's flat-config tooling). None of these are direct dependencies this repo pins explicitly at the vulnerable version; the advisories were published/discovered after the last lockfile refresh in each workspace.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: no new unit tests required (dependency-lockfile-only change); verification is `npm audit --audit-level=moderate` exiting 0 in all three workspaces, plus a full re-run of each workspace's existing test suite to confirm the dependency bumps introduce no regressions (`npm test` / `npm run test:unit` in `extensions/drm-copilot`, `npm test` in `packages/mcp-server`, and any root-level TypeScript test suite).
- [x] Integration scenario to retest: re-run the CI-equivalent `NPM Audit Gate` check locally (`npm audit --audit-level=moderate`) in each of the three workspaces after applying `npm audit fix` (or explicit version bumps if `audit fix` alone is insufficient), and confirm it now exits 0.
- [x] Manual verification notes: `npm audit fix` must not introduce a breaking major-version bump to a direct dependency without review; if any advisory's fix requires `npm audit fix --force` (a breaking change), stop and flag it explicitly rather than applying it silently, since that crosses from a pure lockfile-hygiene fix into a real dependency-upgrade decision requiring separate review.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
