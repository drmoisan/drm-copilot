Timestamp: 2026-11-05T04-05
Started: 2026-11-05T04:05:01.3756402Z
Command: docker exec -u vscode 4ce6ae052778 bash SCRATCH/issue-1082-runtime.sh
EXIT_CODE: 0
Output Summary:

```text
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
claude-swap v0.29.0
- claude-swap
- cswap
1000:1000 /home/vscode/.claude
1000:1000 /home/vscode/.codex
1000:1000 /home/vscode/.local/share/claude-swap
0:0 /etc/codex/config.toml
check_for_update_on_startup = false
cli_auth_credentials_store = "file"
AUTH_STATE_FILES
tmp/arg0-linux/codex-arg0oVOR3b/.lock
SOURCE_SHA256
429c1cd768e901c23c071048f8fa5267ffd2257f31a329ac4e8eef781df03165  .devcontainer/local/devcontainer.json
17c93d3b34a54659db11bbe0fd7fa289438cbdf0bd6721a3ca4a6924c0779cfe  .devcontainer/lib/workspace.sh
```

Raw output: SCRATCH/issue-1082-local-container-fresh-runtime.log
