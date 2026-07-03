# Research: Publishing the drm-copilot MCP Server to the Public npm Registry

Date: 2026-05-04

---

## Executive Summary

1. **Introduce a new sibling package `packages/mcp-server/`** that owns its own `package.json`, copies the esbuild bundle script, and declares only the subset of the extension's source that the MCP path actually uses. This avoids polluting an npm package with VS Code manifests (`contributes`, `activationEvents`, `engines.vscode`) and 10+ VS Code-only devDependencies.

2. **Use the scoped name `@danmoisan/drm-copilot-mcp`**. Publish with `npm publish --access public`. The `npx -y @danmoisan/drm-copilot-mcp` UX is identical to unscoped. The scoped name is available without checking availability against a crowded unscoped namespace.

3. **Publish the esbuild single-file bundle** (`out/mcp-server.js`). The bundle is already vscode-free due to the shim. Add a `#!/usr/bin/env node` shebang and declare it under `bin`. `files` whitelist must include `out/mcp-server.js` only. Do not ship source, test, or template assets.

4. **Use a GitHub Actions workflow triggered on a semver tag**. Gate the release step on the existing extension unit test job. Store `NPM_TOKEN` as a repository secret. No changesets or semantic-release is required at v0 scale.

5. **Add a top-level `LICENSE` file** before the first publish. The CI `docs-validation` job already blocks on its absence (`ci.yml` line 127). The extension's `package.json` declares MIT but the repo root has no `LICENSE` file.

---

## Finding 1: Package Layout

### Evidence

The MCP server entry point is `extensions/drm-copilot/src/mcp-server.ts`. Its import graph reaches:

| Module | VS Code API usage |
|---|---|
| `mcp-server.ts` | None. Zero `vscode.` occurrences confirmed by grep. |
| `command-runtime.ts` | Uses `vscode.` at lines 98–99 (`createOutputChannel`), 129 (`getWorkspaceRoot`), 407 (`executeBundledScript`). Those three functions are **not reachable** from the MCP path. |
| `mcp-tools.ts` | No `vscode` import. |
| `mcp-tool-inputs.ts` | No `vscode` import. |
| `workflow-command-arguments.ts` | No `vscode` import. |
| `mcp-handlers/*.ts` | No `vscode` imports in any handler file. |
| `repo-automation-service.ts` | No `vscode` import; uses `executeBundledScriptFromExtensionRoot` (pure Node). |

The esbuild shim in `esbuild-mcp-server.cjs` resolves `vscode` as `module.exports = {}` precisely because `command-runtime.ts` has a top-level `import * as vscode from "vscode"` (line 4) that is pulled in transitively, but **none of the VS Code API calls in that file are on the MCP execution path**. The shim is therefore a safety net, not a functional requirement in the steady state.

### Three options evaluated

**Option A — Publish `extensions/drm-copilot/` as-is.**
Rejected. The extension `package.json` contains `contributes` (24 commands, 1 MCP provider), `activationEvents`, `engines.vscode: "^1.108.0"`, and devDeps including `@types/vscode`, `@vscode/test-cli`, `@vscode/test-electron`. npm consumers would install none of the bundled Python/PowerShell template resources meaningfully via `npx`. The `main` field points to `out/extension.js` (the VS Code host entrypoint), not the MCP server. Repurposing this package for npm is not appropriate.

**Option B — Introduce `packages/mcp-server/` (recommended).**
A new directory with its own `package.json` declaring `bin`, `files`, `name`, `version`, and `dependencies: { "@modelcontextprotocol/sdk": "^1.29.0" }`. The esbuild bundle script (`esbuild-mcp-server.cjs`) is copied or symlinked. The compile step runs `tsc` against the same source tree (pointing at `extensions/drm-copilot/src/mcp-server.ts`) then esbuild produces `out/mcp-server.js`. The new package ships only the bundle; no source, no VS Code fields.

**Option C — Monorepo restructure with shared core.**
Overkill for the current state. The MCP path is already cleanly separated from VS Code APIs at the source level. Introducing a shared `packages/core/` package adds build complexity (tsc project references or tsup) with no current benefit.

### Recommendation

**Option B.** The extraction is clean. The only VS Code coupling in the transitive MCP graph is a top-level import in `command-runtime.ts` that the esbuild shim already neutralizes. No source files require modification. The new package references the existing source via a relative `tsconfig.json` path or copies the compiled artifact from the extension's `out/` directory.

---

## Finding 2: `bin` and `npx` Mechanics

For `npx -y @danmoisan/drm-copilot-mcp` to work:

### Required `package.json` fields

```json
{
  "name": "@danmoisan/drm-copilot-mcp",
  "version": "0.1.0",
  "description": "Stdio MCP server exposing drm-copilot repo-automation tools.",
  "license": "MIT",
  "bin": {
    "drm-copilot-mcp": "./out/mcp-server.js"
  },
  "files": [
    "out/mcp-server.js"
  ],
  "engines": {
    "node": ">=18.0.0"
  },
  "type": "commonjs"
}
```

### Shebang

The first line of `out/mcp-server.js` must be:

```
#!/usr/bin/env node
```

The esbuild `banner` option can inject this automatically:

```js
esbuild.build({
  // ...existing options...
  banner: { js: "#!/usr/bin/env node" },
});
```

Without the shebang, `npx` on Linux/macOS will fail to execute the file directly. On Windows, npm installs a `.cmd` shim that always invokes `node <path>`, so the shebang is not strictly required on Windows, but it is required for cross-platform portability.

### Windows-specific notes

npm automatically creates `.cmd`, `.ps1`, and bare wrappers in `node_modules/.bin/` for every `bin` entry. No manual action is required. Line endings in the bundle file do not need special treatment; `node` on Windows handles both `CRLF` and `LF` in JS files. The executable bit (Unix) is set by npm during install, not in the source file.

### `type` field

The esbuild output uses CommonJS (`require`/`module.exports`) because the extension target is CommonJS (the `esbuild-mcp-server.cjs` does not set `format: "esm"`). Set `"type": "commonjs"` or omit the `type` field entirely (defaults to `commonjs`). Do not set `"type": "module"`.

---

## Finding 3: Scoped vs Unscoped Name

### Scoped: `@danmoisan/drm-copilot-mcp`

- Requires `npm publish --access public` (scoped packages default to restricted).
- The `danmoisan` npm scope is tied to the npm user `danmoisan`. No separate org account is needed; a free npm account owning that username controls the scope automatically.
- `npx -y @danmoisan/drm-copilot-mcp` works identically to unscoped from a consumer's perspective. The `@scope/name` form is a fully supported `npx` target.
- Zero risk of name collision. The namespace `@danmoisan/*` is exclusively yours.

### Unscoped: `drm-copilot-mcp`

- Requires checking availability on the public registry before publishing.
- `npm publish` without `--access public` works (unscoped packages default to public).
- Name squatting is possible; the name `drm-copilot-mcp` may be taken.
- Slightly shorter consumer config string.

### Recommendation

**Use `@danmoisan/drm-copilot-mcp`.** The namespace is guaranteed available, `npx` UX is equivalent, and the single extra flag (`--access public`) is a one-time configuration. For MCP client config files, the scoped form is unambiguous and self-documenting.

---

## Finding 4: Versioning and Release Pipeline

### CI baseline

The existing `ci.yml` runs the extension unit test job `drm-copilot-extension-tests` on `ubuntu-latest` and `windows-latest` for every push and PR. A publish workflow can depend on this job.

### Recommended flow: GitHub Actions on semver tag

This is the simplest approach that gates publishes on green CI without requiring changesets or semantic-release.

**Workflow sketch (high level):**

```yaml
name: Publish MCP Server

on:
  push:
    tags:
      - "mcp-server/v*"   # e.g., mcp-server/v0.1.0

jobs:
  test:
    uses: ./.github/workflows/ci.yml   # reuse or duplicate the extension test steps

  publish:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          registry-url: "https://registry.npmjs.org"
      - run: npm ci
        working-directory: packages/mcp-server
      - run: npm run build
        working-directory: packages/mcp-server
      - run: npm publish --access public
        working-directory: packages/mcp-server
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

**Steps to enable:**
1. Create an npm automation token (read-write, automation type) on npmjs.com.
2. Add it as repository secret `NPM_TOKEN` in GitHub settings.
3. Tag a release: `git tag mcp-server/v0.1.0 && git push origin mcp-server/v0.1.0`.

**Rejected alternatives:**
- Manual `npm publish` from maintainer machine: no CI gate, no audit trail.
- `changesets`: adds a changeset PR workflow suitable for multi-package monorepos; unnecessary overhead at v0 single-package scale.
- `semantic-release`: requires commit convention compliance across the whole repo; introduces a config surface that conflicts with the current manual-tagging workflow.

---

## Finding 5: Build Output Format

### Options

**A — esbuild single-file bundle (recommended).** `out/mcp-server.js` is a fully self-contained CommonJS file with all dependencies inlined. No `node_modules` are required at runtime. `npx` downloads only the package itself; consumers pay zero install time for transitive dependencies. The vscode shim is already embedded. File size will be small (the MCP SDK is the main dependency).

**B — tsc multi-file output.** Requires shipping `node_modules` or declaring `@modelcontextprotocol/sdk` as a runtime `dependency` in the npm package, which adds installation weight and transitive dependency surface for all consumers.

**C — Both.** No consumer scenario benefits from having both. The bundle is always preferred for `npx` use.

### Recommendation

**Option A.** The esbuild bundle is already proven to work standalone (it is what the VS Code extension runs). Set `"files": ["out/mcp-server.js"]` in the npm package. The `bin` entry resolves directly to that file at runtime. No `node_modules` or additional install steps are required on the consumer machine.

---

## Finding 6: Required npm Metadata

Fields required or strongly recommended for a public npm package, mapped to current state:

| Field | Required/Recommended | Current State | Action |
|---|---|---|---|
| `name` | Required | Extension: `drm-copilot` (wrong for npm) | New package: `@danmoisan/drm-copilot-mcp` |
| `version` | Required | `0.0.1` | Bump to `0.1.0` for first npm release |
| `description` | Recommended | Present in extension `package.json` | Copy/adapt |
| `license` | Required | `"MIT"` in extension `package.json` | Copy to new package `package.json` |
| `repository` | Recommended | Present in extension `package.json` | Copy; update `directory` to `packages/mcp-server` |
| `bugs` | Recommended | Present in extension `package.json` | Copy |
| `homepage` | Recommended | Present in extension `package.json` | Copy |
| `keywords` | Recommended | `["mcp","copilot","claude","codex","automation","workflow"]` | Copy; add `"stdio"` |
| `author` | Recommended | Not in extension `package.json` | Add: `"Dan Moisan <dan@danmoisan.org>"` |
| `engines.node` | Recommended | Not present | Add: `">=18.0.0"` |
| `files` | Required for correctness | Not applicable to extension | `["out/mcp-server.js"]` |
| `bin` | Required for `npx` | Not in extension `package.json` | Add (see Finding 2) |
| `type` | Recommended | Not in extension `package.json` | Add `"commonjs"` |
| `main` | Optional | Extension uses `out/extension.js` | Omit in npm package (bin is sufficient) |

### LICENSE file

**The repo root has no `LICENSE` file.** Confirmed: a glob for `LICENSE` at the root returned no results. The `docs-validation` CI job (`ci.yml`, line 127) fails if `LICENSE` is absent. The extension `package.json` declares `"license": "MIT"` but that field alone does not satisfy npm's requirement for a license file in the published tarball.

**Action required:** Create `LICENSE` (MIT text) at the repository root before the first npm publish. The extension's existing MIT declaration makes the choice unambiguous.

---

## Finding 7: MCP Consumer Wiring

### How the extension invokes the server today

`extensions/drm-copilot/src/mcp-provider.ts` lines 34–41:

```ts
const serverDef = new vscode.McpStdioServerDefinition(
  "drmCopilotExtension",
  "node",
  [
    vscode.Uri.joinPath(context.extensionUri, "out", "mcp-server.js").fsPath,
  ],
);
```

The server runs as a stdio child process. `cwd` is set to the first workspace folder when one is open (lines 45–48). No additional environment variables are injected. The transport is plain stdio (stdin/stdout JSON-RPC per MCP protocol).

### npm-distributed consumer config

For Claude Desktop, Codex, or any MCP client that accepts a stdio server definition:

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

The `cwd` field is critical. The MCP server uses `process.cwd()` as the fallback `workspace_root` when no `workspace_root` argument is supplied by the tool caller (see `mcp-tools.ts` line 68: `return process.cwd()`; and `workflow-command-arguments.ts` line 278: `fallbackWorkspaceRoot: string = process.cwd()`).

The stdio contract (stdin for MCP requests, stdout for responses, stderr for diagnostics) is preserved by the esbuild bundle exactly as the extension uses it.

---

## Finding 8: Risks and Open Questions

### VS Code workspace context at runtime

**`mcp-server.ts` contains zero `vscode.` calls** — confirmed by grep returning no matches.

The transitive dependency `command-runtime.ts` has three VS Code API call sites:
- Line 98–99: `createOutputChannel()` — called only from the VS Code extension host path. Not reachable from the MCP server.
- Line 129: `getWorkspaceRoot()` — calls `vscode.workspace.workspaceFolders?.[0]`. This function is **not called** from the MCP path. The MCP server creates its own `RepoAutomationService` via `createRepoAutomationService` in `mcp-server.ts` (line 71), which takes `extensionRoot` as a constructor argument and `workspaceRoot` as a per-call argument supplied by the MCP tool input.
- Line 407: `executeBundledScript()` — VS Code host only. Not reachable from MCP path.

The shim `module.exports = {}` is sufficient because none of these VS Code properties are accessed at MCP server startup or during tool dispatch.

### `extensionRoot` resolution in npm mode

`mcp-server.ts` line 30: `return path.resolve(__dirname, "..")`. In the esbuild bundle, `__dirname` resolves to the directory containing `mcp-server.js`. In the npm package, that is `<npx-cache>/out/`. Therefore `extensionRoot` resolves to `<npx-cache>/` — the package root.

The `extensionRoot` is used for:
1. Reading `package.json` for the version string (line 34 in `mcp-server.ts`). Works correctly; `package.json` is in the npm package root.
2. Resolving bundled script paths (`resources/templates/*.py`, `resources/templates/*.ps1`, `resources/scripts/dev_tools/*.py`). **These resource files must be included in the npm package** for tool execution to succeed.

### Bundled resource files

The extension's `resources/` directory contains Python scripts, PowerShell scripts, feature templates, and customization files. These are the actual tool payloads. If the npm package ships only `out/mcp-server.js`, tool calls that invoke bundled scripts will fail with a "file not found" error when `resolveBundledScriptPath` tries to locate them relative to `extensionRoot`.

**This is the most significant open question.** Options:
1. Include `resources/` in the npm package `files` array. This is the minimal-change approach but substantially increases tarball size and ships Python/PowerShell/Markdown template assets as npm payload.
2. Accept a CLI argument or environment variable for `extensionRoot` so the consumer points the server at a local checkout of the extension. This breaks the zero-install `npx` goal.
3. Embed resource files in the esbuild bundle using esbuild's `loader: "text"` or `dataurl` options, then write them to a temp directory at startup. This preserves zero-install but adds startup complexity.

Until this is resolved, an npm-distributed server that runs tools via `executeBundledScriptFromExtensionRoot` (which is all tools except `resolvePolicyAuditTemplateAsset`'s copy path) will fail to locate the scripts.

**The `resolvePolicyAuditTemplateAsset` tool** (`repo-automation-service-workflows.ts` lines 109–116) copies from the bundled `resources/customizations/` tree, making it similarly dependent on `extensionRoot` containing that tree.

### `workspace_root` parameter

Every MCP tool call accepts an optional `workspace_root` argument (string). When supplied, it overrides `process.cwd()`. The MCP client config's `cwd` field sets the process working directory, which becomes the fallback. Either mechanism works without VS Code. The destination workspace does not need to be "open" in any IDE — the path just needs to exist on disk.

---

## Open Questions for the User

1. **Resources inclusion strategy**: Should the npm package include `resources/` (Python scripts, PowerShell scripts, templates) as static files alongside the bundle? Or should an alternative packaging strategy (embedding in bundle, or a separate download step) be pursued? This decision gates whether the tools work out-of-the-box in `npx` mode.

2. **Package directory location**: Should the new npm package live at `packages/mcp-server/` (new top-level `packages/` directory) or at `extensions/mcp-server/` (sibling to the VS Code extension)?

3. **Version coupling**: Should the npm package version track the VS Code extension version (`0.0.1` → `0.0.1`) or maintain an independent versioning sequence?

4. **npm account**: Is the `danmoisan` username on npmjs.com already claimed by you? If not, account creation is a prerequisite before the scoped publish can proceed.

5. **`npx` cold-start latency**: `npx -y` downloads and caches the package on first run. If the package includes `resources/` (potentially several MB of template files), the cold-start time increases. Is this acceptable, or should a minimal server with a separate resource-fetch mechanism be considered?

6. **Python and PowerShell runtime requirement**: Several MCP tools require `python` or `pwsh` on the destination machine's PATH. Should the npm package's `README` or startup message surface this requirement explicitly?

---

## References

| File | Line(s) | Relevance |
|---|---|---|
| `extensions/drm-copilot/src/mcp-server.ts` | 1–136 | MCP server entry point; no vscode calls; `resolveExtensionRoot` uses `__dirname` |
| `extensions/drm-copilot/src/command-runtime.ts` | 4, 98–99, 129, 407 | VS Code API call sites; none reachable from MCP path |
| `extensions/drm-copilot/src/mcp-provider.ts` | 34–48 | Stdio server definition; CWD wiring |
| `extensions/drm-copilot/src/mcp-tools.ts` | 62–75 | `inferWorkspaceRoot` fallback to `process.cwd()` |
| `extensions/drm-copilot/src/workflow-command-arguments.ts` | 276–285 | `normalizeWorkspaceRoot` fallback to `process.cwd()` |
| `extensions/drm-copilot/esbuild-mcp-server.cjs` | 1–36 | vscode shim plugin; bundle config |
| `extensions/drm-copilot/package.json` | 28–30, 141–166 | VS Code engine field; single runtime dependency on `@modelcontextprotocol/sdk` |
| `.github/workflows/ci.yml` | 295–318 | Extension test job (ubuntu + windows); baseline for release gate |
| `.github/workflows/ci.yml` | 125–128 | LICENSE file check in `docs-validation` job |
| `extensions/drm-copilot/src/repo-automation-service.ts` | 154–163, 455–465 | `extensionRoot` used to resolve bundled script paths |
| `extensions/drm-copilot/src/repo-automation-service-workflows.ts` | 191–193 | `buildTemplateRoot` resolves `resources/feature-templates` from `extensionRoot` |
