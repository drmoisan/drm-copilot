#!/bin/bash
set -e

echo "==================================="
echo "Post-Create Container Setup"
echo "==================================="

# -----------------------------------------------------------------------------
# Resolve workspace/repo root deterministically
# -----------------------------------------------------------------------------
# Prefer devcontainer-provided workspace folder when available; fall back to git;
# finally fall back to current directory.
WORKSPACE_DIR="${WORKSPACE_FOLDER:-}"
if [ -n "$WORKSPACE_DIR" ] && [ -d "$WORKSPACE_DIR" ]; then
	# If WORKSPACE_DIR is not a git repo root, try to resolve to the git top-level within it
	if git -C "$WORKSPACE_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
		WORKSPACE_DIR="$(git -C "$WORKSPACE_DIR" rev-parse --show-toplevel)"
	fi
else
	WORKSPACE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi

cd "$WORKSPACE_DIR"
export WORKSPACE_DIR
echo "Workspace directory: $WORKSPACE_DIR"

# Docker Desktop exposes the host checkout as root-owned to the container user.
# Trust only this workspace so Git works for setup, terminals, and extensions.
if ! git config --global --get-all safe.directory | grep -Fxq "$WORKSPACE_DIR"; then
	git config --global --add safe.directory "$WORKSPACE_DIR"
fi

# -----------------------------------------------------------------------------
# Prepare container-owned dependency volumes without changing host dependencies
# -----------------------------------------------------------------------------
# Docker creates empty named volumes as root; only their mount roots need ownership.
# Codespaces has no dependency mounts, so it uses the same setup without this step.
for dependency_dir in .venv node_modules extensions/drm-copilot/node_modules packages/mcp-server/node_modules; do
	if mountpoint -q "$dependency_dir"; then
		sudo chown "$(id -u):$(id -g)" "$dependency_dir"
	fi
done

# -----------------------------------------------------------------------------
# Fix Docker socket permissions
# -----------------------------------------------------------------------------
# The docker-outside-of-docker feature creates a docker group, but the socket
# from the host may be owned by root:root. We need to ensure the vscode user
# can access it by updating the socket group ownership.
echo ""
echo "Configuring Docker socket permissions..."
if [ -S /var/run/docker.sock ]; then
	DOCKER_SOCK_GID=$(stat -c '%g' /var/run/docker.sock 2>/dev/null || echo "")
	DOCKER_GROUP_GID=$(getent group docker | cut -d: -f3 2>/dev/null || echo "")

	if [ -n "$DOCKER_SOCK_GID" ] && [ -n "$DOCKER_GROUP_GID" ]; then
		if [ "$DOCKER_SOCK_GID" != "$DOCKER_GROUP_GID" ]; then
			echo "Docker socket GID ($DOCKER_SOCK_GID) differs from docker group GID ($DOCKER_GROUP_GID)"
			echo "Requesting sudo to fix socket permissions..."
			# Change the socket to be owned by the docker group
			sudo chgrp docker /var/run/docker.sock || echo "Warning: Could not change docker socket group"
			sudo chmod g+rw /var/run/docker.sock || echo "Warning: Could not update docker socket permissions"
		fi
	fi

	# Verify docker access
	if docker ps >/dev/null 2>&1; then
		echo "✓ Docker access configured successfully"
	else
		echo "⚠ Docker access check failed - you may need to rebuild the container"
	fi
else
	echo "⚠ Docker socket not found at /var/run/docker.sock"
fi

# Create PowerShell profile with custom prompt
echo ""
echo "Creating PowerShell profile..."
mkdir -p ~/.config/powershell
cat >~/.config/powershell/Microsoft.PowerShell_profile.ps1 <<'PROFILE_END'
$env:WORKSPACE_DIR = '/workspaces/drm-copilot'

# Activate venv silently (suppress all output)
$activateScript = "$env:WORKSPACE_DIR/.venv/bin/Activate.ps1"
if (Test-Path $activateScript) {
    $null = & $activateScript *>&1
}

# Custom prompt with relative paths
function prompt {
    $venvName = if ($env:VIRTUAL_ENV) {
        $name = Split-Path -Leaf $env:VIRTUAL_ENV
        if ($name -eq '.venv' -and (Test-Path "$env:VIRTUAL_ENV/pyvenv.cfg")) {
            $cfg = Get-Content "$env:VIRTUAL_ENV/pyvenv.cfg" -Raw
            if ($cfg -match 'prompt\s*=\s*(.+)') {
                $matches[1].Trim()
            } else {
                '.venv'
            }
        } else {
            $name
        }
    } else {
        ''
    }
    
    $venv = if ($venvName) { "($venvName)" } else { "" }
    $currentPath = $PWD.Path
    $workspaceDir = $env:WORKSPACE_DIR
    
    if ($currentPath -eq $workspaceDir) {
        $relativePath = "/"
    } elseif ($currentPath.StartsWith($workspaceDir)) {
        $relativePath = $currentPath.Substring($workspaceDir.Length)
    } else {
        $relativePath = $currentPath
    }
    
    "$venv$relativePath> "
}
PROFILE_END

# Persist WORKSPACE_DIR for future bash sessions (optional)
BASHRC="$HOME/.bashrc"
LINE="export WORKSPACE_DIR=\"$WORKSPACE_DIR\""
grep -qxF "$LINE" "$BASHRC" 2>/dev/null || echo "$LINE" >>"$BASHRC"

# -----------------------------------------------------------------------------
# Python / Poetry setup
# -----------------------------------------------------------------------------
echo ""
echo "Installing Python dependencies with Poetry..."

# Ensure Poetry uses an in-project venv for THIS repo (local config, not global)
poetry config virtualenvs.in-project true --local

# If the venv exists but is clearly broken, recreate it
if [ -d ".venv" ] && [ ! -x ".venv/bin/python" ]; then
	echo "Detected broken .venv; removing and recreating..."
	# Keep the mount itself so recovery also works for a fresh dependency volume.
	if mountpoint -q .venv; then
		find .venv -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
	else
		rm -rf .venv
	fi
fi

if [ -f "poetry.lock" ]; then
	echo "poetry.lock found; installing locked dependencies..."
	poetry install --no-interaction --no-ansi --with dev
else
	echo "Warning: poetry.lock not found. Resolving dependencies and creating lock file..."
	poetry lock --no-interaction --no-ansi
	poetry install --no-interaction --no-ansi --with dev
fi

# Verify Poetry is using the in-project environment (warn if not)
echo ""
echo "Verifying Poetry environment..."
ENV_PATH="$(poetry env info --path 2>/dev/null || true)"
if [ -z "$ENV_PATH" ]; then
	echo "Warning: could not determine Poetry env path (poetry env info --path returned nothing)."
elif [ "$ENV_PATH" != "$WORKSPACE_DIR/.venv" ]; then
	echo "Warning: Poetry env is '$ENV_PATH' (expected '$WORKSPACE_DIR/.venv')."
else
	echo "Poetry env path: $ENV_PATH"
fi

# Verify Python tooling
echo ""
echo "Verifying Python tooling..."
poetry run black --version
poetry run ruff --version
poetry run pyright --version
poetry run pytest --version

# -----------------------------------------------------------------------------
# Node.js dependencies
# -----------------------------------------------------------------------------
# The three npm projects are independent (no npm workspaces, no file: links), so
# each lock file is installed separately. npm ci replaces any existing
# node_modules, which also removes trees copied from a Windows host.
echo ""
echo "Installing Node.js dependencies..."
for npm_project in . extensions/drm-copilot packages/mcp-server; do
	if [ -f "$npm_project/package-lock.json" ]; then
		echo "npm ci in $npm_project"
		(cd "$npm_project" && npm ci --no-audit --no-fund)
	else
		echo "Skipping $npm_project (no package-lock.json)"
	fi
done

# -----------------------------------------------------------------------------
# GitHub Copilot CLI verification
# -----------------------------------------------------------------------------
echo ""
echo "Verifying GitHub Copilot CLI..."
if command -v copilot >/dev/null 2>&1; then
	COPILOT_PATH="$(command -v copilot)"
	echo "copilot: $COPILOT_PATH"

	# If we ever see the VS Code extension shim on PATH inside the container,
	# warn loudly. The atomic executor needs the real CLI binary.
	if echo "$COPILOT_PATH" | grep -qi "github\.copilot-chat"; then
		echo "⚠ Warning: 'copilot' resolves to a VS Code shim path."
		echo "  Install the real GitHub Copilot CLI (https://gh.io/copilot-install) and ensure it is first on PATH."
	fi

	copilot --version || echo "⚠ Warning: copilot --version failed"
else
	echo "⚠ Warning: GitHub Copilot CLI not found on PATH (command: copilot)."
	echo "  The atomic executor requires it. See: https://gh.io/copilot-install"
fi

# -----------------------------------------------------------------------------
# PowerShell tooling verification
# -----------------------------------------------------------------------------
echo ""
echo "Verifying PowerShell tooling..."
pwsh -NoLogo -NoProfile -Command "
    Write-Host 'PowerShell version:'
    \$PSVersionTable.PSVersion
    Write-Host ''
    Write-Host 'Installed modules:'
    Get-Module -ListAvailable PSScriptAnalyzer, Pester | Sort-Object Name, Version -Descending | Format-Table Name, Version
"

# -----------------------------------------------------------------------------
# PowerShell QC dependencies
# -----------------------------------------------------------------------------
# Recommendation: Choose ONE strategy for module installation (AllUsers pinned in Dockerfile
# OR CurrentUser pinned here). This script keeps the original behavior (CurrentUser pinning)
# but will not reinstall if a suitable version is already present.
echo ""
echo "Ensuring PowerShell QC dependencies..."
pwsh -NoLogo -NoProfile -Command - <<'PWSH'
$ErrorActionPreference = 'Stop'
$required = @(
    @{ Name = 'PSScriptAnalyzer'; Version = '1.22.0' },
    @{ Name = 'Pester'; Version = '5.9.0'; UpperBound = '6.0.0' }
)

$gallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if (-not $gallery) {
    Register-PSRepository -Default -InstallationPolicy Trusted
} elseif ($gallery.InstallationPolicy -ne 'Trusted') {
    try {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop
    } catch {
        Write-Warning 'Could not set PSGallery to Trusted automatically; you may see prompts during install.'
    }
}

foreach ($module in $required) {
    $installed = Get-Module -ListAvailable -Name $module.Name |
        Where-Object { $_.Version -ge [version]$module.Version -and (-not $module.ContainsKey('UpperBound') -or $_.Version -lt [version]$module.UpperBound) } |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if ($installed) {
        Write-Host "Found $($module.Name) $($installed.Version)"
        continue
    }

    Write-Host "Installing $($module.Name) $($module.Version) (CurrentUser scope)..."
    Install-Module -Name $module.Name -RequiredVersion $module.Version -Scope CurrentUser -AllowClobber -Force -ErrorAction Stop
}
PWSH

# -----------------------------------------------------------------------------
# Import PoshQC module from the mounted workspace
# -----------------------------------------------------------------------------
echo ""
echo "Importing PoshQC module..."
pwsh -NoLogo -NoProfile -Command - <<'PWSH'
$ErrorActionPreference = 'Stop'

$candidate = "$env:WORKSPACE_DIR/scripts/powershell/PoshQC/PoshQC.psd1"
if (-not (Test-Path $candidate)) {
    Write-Error "PoshQC module not found. Checked: $candidate"
    exit 1
}

Import-Module $candidate -Force -ErrorAction Stop
Write-Host "Imported PoshQC from $candidate"
PWSH

# -----------------------------------------------------------------------------
# Git configuration reminder
# -----------------------------------------------------------------------------
if [ ! -f ~/.gitconfig ]; then
	echo ""
	echo "Git configuration not found. You may want to run:"
	echo "  git config --global user.name 'Your Name'"
	echo "  git config --global user.email 'your.email@example.com'"
fi

# -----------------------------------------------------------------------------
# Completion banner
# -----------------------------------------------------------------------------
# A successful dependency install must also satisfy the pinned runtime contract.
bash .devcontainer/verify-container.sh

echo ""
echo "==================================="
echo "Dev Container Setup Complete!"
echo "==================================="
echo ""
echo "Available commands:"
echo "  poetry run pytest                         # Run Python tests"
echo "  poetry run black .                        # Format Python code"
echo "  poetry run ruff check                     # Lint Python code"
echo "  poetry run pyright                        # Type check Python code"
echo "  pwsh -File scripts/dev-tools/fix-all.ps1  # Run all QC checks"
echo ""
echo "VS Code tasks are available via:"
echo "  Ctrl+Shift+P -> Tasks: Run Task"
echo ""
echo "To build the package:"
echo "  poetry build"
echo ""
