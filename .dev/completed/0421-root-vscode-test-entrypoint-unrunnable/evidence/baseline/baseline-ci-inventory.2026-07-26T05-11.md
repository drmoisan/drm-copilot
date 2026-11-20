# Baseline — CI Inventory: No Workflow Runs the Root TypeScript Toolchain (#421)

Timestamp: 2026-07-26T05-11

Task: [P0-T10] — AC8(b) evidence.

Command:

```
rg -n "jest|run-jest|test:unit|vscode-test|npm test|npm run test" .github/workflows/
rg -n "npm" .github/workflows/
```

(Executed via the repository's ripgrep-backed search tool against `.github/workflows/`.)

EXIT_CODE: 0

## Result 1 — Root-toolchain invocation search (expected zero matches)

Pattern: `jest|run-jest|test:unit|vscode-test|npm test|npm run test`
Scope: `.github/workflows/` (all files)

```
No matches found
```

**Zero matches.** No workflow file under `.github/workflows/` references `jest`, `run-jest`, `test:unit`, `vscode-test`, root `npm test`, or root `npm run test`. Confirms the spec's Context finding: the root TypeScript toolchain and the root jest suite (`tests/unit/hello-typescript.test.ts`) are unexercised by CI at baseline.

## Result 2 — Full `npm` inventory (context for the zero-match claim)

Pattern: `npm`
Scope: `.github/workflows/`

```
.github/workflows/_npm-audit-gate.yml:1:name: npm Audit Gate (reusable)
.github/workflows/_npm-audit-gate.yml:24:  npm-audit:
.github/workflows/_npm-audit-gate.yml:25:    name: npm audit (${{ matrix.manifest }})
.github/workflows/_npm-audit-gate.yml:43:          cache: npm
.github/workflows/_npm-audit-gate.yml:48:        run: npm ci
.github/workflows/_npm-audit-gate.yml:54:        run: npm audit --audit-level="$AUDIT_LEVEL"
.github/workflows/_drm-copilot-extension-tests.yml:23:          cache: npm
.github/workflows/_drm-copilot-extension-tests.yml:27:        run: npm --prefix extensions/drm-copilot ci
.github/workflows/_drm-copilot-extension-tests.yml:30:        run: npm --prefix extensions/drm-copilot run test
.github/workflows/README.md:78:   by `_npm-audit-gate.yml` / `npm-audit-gate.yml` in this same directory.
.github/workflows/publish-mcp-npm.yml:1:name: Publish MCP Server to npm
.github/workflows/publish-mcp-npm.yml:26:        run: npm --prefix extensions/drm-copilot ci
.github/workflows/publish-mcp-npm.yml:29:        run: npm --prefix extensions/drm-copilot run test
.github/workflows/publish-mcp-npm.yml:32:    name: Publish to npm
.github/workflows/publish-mcp-npm.yml:46:          registry-url: "https://registry.npmjs.org"
.github/workflows/publish-mcp-npm.yml:48:      - name: Upgrade npm for trusted publishing
.github/workflows/publish-mcp-npm.yml:49:        run: npm install -g npm@11.18.0
.github/workflows/publish-mcp-npm.yml:52:        run: npm --prefix packages/mcp-server ci
.github/workflows/publish-mcp-npm.yml:55:        run: npm --prefix packages/mcp-server run prepack
.github/workflows/publish-mcp-npm.yml:58:        run: npm --prefix packages/mcp-server run build
.github/workflows/publish-extension.yml:34:        run: npm --prefix extensions/drm-copilot ci
.github/workflows/publish-extension.yml:37:        run: npm --prefix extensions/drm-copilot run test
.github/workflows/publish-extension.yml:53:        run: npm --prefix extensions/drm-copilot ci
.github/workflows/publish-extension.yml:56:        run: npm --prefix extensions/drm-copilot run compile
.github/workflows/npm-audit-gate.yml:1:name: npm Audit Gate
.github/workflows/npm-audit-gate.yml:13:      - ".github/workflows/npm-audit-gate.yml"
.github/workflows/npm-audit-gate.yml:14:      - ".github/workflows/_npm-audit-gate.yml"
.github/workflows/ci.yml:32:  npm-audit-gate:
.github/workflows/ci.yml:19:    uses: ./.github/workflows/_npm-audit-gate.yml
```

## Analysis of every `npm run test` occurrence at baseline

| Workflow | Invocation | Is it the root TypeScript toolchain? |
|---|---|---|
| `_drm-copilot-extension-tests.yml:30` | `npm --prefix extensions/drm-copilot run test` | No. `--prefix extensions/drm-copilot` runs the **extension's own** package manifest and its own jest suite, not the repository-root manifest. |
| `publish-mcp-npm.yml:29` | `npm --prefix extensions/drm-copilot run test` | No. Same extension-prefixed suite, in a publish workflow. |
| `publish-extension.yml:37` | `npm --prefix extensions/drm-copilot run test` | No. Same extension-prefixed suite, in a publish workflow. |
| `_npm-audit-gate.yml:48,54` | `npm ci` then `npm audit` | No. Installs and audits dependencies per matrix manifest; runs no test or toolchain stage. |
| `publish-mcp-npm.yml:52,55,58` | `npm --prefix packages/mcp-server ci/prepack/build` | No. MCP server package, not the repository root. |

Every `npm run test` occurrence in `.github/workflows/` at baseline is `--prefix`-scoped to `extensions/drm-copilot` or `packages/mcp-server`. **No workflow executes the repository-root `package.json` `test`, `test:unit`, `format:check`, `lint`, or `typecheck` scripts.**

## AC8(b) Conclusion

At baseline commit `fb483b8468204e4385b5583c3b3ec4c0a987eede`, no CI workflow invokes the root TypeScript toolchain. The root jest suite runs zero times in CI. The new `_root-typescript-tests.yml` workflow added in Phase 3 is therefore a strict increase in CI-executed coverage, not a relocation of existing execution.

Output Summary: Grep of `.github/workflows/` for `jest|run-jest|test:unit|vscode-test|npm test|npm run test` returned **zero matches**, confirming no workflow runs the root TypeScript toolchain at baseline. A separate full `npm` inventory shows every workflow `npm run test` occurrence is `--prefix`-scoped to `extensions/drm-copilot` (`_drm-copilot-extension-tests.yml`, `publish-extension.yml`, `publish-mcp-npm.yml`) or `packages/mcp-server` — the extension's and MCP server's own suites, not the root toolchain. `_npm-audit-gate.yml` runs only `npm ci` + `npm audit`. AC8(b) evidence established.
