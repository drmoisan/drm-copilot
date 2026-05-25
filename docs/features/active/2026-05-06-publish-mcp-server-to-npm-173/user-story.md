# `2026-05-06-publish-mcp-server-to-npm` — User Story

- Issue: #173
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-05-06T21-36

## Story Statement

- As a developer integrating drm-copilot with an MCP client (Claude Desktop, Codex, or a compatible client), I want to configure and run the drm-copilot MCP server using `npx -y @danmoisan/drm-copilot-mcp` without cloning the repository or building from source, so that I can use drm-copilot repo-automation tools from any workspace.
- As the drm-copilot maintainer, I want a reproducible, CI-gated npm publish workflow triggered by a semver tag, so that new releases reach the npm registry only after the extension-tests job passes.

## Problem / Why

The drm-copilot MCP server runs as a standalone Node.js stdio process with no VS Code API dependencies on the MCP execution path. Despite this, the only way to use it today is to clone the repository and build it locally. This creates unnecessary friction for consumers who want to use the MCP tools from non-VS Code environments. Publishing to npm removes the requirement for a local clone and build, and makes the server accessible to any MCP-compatible client via a single `npx` invocation.

## Personas & Scenarios

- Persona: External Developer
  - A software developer who uses Claude Desktop or another MCP-compatible client as their primary AI assistant.
  - They are familiar with npm and `npx` but have no interest in maintaining a local checkout of drm-copilot.
  - They want access to drm-copilot's repo-automation MCP tools (feature promotion, policy audit, PR context collection) in their own workspace.
  - Their constraint: they do not want to install or build a VS Code extension to use a command-line server.
  - Their goal: zero-friction setup — add a server entry to their MCP client config and start using the tools immediately.

- Scenario: First-Time Setup
  - Trigger: An external developer reads the drm-copilot README and finds that the MCP server is available on npm.
  - Steps: They add the following entry to their MCP client configuration file:
    ```json
    {
      "mcpServers": {
        "drm-copilot": {
          "command": "npx",
          "args": ["-y", "@danmoisan/drm-copilot-mcp"],
          "cwd": "/absolute/path/to/their/workspace"
        }
      }
    }
    ```
  - On next client start, `npx` downloads and caches `@danmoisan/drm-copilot-mcp`, then starts the stdio server.
  - The developer invokes a drm-copilot tool (e.g., `new_potential_entry`) from their MCP client and receives a result.
  - Decision point: If their machine lacks Python 3 or PowerShell 7+, tools that invoke bundled scripts fail with an error. The package README informs them of this prerequisite.
  - Expected outcome: The tool executes successfully against the configured workspace without requiring any drm-copilot source code on the consumer's machine.

## Acceptance Criteria

- [x] AC1. `packages/mcp-server/` exists with a publishable package.json (correct name, bin, files, engines, license, repository, type).
- [x] AC2. The esbuild build produces an `out/mcp-server.js` bundle starting with `#!/usr/bin/env node`.
- [x] AC3. The published tarball, when generated locally via `npm pack`, includes `out/mcp-server.js` and the `resources/` tree, and excludes test sources.
- [x] AC4. A top-level MIT LICENSE file exists at the repo root and the docs-validation CI job passes.
- [x] AC5. A GitHub Actions workflow at `.github/workflows/publish-mcp-npm.yml` (or equivalent) is present, triggers on a semver tag push (pattern `mcp-server-v*`), depends on the existing extension-tests job, uses NPM_TOKEN, and runs `npm publish --access public`.
- [x] AC6. README.md inside the package documents: install/usage via `npx -y @danmoisan/drm-copilot-mcp`, the MCP client config snippet (command/args/cwd), and the runtime prerequisites (Node >=18 mandatory; Python 3 and pwsh 7+ for script-backed tools).
- [x] AC7. The package version equals the version in extensions/drm-copilot/package.json at release time.

## Non-Goals

- This feature does not add new MCP tools or change the MCP server's tool API surface.
- This feature does not introduce automated version-bump tooling, changesets, or semantic-release.
- This feature does not restructure the repository into a formal Nx or Turborepo monorepo.
- This feature does not create a shared `packages/core/` package or extract shared logic from the extension.
- This feature does not automate synchronization of the version field between `packages/mcp-server/package.json` and `extensions/drm-copilot/package.json`.
- Embedding resource files into the esbuild bundle (using `loader: "text"` or similar) is out of scope; resources are shipped as static files in the tarball.
- Support for consumers who cannot use `npx` or who require an ESM build is out of scope.
