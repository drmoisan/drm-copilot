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
- Lint: `npm run lint`
- Format: `npm run format`

### Testing

**Unit Tests** (recommended - work anywhere, including dev containers):
```bash
npm run test:unit
```

This runs comprehensive tests including extension activation, command registration, and all utility functions using Jest with mocked VS Code APIs.

**Integration Tests** (optional - require desktop GUI environment):
```bash
npm test  # or npm run test:integration
```

> **Note**: Integration tests launch a real VS Code instance and require a desktop environment with GUI libraries. They will fail in headless dev containers with errors like `libatk-1.0.so.0: cannot open shared object file`. The Jest-based unit tests provide comprehensive coverage and are the recommended way to test the extension.

## Commands

- `drm-copilot.applyCustomizations`: Placeholder command to validate activation wiring.

## Notes

You can drop a devcontainer configuration and additional customization logic once ready.
