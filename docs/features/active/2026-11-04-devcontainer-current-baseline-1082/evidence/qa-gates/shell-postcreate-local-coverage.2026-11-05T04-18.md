Timestamp: 2026-11-05T04-18
Started: 2026-11-05T04:18:16.2238165Z
Command: docker exec -u vscode -e WORKSPACE_FOLDER=/workspaces/drm-copilot -w /workspaces/drm-copilot 4ce6ae052778 kcov --include-pattern=/workspaces/drm-copilot/.devcontainer,/workspaces/drm-copilot/scripts/bash/container_versions.sh --exclude-pattern=/workspaces/drm-copilot/tests SCRATCH/issue-1082-final-kcov-postcreate-local .devcontainer/post-create.sh
EXIT_CODE: 0
Output Summary:

```text
[?1hDevcontainer verification: local
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
[OK] .devcontainer/local/devcontainer.json
[OK] Workspace virtual environment Python 3.13.18
All devcontainer checks passed.

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

```

Raw output: SCRATCH/issue-1082-shell-postcreate-local-coverage.log
