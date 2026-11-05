Timestamp: 2026-11-05T04-16
Started: 2026-11-05T04:16:14.8450177Z
Command: docker exec -u vscode -w /workspaces/drm-copilot 1a90d86c1591 kcov --include-pattern=/workspaces/drm-copilot/.devcontainer,/workspaces/drm-copilot/scripts/bash/container_versions.sh --exclude-pattern=/workspaces/drm-copilot/tests SCRATCH/issue-1082-final-kcov-verifier .devcontainer/verify-container.sh
EXIT_CODE: 0
Output Summary:

```text
Devcontainer verification: codespaces
[OK] Debian GNU/Linux 12 (bookworm)
[OK] python 3.13.18
[OK] git 2.56.0
[OK] node v26.13.0
[OK] npm 11.20.0
[OK] pwsh 7.6.9
[OK] poetry 2.5.1
[OK] gh 2.103.3
[OK] dotnet 10.0.403
[OK] uv 0.13.7
[OK] claude 2.1.318
[OK] cswap 0.29.0
[OK] codex 0.166.0
[OK] shfmt v3.14.1
[OK] shellcheck 0.11.0
[OK] actionlint 1.7.12
[OK] gt 1.7.14
[OK] copilot 0.0.377
[OK] kcov v43
[OK] pester 6.2.0
[OK] pssa 1.25.0
[OK] bats is installed
[OK] bashdb is installed
[OK] .devcontainer/codespaces/devcontainer.json
[OK] Workspace virtual environment Python 3.13.18
All devcontainer checks passed.
```

Raw output: SCRATCH/issue-1082-shell-verifier-coverage.log
