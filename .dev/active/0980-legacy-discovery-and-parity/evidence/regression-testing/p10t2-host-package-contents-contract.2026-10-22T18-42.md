# P10-T2 Host package contents contract

Timestamp: 2026-10-22T18-42
Task: [P10-T2] Verify VSIX and standalone MCP package contents.
Result: PASS

## Behavior verified

- Packaging allowlists: `packages/mcp-server/prepack.cjs` (copy everything under the extension resources except `*.py` and the root `scripts` tree) and `extensions/drm-copilot/.vscodeignore` (exclude source, tests, tooling, `**/*.py`, bytecode and `resources/scripts/**`) already admit every newly mapped non-Python resource, so neither was changed; the explicit Python-source exclusion and the shared-server build (both esbuild configurations bundle `extensions/drm-copilot/src/mcp-server.ts` with the `vscode` shim) are preserved.
- Built artifacts (see `evidence/other/discovery-host-packages.2026-10-22T18-42.md`): VSIX 795 files, SHA-256 `d7ad4748cd8936cc4f35d065958987d503085f24e9e32df98d8b150cef6a4ee7`; npm tarball 789 files, SHA-256 `3681c32cf89a3f8e9a01768e4ffa67d886bbe79d651052cc64ab9ac763464218`. Each carries all 58 required native entries (shared helpers, the compatibility module, the GitHub, Claude and Codex discovery hooks and registrations, the four roles on each host, the routing config, setup templates and the PoshQC module), zero Python entries, no root `scripts` tree, and a server bundle with no `require("vscode")`; the standalone bundle names the wheel `drm_copilot_discovery-2.0.0-py3-none-any.whl` and the gateway module.

## Proof

- `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` (new, 9 cases): every published discovery resource exists and is admitted by `shouldCopy`; Python paths are rejected by both distributables; the `.vscodeignore` patterns are classified so that nothing under `resources/` except the removed Python tree can be excluded; the npm manifest ships `out/mcp-server.js` and `resources` with the `drm-copilot-mcp` bin, `node prepack.cjs`, Node >= 18 and no `vscode` dependency; both esbuild configurations bundle the same entry with the vscode shim; the server entry imports no host module; the wheel file name follows the runtime package version and the gateway module name is fixed; the advertised definitions equal `REPO_AUTOMATION_TOOLS`, the dispatcher returns that array and carries a case per tool, and the extension registers exactly `drmCopilotMcpProvider` pointing at `out/mcp-server.js`.
- `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` (extended): one representative of each newly mapped resource class (Codex virtual helpers, GitHub hook and registration, Copilot agent, Claude hook, compatibility module, bundled and shared routing config, Codex hook and config, template, PoshQC manifest) is admitted; the existing scripts-tree and Python exclusions and the load-time no-copy assertion are retained.

## Gates

- Prettier, ESLint and tsc clean; Jest 14/14 on the packaging folder; extension compile and both package builds exit 0; inspection DEFECTS=0; the worktree carries only the two test files as changes after the builds.

## Carried notes

- `npx --yes @vscode/vsce` resolved the packager at build time; `@vscode/vsce` is not a repository dependency, matching the publish workflow and the sideload script.
- The npm package version (1.1.22) follows the extension version; the publish mechanics are unchanged by this task.
