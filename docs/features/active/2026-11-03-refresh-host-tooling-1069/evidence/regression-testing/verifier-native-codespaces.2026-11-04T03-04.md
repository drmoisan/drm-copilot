Timestamp: 2026-11-04T03-04
Command: docker run --rm --user root -e CODESPACES=true --mount type=bind,source=WORKSPACE,target=/workspaces/drm-copilot,readonly --mount type=volume,target=/workspaces/drm-copilot/.venv --entrypoint bash issue-1069-codespaces-full -lc 'set -e; python -m venv /workspaces/drm-copilot/.venv; chown -R vscode:vscode /workspaces/drm-copilot/.venv; cd /tmp; runuser -u vscode -- bash /workspaces/drm-copilot/.devcontainer/verify-container.sh'
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
