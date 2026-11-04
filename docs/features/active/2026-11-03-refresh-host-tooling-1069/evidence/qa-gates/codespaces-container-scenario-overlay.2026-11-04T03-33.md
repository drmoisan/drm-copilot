Timestamp: 2026-11-04T03-33
Command: pwsh -NoProfile -File SCRATCH/issue-1069-container-final.ps1 -Configuration codespaces
EXIT_CODE: 0
Output Summary: Devcontainer verification: codespaces
[OK] Debian GNU/Linux 12 (bookworm)
[OK] python 3.13.17
[OK] node v26.13.0
[OK] npm 11.20.0
[OK] pwsh 7.6.9
[OK] poetry 2.3.2
[OK] shfmt v3.14.1
[OK] shellcheck 0.11.0
[OK] actionlint 1.7.12
[OK] git is installed
[OK] gh is installed
[OK] kcov is installed
[OK] bats is installed
[OK] bashdb is installed
[OK] claude is installed
[OK] cswap is installed
[OK] .devcontainer/codespaces/devcontainer.json
[OK] Workspace virtual environment Python 3.13.17
All devcontainer checks passed.
===================================
Post-Create Container Setup
===================================
Workspace directory: /workspaces/drm-copilot

Cleaning stale data directories...
Removing stale directory: /workspaces/drm-copilot/data/gutenberg
Skipping /workspaces/drm-copilot/data/sets (mounted)

Configuring Docker socket permissions...
Docker socket GID (1001) differs from docker group GID (1000)
Requesting sudo to fix socket permissions...
Warning: Could not change docker socket group
Warning: Could not update docker socket permissions
⚠ Docker access check failed - you may need to rebuild the container

Creating PowerShell profile...

Installing Python dependencies with Poetry...
Detected broken .venv; removing and recreating...
Warning: poetry.lock not found. Resolving dependencies and creating lock file...

Verifying Poetry environment...
Warning: could not determine Poetry env path (poetry env info --path returned nothing).

Verifying Python tooling...

Verifying GitHub Copilot CLI...
copilot: /fixture/github.copilot-chat/copilot
⚠ Warning: 'copilot' resolves to a VS Code shim path.
  Install the real GitHub Copilot CLI (https://gh.io/copilot-install) and ensure it is first on PATH.
⚠ Warning: copilot --version failed

Verifying PowerShell tooling...
PowerShell 7.6.9

Ensuring PowerShell QC dependencies...
PowerShell 7.6.9

Importing PoshQC module...
PowerShell 7.6.9

Git configuration not found. You may want to run:
  git config --global user.name 'Your Name'
  git config --global user.email 'your.email@example.com'

===================================
Dev Container Setup Complete!
===================================

Available commands:
  poetry run pytest                         # Run Python tests
  poetry run black .                        # Format Python code
  poetry run ruff check                     # Lint Python code
  poetry run pyright                        # Type check Python code
  pwsh -File scripts/dev-tools/fix-all.ps1  # Run all QC checks

VS Code tasks are available via:
  Ctrl+Shift+P -> Tasks: Run Task

To build the package:
  poetry build


Boundary version/setup fixtures isolate branches; native stage independently measures installed versions. Negative scenario exit is normalized only after observing the expected verifier failure.
