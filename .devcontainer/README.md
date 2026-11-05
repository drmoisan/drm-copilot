# Docker Dev Container Setup

This directory contains the Docker Dev Container configuration for the DRM Copilot project.

> **Important**: This repo uses **separate configurations** for GitHub Codespaces and local Docker. Both require **manual selection** to avoid conflicts.

## Prerequisites

- **Docker Desktop** installed and running (for local development)
- **VS Code** with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed (for local development)
- **OR** use **GitHub Codespaces** (no local setup needed)

## Quick Start

### GitHub Codespaces

**⚠️ You must manually select the Codespaces configuration:**

1. Go to repository on GitHub
2. Click **Code** → **Codespaces** → **... (three dots)**
3. Select **"Configure and create codespace"**
4. Choose dev container: **`.devcontainer/codespaces/devcontainer.json`**
5. Click **"Create codespace"**
6. Wait for build (~5-10 minutes first time)
7. Verify: `bash .devcontainer/verify-container.sh`

**📖 Detailed instructions:** See [CODESPACES-SETUP.md](CODESPACES-SETUP.md)

### Local Docker Development

1. Ensure Docker Desktop is running
2. Open this workspace in VS Code
3. Press `F1` → **Dev Containers: Open Folder in Container**
4. Navigate to and select: **`.devcontainer/local/devcontainer.json`**
5. Wait for build (~5-10 minutes first time)
6. Verify: `bash .devcontainer/verify-container.sh`

**Why manual selection?** To prevent one environment's config from interfering with the other, we keep both as non-standard filenames that require explicit selection.

## What's Included

### Base Environment
- **Debian 12 (Bookworm)**
- **Python 3.13.17** with Poetry 2.3.2
- **Node.js 26.13.0 / npm 11.20.0** for development and CI
- **PowerShell 7.6.9** for cross-platform scripting
- **Git** and **GitHub CLI** (gh)
- **Graphite CLI** (`gt`) for the Graphite VS Code extension
- **GitHub Copilot CLI** (`copilot`) for the `atomic_executor` tool
- **shfmt 3.14.1**, **ShellCheck 0.11.0**, and **actionlint 1.7.12**
- **bashdb** for Bash debugging

### Python Tooling
- **Black** (code formatter)
- **Ruff** (fast linter)
- **Pyright** (type checker)
- **Pytest** (test runner with coverage)
- All project dependencies from `pyproject.toml`

### PowerShell Tooling
- **PSScriptAnalyzer** (linter)
- **Pester** (test framework)
- **PoshQC** module (from workspace)

### VS Code Extensions (allow list)
- Python, Pylance, Black Formatter, Ruff, Poetry helper, Parquet Explorer, Live Server
- PowerShell
- GitLens, GitHub Pull Requests, Git Graph, Graphite GTI
- EditorConfig, REST Client
- Coverage Gutters, Koverage, Pester Test Explorer
- Docker tools, Markdown Preview GitHub Styles, Mermaid, Rainbow CSV
- ChatGPT, GitHub Actions

### Mounts and Storage Layout
- Local workspace bind mount: `${localWorkspaceFolder} -> /workspaces/drm-copilot`; host edits and uncommitted changes are immediately available inside the container
- Dedicated background worktree volume: `${localWorkspaceFolderBasename}-workspace-bg -> /workspaces/drm-copilot-bg` (used by background tasks)
- Local Linux dependency volumes cover `.venv` and each `node_modules` directory (root, extension, MCP server). `volume-nocopy` prevents Windows dependencies from entering these volumes
- `artifacts/` and `data/` use the workspace bind mount directly
- The Docker outside-of-Docker feature provides access to the host Docker daemon

Both configurations run `bash .devcontainer/post-create.sh` against their actual workspace. Setup installs the lock-file dependencies and runs `.devcontainer/verify-container.sh` before reporting completion.

The former `${localWorkspaceFolderBasename}-workspace` volume is no longer used. It is retained so any container-only work can be recovered before removal.

## Container Features

### Virtual Environment
Poetry creates a virtual environment at `/workspaces/drm-copilot/.venv` which is:
- Stored in a dedicated Linux volume locally, separate from the host environment
- Automatically activated in the terminal
- Configured as the default Python interpreter

### Terminal Defaults
- Default shell: **PowerShell** (`pwsh`)
- Bash available as alternative

### Common Commands (preferred over VS Code tasks)
Use the Poetry and PowerShell commands directly instead of the `QC: ...` tasks:
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest`
- `poetry run python -m scripts.dev_tools.fix_all`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/format-powershell.ps1`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/run-psscriptanalyzer.ps1`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/run-pester.ps1`

## Rebuilding the Container

If you modify the Dockerfile or devcontainer.json:

1. Press `F1` and select **Dev Containers: Rebuild Container**
2. Or, from outside the container: **Dev Containers: Rebuild and Reopen in Container**

## Customization

### Adding Extensions
Edit the selected `.devcontainer/local/devcontainer.json` or `.devcontainer/codespaces/devcontainer.json` → `customizations.vscode.extensions[]`

### Changing Python/Tool Versions
Edit `.devcontainer/local/Dockerfile` and `.devcontainer/codespaces/Dockerfile` → `FROM` stages and install commands

### Post-Create Steps
Edit `.devcontainer/post-create.sh` to add custom setup commands

## Secrets and API Keys

The container does **not** include secrets. To use OpenAI API:

1. Inside the container, install LastPass CLI or use environment variables
2. Run the load script: `pwsh scripts/dev-tools/load-openai-key.ps1`
3. Or set manually: `export OPENAI_API_KEY="your-key"`

## Troubleshooting

### Container won't start
- Ensure Docker Desktop is running
- Check Docker Desktop resources (RAM: 4GB+, CPU: 2+ cores)
- View logs: `F1` → **Dev Containers: Show Container Log**

### Poetry install fails
- Rebuild container: `F1` → **Dev Containers: Rebuild Container**
- Check `poetry.lock` is committed to repo

### Extensions not loading
- Reopen window: `F1` → **Dev Containers: Reopen in Container**
- Check extension compatibility with container architecture

### Performance issues on Windows
- Dependency directories use Linux volumes to reduce package I/O across the Windows bind mount
- Use the WSL 2 backend. For faster source I/O, open a checkout stored in the WSL filesystem
- Host edits are visible immediately; rebuild after Dockerfile or mount changes
- Avoid aggressive workspace scanners (Task Explorer removed from allow list)

## Benefits Over Local Development

✅ **Consistent environment** across team members  
✅ **No pollution** of host system with dev tools  
✅ **Isolated Python/PowerShell** versions and packages  
✅ **Easy onboarding** - one command to get started  
✅ **Reproducible builds** - same environment every time  
✅ **Cross-platform** - works on Windows, macOS, Linux  

## Additional Resources

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container Specification](https://containers.dev/)
- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
