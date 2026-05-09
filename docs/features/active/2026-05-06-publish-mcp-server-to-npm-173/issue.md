# publish-mcp-server-to-npm (Issue #173)

- Date captured: 2026-05-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/publish-mcp-server-to-npm/ (Issue #173)

- Issue: #173
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/173
- Last Updated: 2026-05-07
- Work Mode: full-feature

## Problem / Why

The drm-copilot MCP server (`extensions/drm-copilot/src/mcp-server.ts`) runs as a Node.js stdio process with no dependency on the VS Code extension host. Consumers who want to use it with Claude Desktop, Codex, or other MCP-compatible clients must currently clone the repository and run the server from a local build. There is no public distribution path. Publishing the server to the npm registry under `@danmoisan/drm-copilot-mcp` allows any consumer to invoke it via `npx -y @danmoisan/drm-copilot-mcp` without a local checkout or build step.

## Proposed Behavior

Introduce a new `packages/mcp-server/` directory containing a standalone `package.json`, an esbuild build script that produces `out/mcp-server.js` with a `#!/usr/bin/env node` shebang, and a `README.md` documenting installation, MCP client configuration, and runtime prerequisites. Publish the package to the public npm registry as `@danmoisan/drm-copilot-mcp`. The published tarball includes `out/mcp-server.js` and the full `extensions/drm-copilot/resources/` tree. The package version tracks `extensions/drm-copilot/package.json`. A GitHub Actions workflow triggers on a `mcp-server-v*` semver tag push, gates on the existing extension-tests CI job, and publishes using an `NPM_TOKEN` repository secret.

## Acceptance Criteria (early draft)

- [x] AC1. `packages/mcp-server/` exists with a publishable package.json (correct name, bin, files, engines, license, repository, type).
- [x] AC2. The esbuild build produces an `out/mcp-server.js` bundle starting with `#!/usr/bin/env node`.
- [x] AC3. The published tarball, when generated locally via `npm pack`, includes `out/mcp-server.js` and the `resources/` tree, and excludes test sources.
- [x] AC4. A top-level MIT LICENSE file exists at the repo root and the docs-validation CI job passes.
- [x] AC5. A GitHub Actions workflow at `.github/workflows/publish-mcp-npm.yml` (or equivalent) is present, triggers on a semver tag push (pattern `mcp-server-v*`), depends on the existing extension-tests job, uses NPM_TOKEN, and runs `npm publish --access public`.
- [x] AC6. README.md inside the package documents: install/usage via `npx -y @danmoisan/drm-copilot-mcp`, the MCP client config snippet (command/args/cwd), and the runtime prerequisites (Node >=18 mandatory; Python 3 and pwsh 7+ for script-backed tools).
- [x] AC7. The package version equals the version in extensions/drm-copilot/package.json at release time.

## Constraints & Risks

- The `resources/` tree contains Python scripts, PowerShell scripts, and Markdown templates. Including the full tree in the npm tarball increases package size. This is accepted per the locked decision to ship resources.
- The npm publish step requires a pre-existing `danmoisan` account on npmjs.com, an npm automation token, and that token stored as `NPM_TOKEN` in GitHub repository secrets. These prerequisites do not block implementation but do block the actual publish.
- The `docs-validation` CI job currently fails because no `LICENSE` file exists at the repository root. Adding this file is part of this feature's scope.
- The MCP server requires Node >=18 at runtime; several tools additionally require Python 3 and PowerShell 7+ on the consumer's PATH. Consumers must be informed of these prerequisites via the package README.

## Test Conditions to Consider

- [ ] `npm pack` output listing matches the `files` whitelist: `out/mcp-server.js` and `resources/` tree present; test sources absent.
- [ ] `out/mcp-server.js` first line is `#!/usr/bin/env node`.
- [ ] The GitHub Actions workflow `.github/workflows/publish-mcp-npm.yml` is syntactically valid and correctly references the extension-tests job.
- [ ] `docs-validation` CI job passes after adding `LICENSE`.
- [ ] `packages/mcp-server/package.json` passes `npm publish --dry-run --access public` without errors.
- [ ] Package version in `packages/mcp-server/package.json` matches `extensions/drm-copilot/package.json` at the time of tagging.

## Next Step

- [ ] Implement `packages/mcp-server/` directory with `package.json`, esbuild build script, and `README.md`.
- [ ] Add `#!/usr/bin/env node` shebang banner to the esbuild build configuration.
- [ ] Add `resources/` to the `files` whitelist in `packages/mcp-server/package.json` and arrange a build-time copy step.
- [ ] Create a top-level `LICENSE` file (MIT) at the repository root.
- [ ] Author `.github/workflows/publish-mcp-npm.yml` workflow.
- [ ] Verify all AC1–AC7 locally before tagging.
- [ ] Satisfy the external prerequisites (npm account, automation token, `NPM_TOKEN` secret) before executing the first publish.