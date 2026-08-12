# P6-T36 Repository-Local MCP Bundle Build

## Literal format attempt and clean-loop restart

Timestamp: 2026-08-11T23:35:01-04:00

Command: `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`

EXIT_CODE: 1

Output Summary: From the workspace root, this npm-exec form evaluated the test glob against the workspace root and reported `No files matching the pattern were found: "test/**/*.ts"`; it also reported that every matched file used Prettier style. No file changed. The required sequence restarted from formatting with the same package-local arguments and the package directory as the working directory.

Timestamp: 2026-08-11T23:35:01-04:00

Command: `(cwd=extensions/drm-copilot) npm exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`

EXIT_CODE: 0

Output Summary: The clean restarted loop checked all intended extension source, test, JSON, and CJS paths; all matched files used Prettier style and no file changed.

## ESLint

Timestamp: 2026-08-11T23:35:01-04:00

Command: `npm --prefix extensions/drm-copilot run lint`

EXIT_CODE: 0

Output Summary: ESLint completed with 0 diagnostics.

## TypeScript compiler

Timestamp: 2026-08-11T23:35:01-04:00

Command: `npm --prefix extensions/drm-copilot run typecheck`

EXIT_CODE: 0

Output Summary: `tsc -p ./ --noEmit` completed with 0 errors.

## Focused current-source tests

Timestamp: 2026-08-11T23:35:01-04:00

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts test/lib/validate/validate-orchestration-service-call.test.ts`

EXIT_CODE: 0

Output Summary: 3/3 suites and 56/56 tests passed; 0 snapshots were present.

## Locked MCP package install

Timestamp: 2026-08-11T23:35:01-04:00

Command: `npm --prefix packages/mcp-server ci`

EXIT_CODE: 0

Output Summary: npm installed 95 packages from the lockfile, audited 96 packages, and reported 0 vulnerabilities. Writes were restricted to ignored `packages/mcp-server/node_modules/` output.

## MCP bundle build

Timestamp: 2026-08-11T23:35:01-04:00

Command: `npm --prefix packages/mcp-server run build`

EXIT_CODE: 0

Output Summary: The repository build script produced ignored `packages/mcp-server/out/mcp-server.js` from the current extension MCP entrypoint.

## Bundle syntax check

Timestamp: 2026-08-11T23:35:01-04:00

Command: `node --check packages/mcp-server/out/mcp-server.js`

EXIT_CODE: 0

Output Summary: Node accepted the generated JavaScript bundle with no syntax diagnostic.

## Build provenance and tracked-input invariance

Timestamp: 2026-08-11T23:35:01-04:00

Command: `resolve and hash source/bundle; inspect packages/mcp-server/esbuild-mcp-server.cjs; git diff --exit-code -- packages/mcp-server/package.json packages/mcp-server/package-lock.json packages/mcp-server/esbuild-mcp-server.cjs .codex/config.toml .claude`

EXIT_CODE: 0

Output Summary: The source and bundle resolve inside the workspace. The build script contains exactly one input reference equal to `../../extensions/drm-copilot/src/mcp-server.ts`. The package manifests, build script, Codex configuration, and `.claude/` have 0 unstaged byte changes. Generated `node_modules/` and `out/` status count is 0 because both are ignored.

| Artifact | Absolute path | Bytes | SHA-256 |
|---|---|---:|---|
| Current source entrypoint | `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25\extensions\drm-copilot\src\mcp-server.ts` | 3,673 | `1CD89097776209A4DE65B1874A94BD8B7417145B3E537C5A4C022B58BB3B9638` |
| Fresh local bundle | `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25\packages\mcp-server\out\mcp-server.js` | 1,231,120 | `AF0EBD9D5C77E76AABC113FF4977083B0407EB1DA0D4B1EE07F7AE55AACCB38E` |

Result: PASS — one clean restarted format, lint, typecheck, focused-test, locked-install, build, syntax, and immutability sequence completed without a tracked write.
