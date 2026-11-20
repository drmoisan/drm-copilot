# PoshQC Format Baseline Evidence

- Timestamp: 2026-06-21T12-06
- Issue: #221
- Task: [P0-T3]

## Command

```
mcp__drm-copilot__run_poshqc_format
```

- Scan folders: scripts/dev-tools, tests/scripts/dev-tools
- EXIT_CODE: 0

## Output Summary

Format check passed (`ok: true`). No in-scope files reformatted: `git status --porcelain` for `scripts/dev-tools/Invoke-FullRelease.ps1` and `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` returned empty. Working tree for in-scope files remains clean.
