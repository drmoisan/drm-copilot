# P4-T6 — MCP-server Prepack No-Python Validation (F11)

Timestamp: 2026-06-26T09-01
Command: npm run prepack (from packages/mcp-server/; runs `node prepack.cjs`)
EXIT_CODE: 0

Output Summary:
- The prepack copies `extensions/drm-copilot/resources` into `packages/mcp-server/resources` via `cpSync` with a `filter` that returns false for any `.py` path and any path under a `scripts/` segment.
- `.py` file count under `packages/mcp-server/resources`: 0 (`rg --files packages/mcp-server/resources -g "*.py" | wc -l` → 0).
- `packages/mcp-server/resources/scripts` does not exist (no bundled dev_tools tree copied).
- Confirmed non-Python payloads present after prepack:
  - `packages/mcp-server/resources/powershell/PoshQC/` (directory present)
  - `packages/mcp-server/resources/templates/run-poshqc-suite.ps1` (file present)
  - `packages/mcp-server/resources/claude-customizations/` (present)
  - `packages/mcp-server/resources/customizations/` (present)
  - `packages/mcp-server/resources/codex-and-agents-customizations/` (present)
- `packages/mcp-server/resources/**` is gitignored (`git check-ignore` confirms); the copied tree is not committed.

Verdict: The MCP-server prepack ships zero Python while preserving the PowerShell and customization-data payloads. AC-F11-6 satisfied.
