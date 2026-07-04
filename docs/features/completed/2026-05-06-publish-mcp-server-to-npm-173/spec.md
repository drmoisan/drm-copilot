# 2026-05-06-publish-mcp-server-to-npm — Spec

- **Issue:** #173
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-05-06T21-36
- **Status:** Draft
- **Version:** 0.1

## Overview

This feature publishes the drm-copilot MCP server as a standalone public npm package (`@danmoisan/drm-copilot-mcp`) so that consumers can invoke it via `npx` without cloning the repository or building from source. The implementation introduces a new `packages/mcp-server/` directory, extends the esbuild build to inject a Node.js shebang, ships the full `resources/` tree in the tarball, and adds a GitHub Actions workflow to automate publication on semver tag push.

## Behavior

### Build

Running `npm run build` inside `packages/mcp-server/` invokes the esbuild build script. The script bundles `extensions/drm-copilot/src/mcp-server.ts` and its transitive imports into a single CommonJS file at `packages/mcp-server/out/mcp-server.js`. The esbuild `banner: { js: "#!/usr/bin/env node" }` option prepends the shebang line. The `vscode` shim plugin remains in place to neutralize the top-level `vscode` import in `command-runtime.ts`, which is unreachable from the MCP execution path but present in the module graph.

### Package layout

`packages/mcp-server/` is a new top-level directory containing:

- `package.json` — npm metadata (name, version, bin, files, engines, license, repository, type, keywords, author, description, bugs, homepage)
- `esbuild-mcp-server.cjs` — esbuild build script with shebang banner added
- `tsconfig.json` — references source at `extensions/drm-copilot/src/mcp-server.ts` or delegates to the extension tsconfig
- `README.md` — consumer-facing documentation
- `out/mcp-server.js` — generated build artifact (not committed to source control)
- `resources/` — the full `extensions/drm-copilot/resources/` tree, present at the package root via a build-time copy step before packaging

### Runtime

When a consumer invokes `npx -y @danmoisan/drm-copilot-mcp`, npm downloads and caches the package, then executes `out/mcp-server.js` via Node. The process communicates over stdio using the MCP JSON-RPC protocol. `extensionRoot` is resolved as `path.resolve(__dirname, "..")`, which evaluates to the package root in an npm install, placing `resources/` at the expected location.

`workspace_root` defaults to `process.cwd()` when not supplied by the MCP tool caller. The MCP client configuration must set `cwd` to the consumer's destination workspace so tool calls that operate on files resolve to the correct location.

### Release

A GitHub Actions workflow (`.github/workflows/publish-mcp-npm.yml`) triggers on a push matching the tag pattern `mcp-server-v*` (e.g., `mcp-server-v0.1.0`). The workflow depends on the existing `drm-copilot-extension-tests` CI job defined in `.github/workflows/ci.yml` and proceeds to publish only when that job passes. Publication runs `npm publish --access public` in `packages/mcp-server/` using the `NPM_TOKEN` repository secret.

## Inputs / Outputs

**Inputs:**
- Source: `extensions/drm-copilot/src/mcp-server.ts` and its transitive imports
- Resources: `extensions/drm-copilot/resources/` (full tree)
- Build config: `packages/mcp-server/esbuild-mcp-server.cjs`
- Version source: `extensions/drm-copilot/package.json` `version` field
- Release trigger: git tag matching `mcp-server-v*`
- Publish secret: `NPM_TOKEN` GitHub repository secret

**Outputs:**
- `packages/mcp-server/out/mcp-server.js` — esbuild bundle with shebang
- npm tarball containing `out/mcp-server.js` and `resources/` tree
- Published package `@danmoisan/drm-copilot-mcp@<version>` on registry.npmjs.org

**Excluded from tarball:** `src/`, `tests/`, `*.ts`, `*.cjs`, `.gitignore`, `tsconfig*.json`, `coverage/`

## API / CLI Surface

**Consumer invocation:**
```
npx -y @danmoisan/drm-copilot-mcp
```

**MCP client configuration (Claude Desktop / Codex / compatible clients):**
```json
{
  "mcpServers": {
    "drm-copilot": {
      "command": "npx",
      "args": ["-y", "@danmoisan/drm-copilot-mcp"],
      "cwd": "/absolute/path/to/destination/workspace"
    }
  }
}
```

**`bin` declaration in `package.json`:**
```json
"bin": {
  "drm-copilot-mcp": "./out/mcp-server.js"
}
```

The MCP tool API surface (tool names, input schemas, and output shapes) is unchanged from the VS Code extension's MCP server. No new tools are added by this feature.

## Data & State

- **Version coupling:** `packages/mcp-server/package.json` `version` field must match `extensions/drm-copilot/package.json` `version` at the time of tagging. This is a manual synchronization step in the release process; no automated version-bump tooling is added by this feature.
- **Resources:** The `resources/` tree is present at the package root, which is the parent directory of `out/`. The `extensionRoot` resolver in `mcp-server.ts` (`path.resolve(__dirname, "..")`) locates it there at runtime.
- **No persistent state:** The MCP server is stateless per invocation. No database or file-based state is introduced.
- **Caching:** npm caches downloaded packages in the local npm cache directory. No application-level caching is introduced.

## Constraints & Risks

- **Tarball size:** The `resources/` tree includes Python scripts, PowerShell scripts, and Markdown templates. The tarball will be larger than a typical single-file npm package. This is accepted per the locked decision; `npx` cold-start latency will increase proportionally.
- **Runtime prerequisites:** Node >=18 is mandatory. Several MCP tools require Python 3 and PowerShell 7+ on the consumer's PATH; absence of these will result in tool execution errors, not server startup failures.
- **npm account prerequisite:** The `danmoisan` npm account, automation token, and `NPM_TOKEN` secret are required for the actual publish step. These do not block implementation or local testing.
- **VS Code shim dependency:** `command-runtime.ts` has a top-level `import * as vscode from "vscode"`. The esbuild shim (`module.exports = {}`) must remain in the build config. Removing it would cause a require-time error.
- **`extensionRoot` path assumption:** `mcp-server.ts` assumes `__dirname` is inside a directory whose parent is the package root containing `resources/`. Placing `out/mcp-server.js` deeper than one level from the package root would break resource resolution.
- **LICENSE gap:** No `LICENSE` file exists at the repo root. The `docs-validation` CI job blocks on this. Adding `LICENSE` is in scope for this feature.

## Implementation Strategy

### New `packages/mcp-server/` directory

Create `packages/mcp-server/` with the following structure:

```
packages/mcp-server/
├── package.json
├── esbuild-mcp-server.cjs
├── tsconfig.json
├── README.md
└── out/             (gitignored; generated by build)
    └── mcp-server.js
```

The `resources/` tree is included in the tarball via a build-time copy step (e.g., a `prepack` npm script that copies `../../extensions/drm-copilot/resources` to `./resources`). The copy must complete before `npm pack` or `npm publish` runs.

### esbuild bundle with shebang banner

In `packages/mcp-server/esbuild-mcp-server.cjs`, add the following to the esbuild `build()` call:

```js
banner: { js: "#!/usr/bin/env node" },
```

All other build options (entry point, bundle, platform, external, vscode shim plugin) remain equivalent to the extension's existing build script.

### `package.json` metadata

Required fields:

```json
{
  "name": "@danmoisan/drm-copilot-mcp",
  "version": "<mirrors extensions/drm-copilot/package.json version>",
  "description": "Stdio MCP server exposing drm-copilot repo-automation tools.",
  "license": "MIT",
  "type": "commonjs",
  "bin": {
    "drm-copilot-mcp": "./out/mcp-server.js"
  },
  "files": [
    "out/mcp-server.js",
    "resources"
  ],
  "engines": {
    "node": ">=18.0.0"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/drmoisan/drm-copilot.git",
    "directory": "packages/mcp-server"
  },
  "bugs": {
    "url": "https://github.com/drmoisan/drm-copilot/issues"
  },
  "homepage": "https://github.com/drmoisan/drm-copilot#readme",
  "keywords": ["mcp", "copilot", "claude", "codex", "automation", "workflow", "stdio"],
  "author": "Dan Moisan"
}
```

### GitHub Actions workflow

Create `.github/workflows/publish-mcp-npm.yml` that triggers on `mcp-server-v*` tag pushes. The workflow must declare a `needs` dependency on the `drm-copilot-extension-tests` job from `ci.yml`. The publish step runs `npm publish --access public` in `packages/mcp-server/` with `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}`. If `ci.yml` does not expose a `workflow_call` trigger, the extension test steps must be duplicated or the job structure adjusted to establish the dependency gate.

### LICENSE file

Create `LICENSE` at the repository root containing the standard MIT license text with copyright holder `Dan Moisan`. This unblocks the `docs-validation` CI job, which currently fails due to the missing file.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] `npm pack` tarball contents match the `files` whitelist: `out/mcp-server.js` and `resources/` tree present; test sources absent.
- [ ] First line of `out/mcp-server.js` is `#!/usr/bin/env node`.
- [ ] `packages/mcp-server/package.json` `name` field is `@danmoisan/drm-copilot-mcp`.
- [ ] `packages/mcp-server/package.json` `engines.node` is `>=18.0.0`.
- [ ] Version in `packages/mcp-server/package.json` matches `extensions/drm-copilot/package.json` at tag time.
- [ ] `docs-validation` CI job passes after LICENSE is added.
- [ ] `.github/workflows/publish-mcp-npm.yml` is syntactically valid YAML and the publish step is correctly gated on extension-tests.
