# Discovery host packages rebuild (P12-T11)

Timestamp: 2026-10-28T13-21
Command: sh SCRATCH/issue-980-p12t11-packages.sh (npm run compile in extensions/drm-copilot; npx --yes @vscode/vsce package --allow-missing-repository --skip-license --out SCRATCH/stage/drm-copilot.vsix; npm run build in packages/mcp-server; npm pack --pack-destination SCRATCH/stage); poetry run python -I SCRATCH/issue-980-p12t11-inspect.py SCRATCH/stage; node extensions/drm-copilot/run-jest.cjs --rootDir extensions/drm-copilot extensions/drm-copilot/test/packaging/discovery-resources.test.ts extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts
EXIT_CODE: 0 (compile), 0 (vsce), 0 (mcp-server build), 0 (npm pack), 0 (inspection, DEFECTS=0), 0 (Jest 2 suites, 14 passed)
Output Summary: Both distributables were rebuilt from the Phase 12 sources into SCRATCH/stage and inspected without extraction; neither contains a Python, bytecode or `__pycache__` entry, so no Python business logic is copied into the host packages. The packaging contract suites pass unchanged.

## VSIX (extension 1.1.22)

- File: `drm-copilot.vsix`, 795 files, 3,090,214 bytes, SHA-256 `834cb08195301399242742d06fd19496e406f761757546a4e17e5d47eb9a9b48`.
- Python entries: 0. Root manifest: `extension/package.json`.

## Standalone MCP package (@danmoisan/drm-copilot-mcp 1.1.22)

- File: `danmoisan-drm-copilot-mcp-1.1.22.tgz`, 789 entries, 1,868,626 bytes, SHA-256 `1bebefbc5899149e461d6fefb39d1369844ae2256584ca23265da4fb56e2b01c`.
- Python entries: 0. `package/package.json` version 1.1.22.

## Notes

- The entry counts equal the P10-T2 counts (795 and 789); the Phase 12 changes alter the compiled TypeScript (`discovery-runtime`, `discovery-authorization`, the authorization gate, the identity module, the agent service) rather than the resource tree, so the digests change and the inventories do not.
- The packaging allowlists (`packages/mcp-server/prepack.cjs`, `extensions/drm-copilot/.vscodeignore`) needed no change; the staged artifacts live only under SCRATCH and the worktree carries no build residue.
- These artifacts and the rebuilt wheel are the ones P12-T12 installs for the completion-receipt smoke.
