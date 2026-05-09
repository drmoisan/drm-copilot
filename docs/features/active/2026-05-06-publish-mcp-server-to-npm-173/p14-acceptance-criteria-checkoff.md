# Acceptance Criteria Check-off — publish-mcp-server-to-npm

- **Issue:** #173
- **Feature:** publish-mcp-server-to-npm
- **Branch:** feature/publish-mcp-server-to-npm-173
- **Work Mode:** full-feature
- **Final Review Status:** PASS (policy-audit.2026-05-07T09-00.md, feature-audit.2026-05-07T09-00.md)
- **Completed:** 2026-05-07

## Acceptance Criteria Verification

| AC | Description | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | `packages/mcp-server/` exists with publishable package.json (name, bin, files, engines, license, repository, type) | PASS | `packages/mcp-server/package.json` verified by P1-T2 acceptance check; `artifacts/evidence/post-change/npm-publish-dry-run.md` |
| AC2 | esbuild build produces `out/mcp-server.js` starting with `#!/usr/bin/env node` | PASS | P2-T3 acceptance check (`head -1 packages/mcp-server/out/mcp-server.js`); `artifacts/evidence/post-change/npm-pack-listing.md` |
| AC3 | `npm pack` tarball includes `out/mcp-server.js` and `resources/` tree; excludes test sources | PASS | P6-T1 and P6-T2 tarball inspection; `artifacts/evidence/post-change/npm-pack-listing.md` |
| AC4 | Top-level MIT LICENSE exists at repo root; docs-validation CI job passes | PASS | `LICENSE` file present at repository root; P3-T2 verification (`test -f LICENSE`) |
| AC5 | `.github/workflows/publish-mcp-npm.yml` present; triggers on `mcp-server-v*`; depends on extension-tests; uses NPM_TOKEN; runs `npm publish --access public` | PASS | P4-T1 grep checks; P4-T2 YAML validation; actionlint passed in remediation Phase 4 |
| AC6 | README.md documents `npx -y @danmoisan/drm-copilot-mcp` usage; MCP config snippet with cwd; runtime prerequisites (Node >=18, Python 3, pwsh 7+) | PASS | P1-T5 grep checks; remediation P1-T1 added cwd field; `packages/mcp-server/README.md` |
| AC7 | Package version equals `extensions/drm-copilot/package.json` version at release time | PASS | Both set to `0.0.1`; P1-T2 acceptance check; `artifacts/evidence/post-change/ac-verification.md` |

## AC Source Files

- `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/issue.md` — all AC1–AC7 checked `[x]`
- `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/user-story.md` — all AC1–AC7 checked `[x]`

## Review Artifacts

- `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/policy-audit.2026-05-07T09-00.md`
- `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/code-review.2026-05-07T09-00.md`
- `docs/features/active/2026-05-06-publish-mcp-server-to-npm-173/feature-audit.2026-05-07T09-00.md`

## External Prerequisites for Merge and Release

The following actions are outside the scope of this PR and must be completed by the maintainer before executing the first live npm publish:

1. Register the `danmoisan` username on npmjs.com.
2. Create an npm automation token (read-write, automation type).
3. Add the token as the `NPM_TOKEN` repository secret in GitHub repository settings.

After these prerequisites are satisfied, publish by pushing a semver tag matching `mcp-server-v*` (e.g., `git tag mcp-server-v0.0.1 && git push origin mcp-server-v0.0.1`).
