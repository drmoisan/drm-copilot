# Baseline — Manifest Versions

Timestamp: 2026-06-16T20-33

Current manifest versions (read from disk before any change):
- `extensions/drm-copilot/package.json`: version = `0.0.2` -> expected patch bump = `0.0.3`
- `packages/mcp-server/package.json`: version = `0.0.1` -> expected patch bump = `0.0.2`

Notes:
- The extension manifest patch bump (`0.0.2` -> `0.0.3`) is performed by the delegated publish script `Publish-DrmCopilotExtension.ps1 -VersionBump patch`.
- The mcp-server manifest patch bump (`0.0.1` -> `0.0.2`) is performed directly by the new script via the npm wrapper seam.
- Derived mcp-server tag name for the post-bump version: `mcp-server-v0.0.2`.
