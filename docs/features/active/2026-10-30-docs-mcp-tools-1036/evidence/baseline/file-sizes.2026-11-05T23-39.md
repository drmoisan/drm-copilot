# Baseline File Sizes ([P0-T11])

Timestamp: 2026-11-05T23-39
Command: awk 'END{print NR}' <file> for each edited non-Markdown file in `## Artifact Classification` (logical lines; a trailing terminator adds no line)
EXIT_CODE: 0
Output Summary: eleven edited non-Markdown files counted; none above 800; `jest.config.cjs` is in the 500-699 guidance band.

| Path | Logical lines |
|---|---|
| `extensions/drm-copilot/src/mcp-tools.ts` | 461 |
| `extensions/drm-copilot/src/repo-automation-tool-names.ts` | 47 |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | 425 |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` | 462 |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` | 298 |
| `extensions/drm-copilot/src/repo-automation-service.ts` | 450 |
| `extensions/drm-copilot/test/mcp-server.test.ts` | 494 |
| `extensions/drm-copilot/test/mcp-discovery-authority-tool-definitions.test.ts` | 198 |
| `extensions/drm-copilot/test/mcp-server-test-service.ts` | 165 |
| `extensions/drm-copilot/test/repo-automation-service.test.ts` | 28 |
| `extensions/drm-copilot/jest.config.cjs` | 559 |
