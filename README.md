# drm-copilot

VS Code extension scaffolding to apply agentic programming customizations to projects. This repository is a starting point; extension logic will evolve as you add your devcontainer configuration and work-in-progress content.

## Features

- Starter command: **DRM Copilot: Apply Agentic Customizations**.
- Cross-platform scaffolding designed for Windows, macOS, and Linux.
- Workspace recommendations for Python, PowerShell, Bash, and Node.js tooling.

## Requirements

- VS Code
- Node.js (for extension development)

## Development

- Compile: `npm run compile`
- Watch: `npm run watch`
- Test: `npm test`

## Commands

- `drm-copilot.applyCustomizations`: Placeholder command to validate activation wiring.
- `drmCopilotExtension.collectPrContext`: Packaged PR-context command used by rewritten customization references.
- `drmCopilotExtension.newActiveFeatureFolderPlaceholder`: Placeholder command used when copied customization files reference uncovered feature-folder tooling.

## Push-down publisher

- Publish the scoped `.github` customization trees into another workspace with:
	`poetry run python -m scripts.dev_tools.push_down_copilot_customizations --destination <workspace-root>`
- The publisher rewrites supported script references to stable textual VS Code command references.
- Known-but-unimplemented references are rewritten to placeholder command IDs such as `drmCopilotExtension.newActiveFeatureFolderPlaceholder`, which fail deterministically with a `Not implemented:` error when invoked.

## Skills

- [Skills taxonomy](.github/skills/README.md)

## Notes

You can drop a devcontainer configuration and additional customization logic once ready.
