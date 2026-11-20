Timestamp: 2026-11-05T04-04
Started: 2026-11-05T04:04:09.2820670Z
Command: docker exec -u vscode e525debb7e74 bash SCRATCH/issue-1082-runtime.sh
EXIT_CODE: 1
Output Summary:

```text
[OK] pester 6.2.0
[OK] pssa 1.25.0
[OK] bats is installed
[OK] bashdb is installed
[OK] .devcontainer/local/devcontainer.json
[OK] Workspace virtual environment Python 3.13.18
All devcontainer checks passed.
uid=1000(vscode) gid=1000(vscode) groups=1000(vscode),994(docker),998(pipx),999(nvm)
GIT_EFFECTIVE_FSMONITOR=false
GIT_HOST_LOCAL_FSMONITOR=true
GIT_STATUS_START
 M .devcontainer/codespaces/Dockerfile
 M .devcontainer/codespaces/devcontainer.json
 M .devcontainer/local/Dockerfile
 M .devcontainer/local/devcontainer-lock.json
 M .devcontainer/local/devcontainer.json
 M .devcontainer/post-create.sh
 M .devcontainer/verify-container.sh
 M scripts/bash/container_versions.sh
DEPENDENCY_MOUNTS
.venv is a mountpoint
1000:1000 .venv
node_modules is a mountpoint
1000:1000 node_modules
extensions/drm-copilot/node_modules is a mountpoint
1000:1000 extensions/drm-copilot/node_modules
packages/mcp-server/node_modules is a mountpoint
1000:1000 packages/mcp-server/node_modules
Python 3.13.18
0.28.2
0.28.2
NATIVE_CODEX_LOCATION=/usr/local/bin/codex
codex-cli 0.166.0
10.0.403 [/usr/share/dotnet/sdk]
No tools installed
1000:1000 /home/vscode/.claude
1000:1000 /home/vscode/.codex
1000:1000 /home/vscode/.local/share/claude-swap
0:0 /etc/codex/config.toml
check_for_update_on_startup = false
cli_auth_credentials_store = "file"
CREDENTIAL_FILES=1
SOURCE_SHA256
429c1cd768e901c23c071048f8fa5267ffd2257f31a329ac4e8eef781df03165  .devcontainer/local/devcontainer.json
sha256sum: '.devcontainer/lib/workspace.sh'$'\r': No such file or directory
```

Raw output: SCRATCH/issue-1082-local-container-reused-runtime-scoped.log
