# Docker Dev Container - Quick Reference

## Starting the Dev Container

### First Time Setup

**For GitHub Codespaces:**
1. Go to repository on GitHub
2. Choose **Code** → **Codespaces** → **Configure and create codespace**
3. Select `.devcontainer/codespaces/devcontainer.json` and create the Codespace
4. After setup completes, verify: `bash .devcontainer/verify-container.sh`

**For Local Docker:**
1. Ensure Docker Desktop is running
2. In VS Code, press `F1` (or `Ctrl+Shift+P`)
3. Type and select: **Dev Containers: Reopen in Container**
4. When prompted, choose the **Local** configuration
5. Wait for the build process (~5-10 minutes)
6. Container will automatically run post-create setup
7. Verify setup: `bash .devcontainer/verify-container.sh`

### Subsequent Uses
- Just open the workspace - VS Code will prompt to reopen in container
- Or use `F1` → **Dev Containers: Reopen in Container**

## Common Commands

### In Terminal (inside container)
```bash
# Run all QC checks
pwsh scripts/dev-tools/fix-all.ps1

# Python formatting and linting
poetry run black .
poetry run ruff check --fix

# Type checking and testing
poetry run pyright
poetry run pytest

# PowerShell QC
pwsh -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."
pwsh -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."
pwsh -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."

```

### VS Code Tasks
All existing tasks work in the container. Access via:
- `Ctrl+Shift+B` (default build task)
- `F1` → **Tasks: Run Task**

## Managing the Container

### Rebuild Container
When you change Dockerfile or devcontainer.json:
```
F1 → Dev Containers: Rebuild Container
```

### Stop Container
```
F1 → Dev Containers: Close Remote Connection
```

### View Container Logs
```
F1 → Dev Containers: Show Container Log
```

### Open New Terminal
```
Ctrl+` or Terminal → New Terminal
```

## File Persistence

### What Persists
- Your host workspace is mounted directly at `/workspaces/drm-copilot`, including uncommitted edits, `artifacts/`, and `data/`
- Linux dependency volumes persist `.venv` and the root, extension, and MCP server `node_modules` directories separately from host packages
- Both local and Codespaces configurations run the shared post-create script and verify the runtime baseline before reporting success
- The old `${localWorkspaceFolderBasename}-workspace` volume is retained but unused; recover any container-only changes before removing it
- Git configuration
- Installed VS Code extensions

### What Doesn't Persist
- Global system packages (outside workspace)
- Shell history (by default)
- Temporary container files

## Troubleshooting

### Container Build Fails
1. Check Docker Desktop is running and has resources (4GB+ RAM)
2. View error logs: `F1` → **Dev Containers: Show Container Log**
3. Try: `F1` → **Dev Containers: Rebuild Container Without Cache**

### Poetry/Python Issues
```bash
# Reinstall dependencies
poetry install --no-cache

# Clear Poetry cache
poetry cache clear pypi --all
```

### PowerShell Module Issues
```bash
# Reimport PoshQC
pwsh -Command "Import-Module -Force ./scripts/powershell/PoshQC"

# Verify modules installed
pwsh -Command "Get-Module -ListAvailable PSScriptAnalyzer, Pester"
```

### Permission Issues
The container runs as user `vscode` (non-root). If you need root:
```bash
sudo apt-get update
```

### Performance on Windows
- Dependency directories use Linux volumes; source files use the host checkout directly
- Use WSL 2 backend in Docker Desktop settings
- Keep large artifacts out of source directories to reduce scanning overhead
- Aggressive workspace scanners are not allowed (Task Explorer removed)
- For faster source I/O, open a checkout stored in the WSL filesystem

## Tips

### Multiple Terminals
- Default: PowerShell (`pwsh`)
- Switch to Bash: Click terminal dropdown → Select Default Profile → Bash

### Secrets Management
```bash
# Set environment variable for OpenAI
export OPENAI_API_KEY="your-key-here"

# Or use the load script
pwsh scripts/dev-tools/load-openai-key.ps1
```

### Extension Management
- Extensions auto-install from devcontainer.json (Task Explorer excluded by policy)
- Install more: Extensions panel → Install in Dev Container (avoid workspace-wide scanners)

### Customize Shell Prompt
Add to `~/.bashrc` or `~/.config/powershell/profile.ps1` inside container
(these will be lost when container is rebuilt - use post-create.sh for persistence)

## Advantages

✅ No need to install Python, Poetry, PowerShell, or tools locally  
✅ Same environment for all developers  
✅ Clean separation from host system  
✅ Easy to reset (rebuild container)  
✅ Works on Windows, macOS, Linux  
✅ All VS Code tasks and debugging work normally  

## Going Back to Local Development

```
F1 → Dev Containers: Reopen Folder Locally
```

Your local environment is unchanged - the container doesn't affect your host machine.
